if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Firecycle Command",
		desc      = "Controls flamethrower units's preferences",
		author    = "Shaman / Hellaratsastaja212",
		date      = "12.20.2021",
		license   = "CC-0",
		layer     = 9999, -- preferably higher?
		enabled   = true  --  loaded by default?
	}
end

local unitStates = {}
local wantedDefs = {} -- unitDefID = {[weaponID] = true}
local wantedWeaponDefs = {}

-- speed ups --
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spIsUnitInLos = Spring.IsUnitInLos
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spFindUnitCmdDesc = Spring.FindUnitCmdDesc
local spEditUnitCmdDesc = Spring.EditUnitCmdDesc
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitWeaponTarget = Spring.GetUnitWeaponTarget
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local CMD_FIRECYCLE = Spring.Utilities.CMD.FIRECYCLE

Spring.Echo("[Firecycle] Scanning units")
for i = 1, #UnitDefs do
	local weapons = UnitDefs[i].weapons
	if weapons then
		for w = 1, #weapons do
			local weaponDefID = weapons[w].weaponDef
			if WeaponDefs[weaponDefID].customParams.usefirecycle then
				Spring.Echo("Added " .. weaponDefID)
				wantedWeaponDefs[weaponDefID] = true
				if wantedDefs[i] == nil then
					wantedDefs[i] = {}
				end
				wantedDefs[i][#wantedDefs[i] + 1] = w
			end
		end
	end
end

local firecycle_desc = {
	id      = CMD_FIRECYCLE,
	type    = CMDTYPE.ICON_MODE,
	name	= 'Fire Cycle',
	tooltip = 'Makes this unit prioritize units not already on fire.',
	action  = 'firecycle',
	params  = {0, 'Spread Fire Off', 'Spread Fire On'},
}



local function IsUnitInLos(unitID, attackerID) -- gadgets can see everything. Don't reveal info about units in fog.
	return spIsUnitInLos(unitID, spGetUnitAllyTeam(attackerID)) or false
end

local function IsUnitOnFire(unitID)
	return (spGetUnitRulesParam(unitID, "on_fire") or 0) == 1
end

function gadget:AllowWeaponTarget(attackerID, targetID, attackerWeaponNum, attackerWeaponDefID, defPriority)
	if not wantedWeaponDefs[attackerWeaponDefID] then
	end
	if defPriority == nil then
		return true, nil
	end
	local priority = defPriority
	if unitStates[attackerID] and IsUnitOnFire(targetID) then
		priority = priority * 900
	end
	--Spring.Echo("Priority: " .. priority)
	return true, priority
end

local function ToggleCommand(unitID, cmdParams)
	local state = cmdParams[1]
	local cmdDescID = spFindUnitCmdDesc(unitID, CMD_FIRECYCLE)
	
	if (cmdDescID) then
		firecycle_desc.params[1] = state
		spEditUnitCmdDesc(unitID, cmdDescID, { params = firecycle_desc.params})
	end
	unitStates[unitID] = state == 1
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if (cmdID ~= CMD_FIRECYCLE) then
		return true  -- command was not used
	end
	if unitStates[unitID] == nil then
		return false
	end
	ToggleCommand(unitID, cmdParams)
	return false  -- command was used
end

function gadget:AllowCommand_GetWantedCommand()
	return {[CMD_FIRECYCLE] = true}
end

function gadget:UnitDestroyed(unitID)
	unitStates[unitID] = nil
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if wantedDefs[unitDefID] then
		unitStates[unitID] = false
		spInsertUnitCmdDesc(unitID, firecycle_desc)
		ToggleCommand(unitID, {0}, {})
	end
end

local function GetWeaponIsFiringAtSomething(unitID, weaponID)
	local type, isUserTarget = spGetUnitWeaponTarget(unitID, weaponID)
	return isUserTarget == true
end


local function NotifyUnitSwitchTarget(unitID)
	--Spring.Echo("NotifyUnitSwitchTarget")
	if unitStates[unitID] then
		if not GetWeaponIsFiringAtSomething(unitID, 1) then
			Spring.SetUnitTarget(unitID, nil) -- try to force unit to pick a new target.
			spGiveOrderToUnit(unitID, CMD.WAIT, {}, {})
			spGiveOrderToUnit(unitID, CMD.WAIT, {}, {})
			local currentcommand = Spring.GetUnitCommands(unitID, 1)
			local queueLength = Spring.GetUnitCommands(unitID, 0)
			if queueLength == 1 and currentcommand[1].id == CMD.ATTACK  then
				spGiveOrderToUnit(unitID, CMD.STOP, {}, {})
			end
			--Spring.Echo("Switch!")
		end
	end
end

local function AddUnitOverride(unitID) -- for commanders.
	unitStates[unitID] = false
	spInsertUnitCmdDesc(unitID, firecycle_desc)
	ToggleCommand(unitID, {0}, {})
end

GG.FireCycle = {}
GG.FireCycle.AddUnit = AddUnitOverride
GG.FireCycle.NotifyUnitSwitchTarget = NotifyUnitSwitchTarget
