function gadget:GetInfo()
	return {
		name      = "Cluster Ammunition Spawner",
		desc      = "Spawns subprojectiles",
		author    = "_Shaman",
		date      = "March 12, 2019",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

--[[
	Expected customParams:
	{
		numprojectiles = int, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile = string, -- the weapondef name. we will convert this to an ID in init. REQUIRED. If defined in the unitdef, it will be unitdefname_weapondefname.
		keepmomentum = 1/0, -- should the projectile we spawn keep momentum of the mother projectile? OPTIONAL. Default: True
		spreadradius = num, -- used in clusters. OPTIONAL. Default: 100.
		clusterposition = string,
		clustervelocity = string,
		use2ddist = 1/0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		spawndist = num, -- at what distance should we spawn the projectile(s)? REQUIRED.
		soundspawn = file, -- file to play when we spawn the projectiles. OPTIONAL. Default: None.
		timeoutspawn = 1/0, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
		vradius = num, -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Enter as "min,max" to define custom radius.
		groundimpact = 1/0 -- check the distance between ground and projectile? OPTIONAL.
		proxy = 1/0 -- check for nearby units?
		proxydist = num, -- how far to check for units? Default: spawndist
		timedcharge = num, -- how long after reaching the spawndistance should it spawn projectiles? (in frames) -- NOTE: this disables the default behavior!
	}
]]

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

--Speedups--
local spEcho = Spring.Echo
local spGetGameFrame = Spring.GetGameFrame
local spGetProjectilePosition = Spring.GetProjectilePosition
local spGetProjectileTarget = Spring.GetProjectileTarget
local spGetProjectileTimeToLive = Spring.GetProjectileTimeToLive
local spGetGroundHeight = Spring.GetGroundHeight
local spDeleteProjectile = Spring.DeleteProjectile
local spGetProjectileOwnerID = Spring.GetProjectileOwnerID
local spGetProjectileVelocity = Spring.GetProjectileVelocity
local spGetUnitTeam = Spring.GetUnitTeam
local spPlaySoundFile = Spring.PlaySoundFile
local spSpawnExplosion = Spring.SpawnExplosion
local spSpawnProjectile = Spring.SpawnProjectile
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder
local spGetUnitsInSphere = Spring.GetUnitsInSphere
local spSetProjectileTarget = Spring.SetProjectileTarget
local spSetProjectileIgnoreTrackingError = Spring.SetProjectileIgnoreTrackingError
local spGetProjectileDefID = Spring.GetProjectileDefID
local spAreTeamsAllied = Spring.AreTeamsAllied
local spGetUnitIsCloaked = Spring.GetUnitIsCloaked
local SetWatchWeapon = Script.SetWatchWeapon
local spSetProjectileAlwaysVisible = Spring.SetProjectileAlwaysVisible
local spGetProjectileIsIntercepted = Spring.GetProjectileIsIntercepted
local random = math.random
local sqrt = math.sqrt
local byte = string.byte
local abs = math.abs
local pi = math.pi
local abs = math.abs
local strfind = string.find
local gmatch = string.gmatch

local ground = byte("g")
local unit = byte("u")
local projectile = byte("p")
local feature = byte("f")

--variables--
local config = {} -- projectile configuration data
local projectiles = {} -- stuff we need to act on.
local debug = false
-- functions --
local function distance3d(x1, y1, z1, x2, y2, z2)
	return sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)) + ((z2 - z1) * (z2 - z1)))
end

local function debugEcho(str)
	if debug then
		spEcho(str)
	end
end

spEcho("CAS: Scanning weapondefs")

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if curRef.projectile or curRef.submunition_tablesize then
		spEcho("CAS: Discovered " .. i .. "(" .. wd.name .. ")")
		config[i] = {}
		config[i]["isBomb"] = (wd.type == "AircraftBomb")
		config[i]["launcher"] = (wd.type == "StarburstLauncher")
		config[i]["proxy"] = curRef["proxydist"] ~= nil
		config[i]["proxydistance"] = tonumber(curRef.proxydist) or 0
		config[i]["keepmomentum"] = tonumber(curRef.keepmomentum) or false
		config[i]["timeoutspawn"] = curRef.timeoutspawn ~= nil
		config[i]["use2ddist"] = curRef.use2ddist ~= nil
		config[i]["alwaysvisible"] = curRef.alwaysvisible ~= nil
		config[i]["useheight"] = curRef.useheight ~= nil
		config[i]["spawndist"] = tonumber(curRef.spawndist) or 100
		if curRef.timedcharge then
			config[i]["type"] = "timedcharge"
		else
			config[i]["type"] = "normal
		end
		local tablesize = tonumber(curRef.submunition_tablesize) or 1
		config[i]["subprojectilecount"] = tablesize
		local projectiles = {}
		if tablesize > 1 then
			local nomore = false
			for p = 1, tablesize do
				local projectileref = curRef[p .. "_projectile"]
				if WeaponDefNames[projectileref] and not nomore then
					projectiles[p] = {}
					projectiles[p].projectile = WeaponDefNames[projectileref].id
					projectiles[p].count = tonumber(curRef[p .. "_numprojectiles"]) or 1
					if curRef.vlist then
							projectiles[p]["vlist"] = {}
							local x,y,z
							for w in gmatch(curRef[p .. "_vlist"],"%S+") do -- string should be "x,y,z/x,y,z/x,y,z,/x,y,z/etc
								x,y,z = w:match("([^,]+),([^,]+),([^,]+)")
								projectiles[p]["vlist"][#projectiles[p]["vlist"] + 1] = {tonumber(x),tonumber(y),tonumber(z)}
							end
						end
					end
					if not curRef[p .. "_vradius"] then
						projectiles[p]["veldata"] = {min = {-4.2,-4.2,-4.2}, max = {4.2,4.2,4.2}}
					else
						if strfind(curRef[p .. "_vradius"], ",") then -- projectile velocity offsets
							projectiles[p]["veldata"] = {min = {}, max = {}}
							projectiles[p]["veldata"].min[1],projectiles[p]["veldata"].min[2], projectiles[p]["veldata"].min[3],projectiles[p]["veldata"].max[1],projectiles[p]["veldata"].max[2],projectiles[p]["veldata"].max[3]  = curRef[p .."_vradius"]:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
							for j=1, 3 do
								projectiles[p]["veldata"].min[j] = tonumber(projectiles[p]["veldata"].min[j])
								projectiles[p]["veldata"].max[j] = tonumber(projectiles[p]["veldata"].max[j])
								if projectiles[p].veldata.min[j] > projectiles[p].veldata.max[j] then
									local mi = projectiles[p]["veldata"].min[j]
									local ma = projectiles[p]["veldata"].max[j]
									projectiles[p]["veldata"].min[j] = mi
									projectiles[p]["veldata"].max[j] = ma
									spEcho("[CAS] WARNING: Illegal min,max value for velocity on projectile ID " .. i .. " (" .. wd.name .. ").\n These values have been automatically switched, but you should fix your config!\nValues got:" .. config[i]["veldata"].min[j],config[i]["veldata"].max[j])
								end
							end
						else
							projectiles[p].veldata = {min = {}, max = {}}
							for j=1,3 do
								projectiles[p]["veldata"].min[j] = -abs(tonumber(curRef.vradius)) or -1
								projectiles[p]["veldata"].max[j] = abs(tonumber(curRef.vradius)) or 1
							end
						end
					end
					config[i].projectiles = projectiles
				else
					nomore = true
					config[i] = nil
					spEcho("Bad config for " .. i .. "," ..  p .. "!")
				end
			end
			config[i].projectiles = projectiles
		else
			if WeaponDefNames[curRef.projectile] then
				projectiles[1] = {}
				projectiles[1].projectile = WeaponDefNames[curRef.projectile].id
				projectiles[1].count = tonumber(curRef.numprojectiles) or 1
				if curRef.vlist then
						projectiles[1]["vlist"] = {}
						local x,y,z
						for w in gmatch(curRef.vlist,"%S+") do -- string should be "x,y,z/x,y,z/x,y,z,/x,y,z/etc
							x,y,z = w:match("([^,]+),([^,]+),([^,]+)")
							projectiles[1]["vlist"][#projectiles[1]["vlist"] + 1] = {tonumber(x),tonumber(y),tonumber(z)}
						end
					end
				end
				if not curRef.vradius then
					projectiles[1]["veldata"] = {min = {-4.2,-4.2,-4.2}, max = {4.2,4.2,4.2}}
				else
					if strfind(curRef.vradius,",") then -- projectile velocity offsets
						projectiles[1]["veldata"] = {min = {}, max = {}}
						projectiles[1]["veldata"].min[1],projectiles[1]["veldata"].min[2], projectiles[1]["veldata"].min[3],projectiles[1]["veldata"].max[1],projectiles[1]["veldata"].max[2],projectiles[1]["veldata"].max[3]  = curRef.vradius:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
						for j=1, 3 do
							projectiles[1]["veldata"].min[j] = tonumber(projectiles[1]["veldata"].min[j])
							projectiles[1]["veldata"].max[j] = tonumber(projectiles[1]["veldata"].max[j])
							if projectiles[1].veldata.min[j] > projectiles[1].veldata.max[j] then
								local mi = projectiles[1]["veldata"].min[j]
								local ma = projectiles[1]["veldata"].max[j]
								projectiles[1]["veldata"].min[j] = mi
								projectiles[1]["veldata"].max[j] = ma
								spEcho("[CAS] WARNING: Illegal min,max value for velocity on projectile ID " .. i .. " (" .. wd.name .. ").\n These values have been automatically switched, but you should fix your config!\nValues got:" .. config[i]["veldata"].min[j],config[i]["veldata"].max[j])
							end
						end
					else
						config[i].veldata = {min = {}, max = {}}
						for j=1,3 do
							projectiles[1]["veldata"].min[j] = -abs(tonumber(curRef.vradius))
							projectiles[1]["veldata"].max[j] = abs(tonumber(curRef.vradius))
						end
					end
				end
				config[i].projectiles = projectiles
			else
				config[i] = nil
				spEcho("CAS: Invalid projectile for " .. i)
			end
		end
	end
end
spEcho("CAS: done processing weapondefs")

local function unittest(tab, self, teamID)
	if #tab == 0 or (#tab == 1 and tab[1] == self) then
		return false
	end
	for i=1, #tab do
		if not spAreTeamsAllied(spGetUnitTeam(tab[i]), teamID) and not spGetUnitIsCloaked(tab[i]) then -- condition: enemy unit that isn't cloaked.
			return true
		end
	end
	return false
end

if debug then 
	for name, data in pairs(config) do
		spEcho(name .. " : ON")
		for k,v in pairs(data) do
			spEcho(k .. " = " .. tostring(v))
		end
	end 
end

local function distance2d(x1,y1,x2,y2)
	return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)))
end

local function RegisterSubProjectiles(p, me)
	if config[me] then
		projectiles[p] = {def = me, intercepted = false}
		if config[me]["alwaysvisible"] then
			spSetProjectileAlwaysVisible(p, true)
		end
	end
end

local function SpawnSubProjectiles(id, wd, subid)
	if id == nil then
		return
	end
	local projectileattributes = {pos = {0,0,0}, speed = {0,0,0}, owner = 0, team = 0, ttl= 0,gravity = 0,tracking = false,}
	debugEcho("Fire the submunitions!")
	local x,y,z = spGetProjectilePosition(id)
	local vx,vy,vz = spGetProjectileVelocity(id)
	local ttype,target = spGetProjectileTarget(id)
	local r = config[wd].projectiles[subid]["spreadradius"]
	local vr = config[wd].projectiles[subid]["veldata"]
	local me = config[wd].projectiles[subid].projectile
	local projectilecount = config[wd].projectiles[subid].count
	local step = {0,0,0}
	for i=1, 3 do
		step[i] = (vr.max[i] - vr.min[i])/projectilecount
	end
	debugEcho("Velocity: " ..tostring(config[wd].clusterpos),tostring(config[wd].clustervec))
	debugEcho("step: " .. tostring(step))
	local positioning = config[wd].projectile[subid].clusterpos or "none"
	local vectoring = config[wd].projectile[subid].clustervec or "none"
	-- update projectile attributes --
	projectileattributes["gravity"] = -WeaponDefs[wd].myGravity or -1
	projectileattributes["owner"] = spGetProjectileOwnerID(id)
	projectileattributes["team"] = spGetUnitTeam(projectileattributes["owner"])
	projectileattributes["ttl"] = WeaponDefs[wd].flightTime
	projectileattributes["tracking"] = WeaponDefs[wd].tracks or false
	projectileattributes["pos"][1] = x
	projectileattributes["pos"][2] = y
	projectileattributes["pos"][3] = z
	projectileattributes["speed"][1] = vx
	projectileattributes["speed"][2] = vy
	projectileattributes["speed"][3] = vz
	projectileattributes["tracking"] = tracks
	-- create the explosion --
	spSpawnExplosion(x,y,z,0,0,0,{weaponDef = wd, owner = spGetProjectileOwnerID(id), craterAreaOfEffect = WeaponDefs[wd].craterAreaOfEffect, damageAreaOfEffect = WeaponDefs[wd].damageAreaOfEffect, edgeEffectiveness = WeaponDefs[wd].edgeEffectiveness, explosionSpeed = WeaponDefs[wd].explosionSpeed, impactOnly = WeaponDefs[wd].impactOnly, ignoreOwner = WeaponDefs[wd].noSelfDamage, damageGround = true})
	spPlaySoundFile(WeaponDefs[wd].hitSound[1].name,WeaponDefs[wd].hitSound[1].volume,x,y,z)
	spDeleteProjectile(id)
	-- Create the projectiles --
	for i=1, config[wd]["numprojectiles"] do
		local p
		if strfind(positioning,"random") then
			if strfind(positioning,"x") then
				projectileattributes["pos"][1] = x+random(-r,r)
			end
			if strfind(positioning,"y") then
				projectileattributes["pos"][2] = y+random(-r,r)
			end
			if strfind(positioning,"z") then
				projectileattributes["pos"][3] = z+random(-r,r)
			end
		elseif strfind(vectoring,"random") then
			if strfind(vectoring,"x") then
				projectileattributes["speed"][1] = vx+random(vr.min[1],vr.max[1])
			end
			if strfind(vectoring,"y") then
				projectileattributes["speed"][2] = vy+random(vr.min[2],vr.max[2])
			end
			if strfind(vectoring,"z") then
				projectileattributes["speed"][3] = vz+random(vr.min[3],vr.max[3])
			end
		elseif strfind(vectoring,"even") then
			if strfind(vectoring,"x") then
				projectileattributes["speed"][1] = vx+(vr.min[1]+(step[1]*(i-1)))
			end
			if strfind(vectoring,"y") then
				projectileattributes["speed"][2] = vy+(vr.min[2]+(step[2]*(i-1)))
			end
			if strfind(vectoring,"z") then
				projectileattributes["speed"][3] = vz+(vr.min[3]+(step[3]*(i-1)))
			end
		end
		debugEcho("Projectile Speed: " .. projectileattributes["speed"][1],projectileattributes["speed"][2],projectileattributes["speed"][3])
		p = spSpawnProjectile(me, projectileattributes)
		if ttype ~= ground then
			debugEcho("setting target for " .. p .. " = " .. target)
			spSetProjectileTarget(p, target,ttype)
		else
			spSetProjectileTarget(p, target[1], target[2], target[3])
		end
		RegisterSubProjectiles(p,me)
	end
	projectiles[id].dead = true
end

local function CheckProjectile(id)
	debugEcho("CheckProjectile " .. id)
	local targettype, targetID = spGetProjectileTarget(id)
	if targettype == nil or projectiles[id].dead then
		projectiles[id] = nil
		return
	end
	local wd = projectiles[id].def
	projectiles[id].intercepted = spGetProjectileIsIntercepted(id)
	local isMissile = false -- check for missile status. When the missile times out, the subprojectiles will be spawned if allowed.
	if WeaponDefs[wd]["flightTime"] ~= nil and WeaponDefs[wd].type == "Missile" then
		isMissile = true
	end
	local vx,vy,vz = spGetProjectileVelocity(id)
	if config[wd].launcher and vy > -0.000001 then
		return
	end
	--spEcho("CheckProjectile: " .. id .. ", " .. wd)
	if isMissile and debug then spEcho("ttl: " .. spGetProjectileTimeToLive(id)) end
	if isMissile and config[wd].timeoutspawn and spGetProjectileTimeToLive(id) == 0 then
		SpawnSubProjectiles(id,wd)
	end
	local use3d = (config[wd].use2ddist == 0)
	local distance
	local x2,y2,z2 = spGetProjectilePosition(id)
	local x1,y1,z1
	debugEcho("Attack type: " .. targettype .. "\nTarget: " .. tostring(targetID))
	--debugEcho("Key: 'g' = " .. byte("g") .. "\n'u' = " .. byte("u") .. "\n'f' = " .. byte("f") .. "\n'p' = " .. byte("p"))
	if config[wd].useheight and config[wd].useheight ~= 0 then -- this spawns at the selected height when vy < 0
		debugEcho("Useheight check")
		if y2 - spGetGroundHeight(x2,z2) < config[wd].spawndist and vy < 0 then
			SpawnSubProjectiles(id,wd)
		else
			return
		end
	end
	if targettype == ground then -- this is an undocumented case. Aircraft bombs when targeting ground returns 103 or byte(49).
		x1 = targetID[1]
		y1 = targetID[2]
		z1 = targetID[3]
		debugEcho(x1,y1,z1)
	elseif targettype == 103 then
		debugEcho("103! \n" .. targetID[1],targetID[2],targetID[3])
		x1 = x2
		y1 = spGetGroundHeight(x2,z2)
		z1 = z2
	elseif targettype == unit or targettype == 117 then
		x1,y1,z1 = spGetUnitPosition(targetID)
	elseif targettype == feature then
		x1,y1,z1 = spGetFeaturePosition(targetID)
	elseif targettype == projectile then
		x1,y1,z1 = spGetProjectilePosition(targetID)
	end
	if use3d then
		distance = distance3d(x2,y2,z2,x1,y1,z1)
	else
		distance = distance2d(x2,z2,x1,z1)
	end
	local height = y2 - spGetGroundHeight(x2,z2)
	debugEcho("d: " .. distance .. "\nisBomb: " .. tostring(config[wd]["isBomb"]) .. "\nVelocity: (" .. vx,vy,vz .. ")" .. "\nH: " .. height .. "\nexplosion dist: " .. height - config[wd].spawndist)
	if distance < config[wd].spawndist and not config[wd]["isBomb"] then -- bombs ignore distance and explode based on height. This is due to bomb ground attacks being absolutely fucked in current spring build.
		SpawnSubProjectiles(id,wd)
		debugEcho("distance")
	elseif config[wd]["isBomb"] and height <= config[wd].spawndist then
		SpawnSubProjectiles(id,wd)
		debugEcho("bomb engage")
	elseif config[wd].groundimpact == 1 and vy < -1 and height <= config[wd].spawndist then
		debugEcho("ground impact")
		SpawnSubProjectiles(id,wd)
	elseif config[wd]["proxy"] == 1 then
		local units
		if use3d then
			units = spGetUnitsInSphere(x2,y2,z2,config[wd]["proxydist"])
		else 
			units = spGetUnitsInCylinder(x2,z2,config[wd]["proxydist"])
		end
		if unittest(units, projectiles[id].owner, projectiles[id].teamID) then
			debugEcho("Unit passed unittest. Passed to SpawnSubProjectiles")
			SpawnSubProjectiles(id, wd)
		end
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	debugEcho("ProjectileCreated: " .. tostring(proID, proOwnerID, weaponDefID))
	if weaponDefID == nil then
		weaponDefID = spGetProjectileDefID(proID)
	end
	if config[weaponDefID] and not projectiles[proID] then
		debugEcho("Registered projectile " .. proID)
		projectiles[proID] = {def = weaponDefID, intercepted = false, owner = proOwnerID, teamID = spGetUnitTeam(proOwnerID)}
		if config[weaponDefID]["alwaysvisible"] then
			spSetProjectileAlwaysVisible(proID,true)
		end
	end
end

function gadget:ProjectileDestroyed(proID)
	if projectiles[proID] and not projectiles[proID].intercepted then
		local wd = projectiles[proID].def
		SpawnSubProjectiles(id, wd)
	end
end

function gadget:GameFrame(f)
	for id, _ in pairs(projectiles) do
		CheckProjectile(id)
	end
end
