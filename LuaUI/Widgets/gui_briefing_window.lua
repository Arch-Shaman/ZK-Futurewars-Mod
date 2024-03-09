--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Briefing window",
		desc      = "I took GF's Galaxy Battle Handler and stripped it down for a changelog",
		author    = "Stuffphoton",
		date      = "29 September 2023",
		license   = "GNU GPL, v2 or later",
		layer     = 1000000, -- Do the BringToFront thing after everything else
		enabled   = true,
		alwaysStart = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local spGetDescription = Spring.Utilities.GetDescription
local spGetHumanName = Spring.Utilities.GetHumanName
local spGetModKeyState = Spring.GetModKeyState
local spGetMouseState = Spring.GetMouseState
local spGetUnitDefID = Spring.GetUnitDefID

local max, min = math.max, math.min

local glColor               = gl.Color
local glTexture             = gl.Texture
local glPopMatrix           = gl.PopMatrix
local glPushMatrix          = gl.PushMatrix
local glTranslate           = gl.Translate
local glText                = gl.Text
local glBeginEnd            = gl.BeginEnd
local glTexRect             = gl.TexRect
local glLoadFont            = gl.LoadFont
local glDeleteFont          = gl.DeleteFont
local glRect                = gl.Rect
local glLineWidth           = gl.LineWidth
local glDepthTest           = gl.DepthTest

local osClock               = os.clock

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables/config



local briefing, lastWrittenVersion = VFS.Include("LuaUI/Configs/briefing.lua")
local writeVersion
local showBriefing = true


do
	local configLocation = "luaui\\config\\fw_patchnotes.lua"
	local gameVersion = Game.gameVersion
	local splittedVersion = {}
	gameVersion = string.gsub(gameVersion, "v", "")
	for str in string.gmatch(gameVersion, "%d+") do
		splittedVersion[#splittedVersion + 1] = str
	end
	local lastSeenVersion
	if VFS.FileExists(configLocation) then
		lastSeenVersion = tonumber(VFS.Include(configLocation))
		if lastSeenVersion == nil then lastSeenVersion = "0" end
	else
		lastSeenVersion = "0"
	end
	lastSeenVersion = tonumber(lastSeenversion) or 0
	if splittedVersion[1] and splittedVersion[2] and splittedVersion[3] then
		if splittedVersion[3] and tonumber(splittedVersion[3]) < 10 then
			splittedVersion[3] = "0" .. splittedVersion[3]
		end
		local thisVersion = tonumber(splittedVersion[1] .. splittedVersion[2] .. "." .. splittedVersion[3])
		if lastSeenVersion == 0 then
			showBriefing = true
		else
			local modoptions = Spring.GetModOptions()
			Spring.Echo("[gui_briefing_window]: lastSeenVersion: " .. tostring(lastSeenVersion) .. " < " .. tostring(lastWrittenVersion))
			showBriefing = lastSeenVersion < lastWrittenVersion or (modoptions.commwars and modoptions.commwars == "1") or Spring.GetGameRulesParam("chicken_difficulty") ~= nil
			--Spring.Echo("showBriefing: " .. tostring(showBriefing))
		end
		writeVersion = thisVersion
	end
end


local Chili

local myAllyTeamID = Spring.GetMyAllyTeamID()

local briefingWindow, supportButton, discordButton

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Endgame screen

local screenx, screeny, myFont
local screenCenterX, screenCenterY, wndX1, wndY1, wndX2, wndY2
local victoryTextX, defeatTextX, defeatTextX, lowerTextX
local textY, lineOffset, yCenter, xCut, mouseOver

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

VFS.Include("LuaRules/Utilities/tablefunctions.lua")
local configLocation = "luaui\\config\\fw_patchnotes.lua"


local function GetUnitDefFromIconFilename(filename)
-- 	Spring.Echo('Searching for unit in filename: ' .. filename)
	local name = string.match(filename, "unitpics/(%w+).png")
	if name then
-- 		Spring.Echo('Found unitname: ' .. name)
		local udef = UnitDefNames[name]
		if udef then
			return udef
		end
	end
	return
end

local function GetUnitTooltip(udef)
	return spGetHumanName(udef) .. " - " .. spGetDescription(udef) .. "\n\255\1\255\1" .. WG.Translate("interface", "space_click_show_stats")
end

local function WriteVersionToFile()
	local file = io.open(configLocation, "w")
	file:write("return " .. "\"" .. writeVersion .. "\"\n")
	file:flush()
	file:close()
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Briefing Window

local function GetNewTextHandler(parentControl, paragraphSpacing, imageSize)
	local offset = 0
	
	local holder = Chili.Control:New{
		x = 0,
		y = 0,
		right = 0,
		padding = {0,0,0,0},
		parent = parentControl,
	}
	
	local externalFunctions = {}
	
	function externalFunctions.AddEntry(textBody, fontsize, imageFile)
		local textPos = 4
		if imageFile then
			textPos = imageSize + 10
			
			local image = Chili.Image:New{
				x = 4,
				y = offset,
				width = imageSize,
				height = imageSize,
				keepAspect = true,
				file = imageFile,
				parent = holder
			}
			local udef = GetUnitDefFromIconFilename(imageFile)
			if udef then
				image.tooltip = GetUnitTooltip(udef)
				image.OnClick = {
						function(_, _, _, button)
							local _, _, meta, _ = spGetModKeyState()
							if meta and (button == 1) and WG.MakeStatsWindow then  -- Space+Click - show unit stats
								local x, y = spGetMouseState()
								WG.MakeStatsWindow(udef, x, y)
								return true
							end
							return false
						end
				}
			end
		end
		
		local label = Chili.TextBox:New{
			x = textPos,
			y = offset + 6,
			right = 4,
			height = textSpacing,
			align = "left",
			valign = "top",
			text = textBody,
			fontsize = fontsize,
			parent = holder,
		}
		
		local offsetSize = (#label.physicalLines)*14 + 2
		if imageFile and (offsetSize < imageSize) then
			offsetSize = imageSize
		end
		
		offset = offset + offsetSize + paragraphSpacing
		holder:SetPos(nil, nil, nil, offset - paragraphSpacing/2)
		return offset - paragraphSpacing/2
	end
	
	return externalFunctions
end

local function InitializeBriefingWindow()
	local BRIEF_WIDTH = 720
	local BRIEF_HEIGHT = 680
	
	local SCROLL_POS = 70
	local DEFAULT_SCROLL_SIZE = 320
	
	local externalFunctions = {}
	
	local screenWidth, screenHeight = Spring.GetViewGeometry()
	
	local briefingWindow = Chili.Window:New{
		classname = "main_window",
		name = 'mission_galaxy_brief',
		x = math.floor((screenWidth - BRIEF_WIDTH)/2),
		y = math.max(50, math.floor((screenHeight - BRIEF_HEIGHT)/2.5)),
		width = BRIEF_WIDTH,
		height = BRIEF_HEIGHT,
		minWidth = BRIEF_WIDTH,
		minHeight = BRIEF_HEIGHT,
		dockable = false,
		draggable = false,
		resizable = false,
		tweakDraggable = true,
		tweakResizable = true,
		parent = Chili.Screen0,
	}
	briefingWindow:SetVisibility(false)
	
	Chili.Label:New{
		x = 0,
		y = 12,
		width = briefingWindow.width - (briefingWindow.padding[2] + briefingWindow.padding[4]),
		height = 26,
		fontsize = 44,
		align = "center",
		caption = briefing.modname.." "..briefing.version,
		parent = briefingWindow,
	}
	
	local textScroll = Chili.ScrollPanel:New{
		x = "4%",
		y = SCROLL_POS + 22,
		right = "4%",
		bottom = 80,
		horizontalScrollbar = false,
		parent = briefingWindow,
	}
	local planetTextHandler = GetNewTextHandler(textScroll, 14, 64)

	local entries = briefing.entries
	for i = 1, #entries do
		local entry = entries[i]
		local str = ""
		for n = 1, #entry do
			if entry[n] ~= "" and not entries[i].notranslation then
				str = str .. WG.Translate("briefing", entry[n])
			else
				str = str..entry[n].."\n"
			end
		end
		textSize = planetTextHandler.AddEntry(str, entry.fontsize or 14, entry.image)
	end
	
	--local totalSize = math.min(math.floor(screenHeight*0.90), (BRIEF_HEIGHT + math.max(0, textSize - DEFAULT_SCROLL_SIZE)))
	--local finalPosition = math.max(50, math.floor((screenHeight - totalSize)/2.5))
	--briefingWindow:SetPos(nil, finalPosition, nil, totalSize)
	
	Chili.Button:New{
		x = "20%",
		right = "55%",
		bottom = 10,
		height = 60,
		caption = WG.Translate("interface", "menu_close"),
		fontsize = 26,
		OnClick = {
			function ()
				externalFunctions.Hide()
			end
		},
		parent = briefingWindow
	}
	
	supportButton = Chili.Button:New{
		x = "45%",
		right = "20%",
		bottom = 10,
		height = 30,
		caption = WG.Translate("briefing", "support_fw"),
		fontsize = 20,
		OnClick = {
			function ()
				Spring.SetClipboard ("https://ko-fi.com/fwshaman")
				supportButton:SetCaption(WG.Translate("briefing", "link_copied"))
			end
		},
		parent = briefingWindow
	}
	discordButton = Chili.Button:New{
		x = "45%",
		right = "20%",
		bottom = 40,
		height = 30,
		caption = WG.Translate("briefing", "join_discord"),
		fontsize = 20,
		OnClick = {
			function ()
				Spring.SetClipboard("https://discord.com/invite/GMUnRGUuSy")
				discordButton:SetCaption(WG.Translate("briefing", "link_copied"))
			end
		},
		parent = briefingWindow
	}
	
	function externalFunctions.Show()
		briefingWindow:SetVisibility(true)
		briefingWindow:BringToFront()
	end
	
	function externalFunctions.BringToFrontFix()
		if briefingWindow.visible then
			briefingWindow:BringToFront()
		end
	end
	
	function externalFunctions.Dispose()
		briefingWindow:Dispose()
	end
	
	function externalFunctions.Hide()
		briefingWindow:SetVisibility(false)
		WriteVersionToFile()
		briefingWindow:Dispose()
		widgetHandler:RemoveWidget(self)
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function OnLocaleChanged()
	if briefingWindow then
		briefingWindow:Dispose()
	end
	briefingWindow = InitializeBriefingWindow()
	briefingWindow.Show()
end
	

function widget:Initialize()
	if #briefing.entries == 0 or not showBriefing then
		Spring.Echo("No briefing required.")
		widgetHandler:RemoveWidget(self)
		return
	end
	if Spring.GetGameFrame() < 1 then
		Chili = WG.Chili
		WG.InitializeTranslation(OnLocaleChanged, GetInfo().name)
	else
		widgetHandler:RemoveWidget(self)
	end
end

function widget:GameStart()
	if briefingWindow then
		--briefingWindow.Dispose()
		--WriteVersionToFile()
		--widgetHandler:RemoveWidget(self)
	end
end
