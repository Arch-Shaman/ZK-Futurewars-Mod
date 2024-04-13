if (not gadgetHandler:IsSyncedCode()) then return end

function gadget:GetInfo() return {
	name      = "Ammo States",
	desc      = "Implements ammo switching for units.",
	author    = "Shaman",
	date      = "20 April 2023",
	license   = "CC BY-NC-ND",
	layer     = 1,
	enabled   = true,
} end

local config = {}
local params = {}
local states = {}
local wantedCMDs = {}

do
	local num = 1
	for i = 1, #UnitDefs do
		local ud = UnitDefs[i]
		if ud.customParams.ammocount then
			config[i] = Spring.Utilities.CMD.AMMO_SELECT_GENERIC + num
			wantedCMDs[Spring.Utilities.CMD.AMMO_SELECT_GENERIC + num] = true
			num = num + 1
		end
	end
	local _, tooltips = VFS.Include("LuaRules/Configs/ammostateinfo.lua")
	for id, data in pairs(tooltips) do
		params[id] = data.stateTooltip
	end
end

-- Speed ups --
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spEditUnitCmdDesc = Spring.EditUnitCmdDesc
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spFindUnitCmdDesc = Spring.FindUnitCmdDesc
local inLOS = {inlos = true}

local function UpdateRulesParam(unitID, state)
	spSetUnitRulesParam(unitID, "ammostate", state, inLOS)
end

local function CallUnitScriptFunction(unitID, state)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if env then
		Spring.UnitScript.CallAsUnit(unitID, env.OnAmmoTypeChange, state)
	end
end

local function GetCmdDesc(cmdID)
	local cmdDesc = {
		id      = cmdID,
		type    = CMDTYPE.ICON_MODE,
		name    = 'Toggle Ammo',
		action  = 'ammo',
		tooltip    = 'Toggles Ammo',
		params     = {0}
	}
	for i = 1, #params[cmdID] do
		cmdDesc.params[#cmdDesc.params + 1] = params[cmdID][i]
	end
	return cmdDesc
end

local function GetCmdParams(cmdID)
	local ret = {0}
	for i = 1, #params[cmdID] do
		ret[#ret + 1] = params[cmdID][i]
	end
	return ret
end


local function ChangeUnitAmmo(unitID, num)
	--Spring.Echo("Changing " .. unitID .. " to state " .. num)
	UpdateRulesParam(unitID, num)
	CallUnitScriptFunction(unitID, num)
end

local function ToggleCommand(unitID, cmdParams, def, cmdID)
	if config[def] == cmdID then
		local state = cmdParams[1]
		--Spring.Echo("Got: " .. unitID .. " to state " .. state)
		local cmdDescID = spFindUnitCmdDesc(unitID, cmdID)
		if cmdDescID then
			local paramsToBeChanged = GetCmdParams(cmdID)
			paramsToBeChanged[1] = state
			ChangeUnitAmmo(unitID, state)
			spEditUnitCmdDesc(unitID, cmdDescID, { params = paramsToBeChanged})
		else
			--Spring.Echo("CMD Not found")
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if not config[unitDefID] then
		return false
	end
	ToggleCommand(unitID, cmdParams, unitDefID, cmdID)
	return false  -- command was used
end

function gadget:AllowCommand_GetWantedCommand()
	return wantedCMDs
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if config[unitDefID] then
		spInsertUnitCmdDesc(unitID, GetCmdDesc(config[unitDefID]))
		UpdateRulesParam(unitID, 0)
	end
end
