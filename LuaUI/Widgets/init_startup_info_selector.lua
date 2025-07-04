local versionNumber = "1.337"
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name	= "Startup Info and Selector",
		desc	= "[v" .. string.format("%s", versionNumber ) .. "] Shows important information and options on startup.",
		author	= "SirMaverick",
		date	= "2009,2010",
		license	= "GNU GPL, v2 or later",
		layer	= 0,
		enabled	= true
	}
end

function CheckForSpec()
	if (Spring.GetSpectatingState() or Spring.IsReplay()) and (not Spring.IsCheatingEnabled()) then
		widgetHandler:RemoveWidget()
		return true
	end
end

include("Widgets/COFCTools/ExportUtilities.lua")
VFS.Include("LuaRules/Utilities/tobool.lua")
local GetRawBoxes = VFS.Include("LuaUI/Headers/startbox_utilities.lua")
local moduleDefs, emptyModules, chassisDefs, upgradeUtilities, chassisDefByBaseDef, moduleDefNames, chassisDefNames = VFS.Include("LuaRules/Configs/dynamic_comm_defs.lua")
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--[[
-- Features:
_ Show a windows at game start with pictures to choose commander type.
]]--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local spGetGameRulesParam = Spring.GetGameRulesParam
local coop = false

local Chili
local Window
local ScrollPanel
local Grid
local Label
local screen0
local Image
local Button
local openButton

local vsx, vsy = Spring.GetViewGeometry()
local modoptions = Spring.GetModOptions() --used in LuaUI\Configs\startup_info_selector.lua for planetwars
local campaignBattleID = modoptions.singleplayercampaignbattleid
local fixedStartPos = modoptions.fixedstartpos
local selectorShown = false
local mainWindow
local scroll
local grid
local trainerCheckbox
local showModulesCheckbox
local buttonData = {}
local buttonLabels = {}
local trainerLabels = {}
local closeButton
local actionShow = "showstartupinfoselector"
local optionData

local noComm = false
local wantClose = false

local WINDOW_WIDTH = 720
local WINDOW_HEIGHT = 480
local BUTTON_WIDTH = 128
local BUTTON_HEIGHT = 128

if (vsx < 1024 or vsy < 768) then
	--shrinker
	WINDOW_WIDTH = vsx*(WINDOW_WIDTH/1024)
	WINDOW_HEIGHT = vsy*(WINDOW_HEIGHT/768)
	BUTTON_WIDTH = vsx*(BUTTON_WIDTH/1024)
	BUTTON_HEIGHT = vsy*(BUTTON_HEIGHT/768)
end


local commTips = {
	["assault"] = "Not initialized!",
	["recon"] = "Not initialized!",
	["riot"] = "Not initialized!",
	["strike"] = "Not initialized!",
	["support"] = "Not initialized!",
	["campaign"] = "Not initialized!",
}

local localization = {
	["level"]   = "Level",
	["modules"] = "Modules",
	["close_menu"] = "CLOSE",
	["commander_selector_title"] = "COMMANDER SELECTOR",
	["commander_selector_module_tooltips"] = "Module tooltips",
	["commander_selector_sitelink"] = "",
	["commander_selector_open"] = "",
	["commander_selector_hide_default"] = "",
}

--local wantLabelUpdate = false
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- wait for next screenframe so Grid can resize its elements first	-- doesn't actually work

local colorWeapon = "\255\255\32\32"
local colorConversion = "\255\255\96\0"
local colorWeaponMod = "\255\255\0\255"
local colorModule = "\255\128\128\255"

local function GetTranslatedName(name)
	local lowerName = string.lower(name)
	if lowerName == "engineer" then
		name = WG.Translate("interface", "support")
	elseif lowerName == "guardian" then
		name = WG.Translate("interface", "assault")
	elseif commTips[lowerName] then
		name = WG.Translate("interface", lowerName)
	end
	return name
end

local function FetchTooltip(profileID, commanderName)
	local commData = WG.ModularCommAPI.GetCommProfileInfo(profileID)
	commanderName = GetTranslatedName(commanderName)
	local str = WG.Translate("interface", "select_commander", {name = commanderName}) or "Select " .. commanderName
	str = str .. "\n\n"
	local level = WG.Translate("interface", "level")
	local modules = WG.Translate("interface", "modules")
	--Spring.Echo("Fetching tooltip for " .. profileID .. " [ " .. commanderName .. "]")
	for i=1,#commData.modules do
		str = str .. "\n\255\255\255\000" .. string.upper(level) .. " " .. (i + 1) .. " " .. string.upper(modules) .. ":\255\255\255\255"	-- TODO calculate metal cost
		for j, modulename in pairs(commData.modules[i]) do
			if moduleDefNames[modulename] then
				local moduleDef = moduleDefs[moduleDefNames[modulename]]
				local substr = WG.Translate("interface", modulename .. "_name")
				
				-- assign color
				if (modulename):find("commweapon_") then
					substr = colorWeapon..substr
				elseif (modulename):find("conversion_") then
					substr = colorConversion..substr
				elseif (modulename):find("weaponmod_") then
					substr = colorWeaponMod..substr
				else
					substr = colorModule..substr
				end
				str = str.."\n\t\t"..substr.."\008"
			end
		end
	end
	return str
end

local function ToggleTrainerButtons(bool)
	for i=1,#buttonData do
		if buttonData[i].trainer and (#buttonData > 4) then
			if bool then
				grid:AddChild(buttonData[i].control)
			else
				grid:RemoveChild(buttonData[i].control)
			end
		end
	end
end

local function RebuildTooltips(bool)
	for i = 1, #buttonData do
		buttonData[i].tooltip = FetchTooltip(buttonData[i].profileID, buttonData[i].name)
		local commTip = WG.Translate("interface", "select_" .. buttonData[i].chassis)
		buttonData[i].control.tooltip = (bool and buttonData[i].tooltip .. "\n\n\n" or "") .. (commTip or "")
		local name = GetTranslatedName(buttonData[i].name)
		buttonData[i].label:SetCaption(name)
		buttonData[i].control:Invalidate()
		buttonData[i].label:Invalidate()
	end
end

local function ToggleModuleTooltip(bool)
	for i = 1, #buttonData do
		if buttonData[i].tooltip then
			buttonData[i].control.tooltip = ((bool and (buttonData[i].tooltip .. "\n\n\n")) or "") .. (commTips[buttonData[i].chassis] or "")
			buttonData[i].control:Invalidate()
		end
	end
end

options_path = 'Settings/HUD Panels/Commander Selector'
options = {
	hideTrainers = {
		name = 'Hide default commanders',
		desc = 'You can customise your commanders for use in multiplayer on the Zero-K site: https://zero-k.info',
		-- use the below after Chobby replaces site for customisation
		-- desc = 'You can customize your commanders before the game, in the main menu.',
		type = 'bool',
		value = false,
		noHotkey = true,
		OnChange = function(self)
			if trainerCheckbox then
				trainerCheckbox.checked = self.value
				trainerCheckbox.state.checked = self.value
				trainerCheckbox:Invalidate()
			end
			ToggleTrainerButtons(not self.value)
		end
	},
	showModules = {
		name = 'Module tooltips',
		type = 'bool',
		value = false,
		noHotkey = true,
		OnChange = function(self)
			if showModulesCheckbox then
				showModulesCheckbox.checked = self.value
				showModulesCheckbox.state.checked = self.value
				showModulesCheckbox:Invalidate()
			end
			ToggleModuleTooltip(self.value)
		end
	},
	cameraZoom = {
		name = 'Zoom camera to start position',
		type = 'bool',
		value = true,
		noHotkey = true,
	},
	cameraZoomDistance = {
		name = 'Start position zoom distance',
		desc = "Distance that the start position zoom zooms the camera to.",
		type = 'number',
		value = 1100,
		min = 400, max = 3000, step = 50,
		noHotkey = true,
	},
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function OnLocaleChanged()
	for chassis, _ in pairs(commTips) do -- DO NOT use this for the initial setup!
		commTips[chassis] = WG.Translate("interface", "select_" .. chassis)
	end
	if closeButton then
		closeButton.caption = WG.Translate("interface", "close_menu")
		closeButton:Invalidate()
		openButton.tooltip = WG.Translate("interface", "commander_selector_open")
		openButton:Invalidate()
		options.showModules.name = WG.Translate("interface", "commander_selector_module_tooltips") -- will this even work?
		options.hideTrainers.name = WG.Translate("interface", "commander_selector_hide_default")
		options.hideTrainers.desc =  WG.Translate("interface", "commander_selector_sitelink")
		trainerCheckbox.tooltip = WG.Translate("interface", "commander_selector_sitelink")
		trainerCheckbox.caption = WG.Translate("interface", "commander_selector_hide_default")
		trainerCheckbox:Invalidate()
		showModulesCheckbox.caption = WG.Translate("interface", "commander_selector_module_tooltips")
		showModulesCheckbox:Invalidate()
		RebuildTooltips(options.showModules.value)
		mainWindow.caption = WG.Translate("interface", "commander_selector_title")
		mainWindow:Invalidate()
	end
	if openButton then
		openButton.tooltip = WG.Translate("interface", "commander_selector_open")
	end
end

local function PlaySound(filename, ...)
	local path = filename..".WAV"
	if (VFS.FileExists(path)) then
		Spring.PlaySoundFile(path, ...)
	else
		Spring.Echo("<Startup Info Selector>: Error - file "..path.." doesn't exist.")
	end
end

function widget:ViewResize(viewSizeX, viewSizeY)
  vsx = viewSizeX
  vsy = viewSizeY
end

local function GetStartZoomBounds()
	if fixedStartPos then
		local teamID = Spring.GetMyTeamID()
		local teamInfo = teamID and select(7, Spring.GetTeamInfo(teamID))
		local x, z = tonumber(teamInfo.start_x), tonumber(teamInfo.start_z)
		if not x then
			x, _, z = Spring.GetTeamStartPosition(teamID)
		end
		return x, z, x, z, 0, options.cameraZoomDistance.value, 0
	end

	local minX, minZ, maxX, maxZ, maxY = Game.mapSizeX, Game.mapSizeZ, 0, 0, 0

	local myBoxID = Spring.GetTeamRulesParam(Spring.GetMyTeamID(), "start_box_id")
	if not myBoxID then
		return minX, minZ, maxX, maxZ, maxY
	end

	local rawBoxes = GetRawBoxes()
	if not rawBoxes then
		return minX, minZ, maxX, maxZ, maxY
	end

	local myBox = rawBoxes[myBoxID]
	if not myBox then
		return minX, minZ, maxX, maxZ, maxY
	end

	local polygons = myBox.boxes
	if not polygons then
		return minX, minZ, maxX, maxZ, maxY
	end

	for i = 1, #polygons do
		local vertices = polygons[i]
		for j = 1, #vertices do
			local vertex = vertices[j]
			minX = math.min(minX, vertex[1])
			minZ = math.min(minZ, vertex[2])
			maxX = math.max(maxX, vertex[1])
			maxZ = math.max(maxZ, vertex[2])
			maxY = math.max(maxY, Spring.GetGroundHeight(vertex[1], vertex[2]))
		end
	end

	return minX, minZ, maxX, maxZ, maxY
end

local function RemoveSideButton()
	if not buttonWindow then
		return
	end

	screen0:RemoveChild(buttonWindow)
	buttonWindow:Dispose()
	buttonWindow = nil
	widgetHandler:RemoveAction(actionShow)
end

function WG.ZoomToStart()
	cameraAlreadyMoved = true
	local minX, minZ, maxX, maxZ, maxY, height, smoothness = GetStartZoomBounds()
	SetCameraTargetBox(minX, minZ, maxX, maxZ, 1000, maxY, smoothness or 0.67, true, height)
	if WG.DelaySmoothCam then
		WG.DelaySmoothCam((smoothness or 0.67) + 0.2)
	end
end

local cameraAlreadyMoved = false
function Close(permanently, wantMoveCamera)
	if mainWindow then
		mainWindow:Dispose()
	end

	local moveCamera = wantMoveCamera and not cameraAlreadyMoved and not Spring.GetSpectatingState()
	if moveCamera then
		WG.ZoomToStart()
	end

	if permanently then
		RemoveSideButton()
	end
end

local function CreateWindow()
	if mainWindow then
		mainWindow:Dispose()
	end

	local numColumns = math.floor(WINDOW_WIDTH/BUTTON_WIDTH)
	local numRows = math.ceil(#optionData/numColumns)

	mainWindow = Window:New{
		resizable = false,
		draggable = false,
		clientWidth  = WINDOW_WIDTH,
		clientHeight = WINDOW_HEIGHT,
		x = math.floor((vsx - WINDOW_WIDTH)/2),
		y = math.floor((vsy - WINDOW_HEIGHT)/2),
		classname = "main_window",
		parent = screen0,
		caption = WG.Translate("interface", "commander_selector_title"),
	}
	--scroll = ScrollPanel:New{
	--	parent = mainWindow,
	--	horizontalScrollbar = false,
	--	bottom = 36,
	--	x = 2,
	--	y = 12,
	--	right = 2,
	--}
	grid = Grid:New{
		parent = mainWindow,
		autosize = false,
		resizeItems = true,
		x=0, right=0,
		y=3, bottom=38,
		centerItems = false,
	}
	-- add posters
	local i = 0
	for index, option in ipairs(optionData) do
		i = i + 1
		local hideButton = options.hideTrainers.value and option.trainer and (#optionData > 4)
		local commTip = WG.Translate("interface", "select_" .. option.chassis) or "???"
		local tooltip = ((options.showModules.value and (FetchTooltip(option.commProfile, option.name) .. "\n\n\n")) or "") .. commTip
		local button = Button:New {
			parent = (not hideButton) and grid or nil,
			caption = "",
			valign = "bottom",
			tooltip = tooltip, --added comm name under cursor on tooltip too, like for posters
			width = BUTTON_WIDTH,
			height = BUTTON_HEIGHT,
			padding = {5,5,5,5},
			OnClick = {function()
				Spring.SendLuaRulesMsg("customcomm:"..option.commProfile)
				Spring.SendLuaUIMsg("selectedcomm:" .. option.name .. "," .. option.chassis, "a")
				--Spring.Echo("Sent: " .. option.name .. ", " .. option.chassis)
				Close(false, true)
			end},
		}
		local name = option.name
		name = GetTranslatedName(name)
		local label = Label:New{
			parent = button,
			x = 0, right = 0,
			bottom = 4,
			caption = name,
			align = "center",
			autosize = false,
			font = {size = 14},
		}
		
		buttonData[i] = {
			control = button,
			trainer = option.trainer,
			tooltip = option.tooltip,
			chassis = option.chassis,
			image = option.image,
			profileID = option.commProfile,
			name = option.name,
			label = label,
		}
		
		local image = Image:New{
			parent = button,
			file = option.image,--lookup Configs/startup_info_selector.lua to get optiondata
			tooltip = option.tooltip,
			x = 2,
			y = 2,
			right = 2,
			bottom = 12,
		}
		--if option.trainer then
		--	local trainerLabel = Label:New{
		--		parent = image,
		--		x = 0, right = 0,
		--		y = "50%",
		--		caption = "TRAINER",
		--		align = "center",
		--		autosize = false,
		--		font = {color = {1,0.2,0.2,1}, size=16, outline=true, outlineColor={1,1,1,0.8}},
		--	}
		--	trainerLabels[i] = trainerLabel
		--end
	end
	local cbWidth = WINDOW_WIDTH*0.4
	closeButton = Button:New{
		parent = mainWindow,
		caption = WG.Translate("interface", "close_menu"),
		width = cbWidth,
		x = WINDOW_WIDTH*0.5 + (WINDOW_WIDTH*0.5 - cbWidth)/2,
		height = 30,
		bottom = 5,
		OnClick = {function() Close(false, false) end}
	}
	if #optionData > 4 then
		trainerCheckbox = Chili.Checkbox:New{
			parent = mainWindow,
			x = 16,
			bottom = 25,
			width = 200,
			boxalign = "left",
			caption = options.hideTrainers.name,
			tooltip = options.hideTrainers.desc,
			checked = options.hideTrainers.value,
			OnChange = { function(self)
				-- this is called *before* the 'checked' value is swapped, hence negation everywhere
				if options.hideTrainers.epic_reference then
					options.hideTrainers.epic_reference.checked = not self.checked
					options.hideTrainers.epic_reference.state.checked = not self.checked
					options.hideTrainers.epic_reference:Invalidate()
				end
				options.hideTrainers.value = not self.checked
				ToggleTrainerButtons(self.checked)
			end },
		}
	end
	showModulesCheckbox = Chili.Checkbox:New{
		parent = mainWindow,
		x = 16,
		bottom = 5,
		width = 200,
		boxalign = "left",
		caption = options.showModules.name,
		tooltip = options.showModules.desc,
		checked = options.showModules.value,
		OnChange = { function(self)
			-- this is called *before* the 'checked' value is swapped, hence negation everywhere
			if options.showModules.epic_reference then
				options.showModules.epic_reference.checked = not self.checked
				options.showModules.epic_reference.state.checked = not self.checked
				options.showModules.epic_reference:Invalidate()
			end
			options.showModules.value = not self.checked
			ToggleModuleTooltip(not self.checked)
		end },
	}
	grid:Invalidate()
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:Initialize()
	if Spring.GetGameRulesParam("totalSaveGameFrame") or not (WG.Chili) then
		widgetHandler:RemoveWidget()
		return
	end
	CheckForSpec()
	
	optionData = include("Configs/startup_info_selector.lua")

	-- chili setup
	Chili = WG.Chili
	Window = Chili.Window
	ScrollPanel = Chili.ScrollPanel
	Grid = Chili.Grid
	Label = Chili.Label
	screen0 = Chili.Screen0
	Image = Chili.Image
	Button = Chili.Button
	
	-- FIXME: because this code runs before gadget:GameLoad(), the selector window pops up
	-- even if comm is already selected
	-- nothing serious, just annoying
	local playerID = Spring.GetMyPlayerID()
	local teamID = Spring.GetMyTeamID()
	local teamInfo = teamID and select(7, Spring.GetTeamInfo(teamID))
	if teamInfo and teamInfo.staticcomm then
		wantClose = true
		return
	end
	
	if ((coop and playerID and Spring.GetGameRulesParam("commSpawnedPlayer"..playerID) == 1)
	or (not coop and Spring.GetTeamRulesParam(teamID, "commSpawned") == 1)
	or Spring.GetSpectatingState() or Spring.IsReplay())
	--and (not Spring.IsCheatingEnabled())
	then
		noComm = true -- will prevent window from auto-appearing; can still be brought up from the button
	end

	vsx, vsy = Spring.GetViewGeometry()

	if (not noComm) then
		widgetHandler:AddAction(actionShow, CreateWindow, nil, "t")
		buttonWindow = Window:New{
			resizable = false,
			draggable = false,
			width = 64,
			height = 64,
			right = 0,
			y = 160,
			tweakDraggable = true,
			color = {0, 0, 0, 0},
			padding = {0, 0, 0, 0},
			itemMargin = {0, 0, 0, 0}
		}
		if Spring.GetGameSeconds() <= 0 then
			screen0:AddChild(buttonWindow)
		end
		
		openButton = Button:New{
			parent = buttonWindow,
			caption = '',
			tooltip = "Open comm selection screen",
			width = "100%",
			height = "100%",
			x = 0,
			y = 0,
			classname = "overlay_button",
			OnClick = {function() Spring.SendCommands({"luaui "..actionShow}) end}
		}
		
		buttonImage = Image:New{
			parent = openButton,
			width="100%";
			height="100%";
			x=0;
			y=0;
			file = "LuaUI/Images/startup_info_selector/selecticon.png",
			keepAspect = false,
		}
		CreateWindow()
	end
	WG.InitializeTranslation(OnLocaleChanged, GetInfo().name)
end

-- hide window if game was loaded
local timer = 0
local startPosTimer = 0
function widget:Update(dt) -- TODO: Remove this if possible.
	
	if timer then
		timer = timer + dt
		if timer >= 0.01 then
			if (spGetGameRulesParam("loadedGame") == 1) or wantClose then
				Close(true, wantClose)
			end
			timer = false
		end
	end
	
	if startPosTimer and options.cameraZoom.value and (not campaignBattleID) then
		startPosTimer = startPosTimer + dt
		if Spring.GetGameFrame() <= 0 then
			if startPosTimer > 0.1 then
				local _, active, spec, teamID = Spring.GetPlayerInfo(Spring.GetMyPlayerID(), false)
				if not spec then
					local x, y, z = Spring.GetTeamStartPosition(teamID)
					if not (x == 0 and y == 0 and z == 0) then
						if WG.DelaySmoothCam then
							WG.DelaySmoothCam(1)
						end
						SetCameraTarget(x, y, z, 0.8, nil, options.cameraZoomDistance.value)
						startPosTimer = false
					end
				end
			end
		else
			startPosTimer = false
		end
	end
end

function widget:Shutdown()
	Close(true, false)
end

function widget:GameStart()
	Close(true, false)
	widgetHandler:RemoveCallIn('Update')
end

-- this a pretty retarded place to put this but:
-- Update can fire before the game is actually loaded
-- GameStart is the actual game starting (not loading finished)
-- there is probably some better way
function widget:DrawWorld()
	if (Spring.GetGameFrame() < 1) then
		PlaySound("sounds/reply/advisor/command_console_activated", 1, 'ui')
	end
	widgetHandler:RemoveCallIn('DrawWorld')
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
