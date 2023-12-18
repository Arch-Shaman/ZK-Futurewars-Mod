--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


function gadget:GetInfo()
	return {
		name     = "Chicken Handler",
		desc     = "JHandes the chicken gamemode chickens",
		author   = "quantum, improved by KingRaptor and Stuffphoton",
		date     = "April 29, 2008", --last update: 2023 August 21st
		license  = "GNU GPL, v2 or later",
		layer    = 0,
		enabled  = true --	loaded by default?
	}
end

include("LuaRules/Configs/customcmds.h.lua")

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
local spSetUnitHealth		= Spring.SetUnitHealth
local spGetUnitsInCylinder	= Spring.GetUnitsInCylinder
local spValidUnitID			= Spring.ValidUnitID
local spGetTeamResources			= Spring.GetTeamResources
local spSetTeamResource			= Spring.SetTeamResource
local spGetTeamRulesParam           = Spring.GetTeamRulesParam
local spGetUnitCommands             = Spring.GetUnitCommands
local spSetGameRulesParam      = Spring.SetGameRulesParam
local spDestroyUnit       = Spring.DestroyUnit
local GetUnitCost  = Spring.Utilities.GetUnitCost

local echo = Spring.Echo

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
local tachyonCandy = false -- every 60 seconds, half an hour passes

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local CMD_MOVESTATE_ROAM = CMD.MOVESTATE_ROAM
local maxTries		= 600
local propagateTries	= 400
local maxTriesSmall	= 100
local spawnDeviation   = 0.15
local lava = (Game.waterDamage > 0)
local eggs = tobool(Spring.GetModOptions().eggs)
local pvp = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local luaAI
local chickenTeamID
local computerTeams	= {}
local humanTeams	= {}
local gameFrameOffset = 0

local time = 1
local chickenMult = 1
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
	
	eggDecay = {},	-- indexed by featureID, value = game second
	targets = {},	--indexed by unitID, value = teamID
	menacePool = {},

	stockChicken = "chicken",
	unlockedChickens = {},
	unlockedChickensUnion = {chicken = true},
	unlockedCount = 0,
	nextUnlockTime = 0,

	cookery = 0,
	strength = 1,
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

echo("burrowName: "..burrowName)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Utility
--

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

local hyperevoFactor = 250000
local function updateHyperevo()
	local techmult = data.techTime--min(tt^1.34, 34*tt+420)
	chickenMult = techmult * (1 + data.wrath/2) * max(0.5, data.strength) * sqrt(waveSizeMult)
	hyperevo = max(chickenMult/hyperevoFactor, 1)
	chickenMult = min(chickenMult, hyperevoFactor)
	spSetGameRulesParam("chicken_hyperevo", hyperevo)

	baseHyperevo = max(techmult/hyperevoFactor, 1)
	defenseHyperevo = 2^min(data.waveNumber * defenseEvoMult * 0.7, 5) * baseHyperevo / max(0.5, data.strength)
	menaceHyperevo = eular^((min(data.waveNumber - menaceStartWave, 5) * menaceScalingMult + menaceEvoMod)/ 2) * baseHyperevo
	--spEcho("hyperuwu", hyperevo, defenseHyperevo, menaceHyperevo, queenHyperevo)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Teams
--

local function getDifficaulty(str)
	local i
	for i=1, #modes do
		echo("checking", modes[i], string.find(str, modes[i]))
		if string.find(str, modes[i]) then
			return i
		end
	end
	return 0
end


if (not gameMode) then -- set human and computer teams
	humanTeams[0]		= true
	computerTeams[1]	= true
	chickenTeamID		= 1
	luaAI			= 0 --defaultDifficulty
else
	local teams = Spring.GetTeamList()
	local lastChickenTeam = nil
	-- the problem is with human controlled chickens, otherwise it counts them as robot-players and difficulty increases very much
	-- probably, ideally this needs to be taught to differentiate between human chickens and human robots...
	for _, teamID in pairs(teams) do
		local _, teamLuaAI = Spring.GetAIInfo(teamID)
		if (teamLuaAI and teamLuaAI ~= "" and string.find(string.lower(teamLuaAI), "chicken")) then
			chickenTeamID = teamID
			local difficulty = getDifficaulty(teamLuaAI) or 4 -- default to normal
			if difficulty > 0 then
				luaAI = math.max(difficulty, (luaAI or 0))
			end
		end
	end
	if chickenTeamID then
		spEcho("Chicken Detected on team "..chickenTeamID.." with difficaulty "..luaAI)
	end
	for _, teamID in pairs(teams) do
		if chickenTeamID and Spring.AreTeamsAllied(teamID, chickenTeamID) then
			computerTeams[teamID] = true
		else
			humanTeams[teamID] = true
		end
	end
	if chickenTeamID then
		spSetGameRulesParam("chicken_chickenTeamID", chickenTeamID)
	end
end

if (not luaAI) or (luaAI == 0) then
	return false	-- nothing to do here, go home
end

spEcho("Initialising Chicken Handler")

local gaiaTeamID = Spring.GetGaiaTeamID()
local _, _, _, _, _, chickenAllyTeamID = Spring.GetTeamInfo(chickenTeamID)
computerTeams[gaiaTeamID] = nil
humanTeams[gaiaTeamID] = nil

local humanTeamsOrdered = {}
for id,_ in ipairs(humanTeams) do humanTeamsOrdered[#humanTeamsOrdered+1] = id end
for i=1, #humanTeamsOrdered do
	if humanTeamsOrdered[i+1] and not Spring.AreTeamsAllied(humanTeamsOrdered[i], humanTeamsOrdered[i+1]) then
		pvp = true
		Spring.Log(gadget:GetInfo().name, LOG.INFO, "Chicken: PvP mode detected")
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

difficulty = modes[luaAI]
SetGlobals(modes[luaAI]) -- set difficulty

queenTime = queenTime * 30
strengthPerSecond = strengthPerSecond * 32/30

echo("Chicken configured for "..tostring(difficulty).." ("..luaAI..")v difficaulty")

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

local modoptions = Spring.GetModOptions() or {}
--waveSizeMult = waveSizeMult * (modoptions.wavesizemult or 1)
--techCostMult = techCostMult * (modoptions.techtimemult or 1)
menaceBuildSpeed = 1 / 30 / ((chickenSpawnRate - gracePeriod) * 0.1 + gracePeriod)


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Game Rules
--


local difficulty = luaAI

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Game End Stuff
--

local function KillAllComputerUnits()
	data.victory = true
	spSetGameRulesParam("chicken_award", 1)

	local ggDestroyAlliance = GG.DestroyAlliance
	if not ggDestroyAlliance then
		return
	end

	
	local allyteamsToKill = {}
	local count = 0
	local spGetTeamInfo = Spring.GetTeamInfo
	for teamID in pairs(computerTeams) do
		local _, _, _, _, _, allyTeam = spGetTeamInfo(teamID, false)
		count = count + 1
		allyteamsToKill[count] = allyTeam
	end

	for i = 1, count do
		-- not destroyed directly in the previous loop
		-- because removal breaks the pairs iterator
		ggDestroyAlliance(allyteamsToKill[i])
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
	--echo("Final selected target ID: "..data.targetID)
	local validUnitID = spValidUnitID(data.targetID) --in case multiple UnitDestroyed() is called at same frame and burrow happen to choose a target before all Destroyed unit is registered.
	if validUnitID and targetData.targetID ~= oldTarget then
		targetData.targetTeam = spGetUnitTeam(data.targets[data.targetID])
		--spGiveOrderToUnit(burrowID, CMD_ATTACK, data.targetID, 0)
		--echo("Target for burrow ID ".. burrowID .." updated to target ID " .. data.targetID)
	elseif not validUnitID then
		targetData.targetID = nil
		--spGiveOrderToUnit(burrowID, CMD_STOP, 0, 0)
		--echo("Target for burrow ID ".. burrowID .." lost, waiting")
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
	spEcho("Testing chicken Count: "..#chix)
	if #chix > 2 then
		local maxNum, maxIndex, i = 0, 1
		for i=0, 2 do
			if SetCount(techs[techNum - i] or {}) > maxNum then
				maxNum = SetCount(techs[techNum - i])
				maxIndex = techNum - i
			end
		end
		chix[#chix+1] = Choose1Chicken(techs, maxIndex,  units, picked, cost)
	end

	return chix
end

local function SpawnAround(unitName, bx, by, bz, spawnNumber, target, registar)
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
		local unitID = spCreateUnit(unitName, x, by, z, "n", chickenTeamID)
		if unitID then
			spGiveOrderToUnit(unitID, CMD.MOVE_STATE, CMD_MOVESTATE_ROAM, 0)
			if tloc then spGiveOrderToUnit(unitID, CMD_FIGHT, tloc, 0) end
			if registar then registar[unitID] = true end
		end
	end
end

local function SpawnChicken(burrowID, spawnNumber, chickenName, isTurret)
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

	SpawnAround(chickenName, bx, by, bz, spawnNumber, tloc, data.chickens)
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
			SpawnAround(applyHyperevo(chicken_turret, defenseHyperevo, 0, 15), bx, by, bz, 1)
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

		spEcho("[chicken_handler.lua] Spawning roost at ("..x..", "..y..", "..z..") after "..tries.." tries. humanUnitsInProximity: "..tostring(humanUnitsInProximity)..", humanUnitsInVicinity: "..tostring(humanUnitsInVicinity)..", propagate: "..tostring(propagate)..", minDist: "..tostring(minDist))

		unitID = spCreateUnit(applyHyperevo(burrowName, defenseHyperevo, 0, 15), x, y, z, "n", chickenTeamID)
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
		local unitID = spCreateUnit(unitName, x + random(-spawnSquare, spawnSquare), y, z + random(-spawnSquare, spawnSquare), "n", chickenTeamID)
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
	if menaceEvoMod ~= 0 then
		queenName = queenName.."_"..menaceEvoMod
		queenMorphName = queenMorphName.."_"..menaceEvoMod
	end
	local unitID = spCreateUnit(queenName, x, y, z, "n", chickenTeamID)
	
	if queenMorphName ~= '' then SetMorphFrame() end
	return unitID
end

local function updateMenace(menaceID)
	local menaceData = data.menaces[menaceID]
	local menaceDef = menaceData.def

	if menaceData.building then
		local progress = min((time - menaceData.startTime) * menaceBuildSpeed, 1)
		spSetUnitHealth(menaceID, {build = progress})
		if progress == 1 then
			menaceData.building = false
			for id, _ in pairs(menaceData.shield) do
				spDestroyUnit(id)
			end
		end
	end
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
	local unitID = spCreateUnit(applyHyperevo(menaceDef.name, menaceHyperevo, -3, 17, true), x, y, z, "n", chickenTeamID, true)
	
	if unitID then
		spSetUnitHealth(unitID, math.huge)

		data.menaces[unitID] = {
			startTime = time,
			building = true,
			def = menaceDef,
			shield = {}
		}
		
		spGiveOrderToUnit(unitID, CMD.MOVE_STATE, CMD_MOVESTATE_ROAM, 0)

		SpawnAround(applyHyperevo(chicken_turret, max(menaceHyperevo*(2^1.5), defenseHyperevo), 0, 15), x, y, z, 3)
		SpawnAround(applyHyperevo(chicken_shield, menaceHyperevo, 0, 15), x, y, z, 1, nil, data.menaces[unitID].shield)

		updateMenace(unitID)
	end
end


local function UpdateTech()
	if data.techTime < data.nextUnlockTime then
		return
	end
	data.nextUnlockTime = data.nextUnlockTime + queenTime / chicken_totaltech * techCostMult
	data.unlockedCount = data.unlockedCount + 1
	if stockChickens[data.unlockedCount] then
		data.stockChicken = stockChickens[data.unlockedCount]
		return
	end		
	local techs = data.unlockedChickens
	local tier = #techs
	if tier == 0 or SetCount(techs[tier]) >= chickenTechTree[tier].max then
		tier = tier + 1
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
	local waveCost = (0.00328*sqrt(time))*chickenMult*(0.5+#chickens/2) * 0.01
		+ min(totalhumanValue, 1000000)*waveSizePerValue * 0.01
		+ waveSizePerPlayer*#humanTeams
	waveCost = waveCost * waveMult * sqrt(waveSizeMult)
	
	local totalPower = 0
	for _, entry in pairs(chickens) do
		--totalPower = totalPower +  UnitDefNames[entry[1]].power * entry[2]
		totalPower = totalPower +  UnitDefNames[entry[1]].buildTime * entry[2]
	end
	local totalSpawns = min(waveCost/totalPower + 0.01/#chickens, burrowCount * waveSizeMult * 5)
	
	local spawned = {}
	for i, entry in pairs(chickens) do
		spawned[i] = {entry[1], 0}
	end
	
	for menaceID, menaceData in pairs(data.menaces) do
		if not menaceData.building and menaceData.def.spawns then
			local spawnMult = menaceData.def.spawns
			for i, entry in pairs(chickens) do
				local chixCount = floor(totalSpawns*entry[2]*(1-spawnDeviation+2*spawnDeviation*random())*spawnMult + random())
				if chixCount > 0.1 then
					SpawnChicken(menaceID, chixCount, applyHyperevo(entry[1], hyperevo, 0, 10))
					spawned[i][2] = spawned[i][2] + chixCount
				end
			end
		end
	end

	local burrowSpawns = totalSpawns / burrowCount
 
	for i, entry in pairs(chickens) do
		local chix = applyHyperevo(entry[1], hyperevo, 0, 10)
		local actualChixCount = 0
		local spawns = burrowSpawns * entry[2] * (1 - spawnDeviation + 2 *spawnDeviation*random())
		for burrowID in pairs(data.burrows) do
			local chixCount = floor(spawns + random())
			if chixCount > 0.1 then
				SpawnChicken(burrowID, chixCount, chix)
				actualChixCount = actualChixCount + chixCount
			end
		end
		spawned[i][2] = spawned[i][2] + actualChixCount
	end
	
	return spawned
end

local function MorphQueen()
	-- store values to be copied
	local tempID = data.queenID
	local x, y, z = spGetUnitPosition(tempID)
	if not (x and y and z) then	-- invalid position somehow, try again in a bit
		data.morphFrame = data.morphFrame + 60
		return
	end
	
	local oldHealth,oldMaxHealth,paralyzeDamage,captureProgress,buildProgress = Spring.GetUnitHealth(tempID)
	local xp = Spring.GetUnitExperience(tempID)
	local heading = Spring.GetUnitHeading(tempID)
	local cmdQueue = spGetCommandQueue(tempID, -1)
	local queenOwner = spGetUnitTeam(tempID)
	
	if Spring.GetUnitIsStunned(tempID) or (Spring.GetUnitRulesParam(tempID, "disarmed") == 1) then	-- postpone morph
		data.morphFrame = data.morphFrame + 60
		return
	end
	
	-- perform switcheroo
	data.queenID = nil
	spDestroyUnit(tempID, false, true, tempID, true)
	if data.morphed == true then
		data.queenID = spCreateUnit(queenName, x, y, z, "n", queenOwner)
	else
		data.queenID = spCreateUnit(queenMorphName, x, y, z, "n", queenOwner)
	end

	if not data.queenID then
		Spring.Echo("LUA_ERRRUN chicken queen was not recreated correctly, chicken team unit count / total unit count / maxunits ", Spring.GetTeamUnitCount(queenOwner), #Spring.GetAllUnits(), Spring.GetModOptions().maxunits or 10000)
		return
	end

	data.morphed = not data.morphed
	SetMorphFrame()
	
	-- copy values
	-- position
	Spring.MoveCtrl.Enable(data.queenID)
	--Spring.MoveCtrl.SetPosition(data.queenID, x, y, z)	--needed to reset y-axis position
	--Spring.SpawnCEG("dirt", x, y, z)	--helps mask the transition
	Spring.MoveCtrl.SetHeading(data.queenID, heading)
	Spring.MoveCtrl.Disable(data.queenID)
	local env = Spring.UnitScript.GetScriptEnv(data.queenID)
	Spring.UnitScript.CallAsUnit(data.queenID, env.MorphFunc)
	--health handling
	local _,newMaxHealth				 = Spring.GetUnitHealth(data.queenID)
	newMaxHealth = newMaxHealth * queenHealthMod
	local newHealth = (oldHealth / oldMaxHealth) * newMaxHealth
	-- if newHealth >= 1 then newHealth = 1 end
	Spring.SetUnitMaxHealth(data.queenID, newMaxHealth)
	spSetUnitHealth(data.queenID, {health = newHealth, capture = captureProgress, paralyze = paralyzeDamage, build = buildProgress, })
	-- orders, XP
	Spring.SetUnitExperience(data.queenID, xp)
	if (cmdQueue and cmdQueue[1]) then		--copy order queue
		for i=1,#cmdQueue do
			spGiveOrderToUnit(data.queenID, cmdQueue[i].id, cmdQueue[i].params, cmdQueue[i].options.coded)
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
		local wantedMenaces = min(menaceStartNum + math.floor(data.waveNumber / menaceStartWave - 0.4), menaceMaxNum)
		local i
		for i=1, wantedMenaces do
			SpawnMenace()
		end
	end
	if data.endgame then
		return
	end
	
	UpdateTech()
	data.waveChickens = ChooseChicken(nil)
	spSetGameRulesParam("chicken_waveActive", 0)
	
	_G.chickenEventArgs = {type="waveEnd", waveNumber = data.waveNumber, wave = data.waveChickens}
	SendToUnsynced("ChickenEvent")
	_G.chickenEventArgs = nil
	
	for unitID, _ in pairs(data.chickens) do
		spDestroyUnit(unitID, true)
	end
	data.chickens = {}
end

--------------------------------------------------------------------------------
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
		--echo("Building ID "..unitID .." added to target array")
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
	data.waveSchedule = gracePeriod * 30 + 42
	spSetGameRulesParam("chicken_waveSchedule", data.waveSchedule)
end

function gadget:GameFrame(n)
	if tachyonCandy then
		time = n*30 + 17
	else
		time = n
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
		updateMenace(meanceID)
	end

	if ((n+17) % 30 < 0.1) then
		data.angerTime = time + data.angerTimeBonus
		data.techTime = time
		data.strength = data.strength + strengthPerSecond
		data.wrath = data.wrath + wrathPerSecond
		spSetGameRulesParam("chicken_angerTime", data.angerTime)
		spSetGameRulesParam("chicken_strength", data.strength)
		spSetGameRulesParam("chicken_wrath", data.wrath)

		totalhumanValue = 1
		local incomeTechMod = 0
		for team in pairs(humanTeams) do
			totalhumanValue = totalhumanValue + spGetTeamRulesParam(team, "stats_history_unit_value_current")
			local _, _, _, income, _, share = spGetTeamResources(team, "metal")
			incomeTechMod = incomeTechMod + math.max(income - share, 0) * techPerIncome
		end
		incomeTechMod = incomeTechMod + #humanTeams * techPerPlayer
		data.techTime = data.techTime + max(incomeTechMod, 0)
		UpdateTech()
		updateHyperevo()

		spSetTeamResource(chickenTeamID, "m", 10000)
		spSetTeamResource(chickenTeamID, "e", 10000)
		spSetTeamResource(chickenTeamID, "ms", 2000000)
		spSetTeamResource(chickenTeamID, "es", 2000000)
		Spring.SetGlobalLos(chickenAllyTeamID, true) -- globallos could get disabled

		local waveMult = 0
	
		if (data.angerTime >= queenTime) and (not data.endgame) then
			if endlessMode then
				spSetGameRulesParam("chicken_award_endless", 1)
			else
				_G.chickenEventArgs = {type="queen"}
				SendToUnsynced("ChickenEvent")
				_G.chickenEventArgs = nil
				if not pvp then
					local queenID = SpawnQueen()
					if queenID then
						data.queenID = queenID
					end
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
	end
	
	if ((n+29) % 90) < 0.1 then
		DecayEggs()
		
		if data.waveActive or data.endgame then
			local waveProgress
			if data.endgame then
				waveProgress = (1-((data.waveSchedule-time)/chickenSpawnRate/30))
			else
				waveProgress = (1-((data.graceSchedule-time)/(chickenSpawnRate-gracePeriod)/30))
			end
			if waveProgress < 0.5 then
				Wave(waveProgress*1.5+0.25)
			else
				Wave((2-waveProgress*2)^2)
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
		-- FIXME: don't make chickens lose if they won
		--if (not data.victory) and Spring.IsGameOver() then
		--	KillAllComputerUnits()
		--end
	end
	
	--morphs queen
	if n == data.morphFrame then
		--Spring.Echo("Morphing queen")
		MorphQueen()
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
		if (unitID == data.queenID) then
			data.bonusScore = data.bonusScore + scorePerQueen
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

			data.wrath = data.wrath + wrathPerBurrow
			data.strength = data.strength * strengthPerBurrow
			data.bonusScore = data.bonusScore + scorePerBurrow
		
			if alwaysEggs then SpawnEggs(spGetUnitPosition(unitID)) end
			if (eggs) then SpawnEggs(spGetUnitPosition(unitID)) end
		
			if pvp and data.endgame then
				if count == 0 then KillAllComputerUnits() end
			end
		end
		if chickenUnion[unitDefID] then
			local x, y, z = spGetUnitPosition(unitID)
			if alwaysEggs then
			local eggID = Spring.CreateFeature(chickenUnion[unitDefID].eggName, x, y, z, random(-32000, 32000))
			if eggDecayTime > 0 and not eggs then data.eggDecay[eggID] = spGetGameSeconds() + eggDecayTime end
		end
		if eggs then Spring.CreateFeature(chickenUnion[unitDefID].eggName, x, y, z, random(-32000, 32000)) end
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
	local metalmult = tonumber(Spring.GetModOptions().metalmult) or 1
	local energymult = tonumber(Spring.GetModOptions().energymult) or 1
	if ExceedsOne(modopts.metalmult) or ExceedsOne(modopts.metalmult) or (not ExceedsOne((modopts.terracostmult or 1) + 0.001)) then
		Spring.Log(gadget:GetInfo().name, LOG.INFO, "<Chicken> Cheating modoptions, no score sent")
		return
	end
	
	--Spring.Echo("<Chicken> AGGRO STATS")
	--for waveNum,aggro in ipairs(data.humanAggroPerWave) do
	--	Spring.Echo(waveNum, aggro)
	--end
	
	--Spring.SendCommands("wbynum 255 SPRINGIE:score,ID: "..Spring.Utilities.Base64Encode(tostring(spGetGameFrame() + gameFrameOffset).."/"..tostring(math.floor(score))))
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
	spSetGameRulesParam("chicken_difficulty", difficulty)
	spSetGameRulesParam("chicken_score", 0)
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

