function gadget:GetInfo() return {
	name      = "Spectators as Zombies",
	desc      = "Spectators become zombies",
	author    = "Shaman",
	date      = "22 September 2022",
	license   = "CC-0",
	layer     = 8000,
	enabled   = true,
} end

local isEnabled
do
	local modoptions = Spring.GetModOptions()
	local playableZombies = tonumber(modoptions.playable_zombies or "0")
	Spring.Echo("PlayableZombies: " .. playableZombies)
	local zombies = tonumber(modoptions.zombies or "0")
	isEnabled = zombies == 1 and playableZombies == 1
end

if not isEnabled then return end

if (not gadgetHandler:IsSyncedCode()) then 
	function gadget:PlayerChanged(playerID)
		if playerID == Spring.GetMyPlayerID() then
			Spring.SendLuaRulesMsg("zombieismupdate")
		end
	end
	return 
end

local zombieCount = 0
local gaiaTeamID = Spring.GetGaiaTeamID()

local function ChangeToZombie(playerID)
	local name = Spring.GetPlayerInfo(playerID)
	Spring.AssignPlayerToTeam(playerID, gaiaTeamID)
	Spring.Echo("game_message: " .. name .. " became a zombie!")
end

function gadget:RecvLuaMsg(msg, playerID)
	if msg:find("zombieismupdate") then
		local name, active, spectator = Spring.GetPlayerInfo(playerID)
		if spectator then
			ChangeToZombie(playerID)
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if builderID and unitTeam == gaiaTeamID then
		local _, _, _, _, bp = Spring.GetUnitHealth(unitID)
		if bp < 1 then
			local cost = UnitDefs[unitDefID].metalCost
			Spring.SetUnitCosts(unitID, {buildTime = cost, metalCost = 0, energyCost = cost})
		end
	end
end

function gadget:GameStart()
	local playerList = Spring.GetPlayerList(-1, false)
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
	local randomTable = {"dynsupport0", "dynstrike0", "dynriot0", "dynassault0", "dynrecon0"}
	local xBound = Game.mapSizeX
	local yBound = Game.mapSizeZ
	local minX = xBound * 0.4
	local maxX = xBound * 0.6
	local minY = yBound * 0.4
	local maxY = yBound * 0.6
	for i = 1, zombieCount do
		local x = math.random(minX, maxX)
		local z = math.random(minY, maxY)
		local id = Spring.CreateUnit(randomTable[math.random(1, #randomTable)], x, Spring.GetGroundHeight(x, z), z, math.random(1, 4) - 1, gaiaTeamID)
		Spring.SetUnitResourcing(id, "ume", 6/zombieCount)
	end
end
