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

-- config --

local function GetConfig()
	local modoptions = Spring.GetModOptions()
	local hivemind = modoptions.sharemode == "all"
	local alloweverywhere = modoptions.shuffle == "disable"
	local bonuscomms = modoptions.bonuscomms or false
	local aiplacement = modoptions.setaispawns
	local overrides = modoptions.commlimit
	overrides = overrides:gsub(" ", "") -- trim spaces.
	local overridetable = {}
	local count = 1
	local campaignBattleID = modOptions.singleplayercampaignbattleid -- is this a campaign?
	if campaignBattleID then
		campaign = true
	else
		for word in string.gmatch(str, '([^,]+)') do
			overridetable[count] = tonumber(word)
			count = count + 1
		end
		local allys = spGetAllyTeamList()
		for i = 1, #allys do
			local allyID = allys[i]
			if not overridetable[allyID] or overridetable[allyID] < 0 then -- remove negatives and nils by setting to 0 (no limit)
				overridetable[allyID] = 0
			elseif overridetable[allyID] > commlimit then
				overridetable[allyID] = commlimit
			end
		end
	end
	spEcho("[Startpos] Got config:\nCampaign: " .. tostring(campaign) .. "\nAllow Everywhere: " .. tostring(alloweverywhere) .. "\nAI Placement: " .. tostring(aiplacement) .. "\nHivemind Mode: " .. tostring(hivemind) .. "\nBonus comms: " .. tostring(bonuscomms))
	return {campaign = campaign, alloweverywhere = alloweverywhere, aiplacement = aiplacement, commoverrides = overridetable, hivemindmode = hivemind, bonuscomms = bonuscomms}
end

local config = GetConfig()

if config.campaign then -- use campaign handler instead.
	return
end

-- Common speedups --

local spGetPlayerRulesParam = Spring.GetPlayerRulesParam
local spGetPlayerInfo = Spring.GetPlayerInfo


-- Common Toolbox --
local function GetIsCommsharing(playerID)
	return spGetPlayerRulesParam(playerID, "commshare_orig_teamid") ~= nil
end

local function GetTeamID(playerID)
	local _, _, _, teamID = spGetPlayerInfo(playerID)
	return teamID
end

if not (gadgetHandler:IsSyncedCode()) then 					-- this entire segment's purpose is to just report changes to widgets.
	local myPlayerID = Spring.GetMyPlayerID()
	local spAreTeamsAllied = Spring.AreTeamsAllied
	local spSendSkirmishAIMessage = Spring.SendSkirmishAIMessage
	
	local function AIMsg(_, targetTeamID, teamID, data)
		if spAreTeamsAllied(teamID, targetTeamID) then
			spSendSkirmishAIMessage(teamID, data)
		end
	end
	
	local function updatestartinfo(_, teamID, update)
		local _, _, spec, myteamID = spGetPlayerInfo(myPlayerID)
		spEcho("[StartPos] updatestartinfo " .. teamID)
		if teamID == spGetMyTeamID() or spAreTeamsAllied(myteamID, teamID) or spec or update then -- update here is if say AI placement is used.
			Script.LuaUI.StartPosUpdate(teamID) -- tell startpos API that some team got updated.
		end
	end
	
	function gadget:RecvSkirmishAIMessage(aiTeam, dataStr) 
		if dataStr:find("aistartpos:") then -- gadget expects the following format: index,x,z where index 
			dataStr = dataStr:gsub("aistartpos:","")
			dataStr = "aistartpos:" .. aiTeam .. "," .. dataStr
			Spring.SendLuaRulesMsg(dataStr)
		end
	end
	
	function gadget:Initialize()
		gadgetHandler:AddSyncAction("updatestartinfo", updatestartinfo)
		gadgetHandler:AddSyncAction("SendAIMsg", AIMsg)
	end

	return
end

-- Headers --
VFS.Include("LuaRules\Configs\start_commanders.lua")

-- speedups --
local spGetTeamRulesParam = Spring.GetTeamRulesParam
local spSetTeamRulesParam = Spring.SetTeamRulesParam
local spGetAllyTeamList = Spring.GetAllyTeamList
local spGetTeamList = Spring.GetTeamList
local CheckStartBox = GG.CheckStartBox

local PUBLIC = {public = true}
local ALLIED = {allied = true}
local EMPTY  = {}

-- variables --
local startinfo = {} -- teamID[1..oo] = {unitdef, x, z, name, ownername, commID}
local reverselookup = {} -- commID = {teamID, index, origID}
local commlimit = 48 -- maximum comms per allyteam. This leaves a total of 816 comms possible.
local AIs = {} -- [1] = teamID, [2] = teamID, etc. This holds the list of AIs we must update.

--[[How these two tables work:
startinfo contains a list of teamIDs which are a metatable that holds a commID (a unique identifier)
when a team changes, we move the table over to the new id. the commID is then updated in reverse lookup in case of unmerge.
]]


-- Toolbox --

local function CheckStartPosition(teamID, x, z)
	local boxID = spGetTeamRulesParam(teamID, "start_box_id")
	return CheckStartbox(boxID, x, z)
end

local function ProcessCommString(str)
	str = str:gsub(" ", "") -- get rid of spaces to fit nicely into our template below
	local index, profileID = str:match("([^,]+),([^,]+)")
	index = tonumber(index)
	return index, profileID
end

local function UpdateStartInfo(teamID, index, visible)
	local data = startinfo[teamID][index]
	local x = data.x
	local z = data.z
	local def = data.unitdef
	if spGetTeamRulesParam(teamID, "player_ready") == nil then
		spSetTeamRulesParam(teamID, "player_ready", false, PUBLIC)
		spSetTeamRulesParam(teamID, "start_placed", 0) -- first time loading
	end
	if x ~= -1 and z ~= -1 then
		local placed = spGetTeamRulesParam(teamID, "start_placed")
		placed = placed + 1
		if placed == spGetTeamRulesParam(teamID, "startpos_indexes") then
			spSetTeamRulesParam(teamID, "player_ready", true, PUBLIC)
		end
		spSetTeamRulesParam(teamID, "start_placed", placed, PUBLIC)
	end
	if visible then
		spSetTeamRulesParam(teamID, "startpos_" .. index .. "_x", x, PUBLIC)
		spSetTeamRulesParam(teamID, "startpos_" .. index .. "_z", z, PUBLIC)
		spSetTeamRulesParam(teamID, "startpos_" .. index .. "_def", def, PUBLIC)
		SendToUnsynced("updatestartinfo", teamID, true)
	else
		spSetTeamRulesParam(teamID, "startpos_" .. index .. "_x", x, ALLIED)
		spSetTeamRulesParam(teamID, "startpos_" .. index .. "_z", z, ALLIED)
		spSetTeamRulesParam(teamID, "startpos_" .. index .. "_def", def, ALLIED)
		SendToUnsynced("updatestartinfo", teamID, false)
	end
	if #AIs > 0 then
		for i = 1, #AIs do
			local AITeamID = AIs[i]
			SendToUnsynced("SendAIMsg", teamID, AITeamID, "startposupdate:" .. teamID .. "," .. index .. "," .. x .. "," .. z .. "," .. def) -- tell AIs about the new start position. This allows AIs to be aware of players on their teams or other AIs.
		end
	end
end

local function ProcessStartposString(str)
	str = str:gsub(" ", "") -- get rid of spaces to fit nicely into our template below
	local targetTeamID, index, x, z = str:match("([^,]+),([^,]+),([^,]+),([^,]+)")
	targetTeamID = tonumber(targetTeamID)
	x = tonumber(x)
	z = tonumber(z)
	index = tonumber(index)
	return targetTeamID, index, x, z
end

local function ProcessCommander(id)
	local profile = GG.ModularCommAPI.GetCommProfileInfo(id)
	local unitdefID = profile.baseUnitDefID
	return unitdefID
end

local function CheckIndex(index, teamID)
	return not (index > #startinfo[teamID])
end

local function SetStartPosition(teamID, targetTeamID, index, x, z, visible)
	if not (teamID and targetTeamID and index and x and z) then
		spEcho("[StartPos] Handling error! Got:\nteamID: " .. tostring(teamID) .. "\ntargetID: " .. tostring(targetTeamID) .. "\nIndex: " .. tostring(index) .. "\nCoords: " .. tostring(x) .. "," .. tostring(z))
		return
	end
	local _, _, _, isAI = spGetTeamInfo(teamID)
	local commshareID = spGetTeamRulesParam(targetTeamID, "isCommsharing")
	spEcho("Update team startpos: " .. teamID .. ", " .. targetTeamID .. " on index " .. index .. " (coords: " .. x .. "," .. z .. ")\nChecking validity:\nisAI: " .. tostring(isAI) .. "\nisCommshareRequest: " .. tostring(teamID ~= targetTeamID) .. "\nCommshareID: " .. tostring(commshareID) .. "\nValidity: " .. tostring(CheckStartPosition(teamID, x, z)))
	if (teamID ~= targetTeamID and not commshareID == teamID) and (isAI and not config.aiplacement) then
		spEcho("[StartPos] TeamID " .. teamID .. " tried to set an invalid start position (" .. teamID .. "'s " .. index .. ")")
		return
	end
	if CheckStartPosition(teamID, x, z) or config.alloweverywhere then -- gadgets may bypass startpositions entirely.
		startinfo[targetTeamID][index].x = x
		startinfo[targetTeamID][index].z = z
		UpdateStartInfo(targetTeamID, index, visible)
	end
end

local function SetCommander(teamID, targetTeamID index, profileID)
	local unitdefID = ProcessCommander(profileID)
	if index and CheckIndex(teamID, index) and CheckTeam(teamID, targetTeamID) then
		startinfo[teamID][index].unitdef = ProcessComm(profileID)
		UpdateStartInfo(targetTeamID, index, false)
	end
end

local function GetBonusComms(allyteamID, numbonus) -- gets the highest elo players to give an extra comm to.
	if numbonus == 0 then
		return {}
	end
	local elo = {}
	local teamlist = spGetTeamList(allyteamID)
	for i = 1, #teamlist do
		local teamID = teamlist[i]
		local playerlist = spGetPlayerList(teamID, true)
		local teamelo = 0
		local teamcount = #playerlist
		if #playerlist > 0 then
			for p = 1, #playerlist do
				local playerID = playerlist[p]
				local cp = select(10, spGetPlayerInfo(playerID, false)) -- i forget what true does here.
				local elo = cp.elo or 0
				teamelo = teamelo + cp.elo or 0
			end
		end
		teamelo = teamelo / (math.max(teamcount, 1)) -- average elo, in case some crazy stuff in infra happens. (or worse: pregame commshare :O)
		elo[teamID] = teamelo
	end
	local count = 0
	local highest = -99999999999
	local highestid = 0
	local ret = {}
	repeat
		for id, elo in pairs(elo) do -- admittedly this isn't the cleanest but it runs only once so should be fine.
			if elo > highest then
				highest = elo
				highestid = id
			end
		end
		elo[highestid] = nil
		ret[#ret + 1] = highestid
		count = count + 1
	until count = numbonus
	return ret
end

local function Setup()
	local allys = spGetAllyTeamList()
	local playercounts = {}
	local comms = {}
	local isAI = {}
	local highest = 0
	local commoverrides = config.commoverrides
	for a = 1, #allys - 1 do -- step 1: get player counts. (ignore gaia, who is the last allyteam)
		local allyteamID = allys[a]
		playercounts[allyteamID] = 0
		local teamlist = spGetTeamList(allyteamID)
		local numAI = 0
		for t = 1, #teamlist do
			local teamID = teamlist[t]
			local _, _, _, isAI = spGetTeamInfo(teamID)
			if isAI then
				AIs[#AIs + 1] = teamID
				playercounts[allyteamID]
				numAI = numAI + 1
			else
				local playerlist = spGetPlayerList(teamID, true)
				playercounts[allyteamID] = playercounts[allyteamID] + #playerlist
			end
		end
		if playercounts[allyteamID] == 0 and numAI > 0 then
			isAI[allyteamID] = true
		end
		local playercount = playercounts[allyteamID]
		local commoverride = commoverrides[allyteamID]
		if commoverride == 0 or (playercounts[allyteamID] < commoverride and not config.hivemindmode) then -- in normal MP games, ensure everyone has at least one comm.
			comms[allyteamID] = playercounts[allyteamID] + numAI
		else
			comms[allyteamID] = commoverride
		end
		if playercounts[i] > highest then
			highest = playercounts[i]
		end
	end
	-- Step 2: Assign bonus comms.
	if config.bonuscomms then
		for i = 1, #playercounts do
			local commcount = commoverrides[i]
			if isAI[i] == nil and commcount == 0 and playercounts[i] < highest then
				comms[i] = highest
			end
		end
	end
	-- Step 3: Assign comms individually. Comms are rewarded evenly then split along elo lines. Note for purposes of pregame squads (eg startscript stuff) the average elo of the playerlist is taken.
	for i = 1, #playercounts do
		local commanders = comms[i]
		local playercount = playercounts[i]
		local extracomms = commsanders % playercount
		local commsperplayer = (commanders - extracomms) / playercount
		local teamlist = spGetTeamList(i)
		if commsperplayer == 0 or config.hivemindmode then -- this is a commshare mode.
			local predictedleader = GetBonusComms(i, 1)
			predictedleader = predictedleader[1]
			for t = 1, #teamlist do
				local teamID = teamlist[t]
				if teamID == predictedleader then
					startinfo[teamID] = {}
					for c = 1, commanders do
						startinfo[teamID][c] = {x = -1, z = -1, unitdef = DEFAULT_UNIT}
						UpdateStartInfo(teamID, c, false)
					end
					spSetTeamRulesParam(teamID, "startpos_indexes", commanders)
					spSetTeamRulesParam(teamID, "use_team_name", 1)
				else
					startinfo[teamID] = {}
					spSetTeamRulesParam(teamID, "startpos_indexes", 0)
					spSetTeamRulesParam(teamID, "player_ready", true)
				end
			end
		else
			local bonuscomms = GetBonusComms(i, extracomms)
			for t = 1, #teamlist do -- give everyone a commander (or more)
				local teamID = teamlist[t]
				for c = 1, commsperplayer do
					startpos[teamID][c] = {x = -1, z = -1, unitdef = DEFAULT_UNIT}
					UpdateStartInfo(teamID, c, false)
				end
				spSetTeamRulesParam(teamID, "startpos_indexes", commsperplayer)
				spSetTeamRulesParam(teamID, "player_ready", false)
			end
			if #bonuscomms > 0 then
				for b = 1, #bonuscomms do
					local teamID = bonuscomms[b]
					local count = #startpos[teamID]
					startpos[teamID][count + 1] = {x = -1, z = -1, unitdef = DEFAULT_UNIT}
					UpdateStartInfo(teamID, count + 1, false)
				end
				spSetTeamRulesParam(teamID, "startpos_indexes", count + 1)
			end
		end
	end
	Spring.Echo("Start system ready.")
end

-- Externals --
function GetStartPosition(teamID)
	return startinfo[teamID]
end

function GetCommStartPosition(commID)
	local teamID = reverselookup[commID].teamID
	local index = reverselookup[commID].index
	return startinfo[teamID][index]
end

function ForceSetStartPosition(teamID, index, x, z)
	if not (teamID and targetTeamID and index and x and z) then
		spEcho("[StartPos] Gadget Handling error! Got:\nteamID: " .. tostring(teamID) .. "\ntargetID: " .. tostring(targetTeamID) .. "\nIndex: " .. tostring(index) .. "\nCoords: " .. tostring(x) .. "," .. tostring(z))
	end
	-- gadgets may bypass startpositions entirely.
	startinfo[targetTeamID][index].x = x
	startinfo[targetTeamID][index].z = z
end

function ForceSetCommander(teamID, index, profileID)
	local unitdefID = ProcessCommander(profileID)
	if index and CheckIndex(teamID, index) then
		startinfo[teamID][index].unitdef = ProcessComm(profileID)
	end
end

function LegacyStartposSupport(teamID, profileID)

GG.StartHandler = {SetCommander = ForceSetCommander, SetStartPosition = ForceSetStartPosition, GetStartPositions = GetStartPosition, GetCommStartPosition = GetCommStartPosition}

-- callins --


function gadget:RecvLuaMsg(msg, playerID)
	if msg:find("customcomm",1,true) then -- widget says 'customcomm:<targetTeamID>,<index>,<profileID>'
		local profileID, targetTeamID, index = ProcessComm(msg:gsub("customcomm:",""))
		local _, _, _, teamID = spGetPlayerInfo(playerID)
		SetCommander(teamID, targetTeamID, index)
	elseif msg:find("ai_commander:", 1, true) then -- Legacy backwards Compat. Remove when other AIs have updated! AI should use customcomm!
		local command = "ai_commander:"
		local offset = msg:find(":", command:len() + 1,true)
		local teamID = msg:sub(command:len() + 1, offset - 1)
		local name = msg:sub(offset + 1)
		
		teamID = tonumber(teamID)
		
		local _, _, _, isAI = spGetTeamInfo(teamID, false)
		if(isAI) then -- this is actually an AI
			local aiid, ainame, aihost = Spring.GetAIInfo(teamID)
			if (aihost == playerID) then -- it's actually controlled by the local host
				local unitDef = UnitDefNames[name]
				if unitDef then -- the requested unit actually exists
					if aiCommanders[unitDef.id] then
						SetCommander(teamID, teamID, 1, unitDef.id)
					end
				end
			end
		end
	elseif (msg:find("ai_start_pos:", 1, true) and config.aiplacement) then
		local msg_table = Spring.Utilities.ExplodeString(':', msg)
		if msg_table then
			local index = tonumber(msg_table[5]) or 1 -- backwards compatibility.
			local teamID, x, z = tonumber(msg_table[2]), tonumber(msg_table[3]), tonumber(msg_table[4])
			if teamID then
				local _, _, _, isAI = Spring.GetTeamInfo(teamID, false)
				if isAI and x and z then
					SetStartPosition(teamID, index , x, z, true)
					--Spring.MarkerAddPoint(x, 0, z, "AI " .. teamID .. " start")
				end
			end
		end
	elseif msg:find("startpos", 1, true) then -- widget says 'startpos:teamID,index,x,z'
		msg = msg:gsub("startpos:", "") -- remove the start of the message
		local targetTeamID, index, x, z = ProcessStartposString(msg)
		local _, _, _, teamID = spGetPlayerInfo(playerID, false)
		SetStartPosition(teamID, targetTeamID, index, x, z, false)
	elseif msg:find("aistartpos", 1, true) then
		msg = msg:gsub("aistartpos:", "")
		local targetTeamID, index, x, z = ProcessStartposString(msg)
		SetStartPosition(targetTeamID, targetTeamID, index, x, z, false)
	end
end

function gadget:Initialize()
	local allys = spGetAllyTeamList()
	if not config.campaign then
		Setup()
		
	end
end

function gadget:GameStart()
	gadgetHandler:RemoveCallin('RecvLuaMsg') -- "Shutdown" the gadget's interfacing points.
end
