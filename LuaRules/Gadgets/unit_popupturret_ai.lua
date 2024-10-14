if (not gadgetHandler:IsSyncedCode()) then return end

function gadget:GetInfo() return {
	name      = "Popup Turret AI",
	desc      = "Popup turrets will automatically hold fire when disarmed or low hp.",
	author    = "Shaman",
	date      = "26 July 2022",
	license   = "CC-0",
	layer     = 0,
	enabled   = true,
} end

local IterableMap = Spring.Utilities.IterableMap
local handled = IterableMap.New()

local CHECK_RATE = 3 -- 10Hz
local wanted = {}
local exceptions = {}

for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	if ud.customParams.popupholdfirehp and ud.isBuilding then -- this is probably a popup turret.
		wanted[i] = {
			minhealth = tonumber(ud.customParams.popupholdfirehp) or 0.33, -- hp % required to trigger hold fire
			maxhealth = tonumber(ud.customParams.popupunholdfirehp) or 0.5, -- hp % require to lift hold fire
			maxdisarm = 0.75, -- after being disarmed, wait until this much disarm before lifting hold fire.
			usearmorstate = ud.customParams.popupusearmorstate ~= nil,
		}
	end
end

-- speed ups --
local CMD_UNIT_CANCEL_TARGET = Spring.Utilities.CMD.UNIT_CANCEL_TARGET
local CMD_UNIT_AI            = Spring.Utilities.CMD.UNIT_AI
local CMD_ARMORSTATE         = Spring.Utilities.CMD.ARMORSTATE
local EMPTY                  = {}
local spFindUnitCmdDesc      = Spring.FindUnitCmdDesc
local spEditUnitCmdDesc      = Spring.EditUnitCmdDesc
local spGetUnitRulesParam    = Spring.GetUnitRulesParam
local spGetUnitHealth        = Spring.GetUnitHealth
local spGetUnitStates        = Spring.GetUnitStates
local spGetUnitDefID         = Spring.GetUnitDefID

-- Unit Addition / Removal --
local function AddUnit(unitID)
	local t = {
		holdFire = false,
		hpHoldFire = false,
		disarmHoldFire = false,
		config = wanted[Spring.GetUnitDefID(unitID)],
	}
	IterableMap.Add(handled, unitID, t)
end

local function RemoveUnit(unitID)
	IterableMap.Remove(handled, unitID)
end

-- Unit AI Command --

local unitAICmdDesc = {
	id      = CMD_UNIT_AI,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Unit AI',
	action  = 'unitai',
	tooltip    = 'Toggles smart unit AI for the unit',
	params     = {1, 'AI Off','AI On'}
}

local function AIToggleCommand(unitID, cmdParams)
	local def = spGetUnitDefID(unitID)
	if wanted[def] then
		local state = cmdParams[1]
		local cmdDescID = spFindUnitCmdDesc(unitID, CMD_UNIT_AI)
		if (cmdDescID) then
			unitAICmdDesc.params[1] = state
			spEditUnitCmdDesc(unitID, cmdDescID, { params = unitAICmdDesc.params})
			if state == 1 then
				AddUnit(unitID)
			else
				RemoveUnit(unitID)
			end
		end
	end
end

local function CheckState(unitID, state) -- user overrides something.
	local data = IterableMap.Get(handled, unitID)
	if data then
		return data.holdFire ~= state
	else
		return false
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced) -- we get unitAI cmd from tactical ai. this just plugs it into this script.
	if (cmdID == CMD_UNIT_AI) and wanted[unitDefID] then
		AIToggleCommand(unitID, cmdParams)
		return false  -- command was used
	end
	if cmdID == CMD_ARMORSTATE and wanted[unitDefID] then
		if CheckState(unitID, cmdParams[1] == 1) then
			--Spring.Echo("added an exception")
			exceptions[unitID] = true
		else
			exceptions[unitID] = nil
		end
	end
	if cmdID == CMD.FIRE_STATE and wanted[unitDefID] and not wanted[unitDefID].usearmorstate then
		local isHoldFire = cmdParams[1] == 0
		if CheckState(unitID, isHoldFire) then
			--Spring.Echo("added an exception")
			exceptions[unitID] = true
		else
			exceptions[unitID] = nil
		end
	end
	return true  -- command wasnt used
end

-- Rest --

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if wanted[unitDefID] then
		AddUnit(unitID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	if wanted[unitDefID] then
		RemoveUnit(unitID)
	end
end

function gadget:GameFrame(f)
	if f%CHECK_RATE == 0 then
		for unitID, data in IterableMap.Iterator(handled) do
			local disarmFrame = spGetUnitRulesParam(unitID, "disarmframe") or -1
			local disarmed = (spGetUnitRulesParam(unitID, "disarmed") or 0) == 1
			local disarmProp = (disarmFrame - f)/1200
			local hp, maxhp, _ = spGetUnitHealth(unitID)
			if not hp then
				Spring.Echo("[Popup Turret] Safety: " .. unitID .. " is nil, removing.")
				RemoveUnit(unitID)
			else
				local hpProp = hp/maxhp
				local config = data.config
				local useArmorState = config.usearmorstate
				
				if data.hpHoldFire and hpProp >= config.maxhealth then
					data.hpHoldFire = false
				elseif not data.hpHoldFire and hpProp < config.minhealth then
					data.hpHoldFire = true
				end
				if data.disarmHoldFire and disarmProp <= config.maxdisarm then
					data.disarmHoldFire = false
				elseif not data.disarmHoldFire and disarmed then
					data.disarmHoldFire = true
				end
				if data.holdFire and (not data.hpHoldFire and not data.disarmHoldFire) then
					data.holdFire = false
				elseif not data.holdFire and (data.hpHoldFire or data.disarmHoldFire) then
					data.holdFire = true
				end
				
				-- ensure our state matches --
				if exceptions[unitID] == nil then
					if useArmorState then
						local armorstate = spGetUnitRulesParam(unitID, "hunkerstate") == 1
						if data.holdFire and not armorstate then
							GG.DelegateOrder(unitID, CMD_ARMORSTATE, {1}, 0)
						elseif not data.holdFire and armorstate then
							GG.DelegateOrder(unitID, CMD_ARMORSTATE, {0}, 0)
						end
					else
						local isHoldFire = spGetUnitStates(unitID).firestate == 0
						if isHoldFire ~= data.holdFire then
							if data.holdFire then
								GG.DelegateOrder(unitID, CMD.STOP, {}, 0) -- stop force fire / set target / etc. We want to close up immediately.
								GG.DelegateOrder(unitID, CMD.FIRE_STATE, {0}, 0) -- set hold fire
							else
								GG.DelegateOrder(unitID, CMD.FIRE_STATE, {2}, 0) -- clear hold fire.
							end
						end
					end
				end
			end
		end
	end
end
