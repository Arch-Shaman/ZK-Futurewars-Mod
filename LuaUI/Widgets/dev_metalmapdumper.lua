function widget:GetInfo()
	return {
		name      = "Metal map dumper",
		desc      = "Dump all database",
		author    = "Shaman",
		date      = "January 22, 2019",
		license   = "CC-0",
		layer     = 5,
		enabled   = false,
	}
end

local dumpstring = "return {\n\tspots = {\n"

function widget:Initialize()

	for i = 1, #WG.metalSpots do
		local spot = WG.metalSpots[i]
		dumpstring = dumpstring .. "\t\t{x = " .. spot.x .. ", z = " .. spot.z .. ", metal = " .. spot.metal .. "},\n"
	end
	dumpstring = dumpstring .. "\t}\n}\n"
end

function widget:KeyPress(v)
	if v == 268 then
		Spring.Echo("Dumping")
		local file = io.open("luaui\\dumps\\" .. Game.mapName .. ".lua","w")
		file:write(dumpstring)
		file:flush()
		file:close()
		Spring.Echo("game_message:Metal map dumped.")
	end
end
