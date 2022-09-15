if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name      = "Dangerous Reclaim",
		desc      = "Handles Dangerous Reclaim for RTGs",
		author    = "Shaman",
		date      = "1/22/2021",
		license   = "CC-0",
		layer     = 0,
		enabled   = true
	}
end

local wantedunits = {}
for i = 1, #UnitDefs do
	local cp = UnitDefs[i].customParams
	if cp["dangerous_reclaim"] then
		wantedunits[i] = true
	end
end

local spSetUnitHealth = Spring.SetUnitHealth
local spDestroyUnit = Spring.DestroyUnit
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local params = {health = 1, build = 1}

function gadget:UnitReverseBuilt(unitID, unitDefID, unitTeam)
	if wantedunits[unitDefID] then
		spSetUnitRulesParam(unitID, "dangerous", 1)
		spSetUnitHealth(unitID, params)
		spDestroyUnit(unitID, true)
	end
end
