if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Facplop",
		desc      = "Implements facplopping.",
		author    = "Original by Licho, CarRepairer, Google Frog, SirMaverick. Rewritten by Shaman",
		date      = "September 21, 2020",
		license   = "PD",
		layer     = -1, -- Before terraforming gadget (for facplop terraforming)
		enabled   = true,  --  loaded by default?
	}
end

include("LuaRules/Configs/start_facplops.lua")

local spGetAllUnits = Spring.GetAllUnits
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spGetUnitHealth = Spring.GetUnitHealth
local spSpawnCEG = Spring.SpawnCEG
local spSetUnitHealth = Spring.SetUnitHealth
local spGetUnitPosition = Spring.GetUnitPosition
local spSendComamnds = Spring.SendCommands
local spGetPlayerInfo = Spring.GetPlayerInfo
local spGetTeamInfo = Spring.GetTeamInfo
local spPlaySoundFile = Spring.PlaySoundFile
local spGetGameFrame = Spring.GetGameFrame
local spGetUnitCurrentCommand = Spring.GetUnitCurrentCommand
local spEcho = Spring.Echo
local spGetUnitDefID = Spring.GetUnitDefID
local spIsCheatingEnabled = Spring.IsCheatingEnabled
local spSendCommands = Spring.SendCommands
local IN_LOS = {inlos = true}
local PRIVATE = {private = true}
local SETHEALTH = {health = 0, build = 1} -- Table for facplop to set max health on.

local modOptions = Spring.GetModOptions()
local campaignBattleID = modOptions.singleplayercampaignbattleid

local facplopsremaining = 0
local debugMode = false
local CampaignSafety = false

if VFS.FileExists("mission.lua") or campaignBattleID then
	CampaignSafety = true -- don't turn off the UnitCreated callin just in case. This can be removed later on when these changes are stable.
end
	
function GG.GiveFacplop(unitID) -- no longer deprecated due to how ShamanPlop's automatic shutoff works. Could become a global instead via Script.LuaRules.GiveFacPlop but this would involve rewriting who knows how many missions.
	facplopsremaining = facplopsremaining + 1
	local ud = UnitDefs[spGetUnitDefID(unitID)]
	if not ud.isBuilder and not ud.isMobileBuilder then
		return
	end
	spSetUnitRulesParam(unitID, "facplop", 1, IN_LOS)
	if facplopsremaining == 1 and not CampaignSafety then
		gadgetHandler:UpdateCallIn('UnitCreated')
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if ploppableDefs[unitDefID] and builderID and spGetUnitRulesParam(builderID, "facplop") == 1 then
		facplopsremaining = facplopsremaining - 1
		if debugMode then
			spEcho("Facplop: " .. unitID .. " (remaining: " .. facplopsremaining .. ")")
		end
		spSetUnitRulesParam(builderID, "facplop", 0, IN_LOS)
		spSetUnitRulesParam(unitID, "ploppee", 1, PRIVATE)
		local _, _, cmdTag = spGetUnitCurrentCommand(builderID)
		local _, maxHealth = spGetUnitHealth(unitID)
		SETHEALTH.health = maxHealth
		spSetUnitHealth(unitID, SETHEALTH)
		local x, y, z = spGetUnitPosition(unitID)
		GG.Lagmonitor.RegisterFacPlop(unitID, builderID)
		spSpawnCEG("teleport_in", x, y, z)
		-- This is obsolete, but still live. See ZKDev chat.
		--[[local _, playerID, _, isAI, _, allyTeam = spGetTeamInfo(unitTeam, false)
		local facname = UnitDefs[unitDefID].name
		local playername = spGetPlayerInfo(playerID, false) or "ChanServ"  -- ditto, different acc to differentiate
		local str = "SPRINGIE:facplop," .. facname .. "," .. unitTeam .. "," .. allyTeam .. ","
		if isAI then
			str = str .. "Nightwatch" -- existing account just in case infra explodes otherwise
		else
			str = str .. playername
		end
		str = str .. ",END_PLOP"
		spSendCommands("wbynum 255 " .. str)]]
		GG.PlayFogHiddenSound("Teleport2", 10, x, y, z) -- this is fine now because of preloading
		if facplopsremaining == 0 and not CampaignSafety then
			if debugMode then
				spEcho("No facplops remaining. Disabling UnitCreated.")
			end
			gadgetHandler:RemoveCallIn('UnitCreated')
		end
		--spGiveOrderToUnit(builderID, CMD.REMOVE, cmdTag, CMD.OPT_CTRL) -- This seems to cause a recursion error sometimes
	end
end

local function CheckUnits()
	local allunits = spGetAllUnits()
	if #allunits == 0 then
		return
	end
	for i=1, #allunits do
		local unitID = allunits[i]
		if spGetUnitRulesParam(unitID, "facplop") == 1 then
			facplopsremaining = facplopsremaining + 1
			if debugMode then
				spEcho("Facplops left: " .. facplopsremaining)
			end
		end
	end
end

local function ToggleDebug()
	if spIsCheatingEnabled() then -- toggle debugMode
		debugMode = not debugMode
	else
		spEcho("[Facplop] Enable cheats to toggle debug mode.")
		return
	end
	if debugMode then
		spEcho("[Facplop] Debug enabled.")
	else
		spEcho("[Facplop] Debug disabled.")
	end
end

function gadget:Load() -- TODO: implement proper saving the amount of facplops remaining.
	CheckUnits()
	if facplopsremaining == 0 and not CampaignSafety then
		gadgetHandler:RemoveCallIn('UnitCreated')
	end
end

function gadget:Initialize()
	gadgetHandler:AddChatAction("debugfacplop", ToggleDebug, "Toggles facplop debugMode echos.")
end
