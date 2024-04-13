if (not gadgetHandler:IsSyncedCode()) then return end

function gadget:GetInfo() return {
	name      = "Take off command",
	desc      = "Gives flying units a take off command.",
	author    = "Shaman",
	date      = "22 September 2022",
	license   = "CC-0",
	layer     = 0,
	enabled   = true,
} end

local CMD_IMMEDIATETAKEOFF = Spring.Utilities.CMD.IMMEDIATETAKEOFF

local takeoffCMD = {
	id      = CMD_IMMEDIATETAKEOFF,
	name    = "Takeoff",
	action  = "takeoff",
	cursor  = 'Repair',
	type    = CMDTYPE.ICON,
}

local wantedUnits = {}

for i = 1, #UnitDefs do
	local unitDef = UnitDefs[i]
	local movetype = Spring.Utilities.getMovetype(unitDef)
	if (movetype == 1 or movetype == 0) and (not Spring.Utilities.tobool(unitDef.customParams.cantuseairpads)) then
		wantedUnits[i] = true
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if wantedUnits[unitDefID] then
		Spring.InsertUnitCmdDesc(unitID, takeoffCMD)
	end
end
