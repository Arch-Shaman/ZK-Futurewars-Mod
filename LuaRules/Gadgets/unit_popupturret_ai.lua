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

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local handled = IterableMap.New()
VFS.Include("LuaRules/Configs/customcmds.h.lua")

local CHECK_RATE = 3 -- 10Hz
local wanted = {}

for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	if ud.customParams.popupholdfirehp and ud.isBuilding then -- this is probably a popup turret.
		wanted[i] = {
			minhealth = tonumber(ud.customParams.popupholdfirehp) or 0.33, -- hp % required to trigger hold fire
			maxhealth = tonumber(ud.customParams.popupunholdfirehp) or 0.5, -- hp % require to lift hold fire
			maxdisarm = 0.75, -- after being disarmed, wait until this much disarm before lifting hold fire.
		}
	end
end

-- speed ups --
local CMD_UNIT_CANCEL_TARGET = Spring.Utilities.CMD.UNIT_CANCEL_TARGET
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

local function AIToggleCommand(unitID, cmdParams, cmdOptions)
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

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced) -- we get unitAI cmd from tactical ai. this just plugs it into this script.
	if (cmdID == CMD_UNIT_AI) and wanted[unitDefID] then
		AIToggleCommand(unitID, cmdParams, cmdOptions)
		return false  -- command was used
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
			local hpProp = hp/maxhp
			local config = data.config
			
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
