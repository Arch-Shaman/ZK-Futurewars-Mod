if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name      = "Strider Plate Blocker",
		desc      = "Fixes strider plate being able to create units without a parent.",
		author    = "Shaman",
		date      = "15 August, 2022",
		license   = "CC-0",
		layer     = 0, -- low enough to catch any geo creation.
		enabled   = false,
	}
end

local wantedDef = {
	[UnitDefNames["platestrider"].id] = true
}

local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitRulesParam = Spring.GetUnitRulesParam

function gadget:AllowUnitCreation(unitDefID, builderID, builderTeam, x, y, z, facing)
	return not (wantedDef[spGetUnitDefID(builderID)] and (spGetUnitRulesParam(builderID, "nofactory") or 0) == 1)
end
