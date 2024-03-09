function gadget:GetInfo()
	return {
		name      = "Resign Handler",
		desc      = "Handles Resign state",
		author    = "Shaman, terve886",
		date      = "4/15/2021",
		license   = "PD-0",
		layer     = 1,
		enabled   = true  --  loaded by default?
	}
end

if not gadgetHandler:IsSyncedCode() then
	local function MakeUpdate(_, allyTeamID)
		--Spring.Echo("MakeUpdate: " .. tostring(allyTeamID))
		if Script.LuaUI('UpdateResignState') then
			Script.LuaUI.UpdateResignState(allyTeamID)
		end
	end
	
	local function MakePlayerUpdate(_, playerID, state)
		if Script.LuaUI('UpdatePlayer') then
			Script.LuaUI.UpdatePlayer(playerID, state)
		end
	end
	
	function gadget:Initialize()
		gadgetHandler:AddSyncAction("MakeUpdate", MakeUpdate)
		gadgetHandler:AddSyncAction("MakePlayerUpdate", MakePlayerUpdate)
	end
	return
end

local DestroyAlliance = GG.DestroyAlliance
local PUBLIC = {public = true}
local ALLIED = {allied = true}

local states = {} -- allyTeamID = {count = num, playerStates = {}}
local playerMap = {} -- playerID = allyTeamID
local resigntimer = 180 -- timer starts at 3 minutes and loses a second every 3rd second (down to 60s) over the first 6 minutes.
local mintime = 60
local resignteams = {}
local exemptplayers = {} -- players who are exempt.
local afkplayers = {}

-- config --

local thresholds = {
	[1] = 1,
	[2] = 2,
	[3] = 2,
	[4] = 3,
	[5] = 3,
	[6] = 4,
	[7] = 4,
	[8] = 5,
	[9] = 5,
	[10] = 5,
	[11] = 6,
	[12] = 6,
	[13] = 7,
	[14] = 7,
	[15] = 8,
	[16] = 8,
}

local function GetAllyTeamPlayerCount(allyTeamID)
	local teamlist = Spring.GetTeamList(allyTeamID)
	local aiteam = true
	local aicount = 0
	local playerCount = 0
	for i = 1, #teamlist do
		local teamID = teamlist[i]
		local teamAI = select(2, Spring.GetAIInfo(teamID))
		if teamAI then
			aicount = aicount + 1
		else
			aiteam = false
		end
		local playerList = Spring.GetPlayerList(teamID) -- spectators are ignored as of 104.0
		for p = 1, #playerList do
			local playerID = playerList[p]
			if Spring.GetPlayerRulesParam(playerID, "lagmonitor_lagging") == nil and exemptplayers[playerID] == nil then
				playerCount = playerCount + 1
			end
		end
	end
	return playerCount
end

local function GetAllyTeamThreshold(allyTeamID)
	local playerCount = GetAllyTeamPlayerCount(allyTeamID)
	local threshold = thresholds[playerCount] or math.max(math.ceil((playerCount / 2) + 1), math.min(playerCount, 3))
	if threshold > playerCount then
		threshold = playerCount
	end
	return threshold, playerCount
end

local function AddResignTeam(allyTeamID)
	local count = #resignteams
	for i = 1, count do
		if resignteams[i] then
			return
		end
	end
	resignteams[count + 1] = allyTeamID
end

local function RemoveResignTeam(allyTeamID)
	local id
	if #resignteams == 1 then
		resignteams[1] = nil
		return
	end
	for i = 1, #resignteams do
		if resignteams[i] == allyTeamID then
			id = i
			break
		end
	end
	if id == nil then
		return
	end
	resignteams[id] = resignteams[#resignteams]
	resignteams[#resignteams] = nil
end

local function CheckAllyTeamState(allyTeamID)
	if states[allyTeamID].count == states[allyTeamID].total then
		states[allyTeamID].timer = 1
		DestroyAlliance(allyTeamID)
		RemoveResignTeam(allyTeamID)
	end
	if states[allyTeamID].count >= states[allyTeamID].threshold and not states[allyTeamID].thresholdState then
		states[allyTeamID].thresholdState = true
		AddResignTeam(allyTeamID)
	elseif states[allyTeamID].count < states[allyTeamID].threshold and states[allyTeamID].thresholdState then
		states[allyTeamID].thresholdState = false
	end
end

local function UpdatePlayerResignState(playerID, state, update)
	local allyTeamID = playerMap[playerID]
	local currentState = states[allyTeamID].playerStates[playerID] or false
	local val
	if state then val = 1 else val = 0 end
	Spring.SetPlayerRulesParam(playerID, "resign_state", val, ALLIED)
	if currentState == state then
		return
	end
	local mod = 0
	if state then
		mod = 1
	else
		mod = -1
	end
	states[allyTeamID].count = states[allyTeamID].count + mod
	Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_count", states[allyTeamID].count, PUBLIC)
	states[allyTeamID].playerStates[playerID] = state
	if update then
		CheckAllyTeamState(allyTeamID)
	end
	SendToUnsynced("MakeUpdate", allyTeamID)
end

local function UpdateAllyTeam(allyTeamID)
	states[allyTeamID].threshold, states[allyTeamID].total = GetAllyTeamThreshold(allyTeamID)
	Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_threshold", states[allyTeamID].threshold, PUBLIC)
	Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_total", states[allyTeamID].total, PUBLIC)
	SendToUnsynced("MakeUpdate", allyTeamID)
end

local function AFKUpdate(playerID)
	if not playerMap[playerID] then
		return
	end
	local state = Spring.GetPlayerRulesParam(playerID, "lagmonitor_lagging") or 0
	local allyTeamID = playerMap[playerID]
	if state == 1 and not afkplayers[playerID] then
		local wantsResign = states[allyTeamID].playerStates[playerID]
		afkplayers[playerID] = states[allyTeamID].playerStates[playerID] or false
		UpdateAllyTeam(allyTeamID)
		UpdatePlayerResignState(playerID, false, true)
		SendToUnsynced("MakePlayerUpdate", playerID, "afk")
	elseif state == 0 and afkplayers[playerID] ~= nil then
		local wantedresign = afkplayers[playerID]
		afkplayers[playerID] = nil
		UpdateAllyTeam(allyTeamID)
		if wantedresign then
			UpdatePlayerResignState(playerID, true, true)
		end
		SendToUnsynced("MakePlayerUpdate", playerID, "normal")
	end
end

GG.ResignState = {UpdateAFK = AFKUpdate}

function gadget:Initialize()
	local allyteamlist = Spring.GetAllyTeamList()
	Spring.Echo("ResignState: Loading")
	Spring.SetGameRulesParam("resigntimer_max", resigntimer, PUBLIC)
	for a = 1, #allyteamlist do
		local allyTeamID = allyteamlist[a]
		states[allyTeamID] = {
			playerStates = {},
			count = 0,
			timer = resigntimer,
		}
		states[allyTeamID].threshold, states[allyTeamID].total = GetAllyTeamThreshold(allyTeamID)
		Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_threshold", states[allyTeamID].threshold, PUBLIC)
		Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_total", states[allyTeamID].total, PUBLIC)
		Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_count", 0, PUBLIC)
		Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_timer", resigntimer, PUBLIC)
		local teamlist = Spring.GetTeamList(allyTeamID)
		for t = 1, #teamlist do
			local teamID = teamlist[t]
			local playerList = Spring.GetPlayerList(teamID)
			for p = 1, #playerList do
				local playerID = playerList[p]
				states[allyTeamID].playerStates[playerID] = false
				Spring.SetPlayerRulesParam(playerID, "resign_state", 0, ALLIED)
				playerMap[playerID] = allyTeamID
			end
		end
	end
end

local function UpdateResignTimer(allyTeamID)
	Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_timer", states[allyTeamID].timer, PUBLIC)
	SendToUnsynced("MakeUpdate", allyTeamID)
end

function gadget:GameFrame(f)
	if f%90 == 15 then
		if resigntimer > mintime then
			for i = 0, #states do
				if states[i].timer >= resigntimer - 1 then
					states[i].timer = states[i].timer - 1
					UpdateResignTimer(i)
					SendToUnsynced("MakeUpdate", i)
				end
			end
			resigntimer = resigntimer - 1
			Spring.SetGameRulesParam("resigntimer_max", resigntimer, PUBLIC)
		end
		if #resignteams > 0 then
			for i = 1, #resignteams do
				local allyTeamID = resignteams[i]
				if not states[allyTeamID].thresholdState then
					states[allyTeamID].timer = states[allyTeamID].timer + 1
					UpdateResignTimer(allyTeamID)
					if states[allyTeamID].timer == resigntimer then
						RemoveResignTeam(allyTeamID)
					end
				end
				SendToUnsynced("MakeUpdate", allyTeamID)
			end
		end
	end
	if f%30 == 0 and #resignteams > 0 then
		for i = 1, #resignteams do
			local allyTeamID = resignteams[i]
			if states[allyTeamID].thresholdState then
				states[allyTeamID].timer = states[allyTeamID].timer - 1
				UpdateResignTimer(allyTeamID)
				if states[allyTeamID].timer == 0 then
					if GetAllyTeamPlayerCount(allyTeamID) > 1 then
						Spring.Echo("game_message: Team " .. allyTeamID .. " Destroyed due to morale.")
					end
					DestroyAlliance(allyTeamID)
					RemoveResignTeam(allyTeamID)
					Spring.SetGameRulesParam("resign_" .. allyTeamID .. "_total", 0, PUBLIC)
					SendToUnsynced("MakeUpdate", allyTeamID)
				end
			end
		end
	end
end

function gadget:GameOver()
	gadgetHandler:RemoveCallIn("gameframe") -- stop teams from resigning.
end

function gadget:RecvLuaMsg(msg, playerID)
	if playerMap[playerID] == nil then
		return
	end
	local allyTeamID = playerMap[playerID]
	if msg:find("forceresign") or msg == "resignstate playerresigned" then
		if allyTeamID == nil then
			return
		end
		UpdatePlayerResignState(playerID, false, false)
		states[allyTeamID].playerStates[playerID] = nil
		playerMap[playerID] = nil
		exemptplayers[playerID] = true
		UpdateAllyTeam(allyTeamID)
		CheckAllyTeamState(allyTeamID)
		SendToUnsynced("MakePlayerUpdate", playerID, "exempt")
	end
	if msg:find("resignstate") and Spring.GetGameFrame() > 1 then -- resignstate 1 or resignstate 0
		msg = msg:gsub("resignstate", "")
		msg = msg:gsub(" ", "")
		local s = tonumber(msg)
		if s ~= nil then
			UpdatePlayerResignState(playerID, s == 1, true)
		end
	end
	if msg == "resignquit" and playerMap[playerID] then
		UpdatePlayerResignState(playerID, false, true)
		exemptplayers[playerID] = true
		UpdateAllyTeam(allyTeamID)
		CheckAllyTeamState(allyTeamID)
		SendToUnsynced("MakePlayerUpdate", playerID, "exempt")
	end
	if msg == "resignrejoin" and playerMap[playerID] and exemptplayers[playerID] then
		exemptplayers[playerID] = nil
		UpdateAllyTeam(allyTeamID)
		CheckAllyTeamState(allyTeamID)
		SendToUnsynced("MakePlayerUpdate", playerID, "normal")
	end
end
