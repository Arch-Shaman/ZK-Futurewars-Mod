--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local modoptions = Spring.GetModOptions() or {}

--------------------------------------------------------------------------------
-- system

spawnSquare				= 150	   -- size of the chicken spawn square centered on the burrow
spawnSquareIncrement	= 1		 -- square size increase for each unit spawned
burrowName				= "roost"   -- burrow unit name
burrowID                  = UnitDefNames[burrowName].id
queenName				= "chickenflyerqueen"
queenMorphName			= "chickenlandqueen"
miniQueenName			= "chicken_dragon"
minBaseDistance			= 2000
maxBaseDistance			= 3500
basePruneDistance          = 6000
minMenaceSeperation		= 700
propagateDist              = 750

alwaysVisible			= false	 -- chicken are always visible

alwaysEggs				= true			--spawn limited-lifespan eggs when not in Eggs mode?
eggDecayTime			= 180
burrowEggs				= 15	   -- number of eggs each burrow spawns

gameMode				= true
endlessMode				= false

tooltipMessage			= "Kill chickens and collect their eggs to get metal."

noTarget = {
	terraunit=true,
	wolverine_mine=true,
	roost=true,
	los_superwep=true,
	los_menace=true,
}

modes = {
	[0] = 0,
	[1] = 'Beginner',  -- Beginner - designed for somebody who's never played rts
	[2] = 'Very Easy', -- V. Easy - designed for a single low-tier player
	[3] = 'Easy',      -- Easy - designed for a sub-par pot of low-tier players
	[4] = 'Normal',    -- Normal - should challange the average pot of average players
	[5] = 'Hard',      -- Hard - will require a reasonably good and coordinated team to bust
	[6] = 'Suicidal',  -- Suicidal - meant for players better than the current best player
	[7] = 'Custom',
	[8] = 'Speed',     -- Normal at 2x speed
}
defaultDifficulty = modes[2]
testBuilding = UnitDefNames["energypylon"].id	--testing to place burrow
testBuildingQ = UnitDefNames["chicken_dragon"].id	--testing to place queen

--------------------------------------------------------------------------------
-- difficulty settings

queenTime = 35*60 -- hive anger counts up to queenTime through angerTime
                  -- a lot of things also scale up to queenTime through spring's in-game timer
                  -- an average game of chicken should last 40-50mins

gracePeriod = 210
chickenSpawnRate = 350
rampUpTime = 500

minBurrows = 10	-- Amount of burrows to have at 0:00
maxBurrows = 50	-- Amount of burrows to have at queenTime

waveSizeMult = 1	-- multiplier on wave size
waveSizePerValue = 0.3	-- wave size per human value
waveSizePerPlayer = 70	-- waev size per human team
waveDespawn = true

chicken_turret = "chickend"
chicken_shield = "chicken_rafflesia"
defenseMult = 1	--multuplier on the number of defenses
defenseEvoMult = 1	--multiplier on defense evo

queenMorphTime = {60*30, 120*30}	--lower and upper bounds for delay between morphs, gameframes
queenHealthMod = 1
burrowQueenTime = 25	-- how much killing a burrow shaves off the queen timer, seconds

menaceEvoMod = 0
menaceStartWave = 2
menaceStartNum = 1
menaceMaxNum = 2
menaceScalingMult = 1

strengthPerBurrow = 0.92	-- multiply strength by this when a burrow dies
strengthPerSecond = 0.003	-- how much strength increases per second

wrathPerBurrow = 0.09	-- how much wrath increases per wave
wrathPerSecond = 0.003	-- how much wrath increases per second

techCostMult = 1	-- modifies the tech cost for unlocking new chickens
techPerIncome = 30
techPerPlayer = -300

scoreMult = 1
scoreQueenTime = 2000
scorePerBurrow = 25
scorePerQueen = 1000

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
	[4] = "chickenc",
	[8] = "chickena",
}

chickenTechTree = {
	{max = 2, "chicken_pigeon", "chickens"}, --todo: rework chicken_drone as a jumper chicken
	{max = 3, "chicken_spidermonkey", "chicken_dodo", "chickenr"},--todo: add chicken_listener as a mini-shield
	{max = 2, "chickenwurm", "chicken_roc"},
	{max = 3, "chicken_sporeshooter", "chicken_shield", "chickenf"},--todo: add chicken_leaper as an orbital strike chicken
	{max = 2, "chickenblobber", "chicken_blimpy"},
	{max = 1, "chicken_tiamat"},
}

chicken_totaltech = 8 -- This number of techs would be researched by queenTime

chickenUnion = {}
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
		spawns = 0.25,
	},
	chickenspire = {
		cocoon = "chickenspire_cocoon",
		immobile = true,
	},
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
	['Beginner'] = {
		queenTime	    = 50*60,
		gracePeriod      = 330,
		chickenSpawnRate = 500,
		rampUpTime       = 1200,
		waveSizeMult     = 0.2,
		strengthPerSecond = 0.0015,
		menaceStartWave  = 3,
		menaceStartNum   = 1,
		menaceMaxNum     = 1,
		menaceEvoMod     = -3,
		defenseMult      = 0.2,
		defenseEvoMult   = 0.5,
		maxBurrows       = 15,
		cookeryPerSecond = 0,
		techCostMult     = 1.6,
		scoreMult        = 0.2,
	},
	
	['Very Easy'] = {
		queenTime	    = 45*60,
		gracePeriod      = 290,
		chickenSpawnRate = 450,
		rampUpTime       = 1200,
		waveSizeMult     = 0.3,
		strengthPerSecond = 0.002,
		menaceStartWave  = 3,
		menaceStartNum   = 1,
		menaceMaxNum     = 1,
		menaceEvoMod     = -2,
		defenseMult      = 0.3,
		defenseEvoMult   = 0.6,
		maxBurrows       = 20,
		cookeryPerSecond = 0,
		techCostMult     = 1.4,
		scoreMult        = 0.35,
	},
	
	['Easy'] = {
		queenTime	    = 40*60,
		gracePeriod	  = 250,
		chickenSpawnRate = 400,
		rampUpTime	   = 900,
		waveSizeMult	 = 0.5,
		strengthPerSecond = 0.0025,
		menaceStartNum   = 1,
		menaceMaxNum     = 2,
		menaceEvoMod     = -2,
		defenseMult      = 0.5,
		defenseEvoMult   = 0.8,
		techCostMult     = 1.2,
		scoreMult		 = 0.6,
	},

	['Normal'] = {
		waveSizeMult	 = 0.7,
		defenseEvoMult   = 0.9,
		techCostMult     = 1.1,
		menaceEvoMod     = -1,
		defenseMult      = 0.7,
		scoreMult		= 1,
	},

	['Hard'] = {
		waveSizeMult	 = 1.5,
		scoreMult   	 = 2.5,
	},

	['Suicidal'] = {
		waveSizeMult	 = 2.5,
		techCostMult     = 0.85,
		rampUpTime       = 350,
		menaceEvoMod     = 1,
		defenseEvoMult   = 1.2,
		scoreMult   	 = 6.9,
	},
	
	--['Suicidal'] = {
	--	waveSizeMult	 = 2.5,
	--	waveDespawn      = false,
	--	rampUpTime       = 350,
	--	menaceEvoMod     = 2,
	--	techCostMult     = 0.7,
	--	defenseMult      = 1.5,
	--	scoreMult   	 = 5,
	--},

	['Custom'] = {
		queenTime	    = modoptions.queentime and modoptions.queentime*60 or queenTime,
		gracePeriod	  = modoptions.gracePeriod or gracePeriod,
		chickenSpawnRate = modoptions.chickenspawnrate or chickenSpawnRate,
		rampUpTime	   = modoptions.ramppptime or rampUpTime,
		waveSizeMult	 = modoptions.wavesizemult or waveSizeMult,
		strengthPerSecond = modoptions.strengthpersecond and modoptions.strengthpersecond/100 or strengthPerSecond,
		menaceStartWave  = modoptions.menacestartwave or menaceStartWave,
		menaceStartNum   = modoptions.menacestartnum or menaceStartNum,
		menaceMaxNum     = modoptions.menacemaxnum or menaceMaxNum,
		menaceEvoMod     = modoptions.menaceevomod or menaceMaxNum,
		defenseMult      = modoptions.chickendefensemult or defenseMult,
		defenseEvoMult   = modoptions.chickendefenseevomult or defenseEvoMult,
		techCostMult     = modoptions.chickentechcostmult or techCostMult,
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
	end
end

defaultDifficulty = 'Normal'

-- special config (used by campaign)
if modoptions.chicken_nominiqueen then
	for _, d in pairs(difficulties) do
		d.miniQueenTime = {}
	end
end
if modoptions.chicken_minaggro then
	humanAggroMin = tonumber(modoptions.chicken_minaggro)
end
if modoptions.chicken_maxaggro then
	humanAggroMax = tonumber(modoptions.chicken_maxaggro)
end
if modoptions.chicken_maxtech then
	techTimeMax = tonumber(modoptions.chicken_maxtech)
end
if modoptions.chicken_endless then
	endlessMode = Spring.Utilities.tobool(modoptions.chicken_endless)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
