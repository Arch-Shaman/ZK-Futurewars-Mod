
if addon.InGetInfo then
	return {
		name    = "Main",
		desc    = "displays a simple loadbar",
		author  = "jK",
		date    = "2012,2013",
		license = "GPL2",
		layer   = 0,
		depend  = {"LoadProgress"},
		enabled = true,
	}
end

------------------------------------------
local BAR_SCALING = 0.72
local X_OFFSET = 0.1575
local Y_OFFSET = -0.1

local lastLoadMessage = ""
local lastProgress = {0, 0}
local lang = "en"
local start = os.clock()
math.randomseed(start)
local currenttip = math.random(1, 14)
local tiptext

local font = gl.LoadFont("FreeSansBold.otf", 50, 20, 1.75)

local strings = VFS.Include("LuaIntro/Configs/localization.lua")

local tipTextLines, currentFontSize, tipFinalY, tipFont
local loadingString

Spring.Echo("[NGLS] Picked " .. currenttip)

do
	local config = VFS.Include("LuaUI/config/ZK_data.lua")
	if config then
		Spring.Echo("Localization initialized. Language is " .. config["EPIC Menu"].lang)
		lang = config["EPIC Menu"].lang
	else
		Spring.Echo("[NGLS] No config! Localization defaulting to en.")
	end
	if not strings[lang] then
		Spring.Echo("[NGLS] Warning: No strings for " .. lang .. "! Defaulting to en")
		lang = "en"
	end
	tiptext = strings[lang][currenttip]
	loadingString = strings[lang]["elapsed"]
end

local function IsCJK(lang) -- CJK and thai do not have spaces! Use the alternative method.
	return lang == "ko" or lang == "zh" or lang == "ja" or lang == "tw" or lang == "th"
end

local function CalculateDescent(fontSize) -- adds padding to text for characters that dip below the baseline
	if IsCJK(lang) then
		return fontSize * 0.15 -- CJK text looks better with some padding to it. ~15% of font size makes text look nice.
	else
		return fontSize * 0.21
	end
end

local function CalculateDimensionsCJK(text, startingFontSize, maxWidth, maxHeight, startingX, startingY)
	local textLines = {}
	local currentLine = ""
	local currentX = startingX
	local currentY = startingY
	local fontSize = startingFontSize
	local spaceWidth = gl.GetTextWidth(" ") * fontSize
	local calculating = true
	textLines[1] = ""
	local descentSize = CalculateDescent(startingFontSize)
	text = text:gsub(" ", "")
	while calculating do
		for word in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
			local wordWidth = gl.GetTextWidth(word) * fontSize
			if wordWidth + currentX > maxWidth then
				textLines[#textLines + 1] = word
				currentX = startingX + wordWidth
				currentY = currentY + (gl.GetTextHeight(textLines[#textLines - 1]) * fontSize) + descentSize
				if currentY > maxHeight then
					if fontSize == 1 then 
						Spring.Echo("Error: Text can never fit in the designated box! Aborting.")
						return
					end
					fontSize = fontSize - 1
					currentY = startingY
					currentX = startingX
					spaceWidth = gl.GetTextWidth(" ") * fontSize
					textLines = {[1] = ""}
					break -- stop, reduce font size, try again.
				end
			else
				textLines[#textLines] = textLines[#textLines] .. word
				currentX = currentX + wordWidth
			end
		end
		if currentY + (gl.GetTextHeight(textLines[#textLines]) * fontSize) + 5 > maxHeight then
			fontSize = fontSize - 1
			currentY = startingY
			currentX = startingX
			spaceWidth = gl.GetTextWidth(" ") * fontSize
			descentSize = CalculateDescent(fontSize)
			textLines = {[1] = ""}
		elseif textLines[1] ~= "" then
			currentY = currentY + (gl.GetTextHeight(textLines[#textLines]) * fontSize) + descentSize
			for i = 1, #textLines do
				tipTextLines[i] = textLines[i]
			end
			currentFontSize = fontSize
			tipFinalY = currentY
			local str = ""
			for i = 1, #tipTextLines do
				str = str .. tipTextLines[i] .. "\n"
			end
			Spring.Echo("[NGLS] Got:\n" .. str .. "\n\nFontSize: " .. fontSize .. ", maxY: " .. tipFinalY)
			return
		end
	end
end

local function CalculateDimensions(text, startingFontSize, maxWidth, maxHeight, startingX, startingY)
	local textLines = {}
	local currentLine = ""
	local currentX = startingX
	local currentY = startingY
	local fontSize = startingFontSize
	local spaceWidth = gl.GetTextWidth(" ") * fontSize
	local calculating = true
	textLines[1] = ""
	local descentSize = CalculateDescent(startingFontSize)
	while calculating do
		for word in text:gmatch("%S+") do
			local wordWidth = gl.GetTextWidth(word) * fontSize
			if wordWidth + currentX > maxWidth then
				textLines[#textLines + 1] = word .. " "
				currentX = startingX + wordWidth + spaceWidth
				currentY = currentY + (gl.GetTextHeight(textLines[#textLines - 1]) * fontSize) + descentSize
				if currentY > maxHeight then
					if fontSize == 1 then 
						Spring.Echo("Error: Text can never fit in the designated box! Aborting.")
						return
					end
					fontSize = fontSize - 1
					currentY = startingY
					currentX = startingX
					spaceWidth = gl.GetTextWidth(" ") * fontSize
					textLines = {[1] = ""}
					break -- stop, reduce font size, try again.
				end
			else
				textLines[#textLines] = textLines[#textLines] .. word .. " "
				currentX = currentX + wordWidth + spaceWidth
			end
		end
		if currentY + (gl.GetTextHeight(textLines[#textLines]) * fontSize) + 5 > maxHeight then
			fontSize = fontSize - 1
			currentY = startingY
			currentX = startingX
			spaceWidth = gl.GetTextWidth(" ") * fontSize
			descentSize = CalculateDescent(fontSize)
			textLines = {[1] = ""}
		elseif textLines[1] ~= "" then
			currentY = currentY + (gl.GetTextHeight(textLines[#textLines]) * fontSize) + descentSize
			for i = 1, #textLines do
				tipTextLines[i] = textLines[i]
			end
			currentFontSize = fontSize
			tipFinalY = currentY
			local str = ""
			for i = 1, #tipTextLines do
				str = str .. tipTextLines[i] .. "\n"
			end
			Spring.Echo("[NGLS] Got:\n" .. str .. "\n\nFontSize: " .. fontSize .. ", maxY: " .. tipFinalY)
			return
		end
	end
end

local function UpdateText(text)
	local viewSizeX, viewSizeY = gl.GetViewSizes()
	tipTextLines = {}
	if IsCJK(lang) then
		CalculateDimensionsCJK(text, 40, 0.94 * viewSizeX, 0.69 * viewSizeY, 0.51 * viewSizeX, 0.31 * viewSizeY)
	else
		CalculateDimensions(text, 40, 0.94 * viewSizeX, 0.69 * viewSizeY, 0.51 * viewSizeX, 0.31 * viewSizeY)
	end
	tipFinalY = tipFinalY / viewSizeY + 0.01
	--if tipFont then
		--gl.DeleteFont(tipFont)
	--end
	--tipFont = gl.LoadFont("FreeSansBold.otf", currentFontSize, 10, 1.75)
end

local firstRun = false

local function DrawText()
	local viewSizeX, viewSizeY = gl.GetViewSizes()
	local startX = 0.51 * viewSizeX
	local startY = (tipFinalY - 0.01) * viewSizeY
	gl.Color(1,1,1,1)
	gl.PushMatrix()
	-- Tip background --
	gl.Texture(":n:LuaIntro/Images/panel.png") -- draw around the text
	gl.TexRect(0.5, 0.3, 0.95, tipFinalY)
	gl.Texture(false)
	gl.Scale(1/viewSizeX, 1/viewSizeY, 1)
	local descenderSize = CalculateDescent(currentFontSize)
	local currentY = startY - (gl.GetTextHeight(tipTextLines[1]) * currentFontSize)
	for i = 1, #tipTextLines do
		if firstRun then
			Spring.Echo("[NGLS] " .. tipTextLines[i])
		end
		font:Print(tipTextLines[i], startX, currentY, currentFontSize, "o")
		if firstRun then
			Spring.Echo("[NGLS] Pos: " .. currentY)
		end
		if i < #tipTextLines then
			currentY = currentY - (gl.GetTextHeight(tipTextLines[i + 1]) * currentFontSize) - descenderSize
		end
	end
	--firstRun = false
	gl.PopMatrix()
end

local function UpdateLoadScreen()
	currenttip = math.random(1, 14)
	tiptext = strings[lang][currenttip]
	UpdateText(tiptext)
end

local progressByLastLine = {
	["Parsing Map Information"] = {0, 20},
	["Loading Weapon Definitions"] = {10, 50},
	["Loading LuaRules"] = {40, 80},
	["Loading LuaUI"] = {70, 95},
	["Loading Skirmish AIs"] = {90, 99},
}

for name,val in pairs(progressByLastLine) do
	progressByLastLine[name] = {val[1]*0.01, val[2]*0.01}
end

function addon.LoadProgress(message, replaceLastLine)
	lastLoadMessage = message
	if message:find("Path") then -- pathing has no rigid messages so cant use the table
		lastProgress = {0.3, 0.6}
	end
	lastProgress = progressByLastLine[message] or lastProgress
end

------------------------------------------

UpdateText(strings[lang][currenttip])

local function FormatTime(seconds)
	local minutes = math.floor(seconds/60)
	if minutes < 10 then
		minutes = "0" .. minutes
	end
	local seconds = seconds%60
	if seconds < 10 then
		return minutes .. ":0" .. string.format("%.3f", seconds)
	else
		return minutes .. ":" .. string.format("%.3f", seconds)
	end
end

local lastUpdated = os.clock()

function addon.DrawLoadScreen()
	if os.clock() - lastUpdated > 7 then
		lastUpdated = os.clock()
		UpdateLoadScreen()
	end
	gl.Texture(":n:LuaIntro/Images/tip" .. currenttip .. ".png")
	gl.TexRect(0,0,1,1) -- whole screen.
	gl.Texture(false)
	-- logo --
	gl.Texture(":n:LuaIntro/Images/logo.png")
	gl.TexRect(0.375,0.80,0.625,0.95)
	gl.Texture(false)
	local loadProgress = SG.GetLoadProgress()
	if loadProgress == 0 then
		loadProgress = lastProgress[1]
	else
		loadProgress = math.min(math.max(loadProgress, lastProgress[1]), lastProgress[2])
	end

	local vsx, vsy = gl.GetViewSizes()

	-- draw progressbar
	gl.PushMatrix()
	gl.Scale(BAR_SCALING,BAR_SCALING,1)
	gl.Translate(X_OFFSET,Y_OFFSET,0)
	
	gl.Texture(":n:LuaIntro/Images/barframe.png")
	gl.TexRect(0.188,0.2194,0.810,0.097)
	gl.Texture(false)
	
	gl.BeginEnd(GL.QUADS, function()
		--progress
		gl.Color(0.15,0.91,0.97,0.95)
			gl.Vertex(0.2035, 0.186)
			gl.Vertex(0.2035 + math.max(0, loadProgress-0.01) * 0.595, 0.186)
			gl.Vertex(0.2035 + math.max(0, loadProgress-0.01) * 0.595, 0.17)
			gl.Vertex(0.2035, 0.17)
		gl.Color(0.1,0.73,0.75,0.95)
			gl.Vertex(0.2035 + math.max(0, loadProgress-0.01) * 0.595, 0.186)
			gl.Vertex(0.2035 + math.max(0, loadProgress-0.01) * 0.595, 0.17)
		gl.Color(0.05,0.67,0.69,0)
			gl.Vertex(0.2035 + math.min(1, math.max(0, loadProgress+0.01)) * 0.595, 0.17)
			gl.Vertex(0.2035 + math.min(1, math.max(0, loadProgress+0.01)) * 0.595, 0.186)
	end)

	-- progressbar text
	gl.PushMatrix()
	gl.Scale(1/vsx,1/vsy,1)
	local barTextSize = vsy * (0.05 - 0.015)

	--font:Print(lastLoadMessage, vsx * 0.5, vsy * 0.3, 50, "sc")
	--font:Print(Game.gameName, vsx * 0.5, vsy * 0.95, vsy * 0.07, "sca")
	--font:Print(lastLoadMessage, vsx * 0.2, vsy * 0.14, barTextSize*0.5, "sa")
	font:Print(lastLoadMessage, vsx * 0.5, vsy * 0.125, barTextSize*0.775, "oc")
	local loadPerc = ("%.0f%%"):format(loadProgress * 100)
	local loadTime = FormatTime(os.clock() - start)
	if loadProgress>0 then
		font:Print(loadPerc .. " [ " .. loadingString .. loadTime .. "]", vsx * 0.5, vsy * 0.171, barTextSize*0.65, "oc")
	else
		font:Print("Loading...", vsx * 0.5, vsy * 0.171, barTextSize*0.65, "oc")
	end
	gl.PopMatrix()
	gl.PopMatrix()
	DrawText()
end


function addon.MousePress(...)
	--Spring.Echo(...)
end


function addon.Shutdown()
	Spring.Echo("[NGLS] Finished loading in " .. FormatTime(os.difftime(os.clock(), start)))
	gl.DeleteFont(font)
	--gl.DeleteFont(tipFont)
end
