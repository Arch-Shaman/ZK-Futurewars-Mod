
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


function gadget:GetInfo()
	return {
		name     = "Chicken Handler",
		desc     = "Handes the chicken gamemode chickens",
		author   = "quantum, improved by KingRaptor and Stuffphoton",
		date     = "April 29, 2008", --last update: 2024 Nov 27st
		license  = "GNU GPL, v2 or later",
		layer    = 0,
		enabled  = true --	loaded by default?
	}
end



if (gadgetHandler:IsSyncedCode()) then
-- BEGIN SYNCED

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Speed-ups and upvalues
--

local Spring		= Spring
local math			= math
local Game			= Game
local table			= table
local ipairs		= ipairs
local pairs			= pairs

local random				= math.random
local max					= math.max
local min					= math.min
local floor					= math.floor
local sqrt					= math.sqrt
local eular = 2.718281828

local CMD_FIGHT				= CMD.FIGHT
local CMD_ATTACK			= CMD.ATTACK
local CMD_STOP				= CMD.STOP
local spEcho				= Spring.Echo
local spLog                 = Spring.Log
local spGiveOrderToUnit		= Spring.GiveOrderToUnit
local spGetTeamUnits		= Spring.GetTeamUnits
local spGetUnitTeam			= Spring.GetUnitTeam
local spGetCommandQueue		= Spring.GetCommandQueue
local spGetGameSeconds		= Spring.GetGameSeconds
local spGetGroundBlocked	= Spring.GetGroundBlocked
local spCreateUnit			= Spring.CreateUnit
local spGetUnitPosition		= Spring.GetUnitPosition
local spGetUnitDefID		= Spring.GetUnitDefID
local spGetUnitSeparation	= Spring.GetUnitSeparation
local spGetGameFrame		= Spring.GetGameFrame
local spGetUnitHealth		= Spring.GetUnitHealth
local spSetUnitHealth		= Spring.SetUnitHealth
local spSetUnitMaxHealth	= Spring.SetUnitMaxHealth
local spGetUnitsInCylinder	= Spring.GetUnitsInCylinder
local spValidUnitID			= Spring.ValidUnitID
local spGetTeamResources	= Spring.GetTeamResources
local spGetTeamRulesParam   = Spring.GetTeamRulesParam
local spGetUnitCommands     = Spring.GetUnitCommands
local spSetGameRulesParam   = Spring.SetGameRulesParam
local spDestroyUnit         = Spring.DestroyUnit
local GetUnitCost           = Spring.Utilities.GetUnitCost
local spSetUnitCosts        = Spring.SetUnitCosts
local spSetUnitWeaponDamages = Spring.SetUnitWeaponDamages
local spSetUnitWeaponState  = Spring.SetUnitWeaponState

local chickend

local mexesUnitDefID = {}
local mexes = {}
for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	if ud.customParams.metal_extractor_mult then
		mexesUnitDefID[-i] = true
		mexes[ud.name] = true
	end
end

local debugMode = false    -- prints debug info to the console
local tachyonChicken = false -- accelerates chickens """slightly"""
local section = 'chicken_handler.lua'

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local CMD_MOVESTATE_ROAM = CMD.MOVESTATE_ROAM
local maxTries		= 600
local propagateTries	= 400
local maxTriesSmall	= 100
local lava = (Game.waterDamage > 0)
local eggs = tobool(Spring.GetModOptions().eggs)
local pvp = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local luaAI = 0
local chickenTeamID
local computerTeams	= {}
local humanTeams	= {}
local numHumanTeams = 0
local gameFrameOffset = 0

local time = 1
local waveCostComponents = 1
local hyperevo = 1
local defenseHyperevo = 1
local menaceHyperevo = 1
local queenHyperevo = 1
local totalhumanValue = 1

-- anything that needs saving goes in here
local data = {
	queenID = nil,
	menaceNum = 1,
	targetCache = nil,
	burrows = {},
	burrowsQuadfield = Spring.Utilities.QuadField(250),
	chickens = {},
	menaces = {},

	waveSchedule = math.huge,	-- wave spawns when this gameframe is reached
	graceSchedule = math.huge,
	waveActive = false,
	waveNumber = 0,
	waveChickens = {{"chicken", 1}},
	waveTotalCost = 20,
	waveTotalWeight = 1,

	eggDecay = {},	-- indexed by featureID, value = game second
	targets = {},	--indexed by unitID, value = teamID
	menacePool = {},

	stockChicken = "chicken",
	unlockedChickens = {},
	unlockedChickensUnion = {chicken = true},
	unlockedCount = 0,
	nextUnlockTime = 0,

	cookery = 0,
	strength = 0.5,
	wrath = 0,

	endgame = false,
	victory = false,
	endMenaceNum = 0,

	morphFrame = -1,
	morphed = false,

	nextCookery = false,
	cookeryWork = 0,
	cookeryDelay = 0,

	angerTime = 1,
	angerTimeBonus = 1,
	techTime = 1,

	bonusScore = 0,
	totalScore = 0,
	currentAward = 0,

	gameoverSchedule = 1000000000
}

_G.data = data
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Load Config
--

do -- load config file
	local CONFIG_FILE = "LuaRules/Configs/chicken_defs.lua"
	local VFSMODE = VFS.RAW_FIRST
	local s = assert(VFS.LoadFile(CONFIG_FILE, VFSMODE))
	local chunk = assert(loadstring(s, file))
	setfenv(chunk, gadget)
	chunk()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Utility
--

local margins = 10
local mapx = Game.mapSizeX - margins
local mapz = Game.mapSizeZ - margins

local function clampPos(x, z)
	if x > mapx then -- clamp inside the map
		x = mapx
	elseif x < margins then
		x = margins
	end
	if z > mapz then -- ditto
		z = mapz
	elseif z < margins then
		z = margins
	end
	return x, z
end

local function SetToList(set)
	local list = {}
	for k in pairs(set) do
		list[#list+1] = k
	end
	return list
end


local function SetCount(set)
	local count = 0
	for k in pairs(set) do
		count = count + 1
	end
	return count
end


local function QTimeLerp(lmin, lmax)
	return lmin + (lmax - lmin) * min(time / queenTime, 1)
end

local hyperevoFactor = 350000
local function UpdateHyperevo()
	local costComponents = {}
	data.waveCostComponents = costComponents
	--costComponents.time = (waveSizePerTime) * (((time) ^ 2.5) * sqrt(waveSizeMult)) * (0.5 + #data.waveChickens/2) * 0.00003
	costComponents.time = (chickenWaveExponent ^ (data.waveNumber - 1)) * baseWaveSize * sqrt(waveSizeMult)
	costComponents.value = min(totalhumanValue, 1000000) * waveSizePerValue
	costComponents.base = waveSizePerPlayer * numHumanTeams + waveSizeBase
	costComponents.mult = sqrt(waveSizeMult) * max(0.5, data.strength)
	costComponents.wrath = (1 + data.wrath/2)

	costComponents.total = costComponents.time + costComponents.value + costComponents.base
	costComponents.total = costComponents.total * costComponents.mult * costComponents.wrath

	costComponents.max = data.waveTotalCost * 40 / #data.waveChickens
	hyperevo = max(costComponents.total / costComponents.max, 1) * baseHyperEvo
	costComponents.total = min(costComponents.total, costComponents.max)

	spSetGameRulesParam("chicken_hyperevo", hyperevo)

	defenseHyperevo = (defenseWaveExponent ^ min(data.waveNumber * defenseEvoMult, 5)) * hyperevo / max(0.5, data.strength)
	menaceHyperevo = eular ^ ((min(menaceEvoSpeedMod * (data.waveNumber - menaceStartWave), 5) * menaceScalingMult + menaceEvoMod)/ 2)
	--spEcho("hyperuwu", hyperevo, defenseHyperevo, menaceHyperevo, queenHyperevo)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Teams
--

local function getDifficaulty(str)
	local i
	for i=1, #idToDifficulty do
		if string.find(str, idToDifficulty[i]) then
			return i
		end
	end
	return 4 --default to normal
end



local modoptions = Spring.GetModOptions() or {}
if modoptions.chickengaiaai and difficultyToId[modoptions.chickengaiaai] then
	luaAI = difficultyToId[modoptions.chickengaiaai]
	chickenTeamID = Spring.GetGaiaTeamID()
end



if (not gameMode) then -- set human and computer teams
	humanTeams[0]		= true
	numHumanTeams       = 1
	computerTeams[1]	= true
	chickenTeamID		= 1
	luaAI			    = 4 -- Normal
else
	local teams = Spring.GetTeamList()
	-- the problem is with human controlled chickens, otherwise it counts them as robot-players and difficulty increases very much
	-- probably, ideally this needs to be taught to differentiate between human chickens and human robots...
	for _, teamID in pairs(teams) do
		local _, teamLuaAI = Spring.GetAIInfo(teamID)
		if (teamLuaAI and teamLuaAI ~= "" and string.find(string.lower(teamLuaAI), "chicken")) then
			local difficulty = getDifficaulty(teamLuaAI)
			if luaAI < difficulty then
				luaAI = difficulty
				chickenTeamID = teamID
			end
		end
	end
	if chickenTeamID then
		spLog(section, LOG.NOTICE, "Chicken Detected on team "..chickenTeamID.." with difficaulty "..luaAI)
		spSetGameRulesParam("chicken_chickenTeamID", chickenTeamID)
		for _, teamID in pairs(teams) do
			if Spring.AreTeamsAllied(teamID, chickenTeamID) then
				computerTeams[teamID] = true
			else
				humanTeams[teamID] = true
				if teamID ~= Spring.GetGaiaTeamID() then
					numHumanTeams = numHumanTeams + 1
				end
			end
		end
	end
end

spLog(section, LOG.NOTICE, "Detected ".. numHumanTeams .. " human teams")

if (not luaAI) or (luaAI == 0) then
	return false	-- nothing to do here, go home
end

spEcho("Initialising Chicken Handler")

local gaiaTeamID = Spring.GetGaiaTeamID()
local _, _, _, _, _, chickenAllyTeamID = Spring.GetTeamInfo(chickenTeamID)
computerTeams[gaiaTeamID] = nil
humanTeams[gaiaTeamID] = nil
computerTeams[chickenTeamID] = true

local humanTeamsOrdered = {}
for id,_ in pairs(humanTeams) do
	humanTeamsOrdered[#humanTeamsOrdered+1] = id
end

for i=1, #humanTeamsOrdered-1 do
	if not Spring.AreTeamsAllied(humanTeamsOrdered[i], humanTeamsOrdered[i+1]) then
		pvp = true
		spLog(gadget:GetInfo().name, LOG.NOTICE, "Chicken: PvP mode detected")
		break
	end
end

GG.Chicken = {}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Difficulty
--


local function SetGlobals(difficulty)
	for key, value in pairs(gadget.difficulties[difficulty]) do
		gadget[key] = value
	end
	gadget.difficulties = nil
end

SetGlobals(idToDifficulty[luaAI]) -- set difficulty

queenTime = queenTime * 30
chickenSpawnRate = gracePeriod + wavePeriod
queenTimePerBurrow = queenTimePerBurrow * 30
chickenTechTime = chickenTechTime * 30
strengthPerSecond = strengthPerSecond
chickenSpawnRate = max(chickenSpawnRate, gracePeriod + 60)
menaceBuildSpeed = 1 / 30 / ((chickenSpawnRate - gracePeriod) * 0.1 + gracePeriod)

spEcho("Chicken configured for "..tostring(idToDifficulty[luaAI]).." ("..luaAI..") difficaulty")

local function DisableBuildButtons(unitID, buildNames)
	for _, unitName in ipairs(buildNames) do
		if (UnitDefNames[unitName]) then
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, -UnitDefNames[unitName].id)
			if (cmdDescID) then
				local cmdArray = {disabled = true, tooltip = tooltipMessage}
				Spring.EditUnitCmdDesc(unitID, cmdDescID, cmdArray)
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Game End Stuff
--

local function KillAllComputerUnits()
	data.victory = true

	for unitID, _ in pairs(data.chickens) do
		spDestroyUnit(unitID, true)
	end
	for unitID, _ in pairs(data.menaces) do
		spDestroyUnit(unitID, true)
	end

	data.currentAward = math.max(data.currentAward, 2)
	spSetGameRulesParam("chicken_award", data.currentAward)

	spEcho("Chicken resigning")
	_G.chickenEventArgs = {type="resign"}
	SendToUnsynced("ChickenEvent")
	_G.chickenEventArgs = nil

	if chickenTeamID ~= Spring.GetGaiaTeamID() then
		data.gameoverSchedule = time + 90
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Spawn Dynamics
--

local function IsPlayerUnitNear(x, z, r)
	for teamID in pairs(humanTeams) do
		if (spGetUnitsInCylinder(x, z, r, teamID)[1]) then
			return true
		end
	end
end

-- used to generate eggs from burrows
local function SpawnEggs(x, y, z)
	local choices,choisesN = {},0
	local now = spGetGameSeconds() + math.floor(gameFrameOffset/30)

	for name in pairs(data.unlockedChickensUnion) do
		choisesN = choisesN + 1
		choices[choisesN] = name
	end
	if choisesN <= 0 then return end
	for i=1, burrowEggs do
		local choice = choices[random(choisesN)]
		local rx, rz = random(-30, 30), random(-30, 30)
		local eggID = Spring.CreateFeature(choice.."_egg", x+rx, y, z+rz, random(-32000, 32000))
		--if (eggID and (not eggs)) then data.eggDecay[eggID] = spGetGameSeconds() + eggDecayTime end
	end
end

--cleans up old eggs
local function DecayEggs()
	if eggs then return end
	for eggID, decayTime in pairs(data.eggDecay) do
		if spGetGameSeconds() >= decayTime then
			Spring.DestroyFeature(eggID)
			data.eggDecay[eggID] = nil
		end
	end
end

--[[
HOW BURROW TARGETING WORKS
In normal mode, burrows will send chickens after a random unit of the owner of the enemy unit closest to the burrow.
In PvP mode, each burrow caches a target ID: that of the nearest enemy structure (but not mines or terraform). This cache is updated every UnitCreated and UnitDestroyed.
	The chickens will attack a random unit belonging to cached target owner.
Idle chickens are automatically set to attack a random target (in GameFrame).
]]--

local function UpdateBurrowTarget(burrowID, targetArg)
	local targetData = data.burrows[burrowID]
	local oldTarget = targetData.targetID
	if not targetArg then
		for id,_ in pairs(data.targets) do
			local testDistance = spGetUnitSeparation(burrowID, id, true) or 100000
			if testDistance < targetData.targetDistance then
				targetData.targetDistance = testDistance
				targetData.targetID = id
			end
		end
	else
		local testDistance = spGetUnitSeparation(burrowID, targetArg, true) or targetData.targetDistance
		if testDistance < targetData.targetDistance then
			targetData.targetDistance = testDistance
			targetData.targetID = targetArg
		end
	end
	--spEcho("Final selected target ID: "..data.targetID)
	local validUnitID = spValidUnitID(data.targetID) --in case multiple UnitDestroyed() is called at same frame and burrow happen to choose a target before all Destroyed unit is registered.
	if validUnitID and targetData.targetID ~= oldTarget then
		targetData.targetTeam = spGetUnitTeam(data.targets[data.targetID])
		--spGiveOrderToUnit(burrowID, CMD_ATTACK, data.targetID, 0)
		--spEcho("Target for burrow ID ".. burrowID .." updated to target ID " .. data.targetID)
	elseif not validUnitID then
		targetData.targetID = nil
		--spGiveOrderToUnit(burrowID, CMD_STOP, 0, 0)
		--spEcho("Target for burrow ID ".. burrowID .." lost, waiting")
	end
end

local function AttackNearestEnemy(unitID)
	local targetID = Spring.GetUnitNearestEnemy(unitID)
	if (targetID) then
		local tx, ty, tz = spGetUnitPosition(targetID)
		spGiveOrderToUnit(unitID, CMD_FIGHT, {tx, ty, tz}, 0)
	end
end

local function ChooseTarget(unitID)
	local tries = 0
	local units = {}
	if (not unitID) or (spGetUnitTeam(unitID) == gaiaTeamID) then
		--makes chicken go for random unit belonging to owner of random player if unitID is NIL
		local humanTeamList = SetToList(humanTeams)
		if (not humanTeamList[1]) then
			return
		end
		repeat
			local teamID = humanTeamList[random(#humanTeamList)]
			units	= spGetTeamUnits(teamID)
			tries = tries + 1
		until (#units > 0 or tries >= 100)
	else
		--makes chicken go for random unit belonging to owner of closest enemy
		local teamID = spGetUnitTeam(unitID)
		units = spGetTeamUnits(teamID)
	end
	tries = 0
	local targetID
	if (units[2]) then
		repeat
		targetID = units[random(1,#units)]
			tries = tries + 1
		until (targetID and not (noTarget[UnitDefs[Spring.GetUnitDefID(targetID)].name]) or tries>=100)
	else
		targetID = units[1]
	end
	if not targetID then return end
	return {spGetUnitPosition(targetID)}
end

-- Unused for now
local colours = {
	{1, 0.1, 0.1}, -- Hunter-Killer / x3 dmg, x3 hp
	{0.9, 0.3, 0}, --
	{0.7, 0.7, 0}, -- Hypersonic    / x3 speed x3 rof
	{0.1, 1, 0.1}, -- Greater       / x10 hp
	{0.1, 0.1, 1}, --               / x2 range
	{0.7, 0, 0.7}, -- Enchanting    / armor field
}
local function applyHyperevo(unitName, evo, minTier, maxTier, round)
	local tier = math.log(evo, 2.718281828) * 2
	tier = max(min(tier, maxTier), minTier)
	if round then
		tier = floor(tier + 0.5)
	else
		tier = floor(tier + random())
	end
	if tier == 0 then
		return unitName
	else
		return unitName.."_"..tier
	end
end

local notActuallyDamage = {
	impulseFactor = true,
	impulseBoost = true,
	craterMult = true,
	craterBoost = true,
	craterBoost = true,
	dynDamageExp = true,
	dynDamageExp = true,
	dynDamageMin = true,
	dynDamageRange = true,
	craterAreaOfEffect = true,
	damageAreaOfEffect = true,
	edgeEffectiveness = true,
	explosionSpeed = true,
}

local function createWithHyperevo(unitName, evo, ...)
	local defwise = false
	if chickensThatNeedBogusDefs[unitName] then
		unitName = applyHyperevo(unitName, evo, -2, 20, false)
		defwise = true
	end
	local unitDef = UnitDefNames[unitName]
	local unitID = spCreateUnit(unitName, ...)
	if not unitID then
		spLog(section, LOG.ERROR, "createWithHyperevo: Failed to create unit " .. unitName .. " with evo " .. evo)
		return unitID
	end
	if not defwise then
		local tier = math.log(evo, 2.718281828) * 2
		hpMult = evo^1.5
		dmgMult = evo
		rangeMult = 1 + tier/10
		spSetUnitMaxHealth(unitID, unitDef.health * hpMult)
		spSetUnitHealth(unitID, math.huge)
		local cost = unitDef.metalCost * evo
		spSetUnitCosts(unitID, {buildTime = cost, metalCost = cost, energyCost = cost})
		GG.UnitModelRescale(unitID, rangeMult)
		for num, data in pairs(unitDef.weapons) do
			local weaponDef = WeaponDefs[data.weaponDef]
			spSetUnitWeaponState(unitID, num, {
				range = weaponDef.range * rangeMult,
				projectileSpeed = weaponDef.projectilespeed * rangeMult,
			})
			local newDamages = {}
			for key, value in pairs(weaponDef.damages) do
				if not notActuallyDamage[key] then
					newDamages[key] = value * dmgMult
				end
			end
			spSetUnitWeaponDamages(unitID, num, newDamages)
		end
	end

	return unitID
end

local function Choose1Chicken(techs, tier, inter, diff)
	local techEntry = techs[tier]
	if not techEntry then
		return nil
	end
	local allowed = {}
	for chix, _ in pairs(techEntry) do
		if (not inter or inter[chix]) and not diff[chix] then
			allowed[#allowed+1] = chix
		end
	end
	if #allowed == 0 then
		return nil
	else
		chix = allowed[random(#allowed)]
		diff[chix] = true
		return {chix, 1}
	end
end

local function ChooseChicken(units)
	local chix = {{data.stockChicken, 1}}
	local picked = {data.stockChicken}
	local techs = data.unlockedChickens
	local techNum = #techs
	chix[#chix+1] = Choose1Chicken(techs, techNum,   units, picked, cost)
	chix[#chix+1] = Choose1Chicken(techs, techNum-1, units, picked, cost)
	chix[#chix+1] = Choose1Chicken(techs, techNum-2, units, picked, cost)
-- 	if #chix > 2 then
-- 		local maxNum, maxIndex, i = 0, 1
-- 		for i=0, 2 do
-- 			if SetCount(techs[techNum - i] or {}) > maxNum then
-- 				maxNum = SetCount(techs[techNum - i])
-- 				maxIndex = techNum - i
-- 			end
-- 		end
-- 		chix[#chix+1] = Choose1Chicken(techs, maxIndex,  units, picked, cost)
-- 	end

	return chix
end

local function ChooseWaveChickens(units)
	data.waveChickens = ChooseChicken(units)
	local totalPower, totalWeight = 0, 0
	for _, entry in pairs(data.waveChickens) do
		totalPower = totalPower +  chickenUnionNames[entry[1]].spawncost * entry[2]
		totalWeight = totalWeight +  entry[2]
	end
	data.waveTotalCost = totalPower
	data.waveTotalWeight = totalWeight
end

local function SpawnAround(unitName, evo, bx, by, bz, spawnNumber, target, registar)
	local x, z
	local s = spawnSquare
	local tries = 0
	for i=1, spawnNumber do
		repeat
			x = random(bx - s, bx + s)
			z = random(bz - s, bz + s)
			s = s + spawnSquareIncrement
			tries = tries + 1
		until (not spGetGroundBlocked(x, z) or tries > spawnNumber + maxTriesSmall)
		x, z = clampPos(x, z)
		local unitID = createWithHyperevo(unitName, evo, x, by, z, "n", chickenTeamID)
		if unitID then
			spGiveOrderToUnit(unitID, CMD.MOVE_STATE, CMD_MOVESTATE_ROAM, 0)
			if tloc then spGiveOrderToUnit(unitID, CMD_FIGHT, tloc, 0) end
			if registar then registar[unitID] = true end
		end
	end
end

local function SpawnChicken(burrowID, spawnNumber, chickenName, chickenEvo)
	if Spring.IsGameOver() then return end

	local bx, by, bz = spGetUnitPosition(burrowID)
	if (not bx or not by or not bz) then
		return
	end
	local burrowTarget	= Spring.GetUnitNearestEnemy(burrowID, 20000, false)
	local tloc = data.targetCache
	if (burrowTarget) then
		tloc = ChooseTarget(burrowTarget)
	end
	if pvp and data.burrows[burrowID] and data.burrows[burrowID].targetID then
		local tx, ty, tz = spGetUnitPosition(data.burrows[burrowID].targetID)
		tloc = {tx, ty, tz}
	end

	SpawnAround(chickenName, chickenEvo, bx, by, bz, spawnNumber, tloc, data.chickens)
end

local function SpawnTurrets(burrowID)
	if Spring.GetUnitIsDead(burrowID) then return end
	if data.victory or Spring.IsGameOver() then
		return
	end

	local burrowData = data.burrows[burrowID]
	local neighborCount = #data.burrowsQuadfield:GetNeighbors(burrowID)
	local wantedTurrets = max(floor(burrowData.defenseDelta + sqrt(min(data.waveNumber, 8)) / (neighborCount + 1) * defenseMult * 2), 1)
	if wantedTurrets > burrowData.defenses then
		local i
		local bx, by, bz = spGetUnitPosition(burrowID)
		for i=burrowData.defenses, wantedTurrets-1 do
			SpawnAround(chicken_turret, defenseHyperevo, bx, by, bz, 1)
		end
		burrowData.defenses = wantedTurrets
	end
end

local function SpawnBurrow(number)
	if (data.victory or data.endgame) then return end
	if Spring.IsGameOver() then return end

	local t		 = spGetGameSeconds()
	local unitID

	for i=1, (number or 1) do
		local x, y, z
		local tries = 0
		local minDist = minBaseDistance
		local maxDist = maxBaseDistance
		local humanUnitsInVicinity = false
		local humanUnitsInProximity = false
		local propagate = false
		repeat
			x = random(spawnSquare, Game.mapSizeX - spawnSquare)
			z = random(spawnSquare, Game.mapSizeZ - spawnSquare)
			y = Spring.GetGroundHeight(x, z)
			tries = tries + 1
			local blocking = Spring.TestBuildOrder(testBuilding, x, y, z, 1)
			if (blocking == 2) then
				if (lava and Spring.GetGroundHeight(x,z) <= 0) then
					blocking = 1
				end
				local proximity = spGetUnitsInCylinder(x, z, minDist)
				local vicinity = spGetUnitsInCylinder(x, z, maxDist)
				humanUnitsInVicinity = false
				humanUnitsInProximity = false
				propagate = false
				for j=1, #vicinity, 1 do
					if (spGetUnitTeam(vicinity[j]) ~= chickenTeamID) then
						humanUnitsInVicinity = true
						break
					end
				end

				for j=1, #proximity, 1 do
					if (spGetUnitTeam(proximity[j]) ~= chickenTeamID) then
						humanUnitsInProximity = true
						break
					end
				end

				if tries > propagateTries then
					data.burrowsQuadfield:Insert(-1, x, z, 1)
					if (data.burrowsQuadfield:GetNeighbors(-1)[1]) > 1 then
						propagate = true
					end
					data.burrowsQuadfield:Remove(-1)
				end

				if (humanUnitsInProximity or not humanUnitsInVicinity) and not propagate then
					blocking = 1
				end
			end
			if tries < propagateTries then
				minDist = minDist * 0.999
			end
		until (blocking == 2 or tries > maxTries)

		--spEcho("[chicken_handler.lua] Spawning roost at ("..x..", "..y..", "..z..") after "..tries.." tries. humanUnitsInProximity: "..tostring(humanUnitsInProximity)..", humanUnitsInVicinity: "..tostring(humanUnitsInVicinity)..", propagate: "..tostring(propagate)..", minDist: "..tostring(minDist))

		x, z = clampPos(x, z)
		unitID = createWithHyperevo(burrowName, defenseHyperevo, x, y, z, "n", chickenTeamID)
		data.burrows[unitID] = {targetID = unitID, targetDistance = 100000, defenses = 0, defenseDelta = min(random(), 0.9), spawnedMenace = false}
		data.burrowsQuadfield:Insert(unitID, x, z, propagateDist)
		UpdateBurrowTarget(unitID, nil)
		SpawnTurrets(unitID)
	end
	return unitID
end
GG.Chicken.SpawnBurrow = SpawnBurrow

-- spawns arbitrary unit(s) obeying min and max distance from human units
-- supports spawning in batches

local function SpawnUnit(unitName, number, minDist, maxDist, target)
	if data.victory then return end
	minDist = minDist or minBaseDistance
	maxDist = maxDist or maxBaseDistance

	local x, y, z
	local tries = 0
	local block = false

	repeat
		if not target then
			x = random(spawnSquare, Game.mapSizeX - spawnSquare)
			z = random(spawnSquare, Game.mapSizeZ - spawnSquare)
		else
			x = random(target[1] - maxDist, target[1] + maxDist)
			z = random(target[3] - maxDist, target[3] + maxDist)
		end
		y = Spring.GetGroundHeight(x, z)
		tries = tries + 1
		block = false

		local proximity = spGetUnitsInCylinder(x, z, minDist)
		local vicinity = spGetUnitsInCylinder(x, z, maxDist)
		local humanUnitsInVicinity = false
		local humanUnitsInProximity = false
		for i=1, #vicinity, 1 do
			if (spGetUnitTeam(vicinity[i]) ~= chickenTeamID) then
				humanUnitsInVicinity = true
				break
			end
		end

		for i=1, #proximity, 1 do
			if (spGetUnitTeam(proximity[i]) ~= chickenTeamID) then
				humanUnitsInProximity = true
				break
			end
		end

		if (humanUnitsInProximity or not humanUnitsInVicinity) then
			block = true
			minDist = minDist * 0.9997
		end
	until (not spGetGroundBlocked(x, z) or (not block) or (tries > number + maxTries*2))

	for i=1, (number or 1) do
		sx, sz = clampPos(x + random(-spawnSquare, spawnSquare), z + random(-spawnSquare, spawnSquare))
		local unitID = spCreateUnit(unitName, sx, y, sz, "n", chickenTeamID)
		if unitID then
			spGiveOrderToUnit(unitID, CMD.MOVE_STATE, CMD_MOVESTATE_ROAM, 0)
		end
	end
end

local function SetMorphFrame()
	data.morphFrame = spGetGameFrame() + random(queenMorphTime[1], queenMorphTime[2])
	--Spring.Echo("Morph frame set to: " .. data.morphFrame)
	Spring.Echo("Next morph in: " .. math.ceil((data.morphFrame - spGetGameFrame())/30) .. " seconds")
end

local function SpawnQueen()
	local x, y, z
	local tries = 0

	local validBurrows = {}
	for id, data in pairs(data.burrows) do
		validBurrows[#validBurrows+1] = id
	end
	repeat
		x, _, z = spGetUnitPosition(validBurrows[random(1, #validBurrows)])
		x = x + 2*random(-spawnSquare, spawnSquare)
		z = z + 2*random(-spawnSquare, spawnSquare)
		y = Spring.GetGroundHeight(x, z)
		tries = tries + 1
		local blocking = Spring.TestBuildOrder(testBuildingQ, x, y, z, 1)

		if blocking == 2 then
			local proximity = spGetUnitsInCylinder(x, z, minBaseDistance)
			for i=1, #proximity, 1 do
				if (spGetUnitTeam(proximity[i]) ~= chickenTeamID) then
					blocking = 1
					break
				end
			end
		end
	until (blocking == 2 or tries > maxTries)
	local queenEvoMod = math.floor(menaceEvoMod + math.max(2 - menaceStartWave, 0))
	if menaceEvoMod ~= 0 then
		queenName = queenName.."_"..menaceEvoMod
		queenMorphName = queenMorphName.."_"..menaceEvoMod
	end
	x, z = clampPos(x, z)
	local unitID = spCreateUnit(queenName, x, y, z, "n", chickenTeamID)

	if queenMorphName ~= '' then SetMorphFrame() end
	return unitID
end

local function MenaceFastUpdate(menaceID)
	local menaceData = data.menaces[menaceID]
	local menaceDef = menaceData.def

	if menaceData.building then
		local progress = min((time - menaceData.startTime) * menaceBuildSpeed, 1)
		if not cocoonMode then
			spSetUnitHealth(menaceID, {build = progress})
		end
		if progress == 1 then
			menaceData.building = false
			for id, _ in pairs(menaceData.shield) do
				spDestroyUnit(id)
			end
			if cocoonMode then
				data.menaces[menaceID] = nil
				menaceID = GG.MorphUnit(menaceID, menaceData.finishedName, {})
				data.menaces[menaceID] = menaceData
			end
			return true
		end
	end

	return false
end


local function MenaceSlowUpdate(menaceID)
	local menaceData = data.menaces[menaceID]
	local menaceDef = menaceData.def

	if menaceData.building then
		return
	end

	if menaceDef.spawns then
		local spawnMult = menaceDef.spawns
		if menaceDef.scaleSpawnByDamage then
			local hp, maxHp = spGetUnitHealth(menaceID)
			spawnMult = spawnMult * (1 - (hp / maxHp))
		end

		local toSpawnCost = data.waveCostComponents.total * spawnMult / 3 -- Divide by 3 because this function runs 3 times more often than wave()
		local burrowSpawnCost = toSpawnCost / data.waveTotalWeight

		for i, entry in pairs(data.waveChickens) do
			local spawns = burrowSpawnCost / chickenUnionNames[entry[1]].spawncost * entry[2]
			local chixCount = floor(spawns + random())
			if chixCount > 0.1 then
				SpawnChicken(menaceID, chixCount, entry[1], hyperevo)
			end
		end
	end

	return false
end

local function SpawnMenace()
	local x, y, z
	local tries = 0

	local validBurrows = {}
	for id, data in pairs(data.burrows) do
		validBurrows[#validBurrows+1] = id
	end
	local menacePool = data.menacePool
	if #menacePool == 0 then
		for name, data in pairs(menaceDefs) do
			menacePool[#menacePool+1] = name
		end
	end
	local rand = random(1, #menacePool)
	local menaceDef = menaceDefs[menacePool[rand]]
	menacePool[rand] = menacePool[#menacePool]
	menacePool[#menacePool] = nil
	repeat
		x, _, z = spGetUnitPosition(validBurrows[random(1, #validBurrows)])
		x = x + 2*random(-spawnSquare, spawnSquare)
		z = z + 2*random(-spawnSquare, spawnSquare)
		y = Spring.GetGroundHeight(x, z)
		tries = tries + 1
		local blocking = Spring.TestBuildOrder(testBuildingQ, x, y, z, 1)
		if (blocking == 2) then
			local proximity = spGetUnitsInCylinder(x, z, minMenaceSeperation)
			for i=1, #proximity, 1 do
				if chickenMenaces[spGetUnitDefID(proximity[i])] then
					blocking = 1
					break
				end
			end
		end
		if blocking == 2 then
			local proximity = spGetUnitsInCylinder(x, z, minBaseDistance)
			for i=1, #proximity, 1 do
				if (spGetUnitTeam(proximity[i]) ~= chickenTeamID) then
					blocking = 1
					break
				end
			end
		end
	until (blocking == 2 or tries > maxTries)
	x, z = clampPos(x, z)
	local unitID
	local finishedName = applyHyperevo(menaceDef.name, menaceHyperevo, -2, 20, true)
	if cocoonMode then
		unitID = createWithHyperevo(menaceDef.cocoon, menaceHyperevo, x, y, z, "n", chickenTeamID)
	else
		unitID = spCreateUnit(finishedName, x, y, z, "n", chickenTeamID, true)
	end

	if unitID then
		spSetUnitHealth(unitID, math.huge)

		data.menaces[unitID] = {
			startTime = time,
			building = true,
			def = menaceDef,
			finishedName = finishedName,
			shield = {}
		}

		spGiveOrderToUnit(unitID, CMD.MOVE_STATE, CMD_MOVESTATE_ROAM, 0)

		SpawnAround(chicken_turret, defenseHyperevo, x, y, z, 3)
		if not cocoonMode then
			SpawnAround(chicken_shield, menaceHyperevo, x, y, z, 1, nil, data.menaces[unitID].shield)
		end
		MenaceFastUpdate(unitID)
	end
end


local function UpdateTech()
	if data.techTime < data.nextUnlockTime then
		return
	end
	data.nextUnlockTime = data.nextUnlockTime + chickenTechTime * techCostMult
	data.unlockedCount = data.unlockedCount + 1
	if stockChickens[data.unlockedCount] then
		data.stockChicken = stockChickens[data.unlockedCount]
		return
	end
	local techs = data.unlockedChickens
	local tier = #techs
	if tier == 0 or (chickenTechTree[tier] and (SetCount(techs[tier]) >= chickenTechTree[tier].max)) then
		tier = tier + 1
		if not chickenTechTree[tier] then
			return
		end
		techs[tier] = {}
	end
	if not chickenTechTree[tier] then
		return
	end
	local ttechs = techs[tier]
	local allowed = {}
	local i
	for i=1, #chickenTechTree[tier] do
		local chix = chickenTechTree[tier][i]
		if not ttechs[chix] then
			allowed[#allowed+1] = chix
		end
	end
	chix = allowed[random(#allowed)]
	ttechs[chix] = true
	data.unlockedChickensUnion[chix] = true
	spLog(section, LOG.NOTICE, "Chickens unlocked "..chix.." as technology number "..data.unlockedCount.." , current techTime: "..data.techTime)

	if data.techTime > data.nextUnlockTime then
		UpdateTech()
	end
end


local function Wave(waveMult)
	if data.victory or Spring.IsGameOver() then
		return
	end

	local chickens = data.waveChickens
	local burrowCount = SetCount(data.burrows)
	local waveCost = data.waveCostComponents.total
	waveCost = waveCost * waveMult

	local burrowSpawnCost = waveCost / data.waveTotalWeight / burrowCount

	for i, entry in pairs(chickens) do
		local spawns = burrowSpawnCost / chickenUnionNames[entry[1]].spawncost * entry[2]
		for burrowID in pairs(data.burrows) do
			local chixCount = floor(spawns + random())
			if chixCount > 0.1 then
				SpawnChicken(burrowID, chixCount, entry[1], hyperevo)
			end
		end
	end
end


local function waveStart()
	data.waveSchedule = time + (30 * chickenSpawnRate)
	data.graceSchedule = data.waveSchedule - (30 * gracePeriod)
	data.waveActive = true
	data.waveNumber = data.waveNumber + 1
	spSetGameRulesParam("chicken_waveSchedule", data.waveSchedule)
	spSetGameRulesParam("chicken_graceSchedule", data.graceSchedule)
	spSetGameRulesParam("chicken_waveNumber", data.waveNumber)
	spSetGameRulesParam("chicken_waveActive", 1)

	UpdateHyperevo()

	spLog(section, LOG.NOTICE, "Wave "..data.waveNumber.." Started. "..Spring.Utilities.TableToString(data.waveCostComponents, "Wave cost breakdown for current time "))

	if data.waveNumber > 2 then
		data.currentAward = math.max(data.currentAward, 1)
		spSetGameRulesParam("chicken_award", data.currentAward)
	end

	if data.endgame and not endlessMode then
		UpdateTech()
		ChooseWaveChickens(nil)
		spSetGameRulesParam("chicken_waveActive", 0)
	end

	--_G.chickenEventArgs = {type="waveStart", waveNumber = data.waveNumber}
	_G.chickenEventArgs = {type="wave", waveNumber = data.waveNumber, wave = data.waveChickens}
	SendToUnsynced("ChickenEvent")
	_G.chickenEventArgs = nil
end


local function waveEnd()
	data.waveActive = false
	for burrowID in pairs(data.burrows) do
		x, _, z = spGetUnitPosition(burrowID)
		local vicinity = spGetUnitsInCylinder(x, z, basePruneDistance)
		local prune = true
		for i=1, #vicinity, 1 do
			if (spGetUnitTeam(vicinity[i]) ~= chickenTeamID) then
				prune = false
				break
			end
		end
		if prune == true then
			spDestroyUnit(burrowID)
		end
	end
	for burrowID in pairs(data.burrows) do
		SpawnTurrets(burrowID)
	end
	local burrowDiff = floor(QTimeLerp(minBurrows, maxBurrows)) - SetCount(data.burrows)
	if burrowDiff > 0 then
		SpawnBurrow(burrowDiff)
	end
	if data.waveNumber >= menaceStartWave then
		local wantedMenaces = min(1 + math.floor(data.waveNumber / menaceStartWave - 0.4), menaceMaxNum)
		local i
		for i=1, wantedMenaces do
			SpawnMenace()
		end
	end

	if data.endgame and not endlessMode then
		return
	end

	UpdateTech()
	ChooseWaveChickens(nil)
	spSetGameRulesParam("chicken_waveActive", 0)

	_G.chickenEventArgs = {type="waveEnd", waveNumber = data.waveNumber, wave = data.waveChickens}
	SendToUnsynced("ChickenEvent")
	_G.chickenEventArgs = nil

	if data.endgame or speedChickens then
		return
	end

	for unitID, _ in pairs(data.chickens) do
		spDestroyUnit(unitID, true)
	end
	data.chickens = {}
end

----------------------------------------------------g----------------------------
--------------------------------------------------------------------------------
--
-- Call-ins
--

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	--local name = UnitDefs[unitDefID].name
	--if ( chickenTeamID == unitTeam ) then
	--	local n = Spring.GetGameRulesParam(name.."Count") or 0
	--	spSetGameRulesParam(name.."Count", n+1)
	--end
	if (alwaysVisible and unitTeam == chickenTeamID) then
		Spring.SetUnitAlwaysVisible(unitID, true)
	end
	if (eggs) then
		DisableBuildButtons(unitID, mexes)
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	--burrow targetting
	local name = UnitDefs[unitDefID].name
	if (humanTeams[unitTeam]) and UnitDefs[unitDefID].isImmobile and (not noTarget[name]) then
		--spEcho("Building ID "..unitID .." added to target array")
		local x, y, z = spGetUnitPosition(unitID)
		data.targets[unitID] = unitTeam
		--distance check for existing burrows goes here
		for burrow, burrowdata in pairs(data.burrows) do
			UpdateBurrowTarget(burrow, unitID)
		end
	end
end

function gadget:GameStart()
	if pvp then Spring.Echo("Chicken: PvP mode initialized") end
	--data.waveSchedule[gracePeriod*30] = true	-- schedule first wave
	data.waveSchedule = (gracePeriod + initialGraceBonus) * 30 + 42
	spSetGameRulesParam("chicken_waveSchedule", data.waveSchedule)

	for i=1, startTechs do
		data.nextUnlockTime = -100
		UpdateTech()
	end
	ChooseWaveChickens(nil)
	_G.chickenEventArgs = {type="spawnUpdate", waveNumber = data.waveNumber, wave = data.waveChickens}
	SendToUnsynced("ChickenEvent")
	_G.chickenEventArgs = nil
	data.nextUnlockTime = chickenTechTime * techCostMult
end

function gadget:GameFrame(n)
	if tachyonChicken then
		time = n*31 + 17
	else
		time = n
	end

	if time > data.gameoverSchedule then
		local _, _, _, _, _, allyteamToKill = Spring.GetTeamInfo(chickenTeamID, false)
		GG.DestroyAlliance(allyteamToKill)
	end

	if data.victory then
		return
	end

	local burrowDiff = minBurrows - SetCount(data.burrows)
	if burrowDiff > 0 then
		SpawnBurrow(burrowDiff)
	end

	if time > data.waveSchedule then
		waveStart()
	end

	if data.waveActive and time > data.graceSchedule then
		waveEnd()
	end

	-- Run this every frame to ensure smooth build animations
	for meanceID, _ in pairs(data.menaces) do
		if MenaceFastUpdate(meanceID) then -- This is horrible but it works
			break
		end
	end

	if ((n+17) % 30 < 0.1) then
		data.angerTime = time + data.angerTimeBonus
		data.strength = data.strength + strengthPerSecond
		data.wrath = data.wrath + wrathPerSecond
		spSetGameRulesParam("chicken_angerTime", data.angerTime)
		spSetGameRulesParam("chicken_strength", data.strength)
		spSetGameRulesParam("chicken_wrath", data.wrath)

		totalhumanValue = 1
		--local incomeTechMod = 0
		for team in pairs(humanTeams) do
			totalhumanValue = totalhumanValue + spGetTeamRulesParam(team, "stats_history_unit_value_current")
			--local _, _, _, income, _, share = spGetTeamResources(team, "metal")
			--spLog(section, LOG.NOTICE, "Income for team "..team.." is "..income.." income and "..share.." share")
			--incomeTechMod = incomeTechMod + math.max(income - share, 0) * techPerIncome
		end
		--incomeTechMod = incomeTechMod + #humanTeams * techPerPlayer
		data.techTime = time-- + max(incomeTechMod, 0)
		UpdateTech()
		UpdateHyperevo()

		Spring.SetGlobalLos(chickenAllyTeamID, true) -- globallos could get disabled

		local waveMult = 0

		if (data.angerTime >= queenTime) and (not data.endgame) then
			data.currentAward = max(data.currentAward, 2)
			spSetGameRulesParam("chicken_award", data.currentAward)
			spEcho("Chicken max anger reached, spawning queen")
			if endlessMode then
				data.currentAward = math.max(data.currentAward, 2)
				spSetGameRulesParam("chicken_award", data.currentAward)
			elseif pvp then
				KillAllComputerUnits()
			else
				spEcho("Chicken queening")
				_G.chickenEventArgs = {type="queen"}
				SendToUnsynced("ChickenEvent")
				_G.chickenEventArgs = nil
				local queenID = SpawnQueen()
				if queenID then
					data.queenID = queenID
				end
			end
			data.endgame = true
		end

		local qTime = time / queenTime
		if not endlessMode then
			qTime = min(qTime, 1)
		end
		local baseScore = qTime ^ 2 * scoreQueenTime
		data.totalScore = (baseScore + data.bonusScore) * scoreMult
		spSetGameRulesParam("chicken_score", data.totalScore)

		for meanceID, _ in pairs(data.menaces) do
			if MenaceSlowUpdate(meanceID) then -- This is horrible but it works
				break
			end
		end
	end

	if ((n+29) % 90) < 0.1 then
		DecayEggs()

		if data.endgame and not endlessMode then
			Wave(1)
		elseif data.waveActive or data.endgame then
			local waveProgress
			if data.endgame then
				waveProgress = (1-((data.waveSchedule-time)/chickenSpawnRate/30))
			else
				waveProgress = (1-((data.graceSchedule-time)/(chickenSpawnRate-gracePeriod)/30))
			end
			if waveProgress < 0.3 then
				Wave(1)
			else
				Wave(max(1.3 - waveProgress, 0)^2)
			end
		end

		data.targetCache = ChooseTarget()

		if (data.targetCache) then
			local chickens = spGetTeamUnits(chickenTeamID)
			for i=1,#chickens do
				local unitID = chickens[i]
				if not Spring.GetUnitCurrentCommand(unitID) then
					spGiveOrderToUnit(unitID, CMD_FIGHT, data.targetCache, CMD.OPT_SHIFT)
				end
			end
		end

		if pvp and not data.victory then
			-- check if there are still multiple human teams alive

			local humanTeamsAliveOrdered = {}
			for teamID ,_ in pairs(humanTeams) do
				humanTeamsAliveOrdered[#humanTeamsAliveOrdered+1] = teamID
			end

			local pvpAlive = false
			for i=1, #humanTeamsAliveOrdered do
				if humanTeamsAliveOrdered[i+1] and not Spring.AreTeamsAllied(humanTeamsAliveOrdered[i], humanTeamsAliveOrdered[i+1]) then
					pvpAlive = true
					break
				end
			end

			if not pvpAlive then
				spLog(section, LOG.NOTICE, "Chicken: All but 1 human team died, resigning")
				KillAllComputerUnits()
			end
		end
	end

	--morphs queen
	if n == data.morphFrame then
		--Spring.Echo("Morphing queen")
		local targetName = ""
		if data.morphed == true then
			targetName = queenName
		else
			targetName = queenMorphName
		end
		data.queenID = GG.MorphUnit(data.queenID, targetName, {})
		if not data.queenID then
			Spring.Echo("LUA_ERRRUN chicken queen was not recreated correctly, chicken team unit count / total unit count / maxunits ", Spring.GetTeamUnitCount(queenOwner), #Spring.GetAllUnits(), Spring.GetModOptions().maxunits or 10000)
			return
		end

		data.morphed = not data.morphed
		SetMorphFrame()
	end
end


function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	data.chickens[unitID] = nil
	if data.targets[unitID] then
		data.targets[unitID] = nil
		for burrow, burrowdata in pairs(data.burrows) do
			if burrowdata.targetID == unitID then		--retarget burrows if needed
				burrowdata.targetID = burrow
				burrowdata.targetDistance = 1000000
				UpdateBurrowTarget(burrow, nil)
			end
		end
	end
	if (unitTeam == chickenTeamID) then
		if GG.wasMorphedTo[unitID] then -- Short circuit in case the unit just got morphed
			return
		end
		if (unitID == data.queenID) then
			data.bonusScore = data.bonusScore + scorePerQueen
			spLog(section, LOG.ERROR, "Queen kill detected, initiating gadget shutdown")
			KillAllComputerUnits()
		end
		if data.menaces[unitID] then
			for id, _ in pairs(data.menaces[unitID].shield) do
				spDestroyUnit(id)
			end
			data.menaces[unitID] = nil
		end
		if (data.burrows[unitID]) then
			data.burrows[unitID] = nil
			local count = 0
			local burrowsOrdered = {}
			for _,id in pairs(data.burrows) do
				burrowsOrdered[#burrowsOrdered + 1] = id
				count = count + 1
			end
			data.burrowsQuadfield:Remove(unitID)

			--data.wrath = data.wrath + wrathPerBurrow
			data.strength = data.strength * strengthPerBurrow
			data.bonusScore = data.bonusScore + scorePerBurrow
			if data.strength < 0.5 then
				data.angerTimeBonus = data.angerTimeBonus + queenTimePerBurrow
			end

			if alwaysEggs then SpawnEggs(spGetUnitPosition(unitID)) end
			if (eggs) then SpawnEggs(spGetUnitPosition(unitID)) end
		end
		if chickenUnion[unitDefID] then
			local x, y, z = spGetUnitPosition(unitID)
			if alwaysEggs then
				local eggID = Spring.CreateFeature(chickenUnion[unitDefID].eggName, x, y, z, random(-32000, 32000))
				if eggDecayTime > 0 and not eggs then
					data.eggDecay[eggID] = spGetGameSeconds() + eggDecayTime
				end
			end
			if eggs then
				Spring.CreateFeature(chickenUnion[unitDefID].eggName, x, y, z, random(-32000, 32000))
			end
		end
	else
		local wrathReduction = (GetUnitCost(unitID, unitDefID) / totalhumanValue) * 10
		data.wrath = math.max(data.wrath - wrathReduction, 0)
	end
end

--capturing a chicken counts as killing it
function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
	if capture then
		if chickenUncapturable[unitDefID] then
			spDestroyUnit(unitID)
		else
			gadget:UnitDestroyed(unitID, unitDefID, oldTeam)
		end
	end
	return true
end

function gadget:TeamDied(teamID)
	humanTeams[teamID] = nil
	computerTeams[teamID] = nil
	Spring.SetTeamRulesParam(teamID, "chicken_score", data.totalScore)
	Spring.SetTeamRulesParam(teamID, "chicken_award", data.currentAward)
end

function gadget:AllowCommand_GetWantedCommand()
	return mexesUnitDefID
end

function gadget:AllowCommand_GetWantedUnitDefID()
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if (eggs) then
		if (mexesUnitDefID[cmdID]) then
			return false -- command was used
		end
	end
	return true	-- command was not used
end

function gadget:FeatureDestroyed(featureID, allyTeam)
	data.eggDecay[featureID] = nil
end

function gadget:GameOver()

	data.morphFrame = -1

	local function ExceedsOne(num)
		num = tonumber(num) or 1
		return num > 1
	end
	local modopts = Spring.GetModOptions()
	if ExceedsOne(modopts.metalmult) or
			ExceedsOne(modopts.metalmult) or
			(not ExceedsOne((modopts.terracostmult or 1) + 0.001)) then
		spLog(gadget:GetInfo().name, LOG.NOTICE, "<Chicken> Cheating modoptions, no score sent")
		return
	end

	--Spring.Echo("<Chicken> AGGRO STATS")
	--for waveNum,aggro in ipairs(data.humanAggroPerWave) do
	--	Spring.Echo(waveNum, aggro)
	--end

	--Spring.SendCommands("wbynum 255 SPRINGIE:score,ID: "..Spring.Utilities.Base64Encode(tostring(spGetGameFrame() + gameFrameOffset).."/"..tostring(math.floor(score))))
end


local function ToggleChickenSpeed(cmd,line,words,player)
	if not Spring.IsCheatingEnabled() then
		return
	end

	tachyonChicken = not tachyonChicken
	return true
end

local function MenaceWrapper(cmd,line,words,player)
	if not Spring.IsCheatingEnabled() then
		return
	end

	SpawnMenace()
	return true
end

function gadget:Initialize()
	spSetGameRulesParam("chicken_angerTime", data.angerTime)
	spSetGameRulesParam("chicken_queenTime", queenTime)
	spSetGameRulesParam("chicken_waveActive", 0)
	spSetGameRulesParam("chicken_waveSchedule", data.waveSchedule)
	spSetGameRulesParam("chicken_graceSchedule", data.graceSchedule)
	spSetGameRulesParam("chicken_waveNumber", data.waveNumber)
	spSetGameRulesParam("chicken_strength", data.strength)
	spSetGameRulesParam("chicken_wrath", data.wrath)
	spSetGameRulesParam("chicken_hyperevo", hyperevo)
	spSetGameRulesParam("chicken_difficulty", luaAI)
	spSetGameRulesParam("chicken_score", 0)
	spSetGameRulesParam("chicken_pvp", ((pvp and 1) or 0))
	spSetGameRulesParam("chicken_award", data.currentAward)

	gadgetHandler:AddChatAction("chicken_speed", ToggleChickenSpeed, "Makes chickens 30x faster")
	Script.AddActionFallback("chicken_speed"..' ', "Makes chickens 30x faster")
	gadgetHandler:AddChatAction("chicken_spawnmenace", MenaceWrapper, "Spawn a chicken Menace")
	Script.AddActionFallback("chicken_speed"..' ', "Spawn a chicken Menace")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
-- END SYNCED
-- BEGIN UNSYNCED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function WrapToLuaUI()
	if (Script.LuaUI('ChickenEvent')) then
		local chickenEventArgs = {}
		for k, v in pairs(SYNCED.chickenEventArgs) do
			chickenEventArgs[k] = v
		end
		Script.LuaUI.ChickenEvent(chickenEventArgs)
	end
end


function gadget:Initialize()
	gadgetHandler:AddSyncAction('ChickenEvent', WrapToLuaUI)
end

end
-- END UNSYNCED
--------------------------------------------------------------------------------

