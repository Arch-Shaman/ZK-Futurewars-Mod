
function widget:GetInfo()
	return {
		name      = "Chili Crude Player List v2",
		desc      = "An inexpensive playerlist.",
		author    = "GoogleFrog",
		date      = "8 November 2019",
		license   = "GNU GPL, v2 or later",
		layer     = 50,
		enabled   = true,
	}
end

if Spring.GetModOptions().singleplayercampaignbattleid then
	function widget:Initialize()
		Spring.SendCommands("info 0")
	end

	return
end

-- A test game: http://zero-k.info/Battles/Detail/797379
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local myAllyTeamID          = Spring.GetMyAllyTeamID()
local myTeamID              = Spring.GetMyTeamID()
local myPlayerID            = Spring.GetMyPlayerID()
local mySpectating          = Spring.GetSpectatingState()
local spGetPlayerRulesParam = Spring.GetPlayerRulesParam

if mySpectating then
	myTeamID = false
	myAllyTeamID = false
end
local fallbackAllyTeamID    = Spring.GetMyAllyTeamID()

local Chili
local playerStatuses = {}

local function GetColorChar(colorTable)
	if colorTable == nil then return string.char(255,255,255,255) end
	local col = {}
	for i = 1, 4 do
		col[i] = math.ceil(colorTable[i]*255)
	end
	return string.char(col[4],col[1],col[2],col[3])
end

local pingCpuColors = {
	{0, 1, 0, 1},
	{0.7, 1, 0, 1},
	{1, 1, 0, 1},
	{1, 0.6, 0, 1},
	{1, 0, 0, 1},
	{1, 1, 1, 1},
}

local ALLY_COLOR  = {0, 1, 1, 1}
local ENEMY_COLOR = {1, 0, 0, 1}

local PING_TIMEOUT = 10 -- seconds. Remember: pingTime is in seconds!

local MAX_NAME_LENGTH = 150

local UPDATE_PERIOD = 1

local IMAGE_SHARE  = ":n:" .. LUAUI_DIRNAME .. "Images/playerlist/share.png"
local IMAGE_CPU    = ":n:" .. LUAUI_DIRNAME .. "Images/playerlist/cpu.png"
local IMAGE_PING   = ":n:" .. LUAUI_DIRNAME .. "Images/playerlist/ping.png"
local IMAGE_AWAY   = ":n:" .. LUAUI_DIRNAME .. "Images/Misc/away.png"
local IMAGE_NOCON  = ":n:" .. LUAUI_DIRNAME .. "Images/Misc/no_cons.png"
local IMAGE_RESIGN = ":n:" .. LUAUI_DIRNAME .. "Images/Crystal_Clear_action_flag_white.png"
local IMAGE_DISCONNECTED = ":n:" .. LUAUI_DIRNAME .. "Images/connection_lost.png"
local IMAGE_REJOINING = ":n:" .. LUAUI_DIRNAME .. "Images/clock.png"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function PingTimeOut(pingTime)
	if pingTime < 1 then
		return "Ping " .. (math.floor(pingTime*1000) ..'ms')
	elseif pingTime > 999 then
		return "Ping " .. ('' .. (math.floor(pingTime*100/60)/100)):sub(1,4) .. 'min'
	end
	--return (math.floor(pingTime*100))/100
	return "Ping " .. ('' .. (math.floor(pingTime*100)/100)):sub(1,4) .. 's' --needed due to rounding errors.
end

local function CpuUsageOut(cpuUsage)
	return "CPU usage " .. math.ceil(cpuUsage*100) .. "%"
end

local function ToGrey(v)
	if v < 0.6 then
		return 0.6 - 0.1*(0.6 - v)
	end
	return 0.6 + 0.1*(v - 0.6)
end

local function GetName(name, font, state)
	if state.isDead then
		name = "<Dead> " .. name
	--[[elseif state.isLagging then
		name = "<Lagging> " .. name
	elseif state.isWaiting then
		name = "<Waiting> " .. name
	elseif state.isAfk then
		name = "<AFK> " .. name]]
	elseif state.isResigning then -- TODO: Localization.
		name = "<Surrendering>"
	end
	
	if not font then
		return name
	end
	return Spring.Utilities.TruncateStringIfRequiredAndDotDot(name, font, MAX_NAME_LENGTH) or name
end

local function GetPlayerTeamColor(teamID, isDead)
	local r, g, b, a = Spring.GetTeamColor(teamID)
	if isDead then
		r, g, b = ToGrey(r), ToGrey(g), ToGrey(b)
	end
	return {r, g, b, a}
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

local function IsPlayerAFK(playerID)
	return spGetPlayerRulesParam(playerID, "lagmonitor_lagging") ~= nil
end

local function ShareUnits(playername, teamID)
	if not teamID then
		Spring.Echo('Player List: Invalid team to share.')
		return
	end
	if IsTeamAFK(teamID) then
		Spring.Echo("game_message: Can't share units to an AFK team.")
		return
	end
	local selcnt = Spring.GetSelectedUnitsCount()
	if selcnt > 0 then
		Spring.SendCommands("say a: I gave "..selcnt.." units to "..playername..".")
		Spring.ShareResources(teamID, "units")
	else
		Spring.Echo('Player List: No units selected to share.')
	end
end
	

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function UpdateStatusImage(controls, waiting, afk, cons, lagging)
	if not controls then Spring.Echo("No controls!"); return end
	--Spring.Echo("cons: " .. tostring(cons))
	if cons == nil then cons = true end
	cons = not cons
	if cons and Spring.GetGameFrame() < 30 then
		cons = false
	end
	local visibilityState = waiting or afk or cons or lagging
	if visibilityState ~= controls.imStatus.visible then
		if visibilityState then
			controls.imStatus:Show()
		else
			controls.imStatus:Hide()
			return
		end
	end
	if waiting then -- disconnected
		controls.imStatus.file = IMAGE_DISCONNECTED
	elseif lagging then -- lagging
		controls.imStatus.file = IMAGE_REJOINING
	elseif afk then -- afk
		controls.imStatus.file = IMAGE_AWAY
	elseif cons then -- no cons
		controls.imStatus.file = IMAGE_NOCON
	end
	controls.imStatus:Invalidate()
end

local aiHosts = {}

local function UpdateEntryData(entryData, controls, pingCpuOnly, forceUpdateControls)
	local newTeamID, newAllyTeamID = entryData.teamID, entryData.allyTeamID
	local newIsLagging = entryData.isLagging
	local newIsWaiting = entryData.isWaiting
	local isSpectator = false
	local isAFK = false

	local teamHasCons = WG.ConTracker.GetTeamConStatus(entryData.teamID)
	local needsConUpdate = entryData.hasCons ~= teamHasCons
	local needsUpdating = needsConUpdate
	--Spring.Echo("Team " .. newTeamID .. " has cons: " .. tostring(teamHasCons))
	if controls and entryData.hasCons ~= teamHasCons then
		entryData.hasCons = teamHasCons
	end
	if needsUpdating and not entryData.playerID then
		--Spring.Echo("Updating con status: " .. tostring(teamHasCons))
		UpdateStatusImage(controls, false, false, teamHasCons, false)
		--Spring.Echo("Updating team status")
		--[[if entryData.isAI then
			if entryData.aiHost then
				local aiEntryData = playersByPlayerID[entryData.aiHost].entryData
				UpdateStatusImage(controls, aiEntryData.isWaiting, false, not teamHasCons, aiEntryData.isLagging)
			else
				UpdateStatusImage(controls, false, false, not teamHasCons, false)
			end
		end]]
	end
	
	if entryData.playerID then
		local playerName, active, spectator, teamID, allyTeamID, pingTime, cpuUsage, country, rank = Spring.GetPlayerInfo(entryData.playerID, false)
		newTeamID, newAllyTeamID = teamID, allyTeamID
		
		entryData.isMe = (entryData.playerID == myPlayerID)
		
		if spectator then
			isSpectator = true
			newTeamID, newAllyTeamID = entryData.initTeamID,  entryData.initAllyTeamID
		end
		
		local pingBucket = (active and math.max(1, math.min(5, math.ceil(math.min(pingTime, 1) * 5)))) or 6
		if forceUpdateControls or pingBucket ~= entryData.pingBucket then
			entryData.pingBucket = pingBucket
			if controls then
				controls.imPing.color = pingCpuColors[entryData.pingBucket]
				controls.imPing:Invalidate()
			end
		end
		
		local cpuBucket = (active and math.max(1, math.min(5, math.ceil(cpuUsage * 5)))) or 6
		if forceUpdateControls or cpuBucket ~= entryData.cpuBucket then
			entryData.cpuBucket = cpuBucket
			if controls then
				controls.imCpu.color = pingCpuColors[entryData.cpuBucket]
				controls.imCpu:Invalidate()
			end
		end
		
		if controls then
			controls.imCpu.tooltip = CpuUsageOut(cpuUsage)
			controls.imPing.tooltip = PingTimeOut(pingTime)
		end
		pingTime = pingTime
		newIsLagging = pingTime and (pingTime > PING_TIMEOUT)
		--Spring.Echo(entryData.playerID .. " lagging: " .. tostring(newIsLagging) .. "(" .. tostring(pingTime) .. ")")
		isAFK = IsPlayerAFK(entryData.playerID)
		newIsWaiting = (not active)
		if forceUpdateControls or newIsLagging ~= entryData.isLagging then
			entryData.isLagging = newIsLagging
			needsUpdating = true
		end
		
		if isAFK ~= entryData.isAfk then
			entryData.isAfk = isAFK
			needsUpdating = true
		end
		
		if newIsWaiting ~= entryData.isWaiting then
			entryData.isWaiting = newIsWaiting
			needsUpdating = true
		end
		
		if controls and (needsUpdating or forceUpdate) then
			--Spring.Echo("Updating player " .. entryData.playerID)
			UpdateStatusImage(controls, entryData.isWaiting, entryData.isAfk, teamHasCons, entryData.isLagging)
			--[[if (entryData.isWaiting or entryData.isLagging) and aiHosts[entryData.playerID] then
				for i = 1, #aiHosts[entryData.playerID] do
					local teamID = aiHosts[entryData.playerID][i]
					--Spring.Echo("Updating AI " .. teamID)
					local AIcontrols = teamByTeamID[teamID]
					if AIcontrols then
						UpdateStatusImage(AIcontrols, entryData.isWaiting, false, WG.ConTracker.GetTeamConStatus(teamID), entryData.isLagging)
					end
				end
			end]] -- Do not bother until engine makes AI resisitation possible.
		end
		
		--[[newIsAfk = (spGetPlayerRulesParam(entryData.playerID, "lagmonitor_lagging") and true) or false
		if forceUpdateControls or newIsAfk ~= entryData.isAfk then
			entryData.isAfk = newIsAfk
			if controls and not (entryData.isDead or entryData.isLagging or entryData.isWaiting) then
				controls.textName:SetCaption(GetName(entryData.name, controls.textName.font, entryData))
			end
		end]]
		
		if pingCpuOnly then
			return false
		end
	elseif pingCpuOnly then
		return false
	end
	
	-- Ping and CPU cannot resort
	local resortRequired = false
	if forceUpdateControls or newTeamID ~= entryData.teamID then
		entryData.teamID = newTeamID
		entryData.isMyTeam = (entryData.teamID == myTeamID)
		resortRequired = true
		if controls then
			controls.textName.font.color = GetPlayerTeamColor(entryData.teamID, entryData.isDead)
			controls.textName:Invalidate()
		end
	end
	
	if forceUpdateControls or newAllyTeamID ~= entryData.allyTeamID then
		entryData.allyTeamID = newAllyTeamID
		resortRequired = true
		if controls then
			controls.textAllyTeam:SetCaption(entryData.allyTeamID + 1)
		end
	end
	
	local isMyAlly = (entryData.allyTeamID == (myAllyTeamID or fallbackAllyTeamID))
	if forceUpdateControls or isMyAlly ~= entryData.isMyAlly then
		entryData.isMyAlly = isMyAlly
		entryData.allyTeamColor = (isMyAlly and ALLY_COLOR) or ENEMY_COLOR
		resortRequired = true
		if controls then
			controls.textAllyTeam.font.color = entryData.allyTeamColor
			controls.textAllyTeam:Invalidate()
			
			controls.btnShare:SetVisibility((myAllyTeamID and entryData.isMyAlly and not entryData.isDead and (entryData.teamID ~= myTeamID) and true) or false)
		end
	end
	local newIsDead = ((isSpectator or Spring.GetTeamRulesParam(entryData.teamID, "isDead")) and true) or false
	if forceUpdateControls or newIsDead ~= entryData.isDead then
		entryData.isDead = newIsDead
		if controls then
			controls.textName:SetCaption(GetName(entryData.name, controls.textName.font, entryData))
			controls.textName.font.color = GetPlayerTeamColor(entryData.teamID, entryData.isDead)
			controls.textName:Invalidate()
		end
	end
	
	return resortRequired
end

local function GetEntryData(playerID, teamID, allyTeamID, isAiTeam, isDead, hasCons)
	--Spring.Echo("Get Entry Data: " .. tostring(playerID) .. ", " .. teamID)
	local entryData = {
		playerID = playerID,
		teamID = teamID,
		allyTeamID = allyTeamID,
		initTeamID = teamID,
		initAllyTeamID = allyTeamID,
		isAiTeam = isAiTeam,
		isDead = isDead,
		hasCons = hasCons,
	}
	
	if isAiTeam then -- first run
		local host = select(3, Spring.GetAIInfo(entryData.teamID))
		--Spring.Echo("Host is " .. host)
		entryData.aiHost = host
		if host then
			if aiHosts[host] then
				aiHosts[host][#aiHosts[host] + 1] = entryData.teamID
			end
		end
	end
	
	if playerID then
		local playerName, active, spectator, teamID, allyTeamID, pingTime, cpuUsage, country, rank, customKeys = Spring.GetPlayerInfo(playerID, true)
		customKeys = customKeys or {}
		
		entryData.isMe = (entryData.playerID == myPlayerID)
		entryData.name = playerName
		entryData.country = (country and country ~= '' and ("LuaUI/Images/flags/" .. country ..".png"))
		entryData.rank = ("LuaUI/Images/LobbyRanks/" .. (customKeys.icon or "0_0") .. ".png")
		
		if customKeys.clan and customKeys.clan ~= "" then
			entryData.clan = "LuaUI/Configs/Clans/" .. customKeys.clan ..".png"
		elseif customKeys.faction and customKeys.faction ~= "" then
			entryData.clan = "LuaUI/Configs/Factions/" .. customKeys.faction .. ".png"
		end
	end
	
	if isAiTeam then
		local _, name = Spring.GetAIInfo(teamID)
		entryData.name = name
	end
	
	if not entryData.name then
		entryData.name = "noname"
	end
	
	UpdateEntryData(entryData)
	
	return entryData
end

local function OnStatusClick(teamID)
	local playerList = Spring.GetPlayerList(teamID)
	local isBot = #playerList == 0
	local isAFK = false
	if #playerList > 0 then
		local playerActive = false
		for i = 1, #playerList do
			local playerID = playerList[i]
			if not IsPlayerAFK(playerID) then
				playerActive = true
			end
		end
		isAFK = not playerActive
	end
	if WG.ConTracker.GetTeamConStatus(teamID) and not isAFK then
		local playerName, _, _, playerTeam = Spring.GetPlayerInfo(playerID)
		local selection = WG.ConTracker.GetIdleCons()
		local selected
		local currentSelection = Spring.GetSelectedUnits()
		for i = 1, #selection do
			local unitDefID = Spring.GetUnitDefID()
			local ud = UnitDefs[unitDefID]
			if ud.customParams.level == nil and ud.customParams.dynamic_comm == nil then
				selected = selection[i]
				Spring.SelectUnit(selected)
				ShareUnits(playerTeam, playerName)
				Spring.SelectUnitMap(currentSelection)
				return
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function GetUserControls(playerID, teamID, allyTeamID, isAiTeam, isDead, parent, hasCons)
	--Spring.Echo("GetUserControls: " .. tostring(playerID) .. ", " .. tostring(teamID))
	local offset             = 0
	local offsetY            = 0
	local height             = options.text_height.value + 4
	local userControls = {}

	userControls.entryData = GetEntryData(playerID, teamID, allyTeamID, isAiTeam, isDead, hasCons)

	userControls.mainControl = Chili.Control:New {
		name = playerID,
		x = 0,
		bottom = 0,
		right = 0,
		height = height,
		padding = {0, 0, 0, 0},
		parent = parent
	}

	offset = offset + 1
	userControls.imStatus = Chili.Image:New {
		name = "imStatus",
		x = offset,
		y = offsetY,
		width = options.text_height.value + 4,
		height = options.text_height.value + 3,
		parent = userControls.mainControl,
		keepAspect = true,
		file = "LuaUI/Images/Misc/no_cons.png",
		--OnClick = OnStatusClick(playerID),
	}
	if playerID then
		--Spring.Echo("initializing player " .. playerID)
		local _, active, spectator, _, _, ping = Spring.GetPlayerInfo(playerID)
		UpdateStatusImage(userControls, not active, IsPlayerAFK(playerID), hasCons, (ping > PING_TIMEOUT))
	else
		UpdateStatusImage(userControls, false, false, hasCons, false)
	end
	offset = offset + options.text_height.value + 5
	if userControls.entryData.country then
		userControls.imCountry = Chili.Image:New {
			name = "imCountry",
			x = offset,
			y = offsetY,
			width = options.text_height.value + 8,
			height = options.text_height.value + 2,
			parent = userControls.mainControl,
			keepAspect = true,
			file = userControls.entryData.country,
		}
	end
	offset = offset + options.text_height.value + 4

	offset = offset + 6
	if userControls.entryData.rank then
		userControls.imRank = Chili.Image:New {
			name = "imRank",
			x = offset,
			y = offsetY,
			width = options.text_height.value + 4,
			height = options.text_height.value + 3,
			parent = userControls.mainControl,
			keepAspect = true,
			file = userControls.entryData.rank,
		}
	end
	offset = offset + options.text_height.value + 5
	
	offset = offset + 1
	if userControls.entryData.clan then
		userControls.imClan = Chili.Image:New {
			name = "imClan",
			x = offset,
			y = offsetY,
			width = options.text_height.value + 4,
			height = options.text_height.value + 3,
			parent = userControls.mainControl,
			keepAspect = true,
			file = userControls.entryData.clan,
		}
	end
	offset = offset + options.text_height.value + 5
	
	offset = offset + 13
	userControls.textAllyTeam = Chili.Label:New {
		name = "textAllyTeam",
		x = offset,
		y = offsetY + 1,
		right = 0,
		bottom = 3,
		parent = userControls.mainControl,
		caption = userControls.entryData.allyTeamID + 1,
		textColor = userControls.entryData.allyTeamColor,
		fontsize = options.text_height.value,
		fontShadow = true,
		autosize = false,
	}
	offset = offset + options.text_height.value + 3
	
	offset = offset + 2
	userControls.textName = Chili.Label:New {
		name = "textName",
		x = offset,
		y = offsetY + 1,
		right = 0,
		bottom = 3,
		align = "left",
		parent = userControls.mainControl,
		caption = GetName(userControls.entryData.name, nil, userControls.entryData),
		textColor = GetPlayerTeamColor(userControls.entryData.teamID, userControls.entryData.isDead),
		fontsize = options.text_height.value,
		fontShadow = true,
		autosize = false,
	}
	userControls.textName:SetCaption(GetName(userControls.entryData.name, userControls.textName.font, userControls.entryData))
	offset = offset + MAX_NAME_LENGTH

	offset = offset + 1
	userControls.btnShare = Chili.Button:New {
		name = "btnShare",
		x = offset + 2,
		y = offsetY + 2,
		width = options.text_height.value - 1,
		height = options.text_height.value - 1,
		parent = userControls.mainControl,
		caption = "",
		tooltip = "Double click to share the units you have selected to this player.",
		padding ={0,0,0,0},
		OnDblClick = {function(self)
			ShareUnits(userControls.entryData.name, userControls.entryData.teamID)
		end, },
	}
	Chili.Image:New {
		name = "imShare",
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		parent = userControls.btnShare,
		keepAspect = true,
		file = IMAGE_SHARE,
	}
	userControls.btnShare:SetVisibility((userControls.entryData.isMyAlly and (userControls.entryData.teamID ~= myTeamID) and true) or false)
	offset = offset + options.text_height.value + 1

	offset = offset + 1
	if userControls.entryData.cpuBucket then
		userControls.imCpu = Chili.Image:New {
			name = "imCpu",
			x = offset,
			y = offsetY,
			width = options.text_height.value + 3,
			height = options.text_height.value + 3,
			parent = userControls.mainControl,
			keepAspect = true,
			file = IMAGE_CPU,
			color = pingCpuColors[userControls.entryData.cpuBucket],
		}
		function userControls.imCpu:HitTest(x,y) return self end
	end
	offset = offset + options.text_height.value
	
	offset = offset + 1
	if userControls.entryData.pingBucket then
		userControls.imPing = Chili.Image:New {
			name = "imPing",
			x = offset,
			y = offsetY,
			width = options.text_height.value + 3,
			height = options.text_height.value + 3,
			parent = userControls.mainControl,
			keepAspect = true,
			file = IMAGE_PING,
			color = pingCpuColors[userControls.entryData.pingBucket],
		}
		function userControls.imPing:HitTest(x,y) return self end
	end
	offset = offset + options.text_height.value

	UpdateEntryData(userControls.entryData, userControls, false, true)

	return userControls
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local playerlistWindow
local listControls = {}
local playersByPlayerID = {}
local teamByTeamID = {}

local function Compare(ac, bc)
	local a, b = ac.entryData, bc.entryData
	
	if not a.isMe ~= not b.isMe then
		return b.isMe
	end
	
	if not a.isMyTeam ~= not b.isMyTeam then
		return b.isMyTeam
	end
	
	if not a.isMyAlly ~= not b.isMyAlly then
		return b.isMyAlly
	end
	
	if a.allyTeamID ~= b.allyTeamID then
		return a.allyTeamID > b.allyTeamID
	end
	
	if not a.isAiTeam ~= not b.isAiTeam then
		return a.isAiTeam
	end
	
	if a.teamID ~= b.teamID then
		return a.teamID > b.teamID
	end
	
	if a.playerID then
		return (not b.playerID) or a.playerID > b.playerID
	end
	return (not b.playerID)
end

local function SortEntries()
	if not playerlistWindow then
		return
	end
	
	table.sort(listControls, Compare)
	
	local toTop = options.alignToTop.value
	local offset = 0
	for i = 1, #listControls do
		if toTop then
			listControls[i].mainControl._relativeBounds.top = offset
			listControls[i].mainControl._relativeBounds.bottom = nil
		else
			listControls[i].mainControl._relativeBounds.top = nil
			listControls[i].mainControl._relativeBounds.bottom = offset
		end
		listControls[i].mainControl:UpdateClientArea(false)
		
		offset = offset + options.text_height.value + 2
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function UpdateTeam(teamID)
	local controls = teamByTeamID[teamID]
	if not controls then
		return
	end
	
	local toSort = UpdateEntryData(controls.entryData, controls)
	if toSort then
		SortEntries()
	end
end

local function ForceUpdateTeam(teamID)
	local controls = teamByTeamID[teamID]
	if not controls then
		return
	end
	
	local toSort = UpdateEntryData(controls.entryData, controls, false, true)
	if toSort then
		SortEntries()
	end
end

local function UpdatePlayer(playerID, forceUpdate)
	local controls = playersByPlayerID[playerID]
	if not controls then
		return
	end
	
	local toSort = UpdateEntryData(controls.entryData, controls, nil, forceUpdate or false)
	if toSort then
		SortEntries()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function InitializePlayerlist()
	--Spring.Echo("Initialize Player list")
	if playerlistWindow then
		playerlistWindow:Dispose()
		playerlistWindow = nil
	end
	
	if listControls then
		for i = 1, #listControls do
			if listControls[i].mainControl then
				listControls[i].mainControl:Dispose()
			end
		end
		listControls = {}
		playersByPlayerID = {}
		teamByTeamID = {}
	end
	local screenWidth, screenHeight = Spring.GetViewGeometry()
	local windowWidth = MAX_NAME_LENGTH + 13*(options.text_height.value or 13)

	--// WINDOW
	playerlistWindow = Chili.Window:New{
		backgroundColor = {0, 0, 0, 0},
		color = {0, 0, 0, 0},
		parent = Chili.Screen0,
		dockable = true,
		name = "Player List", -- NB: this exact string is needed for HUD preset playerlist handling
		padding = {0, 0, 0, 0},
		x = screenWidth - windowWidth,
		y = math.floor(screenHeight/10),
		width = windowWidth,
		minWidth = windowWidth,
		clientHeight = math.floor(screenHeight/2),
		minHeight = 100,
		draggable = false,
		resizable = false,
		tweakDraggable = true,
		tweakResizable = true,
		minimizable = false,
	}
	
	local gaiaTeamID = Spring.GetGaiaTeamID
	local teamList = Spring.GetTeamList()
	for i = 1, #teamList do
		local teamID = teamList[i]
		if teamID ~= gaiaTeamID then
			local _, leaderID, isDead, isAiTeam, _, allyTeamID = Spring.GetTeamInfo(teamID, false)
			--Spring.Echo(teamID .. " LeaderID: " .. tostring(leaderID))
			--Spring.Echo("isAI: " .. tostring(isAiTeam))
			local skirmishAIID, name, hostingPlayerID = Spring.GetAIInfo(teamID)
			--pring.Echo("AIInfo: " .. tostring(skirmishAIID) .. ", " .. tostring(name) .. ", " .. tostring(hostingPlayerID))
			local isActuallyAI = Spring.GetTeamRulesParam(teamID, "initAI")
			--Spring.Echo("TeamID " .. teamID .. " is init AI: " .. tostring(isActuallyAI))
			if leaderID < 0 then
				leaderID = Spring.GetTeamRulesParam(teamID, "initLeaderID") or leaderID
				--Spring.Echo("Leader ID is now: " .. leaderID)
			end
			
			if leaderID >= 0 then
				if isAiTeam or isActuallyAI then
					--Spring.Echo("teamID " .. teamID .. " is AI!")
					leaderID = nil
					--[[local host = Spring.GetTeamRulesParam(teamID, "initAIHost", host, PUBLIC_VISIBLE)
					local name = Spring.GetTeamRulesParam(teamID, "initAIName", name, PUBLIC_VISIBLE)
					local short = Spring.GetTeamRulesParam(teamID, "initAIShort", shortName, PUBLIC_VISIBLE)
					local version = Spring.GetTeamRulesParam(teamID, "initAIVersion", version, PUBLIC_VISIBLE)
					Spring.Echo("Hosted by " .. host .. "\nName: " .. tostring(name) .. "\nshort: " .. tostring(short))]]
				end
				local hasCons = WG.ConTracker.GetTeamConStatus(teamID)
				--Spring.Echo("Calling GetUserControls: " .. tostring(leaderID) .. ", " .. teamID .. ", " .. allyTeamID)
				local controls = GetUserControls(leaderID, teamID, allyTeamID, isAiTeam, isDead, playerlistWindow, hasCons)
				--Spring.Echo("Listed controls for " .. teamID)
				listControls[#listControls + 1] = controls
				teamByTeamID[teamID] = controls
				if leaderID then
					playersByPlayerID[leaderID] = controls
				end
			end
		end
	end
	
	SortEntries()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

options_path = 'Settings/HUD Panels/Player List'
options_order = {'text_height', 'backgroundOpacity', 'alignToTop'}
options = {
	text_height = {
		name = 'Font Size (10-18)',
		type = 'number',
		value = 13,
		min = 10, max = 18, step = 1,
		OnChange = InitializePlayerlist,
		advanced = true
	},
	backgroundOpacity = {
		name = "Background opacity",
		type = "number",
		value = 0, min = 0, max = 1, step = 0.01,
		OnChange = function(self)
			playerlistWindow.backgroundColor = {1,1,1,self.value}
			playerlistWindow.borderColor = {1,1,1,self.value}
			playerlistWindow:Invalidate()
		end,
	},
	alignToTop = {
		name = "Align to top",
		type = 'bool',
		value = false,
		desc = "Align list entries to top (i.e. don't push to bottom)",
		OnChange = SortEntries,
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local lastUpdate = 0
function widget:Update(dt)
	lastUpdate = lastUpdate + dt
	if lastUpdate < UPDATE_PERIOD then
		return
	end
	lastUpdate = 0
	
	for i = 1, #listControls do
		UpdateEntryData(listControls[i].entryData, listControls[i], true)
	end
end

function widget:PlayerChanged(playerID)
	if playerID == myPlayerID then
		local updateAll = false
		
		if mySpectating ~= Spring.GetSpectatingState() then
			updateAll = true
			mySpectating = Spring.GetSpectatingState()
		end
		if myAllyTeamID ~= (not mySpectating and Spring.GetMyAllyTeamID()) then
			updateAll = true
			myAllyTeamID = (not mySpectating and Spring.GetMyAllyTeamID())
		end
		if myTeamID ~= (not mySpectating and Spring.GetMyTeamID()) then
			updateAll = true
			myTeamID = (not mySpectating and Spring.GetMyTeamID())
		end
		
		if changedTeam then
			local toSort = false
			for i = 1, #listControls do
				toSort = UpdateEntryData(listControls[i].entryData, listControls[i], false, true) or toSort
			end
			
			if toSort then
				SortEntries()
			end
			return
		end
	end
	
	UpdatePlayer(playerID)
end

function widget:PlayerAdded(playerID)
	UpdatePlayer(playerID)
end

function widget:PlayerRemoved(playerID)
	UpdatePlayer(playerID)
end

function widget:TeamDied(teamID)
	UpdateTeam(teamID)
end

function widget:TeamChanged(teamID)
	UpdateTeam(teamID)
end

function TeamColorsUpdated(teamID)
	if teamID == -1 then 
		Spring.Echo("crudeplayerlist: Successfully subscribed!")
		return 
	end -- test event.
	--Spring.Echo("TeamColorsUpdated::" .. teamID)
	ForceUpdateTeam(teamID)
end

function TeamConUpdate(teamID, hasCons)
	if teamID == -1 then -- test
		Spring.Echo("crudeplayerlist: team con status subscribed!")
	else
		--Spring.Echo("TeamConUpdate: " .. teamID .. ", " .. tostring(hasCons))
		local playerList = Spring.GetPlayerList(teamID)
		--Spring.Echo("crudeplayerlist: team con status updating")
		for p = 1, #playerList do
			local playerID = playerList[p]
			UpdatePlayer(playerID, true)
		end
		UpdateTeam(teamID)
	end
end


function widget:Initialize()
	Chili = WG.Chili
	if (not Chili) then
		widgetHandler:RemoveWidget()
		return
	end
	InitializePlayerlist()
	Spring.SendCommands("info 0")
	WG.ConTracker.Subscribe(TeamConUpdate, "crudeplayerlistv2")
	WG.TeamColorSubscribe(TeamColorsUpdated, "crudeplayerlistv2")
end

function widget:Shutdown()
	--Spring.SendCommands("info 1")
	WG.RemoveColorListener("crudeplayerlistv2")
	WG.ConTracker.Unsubscribe(TeamConUpdate, "crudeplayerlistv2")
end
