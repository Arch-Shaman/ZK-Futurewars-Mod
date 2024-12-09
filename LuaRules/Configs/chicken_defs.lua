--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local modoptions = Spring.GetModOptions() or {}

--------------------------------------------------------------------------------
-- system

spawnSquare				= 150	   -- size of the chicken spawn square centered on the burrow
spawnSquareIncrement	= 1		 -- square size increase for each unit spawned
burrowName				= "roost"   -- burrow unit name
burrowID                = UnitDefNames[burrowName].id
queenName				= "chickenflyerqueen"
queenMorphName			= "chickenlandqueen"
miniQueenName			= "chicken_dragon"
minBaseDistance			= 2000
maxBaseDistance			= 3500
basePruneDistance       = 6000
minMenaceSeperation		= 700
propagateDist           = 750

alwaysVisible			= false	 -- chicken are always visible

alwaysEggs				= true			--spawn limited-lifespan eggs when not in Eggs mode?
eggDecayTime			= 180
burrowEggs				= 15	   -- number of eggs each burrow spawns

gameMode				= true
endlessMode				= false
speedChickens           = false

tooltipMessage			= "Kill chickens and collect their eggs to get metal."

noTarget = {
	terraunit=true,
	wolverine_mine=true,
	roost=true,
	los_superwep=true,
	los_menace=true,
}

idToDifficulty = {
    [0] = 0,
    [1] = 'Casual',
    [2] = 'Normal',
    [3] = 'Hard',
    [4] = 'Brutal',
    [5] = 'Suicidal',
    [6] = 'Nightmare',
    [7] = 'Annihilation',
    [8] = 'Custom',
}
difficultyToId = {}
for id, difficulty in pairs(idToDifficulty) do
	difficultyToId[difficulty] = id
end


testBuilding = UnitDefNames["energypylon"].id	--testing to place burrow
testBuildingQ = UnitDefNames["chicken_dragon"].id	--testing to place queen

--------------------------------------------------------------------------------
-- difficulty settings

queenTime = 30*60 -- hive anger counts up to queenTime through angerTime
                  -- a lot of things also scale up to queenTime through spring's in-game timer
                  -- an average game of chicken should last 40-50mins
queenTimePerBurrow = 30

gracePeriod = 135
wavePeriod = 120
initialGraceBonus = 45
--chickenSpawnRate = 255
rampUpTime = 350

minBurrows = 10	-- Amount of burrows to have at 0:00
maxBurrows = 50	-- Amount of burrows to have at queenTime

waveSizeMult = 1	-- multiplier on wave size
chickenWaveExponent = 2
baseWaveSize = 200
waveSizePerValue = 0.0004	-- wave size per human value
waveSizePerPlayer = 100	-- wave size per human team
waveSizeBase = -100
baseHyperEvo = 1
waveDespawn = true

chicken_turret = "chickend"
chicken_shield = "chicken_rafflesia"
defenseWaveExponent = 2
defenseMult = 1	--multuplier on the number of defenses
defenseEvoMult = 1	--multiplier on defense evo

queenMorphTime = {80*30, 100*30}	--lower and upper bounds for delay between morphs, gameframes
queenHealthMod = 1
burrowQueenTime = 25	-- how much killing a burrow shaves off the queen timer, seconds

menaceEvoMod = 0
menaceStartWave = 2
menaceMaxNum = 1
menaceScalingMult = 1
menaceEvoSpeedMod = 1

strengthPerBurrow = 0.95	-- multiply strength by this when a burrow dies
strengthPerSecond = 0.003	-- how much strength increases per second

wrathPerBurrow = 0.09	-- how much wrath increases per wave
wrathPerSecond = 0.003	-- how much wrath increases per second

techCostMult = 1	-- modifies the tech cost for unlocking new chickens
techPerIncome = 30    -- Note: Unused
techPerPlayer = -300  -- Note: Unused
startTechs = 0

scoreMult = 1
scoreQueenTime = 1500
scorePerBurrow = 25
scorePerQueen = 750

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

VFS.Include("LuaRules/Utilities/tablefunctions.lua")

local function Copy(original)   -- Warning: circular table references lead to
	local copy = {}			   -- an infinite loop.
	for k, v in pairs(original) do
		if (type(v) == "table") then
			copy[k] = Copy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

stockChickens = {
	[3] = "chickenc",
	[6] = "chickena",
}

chickenTechTree = {
	{max = 1, "chicken_pigeon", "chickens"},
	{max = 1, "chicken_spidermonkey", "chickenr"},
	-- chickenc
	{max = 1, "chicken_dodo", "chicken_roc"},
	{max = 1, "chickenwurm", "chickenf"},
	-- chickena
	{max = 2, "chickenblobber", "chicken_blimpy"},
	{max = 2, "chicken_sporeshooter", "chicken_shield"},--todo: add chicken_leaper as an orbital strike chicken
	{max = 1, "chicken_tiamat"},
}


chickenTechTime = 220 -- Time per tech, in seconds

chickenUnion = {}
chickenUnionNames = {}
chickenTypes = {}
chickenStructures = {}
chickenMenaces = {}
chickensThatNeedBogusDefs = {}

chickenUncapturable = {}

for uid, uDef in pairs(UnitDefs) do
	local params = uDef.customParams
	if params.chicken then
		local data = {
			eggName = (params.original_chicken or uDef.name).."_egg",
			spawncost = (params.chicken_spawncost or uDef.buildTime)
		}
		if params.chicken_menace then
			data.eggName = "chicken_dragon_egg"
			chickenMenaces[uid] = data
		elseif params.chicken_structure then
			chickenStructures[uid] = data
		else
			chickenTypes[uid] = data
		end
		if params.chicken_uncapturable then
			chickenUncapturable[uid] = true
		end
		if not params.chicken_roost then
			chickenUnion[uid] = data
			chickenUnionNames[uDef.name] = data
		end
		if params.chicken_needs_bogus_defs then
			chickensThatNeedBogusDefs[uDef.name] = true
		end
	end
end

cocoonMode = true

menaceNames = {
	chicken_dragon = {
		cocoon = "chicken_dragon_cocoon",
	},
	chickenbroodqueen = {
		cocoon = "chickenbroodqueen_cocoon",
		spawns = 0.4,
	},
	chickenspire = {
		cocoon = "chickenspire_cocoon",
		immobile = true,
	},
}

chickenQueenMenaceDef = {
	spawns = 0.4,
	scaleSpawnByDamage = true,
}

menaceDefs = {}

for k, v in pairs(menaceNames) do
	v.name = k
	v.cocoonID = UnitDefNames[v.cocoon].id
	
	menaceDefs[UnitDefNames[k].id] = v
end



-- TODO: add support for
--     campaign_chicken_types_offense
--     campaign_chicken_types_defense
--     campaign_chicken_types_support

local function SetCustomMiniQueenTime()
	if modoptions.miniqueentime then
		if modoptions.miniqueentime == 0 then return nil
		else return modoptions.miniqueentime end
	else
		return 0.6
	end
end
	
difficulties = {
	['Casual'] = {
		queenTime	     = 40*60,
		gracePeriod      = 210,
		waveSizeMult     = 0.25,
		strengthPerSecond = 0.001,
		menaceStartWave  = 3,
		menaceMaxNum     = 1,
		menaceEvoMod     = -2,
		defenseMult      = 0.2,
		defenseEvoMult   = 0.4,
		maxBurrows       = 25,
		cookeryPerSecond = 0,
		techCostMult     = 1.75,
		scoreMult        = 0.25,
	},

	['Normal'] = {
		queenTime	     = 38*60,
		gracePeriod      = 195,
		waveSizeMult     = 0.4,
		strengthPerSecond = 0.0015,
		menaceStartWave  = 3,
		menaceMaxNum     = 1,
		menaceEvoMod     = -1,
		defenseMult      = 0.2,
		defenseEvoMult   = 0.4,
		maxBurrows       = 25,
		cookeryPerSecond = 0,
		techCostMult     = 1.5,
		scoreMult        = 0.4,
	},
	
	['Hard'] = {
		queenTime	     = 36*60,
		gracePeriod      = 180,
		waveSizeMult     = 0.6,
		strengthPerSecond = 0.002,
		menaceStartWave  = 3,
		menaceMaxNum     = 1,
		menaceEvoMod     = 0,
		defenseMult      = 0.3,
		defenseEvoMult   = 0.5,
		maxBurrows       = 40,
		cookeryPerSecond = 0,
		techCostMult     = 1.2,
		scoreMult        = 0.6,
	},
	
	['Brutal'] = {
		queenTime	     = 34*60,
		gracePeriod	     = 165,
		waveSizeMult	 = 1,
		strengthPerSecond = 0.0025,
		menaceEvoMod     = 0,
		defenseMult      = 0.5,
		defenseEvoMult   = 0.65,
		scoreMult		 = 1,
	},

	['Suicidal'] = {
		queenTime	     = 32*60,
		gracePeriod	     = 150,
		startTechs       = 1,
		waveSizeMult	 = 1.4,
		baseHyperEvo     = 1.5,
		techCostMult     = 0.9,
		menaceEvoMod     = 1,
		defenseMult      = 0.7,
		defenseEvoMult   = 0.85,
		scoreMult	     = 2,
	},

	['Nightmare'] = {
		waveSizeMult	 = 1.75,
		baseHyperEvo     = 3,
		scoreMult   	 = 5,
		startTechs       = 1,
		menaceEvoMod     = 2,
		defenseEvoMult   = 1,
		techCostMult     = 4,
	},

	['Annihilation'] = {
		waveSizeMult	 = 2,
		baseHyperEvo     = 6,
		techCostMult     = 0.7,
		startTechs       = 1,
		menaceStartWave  = 1,
		menaceEvoMod     = 3,
		defenseEvoMult   = 1,
		scoreMult   	 = 10,
	},

	['Custom'] = {
		-- We need to check if these values are nil if we are doing math on them
		-- Otherwise, nil values are automatically replaced with defaults
		queenTime	     = (modoptions.chickenqueentime and modoptions.chickenqueentime * 60),
		gracePeriod      = modoptions.chickengraceduration,
		wavePeriod       = modoptions.chickenwaveduration,
		rampUpTime       = modoptions.chickenramptime,
		waveSizeMult     = modoptions.chickenwavesizemult,
		strengthPerSecond = (modoptions.chickenstrengthpersec and modoptions.chickenstrengthpersec / 100),
		menaceStartWave  = modoptions.chickenmenacestart,
		menaceMaxNum     = modoptions.chickenmenacemax,
		menaceEvoMod     = modoptions.chickenmenaceevomod,
		defenseMult      = modoptions.chickendefensemult,
		defenseEvoMult   = (modoptions.chickendefenseevomult and modoptions.chickendefenseevomult * 0.65),
		techCostMult     = (modoptions.chickentechcostmult and 1 / modoptions.chickentechcostmult),
		baseHyperEvo     = (modoptions.chickenbasehyperevo and chickenbasehyperevo + 1),
		startTechs       = modoptions.chickenstarttechs,
		scoreMult        = 0,
	},
}

--[[
for chicken, t in pairs(chickenTypes) do
	t.timeBase = t.time
end
for chicken, t in pairs(supporters) do
	t.timeBase = t.time
end
for chicken, t in pairs(defenders) do
	t.timeBase = t.time
end
]]--

for _, d in pairs(difficulties) do
	d.timeSpawnBonus = (d.timeSpawnBonus or 0)/60

	if modoptions.speedchicken == "1" then
		d.queenTime = (d.queenTime or queenTime)*0.5
		d.gracePeriod = (d.gracePeriod or gracePeriod)*0.75
		d.chickenSpawnRate = (d.chickenSpawnRate or chickenSpawnRate)*0.75
		d.rampUpTime = (d.rampUpTime or rampUpTime)*0.5
		d.waveSizeMult = (d.waveSizeMult or waveSizeMult)*0.85
		-- nothing for d.strengthPerSecond
		-- nothing for d.menaceStartNum
		-- nothing for d.menaceMaxNum
		d.menaceEvoMod = (d.menaceEvoMod or menaceEvoMod)-1
		d.defenseMult = (d.defenseMult or defenseMult)*0.85
		-- nothing for d.defenseEvoMult
		-- nothing for d.defenseEvoMult
		d.techCostMult = (d.techCostMult or techCostMult)*0.75

		d.scoreMult = d.scoreMult
	end
end

if modoptions.chicken_endless then
	endlessMode = Spring.Utilities.tobool(modoptions.chicken_endless)
end
if modoptions.speedchicken then
	speedChickens = Spring.Utilities.tobool(modoptions.speedchicken)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
