aiCommanders = {}
ploppableDefs = {}
for unitDefID, unitDef in pairs(UnitDefs) do
	local cp = unitDef.customParams
	if cp.ai_start_unit then
		aiCommanders[unitDefID] = true
	end
	if cp.ploppable then
		ploppableDefs[unitDefID] = true
	end
end

ploppables = {
	"factoryhover",
	"factoryveh",
	"factorytank",
	"factoryshield",
	"factorycloak",
	"factoryamph",
	"factoryjump",
	"factoryspider",
	"factoryship",
	"factoryplane",
	"factorygunship",
}

ploppableDefs = {}
for i = 1, #ploppables do
	local ud = UnitDefNames[ploppables[i]]
	if ud and ud.id then
		ploppableDefs[ud.id ] = true
	end
end

-- starting resources
START_METAL   = 400
START_ENERGY  = 400

INNATE_INC_METAL   = 2
INNATE_INC_ENERGY  = 2
START_STORAGE = 0

local commwars = false
if (Spring.GetModOptions) then
	local modOptions = Spring.GetModOptions()
    if modOptions then
		commwars = modOptions.commwars == "1"
	end
end
if commwars then
	INNATE_INC_METAL = 9
	INNATE_INC_ENERGY = 10000
end


COMM_SELECT_TIMEOUT = 30 * 15 -- 15 seconds

DEFAULT_UNIT = UnitDefNames["dyntrainer_strike_base"].id
DEFAULT_UNIT_NAME = "Ambush Trainer"
