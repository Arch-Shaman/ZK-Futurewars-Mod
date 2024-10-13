function widget:GetInfo()
	return {
		name      = "Con Notifier",
		desc      = "Notifies when your team is out of cons and gives an easy global command bar fix.",
		author    = "Shaman",
		date      = "4/15/2021",
		license   = "PD-0",
		layer     = 1,
		enabled   = true,  --  loaded by default?
		handler   = true,
	}
end

local ColorToInColor

local needsCons = {}

local global_command_button
local spGetPlayerRulesParam = Spring.GetPlayerRulesParam

local function IsPlayerAFK(playerID)
	return spGetPlayerRulesParam(playerID, "lagmonitor_lagging") ~= nil
end

local function SendGameMessage(str)
	Spring.Echo("game_message: " .. str)
end

local function IsTeamAFK(teamID)
	local playerList = Spring.GetPlayerList(teamID)
	--Spring.Echo("Number of players: " .. tostring(#playerList))
	if #playerList == 0 then return false end
	for p = 1, #playerList do
		local playerID = playerList[p]
		if not spGetPlayerRulesParam(playerID, "lagmonitor_lagging") then
			return false
		end
	end
	return true
end

local function ShareUnits(playername, teamID)
	if not teamID then
		Spring.Echo('Con Notifier: Invalid team to share.')
		return
	end
	if IsTeamAFK(teamID) then
		Spring.Echo("game_message: Can't share units to an AFK team.")
		return
	end
	local selcnt = Spring.GetSelectedUnitsCount()
	if selcnt > 0 then
		Spring.SendCommands("say a: I gave a constructor to "..playername..".") -- TODO: localize this.
		Spring.ShareResources(teamID, "units")
	else
		Spring.Echo('Con Notifier: No units selected to share.')
	end
end

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

local function IsFunctionalAI(teamID)
	local isAI = select(4, Spring.GetTeamInfo(teamID))
	local isOriginallyAI = Spring.GetTeamRulesParam(teamID, "initAI")
	local functional = true
	isAI = isAI or isOriginallyAI
	if not isAI and isOriginallyAI then
		functional = false
	end
	return isAI, functional
end

local function OnButtonClick(teamID, isAI)
	local playerName
	if isAI then
		_, playerName = Spring.GetAIInfo(teamID)
	else
		local teamLeader = select(2, Spring.GetTeamInfo(teamID))
		playerName = Spring.GetPlayerInfo(teamLeader)
	end
	local selection = WG.ConTracker.GetIdleCons()
	local selected
	local currentSelection = Spring.GetSelectedUnits()
	if selection == nil or #selection == 0 then -- nothing idle!
		SendGameMessage(ColorToInColor({0.7,0,0,1}) .. WG.Translate("Interface", "give_con_no_con"))
		return 
	end 
	for i = 1, #selection do
		local unitDefID = Spring.GetUnitDefID(selection[i])
		local ud = UnitDefs[unitDefID]
		if ud.customParams.level == nil and ud.customParams.dynamic_comm == nil and not ud.isFactory then
			selected = selection[i]
			Spring.SelectUnit(selected)
			ShareUnits(playerName, teamID)
			Spring.SelectUnitMap(currentSelection)
			return
		end
	end
	SendGameMessage(ColorToInColor(errorColor) .. WG.Translate("Interface", "give_con_no_con"))
end

local function DoTheThing()
	if WG.ConTracker.GetConstructorsCount(Spring.GetMyTeamID()) < 1 then 
		SendGameMessage(ColorToInColor(errorColor) .. WG.Translate("Interface", "give_con_no_con")) 
		return 
	end
	local longestWaiter = 9999999999999999999999999
	local pickedTeam = -1
	local pickedAI
	for teamID, gameFrame in pairs(needsCons) do
		local isAI, functional = IsFunctionalAI(teamID)
		local effectiveFrame = gameFrame
		if isAI and functional then
			effectiveFrame = gameFrame * 3 -- have AIs lower priority than players.
		elseif isAI and not functional then
			needsCons[teamID] = nil -- this AI is broken and will never be fixable. Don't bother. (FIXME: change in the future!). Pray to engine lords for your success.
		else
			local isAFK = IsTeamAFK(teamID)
			if isTeamAFK(teamID) then -- pick AFK human teams last.
				effectiveFrame = 99999999
			end
		end
		if effectiveFrame < longestWaiter then
			longestWaiter = gameFrame
			pickedTeam = teamID
			pickedAI = isAI
		end
	end
	if teamID == -1 then return end
	OnButtonClick(pickedTeam, pickedAI)
end


local function OnConStateChange(teamID, hasCons)
	local frame = Spring.GetGameFrame()
	if frame < 10 then return end
	if IsTeamAFK(teamID) then return end
	local name, squad = GetTeamName(teamID)
	if hasCons then
		needsCons[teamID] = nil
		if squad then
			SendGameMessage(WG.Translate("interface", "has_cons_squad", {name = name}))
		else
			SendGameMessage(WG.Translate("interface", "has_cons", {name = name}))
		end
	else
		needsCons[teamID] = frame
		if squad then
			SendGameMessage(WG.Translate("interface", "has_no_cons_squad", {name = name}))
		else
			SendGameMessage(WG.Translate("interface", "has_no_cons", {name = name}))
		end
	end
end

local function OnLocaleChanged()
	global_command_button.tooltip = WG.Translate("interface", "give_con_button")
	global_command_button:Invalidate()
end

function widget:Initialize()
	WG.ConTracker.Subscribe(OnConStateChange, "connotifier")
	ColorToInColor = WG.Chili.color2incolor
	local f = Spring.GetGameFrame()
	local spec = Spring.GetSpectatingState()
	if f > 0 and not spec then -- game started
		local teamsWithoutCons = WG.ConTracker.GetTeamsWithoutCons()
		for teamID, _ in pairs(teamsWithoutCons) do
			needsCons[teamID] = f
		end
	end
	if not spec then
		global_command_button = WG.GlobalCommandBar.AddCommand("LuaUI/Images/Misc/no_cons.png", WG.Translate("interface", "give_con_button"), DoTheThing)
	end
	WG.InitializeTranslation(OnLocaleChanged, GetInfo().name)
end

function widget:ShutDown()
	WG.ConTracker.Unsubscribe("connotifier")
end

