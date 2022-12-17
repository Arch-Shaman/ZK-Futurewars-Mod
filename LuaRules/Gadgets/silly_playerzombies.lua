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

local isEnabled = tonumber(Spring.GetModOptions()["playable_zombies"] or "1") == 1

if not isEnabled then return end

local zombieCount = 0
local gaiaTeamID = Spring.GetGaiaTeamID()

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
			zombieCount = zombieCount + 1
		end
	end
	if zombieCount == 0 then
		zombieCount = math.random(1, 10)
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

function gadget:GameStart()
	local randomTable = {"dynsupport0", "dynstrike0", "dynriot0", "dynassault0", "dynrecon0"}
	local xBound = Game.mapSizeX
	local yBound = Game.mapSizeZ
	for i = 1, zombieCount do
		local x = math.random(xBound * 0.4, xBound * 0.6)
		local z = math.random(zBound * 0.4, zBound * 0.6)
		Spring.CreateUnit(randomTable[math.random(1, #randomTable)], x, Spring.GetGroundHeight(x, z), z)
	end
end
