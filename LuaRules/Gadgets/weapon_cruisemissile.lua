function gadget:GetInfo()
	return {
		name      = "Cruise Missile Trajectory",
		desc      = "Missiles become cruise missiles.",
		author    = "Shaman",
		date      = "11/26/2020",
		license   = "CC-0",
		layer     = 0,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local config = {} -- stores the config for weapondefs.
local missiles = {}
local targettypes = {}

-- speed ups --
targettypes[string.byte('g')] = 'ground'
targettypes[string.byte('u')] = 'unit'
targettypes["unit"] = string.byte('u')
targettypes[string.byte('p')] = 'projectile'
targettypes[string.byte('f')] = 'feature'
local random = math.random
local rad = math.rad
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local max = math.max

local spGetGroundHeight = Spring.GetGroundHeight
local spValidUnitID = Spring.ValidUnitID
local spIsUnitInLos = Spring.IsUnitInLos
local spGetUnitPosition = Spring.GetUnitPosition
local spGetFeaturePosition = GetFeaturePosition
local spSetProjectileTarget = Spring.SetProjectileTarget
local spGetProjectileDefID = Spring.GetProjectileDefID
local spGetProjectileTarget = Spring.GetProjectileTarget
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGetProjectilePosition = Spring.GetProjectilePosition
local SetWatchWeapon = Script.SetWatchWeapon
local spEcho = Spring.Echo

-- proccess config --
for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if tonumber(curRef.cruisealt) ~= nil and tonumber(curRef.cruisedist) ~= nil then -- found it!
		config[i] = {}
		config[i].altitude = tonumber(curRef.cruisealt)
		config[i].randomizationtype = curRef.cruise_randomizationtype or "?"
		config[i].distance = tonumber(curRef.cruisedist)
		config[i].track = curRef.cruisetracking ~= nil
		config[i].airlaunched = curRef.airlaunched ~= nil
		config[i].radius = tonumber(curRef.cruiserandomradius)
		config[i].permoffset = curRef.cruise_permoffset ~= nil
		config[i].finaltracking = curRef.cruise_nolock == nil
		SetWatchWeapon(i, true)
	elseif curRef.cruisealt ~= nil or curRef.cruisedist ~= nil then
		spEcho("[Cruise Missiles] Bad def " .. WeaponDefs[i].name .. " (Missing Altitude or Distance field)")
	end
end

local function Distance(x1, x2, y1, y2)
	return sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))
end


local function GetTargetType(num)
	return targettypes[num] or '?'
end

local function GetRandomizedDestination(weaponDefID, x, z)
	local radius = config[weaponDefID].radius
	if radius then
		local distance = random(0, radius)
		local heading = rad(random(0, 360))
		local fx = x + (distance * sin(heading))
		local fz = z + (distance * cos(heading))
		return fx, spGetGroundHeight(fx, fz), fz
	end
end

local function GetRandomizedOffset(weaponDefID)
	local radius = config[weaponDefID].radius
	if radius then
		local distance = random(0, radius)
		local heading = rad(random(0, 360))
		local fx = (distance * sin(heading))
		local fz = (distance * cos(heading))
		return fx, fz
	end
end

local function GetRandomizedOffsetOnCircle(weaponDefID)
	local radius = config[weaponDefID].radius
	if radius then
		local heading = rad(random(0, 360))
		local fx = (radius * sin(heading))
		local fz = (radius * cos(heading))
		return fx, fz
	end
end

local function GetMissileDestination(num, allyteam)
	local missile = missiles[num]
	if missile.type == 'ground' then
		return missile.target[1], missile.target[2], missile.target[3]
	else
		local target = missile.target
		if spValidUnitID(target) and spIsUnitInLos(target, allyteam) then
			local x, y, z = spGetUnitPosition(target)
			missiles[num].lastknownposition[1] = x
			missiles[num].lastknownposition[2] = y
			missiles[num].lastknownposition[3] = z
			return x, y, z
		else
			return missile.lastknownposition[1], missile.lastknownposition[2], missile.lastknownposition[3]
		end
	end
end

local function ProccessOffset(wep, proID) -- send the offset request to the proper area. This way we don't have to update it anywhere else its being used.
	local ox, oz
	if config[wep].randomizationtype == "circular" then
		ox, oz = GetRandomizedOffsetOnCircle(wep)
	else
		ox, oz = GetRandomizedOffset(wep)
	end
	if missiles[proID].offset then
		missiles[proID].offset.x = ox
		missiles[proID].offset.z = oz
	else
		missiles[proID].offset = {x = ox, z = oz}
	end
end


local function IsMissileCruiseDone(id) -- other gadgets can look up if the missile is done with its cruise phase.
	return not missiles[id] == nil
end

local function ForceUpdate(id, x, y, z)
	if missiles[id] then
		missiles[id].target[1] = x
		missiles[id].target[2] = y
		missiles[id].target[3] = z
	end
end

GG.ForceCruiseUpdate = ForceUpdate
GG.GetMissileCruising = IsMissileCruiseDone

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	local wep = weaponDefID or spGetProjectileDefID(proID) -- needed for bursts.
	if config[wep] then
		local type, target = spGetProjectileTarget(proID)
		local ty = 0
		--spEcho("Type: " .. type)
		type = GetTargetType(type)
		--spEcho("Type: " .. type)
		if type == "feature" then -- don't bother tracking features.
			local x, y, z = spGetFeaturePosition(target)
			ty = y
			target = {x, y, z}
			type = 'ground'
		end
		if type == "unit" then -- nontracking missiles get the initial unit position.
			local x, y, z = spGetUnitPosition(target)
			ty = y
			last = {x, y, z}
			if not config[wep].track then
				type = 'ground'
				target = last
			end
		end
		if type == "projectile" then
			return -- don't cruise for projectiles
		end
		local allyteam = spGetUnitAllyTeam(proOwnerID)
		local _, py = spGetProjectilePosition(proID)
		py = max(py, ty)
		missiles[proID] = {target = target, type = type, cruising = false, takeoff = true, lastknownposition = last, configid = wep, started = false, allyteam = allyteam, wantedalt = py + config[wep].altitude, updates = 0}
		--spEcho("Wanted Altitude: " .. missiles[proID].wantedalt)
		if config[wep].radius then
			ProccessOffset(wep, proID)
		end
	end
end

function gadget:ProjectileDestroyed(proID)
	missiles[proID] = nil
end

function gadget:GameFrame(f)
	if f%2 == 0 then
		for projectile, data in pairs(missiles) do
			local cx, cy, cz = spGetProjectilePosition(projectile)
			local x, y, z = GetMissileDestination(projectile, data.allyteam)
			local projectiledef = data.configid
			local missileconfig = config[projectiledef]
			missiles[projectile].updates = data.updates + 1
			if data.offset then
				x = x + data.offset.x
				z = z + data.offset.z
				y = spGetGroundHeight(x, z)
			end
			if not missileconfig.permoffset and missileconfig.radius and data.updates%15 == 0 then
				ProccessOffset(data.configid, projectile)
			end
			local wantedalt = data.wantedalt
			local mindist = missileconfig.distance
			local distance = Distance(cx, x, cz, z)
			--spEcho("Projectile ID: " .. projectile .. "\nAlt: " .. cy .. " / " .. wantedalt .. "\nCruising: " .. tostring(data.cruising) .. "\nAscending: " .. tostring(data.takeoff) .. "\nStarted: " .. tostring(data.started) .. "\nTargetCoords: " .. x .. ", " .. y .. ", " .. z .. "\nDistance: " .. distance .. "/" .. mindist)
			if data.takeoff then -- begin ascent phase
				spSetProjectileTarget(projectile, cx, wantedalt, cz)
			end
			if data.takeoff and ((cy >= wantedalt - 20 and not missileconfig.airlaunched) or (cy <= wantedalt + 20 and missileconfig.airlaunched)) then -- end ascent
				missiles[projectile].takeoff = false
				missiles[projectile].cruising = true
			end
			if data.cruising then -- cruise phase
				spSetProjectileTarget(projectile, x, cy, z)
				if distance <= mindist then -- end of cruise phase
					data.cruising = false
					if missileconfig.track and missileconfig.finaltracking and data.type == "unit" then
						spSetProjectileTarget(projectile, data.target, targettypes.unit)
					else
						spSetProjectileTarget(projectile, x, y, z)
					end
					missiles[projectile] = nil -- good night.
				end
			end
		end
	end
end
