if not (gadgetHandler:IsSyncedCode()) then -- entirely synced.
	return
end

function gadget:GetInfo()
	return {
		name      = "Start Position Handler",
		desc      = "Implements start handling in LUA.",
		author    = "Shaman",
		date      = "September 20, 2020",
		license   = "PD",
		layer     = 11, -- specifically after commshare to register changes.
		enabled   = true  --  loaded by default?
	}
end

local aiInfo = {} -- AIs go here.
local gameinfo = {commcount = {}}
local PUBLIC = {public = true}
local ALLIED = {allied = true}
local ActivePlayers = {}
local allyTeamAFKers = {}
local equalizationmode = Spring.GetModOptions().commequalization or "players"
local modOptions = Spring.GetModOptions()

local DEFAULT_UNIT = UnitDefNames["dyntrainer_strike_base"].id
--local DEFAULT_UNIT_NAME = "Strike Trainer"

local CheckStartBox = GG.CheckStartBox

local function SetUpPlayers()
	local allyteamlist = Spring.GetAllyTeamList()
	local highestcomms = 0
	local playingplayers = {}
	for a = 1, #allyteamlist - 1 do
		local allyID = allyteamlist[a]
		allyTeamAFKers[allyID] = 0
		local teamlist = Spring.GetTeamList(allyID)
		local commcount = 0
		local isAIteam = true
		for t = 1, #teamlist do
			local teamID = teamlist[t]
			local _, _, isDead, isAI = Spring.GetTeamInfo(teamID)
			if isAI then
				local luaAI = Spring.GetTeamLuaAI(teamID)
				if not (luaAI and string.find(string.lower(luaAI), "chicken")) then
					Spring.SetTeamRulesParam(teamID, "ai_comms", 1, PUBLIC)
					aiInfo[teamID] = {[1] = {x = 0, z = 0, placed = false, def = 0}}
					if equalizationmode == "all" then
						commcount = commcount + 1
					end
				end
			elseif not isDead then -- god knows why this would happen, but let's be safe anyways.
				local playerlist = Spring.GetPlayerList(teamID)
				for p = 1, #playerlist do
					local playerID = playerlist[p]
					local name, _, spec, _, _, _, _, _, _, cp = Spring.GetPlayerInfo(playerID)
					if not spec then
						commcount = commcount + 1
						Spring.SetPlayerRulesParam(playerID, "commander_count", 1, PUBLIC)
						Spring.SetPlayerRulesParam(playerID, "startpos_1_x", 0, ALLIED)
						Spring.SetPlayerRulesParam(playerID, "startpos_1_z", 0, ALLIED)
						Spring.SetPlayerRulesParam(playerID, "startpos_1_def", DEFAULT_UNIT, ALLIED)
						Spring.SetPlayerRulesParam(playerID, "startpos_1_placed", false, ALLIED)
						Spring.SetPlayerRulesParam(playerID, "startpos_1_profile", "?", ALLIED)
						Spring.SetPlayerRulesParam(playerID, "player_ready", false, PUBLIC)
						Spring.SetPlayerRulesParam(playerID, "startpos_options_movestart", false, ALLIED)
						Spring.SetPlayerRulesParam(playerID, "startpos_options_setcommander", false, ALLIED)
						playingplayers[#playingplayers + 1] = playerID
						isAIteam = false
					end
				end
			end
		end
		gameinfo.commcount[allyID] = {isAI = isAIteam, commcount = commcount}
		if commcount > highestcomms and (equalizationmode == "all" or not isAIteam) then
			highestcomms = commcount
		end
		ActivePlayers = playingplayers
	end
	gameinfo.highestcount = highestcomms
end

local function EqualizeCommanders()
	if equalizationmode == "none" then
		return
	end
	local highest = gameinfo.highestcount
	for a = 1, #gameinfo.commcount do
		local count = gameinfo.commcount[a].commcount
		if count < highest and not gameinfo.commcount[a].isAI then -- start searching for people to give extra comms to
			local toassign = highest - count
			local assigned = 0
			local teamlist = Spring.GetTeamList(a)
			repeat
				for t = 1, #teamlist do
					local teamID = teamlist[t]
					local playerlist = Spring.GetPlayerList(teamID) -- according to the wiki, this gives us only active players on 104+
					for p = 1, #playerlist do
						local playerID = playerlist[p]
						local cp = select(10, Spring.GetPlayerInfo(playerID))
						if tonumber(cp["elo_order"]) + 1 <= toassign and assigned < toassign then
							local count = Spring.GetPlayerRulesParam(playerID, "commander_count")
							Spring.SetPlayerRulesParam(playerID, "commander_count", count + 1, PUBLIC)
							Spring.SetPlayerRulesParam(playerID, "startpos_" .. count + 1 .. "_x", 0, ALLIED)
							Spring.SetPlayerRulesParam(playerID, "startpos_" .. count + 1 .. "_z", 0, ALLIED)
							Spring.SetPlayerRulesParam(playerID, "startpos_" .. count + 1 .. "_def", DEFAULT_UNIT, ALLIED)
							Spring.SetPlayerRulesParam(playerID, "startpos_" .. count + 1 .. "_placed", false, ALLIED)
							Spring.SetPlayerRulesParam(playerID, "startpos_" .. count + 1 .. "_profile", "?", ALLIED)
							assigned = assigned + 1
						end
					end
				end
				if assigned ~= toassign then
					toassign = toassign - assigned
					assigned = 0
				end
			until assigned == toassign
		end
	end
end

local function SetPlayerOptions(movecomms, setcommander)
	Spring.SetPlayerRulesParam(playerID, "startpos_options_movestart", movecomms, ALLIED)
	Spring.SetPlayerRulesParam(playerID, "startpos_options_setcommander", setcommander, ALLIED)
end

local function ProcessString(str)
	str = str:gsub(" ", "") -- get rid of spaces to fit nicely into our template below
	local index, x, z = str:match("([^,]+),([^,]+),([^,]+)")
	return tonumber(index), tonumber(x), tonumber(z)
end

local function ProcessSetPlayerStartpos(str)
	str = str:gsub(" ", "") -- get rid of spaces to fit nicely into our template below
	local playerID, index, x, z, profileID = str:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
	return tonumber(playerID), tonumber(index), tonumber(x), tonumber(z)
end

local function ProcessCommanderString(str)
	str = str:gsub(" ", "")
	local profile, index = str:match("([^,]+),([^,]+)")
	return profile, index
end

local function ProccessForeignString(str)
	str = str:gsub(" ", "")
	local player, profile, index = str:match("([^,]+),([^,]+),([^,]+)")
	return player, profile, index
end

local function CheckStartPosition(teamID, x, z)
	local boxID = spGetTeamRulesParam(teamID, "start_box_id")
	return CheckStartbox(boxID, x, z)
end

local function getMiddleOfStartBox(teamID)
	local x = Game.mapSizeX / 2
	local z = Game.mapSizeZ / 2

	local boxID = Spring.GetTeamRulesParam(teamID, "start_box_id")
	if boxID then
		local startposList = GG.startBoxConfig[boxID] and GG.startBoxConfig[boxID].startpoints
		if startposList then
			local allyTeamID = select(6, Spring.GetTeamInfo(teamID))
			local maxpoints = #startposList
			local index = allyTeamAFKers[allyTeamID] or 0
			allyTeamAFKers[allyTeamID] = index + 1
			local startpos = startposList[(index%maxpoints) + 1] -- todo: distribute afkers over them all instead of always using the 1st
			x = startpos[1]
			z = startpos[2]
		end
	end

	return x, Spring.GetGroundHeight(x,z), z
end

local function GetStartPos(teamID, teamInfo, isAI)
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
	
	if not (Spring.GetTeamRulesParam(teamID, "valid_startpos") or isAI) then
		local x, y, z = getMiddleOfStartBox(teamID)
		return x, y, z
	end
	
	--local x, y, z = Spring.GetTeamStartPosition(teamID)
	-- clamp invalid positions
	-- AIs can place them -- remove this once AIs are able to be filtered through AllowStartPosition
	local boxID = isAI and Spring.GetTeamRulesParam(teamID, "start_box_id")
	if boxID and not GG.CheckStartbox(boxID, x, z) then
		x,y,z = getMiddleOfStartBox(teamID)
	end
	return x, y, z
end

local function SetStartPosition(playerID, index, x, z, def)
	local count = Spring.GetPlayerRulesParam(playerID, "commander_count")
	if index <= count then
		if x ~= nil and z ~= nil then
			Spring.SetPlayerRulesParam(playerID, "startpos_" .. index .. "_x", x, ALLIED)
			Spring.SetPlayerRulesParam(playerID, "startpos_" .. index .. "_z", z, ALLIED)
			Spring.SetPlayerRulesParam(playerID, "startpos_" .. index .. "_placed", true, ALLIED)
		end
		if def ~= nil then
			Spring.SetPlayerRulesParam(playerID, "startpos_" .. index .. "_def", def, ALLIED)
		end
		local isReady = Spring.GetPlayerRulesParam(playerID, "player_ready")
		if not isReady then
			for i = 1, count do
				local isPlaced = Spring.GetPlayerRulesParam(playerID, "startpos_" .. i .. "_placed")
				if not isPlaced then
					return
				end
			end
			Spring.SetPlayerRulesParam(playerID, "player_ready", true, PUBLIC)
		end
	end
end

local function GetFacingDirection(x, z)
	return (math.abs(Game.mapSizeX/2 - x) > math.abs(Game.mapSizeZ/2 - z))
			and ((x>Game.mapSizeX/2) and "west" or "east")
			or ((z>Game.mapSizeZ/2) and "north" or "south")
end

function gadget:RecvLuaMsg(msg, playerID)
	if msg:find("startpos") then -- startpos <index>,<x>,<z>
		msg = msg:gsub("startpos", "")
		local index, x, z = ProcessString(msg)
		local teamID = select(4, Spring.GetPlayerInfo(playerID))
		if CheckStartPosition(teamID, x, z) then
			SetStartPosition(playerID, index, x, z, def)
		end
	elseif msg:find("setplayerstartpos") then -- setplayerstartpos <playerID>,<x>,<z>,<profileID>
		msg = msg:gsub("setplayerstartpos", "")
		local targetPlayerID, index, x, z, profileID = ProcessSetPlayerStartpos(msg)
		local setpos = Spring.GetPlayerRulesParam(targetPlayerID, "startpos_options_movestart")
		local teamID = select(4, Spring.GetPlayerInfo(targetPlayerID)
		local myTeamID = select(4, Spring.GetPlayerInfo(playerID)
		if setpos and CheckStartPosition(teamID, x, z) and teamID == myTeamID then
			SetStartPosition(playerID, index, x, z, Spring.SetPlayerRulesParam(targetPlayerID, "startpos_" .. index .. "_def"))
		end
	elseif msg:find("setstartoptions") then -- setstartoptions placablecommander, settablecommander
		msg = msg:gsub("setstartoptions", "")
		msg = msg:gsub(" ", "")
		local setposition, setcommander = str:match("([^,]+),([^,]+)")
		SetPlayerOptions(setposition == "1", setcommander == "1")
	elseif (msg:find("ai_start_pos:",1,true) and setAiStartPos) then
		local msg_table = Spring.Utilities.ExplodeString(':', msg)
		if msg_table then
			local teamID, x, z = tonumber(msg_table[2]), tonumber(msg_table[3]), tonumber(msg_table[4])
			if teamID then
				local _,_,_,isAI = Spring.GetTeamInfo(teamID, false)
				if isAI and x and z then
					aiInfo[teamID][1].x = x
					aiInfo[teamID][1].z = z
					aiInfo[teamID][1].placed = true
					--Spring.MarkerAddPoint(x, 0, z, "AI " .. teamID .. " start")
				end
			end
		end
	elseif msg:find("customcomm:") then -- profileID, index
		
		local commanderProfile = GG.ModularCommAPI.GetCommProfileInfo(profileID)
		local def = (commanderProfile and commanderProfile.baseUnitDefID) or DEFAULT_UNIT
	elseif msg:find("setplayercomm") then
		
end

function gadget:RecvSkirmishAIMessage(aiTeam, dataStr)
	-- perhaps this should be a global relay mode somewhere instead
	local command = "ai_commander:"
	if dataStr:find(command,1,true) then
		local name = dataStr:sub(command:len()+1)
		aiInfo[aiTeam][1].def = name
	end
end

function gadget:AllowStartPosition(playerID, teamID, readyState, clampedX, clampedY, clampedZ, rawX, rawY, rawZ)
	if aiInfo[teamID] and CheckStartPosition(teamID, clampedX, clampedZ) then
		aiInfo[teamID][1].x = clampedX
		aiInfo[teamID][1].z = clampedZ
		aiInfo[teamID][1].placed = true
		return true
	else
		return false
	end
end

function gadget:GameStart()
	for teamID, data in pairs(aiInfo) do
		for i = 1, #data do
			local startinfo = data[i]
			local unitID = Spring.CreateUnit(startinfo.def, startinfo.x, Spring.GetGroundHeight(startinfo.x, startinfo.z), startinfo.z, GetFacingDirection(startinfo.x, startinfo.z), teamID)
		end
	end
	for i = 1, #ActivePlayers do
		local playerID = ActivePlayers[i]
		local count = Spring.GetPlayerRulesParam(playerID, "commander_count")
		local teamID = select(4, Spring.GetPlayerInfo(playerID))
		local lastx, lastz
		for i = 1, count do
			local x = Spring.GetPlayerRulesParam(playerID, "startpos_" .. i .. "_x")
			local z = Spring.GetPlayerRulesParam(playerID, "startpos_" .. i .. "_z")
			local def = Spring.GetPlayerRulesParam(playerID, "startpos_" .. i .. "_def")
			local placed = Spring.GetPlayerRulesParam(playerID, "startpos_" .. i .. "_placed")
			if placed then
				lastx = x
				lastz = z
			else
				if lastx and lastz then
					x = lastx
					z = lastz
				else
					local x, y, z = getMiddleOfStartBox(teamID)
					lastx = x
					lastz = z
				end
			end
			local unitID = Spring.CreateUnit(def, x, Spring.GetGroundHeight(x, z), z, GetFacingDirection(x, z), teamID)
		end
	end
end

function gadget:Initialize()
	SetUpPlayers()
	EqualizeCommanders()
end
