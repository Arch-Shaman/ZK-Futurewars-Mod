function gadget:GetInfo() return {
	name      = "Spectators as Zombies",
	desc      = "Spectators become zombies",
	author    = "Shaman",
	date      = "22 September 2022",
	license   = "CC-0",
	layer     = 22,
	enabled   = true,
} end

if (not gadgetHandler:IsSyncedCode()) then 
	function gadget:PlayerChanged(playerID)
		if playerID == Spring.GetMyPlayerID() then
			Spring.SendLuaRulesMsg("zombieismupdate")
		end
	end
	
	return 
end


local gaiaTeamID = Spring.GetGaiaTeamID()
local isEnabled = tonumber(Spring.GetModOptions()["playable_zombies"] or "1") == 1


local function ChangeToZombie(playerID)
	local name = Spring.GetPlayerInfo(playerID)
	Spring.AssignPlayerToTeam(playerID, gaiaTeamID)
	Spring.Echo("game_message: " .. name .. " became a zombie!")
end

function gadget:GameStart()
	local playerList = Spring.GetPlayerList()
	for i = 1, #playerList do
		local playerID = playerList[i]
		local name, active, spectator = Spring.GetPlayerInfo(playerID)
		if spectator then
			ChangeToZombie(playerID)
		end
	end
end

function gadget:RecvLuaMsg(msg, playerID)
	if msg:find("zombieismupdate") then
		local name, active, spectator = Spring.GetPlayerInfo(playerID)
		if spectator then
			ChangeToZombie(playerID)
		end
	end
end
