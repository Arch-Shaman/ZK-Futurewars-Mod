function gadget:GetInfo()
	return {
		name      = "Comm Spawner",
		desc      = "Spawns commanders on game start.",
		author    = "Shaman",
		date      = "September 20, 2020",
		license   = "PD",
		layer     = 11, -- specifically after commshare to register changes.
		enabled   = true  --  loaded by default?
	}
end

if not (gadgetHandler:IsSyncedCode()) then -- entirely synced.
	return
end

VFS.Include("LuaRules/Configs/start_commanders.lua")
VFS.Include("LuaRules/Configs/start_resources.lua")

local spGetTeamList = Spring.GetTeamList
local spGetAllyTeamList = Spring.GetAllyTeamList
local spGetTeamRulesParam = Spring.GetTeamRulesParam
local spGetGroundHeight = Spring.GetGroundHeight
local modoptions = Spring.GetModOptions()
local giveextra = modoptions.giveresources == "all" or true
local campaign = modOptions.singleplayercampaignbattleid ~= nil
local spSpawnCEG = Spring.SpawnCEG
local spCreateUnit = Spring.CreateUnit
local spGetTeamInfo = Spring.GetTeamInfo

local commanders = {}

--Script.LuaRules.GiveStartResources(teamID)

local function GetFacingDirection(x, z)
	return (math.abs(Game.mapSizeX/2 - x) > math.abs(Game.mapSizeZ/2 - z))
			and ((x>Game.mapSizeX/2) and "west" or "east")
			or ((z>Game.mapSizeZ/2) and "north" or "south")
end

function gadget:GameStart()
	local allys = spGetAllyTeamList()
	for a = 1, #allys do
		local allyteamID = allys[a]
		local teamlist = spGetTeamList(allyteamID)
		for t = 1, #teamlist do
			local teamID = teamlist[t]
			if campaign then
				
			else
				commanders[teamID] = {}
				local indexes = spGetTeamRulesParam(teamID, "startpos_indexes")
				for i = 1, indexes do
					local x = spGetTeamRulesParam(teamID, "startpos_" .. i .. "_x")
					local z = spGetTeamRulesParam(teamID, "startpos_" .. i .. "_z")
					local y = spGetGroundHeight(x, z)
					local def = spGetTeamRulesParam(teamID, "startpos_" .. i .. "_def")
					commanders[teamID][i] = {x = x, z = z, y = y, def = def}
				end
			end	
		end
	end
end

function gadget:Load()
	if Spring.GetGameFrame() > 2 then
		gadgetHandler:RemoveGadget()
	end
end

function gadget:GameFrame(f)
	if f == 2 then
		for i = 1, #commanders do
			local _, _, _, _, _, allyTeamID = spGetTeamInfo(teamID)
			local data = commanders[i]
			for j = 1, #data do
				local def = data.def
				local x = data.x
				local y = data.y
				local z = data.z
				local owner = spGetTeamRulesParam(targetTeamID, "isCommsharing") or i
				local facing = GetFacingDirection(x, z)
				local unitID = spCreateUnit(def, x, y, z, facing, owner)
				GG.GiveFacplop(unitID)
				SetUpCommander(i)
				spSpawnCEG("gate", x, y, z)
				if GG.Overdrive then
					GG.Overdrive.AddInnateIncome(allyTeamID, INNATE_INC_METAL, INNATE_INC_ENERGY)
				end
				if giveextra or j == 1 then
					Script.LuaRules.GiveStartResources(teamID)
				end
			end
		end
		gadgetHandler:RemoveGadget(gadget)
	end
end
