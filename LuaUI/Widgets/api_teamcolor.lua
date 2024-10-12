function widget:GetInfo()
	return {
		name      = "Callin for color update",
		desc      = "Tells other widgets to update team colors.",
		author    = "Shaman",
		date      = "09/24/18",
		license   = "PD",
		layer     = -99999,
		enabled   = true,
		alwaysStart = true,
		handler = true,
	}
end

local listeners = {}
local listenerCount = 0

local function addListener(l, widgetName)
	if l and type(l) == "function" then
		local okay, err = pcall(l, -1)
		if okay then
			listeners[widgetName] = l
		else
			Spring.Echo("TeamColor subscribe failed: " .. widgetName .. "\nCause: " .. err)
		end
	else
		Spring.Echo("TeamColor subscribe failed: " .. widgetName .. "\nCause: Not a function.")
	end
end

local function FireColorUpdate(teamID)
	for w,f in pairs(listeners) do
		local okay, err = pcall(f, teamID)
		if not okay then
			Spring.Echo("TeamColor update failed: " .. w .. "\nCause: " .. err)
			listeners[w] = nil
		end
	end
end

local function Unsubscribe(widget_name)
	listeners[widget_name] = nil
end

function widget:Initialize()
	WG.TeamColorSubscribe = addListener
	WG.TeamColorWasUpdated = FireColorUpdate
	WG.RemoveColorListener = Unsubscribe
end
