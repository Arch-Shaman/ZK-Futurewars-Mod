--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Commwars Income Handler",
		desc      = "Bonus income in commwars",
		author    = "luminastuffphoton",
		date      = "11 Dec 2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0, -- After start unit gadget
		enabled   = true  --  loaded by default?
	}
end

local commwars = false

if (Spring.GetModOptions) then
	local modOptions = Spring.GetModOptions()
    if modOptions then
		commwars = modOptions.commwars or "0" == "1"
	end
end

if not commwars then
	gadgetHandler:RemoveGadget()
	return
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- BEGIN SYNCED

if gadgetHandler:IsSyncedCode() then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local baseStorage = 100000
local nextGiftTime = 210 * 30
local giftInterval = 90 * 30
local giftNum = 1
local giftValues = {
	2,
	3,
	4,
	5,
	1.5
}
local giftEnergyMult = 10

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GameFrame(n)
	if n < nextGiftTime then
		return
	end
	nextGiftTime = nextGiftTime + giftInterval
	local giftAmount = giftValues[math.min(giftNum, #giftValues)]
	giftNum = giftNum + 1

	local allyteams = Spring.GetAllyTeamList()
	local gaia = Spring.GetGaiaTeamID()
	local allyteamsDamages = {}
	local allyteamsOrdered = {}
	local lastDamage = nil

	for index, allyteamID in pairs(allyteams) do
		local teams = Spring.GetTeamList(allyteamID)
		local totalDamage = 0
		local alive = false
		for _, teamID in pairs(teams) do
			totalDamage = totalDamage + Spring.Utilities.GetHiddenTeamRulesParam(teamID, "stats_history_damage_dealt_current")
			local dead = Spring.GetTeamRulesParam(teamID, "isDead") == 1
			alive = (alive or (not dead)) and (teamID ~= gaia)
		end
		--Spring.Echo("game_message: team "..allyteamID.." is "..((alive and "alive") or "dead"))
		if not alive then
			allyteams[index] = nil
		else
			allyteamsDamages[allyteamID] = math.floor(totalDamage)
		end
	end

	while next(allyteams) do
		local bestDamage = -1
		local bestIndex = 0
		for index, allyteamID in pairs(allyteams) do
			if allyteamsDamages[allyteamID] > bestDamage then
				bestIndex = index
				bestDamage = allyteamsDamages[allyteamID]
			end
		end

		if bestDamage == lastDamage then
			local tiers = allyteamsOrdered[#allyteamsOrdered]
			tiers[#tiers+1] = allyteams[bestIndex]
		else
			allyteamsOrdered[#allyteamsOrdered + 1] = {allyteams[bestIndex]}
		end
		allyteams[bestIndex] = nil
		lastDamage = bestDamage
	end

	local valuePerPlace = giftAmount / #allyteamsOrdered

	Spring.Echo("game_message: It's income gift time!")
	for rank, allyteams in ipairs(allyteamsOrdered) do
		for _, allyteamID in pairs(allyteams) do
			local reward = (#allyteamsOrdered - rank + 1) * valuePerPlace * (GG.allyTeamCommanderCount[allyteamID] or 1)

			SendToUnsynced("PrintUIMessage", false, nextGiftTime, allyteamID, reward, rank)
			GG.Overdrive.AddInnateIncome(allyteamID, reward, reward * giftEnergyMult)
		end
	end

	SendToUnsynced("PrintUIMessage", true, nextGiftTime)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
-- END SYNCED
-- BEGIN UNSYNCED
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- the following function is copied from gui_chili_chicken.lua, made by quantum, KingRaptor in May 04, 2008. Released under GPLv2 or later
local function FormatTime(s)
	if not s then return '' end
	s = math.floor(s)
	local neg = (s < 0)
	if neg then s = -s end	-- invert it here and add the minus sign later, since it breaks if we try to work on it directly
	local m = math.floor(s/60)
	s = s%60
	local h = math.floor(m/60)
	m = m%60
	if s < 10 then s = "0"..s end
	if m < 10 then m = "0"..m end
	local str
	if h < 1 then
		str= (m..":"..s)
	else
		str= (h..":"..m..":"..s)
	end
	if neg then str = "-"..str end
	return str
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function PrintUIMessage(_, specWrapper, nextGiftTime, allyteamID, reward, rank)
	if specWrapper then
		if Spring.GetSpectatingState() then
			Spring.Echo("game_message: The next income gift will occur at "..FormatTime(nextGiftTime/30))
		end
		return
	end


	if not (Spring.GetSpectatingState() or (allyteamID == Spring.GetMyAllyTeamID())) then
		return
	end

	if Spring.GetSpectatingState() then
		local name = Spring.GetGameRulesParam("allyteam_long_name_" .. allyteamID) or allyteamID
		Spring.Echo("game_message: For having the #"..rank.." damage dealt, team "..name.." receives +"..("%.1f"):format(reward).." m/s.")
	else
		Spring.Echo("game_priority_message: For having the #"..rank.." damage dealt, Your team receives +"..("%.1f"):format(reward).." m/s.")
		if rank > 1 then
			Spring.Echo("game_message: The next income gift will occur at "..FormatTime(nextGiftTime/30)..", fight enemy commanders to get a bigger share of the next income gift.")
		else
			Spring.Echo("game_message: The next income gift will occur at "..FormatTime(nextGiftTime/30))
		end
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction('PrintUIMessage', PrintUIMessage)
end

end
-- END UNSYNCED
--------------------------------------------------------------------------------

