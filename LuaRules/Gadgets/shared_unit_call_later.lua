if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Call timer",
		desc      = "Shared gadget for calling something later",
		author    = "Stuffphoton",
		date      = "29/12/2023",
		license   = "GNU GPL, v2 or later",
		layer     = 10000,
		enabled   = true,
	}
end

---------------------------------------------------------------------
---------------------------------------------------------------------

local spEcho = Spring.Echo
local spValidUnitID = Spring.ValidUnitID
local spGetGameFrame = Spring.GetGameFrame

local queue = {}

---------------------------------------------------------------------
---------------------------------------------------------------------

function GG.UnitCallLater(unitID, time, func, ...)
	if time <= 0 then
		func(unitID, ...)
	end
	time = spGetGameFrame() + time
	queue[time] = queue[time] or {}
	queue[time][unitID] = {func, {...}}
end

function gadget:GameFrame(f)
	local calls = queue[f]
	if calls then
		for unitID, data in pairs(calls) do
			if spValidUnitID(unitID) then --this is just cheaper than listening to gadget:UnitDestroyed
				data[1](unitID, unpack(data[2]))
			end
		end
	end
end
