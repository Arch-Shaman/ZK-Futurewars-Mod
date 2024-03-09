function gadget:GetInfo() 
	return {
		name    = "Resign Gadget",
		desc    = "Resign stuff",
		author  = "KingRaptor",
		date    = "2012.5.1",
		license = "Public domain",
		layer   = -2,
		enabled = true,
	} 
end

if (not gadgetHandler:IsSyncedCode()) then
	function gadget:PlayerChanged(playerID)
		if Spring.GetGameFrame() < 1 or playerID ~= Spring.GetMyPlayerID() then return end
		local amIInitialPlayer = (Spring.GetPlayerRulesParam(playerID, "initiallyPlayingPlayer") or 0) == 1
		if not amIInitialPlayer then
			return
		end
		Spring.Echo("Resign::PlayerChanged")
		local _, _, spec, teamID = Spring.GetPlayerInfo(playerID, false)
		local _, _, isDead = Spring.GetTeamInfo(teamID, false)
		if spec and not isDead then
			Spring.Echo("Tell lua rules I said hi")
			Spring.SendLuaRulesMsg("selfresigned")
		end
	end
	return 
end

local spGetPlayerInfo = Spring.GetPlayerInfo
local spKillTeam = Spring.KillTeam
local spSetTeamRulesParam = Spring.SetTeamRulesParam
local spGetPlayerList = Spring.GetPlayerList

local function ResignTeam(teamID)
	Spring.Echo("Resigning team " .. teamID)
	spKillTeam(teamID)
	spSetTeamRulesParam(teamID, "WasKilled", 1)
end

local function ResignAllyTeam(allyTeamID)
	for i, teamID in pairs (Spring.GetTeamList(allyTeamID)) do
		ResignTeam (teamID)
	end
end

function gadget:Initialize()
	GG.ResignTeam = ResignTeam
	GG.ResignAllyTeam = ResignAllyTeam
end

local function CheckPlayer(playerID, isAlreadySpec)
	if Spring.GetGameFrame() <= 0 then return end
	local isInitialPlayer = (Spring.GetPlayerRulesParam(playerID, "initiallyPlayingPlayer") or 0) == 1
	Spring.Echo("CheckPlayer:" .. playerID .. ": " .. tostring(isInitialPlayer))
	if not isInitialPlayer then
		return
	end
	local _, _, spec, teamID = spGetPlayerInfo(playerID, false)
	local playersOnTeam = #spGetPlayerList(teamID)
	Spring.Echo("CheckPlayer:" .. playerID .. ": " .. tostring(spec) .. ", " .. playersOnTeam)
	if (spec and not isAlreadySpec) or playersOnTeam > 1 then -- don't kill the entire squad until the last member resigns
		return
	end
	ResignTeam(teamID)
end

function gadget:RecvLuaMsg (msg, playerID)
	if msg == "forceresign" or msg == "selfresigned" then
		CheckPlayer(playerID, false)
	elseif msg == "selfresigned" then
		CheckPlayer(playerID, true)
	else
		return
	end
end

function gadget:GotChatMsg (msg, senderID)
	if Spring.GetGameFrame() <= 0 then
		return
	end
	if string.find(msg, "resignteam") ~= 1 then
		return
	end

	local allowed = false
	if (senderID == 255) then -- Springie
		allowed = true
	else
		local playerkeys = select (10, spGetPlayerInfo(senderID))
		if playerkeys and (playerkeys.admin == "1" or playerkeys.room_boss == "1") then
			allowed = true
		end
	end
	if not allowed then
		return
	end

	local target = string.sub(msg, 12)
	local players = spGetPlayerList()
	for i = 1, #players do
		local playerID = players[i]
		local nick, _, isSpectator, teamID = spGetPlayerInfo(playerID, false)
		if target == nick then
			if isSpectator then
				return
			end

			local commshareID = Spring.GetPlayerRulesParam(playerID, "commshare_orig_teamid")
			if commshareID or #Spring.GetPlayerList(teamID) > 1 then
				teamID = GG.UnmergePlayerFromCommshare(playerID)
			end

			if #Spring.GetPlayerList(teamID) > 1 then
				Spring.Echo("Force-resign: comshare unmerge failed, other players still on team", nick, "playerID", playerID, "teamID", teamID)
			end

			ResignTeam(teamID)
			return
		end
	end
end
