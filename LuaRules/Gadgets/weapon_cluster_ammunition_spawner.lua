if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Cluster Ammunition Spawner",
		desc      = "Spawns subprojectiles",
		author    = "_Shaman, Stuff",
		date      = "March 12, 2019",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

--[[
	Expected customParams:
	{
		# - replace with subprojectile number.
		numprojectiles# = int, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile# = string, -- the weapondef name. we will convert this to an ID in init. REQUIRED. If defined in the unitdef, it will be unitdefname_weapondefname.
		keepmomentum# = 1/0, -- should the projectile we spawn keep momentum of the mother projectile? OPTIONAL. Default: True
		spreadradius# = num, -- used in clusters. OPTIONAL. Default: 100.
		clusterposition# = string,
		clustervelocity# = string,
		vradius# = num, -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Enter as "min,max" to define custom radius.

		use2ddist = 1/0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		spawndist = num, -- at what distance should we spawn the projectile(s)? REQUIRED.
		soundspawn = file, -- file to play when we spawn the projectiles. OPTIONAL. Default: None.
		timeoutspawn = 1/0, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
		vradius = num, -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Enter as "min,max" to define custom radius.
		groundimpact = 2/1/0 -- check the distance between ground and projectile? OPTIONAL.
		proxy = 1/0 -- check for nearby units?
		proxydist = num, -- how far to check for units? Default: spawndist
		timedcharge = num, -- how long after reaching the spawndistance should it spawn projectiles? (in frames) -- NOTE: this disables the default behavior!
		clustercharges = num -- how many times to spawn the cluster projectiles
		clusterdelay = num -- number of frames between each spawn.
		clusterdelaytype = 0/-1 -- { 0 - after being triggered, keep clustering until clustercharge runs out.
									-1 - only cluster if trigger conditions met AND delay has run out.
		dyndamage = string / nil -- if any non-nil value, this weapon will have commander dynamic damage
		noairburst = value / nil -- if true, this projectile will skip all airburst checks except ttl
		onexplode = value / nil -- if true, this projectile will cluster when it explodes
	}
]]

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
include("LuaRules/Configs/customcmds.h.lua")

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
local spGetProjectileTeamID = Spring.GetProjectileTeamID
local spSpawnSFX = Spring.SpawnSFX
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetUnitDefID = Spring.GetUnitDefID
local spSetProjectileCEG = Spring.SetProjectileCEG


local random = math.random
local sqrt = math.sqrt
local byte = string.byte
local abs = math.abs
local atan2 = math.atan2
local pi = math.pi
local halfpi = pi/2
local doublepi = pi*2
local abs = math.abs -- CAS GOES TO THE GYM AND HAS DOUBLE ABS
local strfind = string.find
local gmatch = string.gmatch
local floor = math.floor
local rad = math.rad
local sin = math.sin
local cos = math.cos

local CommandOrder = 123456
local ground = byte("g")
local unit = byte("u")
local projectile = byte("p")
local feature = byte("f")
local ALLIES = {allied = true}

local frame

local targetCancelRadius = 50*50

local setprojectiletargetcmddesc = {
	id      = CMD_SUBMUNITION_TARGET,
	type    = CMDTYPE.ICON_UNIT_OR_MAP,
	name    = 'Set Warhead Target',
	action  = 'subprojectileattack',
	tooltip	= 'Adds a payload target at the selected position. Payloads without a target will be targeted at a random nearby location (Issue on exsiting target to cancel target)',
}

--variables--
spEcho("CAS: Scanning weapondefs")
local config = VFS.Include("LuaRules/Configs/submunition_config.lua") -- projectile configuration data
spEcho("CAS: done processing weapondefs")

local projectiles = IterableMap.New() -- stuff we need to act on.
local targettable = {} -- holds individual warhead info. form: unitID = {[1] = {x,y,z}, etc}
local projectiletargets = {} -- proID = {[1] = {}, [2] = {}, etc}
local forceupdatetargets = {count = 0, data = {}} -- proID = {x, y, z}
local debugMode = false
local wanteddefs = VFS.Include("LuaRules/Configs/setprojectiletargetdefs.lua") or {}
local mapx = Game.mapSizeX
local mapz = Game.mapSizeZ
-- functions --
local function ToggleDebug()
	if spIsCheatingEnabled() then -- toggle debugMode
		debugMode = not debug
		if debugMode then
			spEcho("[CAS] Debug enabled.")
		else
			spEcho("[CAS] Debug disabled.")
		end
	end
end

local function AddCommand(unitID)
	targettable[unitID] = {} -- note: count is for the active projectiles so we know when to delete the table.
	spInsertUnitCmdDesc(unitID, CommandOrder, setprojectiletargetcmddesc)
end

local function distance3d(x1, y1, z1, x2, y2, z2)
	return sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)) + ((z2 - z1) * (z2 - z1)))
end

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

if debugMode then 
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

local function RegisterForceUpdate(id, x, y, z)
	local count = forceupdatetargets.count + 1
	forceupdatetargets.count = count
	if forceupdatetargets.data[count] then
		forceupdatetargets.data[count].id = id
		forceupdatetargets.data[count].x = x
		forceupdatetargets.data[count].y = y
		forceupdatetargets.data[count].z = z
	else
		forceupdatetargets.data[count] = {id = id, x = x, y = y, z = z}
	end
end

local function RegisterSubProjectiles(p, me)
	if config[me] then
		local damagemult = spGetUnitRulesParam(spGetProjectileOwnerID(p), "comm_damage_mult")
		IterableMap.Add(projectiles, p, {def = me, intercepted = false, ttl = ((config[me].timer and (frame + config[me].timer)) or nil), delay = 0, charges = config[me].clustercharges, commdamagemult = damagemult}) --frame is set to current frame in gameframe
		if config[me]["alwaysvisible"] then
			spSetProjectileAlwaysVisible(p, true)
		end
	end
end

local function GetRandomAttackPoint(x, z, radius)
	local distance = sqrt(random(0, radius*radius))
	local heading = rad(random(0, 360))
	local target = {}
	target[1] = x + (distance * sin(heading))
	target[3] = z + (distance * cos(heading))
	if target[1] > mapx then -- clamp inside the map
		target[1] = mapx
	elseif target[1] < 0 then
		target[1] = 0
	end
	if target[3] > mapz then -- ditto
		target[3] = mapz
	elseif target[3] < 0 then
		target[3] = 0
	end
	target[2] = spGetGroundHeight(target[1], target[3])
	return target
end

local function GetRingAttackPoint(x, z, radius, heading)
	local target = {}
	target[1] = x + (radius * sin(heading))
	target[3] = z + (radius * cos(heading))
	if target[1] > mapx then -- clamp inside the map
		target[1] = mapx
	elseif target[1] < 0 then
		target[1] = 0
	end
	if target[3] > mapz then -- ditto
		target[3] = mapz
	elseif target[3] < 0 then
		target[3] = 0
	end
	target[2] = spGetGroundHeight(target[1], target[3])
	return target
end

local function ConvertProjectileTargetToPos(targettype, targetID, projX, projY, projZ)
	if targettype == ground then -- this is an undocumented case. Aircraft bombs when targeting ground returns 103 or byte(49).
		x1 = targetID[1]
		y1 = targetID[2]
		z1 = targetID[3]
		if debugMode then
			spEcho(x1,y1,z1)
		end
	elseif targettype == 103 then
		if debugMode then
			spEcho("103! \n" .. targetID[1],targetID[2],targetID[3])
		end
		x1 = projX
		y1 = spGetGroundHeight(projX,projZ)
		z1 = projZ
	elseif targettype == unit or targettype == 117 then
		x1,y1,z1 = spGetUnitPosition(targetID)
	elseif targettype == feature then
		x1,y1,z1 = spGetFeaturePosition(targetID)
	elseif targettype == projectile then
		x1,y1,z1 = spGetProjectilePosition(targetID)
	end
	return x1, y1, z1
end

local function GetFixedHeight(wd, x, z)
	if WeaponDefs[wd].waterWeapon then
		return spGetGroundHeight(x, z)
	else
		local h = spGetGroundHeight(x, z)
		if h >= 0 then 
			return h 
		else 
			return 0
		end
	end
end

local function SpawnSubProjectiles(id, wd)
	if id == nil then
		return
	end
	--spawn all the subprojectiles
	local projectiledata = IterableMap.Get(projectiles, id)
	local projectileattributes = {pos = {0,0,0}, speed = {0,0,0}, owner = 0, team = 0, ttl= 0,gravity = 0,tracking = false,}
	if debugMode then
		spEcho("Fire the submunitions!")
	end
	local x, y, z = spGetProjectilePosition(id)
	local vx, vy, vz = spGetProjectileVelocity(id)
	local ttype, target = spGetProjectileTarget(id)
	local targetX, targetY, targetZ = ConvertProjectileTargetToPos(ttype, target, x, y, z)
	-- update projectile attributes --
	local owner = spGetProjectileOwnerID(id)
	projectileattributes["owner"] = owner
	projectileattributes["team"] = spGetProjectileTeamID(id)
	projectileattributes["pos"][1] = x
	projectileattributes["pos"][2] = y
	projectileattributes["pos"][3] = z
	projectileattributes["speed"][1] = vx
	projectileattributes["speed"][2] = vy
	projectileattributes["speed"][3] = vz
	local projectileConfig = config[wd].frags
	local targetoverride
	local forceupdate = false
	local ownerDefID = spGetUnitDefID(owner) or projectiledata.proOwnerDefID
	if config[wd].usertarget then
		targetoverride = projectiletargets[id] or {}
		forceupdate = true
	end
	local step = {0,0,0}
	-- Create the projectiles --
	for j = 1, config[wd].fragcount do
		local me = projectileConfig[j]["projectile"]
		local mr = projectileConfig[j]["spreadmin"]
		local dr = projectileConfig[j]["spreadmax"] - mr
		local vr = projectileConfig[j]["veldata"]
		local projectilecount = projectileConfig[j]["numprojectiles"]
		for i = 1, 3 do
			step[i] = (vr.diff[i]) / projectilecount
		end
		if debugMode then
			spEcho("Velocity: " ..tostring(projectileConfig[j].clusterpos),tostring(projectileConfig[j].clustervec) .. "\nstep: " .. tostring(step))
		end
		if WeaponDefs[me].type == "Cannon" and WeaponDefs[me].flightTime == 0 then
			projectileattributes["ttl"] = 1500 -- Needed to appease the unspeakable evil: https://github.com/beyond-all-reason/spring/issues/704
		else
			projectileattributes["ttl"] = WeaponDefs[me].flightTime or WeaponDefs[me].beamTTL or 9000
		end
		projectileattributes["tracking"] = (WeaponDefs[me].tracks and ttype == unit and target) or false
		projectileattributes["gravity"] = -WeaponDefs[me].myGravity or -1
		local ceg = WeaponDefs[me].cegTag
		--spEcho(tostring(ceg))
		projectileattributes["cegTag"] = ceg
		local positioning = projectileConfig[j].clusterpos or "none"
		local vectoring = projectileConfig[j].clustervec or "none"
		local keepmomentum = projectileConfig[j].keepmomentum
		if config[wd].dynDamage then
			local spawnMult = projectiledata.commdamagemult or 1
			if debugMode then
				spEcho("SpawnMult: " .. spawnMult)
			end
			if spawnMult > 1 then
				projectilecount = floor(spawnMult * projectilecount + random())
			end
		end
		local untargetedCount
		for i = 1, projectilecount do
			if config[wd].usertarget then
				if targetoverride[i] then
					target = targetoverride[i]
				else
					untargetedCount = untargetedCount or (projectilecount - i + 1) --the +1 is there since THIS projectile is also not targeted
					if untargetedCount >= 3 then
						local angle = (i + untargetedCount - projectilecount) * (doublepi / untargetedCount)
						target = GetRingAttackPoint(targetX, targetZ, wanteddefs[ownerDefID]["noTargetRange"], angle)
						
					else
						target = GetRandomAttackPoint(targetX, targetZ, wanteddefs[ownerDefID]["noTargetRange"])
					end
				end
				ttype = ground
			end
			local p
			if strfind(positioning,"random") then
				if strfind(positioning,"x") then
					projectileattributes["pos"][1] = x+mr+(2*dr*random())
				end
				if strfind(positioning,"y") then
					projectileattributes["pos"][2] = y+mr+(2*dr*random())
				end
				if strfind(positioning,"z") then
					projectileattributes["pos"][3] = z+mr+(2*dr*random())
				end
			end
			local vxf, vyf, vzf = (vx * keepmomentum[1]), (vy * keepmomentum[2]), (vz * keepmomentum[3])
			if strfind(vectoring,"random") then
				if strfind(vectoring,"x") then
					projectileattributes["speed"][1] = vxf+vr.min[1]+(vr.diff[1]*random())
				end
				if strfind(vectoring,"y") then
					projectileattributes["speed"][2] = vyf+vr.min[2]+(vr.diff[2]*random())
				end
				if strfind(vectoring,"z") then
					projectileattributes["speed"][3] = vzf+vr.min[3]+(vr.diff[3]*random())
				end
			elseif strfind(vectoring,"even") then
				if strfind(vectoring,"x") then
					projectileattributes["speed"][1] = vxf+(vr.min[1]+(step[1]*(i-1)))
				end
				if strfind(vectoring,"y") then
					projectileattributes["speed"][2] = vyf+(vr.min[2]+(step[2]*(i-1)))
				end
				if strfind(vectoring,"z") then
					projectileattributes["speed"][3] = vzf+(vr.min[3]+(step[3]*(i-1)))
				end
			end
			--projectileattributes["end"][1] = projectileattributes.speed[1] + projectileattributes.pos[1]
			--projectileattributes["end"][2] = projectileattributes.speed[2] + projectileattributes.pos[2]
			--projectileattributes["end"][3] = projectileattributes.speed[3] + projectileattributes.pos[3]
			if debugMode then
				spEcho("Projectile Speed: " .. projectileattributes["speed"][1],projectileattributes["speed"][2],projectileattributes["speed"][3])
			end
			if projectileConfig[j].spawnsfx then
				--How does this work? I have no idea!
				local dx = projectileattributes["speed"][1]
				local dy = projectileattributes["speed"][2] - 1 --hackity hax
				local dz = projectileattributes["speed"][3]
				--do not question the arctangent
				local dx2 = dx * dx	
				local dy2 = dy * dy
				local dz2 = dz * dz
				local dirX = atan2(dx, sqrt(dy2 + dz2))
				local dirY = atan2(dy, sqrt(dx2 + dz2))
				local dirZ = atan2(dz, sqrt(dx2 + dy2))
				spSpawnSFX(projectileattributes["owner"], projectileConfig[j].spawnsfx, projectileattributes["pos"][1], projectileattributes["pos"][2], projectileattributes["pos"][3], dirX, dirY, dirZ, true)
			else
				p = spSpawnProjectile(me, projectileattributes)
				--if projectileattributes["tracking"] then
				if ttype ~= ground then
					if debugMode then
						spEcho("setting target for " .. p .. " = " .. tostring(target)) -- safety
					end
					spSetProjectileTarget(p, target,ttype)
				else
					if debugMode then
						spEcho("CAS: setting target for " .. p .. " = (" .. target[1] .. ", " .. target[2] .. ", " .. target[3] .. ")")
					end
					RegisterForceUpdate(p, target[1], target[2], target[3])
				end
				--end
			end
			RegisterSubProjectiles(p, me)
			--if ceg and ceg ~= "" then
				--spSetProjectileCEG(p, [[custom:]] .. ceg)
			--end
		end
	end
	-- create the explosion --
	if config[wd].noceg then
		spSpawnExplosion(x, y, z, 0, 0, 0, {weaponDef = wd, owner = spGetProjectileOwnerID(id), craterAreaOfEffect = WeaponDefs[wd].craterAreaOfEffect, damageAreaOfEffect = 0, edgeEffectiveness = 0, explosionSpeed = WeaponDefs[wd].explosionSpeed, impactOnly = WeaponDefs[wd].impactOnly, ignoreOwner = WeaponDefs[wd].noSelfDamage, damageGround = true})
	end
	--Spring.Echo("OnSplit", WeaponDefs[wd].hitSound[1].name, WeaponDefs[wd].hitSound[1].volume)
	local soundToPlay = WeaponDefs[wd].customParams.onsplitsound or WeaponDefs[wd].hitSound[1].name
	spPlaySoundFile(soundToPlay, WeaponDefs[wd].hitSound[1].volume, x, y, z, 0, 0, 0, "battle")
	local projectiledata = IterableMap.Get(projectiles, id)
	if projectiledata.charges == 1 or projectiledata.charges == 0 then --charge below 0 never run out
		if debugMode then
			spEcho("Run outta charge")
		end
		spDeleteProjectile(id)
		projectiledata.dead = true
	else
		projectiledata.charges = projectiledata.charges - 1
		if debugMode then
			spEcho("Lost 1 charge")
		end
		projectiledata.delay = frame + config[wd].clusterdelay
		local delaytype = projectileConfig.clusterdelaytype
		if delaytype == 0 then
			projectileConfig.clusterdelaytype = 1
		end
	end
	if config[wd].usertargetable then
		targettable[owner].count = targettable[owner].count - 1
		if targettable[owner].count == 0 and targettable[owner].dead then
			targettable[owner] = nil
		end
	end
	projectiletargets[id] = nil
end

local function CheckProjectile(id)
	if debugMode then 
		spEcho("CheckProjectile " .. id)
	end
	local projectile = IterableMap.Get(projectiles, id)
	local targettype, targetID = spGetProjectileTarget(id)
	if targettype == nil or projectile.dead then
		if debugMode then spEcho("projectile " .. id .. " deleted.") end
		IterableMap.Remove(projectiles, id)
		return
	end
	local wd = projectile.def or spGetProjectileDefID(id)
	if debugMode then spEcho("isCheckedDuringCruise: " .. tostring(config[wd]["block_check_during_cruise"])) end
	if config[wd]["block_check_during_cruise"] and GG.GetMissileCruising(id) then -- some weapons don't want CAS to check during cruise.
		if debugMode then spEcho(id .. " got blocked due to Cruising") end
		return
	end
	if projectile.delay <= frame then
		if config[wd].clusterdelaytype == 1 then
			if debugMode then
				spEcho("Locked in spawning")
			end
			SpawnSubProjectiles(id,wd)
			return
		else
			if projectile.ttl then -- timed weapons don't need anything fancy.
				if projectile.ttl <= frame then
					if debugMode then
						spEcho("Spawn by ttl")
					end
					SpawnSubProjectiles(id, wd)
					return
				else
					return
				end
			end
			if config[wd].airburst then
				--spEcho("wd: " .. tostring(wd))
				projectile.intercepted = spGetProjectileIsIntercepted(id)
				local isMissile = false -- check for missile status. When the missile times out, the subprojectiles will be spawned if allowed.
				if WeaponDefs[wd]["flightTime"] ~= nil and WeaponDefs[wd].type == "Missile" then
					isMissile = true
				end
				local myConfig = config[wd]
				local vx,vy,vz = spGetProjectileVelocity(id)
				if myConfig.launcher and vy > -0.000001 then
					return
				end
				--spEcho("CheckProjectile: " .. id .. ", " .. wd)
				local ttl = spGetProjectileTimeToLive(id)
				if isMissile and debugMode then spEcho("ttl: " .. tostring(ttl)) end
				if isMissile and myConfig.timeoutspawn and ttl == 0 then
					if debugMode then
						spEcho("Spawn by timeoutspawn")
					end
					SpawnSubProjectiles(id,wd)
					return
				end
				local use3d = (myConfig.use2ddist == 0)
				local distance
				local x2,y2,z2 = spGetProjectilePosition(id)
				local x1,y1,z1 = ConvertProjectileTargetToPos(targettype, targetID, x2, y2, z2)
				if debugMode then 
					spEcho("Attack type: " .. targettype .. "\nTarget: " .. tostring(targetID))
				end
				--debugEcho("Key: 'g' = " .. byte("g") .. "\n'u' = " .. byte("u") .. "\n'f' = " .. byte("f") .. "\n'p' = " .. byte("p"))
				if myConfig.useheight and myConfig.useheight ~= 0 then -- this spawns at the selected height when vy < 0
					if debugMode then
						spEcho("Useheight check")
					end
					local heightDiff
					if myConfig.useasl then
						heightDiff = y2
					else
						heightDiff = y2 - GetFixedHeight(wd, x2,z2)
					end
					if heightDiff <= myConfig.spawndist and vy <= myConfig.minvelocity then
						if debugMode then
							spEcho("Spawn by ground height")
						end
						SpawnSubProjectiles(id,wd)
					end
					return
				end
				if use3d then
					distance = distance3d(x2,y2,z2,x1,y1,z1)
				else
					distance = distance2d(x2,z2,x1,z1)
				end
				local height = y2 - GetFixedHeight(wd, x2,z2)
				if debugMode then
					spEcho("d: " .. distance .. "\nisBomb: " .. tostring(myConfig["isBomb"]) .. "\nVelocity: (" .. vx,vy,vz .. ")" .. "\nH: " .. height .. "\nexplosion dist: " .. height - myConfig.spawndist)
				end
				if distance < myConfig.spawndist and not myConfig["isBomb"] then -- bombs ignore distance and explode based on height. This is due to bomb ground attacks being absolutely fucked in current spring build.
					SpawnSubProjectiles(id,wd)
					if debugMode then
						spEcho("distance")
					end
					return
				elseif myConfig["isBomb"] and height <= myConfig.spawndist then
					SpawnSubProjectiles(id,wd)
					if debugMode then
						spEcho("bomb engage")
					end
					return
				elseif myConfig.groundimpact == 1 and vy < -1 or myConfig.groundimpact == 2 and height <= myConfig.spawndist then
					if debugMode then
						spEcho("ground impact")
					end
					SpawnSubProjectiles(id,wd)
					return
				elseif myConfig["proxy"] == 1 then
					local units
					if use3d then
						units = spGetUnitsInSphere(x2,y2,z2, myConfig["proxydist"])
					else 
						units = spGetUnitsInCylinder(x2,z2, myConfig["proxydist"])
					end
					if unittest(units, projectile.owner, projectile.teamID) then
						if debugMode then
							spEcho("Unit passed unittest. Passed to SpawnSubProjectiles")
						end
						SpawnSubProjectiles(id, wd)
						return
					end
				end
			end
		end
	elseif debugMode then
		spEcho("Delay: " .. projectile.delay)
	end
end

local function UpdateAttackOrder(unitID, pos)
	if not pos[2] then
		local new = {}
		new[1], new[2], new[3] = spGetUnitPosition(pos[1])
		pos = new
	end
	if debugMode then
		spEcho("[CAS] Updating Attack Order: Got: {" .. tostring(new[1]) .. "," .. tostring(new[2]) .. "," .. tostring(new[3]) .. ")")
	end
	local unitTargets = targettable[unitID] or {}
	local count = #unitTargets
	local removeTarget = false
	if count > 0 then
		for i = 1, count do
			if unitTargets[i] and (unitTargets[i][1]-pos[1])^2 + (unitTargets[i][3]-pos[3])^2 < targetCancelRadius then
				removeTarget = i
				break
			end
		end
	end
	if removeTarget then
		unitTargets[removeTarget] = unitTargets[count]
		unitTargets[count] = nil
	else
		unitTargets[count + 1] = {pos[1], pos[2], pos[3]}
	end
	count = #unitTargets
	for i = 1, count do
		spSetUnitRulesParam(unitID, "subprojectile_target_" .. i .. "_x", unitTargets[i][1], ALLIES)
		spSetUnitRulesParam(unitID, "subprojectile_target_" .. i .. "_z", unitTargets[i][3], ALLIES)
	end
	if debugMode then
		spEcho("CAS: updating targets for unit " .. unitID .. ", new targets list:")
		Spring.Utilities.TableEcho(unitTargets)
	end
	
	targettable[unitID] = unitTargets
	spSetUnitRulesParam(unitID, "subprojectile_target_count", count, ALLIES)
end

local function AddCommanderCmd(unitID)
	AddCommand(unitID)
end
	

GG.Submunitions = {}
GG.Submunitions.AddProjectileTarget = UpdateAttackOrder
GG.Submunitions.AddCommanderCmd = AddCommanderCmd

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if debugMode then
		spEcho("ProjectileCreated: " .. tostring(proID, proOwnerID, weaponDefID))
	end
	local proOwnerDefID = spGetUnitDefID(proOwnerID)
	if targettable[proOwnerID] and config[weaponDefID] and config[weaponDefID]["usertarget"] then
		local unitTargets = targettable[proOwnerID]
		local ttype, target = spGetProjectileTarget(proID)
		local x,y,z
		if ttype == unit then
			x,y,z = spGetUnitPosition(target)
		else
			x,y,z = target[1], target[2], target[3]
		end
		spSetProjectileTarget(proID, x, y, z)
		
		local selectableTargets = wanteddefs[proOwnerDefID]["targets"]
		local selectedTargets = {}
		local projTargets = {}
		local newUnitTargets = {}
		--select the targets and add them to projTargets
		for i=1, #unitTargets do
			if debugMode then
				spEcho("CAS: distance between MIRV target and warhead target: " .. ((unitTargets[i][1]-x)^2+(unitTargets[i][3]-z)^2))
			end
			if ((unitTargets[i][1]-x)^2+(unitTargets[i][3]-z)^2) <= wanteddefs[proOwnerDefID]["range2"] then
				selectableTargets = selectableTargets - 1
				selectedTargets[i] = true
				projTargets[#projTargets+1] = unitTargets[i]
				if selectableTargets <= 0 then
					break
				end
			end
		end
		--remove the selected targets from unitTargets
		for i=1, #unitTargets do
			if not selectedTargets[i] then
				newUnitTargets[#newUnitTargets+1] = unitTargets[i]
			end
		end
		--update unitrulesparam
		if #newUnitTargets > 0 then
			for i = 1, #newUnitTargets do
				spSetUnitRulesParam(proOwnerID, "subprojectile_target_" .. i .. "_x", newUnitTargets[i][1], ALLIES)
				spSetUnitRulesParam(proOwnerID, "subprojectile_target_" .. i .. "_z", newUnitTargets[i][3], ALLIES)
			end
		end
		spSetUnitRulesParam(proOwnerID, "subprojectile_target_count", #newUnitTargets, ALLIES)
		
		if debugMode then
			spEcho("CAS: MIRV launched by unit " .. proOwnerID)
			spEcho("CAS: Unit Targets:")
			Spring.Utilities.TableEcho(unitTargets)
			spEcho("CAS: New Unit Targets:")
			Spring.Utilities.TableEcho(newUnitTargets)
			spEcho("CAS: MIRV Targets")
			Spring.Utilities.TableEcho(projTargets)
		end
		
		--update the main tables
		targettable[proOwnerID] = newUnitTargets
		projectiletargets[proID] = projTargets
	end
	if weaponDefID == nil then
		weaponDefID = spGetProjectileDefID(proID)
	end
	local projectiledata = IterableMap.Get(projectiles, proID)
	if config[weaponDefID] and not projectiledata then
		if debugMode then
			spEcho("Registered projectile " .. proID)
		end
		IterableMap.Add(projectiles, proID, {def = weaponDefID, intercepted = false, owner = proOwnerID, teamID = spGetProjectileTeamID(proID), ttl = ((config[weaponDefID].timer and (frame + config[weaponDefID].timer)) or nil), delay = 1, charges = config[weaponDefID].clustercharges, proOwnerDefID = proOwnerDefID}) --frame is set to the current frame in gameframe
		if config[weaponDefID]["alwaysvisible"] then
			spSetProjectileAlwaysVisible(proID,true)
		end
	end
end

--Does not seem to called
--[[function gadget:ProjectileDestroyed(proID)
	local projectiledata = IterableMap.Get(projectiles, proID)
	if projectiledata and not projectiledata.intercepted then
		local wd = projectiledata.def
		spEcho("Destroyed")
		SpawnSubProjectiles(id, wd)
	end
end]]--

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if config[weaponDefID] then
		local projectiledata = IterableMap.Get(projectiles, ProjectileID)
		if projectiledata and config[weaponDefID]["onExplode"] then
			if debugMode then
				spEcho("I Smell an Explosion!")
			end
			SpawnSubProjectiles(ProjectileID, weaponDefID)
			IterableMap.Remove(projectiles, id)
		end
	end
end

function gadget:GameFrame(f)
	frame = f
	if forceupdatetargets.count > 0 then
		for i = 1, forceupdatetargets.count do
			local data = forceupdatetargets.data[i]
			spSetProjectileTarget(data.id, data.x, data.y, data.z)
			GG.ForceCruiseUpdate(data.id, data.x, data.y, data.z)
		end
		forceupdatetargets.count = 0
	end
	for id, data in IterableMap.Iterator(projectiles) do
		if debugMode then spEcho(id .. ": Updating.") end
		CheckProjectile(id)
	end
end

function gadget:UnitCreated(unitID, unitDefID)
	if wanteddefs[unitDefID] then
		AddCommand(unitID)
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
	if cmdID ~= CMD_SUBMUNITION_TARGET then
		return true
	else
		UpdateAttackOrder(unitID, cmdParams)
		return false
	end
end

function gadget:Initialize()
	gadgetHandler:AddChatAction("debugcas", ToggleDebug, "Toggles CAS debug echos.")
end

function gadget:UnitDestroyed(unitID)
	targettable[unitID] = nil
end
