if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

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

local IterableMap = Spring.Utilities.IterableMap

local config = {} -- stores the config for weapondefs.
local missiles = IterableMap.New()
local targettypes = {}

-- speed ups --
targettypes[string.byte('g')] = 'ground'
targettypes[string.byte('u')] = 'unit'
targettypes["unit"] = string.byte('u')
targettypes["ground"] = string.byte('g')
targettypes[string.byte('p')] = 'projectile'
targettypes[string.byte('f')] = 'feature'
local random = math.random
local rad = math.rad
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local max = math.max
local atan = math.atan
local atan2 = math.atan2
local ceil = math.ceil
local floor = math.floor
local min = math.min

local spGetProjectileVelocity = Spring.GetProjectileVelocity
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
local spGetUnitPosErrorParams = Spring.GetUnitPosErrorParams

local terrainGranularity = 6

-- proccess config --
for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local customParams = wd.customParams -- hold table for referencing
	if tonumber(customParams.cruisealt) ~= nil and tonumber(customParams.cruisedist) ~= nil then -- found it!
		--Spring.Echo("[CruiseMissiles] Adding " .. i .. "(" .. tostring(wd.name) .. ")")
		config[i] = {}
		config[i].altitude = tonumber(customParams.cruisealt)
		config[i].randomizationtype = customParams.cruise_randomizationtype or "?"
		config[i].distance = tonumber(customParams.cruisedist)
		config[i].track = customParams.cruisetracking ~= nil
		config[i].airlaunched = customParams.airlaunched ~= nil
		config[i].droptoalt = customParams.droptoalt ~= nil
		config[i].noascension = customParams.cruise_noascension ~= nil
		config[i].radius = tonumber(customParams.cruiserandomradius)
		config[i].permoffset = customParams.cruise_permoffset ~= nil
		config[i].finaltracking = customParams.cruise_nolock == nil
		config[i].torpedo = wd.type == "TorpedoLauncher"
		config[i].ascensiononly = customParams.ascentonly ~= nil
		config[i].ascendradius = tonumber(customParams.cruise_ascendradius)
		config[i].splittarget = customParams.cruise_torpedosplittarget ~= nil
		config[i].ignoreterrain = customParams.cruise_ignoreterrain ~= nil
		config[i].minterrainheight = tonumber(customParams.cruise_minterrainheight) or config[i].altitude
		config[i].useprediction = customParams.cruise_useprediction ~= nil
		config[i].predicttime = tonumber(customParams.cruise_useprediction) or 15
		--Spring.Echo(tostring(wd.type))
		SetWatchWeapon(i, true)
	elseif customParams.cruisealt ~= nil or customParams.cruisedist ~= nil then
		spEcho("[Cruise Missiles] Bad def " .. WeaponDefs[i].name .. " (Missing Altitude or Distance field)")
	end
end

local function Distance(x1, x2, y1, y2)
	return sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))
end

local function CalculateAngle(x, z, targetx, targetz) -- first set of coords: center, second: point
	--local heading = GetUnitHeading(unitID)
	local angle = atan2(targetz - z, targetx - x )
	return angle -- Used for determining the center of the arc.
end

local function GetFiringPoint(radius, x, z, angle)
	return x + (radius * cos(angle)), z + (radius * sin(angle))
end

local function GetTargetType(num)
	return targettypes[num] or '?'
end

local function GetRandomizedDestination(weaponDefID, x, z)
	local radius = config[weaponDefID].radius
	if radius then
		local distance = (1 - random()^2) * radius
		local heading = rad(random(0, 360))
		local fx = x + (distance * sin(heading))
		local fz = z + (distance * cos(heading))
		return fx, spGetGroundHeight(fx, fz), fz
	end
end

local function GetRandomizedOffset(weaponDefID)
	local radius = config[weaponDefID].radius
	if radius then
		local distance = (1 - random()^2) * radius
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

local function GetMissileDestination(num, allyteam, unguided)
	local missile = IterableMap.Get(missiles, num)
	if not unguided then
		if missile.type == 'ground' then
			return missile.target[1], missile.target[2], missile.target[3]
		else
			local target = missile.target
			if spValidUnitID(target) and (spIsUnitInLos(target, allyteam) and config[missile.configid].track) then
				local x, y, z = spGetUnitPosition(target)
				missile.lastknownposition[1] = x
				missile.lastknownposition[2] = y
				missile.lastknownposition[3] = z
				return x, y, z
			else
				local x, y, z
				if spValidUnitID(target) then
					local ux, uy, uz = spGetUnitPosition(target)
					x, y, z = spGetUnitPosErrorParams(target)
					x, y, z = x + ux, y + uy, z+uz
					if x and y and z then
						missile.lastknownposition[1] = x
						missile.lastknownposition[2] = y
						missile.lastknownposition[3] = z
					end
				else
					x = missile.lastknownposition[1]
					y = missile.lastknownposition[2]
					z = missile.lastknownposition[3]
				end
				return x, y, z
			end
		end
	else
		local currentX, currentY, currentZ = spGetProjectilePosition(num)
		local distance = config[spGetProjectileDefID(num)].distance + 100
		local heading = rad(random(0, 360))
		local fx = currentX + (distance * sin(heading))
		local fz = currentZ + (distance * cos(heading))
		missile.target[1], missile.target[3] = fx, fz
		if math.random() >= 0.7 then
			missile.unguided = false
			local targetY = spGetGroundHeight(fx, fz)
			missile.target[2] = targetY
			return fx, targetY, fz
		else
			missile.target[2] = currentY
			return fx, currentY, fz
		end
	end
end

local function GetMissileCruiseProgress(projectileID)
	local data = IterableMap.Get(missiles, projectileID)
	if data == nil then return nil end
	if data.takeoff then
		return 0
	end
	local x, y, z = GetMissileDestination(projectileID, data.allyteam, data.unguided)
	local projectiledef = data.configid
	local missileconfig = config[projectiledef]
	local mindist = missileconfig.distance
	local cx, cy, cz = spGetProjectilePosition(projectile)
	local distance = Distance(cx, x, cz, z)
	
	local progress = mindist/distance
	if progress > 1 then return 1 end
	return progress
end

local function ProccessOffset(wep, proID) -- send the offset request to the proper area. This way we don't have to update it anywhere else its being used.
	local ox, oz
	local data = IterableMap.Get(missiles, proID)
	if config[wep].randomizationtype == "circular" then
		ox, oz = GetRandomizedOffsetOnCircle(wep)
	else
		ox, oz = GetRandomizedOffset(wep)
	end
	data.offset.x = ox
	data.offset.z = oz
end


local function IsMissileCruiseDone(id) -- other gadgets can look up if the missile is done with its cruise phase.
	--Spring.Echo("IsMissileCruiseDone: Returning: " .. tostring(missiles[id] ~= nil) .. " for " .. id)
	local data = IterableMap.Get(missiles, id)
	return data ~= nil
end

local function ForceUpdate(id, x, y, z)
	local data = IterableMap.Get(missiles, id)
	if data then
		if type(data.target) == "table" then
			data.target[1] = x
			data.target[2] = y
			data.target[3] = z
		end
	end
end	

local function GetTargetPosition(id, allyteam)
	local data = IterableMap.Get(missiles, id)
	if data then
		return GetMissileDestination(id, allyteam)
	else
		return nil
	end
end

local function SetMissileUnguided(id, unitID)
	local data = IterableMap.Get(missiles, id)
	if data then
		data.type = 'ground'
		data.target[1], data.target[2], data.target[3] = GetMissileDestination(id, spGetUnitAllyTeam(unitID), true)
		data.unguided = true
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	local wep = weaponDefID or spGetProjectileDefID(proID) -- needed for bursts.
	local originalTarget
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
				originalTarget = target
				target = last
			end
		end
		if type == "projectile" then
			return -- don't cruise for projectiles
		end
		local allyteam = spGetUnitAllyTeam(proOwnerID)
		local _, py = spGetProjectilePosition(proID)
		py = max(py, ty)
		IterableMap.Add(missiles, proID, {unguided = false, target = target, originaltarget = originalTarget, useprediction = config[wep].useprediction, altitudestayframes = 0, type = type, cruising = config[wep].noascension, takeoff = not config[wep].noascension, lastknownposition = last, configid = wep, allyteam = allyteam, wantedalt = py + config[wep].altitude, updates = 0, offset = {}})
		if config[wep].radius then
			ProccessOffset(wep, proID)
		end
	end
end

local function ForceMissileToCruise(proID, proOwnerID, weaponDefID)
	gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
end


function gadget:ProjectileDestroyed(proID)
	local data = IterableMap.Get(missiles, proID)
	if data then
		data.destroyed = true
	end
end

function gadget:Initialize()
	GG.ForceCruiseUpdate = ForceUpdate
	GG.GetMissileCruising = IsMissileCruiseDone
	GG.GetCruiseTarget = GetTargetPosition
	GG.SetCruiseMissileUnguided = SetMissileUnguided
	GG.ForceMissileToCruise = ForceMissileToCruise
	GG.GetMissileCruiseProgress = GetMissileCruiseProgress
end

function gadget:GameFrame(f)
	for projectile, data in IterableMap.Iterator(missiles) do
		if data.destroyed then
			IterableMap.Remove(missiles, projectile)
		else
			local cx, cy, cz = spGetProjectilePosition(projectile)
			if cx == nil then
				Spring.Echo("[CruiseMissiles] Error: Projectile Position for " .. projectile .. " is nil. Removing.")
				data.destroyed = true
			else
				local x, y, z = GetMissileDestination(projectile, data.allyteam, data.unguided)
				--spEcho("Target: " .. x .. ", " .. y .. ", " .. z)
				--spEcho("Position: " .. cx .. ", " .. cz)
				local projectiledef = data.configid
				local missileconfig = config[projectiledef]
				local wantedalt = data.wantedalt
				local mindist = missileconfig.distance
				local distance = Distance(cx, x, cz, z)
				local terrainheight = missileconfig.minterrainheight
				if data.offset.x then
					x = x + data.offset.x
					z = z + data.offset.z
					y = spGetGroundHeight(x, z)
					if not missileconfig.permoffset and missileconfig.radius and data.updates%15 == 0 then
						ProccessOffset(data.configid, projectile)
					end
				end
				data.updates = data.updates + 1
				if missileconfig.torpedo then
					if cy <= 0 then -- we're not in the water, so don't bother.
						local success
						if not missileconfig.splittarget then
							wantedalt = missileconfig.altitude
						end
						--spEcho("Current Depth: " .. cy .. "(" .. wantedalt .. ")")
						if data.takeoff and (cy > math.min(wantedalt + 40, -5) or cy < wantedalt - 40) then -- we aren't at the correct height yet, but avoid aiming out of water or at ground.
							if missileconfig.ascendradius then
								local targetx, targetz = GetFiringPoint(missileconfig.ascendradius, cx, cz, CalculateAngle(cx, cz, x, z))
								success = spSetProjectileTarget(projectile, targetx, wantedalt, targetz) -- we don't particularly care if it's UW or surface based, we just want to get within 10 elmos of the target depth
								--spEcho("target: " .. targetx .. ", " .. targetz)
							else
								success = spSetProjectileTarget(projectile, cx, wantedalt, cz) -- we don't particularly care if it's UW or surface based, we just want to get within 10 elmos of the target depth
							end
						elseif data.takeoff then
							--spEcho("Torpedo is now cruising")
							data.takeoff = false
							data.cruising = true
						end
						if data.cruising then
							--spEcho("Distance to target: " .. distance .. " / " .. mindist)
							if distance < mindist then -- final approach
								if missileconfig.finaltracking and data.type == "unit" then
									--Spring.Echo("Set target to unit and releasing!")
									success = spSetProjectileTarget(projectile, data.target, targettypes.unit)
									IterableMap.Remove(missiles, projectile)
								else
									success = spSetProjectileTarget(projectile, x, y, z)
									IterableMap.Remove(missiles, projectile)
								end
							else
								success = spSetProjectileTarget(projectile, x, wantedalt, z)
							end
						end
						--spEcho("Successful torpedo target: " .. tostring(success))
					end
				else
					local cruiseheight = config[projectiledef].altitude
					local originalgroundheight = max(spGetGroundHeight(cx, cz), 0)
					local wantedheight = originalgroundheight + cruiseheight
					--spEcho("Projectile ID: " .. projectile .. "\nAlt: " .. cy .. " / " .. wantedalt .. "\nCruising: " .. tostring(data.cruising) .. "\nAscending: " .. tostring(data.takeoff) .. "\nTargetCoords: " .. x .. ", " .. y .. ", " .. z .. "\nDistance: " .. distance .. "/" .. mindist)
					if data.takeoff then -- begin ascent phase
						if missileconfig.ascendradius and missileconfig.ascendradius > 0 then
							local targetx, targetz = GetFiringPoint(missileconfig.ascendradius, cx, cz, CalculateAngle(cx, cz, x, z))
							--Spring.Echo("Aiming for " .. targetx .. "," .. targetz)
							spSetProjectileTarget(projectile, targetx, spGetGroundHeight(targetx, targetz) + cruiseheight, targetz)
						else
							if not missileconfig.droptoalt then
								spSetProjectileTarget(projectile, cx, originalgroundheight + cruiseheight, cz)
							else
								spSetProjectileTarget(projectile, cx, cruiseheight, cz)
							end
						end
						--spEcho("Taking off: " .. cy .. " / " .. wantedheight)
					end
					if data.takeoff and ((cy >= wantedheight - 40 and not missileconfig.airlaunched and not missileconfig.droptoalt) or (cy <= wantedheight + 20 and missileconfig.airlaunched and not missileconfig.droptoalt) or (cy <= wantedheight and missileconfig.droptoalt)) then -- end ascent
						data.takeoff = false
						data.cruising = true
						--spEcho("No longer taking off")
					end
					if data.cruising then -- cruise phase
						local vx, _, vz = spGetProjectileVelocity(projectile)
						local v = sqrt((vx * vx) + (vz * vz))
						if data.useprediction and not missileconfig.track then
							data.useprediction = false
							if data.originaltarget and spValidUnitID(data.originaltarget) then
								local targetx, targety, targetz = spGetUnitPosition(data.originaltarget)
								if not targetx then
									targetx, targety, targetz = data.target[1], data.target[2], data.target[3]
								end
								local tvx, tvy, tvz = Spring.GetUnitVelocity(data.originaltarget)
								local errorx, errory, errorz = spGetUnitPosErrorParams(data.originaltarget)
								targetx = targetx + errorx
								targety = targety + errory
								targetz = targetz + errorz
								local d = sqrt(((targetx - cx)^2) + ((targetz - cz)^2))
								local t = math.min(math.ceil(d/v), missileconfig.predicttime) -- time it takes to get to the location
								data.target[1] = targetx + (tvx * t)
								data.target[2] = targety
								data.target[3] = targetz + (tvz * t) 
								x, z = data.target[1], data.target[3]
								data.lastknownposition = data.target
							end
						end
						local ty = data.wantedalt
						local angle = CalculateAngle(cx, cz, x, z)
						--spEcho("V: " .. v)
						if not missileconfig.ignoreterrain and v > 0 then
							local eta = distance / v -- time it will take us to get to the final destination
							if eta >= 6 and distance > v * 4 then
								local looksteps = min(ceil((v * 4) / terrainGranularity) + 1, 20)
								local groundheight = originalgroundheight + 10
								local d = 0
								for i = 1, looksteps do
									local lx, lv = GetFiringPoint(i * terrainGranularity, cx, cz, angle)
									local gy = max(spGetGroundHeight(lx, lv), 0)
									if gy > groundheight and gy + terrainheight > data.wantedalt then
										groundheight = gy
										d = i * terrainGranularity
									end
								end
								local t = d / v -- time it takes us to get there.
								if t > 0 and t <= eta then
									wantedheight = groundheight + terrainheight
									local dy = wantedheight - cy
									local wantedangle = atan2(dy, t)
									_, ty = GetFiringPoint(eta, 0, cy, wantedangle) -- reframe the problem as a function of time. We want the height change over time (we don't care about positions)
									ty = ty + wantedheight
									--spEcho("TerrainCheck:\nGround level: " .. groundheight .. "\nCruise Height: " .. wantedheight .. "\nWanted: " .. ty)
									data.wantedalt = wantedheight
									data.altitudestayframes = floor(t)
								else
									if data.altitudestayframes > 0 then
										data.altitudestayframes = data.altitudestayframes - 1
										local dy = data.wantedalt - cy
										if dy > 0 and data.altitudestayframes > 0 then
											local wantedangle = atan2(dy, data.altitudestayframes)
											_, ty = GetFiringPoint(eta, 0, cy, wantedangle)
											ty = ty + data.wantedalt
										else
											ty = cy
										end
										--spEcho("HoldTerrain: " .. ty)
									else
										local wantedheight = originalgroundheight + cruiseheight
										local dy = wantedheight - cy
										local wantedangle = atan2(dy, eta)
										if dy < 0 then
											_, ty = GetFiringPoint(eta, 0, cy, wantedangle)
											--spEcho("TY: " .. ty)
											ty = wantedheight - ty
										else
											ty = cy
										end
										data.wantedalt = wantedheight
									end
								end
							end
						end
						if distance <= mindist or (missileconfig.ascensiononly and data.cruising) then -- end of cruise phase
							data.cruising = false
							if missileconfig.track and missileconfig.finaltracking and data.type == "unit" and spValidUnitID(data.target) then
								spSetProjectileTarget(projectile, data.target, targettypes.unit)
							else
								spSetProjectileTarget(projectile, x, y, z)
							end
							IterableMap.Remove(missiles, projectile)
						else
							--spEcho("Setting target to: " .. x, ty, z)
							spSetProjectileTarget(projectile, x, ty, z)
						end
					end
				end
			end
		end
	end
end
