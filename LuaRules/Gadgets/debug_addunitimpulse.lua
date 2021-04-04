if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name      = "Debug AddUnitImpulse",
		desc      = "Adds a command to add unit impulse.",
		author    = "Shaman",
		date      = "3/23/2021",
		license   = "CC-0",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

local function AddUnitImpulse(unitID, ix, iy, iz)
	Spring.AddUnitImpulse(unitID, ix, iy, iz)
end

local function ProccessCommand(str)
	local unitID, x, y, z
	local i = 1
	-- A "word" is anything between two spaces or the start and the first space. So ProccessCommand("1 2 3 4")
	-- would return 2 3 4 (first 'word' is ignored, only 2nd, 3rd, and 4th count).
	for word in string.gmatch(str, "%S+") do
		if i == 2 then
			unitID = tonumber(word)
		elseif i == 3 then
			x = tonumber(word) or 0
		elseif i == 4 then
			y = tonumber(word) or 0
		elseif i == 5 then
			z = tonumber(word) or 0
			break
		end
		i = i + 1
	end
	if unitID ~= nil then
		AddUnitImpulse(unitID, x, y, z)
	end
end

function gadget:RecvLuaMsg(msg, playerID)
	if Spring.IsCheatingEnabled() and string.find(msg, "addunitimpulse") then
		ProccessCommand(msg)
	end
end
