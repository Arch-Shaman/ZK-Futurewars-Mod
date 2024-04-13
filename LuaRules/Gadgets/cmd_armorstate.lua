if (not gadgetHandler:IsSyncedCode()) then return end

function gadget:GetInfo() return {
	name      = "Armor State Command",
	desc      = "Reimplements armor state as a command for units like Desolator.",
	author    = "Shaman",
	date      = "31 August 2022",
	license   = "CC-0",
	layer     = 1, -- purposefully lower than popup turret ai to allow it to see the commands.
	enabled   = true,
} end



local spInsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local spFindUnitCmdDesc			= Spring.FindUnitCmdDesc
local spEditUnitCmdDesc			= Spring.EditUnitCmdDesc
local spGetUnitDefID			= Spring.GetUnitDefID
local spGetUnitHealth			= Spring.GetUnitHealth
local spSetUnitRulesParam		= Spring.SetUnitRulesParam

local inLOS = {inlos = true}
local CMD_ARMORSTATE = Spring.Utilities.CMD.ARMORSTATE

local cmdDesc = {
	id      = CMD_ARMORSTATE,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Toggle Armored',
	action  = 'armor',
	tooltip    = 'Toggles Armorstate',
	params     = {0, 'UNARMORED','ARMORED'}
}

local wanted = {}
local waiting = {}
local states = {} -- unitID = 0 / 1

for i = 1, #UnitDefs do
	if UnitDefs[i].customParams.hasarmorstate then
		wanted[i] = true
	end
end

local function UpdateRulesParam(unitID, state)
	spSetUnitRulesParam(unitID, "hunkerstate", state, inLOS)
end

local function CallUnitScriptFunction(unitID, state)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if env then
		Spring.UnitScript.CallAsUnit(unitID, env.OnArmorStateChanged, state)
	end
end

local function ToggleCommand(unitID, cmdParams)
	local def = spGetUnitDefID(unitID)
	if wanted[def] then
		local state = cmdParams[1]
		--Spring.Echo("New State: " .. state)
		local cmdDescID = spFindUnitCmdDesc(unitID, CMD_ARMORSTATE)
		if (cmdDescID) then
			local buildprogress = select(5, spGetUnitHealth(unitID))
			cmdDesc.params[1] = state
			spEditUnitCmdDesc(unitID, cmdDescID, { params = cmdDesc.params})
			if state ~= states[unitID] and buildprogress >= 1 then
				CallUnitScriptFunction(unitID, state)
				UpdateRulesParam(unitID, state)
			elseif buildprogress < 1 then
				waiting[unitID] = state
			end
			states[unitID] = state
		end
	end
end

function gadget:UnitFinished(unitID)
	if waiting[unitID] then
		local state = waiting[unitID]
		CallUnitScriptFunction(unitID, state)
		UpdateRulesParam(unitID, state)
		waiting[unitID] = nil
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if wanted[unitDefID] then
		cmdDesc.params[1] = 0
		spInsertUnitCmdDesc(unitID, cmdDesc)
		states[unitID] = 0
		UpdateRulesParam(unitID, 0)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	states[unitID] = nil
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if (cmdID ~= CMD_ARMORSTATE) then
		return true  -- command was not used
	end
	if not wanted[unitDefID] then
		return false
	end
	ToggleCommand(unitID, cmdParams)
	return false  -- command was used
end
