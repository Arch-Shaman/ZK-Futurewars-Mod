function gadget:GetInfo()
	return {
		name      = "StartSetup",
		desc      = "Implements initial setup: start units, resources, and plop for construction",
		author    = "Licho, CarRepairer, Google Frog, SirMaverick",
		date      = "2008-2010",
		license   = "GNU GPL, v2 or later",
		layer     = -2, -- Before terraforming gadget (for facplop terraforming)
		enabled   = true  --  loaded by default?
	}
end

-- partially based on Spring's unit spawn gadget
include("LuaRules/Configs/start_setup.lua")
include("LuaRules/Configs/constants.lua")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local spGetTeamInfo         = Spring.GetTeamInfo
local spGetPlayerInfo       = Spring.GetPlayerInfo
local spGetPlayerList       = Spring.GetPlayerList

local modOptions = Spring.GetModOptions()
local ALLOW_EXTRA_COM = (modOptions.equalcom ~= "off")
local FORCE_EXTRA_COM = (modOptions.equalcom == "enable")

local DELAYED_AFK_SPAWN = false
local COOP_MODE = false
local playerChickens = Spring.Utilities.tobool(Spring.GetModOption("playerchickens", false, false))
local campaignBattleID = modOptions.singleplayercampaignbattleid
local setAiStartPos = (modOptions.setaispawns == "1")

local CAMPAIGN_SPAWN_DEBUG = (Spring.GetModOptions().campaign_spawn_debug == "1")

local gaiateam = Spring.GetGaiaTeamID()
local allyTeamAFKers = {}
local fixedStartPos = (modOptions.fixedstartpos == "1")

local storageUnits = {
	{
		unitDefID = UnitDefNames["staticstorage"].id,
		storeAmount = UnitDefNames["staticstorage"].metalStorage
	}
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (gadgetHandler:IsSyncedCode()) then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Functions shared between missions and non-missions

--[[local function CheckFacplopUse(unitID, unitDefID, teamID, builderID)
	if ploppableDefs[unitDefID] and (select(5, Spring.GetUnitHealth(unitID)) < 0.1) and (builderID and Spring.GetUnitRulesParam(builderID, "facplop") == 1) then
		-- (select(5, Spring.GetUnitHealth(unitID)) < 0.1) to prevent ressurect from spending facplop.
		Spring.SetUnitRulesParam(builderID,"facplop",0, {inlos = true})
		Spring.SetUnitRulesParam(unitID,"ploppee",1, {private = true})
		
		-- Instantly complete factory
		local maxHealth = select(2,Spring.GetUnitHealth(unitID))
		Spring.SetUnitHealth(unitID, {health = maxHealth, build = 1})
		local x,y,z = Spring.GetUnitPosition(unitID)
		Spring.SpawnCEG("gate", x, y, z)

		-- Stats collection (acuelly not, see below)
		if GG.mod_stats_AddFactoryPlop then
			GG.mod_stats_AddFactoryPlop(teamID, unitDefID)
		end

		-- FIXME: temporary hack because I'm in a hurry
		-- proper way: get rid of all the useless shit in modstats, reenable and collect plop stats that way (see above)
		local str = "SPRINGIE:facplop," .. UnitDefs[unitDefID].name .. "," .. teamID .. "," .. select(6, Spring.GetTeamInfo(teamID, false)) .. ","
		local _, playerID, _, isAI = Spring.GetTeamInfo(teamID, false)
		if isAI then
			str = str .. "Nightwatch" -- existing account just in case infra explodes otherwise
		else
			str = str .. (Spring.GetPlayerInfo(playerID, false) or "ChanServ") -- ditto, different acc to differentiate
		end
		str = str .. ",END_PLOP"
		Spring.SendCommands("wbynum 255 " .. str)

		-- Spring.PlaySoundFile("sounds/misc/teleport2.wav", 10, x, y, z) -- FIXME: performance loss, possibly preload?
	end
end]]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Mission Handling

--[[if VFS.FileExists("mission.lua") then -- this is a mission, we just want to set starting storage (and enable facplopping)
	function gadget:Initialize()
		for _, teamID in ipairs(Spring.GetTeamList()) do
			Spring.SetTeamResource(teamID, "es", START_STORAGE + HIDDEN_STORAGE)
			Spring.SetTeamResource(teamID, "ms", START_STORAGE + HIDDEN_STORAGE)
		end
	end

	function GG.SetStartLocation()
	end
	
	function GG.GiveFacplop(unitID) -- deprecated, use rulesparam directly
		Spring.SetUnitRulesParam(unitID, "facplop", 1, {inlos = true})
	end

	function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
		CheckFacplopUse(unitID, unitDefID, teamID, builderID)
	end

	return
end]]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local gamestart = false
--local createBeforeGameStart = {}	-- no longer used
local scheduledSpawn = {}
local luaSetStartPositions = {}
local playerSides = {} -- sides selected ingame from widget  - per players
local teamSides = {} -- sides selected ingame from widgets - per teams

local playerIDsByName = {}
local commChoice = {}
local allyTeamCommanderCount = {}
--local prespawnedCommIDs = {}	-- [teamID] = unitID

GG.allyTeamCommanderCount = allyTeamCommanderCount
GG.startUnits = {}	-- WARNING: this is liable to break with new dyncomms (entries will likely not be an actual unitDefID)
GG.CommanderSpawnLocation = {}

local waitingForComm = {}
GG.waitingForComm = waitingForComm

-- overlaps with the rulesparam
local commSpawnedTeam = {}
local commSpawnedPlayer = {}

local loadGame = false	-- was this loaded from a savegame?

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:Initialize()
	-- needed if you reload luarules
	local frame = Spring.GetGameFrame()
	if frame and frame > 0 then
		gamestart = true
	end
	local allUnits = Spring.GetAllUnits()
	for _, unitID in pairs(allUnits) do
		local udid = Spring.GetUnitDefID(unitID)
		if udid then
			gadget:UnitCreated(unitID, udid, Spring.GetUnitTeam(unitID))
		end
	end
end

local function GetStartUnit(teamID, playerID, isAI)

	local teamInfo = teamID and select(7, Spring.GetTeamInfo(teamID, true))
	if teamInfo and teamInfo.staticcomm then
		local commanderName = teamInfo.staticcomm
		local commanderLevel = teamInfo.staticcomm_level or 1
		local commanderProfile = GG.ModularCommAPI.GetCommProfileInfo(commanderName)
		return commanderProfile.baseUnitDefID
	end

	local startUnit
	local commProfileID = nil

	if isAI then -- AI that didn't pick comm type gets default comm
		return UnitDefNames[Spring.GetTeamRulesParam(teamID, "start_unit") or "dyntrainer_strike_base"].id
	end

	if (teamID and teamSides[teamID]) then
		startUnit = DEFAULT_UNIT
	end

	if (playerID and playerSides[playerID]) then
		startUnit = DEFAULT_UNIT
	end

	-- if a player-selected comm is available, use it
	playerID = playerID or (teamID and select(2, spGetTeamInfo(teamID, false)) )
	if (playerID and commChoice[playerID]) then
		--Spring.Echo("Attempting to load alternate comm")
		local playerCommProfiles = GG.ModularCommAPI.GetPlayerCommProfiles(playerID, true)
		local altComm = playerCommProfiles[commChoice[playerID]]
		if altComm then
			startUnit = playerCommProfiles[commChoice[playerID]].baseUnitDefID
			commProfileID = commChoice[playerID]
		end
	end

	if (not startUnit) and (not DELAYED_AFK_SPAWN) then
		startUnit = DEFAULT_UNIT
	end
	
	-- hack workaround for chicken
	--local luaAI = Spring.GetTeamLuaAI(teamID)
	--if luaAI and string.find(string.lower(luaAI), "chicken") then startUnit = nil end

	--if didn't pick a comm, wait for user to pick
	return (startUnit or nil)
end


local function GetFacingDirection(x, z, teamID)
	return (math.abs(Game.mapSizeX/2 - x) > math.abs(Game.mapSizeZ/2 - z))
			and ((x>Game.mapSizeX/2) and "west" or "east")
			or ((z>Game.mapSizeZ/2) and "north" or "south")
end

local function GetRecommendedStartPosition(teamID, n) -- N is the number of times an ally team has called this
	local x = Game.mapSizeX / 2
	local z = Game.mapSizeZ / 2

	local boxID = Spring.GetTeamRulesParam(teamID, "start_box_id")
	if boxID then
		local startposList = GG.startBoxConfig[boxID] and GG.startBoxConfig[boxID].startpoints
		if startposList then
			local maxpoints = #startposList
			local startpos = startposList[(n%maxpoints) + 1] -- recycle if you run out of points.
			x = startpos[1]
			z = startpos[2]
		end
	end
	return x, Spring.GetGroundHeight(x,z), z
end

local function GetStartPos(teamID, teamInfo, isAI)
	if luaSetStartPositions[teamID] then
		return luaSetStartPositions[teamID].x, luaSetStartPositions[teamID].y, luaSetStartPositions[teamID].z
	end
	
	if fixedStartPos then
		local x, y, z
		if teamInfo then
			x, z = tonumber(teamInfo.start_x), tonumber(teamInfo.start_z)
		end
		if x then
			y = Spring.GetGroundHeight(x, z)
		else
			x, y, z = Spring.GetTeamStartPosition(teamID)
		end
		return x, y, z
	end
	local allyTeamID = select(6, Spring.GetTeamInfo(teamID))
	if not (Spring.GetTeamRulesParam(teamID, "valid_startpos") or isAI) then
		local index = allyTeamAFKers[allyTeamID] or 0
		allyTeamAFKers[allyTeamID] = index + 1
		local x, y, z = GetRecommendedStartPosition(teamID, index)
		return x, y, z
	end
	
	local x, y, z = Spring.GetTeamStartPosition(teamID)
	-- clamp invalid positions
	-- AIs can place them -- remove this once AIs are able to be filtered through AllowStartPosition
	local boxID = isAI and Spring.GetTeamRulesParam(teamID, "start_box_id")
	if boxID and not GG.CheckStartbox(boxID, x, z) then
		local index = allyTeamAFKers[allyTeamID] or 0
		allyTeamAFKers[allyTeamID] = index + 1
		x, y, z = GetRecommendedStartPosition(teamID, index)
	end
	return x, y, z
end

local function CanUnitDropHere(startBoxID, unitDefID, x, y, z, facing, checkForFeature, checkForStartBox)
	if checkForStartBox then
		local inBox = GG.CheckStartbox(startBoxID, x, z)
		if not inBox then return false end
	end
	local blocking, feature = Spring.TestBuildOrder(unitDefID, x, y, z, facing)
	if checkForFeature then
		return blocking == 3 -- Recoil engine now has 3 for "free", 2 for "blocked by feature"
	else
		return blocking > 1
	end
end

local function GetClosestValidSpawnSpot(teamID, unitDefID, facing, x, z)
	local startBoxID = Spring.GetTeamRulesParam(teamID, "start_box_id")
	local radius = 16
	local canDropHere = false
	local mag = 1
	local spiralChangeNumber = 1
	local movesLeft = 1
	local dir = 1 -- 1: right, 2: up, 3: left, 4 down
	local nx, ny, nz
	local offsetX, offsetZ = 0, 0
	local aborted = false
	repeat -- 1 right, 1 up, 2 left, 2 down, 3 right, 3 up
		nx = x + offsetX
		nz = z + offsetZ
		ny = Spring.GetGroundHeight(nx, nz)
		canDropHere = CanUnitDropHere(startBoxID, unitDefID, nx, ny, nz, facing, false, true)
		if canDropHere then
			return nx, ny, nz
		end
		if movesLeft == 0 and not (mag == 8 and movesLeft == 0 and dir == 4) then 
			spiralChangeNumber = spiralChangeNumber + 1
			if spiralChangeNumber%3 == 0 then 
				mag = mag + 1
			end
			movesLeft = mag
			dir = dir%4 + 1
		elseif mag == 8 and movesLeft == 0 and dir == 4 then -- abort
			aborted = true 
		else -- move to the next offset
			if dir == 1 then
				offsetX = offsetX + radius
			elseif dir == 2 then
				offsetZ = offsetZ + radius
			elseif dir == 3 then
				offsetX = offsetX - radius
			elseif dir == 4 then
				offsetZ = offsetZ - radius
			end
			movesLeft = movesLeft - 1
		end
	until canDropHere or aborted
	return x, Spring.GetGroundHeight(x, z), z -- aborted, return original position.
end

local function SpawnStartUnit(teamID, playerID, isAI, bonusSpawn, notAtTheStartOfTheGame)
	if not teamID then
		return
	end
	local _, _, _, _, _, allyTeamID, teamInfo = Spring.GetTeamInfo(teamID, true)
	if teamInfo and teamInfo.nocommander then
		waitingForComm[teamID] = nil
		return
	end
	
	local luaAI = Spring.GetTeamLuaAI(teamID)
	if luaAI and string.find(string.lower(luaAI), "chicken") then
		return false
	elseif playerChickens then
		-- allied to latest chicken team? no com for you
		local chickenTeamID = -1
		for _,t in pairs(Spring.GetTeamList()) do
			local teamLuaAI = Spring.GetTeamLuaAI(t)
			if teamLuaAI and string.find(string.lower(teamLuaAI), "chicken") then
				chickenTeamID = t
			end
		end
		if (chickenTeamID > -1) and (Spring.AreTeamsAllied(teamID,chickenTeamID)) then
			--Spring.Echo("chicken_control detected no com for "..playerID)
			return false
		end
	end
	
	-- get start unit
	local startUnit = GetStartUnit(teamID, playerID, isAI)

	if ((COOP_MODE and playerID and commSpawnedPlayer[playerID]) or (not COOP_MODE and commSpawnedTeam[teamID])) and not bonusSpawn then
		return false
	end

	if startUnit then
		-- replace with shuffled position
		local x,y,z = GetStartPos(teamID, teamInfo, isAI)
		
		-- get facing direction
		local facing = GetFacingDirection(x, z, teamID)
		x, y, z = GetClosestValidSpawnSpot(teamID, startUnit, facing, x, z) -- adjust for new location.

		if CAMPAIGN_SPAWN_DEBUG then
			local _, aiName = Spring.GetAIInfo(teamID)
			Spring.MarkerAddPoint(x, y, z, "Commander " .. (aiName or "Player"))
			return -- Do not spawn commander
		end
		GG.startUnits[teamID] = startUnit
		GG.CommanderSpawnLocation[teamID] = {x = x, y = y, z = z, facing = facing}

		if GG.GalaxyCampaignHandler then
			facing = GG.GalaxyCampaignHandler.OverrideCommFacing(teamID) or facing
		end
		
		-- CREATE UNIT
		local unitID = GG.DropUnit(startUnit, x, y, z, facing, teamID, nil, nil, nil, nil, nil, GG.ModularCommAPI.GetProfileIDByBaseDefID(startUnit), teamInfo and tonumber(teamInfo.static_level), true)
		
		if not unitID then
			return
		end
		allyTeamCommanderCount[allyTeamID] = (allyTeamCommanderCount[allyTeamID] or 0) + 1
		
		if GG.GalaxyCampaignHandler then
			GG.GalaxyCampaignHandler.DeployRetinue(unitID, x, z, facing, teamID)
		end
		
		if Spring.GetGameFrame() <= 1 then
			Spring.SpawnCEG("gate", x, y, z)
		end

		if not bonusSpawn then
			Spring.SetTeamRulesParam(teamID, "commSpawned", 1, {allied = true})
			commSpawnedTeam[teamID] = true
			if playerID then
				Spring.SetGameRulesParam("commSpawnedPlayer"..playerID, 1, {allied = true})
				commSpawnedPlayer[playerID] = true
			end
			waitingForComm[teamID] = nil
		end

		-- add facplop
		--local teamLuaAI = Spring.GetTeamLuaAI(teamID)
		local udef = UnitDefs[Spring.GetUnitDefID(unitID)]
		Script.LuaRules.GiveStartResources(teamID)
		Spring.SetUnitRulesParam(unitID, "commander_storage_override", 0, {inlos = true})
		if GG.Overdrive then
			GG.Overdrive.AddInnateIncome(allyTeamID, INNATE_INC_METAL, INNATE_INC_ENERGY)
		end

		if (udef.customParams.level and udef.name ~= "chickenbroodqueen") and
			((not campaignBattleID) or GG.GalaxyCampaignHandler.HasFactoryPlop(teamID)) then
			GG.GiveFacplop(unitID)
		end
		
		local name = "noname" -- Backup for when player does not choose a commander and then resigns.
		if isAI then
			name = select(2, Spring.GetAIInfo(teamID))
		else
			name = Spring.GetPlayerInfo(playerID, false)
		end
		Spring.SetUnitRulesParam(unitID, "commander_owner", name, {inlos = true})
		return true
	end
	return false
end

local function StartUnitPicked(playerID, name)
	local _,_,spec,teamID = spGetPlayerInfo(playerID, false)
	if spec then
		return
	end
	teamSides[teamID] = name
	local startUnit = GetStartUnit(teamID, playerID)
	if startUnit then
		SendToUnsynced("CommSelection",playerID, startUnit) --activate an event called "CommSelection" that can be detected in unsynced part
		if UnitDefNames[startUnit] then
			Spring.SetTeamRulesParam(teamID, "commChoice", UnitDefNames[startUnit].id)
		else
			Spring.SetTeamRulesParam(teamID, "commChoice", startUnit)
		end
	end
	if gamestart then
		-- picked commander after game start, prep for orbital drop
		-- can't do it directly because that's an unsafe change
		local frame = Spring.GetGameFrame() + 3
		if not scheduledSpawn[frame] then scheduledSpawn[frame] = {} end
		scheduledSpawn[frame][#scheduledSpawn[frame] + 1] = {teamID, playerID}
	--else
		--[[
		if startPosition[teamID] then
			local oldCommID = prespawnedCommIDs[teamID]
			local pos = startPosition[teamID]
			local startUnit = GetStartUnit(teamID, playerID, isAI)
			if startUnit then
				local newCommID = Spring.CreateUnit(startUnit, pos.x, pos.y, pos.z , "s", 0)
				if oldCommID then
					local cmds = Spring.GetCommandQueue(oldCommID, -1)
					--//transfer command queue
					for i = 1, #cmds do
						local cmd = cmds[i]
						Spring.GiveOrderToUnit(newUnit, cmd.id, cmd.params, cmd.options.coded)
					end
					Spring.DestroyUnit(oldCommID, false, true)
				end
				prespawnedCommIDs[teamID] = newCommID
			end
		end
		]]
	end
	GG.startUnits[teamID] = GetStartUnit(teamID) -- ctf compatibility (ctf no longer exists, but a debug command uses it.)
end

local function workAroundSpecsInTeamZero(playerlist, team)
	if team == 0 then
		local players = #playerlist
		local specs = 0
		-- count specs
		for i=1,#playerlist do
			local _,_,spec = spGetPlayerInfo(playerlist[i], false)
			if spec then
				specs = specs + 1
			end
			end
		if players == specs then
			return nil
		end
	end
	return playerlist
end

--[[
   This function return true if everyone in the team resigned.
   This function is alternative to "isDead" from: "_,_,isDead,isAI = spGetTeamInfo(team, false)"
   because "isDead" failed to return true when human team resigned before GameStart() event.
--]]
local function IsTeamResigned(team)
	local playersInTeam = spGetPlayerList(team)
	for j=1,#playersInTeam do
		local spec = select(3,spGetPlayerInfo(playersInTeam[j], false))
		if not spec then
			return false
		end
	end
	return true
end

--[[local function GetPregameUnitStorage(teamID)
	local storage = 0
	for i = 1, #storageUnits do
		storage = storage + Spring.GetTeamUnitDefCount(teamID, storageUnits[i].unitDefID) * storageUnits[i].storeAmount
	end
	return storage
end]]

local function SpawnCustomKeyExtraCommanders(teamID)
	if not ALLOW_EXTRA_COM then
		return
	end
	local playerlist = Spring.GetPlayerList(teamID, true)
	playerlist = workAroundSpecsInTeamZero(playerlist, teamID)
	if playerlist then
		for i = 1, #playerlist do
			local customKeys = select(10, Spring.GetPlayerInfo(playerlist[i]))
			if customKeys and customKeys.extracomm then
				for j = 1, tonumber(customKeys.extracomm) do
					Spring.Echo("Spawing a commander")
					SpawnStartUnit(teamID, playerlist[i], false, true)
				end
			end
		end
	end
end

local function SpawnAllyTeamExtraCommanders(allyTeamID, wanted)
	local teams = Spring.GetTeamList(allyTeamID)
	Spring.Utilities.PermuteList(teams)
	local tries = 50
	while wanted > 0 and tries > 0 do
		for i = 1, #teams do
			local teamID = teams[i]
			local _, playerID, _, isAI = spGetTeamInfo(teamID, false)
			SpawnStartUnit(teamID, playerID, isAI, true)
			wanted = wanted - 1
			if wanted <= 0 then
				break
			end
		end
		tries = tries - 1
	end
end


function gadget:GameStart()
	gamestart = true

	-- spawn units
	local teamList = Spring.GetTeamList()
	for i = 1, #teamList do
		local team = teamList[i]
		
		-- clear resources
		-- actual resources are set depending on spawned unit and setup

		--check if player resigned before game started
		local _,playerID,_,isAI = spGetTeamInfo(team, false)
		local deadPlayer = (not isAI) and IsTeamResigned(team)

		if team ~= gaiateam and not deadPlayer then
			local luaAI = Spring.GetTeamLuaAI(team)
			if DELAYED_AFK_SPAWN then
				if not (luaAI and string.find(string.lower(luaAI), "chicken")) then
					waitingForComm[team] = true
				end
			end
			if COOP_MODE then
				-- 1 start unit per player
				local playerlist = Spring.GetPlayerList(team, true)
				playerlist = workAroundSpecsInTeamZero(playerlist, team)
				if playerlist and (#playerlist > 0) then
					for i=1,#playerlist do
						local _,_,spec = spGetPlayerInfo(playerlist[i], false)
						if (not spec) then
							SpawnStartUnit(team, playerlist[i])
						end
					end
				else
					-- AI etc.
					SpawnStartUnit(team, nil, true)
				end
			else -- no COOP_MODE
				if (playerID) then
					local _,_,spec,teamID = spGetPlayerInfo(playerID, false)
					if (teamID == team and not spec) then
						isAI = false
					else
						playerID = nil
					end
				end

				SpawnStartUnit(team, playerID, isAI)
			end

			-- extra comms
			SpawnCustomKeyExtraCommanders(team)
		end
	end
	
	if FORCE_EXTRA_COM then
		local maxComms = 0
		for allyTeamID, count in pairs(allyTeamCommanderCount) do
			maxComms = math.max(maxComms, count)
		end
		for allyTeamID, count in pairs(allyTeamCommanderCount) do
			if count < maxComms then
				SpawnAllyTeamExtraCommanders(allyTeamID, maxComms - count)
			end
		end
	end
end

function gadget:RecvSkirmishAIMessage(aiTeam, dataStr)
	-- perhaps this should be a global relay mode somewhere instead
	local command = "ai_commander:";
	if dataStr:find(command,1,true) then
		local name = dataStr:sub(command:len()+1);
		CallAsTeam(aiTeam, function()
			Spring.SendLuaRulesMsg(command..aiTeam..":"..name);
		end)
	end
end

local function SetStartLocation(teamID, x, z)
    luaSetStartPositions[teamID] = {x = x, y = Spring.GetGroundHeight(x,z), z = z}
end
GG.SetStartLocation = SetStartLocation

function gadget:RecvLuaMsg(msg, playerID)
	if msg:find("customcomm:",1,true) then
		local name = msg:sub(12)
		commChoice[playerID] = name
		StartUnitPicked(playerID, name)
	elseif msg:find("ai_commander:",1,true) then
		local command = "ai_commander:";
		local offset = msg:find(":",command:len()+1,true);
		local teamID = msg:sub(command:len()+1,offset-1);
		local name = msg:sub(offset+1);
		
		teamID = tonumber(teamID);
		
		local _,_,_,isAI = Spring.GetTeamInfo(teamID, false)
		if(isAI) then -- this is actually an AI
			local aiid, ainame, aihost = Spring.GetAIInfo(teamID)
			if (aihost == playerID) then -- it's actually controlled by the local host
				local unitDef = UnitDefNames[name];
				if unitDef then -- the requested unit actually exists
					if aiCommanders[unitDef.id] then
						Spring.SetTeamRulesParam(teamID, "start_unit", name);
					end
				end
			end
		end
	elseif (msg:find("ai_start_pos:",1,true) and setAiStartPos) then
		local msg_table = Spring.Utilities.ExplodeString(':', msg)
		if msg_table then
			local teamID, x, z = tonumber(msg_table[2]), tonumber(msg_table[3]), tonumber(msg_table[4])
			if teamID then
				local _,_,_,isAI = Spring.GetTeamInfo(teamID, false)
				if isAI and x and z then
					SetStartLocation(teamID, x, z)
					Spring.MarkerAddPoint(x, 0, z, "AI " .. teamID .. " start")
				end
			end
		end
	end
end

function gadget:GameFrame(n)
	if n == (COMM_SELECT_TIMEOUT) then
		for team in pairs(waitingForComm) do
			local _,playerID = spGetTeamInfo(team, false)
			teamSides[team] = DEFAULT_UNIT_NAME
			--playerSides[playerID] = "basiccomm"
			scheduledSpawn[n] = scheduledSpawn[n] or {}
			scheduledSpawn[n][#scheduledSpawn[n] + 1] = {team, playerID} -- playerID is needed here so the player can't spawn coms 2 times in COOP_MODE mode
		end
	end
	if scheduledSpawn[n] then
		for _, spawnData in pairs(scheduledSpawn[n]) do
			local teamID, playerID = spawnData[1], spawnData[2]
			local canSpawn = SpawnStartUnit(teamID, playerID, false, false, true)

			if (canSpawn) then
				-- extra comms
				local customKeys = select(10, playerID)
				if playerID and customKeys and customKeys.extracomm then
					for j=1, tonumber(customKeys.extracomm) do
						SpawnStartUnit(teamID, playerID, false, true, true)
					end
				end
			end
		end
		scheduledSpawn[n] = nil
	end
end

function gadget:Shutdown()
	--Spring.Echo("<Start Unit Setup> Going to sleep...")
end

--------------------------------------------------------------------
-- unsynced code
--------------------------------------------------------------------
else
	function gadget:Initialize()
		gadgetHandler:AddSyncAction('CommSelection',CommSelection) --Associate "CommSelected" event to "WrapToLuaUI". Reference: http://springrts.com/phpbb/viewtopic.php?f=23&t=24781 "Gadget and Widget Cross Communication"
	end
	  
	function CommSelection(_,playerID, startUnit)
		if (Script.LuaUI('CommSelection')) then --if there is widgets subscribing to "CommSelection" function then:
			local isSpec = Spring.GetSpectatingState() --receiver player is spectator?
			local myAllyID = Spring.GetMyAllyTeamID() --receiver player's alliance?
			local _,_,_,_, eventAllyID = Spring.GetPlayerInfo(playerID, false) --source alliance?
			if isSpec or myAllyID == eventAllyID then
				Script.LuaUI.CommSelection(playerID, startUnit) --send to widgets as event
			end
		end
	end
end
