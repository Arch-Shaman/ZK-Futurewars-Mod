function widget:GetInfo()
	return {
		name      = "Scenario Unit Dumper",
		desc      = "Dumps all units into a file for scenario creation.",
		author    = "Shaman",
		date      = "10 Sept 2022",
		license   = "CC-0",
		layer     = 5,
		enabled   = false,
	}
end

local dumpstring = "return {"

local teamToRoleID = {}

function widget:Initialize()
	local allyTeams = Spring.GetAllyTeamList()
	for a = 1, #allyTeams do
		local rolenum = 1
		local teamlist = Spring.GetTeamList(allyTeams[a])
		for t = 1, #teamlist do
			teamToRoleID[teamlist[t]] = rolenum
			rolenum = rolenum + 1
		end
	end
end

local function TableToString(t, tabcount)
	local str = "{"
	local val
	for k, v in pairs(t) do
		local key
		if tonumber(k) then
			key = "[" .. k .. "]"
		else
			key = k
		end
		if type(v) == "string" then
			val = "[[" .. v .. "]]"
		elseif type(v) ~= "table" then
			val = tostring(v)
		else
			val = TableToString(v, tabcount + 1)
		end
		str = str .. "\n" .. string.rep("\t", tabcount + 1) .. key .. " = " .. val .. ","
	end
	if str ~= "{" then
		str = str .. "\n" .. string.rep("\t", tabcount) .. "}"
	else
		str = str .. "}"
	end
	return str
end

local function GetUnitFacing(unitID)
	return math.floor(((Spring.GetUnitHeading(unitID) or 0)/16384 + 0.5)%4)
end

function widget:KeyPress(v)
	if v == 268 then
		Spring.Echo("Dumping units.")
		local allUnits = Spring.GetAllUnits()
		local file = io.open("luaui\\dumps\\scenarios\\" .. Game.mapName .. ".lua","w")
		for i = 1, #allUnits do
			local unitID = allUnits[i]
			local x, y, z = Spring.GetUnitPosition(unitID)
			local rx, ry, rz = Spring.GetUnitRotation(unitID)
			local heading = GetUnitFacing(unitID)
			local hp, maxhp, empdmg, captureprogress, buildprogress = Spring.GetUnitHealth(unitID)
			local unitTable = {
				unitDef = UnitDefs[Spring.GetUnitDefID(unitID)].name,
				positionState = {position = {x, y, z}, facing = heading, rotation = {rx, ry, rz}},
				healthState = {hp = hp, maxhp = maxhp, paralysis = empdmg, captureprogress = captureprogress, buildprogress = buildprogress},
				role = teamToRoleID[Spring.GetUnitTeam(unitID)],
				allyID = Spring.GetUnitAllyTeam(unitID),
				queue = Spring.GetCommandQueue(unitID, 99),
				states = Spring.GetUnitStates(unitID),
			}
			dumpstring = dumpstring .. "\n\t[" .. i .. "] = " .. TableToString(unitTable, 2)
		end
		dumpstring = dumpstring .. "\n}\n"
		file:write(dumpstring)
		file:flush()
		file:close()
		dumpstring = "return {"
		Spring.Echo("game_message:Unitlist dumped.")
	end
end
