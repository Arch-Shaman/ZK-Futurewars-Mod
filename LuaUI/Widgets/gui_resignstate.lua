function widget:GetInfo()
	return {
		name      = "Resign State",
		desc      = "Handles Resign state",
		author    = "Shaman",
		date      = "4/15/2021",
		license   = "PD-0",
		layer     = 1,
		enabled   = true,  --  loaded by default?
		handler   = true,
	}
end

local myID = Spring.GetMyPlayerID()

local Chili, bigtext, window, Screen0, resignimage, grid, bigtextwindow
local mystate = (Spring.GetPlayerRulesParam(myID, "resign_state") or 0) == 1
local spSendLuaRulesMsg = Spring.SendLuaRulesMsg
local progressbars = {}
local exempt = {}
local switches = 2 -- number of times a user can switch states.
local allyteamstrings = {}
local maxresign
local allyteamcount = 0
local MyAllyTeamID = Spring.GetMyAllyTeamID()
local verboseResign = false
--[[local strings = {
	progressbar_help = "Resign Status:\nThe first number represents the number of people voting and the second is the threshold until the timer begins.\nNote: An unanimous vote will immediately resign your team!\n\n",
	exemption = "The following players do NOT currently count towards the total player count nor are their votes contributing to resign:\n",
	voted = "The following players want to resign:\n",
	enemyvote = "You are unaware of which players vote for resign!",
}]]

local firstVote = false

local localization = {
	want_resign_first = "\nYou've voted to surrender! Please wait until your allies agree to the surrender.\nIf enough players on your team wish to surrender, a timer will begin shortly.",
	want_resign = "\nYou've voted to surrender! Please wait until your allies agree to the surrender.",
	no_resign = "\nYou've rescinded your vote to surrender!",
}

local images = {
	on = "LuaUI/Images/epicmenu/whiteflag_check.png",
	off = "LuaUI/Images/epicmenu/whiteflag.png",
	warning = "LuaUI/Images/Crystal_Clear_app_error.png",
}

local colors = {
	high = {0, 0.8, 0, 0.7},            -- 80 - 100%
	medium_high = {0.73,0.9,0.37,0.7},  -- 60 - 80%
	medium = {1, 1, 0, 0.7},            -- 40 - 60%
	medium_low = {0.8, 0.8, 0, 0.7},    -- 20 - 40%
	low = {1, 0 ,0 , 0.7},              -- 00 - 20%
}

local function ToggleState()
	if switches == 0 or Spring.GetGameFrame() < 1 then
		return
	end
	mystate = not mystate
	if mystate and not firstVote then
		Spring.Echo("game_message:" .. localization.want_resign_first)
		Spring.PlaySoundFile("sounds/reply/advisor/resign_state_on.wav", 1.0, "userinterface")
		firstVote = true
	elseif mystate and firstVote then
		Spring.Echo("game_message:" .. localization.want_resign)
		Spring.PlaySoundFile("sounds/reply/advisor/resign_state_on.wav", 1.0, "userinterface")
	else
		Spring.Echo("game_message:" .. localization.no_resign)
		Spring.PlaySoundFile("sounds/reply/advisor/resign_state_off.wav", 1.0, "userinterface")
	end
	--Spring.Echo("MyState: " .. tostring(mystate))
	local n = (mystate and 1) or 0
	Spring.SendLuaRulesMsg("resignstate " .. n)
	local image = (mystate and images.on) or images.off
	resignimage.file = image
	resignimage:Invalidate()
	local text = "Toggle Resign State\nYou're currently"
	if mystate then
		text = text .. " wanting to resign."
	else
		text = text .. " not wanting to resign."
	end
	resignbutton.tooltip = text
	switches = switches - 1
end

WG.ToggleResignState = ToggleState

options_path = 'Settings/Interface/Resign State/'
options = {
	unmerge = {
		name = "Toggle Resign State",
		type = "button",
		OnChange = function(self)
			ToggleState()
		end,
		desc = "Toggles the current resign state.",
	},
	verbose = {
		name = "Verbose resignation",
		desc = "Informs you when a user changes their mind about resigning. Default: OFF",
		OnChange = function(self)
			verboseResign = self.value
		end,
		value = false,
		type = "boolean",
		NoHotkey = true,
	},
}

local c = 0

local function UpdatePlayer(playerID, state)
	if playerID < 0 then return end
	local name, _, _, _, allyTeamID = Spring.GetPlayerInfo(playerID)
	if allyTeamID == nil then return end
	if allyteamstrings[allyTeamID] == nil then
		allyteamstrings[allyTeamID] = {exempt = "", voted = ""}
	end
	if allyteamstrings[allyTeamID].exempt == nil then
		allyteamstrings[allyTeamID].exempt = ""
	end
	if state == "normal" then
		allyteamstrings[allyTeamID].exempt = allyteamstrings[allyTeamID].exempt:gsub("\n" .. name, "") or ""
	else
		allyteamstrings[allyTeamID].exempt = allyteamstrings[allyTeamID].exempt .. "\n" .. name
		allyteamstrings[allyTeamID].exempt = allyteamstrings[allyTeamID].exempt:gsub("\n\n", "\n")
	end
end

local function UpdateVote(playerID)
	if allyteamstrings[allyTeamID] == nil then
		allyteamstrings[allyTeamID] = {exempt = "", voted = ""}
	end
	local name, _, _, _, allyTeamID = Spring.GetPlayerInfo(playerID)
	local state = Spring.GetPlayerRulesParam(playerID, "resign_state") or false
	if state then
		allyteamstrings[allyTeamID].voted = allyteamstrings[allyTeamID].voted .. "\n" .. name
		allyteamstrings[allyTeamID].voted = allyteamstrings[allyTeamID].voted:gsub("\n\n", "\n")
	else
		allyteamstrings[allyTeamID].voted = allyteamstrings[allyTeamID].voted:gsub("\n" .. name, "")
	end
	if verboseResign then
		
	end
end

local function TimeToText(val) -- gives us 00:30 or 00:05
	local seconds = val%60
	local minutes = (val - seconds) / 60
	if seconds < 10 then -- under ten gets a lead zero
		seconds = "0" .. seconds
	end
	if minutes < 10 then -- ditto
		minutes = "0" .. minutes
	end
	return minutes .. ":" .. seconds
end

local function UpdateResignState(allyTeamID)
	--[[if allyteamstrings[allyTeamID] == nil then
		allyteamstrings[allyTeamID] = {exempt = "", voted = ""}
	end]]
	local total = Spring.GetGameRulesParam("resign_" .. allyTeamID .. "_total")
	local threshold = Spring.GetGameRulesParam("resign_" .. allyTeamID .. "_threshold")
	local count = Spring.GetGameRulesParam("resign_" .. allyTeamID .. "_count") or 0
	local timer = Spring.GetGameRulesParam("resign_" .. allyTeamID .. "_timer")
	local name = Spring.GetGameRulesParam("allyteam_long_name_" .. allyTeamID)
	local forcedTimer = Spring.GetGameRulesParam("resign_" .. allyTeamID .. "_forcedtimer")
	maxresign = Spring.GetGameRulesParam("resigntimer_max") or 180
	--Spring.Echo("Resign State" .. allyTeamID .. ":\nTotal: " .. tostring(total) .. "\nthreshold: " .. tostring(threshold) .. "\ncount: " .. count .. "\nTimer: " .. tostring(timer))
	local allied = allyTeamID == MyAllyTeamID
	local exempt = ""
	local resigned = ""
	if total == 0 and progressbars[allyTeamID] then
		progressbars[allyTeamID]:Dispose()
		states[allyTeamID] = nil -- destroyed.
		return
	end
	--[[local tooltip = strings["progressbar_help"] .. strings.exemption .. allyteamstrings[allyTeamID].exempt
	if allied or Spring.GetSpectatingState() then
		tooltip = tooltip .. "\n" .. strings.voted .. allyteamstrings[allyTeamID].voted
	else
		tooltip = tooltip .. "\n" .. strings.enemyvote
	end]]
	local timeLeft = TimeToText(timer)
	local vote = "[" .. count .. " / " .. threshold .. " ]"
	if (count > 0 or timer < maxresign - 5) and progressbars[allyTeamID] == nil then
		--Spring.Echo(name .. " ( allyTeamID: " .. allyTeamID .. ")")
		local text
		if count > 0 then
			text = WG.Translate("interface", "resign_state_voting", {name = name, count = vote})
		else
			text = name
		end
		progressbars[allyTeamID] = Chili.Progressbar:New{parent = grid, width = '100%', caption = text, useValueTooltip = true, min = 0, max = threshold, value = count}
		--Spring.Echo(progressbars[allyTeamID].y)
	end
	if progressbars[allyTeamID] and ((timer > maxresign - 5 and count == 0) or total == 0 or timer <= 0) then
		progressbars[allyTeamID]:Dispose() -- drop the bar because we have no need for it anymore.
		progressbars[allyTeamID] = nil
		return
	end
	if progressbars[allyTeamID] and (forcedTimer or count >= threshold) then
		progressbars[allyTeamID]:SetMinMax(0, maxresign)
		progressbars[allyTeamID]:SetCaption(WG.Translate("interface", "resign_state_resigning", {name = name, count = vote, time = timeLeft}) -- "%{name} Surrendering %{count}: %{time}"
		progressbars[allyTeamID]:SetValue(timer)
		local ratio = timer / maxresign
		if ratio >= 0.9 then
			progressbars[allyTeamID]:SetColor(colors["high"])
		elseif ratio >= 0.8 then
			progressbars[allyTeamID]:SetColor(colors["medium_high"])
		elseif ratio >= 0.6 then
			progressbars[allyTeamID]:SetColor(colors["medium"])
		elseif ratio >= 0.4 then
			progressbars[allyTeamID]:SetColor(colors["medium_low"])
		else
			progressbars[allyTeamID]:SetColor(colors["low"])
		end
	elseif progressbars[allyTeamID] then
		progressbars[allyTeamID]:SetMinMax(0, threshold)
		progressbars[allyTeamID]:SetValue(count)
		if total < 4 then
			vote = "[" .. count .. " / " .. total .. " ]"
		end
		progressbars[allyTeamID]:SetCaption(WG.Translate("interface", "resign_state_voting", {name = name, count = vote}))
		local ratio = count / threshold
		if allied then
			if ratio >= 0.75 then
				progressbars[allyTeamID]:SetColor(colors["low"])
			elseif ratio >= 0.5 then
				progressbars[allyTeamID]:SetColor(colors["medium"])
			elseif ratio >= 0.25 then
				progressbars[allyTeamID]:SetColor(colors["medium_high"])
			else
				progressbars[allyTeamID]:SetColor(colors["high"])
			end
		else
			if ratio >= 0.75 then
				progressbars[allyTeamID]:SetColor(colors["high"])
			elseif ratio >= 0.5 then
				progressbars[allyTeamID]:SetColor(colors["medium_high"])
			elseif ratio >= 0.25 then
				progressbars[allyTeamID]:SetColor(colors["medium"])
			else
				progressbars[allyTeamID]:SetColor(colors["low"])
			end
		end
	end
end

local function LocaleUpdated()
	localization.want_resign = "\n" .. WG.Translate("interface", "resign_state_want_resign")
	localization.want_resign_first = "\n" .. localization.want_resign .. "\n" .. WG.Translate("interface", "resign_state_want_resign_first")
	localization.no_resign = "\n" .. WG.Translate("interface", "resign_state_no_longer_want_resign")
	UpdateResignState()
end

function widget:Initialize()
	WG.InitializeTranslation(LocaleUpdated, GetInfo().name)
	widgetHandler:RegisterGlobal(widget, "UpdateResignState", UpdateResignState)
	widgetHandler:RegisterGlobal(widget, "UpdatePlayer", UpdatePlayer)
	widgetHandler:RegisterGlobal(widget, "UpdateVote", UpdateVote)
	Spring.SendLuaRulesMsg("resignrejoin") -- tell the gadget I want to rejoin (in case I already quit)
	Chili = WG.Chili
	Screen0 = Chili.Screen0
	if WG.GlobalCommandBar and not Spring.GetSpectatingState() then
		local image = mystate and images.on or images.off
		resignbutton = WG.GlobalCommandBar.AddCommand(image, "", ToggleState)
		local text = "Toggle Resign State\nYou're currently "
		if mystate then
			text = text .. "wanting to resign."
		else
			text = text .. "not wanting to resign."
		end
		resignbutton.tooltip = text
		for _, v in pairs(resignbutton.childrenByName) do -- there's only one here, so let's fetch it. The name is some random name so.. this is sadly necessary. Fortunately this doesn't have high perf cost I think.
			resignimage = v
		end
	end
	local allylist = Spring.GetAllyTeamList() -- parent = Screen0, width='20%',height='43.5%',x='0%',y='10%',resizable=false,draggable=false,dockable=true, padding = {0,0,0,0}, color = {0,0,0,0}
	window = Chili.Panel:New{parent=Screen0, width = '20%', height = '40.5%', x = '0%', y = '15%', resizable = false, resizeItems = false, draggable = false, dockable = false, padding = {0,0,0,0}, verticalScrollbar=true, horizontalScrollbar=false, scrollBarSize=150, backgroundColor = {0,0,0,0}, borderColor = {0,0,0,0}} -- in case of weird render sizes, etc.
	grid = Chili.Grid:New{parent = window, columns = 1, orientation = 'vertical', width = '500%', centerItems = false, height = "100%", itemPadding = {0.2,0.2,0.2,0.2}, resizeItems = false, minWidth = window.width, color = {0,0,0,0}, backgroundColor = {0,0,0,0}}
	for i = 1, #allylist do
		local allyTeamID = allylist[i]
		UpdateResignState(allyTeamID)
	end
end

function widget:PlayerChangedTeam(playerID)
	if playerID == myID then
		MyAllyTeamID = Spring.GetMyAllyTeamID()
	end
end

local t = Spring.GetTimer()
function widget:Update()
	local dif = Spring.DiffTimers(Spring.GetTimer(), t)
	if dif > 5 then
		if switches < 2 then
			switches = switches + 1
		end
		t = Spring.GetTimer()
	end
end

function widget:PlayerResigned(playerID)
	if playerID == myID and resignbutton ~= nil then
		resignbutton:Dispose()
		spSendLuaRulesMsg("resignstate playerresigned")
	end
end
