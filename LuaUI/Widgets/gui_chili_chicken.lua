--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Chili Chicken Panel",
		desc      = "Indian cuisine",
		author    = "quantum, KingRaptor",
		date      = "May 04, 2008",
		license   = "GNU GPL, v2 or later",
		layer     = -9,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (not Spring.GetGameRulesParam("chicken_difficulty")) then
	return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
VFS.Include("LuaRules/Utilities/tobool.lua")

local Spring          = Spring
local gl, GL          = gl, GL
local widgetHandler   = widgetHandler
local math            = math
local table           = table

local panelFont		  = "LuaUI/Fonts/komtxt__.ttf"
local waveFont        = LUAUI_DIRNAME.."Fonts/Skrawl_40"
local panelTexture    = LUAUI_DIRNAME.."Images/panel.tga"

local viewSizeX, viewSizeY = 0,0

local red             = "\255\255\001\001"
local white           = "\255\255\255\255"
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local gameInfo		  = {}
local waveMessage
local waveSpacingY    = 7
local waveY           = 800
local waveSpeed       = 0.2
local waveTime
local alertedHyperevo = false
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- include the unsynced (widget) config data
local file              = LUAUI_DIRNAME .. 'Configs/chickengui_config.lua'
local configs           = VFS.Include(file, nil, VFS.ZIP)
--local difficulties    = configs.difficulties
local roostName         = configs.roostName
local chickenColorSet   = configs.colorSet

local chickenNamesPlural = {}
for chickenName, color in pairs(chickenColorSet) do
	chickenNamesPlural[chickenName] = color .. Spring.Utilities.GetHumanName(UnitDefNames[chickenName]) .. "\008"
end

local eggs = (Spring.GetModOptions().eggs == '1')
local speed = (Spring.GetModOptions().speedchicken == '1')

local hidePanel = Spring.Utilities.tobool(Spring.GetModOptions().chicken_hidepanel)
local noWaveMessages = Spring.Utilities.tobool(Spring.GetModOptions().chicken_nowavemessages)

-- include the synced (gadget) config data
VFS.Include("LuaRules/Configs/chicken_defs.lua", nil, VFS.ZIP)

-- totally broken: claims it changes the data but doesn't!
--[[
for key, value in pairs(widget.difficulties[modes[Spring.GetGameRulesParam("difficulty")] ]) do
		widget.key = value
end
widget.difficulties = nil
]]--

local difficulty = widget.difficulties[modes[Spring.GetGameRulesParam("chicken_difficulty")]]

local rules = {
	"angerTime",
	"queenTime",
	"strength",
	"score",
	"difficulty",
	"hyperevo",
	"waveSchedule",
	"graceSchedule",
	"waveActive",
	"waveNumber",
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Chili
local Button
local Label
local Window
local Panel
local TextBox
local Image
local Progressbar
local Control
local Font

-- elements
local window, labelStack, background
local global_command_button
local label_anger, label_next, label_strength, label_hyperevo, label_score, label_mode

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
fontHandler.UseFont(waveFont)
local waveFontSize   = fontHandler.GetFontSize()

--------------------------------------------------------------------------------
-- utility functions
--------------------------------------------------------------------------------

-- I'm sure there's something to do this automatically but ehhh...
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
	local str = (h..":"..m..":"..s)
	if neg then str = "-"..str end
	return str
end

-- explanation for string.char: http://springrts.com/phpbb/viewtopic.php?f=23&t=24952
local function GetColor(percent)
	percent = math.max(math.min(percent * 100, 100), 0)
	local midpt = (percent > 50)
	local r, g
	if midpt then
		r = 255
		g = math.floor(255*(100-percent)/50)
	else
		r = math.floor(255*percent/50)
		g = 255
	end
	return string.char(255,r,g,0)
end

local function GetColorAggression(value)
	local r,g,b
	if (value<=-1) then
		r = 255
		g = math.max(255 + value*25, 0)
		b = math.max(255 + value*25, 0)
	elseif (value>=1) then
		r = math.max(255 - value*25, 0)
		g = 255
		b = math.max(255 - value*25, 0)
	else
		r=255
		g=255
		b=255
	end
	return string.char(255,r,g,b)
end

-- gets the synced config setting for current difficulty
local function GetDifficultyValue(value)
	return difficulty[value] or widget[value]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function WriteTooltipsOnce()
	label_strength.tooltip = "Each burrow killed decreases hive strength by "..("%.1f"):format((1-GetDifficultyValue('strengthPerBurrow'))*100).."% of the total\n"..
		"Hive strength increases by "..("%.1f"):format(GetDifficultyValue('strengthPerSecond')*60*100).."% per minute"
	label_anger.tooltip = "At 100% anger, the Chicken Queen will spawn and chickens will start attacking nonstop with no breaks"
	label_score.tooltip = "Score multiplier from difficaulty: "..("%.1f"):format(GetDifficultyValue('scoreMult')*100).."%"
end

-- done every second
local function UpdateAnger()
	--Spring.SendMessageToPlayer (Spring.GetLocalPlayerID ( ) ,"game_message: \255\255\255\0 >> \255\255\255\255 UwU Fuck me harder Daddy \255\255\255\0 <<")
	local curTime = gameInfo.angerTime
	
	local angerPercent = (curTime / gameInfo.queenTime)
	local angerString = "Hive Anger : ".. GetColor(angerPercent) ..("%.1f"):format(angerPercent*100).."% \008"
	if (angerPercent < 1) and (not endlessMode) then angerString = angerString .. "("..FormatTime((gameInfo.queenTime - curTime) / 30) .. " left)" end
	
	label_anger:SetCaption(angerString)

	local frame = Spring.GetGameFrame()
	if angerPercent > 1 then
		label_next:SetCaption("The Hive is Angered!")
	elseif frame < 100 then
		label_next:SetCaption("Wave 1 Starts in :"..GetColor(0)..FormatTime(GetDifficultyValue("gracePeriod")-frame/30))
	elseif gameInfo["waveActive"] == 1 then
		local timeUntil = (gameInfo["graceSchedule"]-frame)/30
		label_next:SetCaption("Wave "..gameInfo["waveNumber"].." Ends in : "..GetColor(timeUntil/(GetDifficultyValue("chickenSpawnRate") - GetDifficultyValue("gracePeriod")))..FormatTime(timeUntil))
	else
		local timeUntil = (gameInfo["waveSchedule"]-frame)/30
		label_next:SetCaption("Wave "..(gameInfo["waveNumber"]+1).." Starts in : "..GetColor(1-timeUntil/GetDifficultyValue("gracePeriod"))..FormatTime(timeUntil))
	end

	
	label_score:SetCaption("Score : "..("%.1f"):format(gameInfo["score"]))
end

-- done every 2 seconds
local function UpdateRules()
	for _, rule in pairs(rules) do
		gameInfo[rule] = Spring.GetGameRulesParam("chicken_"..rule) or 0
	end

	-- write info
	label_strength:SetCaption("Hive Strength : "..GetColor(gameInfo["strength"]/2)..("%.1f"):format(gameInfo["strength"]*100).."%")
	
	if gameInfo["hyperevo"] < 1.01 then
		label_hyperevo:SetCaption("Hyperevolution : "..("%.1f"):format((gameInfo["hyperevo"] - 1)*100).."%")
	else
		label_hyperevo:SetCaption("Hyperevolution : \255\255\0\0"..("%.1f"):format((gameInfo["hyperevo"] - 1)*100).."%")
		if not alertedHyperevo then
			alertedHyperevo = true
			waveMessage    = {}
			waveMessage[1] = "The Chickens are Hyperevolving!"
			waveTime = Spring.GetTimer()
		end
	end
	
	local substr = ''
	if eggs and speed then
		substr = " (Spd Eggs)"
	elseif eggs then
		substr = " (Eggs)"
	elseif speed then
		substr = " (Speed)"
	end
	label_mode:SetCaption("Mode: " .. configs.difficulties[gameInfo.difficulty] .. substr)
end

--------------------------------------------------------------------------------
-- wave messages
--------------------------------------------------------------------------------
local function WaveRow(n)
	return n*(waveFontSize+waveSpacingY)
end

local function MakeLine(chicken, n)
	if (n <= 0) then
		return
	end
	local humanName = Spring.Utilities.GetHumanName(UnitDefNames[chicken])
	local color = chickenColorSet[chicken] or ""
	return color..humanName.." x"..n
end

function ChickenEvent(chickenEventArgs)
	if (chickenEventArgs.type == "waveStart") then
		waveMessage    = {}
		waveMessage[1] = "Wave "..chickenEventArgs.waveNumber.." Incoming!"
		waveTime = Spring.GetTimer()
	elseif (chickenEventArgs.type == "waveEnd") then
		waveMessage    = {}
		waveMessage[1] = "Wave "..chickenEventArgs.waveNumber.." Survived..."
		waveTime = Spring.GetTimer()
	elseif (chickenEventArgs.type == "wave") then
		if noWaveMessages then
			return
		end

		waveMessage    = {}
		waveCount      = waveCount + 1
		waveMessage[1] = "Wave "..waveCount
		
		for i, entry in pairs(chickenEventArgs[1]) do
			waveMessage[i+1] = MakeLine(entry[1], entry[2]) -- TODO: Localise
		end
		
		waveTime = Spring.GetTimer()
		
	-- table.foreachi(waveMessage, print)
	-- local t = Spring.GetGameSeconds()
	-- print(string.format("time %d:%d", t/60, t%60))
	-- print""
	elseif (chickenEventArgs.type == "burrowSpawn") then
		UpdateRules()
	elseif (chickenEventArgs.type == "miniQueen") then
		waveMessage    = {}
		waveMessage[1] = "Here be dragons!"
		waveTime = Spring.GetTimer()
	elseif (chickenEventArgs.type == "queen") then
		waveMessage    = {}
		waveMessage[1] = "The Hive is angered!"
		waveTime = Spring.GetTimer()
	elseif (chickenEventArgs.type == "refresh") then
		UpdateRules()
		UpdateAnger()
	end
end

function widget:DrawScreen()
	viewSizeX, viewSizeY = gl.GetViewSizes()
	if (waveMessage)  then
		local t = Spring.GetTimer()
		fontHandler.UseFont(waveFont)
		local waveY = viewSizeY - Spring.DiffTimers(t, waveTime)*waveSpeed*viewSizeY
		if (waveY > 0) then
			for i=1,#waveMessage do
				fontHandler.DrawCentered(waveMessage[i], viewSizeX/2, waveY-WaveRow(i))
			end
		else
			waveMessage = nil
			waveY = viewSizeY
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
	-- setup Chili
	Chili = WG.Chili
	Button = Chili.Button
	Label = Chili.Label
	Checkbox = Chili.Checkbox
	Window = Chili.Window
	Panel = Chili.Panel
	StackPanel = Chili.StackPanel
	TextBox = Chili.TextBox
	Image = Chili.Image
	Progressbar = Chili.Progressbar
	Font = Chili.Font
	Control = Chili.Control
	screen0 = Chili.Screen0
	
	--create main Chili elements
	local labelHeight = 22
	local fontSize = 16
	
	window = Window:New{
		parent = screen0,
		name   = 'chickenpanel';
		color = {0, 0, 0, 0},
		width = 270;
		height = 189;
		right = 0;
		y = 100,
		dockable = true;
		draggable = false,
		resizable = false,
		tweakDraggable = true,
		tweakResizable = false,
		minWidth = MIN_WIDTH,
		minHeight = MIN_HEIGHT,
		padding = {0, 0, 0, 0},
		--itemMargin  = {0, 0, 0, 0},
	}
	
	labelStack = StackPanel:New{
		parent = window,
		resizeItems = false;
		orientation   = "vertical";
		height = 175;
		width =  260;
		x = 20,
		y = 10,
		padding = {0, 0, 0, 0},
		itemMargin  = {0, 0, 0, 0},
	}
	
	background = Image:New{
		width=270;
		height=189;
		y=0;
		x=0;
		keepAspect = false,
		file = panelTexture;
		parent = window;
		disableChildrenHitTest = false,
	}
	
	label_anger = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	label_next = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	label_strength = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	label_hyperevo = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	label_score = Label:New{
		parent = labelStack,
		autosize=false;
		align="left";
		valign="center";
		caption = '';
		height = labelHeight,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	label_mode = Label:New{
		parent = labelStack,
		autosize=false;
		align="center";
		valign="center";
		caption = '',
		height = labelHeight*2,
		width = "100%";
		font = {font = panelFont, size = fontSize, shadow = true, outline = true,},
	}
	
	widgetHandler:RegisterGlobal("ChickenEvent", ChickenEvent)
	UpdateRules()
	WriteTooltipsOnce()
	UpdateAnger()

	-- Activate tooltips for labels, they do not have them in default chili
	function label_anger:HitTest(x,y) return self end
	function label_next:HitTest(x,y) return self end
	function label_strength:HitTest(x,y) return self end
	function label_hyperevo:HitTest(x,y) return self end
	function label_score:HitTest(x,y) return self end
	
	if hidePanel then
		window:Hide()
	end

	if WG.GlobalCommandBar and not hidePanel then
		local function ToggleWindow()
			if window.visible then
				window:Hide()
			else
				window:Show()
			end
		end
		global_command_button = WG.GlobalCommandBar.AddCommand("LuaUI/Images/chicken.png", "Chicken info", ToggleWindow)
	end
end

function widget:Shutdown()
	fontHandler.FreeFont(waveFont)
	widgetHandler:DeregisterGlobal("ChickenEvent")
end

function widget:GameFrame(n)
	if (n%60< 1) then UpdateRules() end
	-- every second for smoother countdown
	if (n%30< 1) then UpdateAnger() end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

