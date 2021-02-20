--[[
		name      = "Debug Funtion(s)",
		desc      = "Provides funtion(s) useful for debugging",
		author    = "Everybody can contribute!",
		date      = "It could be now",
		license   = "WTFPL",
		enabled   = always,
]]--
local debugfunc = {}


local function printFullTable(printValue, filler)
	local spEcho = Spring.Echo
	if not filler then
		spEcho("TABLE:")
		filler = "\t"
	end
	for key, value in pairs(printValue) do
		if type(value) == "table" then
			spEcho(filler .. "[ " .. key .. " ] = {")
			printFullTable(value, (filler .. "\t"))
			spEcho(filler .. "}")
		else
		spEcho(filler .. "[ " .. key .. " ] = " .. (value or "nil"))
		end
	end
end

debugfunc.printFullTable = printFullTable

return debugfunc
