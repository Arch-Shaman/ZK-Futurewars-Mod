function widget:GetInfo()
	return {
		name      = "Start Position Selector",
		desc      = "Something",
		author    = "Shaman",
		date      = "2008-2010",
		license   = "GNU GPL, v2 or later",
		layer     = -10,
		enabled   = true  --  loaded by default?
	}
end

-- Button: 1 left click
-- Button: 2 middle mouse click
-- Button: 3 right click
-- Button: 4 mouse_4?
-- No idea about other buttons.

local Chili
local window
local Buttons = {}
local Pics = {}

local currentPlayer = Spring.GetMyPlayerID()
local playerlistindex = 0
local index = 1
local maxindex = 1
local myplayerlist = {}
local CommProfiles
local c = 0

local function UpdateTeamInfo()
	local playerlist = Spring.GetPlayerList(Spring.GetMyTeamID())
	myplayerlist = {[1] = Spring.GetMyPlayerID()}
	for p = 1, #playerlist do
		local playerID = playerlist[p]
		if playerID ~= Spring.GetMyPlayerID() then
			myplayerlist[#myplayerlist + 1] = playerID
		end
	end
end

local function UpdateButtons()
	for i = 1, maxindex do
		
	end
end

local function NextPlayer()
	if #Buttons > 0 then
		for i = 1, #Buttons do
			Buttons[i]:Dispose()
		end
	end
	Buttons = {}
	Pics = {}
	playerlistindex = playerlistindex + 1
	if playerlistindex > #myplayerlist then
		playerlistindex = 1
	end
	index = 1
	currentPlayer = myplayerlist[playerlistindex]
	CommProfiles = WG.ModularCommAPI.GetPlayerCommProfiles(currentPlayer)
	maxindex = Spring.SetPlayerRulesParam(currentPlayer, "commander_count")
end

local function BuildMenu()
	window = Chili.Window:New{
		color = {1,1,1,0},
		parent = Chili.Screen0,
		dockable = true,
		dockableSavePositionOnly = true,
		name = "Comm Window",
		classname = "main_window_small_very_flat",
		padding = {0,0,0,0},
		margin = {0,0,0,0},
		right = 0,
		x = "0%",
		y = "30%",
		height = 60,
		clientWidth  = 400,
		clientHeight = 65,
		minHeight = "40%",
		maxHeight = "40%",
		minWidth = 250,
		draggable = true,
		resizable = false,
		tweakDraggable = true,
		tweakResizable = false,
		parentWidgetName = widget:GetInfo().name, --for gui_chili_docking.lua (minimize function)
	}
end

function widget:PlayerChangedTeam(playerID, old, new)
	if playerID == Spring.GetMyPlayerID() then
		UpdateTeamInfo()
	elseif old == Spring.GetMyTeamID() or new == Spring.GetMyTeamID() then
		UpdateTeamInfo()
	end
end

function widget:PlayerResigned(playerID)
	if playerID == Spring.GetMyPlayerID() then
		WidgetHandler:RemoveWidget()
	end
end

function widget:Update()
	c = c + 1
	if c%60 == 0 then
		UpdateButtons()
	end
end

function widget:MousePress(x, y, button)
	Spring.Echo("x: " .. x .. "\ny:" .. y .. "\nbutton:" .. button)
	if button == 1 then
		if #Spring.GetSelectedUnits() == 0 then
			local t, pos = Spring.TraceScreenRay(x, y, true, false, false)
			Spring.Echo(t)
			local px, pz = pos[1], pos[3]
			Spring.Echo("posx: " .. px .. "\nposy: " .. py .. "\nposz: " .. pz)
			--local actualy = Spring.GetGroundHeight(px, pz)
			--Spring.Echo("Actual ground height: " .. actualy)
			if currentPlayer ~= Spring.GetMyPlayerID() then
				Spring.SendLuaRulesMsg("setplayerstartpos" .. index .. ", " .. px .. ", " .. pz)
			else
				Spring.SendLuaRulesMsg("startpos " .. index .. ", " .. px .. ", " .. pz)
			end
			index = index + 1
			if index > maxindex then
				index = 1
			end
		end
	end
	if button == 2 then
		NextPlayer()
		Spring.Echo("game_message: Now setting start positions for " .. Spring.GetPlayerInfo(currentPlayer))
	end
end

function widget:Initialize()
	Chili = WG.Chili
	if Spring.GetSpectatingState() then
		WidgetHandler:RemoveWidget()
	end
	if Spring.GetGameFrame() > 0 then
		WidgetHandler:RemoveWidget()
	end
end


function widget:GameStart()
	WidgetHandler:RemoveWidget()
end

function widget:GameFrame()
	WidgetHandler:RemoveWidget()
end