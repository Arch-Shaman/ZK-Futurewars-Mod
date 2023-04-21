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

VFS.Include("LuaRules/Configs/customcmds.h.lua")

local cmdDesc = {
	id      = CMD_AMMO_SELECT_GENERIC,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Toggle Ammo',
	action  = 'ammo',
	tooltip    = 'Toggles Ammo',
	params     = {0, 0}
}

local config = {}
local states = {}
local wantedCMDs = {}

do
	local num = 1
	for i = 1, #UnitDefs do
		local ud = UnitDefs[i]
		if ud.customParams.ammocount then
			config[i] = CMD_AMMO_SELECT_GENERIC + num
			wantedCMDs[CMD_AMMO_SELECT_GENERIC + num] = true
			num = num + 1
		end
	end
end

-- Speed ups --
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spEditUnitCmdDesc = Spring.EditUnitCmdDesc
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local inLOS = {inlos = true}

local function UpdateRulesParam(unitID, state)
	spSetUnitRulesParam(unitID, "ammostate", state, inLOS)
end

local function CallUnitScriptFunction(unitID, state)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if env then
		Spring.UnitScript.CallAsUnit(unitID, env.OnAmmoChange, state)
	end
end

local function ChangeUnitAmmo(unitID, num)
	if num then
		UpdateRulesParam(unitID, num)
		CallUnitScriptFunction(unitID, num)
	end
end

local function ToggleCommand(unitID, cmdParams, def)
	if config[def] then
		local state = cmdParams[1]
		--Spring.Echo("New State: " .. state)
		local cmdDescID = spFindUnitCmdDesc(unitID, config[def])
		if (cmdDescID) then
			cmdDesc.params[1] = state
			cmdDesc.id = config[def]
			spEditUnitCmdDesc(unitID, cmdDescID, { params = cmdDesc.params})
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if not config[unitDefID] then
		return false
	end
	ToggleCommand(unitID, cmdParams, unitDefID)
	return false  -- command was used
end

function gadget:AllowCommand_GetWantedCommand()
	return wantedCMDs
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if config[unitDefID] then
		cmdDesc.params[1] = 0
		cmdDesc.id = config[unitDefID]
		spInsertUnitCmdDesc(unitID, cmdDesc)
		UpdateRulesParam(unitID, 0)
	end
end
