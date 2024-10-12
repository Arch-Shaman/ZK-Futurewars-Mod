function widget:GetInfo()
	return {
		name      = "Con Notifier",
		desc      = "Notifies when a player is out of cons",
		author    = "Shaman",
		date      = "10/11/2024",
		license   = "PD-0",
		layer     = 1,
		enabled   = true,  --  loaded by default?
		handler   = true,
	}
end

local ColorToInColor

local function GetTeamInColor(teamID)
	local teamColor = Spring.GetTeamColor(teamID)
	return ColorToInColor(teamColor)
end

local function GetTeamName(teamID)
	local playerList = Spring.GetPlayerList(teamID)
	local _, leader, _, isAI = Spring.GetTeamInfo(target, false)
	local name = select(1,Spring.GetPlayerInfo(leader, false))
	if isAI then
		name = select(2,Spring.GetAIInfo(target))
	end
	name = GetTeamInColor(teamID) .. name .. ColorToInColor({1, 1, 1, 1}) -- Colorize
	if #playerList > 1 then
		return name, true
	else
		return name, false
	end
end



local function OnConStateChange(teamID, hasCons)
	local name, squad = GetTeamName(teamID)
	if hasCons then
		if squad then
			Spring.Echo("game_message: " .. WG.Translate("interface", "has_cons_squad", {name = name}))
		else
			Spring.Echo("game_message: " .. WG.Translate("interface", "has_cons", {name = name}))
		end
	else
		if squad then
			Spring.Echo("game_message: " .. WG.Translate("interface", "has_no_cons_squad", {name = name}))
		else
			Spring.Echo("game_message: " .. WG.Translate("interface", "has_no_cons", {name = name}))
		end
	end
end

function widget:Initialize()
	WG.ConTracker.Subscribe(OnConStateChange, "connotifier")
	ColorToInColor = WG.Chili.color2incolor
end

function widget:ShutDown()
	WG.ConTracker.Unsubscribe("connotifier")
end

