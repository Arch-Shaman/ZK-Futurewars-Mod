if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Resource Setup",
		desc      = "Implements storage and starting resources.",
		author    = "Original by Licho, CarRepairer, Google Frog, SirMaverick. Rewritten by Shaman.",
		date      = "September 21, 2020",
		license   = "PD",
		layer     = -2, -- before facplop and start_unit_setup
		enabled   = true  --  loaded by default?
	}
end

local storagedefs = {}
include("LuaRules/Configs/constants.lua")
include("LuaRules/Configs/start_resources.lua")
local mission = VFS.FileExists("mission.lua")

local loaded = false
local spGetTeamUnitDefCount = Spring.GetTeamUnitDefCount
local spSetTeamResource = Spring.SetTeamResource
local spGetTeamInfo = Spring.GetTeamInfo
local spGetTeamResources = Spring.GetTeamResources
local tobool = Spring.Utilities.tobool

for i=1, #UnitDefs do -- added for mod support or future proofing in case of desiring to add innate storage to everything.
	local ud = UnitDefs[i]
	if ud.metalStorage then
		storagedefs[i] = ud.metalStorage
	end
end

local function SetupStorage(teamID)
	--Spring.Echo("Setting up storage")
	local ammount = 0
	for id, storage in pairs(storagedefs) do
		ammount = ammount + spGetTeamUnitDefCount(teamID, id) * storage
	end
	ammount = HIDDEN_STORAGE + (ammount * GG.GetTeamHandicap(teamID))
	spSetTeamResource(teamID, "es", ammount)
	spSetTeamResource(teamID, "ms", ammount)
	spSetTeamResource(teamID, "energy", 0)
	spSetTeamResource(teamID, "metal", 0)
end

local function GiveStartResources(teamID) -- Called each time a commander spawns.
	--Spring.Echo("Giving starting resources")
	local metal = spGetTeamResources(teamID, "metal")
	local energy = spGetTeamResources(teamID, "energy")
	local teamInfo = teamID and select(7, spGetTeamInfo(teamID, true))
	local mult = GG.GetTeamHandicap(teamID)
	--Spring.Echo("To give: " .. tostring(teamInfo.start_energy) .. " or " .. START_ENERGY + energy)
	local wantede = teamInfo.start_energy or (START_ENERGY + energy)
	local wantedm = teamInfo.start_metal or (START_METAL + metal)
	wantede = wantede * mult
	wantedm = wantedm * mult
	--Spring.Echo("giving " ..wantede .. " to " .. teamID)
	spSetTeamResource(teamID, "energy", wantede)
	spSetTeamResource(teamID, "metal", wantedm)
end

function gadget:Shutdown()
	gadgetHandler:DeregisterGlobal('GiveStartResources')
end

function gadget:Load()
	loaded = true
end

function gadget:Initialize()
	if not (tobool(Spring.GetGameRulesParam("loadedGame")) or loaded) and mission then
		local teamlist = spGetTeamList()
		for i=1, #teamlist do
			local teamID = teamlist[i]
			local _, _, _, _, _, _, teamInfo = spGetTeamInfo(teamID, true)
			spSetTeamResource(teamID, "es", START_STORAGE + HIDDEN_STORAGE)
			spSetTeamResource(teamID, "ms", START_STORAGE + HIDDEN_STORAGE)
		end
	elseif not (tobool(Spring.GetGameRulesParam("loadedGame")) or loaded) and not mission then
		local teamlist = Spring.GetTeamList()
		for i=1, #teamlist do
			local teamID = teamlist[i]
			SetupStorage(teamID)
		end
	end
	gadgetHandler:RegisterGlobal('GiveStartResources', GiveStartResources)
end
