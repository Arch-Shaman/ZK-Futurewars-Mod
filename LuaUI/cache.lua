-- Poisoning for Spring.* functions (caching, filtering, providing back compat)

if not Spring.IsUserWriting then
	Spring.IsUserWriting = function()
		return false
	end
end

-- *etTeamColor
local teamColor = {}

-- GetVisibleUnits
local visibleUnits = {}

-- original functions
local GetTeamColor = Spring.GetTeamColor
local SetTeamColor = Spring.SetTeamColor
local GetVisibleUnits = Spring.GetVisibleUnits
local MarkerAddPoint = Spring.MarkerAddPoint
local GetPlayerInfo  = Spring.GetPlayerInfo

-- Block line drawing widgets
--local MarkerAddLine = Spring.MarkerAddLine
--function Spring.MarkerAddLine(a,b,c,d,e,f,g)
--	MarkerAddLine(a,b,c,d,e,f,true)
--end

-- Cutscenes apply F5
local IsGUIHidden = Spring.IsGUIHidden
function Spring.IsGUIHidden()
	return IsGUIHidden() or (WG.Cutscene and WG.Cutscene.IsInCutscene())
end

function Spring.GetTeamColor(teamid)
  if not teamColor[teamid] then
    teamColor[teamid] = { GetTeamColor(teamid) }
  end
  return unpack(teamColor[teamid])
end

function Spring.MarkerAddPoint(x, y, z, t, b)
	MarkerAddPoint(x,y,z,t,true)
end

function Spring.SetTeamColor(teamid, r, g, b)
  -- set and cache
  SetTeamColor(teamid, r, g, b)
  teamColor[teamid] = { GetTeamColor(teamid) }
end

local spSetUnitNoSelect = Spring.SetUnitNoSelect
function Spring.SetUnitNoSelect(unitID, value)
	return
end

local countryOverrides = {
	["??"] = "Unknown", -- Needed because files can't be named "??"
	["an"] = "nl", -- Does not exist anymore. Now is BQ, but this is for safety purposes.
	["bq"] = "nl", -- The rest of these are just pointers to remade flags to save space / download
	["bv"] = "no", -- NO saves 18kb.
	["hm"] = "au",
	["mf"] = "fr",
	["sj"] = "no",
	["sh"] = "gb",
	["um"] = "us",
}

local function InjectBadges(str, badge)
	local b = ""
	if type(badge):lower() == "table" then
		for i = 1, #badge do
			b = b .. badge[i] .. ","
		end
	else
		b = badge .. ","
	end
	return b .. str
end

local customParamsCache = {}
local fwDevs = {
	["Shaman"] = true,
	["LeojEspino"] = true,
	["Stuff"] = true,
}

function Spring.GetPlayerInfo(playerID, getOpts)
	if getOpts == nil then getOpts = true end
	if playerID == nil then return nil end
	local playerName, active, spectator, teamID, allyTeamID, pingTime, cpuUsage, country, rank, hasSkirmishAIsInTeam, customkeys, desynced
	if getOpts then
		playerName, active, spectator, teamID, allyTeamID, pingTime, cpuUsage, country, rank, customkeys, hasSkirmishAIsInTeam, desynced = GetPlayerInfo(playerID, true)
		if customParamsCache[playerID] == nil then
			if fwDevs[playerName] then
				customkeys.badges = customkeys.badges or ""
				customkeys.badges = InjectBadges(customkeys.badges, "fw_dev")
			elseif playerName == "GhostFenixx" then
				customkeys.badges = customkeys.badges or ""
				customkeys.badges = InjectBadges(customkeys.badges, "fw_fenix")
			end
			customParamsCache[playerID] = customkeys
		else
			customkeys = customParamsCache[playerID]
		end
	else
		playerName, active, spectator, teamID, allyTeamID, pingTime, cpuUsage, country, rank, hasSkirmishAIsInTeam, desynced = GetPlayerInfo(playerID, false)
	end
	local override
	if country then
		override = countryOverrides[country] or country
	else
		override = country
	end
	-- Add dev badges --
	if getOpts then
		return playerName, active, spectator, teamID, allyTeamID, pingTime, cpuUsage, override, rank, customkeys, hasSkirmishAIsInTeam, desynced
	else
		return playerName, active, spectator, teamID, allyTeamID, pingTime, cpuUsage, override, rank, hasSkirmishAIsInTeam, desynced
	end
end

local function buildIndex(teamID, radius, Icons)
	--local index = tostring(teamID)..":"..tostring(radius)..":"..tostring(Icons)
	local t = {}
	if teamID then
		t[#t + 1] = teamID
	end
	if radius then
		t[#t + 1] = radius
	end
	-- concat wants a table where all elements are strings or numbers
	if Icons then
		t[#t+1] = 1
	end
	return table.concat(t, ":")
end

-- returns unitTable = { [1] = number unitID, ... }
function Spring.GetVisibleUnits(teamID, radius, Icons)
	local index = buildIndex(teamID, radius, Icons)

	local currentFrame = Spring.GetGameFrame() -- frame is necessary (invalidates visibility; units can die or disappear outta LoS)
	local now = Spring.GetTimer() -- frame is not sufficient (eg. you can move the screen while game is paused)

	local visible = visibleUnits[index]
	if visible then
		local diff = Spring.DiffTimers(now, visible.time)
		if diff < 0.05 and currentFrame == visible.frame then
			return visible.units
		end
	else
		visibleUnits[index] = {}
		visible = visibleUnits[index]
	end

	local ret = GetVisibleUnits(teamID, radius, Icons)
	visible.units = ret
	visible.frame = currentFrame
	visible.time = now

	return ret
end

--Workaround for Spring.SetCameraTarget() not working in Freestyle mode.
local SetCameraTarget = Spring.SetCameraTarget
function Spring.SetCameraTarget(x, y, z, transTime)
	local cs = Spring.GetCameraState()
	if cs.mode == 4 then --if using Freestyle cam, especially when using "camera_cofc.lua"
		--"0.46364757418633" is the default pitch given to FreeStyle camera (the angle between Target->Camera->Ground, tested ingame) and is the only pitch that original "Spring.SetCameraTarget()" is based upon.
		--"cs.py-y" is the camera height.
		--"math.pi/2 + cs.rx" is the current pitch for Freestyle camera (the angle between Target->Camera->Ground). Freestyle camera can change its pitch by rotating in rx-axis.
		--The original equation is: "x/y = math.tan(rad)" which is solved for "x"
		local ori_zDist = math.tan(0.46364757418633) * (cs.py - y) --the ground distance (at z-axis) between default FreeStyle camera and the target. We know this is only for z-axis from our test.
		local xzDist = math.tan(math.pi / 2 + cs.rx) * (cs.py - y) --the ground distance (at xz-plane) between FreeStyle camera and the target.
		local xDist = math.sin(cs.ry) * xzDist ----break down "xzDist" into x and z component.
		local zDist = math.cos(cs.ry) * xzDist
		x = x - xDist --add current FreeStyle camera to x-component
		z = z - ori_zDist - zDist --remove default FreeStyle z-component, then add current Freestyle camera to z-component
	end
	if x and y and z then
		return SetCameraTarget(x, y, z, transTime) --return new results
	end
end
