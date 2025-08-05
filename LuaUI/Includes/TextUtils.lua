local function GetBestFitFontSizeJapanese(text, width, wantedSize) -- Japanese is beyond stupid with GetTextWidth it seems. Need individual iconograph sizes.
	local array = {}
	for word in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
		array[#array + 1] = word
	end
	local fits = false
	local currentSize = wantedSize
	local length = 0
	while not fits do
		for i = 1, #array do
			length = length + (checkFont:GetTextWidth(text, 1) * currentSize)
		end
		if length > width then
			currentSize = currentSize - 1
			length = 0
		else
			fits = true
		end
	end
	return currentSize
end
	

local function GetBestFitFontSize(text, width, wantedSize)
	local fits = false
	local currentSize = wantedSize
	while not fits do
		--Spring.Echo("CheckSize: " .. checkFont:GetTextWidth(text, 1) * currentSize)
		fits = checkFont:GetTextWidth(text, 1) * currentSize < width - 2
		if not fits then
			currentSize = currentSize - 1
		end
	end
	return currentSize
end

local function GetBestFitForLine(text, width, wantedSize) -- Single line only!
	if WG.IsCurrentLocaleCJK() then
		return GetBestFitFontSizeJapanese(text, width, wantedSize)
	else
		return GetBestFitFontSize(text, width, wantedSize)
	end
end

local function CalculateDescent(fontSize) -- adds padding to text for characters that dip below the baseline. Multiline support.
	if WG.IsCurrentLocaleCJK() then
		return fontSize * 0.15 -- CJK text looks better with some padding to it. ~15% of font size makes text look nice.
	else
		return fontSize * 0.21
	end
end

local function CalculateDimensionsCJK(text, startingFontSize, maxWidth, maxHeight, startingX, startingY) -- CJK languages have multi-byte characters! Needs fancy pattern.
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
		for word in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do -- do not ask what this means.
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
			local str = ""
			for i = 1, #textLines do
				str = str .. textLines[i] .. "\n"
			end
			return str, fontSize, currentY -- returns string with automatic line splits, fontsize, and last y position (for dynamic resizing purposes)
		end
	end
end

local function CalculateDimensions(text, startingFontSize, maxWidth, maxHeight, startingX, startingY) -- Multi-line, box pattern. Non-CJK.
	local textLines = {}
	local currentLine = ""
	local currentX = startingX
	local currentY = startingY
	local fontSize = startingFontSize
	local spaceWidth = gl.GetTextWidth(" ") * fontSize
	local calculating = true
	textLines[1] = ""
	local descentSize = CalculateDescent(startingFontSize)
	local ret = {}
	local lines = {}
	for s in text:gmatch("[^\n]+") do -- preprocess
		Spring.Echo("Lines " .. #lines + 1 .. ": " .. s)
		lines[#lines + 1] = s
	end
	local currentLine = lines[1]
	local lineCount = 1
	while calculating do
		for word in text:gmatch("%S+") do
			local wordWidth = gl.GetTextWidth(word) * fontSize
			local foundInCurrentLine = currentLine:find(word)
			Spring.Echo("Word: " .. word)
			Spring.Echo("Found in current line: " .. tostring(foundInCurrentLine))
			Spring.Echo("Current line number: " .. lineCount)
			if wordWidth + currentX > maxWidth or not foundInCurrentLine then
				if not foundInCurrentLine then
					lineCount = lineCount + 1
					currentLine = lines[lineCount]
				end
				textLines[#textLines + 1] = word .. " "
				currentX = startingX + wordWidth + spaceWidth
				currentY = currentY + (gl.GetTextHeight(textLines[#textLines - 1]) * fontSize) + descentSize
				if currentY > maxHeight then
					if fontSize == 1 then 
						Spring.Echo("Error: Text can never fit in the designated box! Aborting.")
						return
					end
					lineCount = 1
					currentLine = lines[lineCount]
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
			local str = ""
			for i = 1, #textLines do
				str = str .. textLines[i] .. "\n"
			end
			return str, fontSize, currentY -- returns string with automatic line splits, fontsize, and last y position (for dynamic resizing purposes)
		end
	end
end

local function CalculateFontSizeBox(text, startingFontSize, maxWidth, maxHeight, startingX, startingY)
	if WG.IsCurrentLocaleCJK() then
		return CalculateDimensionsCJK(text, startingFontSize, maxWidth, maxHeight, startingX, startingY)
	else
		return CalculateDimensions(text, startingFontSize, maxWidth, maxHeight, startingX, startingY)
	end
end

local function CalculateFontSizeObject(text, startingFontSize, textBox)
	if not textBox then
		Spring.Echo("[CalculateFontSizeObject]: No object supplied. Error. text: '" .. text .. "', startingFontSize: " .. startingFontSize)
		return
	end
	local w = textBox.width
	local h = textBox.height
	local x = textBox.x
	local z = textBox.y
	Spring.Echo("x: " .. tostring(x) .. ", " .. tostring(z) .. ", " .. w .. ", " .. h)
	local str, fontSize, _ = CalculateFontSizeBox(text, startingFontSize, w, h, x, z)
	textBox:SetCaption(str)
	textBox.fontSize = fontSize
	textBox:Invalidate()
end

WG.TextUtils = {
	CalculateFontSizeBox = CalculateFontSizeBox,
	CalculateFontSizeLine = GetBestFitForLine,
	CalculateFontSizeObject = CalculateFontSizeObject,
}
