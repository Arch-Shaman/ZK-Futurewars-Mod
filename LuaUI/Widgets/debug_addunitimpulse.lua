function widget:GetInfo()
	return {
		name      = "Debug AddUnitImpulse",
		desc      = "Adds a command to add unit impulse.",
		author    = "Shaman",
		date      = "3/23/2021",
		license   = "CC-0",
		layer     = 0,
		enabled   = false  --  loaded by default?
	}
end

local function ProccessCommand(str)
	local x, y, z
	local i = 1
	-- A "word" is anything between two spaces or the start and the first space. So ProccessCommand("1 2 3 4")
	-- would return 2 3 4 (first 'word' is ignored, only 2nd, 3rd, and 4th count).
	for word in string.gmatch(str, "%S+") do
		if i == 2 then
			x = tonumber(word)
		elseif i == 3 then
			y = tonumber(word) or 0
		elseif i == 4 then
			z = tonumber(word) or 0
			break
		end
		i = i + 1
	end
	return x, y, z
end

function widget:TextCommand(msg)
	--Spring.Echo(msg)
	if msg:find("addunitimpulse") then
		local selection = Spring.GetSelectedUnits()
		local x, y, z = ProccessCommand(msg)
		for i = 1, #selection do
			Spring.SendLuaRulesMsg("addunitimpulse " .. selection[i] .. " " .. x .. " " .. y .. " " .. z)
		end
	end
end
