if (not gadgetHandler:IsSyncedCode()) then
	return false
end

function gadget:GetInfo()
	return {
		name      = "UnitStealth",
		desc      = "Adds passive unit stealth capability",
		author    = "Sprung",
		date      = "2016-12-15",
		license   = "PD",
		layer     = 0,
		enabled   = true,
	}
end

local spSetUnitStealth = Spring.SetUnitStealth
local spSetUnitSonarStealth = Spring.SetUnitSonarStealth
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local immunity = {}

for i = 1, #UnitDefs do
	local def = UnitDefs[i]
	if def.stealth then
		immunity[i] = true
	end
end

function gadget:UnitCloaked(unitID)
	spSetUnitStealth(unitID, true)
	spSetUnitSonarStealth(unitID, true)
end

function gadget:UnitDecloaked(unitID, unitDefID)
	if immunity[unitDefID] or spGetUnitRulesParam(unitID, "comm_jammed") then
		return
	end
	spSetUnitStealth(unitID, false)
	spSetUnitSonarStealth(unitID, false)
end
