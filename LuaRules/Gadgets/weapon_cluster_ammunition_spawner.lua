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
local strfind = string.find
local gmatch = string.gmatch
local floor = math.floor
local rad = math.rad
local sin = math.sin
local cos = math.cos
local acos = math.acos

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
	Spring.Utilities.TableEcho(config)
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

local function RegisterProjectile(proID, proOwnerID, proOwnerDefID, teamID, weaponDefID)
	if config[weaponDefID] then
		if debugMode then
			spEcho("Registered projectile " .. proID)
		end
		local damagemult = spGetUnitRulesParam(proOwnerID, "comm_damage_mult")
		local projConfig = config[weaponDefID]
		IterableMap.Add(projectiles, proID, {
			def = weaponDefID,
			intercepted = false,
			owner = proOwnerID,
			teamID = teamID,
			ttl = frame + projConfig.timer,
			delay = 1,
			charges = projConfig.clustercharges,
			proOwnerDefID = proOwnerDefID,
			commdamagemult = damagemult,
			clusterdelaytype = projConfig.clusterdelaytype,
			cluster}) --frame is set to current frame in gameframe
		if config[weaponDefID]["alwaysvisible"] then
			spSetProjectileAlwaysVisible(p, true)
		end
	end
end

local function GetRandomAttackPoint(x, z, radius)
	local distance = (1-sqrt(random())) * radius
	local heading = random() * doublepi
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

local function circleRand()
	local theta, mag = random()*doublepi, 1-sqrt(random())
	return cos(theta)*mag, sin(theta)*mag
end

local function getSpread(spreadArr, spreadMode)
	if spreadMode == 1 then -- none
		return {0, 0, 0}
	elseif spreadMode == 2 then --cylY
		local x, z = circleRand()
		return {spreadArr[1] + x*spreadArr[4], spreadArr[2] + 2*(random()-0.5)*spreadArr[5], spreadArr[3] + z*spreadArr[6]}
	elseif spreadMode == 3 then --cylX
		local y, z = circleRand()
		return {spreadArr[1] + 2*(random()-0.5)*spreadArr[4], spreadArr[2] + y*spreadArr[5], spreadArr[3] + z*spreadArr[6]}
	elseif spreadMode == 4 then --cylZ
		local x, y = circleRand()
		return {spreadArr[1] + x*spreadArr[4], spreadArr[2] + z*spreadArr[5], spreadArr[3] + 2*(random()-0.5)*spreadArr[6]}
	elseif spreadMode == 5 then --box
		return {spreadArr[1] + 2*(random()-0.5)*spreadArr[4], spreadArr[2] + 2*(random()-0.5)*spreadArr[5], spreadArr[3] + 2*(random()-0.5)*spreadArr[6]}
	elseif spreadMode == 6 then --sphere
		-- Credits to Karthik Karanth for alg
		local theta, phi, mag = random() * doublepi, acos(2*random() - 1), 1 - random()^(1/3)
		local magsinphi = sin(phi)*mag
		return {spreadArr[1] + magsinphi*sin(theta)*spreadArr[4], spreadArr[2] + magsinphi*cos(theta)*spreadArr[5], spreadArr[3] + mag*cos(phi)*spreadArr[6]}
	else
		Spring.Log(GetInfo().name, "error", "[weapon_cluster_ammunition_spawner.lua] Error: Unknown Spreadmode: ".. spreadMode)
	end
end

local function SpawnSubProjectiles(id, wd)
	if id == nil then
		return
	end
	--spawn all the subprojectiles
	local projectiledata = IterableMap.Get(projectiles, id)
	local projAttributes = {pos = {0,0,0}, speed = {0,0,0}, owner = 0, team = 0, ttl= 0,gravity = 0,tracking = false,}
	if debugMode then
		spEcho("Fire the submunitions!")
	end
	local projConfig = config[wd]
	local x, y, z = spGetProjectilePosition(id)
	local vx, vy, vz = spGetProjectileVelocity(id)
	local ttype, target = spGetProjectileTarget(id)
	local targetX, targetY, targetZ = ConvertProjectileTargetToPos(ttype, target, x, y, z)
	-- update projectile attributes --
	local owner = spGetProjectileOwnerID(id)
	projAttributes["owner"] = owner
	local team = spGetProjectileTeamID(id)
	projAttributes["team"] = team
	local targetoverride
	local forceupdate = false
	local ownerDefID = spGetUnitDefID(owner) or projectiledata.proOwnerDefID
	if projConfig.usertarget then
		targetoverride = projectiletargets[id] or {}
		forceupdate = true
	end
	local step = {0,0,0}
	-- Create the projectiles --
	for j = 1, projConfig.fragcount do
		local fragConfig = projConfig.frags[j]
		local me = fragConfig.projectile
		local projCount = fragConfig["numprojectiles"]
		if WeaponDefs[me].type == "Cannon" and WeaponDefs[me].flightTime == 0 then
			projAttributes["ttl"] = 1500 -- Needed to appease the unspeakable evil: https://github.com/beyond-all-reason/spring/issues/704
		else
			projAttributes["ttl"] = WeaponDefs[me].flightTime or WeaponDefs[me].beamTTL or 9000
		end
		projAttributes["tracking"] = (WeaponDefs[me].tracks and ttype == unit and target) or false
		projAttributes["gravity"] = -WeaponDefs[me].myGravity or -1
		local ceg = WeaponDefs[me].cegTag
		--spEcho(tostring(ceg))
		projAttributes["cegTag"] = ceg
		local keepmomentum = fragConfig.keepmomentum
		if projConfig.dynDamage then
			local spawnMult = projectiledata.commdamagemult or 1
			if debugMode then
				spEcho("SpawnMult: " .. spawnMult)
			end
			if spawnMult > 1 then
				projCount = floor(spawnMult * projCount + random())
			end
		end
		local untargetedCount
		for i = 1, projCount do
			if projConfig.usertarget then
				if targetoverride[i] then
					target = targetoverride[i]
				else
					untargetedCount = untargetedCount or (projCount - i + 1) --the +1 is there since THIS projectile is also not targeted
					if untargetedCount >= 3 then
						local angle = (i + untargetedCount - projCount) * (doublepi / untargetedCount)
						target = GetRingAttackPoint(targetX, targetZ, wanteddefs[ownerDefID]["noTargetRange"], angle)
					else
						target = GetRandomAttackPoint(targetX, targetZ, wanteddefs[ownerDefID]["noTargetRange"])
					end
				end
				ttype = ground
			end
			projAttributes["pos"] = getSpread(fragConfig.posSpread, fragConfig.posSpreadMode)
			local projPos = projAttributes["pos"]
			projPos[1] = projPos[1] + x
			projPos[2] = projPos[2] + y
			projPos[3] = projPos[3] + z
			projAttributes["speed"] = getSpread(fragConfig.velSpread, fragConfig.velSpreadMode)
			if keepmomentum then
				local projVel = projAttributes["speed"]
				projVel[1] = projVel[1] + vx*keepmomentum[1]
				projVel[2] = projVel[2] + vy*keepmomentum[2]
				projVel[3] = projVel[3] + vz*keepmomentum[3]
			end
			if debugMode then
				spEcho("Projectile Speed: " .. projAttributes["speed"][1],projAttributes["speed"][2],projAttributes["speed"][3])
			end
			if fragConfig.spawnsfx then
				--How does this work? I have no idea!
				local dx = projAttributes["speed"][1]
				local dy = projAttributes["speed"][2] - 1 --hackity hax
				local dz = projAttributes["speed"][3]
				--do not question the arctangent
				local dx2 = dx * dx	
				local dy2 = dy * dy
				local dz2 = dz * dz
				local dirX = atan2(dx, sqrt(dy2 + dz2))
				local dirY = atan2(dy, sqrt(dx2 + dz2))
				local dirZ = atan2(dz, sqrt(dx2 + dy2))
				spSpawnSFX(projAttributes["owner"], fragConfig.spawnsfx, projAttributes["pos"][1], projAttributes["pos"][2], projAttributes["pos"][3], dirX, dirY, dirZ, true)
			end
			if fragConfig.projectile then
				p = spSpawnProjectile(me, projAttributes)
				--if projAttributes["tracking"] then
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
				RegisterProjectile(p, owner, ownerDefID, team, me)
			end
		end
	end
	-- create the explosion --
	if not projConfig.noceg then
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
		projectiledata.delay = frame + projConfig.clusterdelay
		if projectiledata.clusterdelaytype == 0 then
			projectiledata.clusterdelaytype = -1
		end
	end
	if projConfig.usertarget then
		if targettable[owner] and targettable[owner].count then
			targettable[owner].count = targettable[owner].count - 1
			if targettable[owner].count == 0 and targettable[owner].dead then
				targettable[owner] = nil
			end
		else
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
	local projConfig = config[wd]
	if debugMode then spEcho("isCheckedDuringCruise: " .. tostring(projConfig["block_check_during_cruise"])) end
	if projConfig["block_check_during_cruise"] and GG.GetMissileCruising(id) then -- some weapons don't want CAS to check during cruise.
		if debugMode then spEcho(id .. " got blocked due to Cruising") end
		return
	end
	if projectile.delay <= frame then
		if projectile.clusterdelaytype == -1 then
			if debugMode then
				spEcho("Locked in spawning")
			end
			SpawnSubProjectiles(id,wd)
			return
		else
			if projectile.ttl <= frame then
				if debugMode then
					spEcho("Spawn by ttl")
				end
				SpawnSubProjectiles(id, wd)
				return
			end
			if not projConfig.airburst then
				if debugMode then
					spEcho("noairburst short circuit")
				end
				return
			end
			
			--spEcho("wd: " .. tostring(wd))
			projectile.intercepted = spGetProjectileIsIntercepted(id)
			local isMissile = false -- check for missile status. When the missile times out, the subprojectiles will be spawned if allowed.
			if WeaponDefs[wd]["flightTime"] ~= nil and WeaponDefs[wd].type == "Missile" then
				isMissile = true
			end
			local myConfig = projConfig
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
			local distance
			local x2,y2,z2 = spGetProjectilePosition(id)
			local x1,y1,z1 = ConvertProjectileTargetToPos(targettype, targetID, x2, y2, z2)
			if debugMode then 
				spEcho("Attack type: " .. targettype .. "\nTarget: " .. tostring(targetID))
			end
			--debugEcho("Key: 'g' = " .. byte("g") .. "\n'u' = " .. byte("u") .. "\n'f' = " .. byte("f") .. "\n'p' = " .. byte("p"))
			if myConfig.useheight then -- this spawns at the selected height when vy < 0
				if debugMode then
					spEcho("Useheight check")
				end
				local heightDiff
				if myConfig.useasl then
					heightDiff = y2
				else
					heightDiff = y2 - GetFixedHeight(wd, x2,z2)
				end
				if heightDiff <= myConfig.spawndist and vy <= myConfig.maxvelocity then
					if debugMode then
						spEcho("Spawn by ground height")
					end
					SpawnSubProjectiles(id,wd)
				end
				return
			end
			if myConfig.use2ddist then
				distance = distance2d(x2,z2,x1,z1)
			else
				distance = distance3d(x2,y2,z2,x1,y1,z1)
			end
			local height = y2 - GetFixedHeight(wd, x2,z2)
			if debugMode then
				spEcho("d: " .. distance .. "\nisBomb: " .. tostring(myConfig["isBomb"]) .. "\nVelocity: (" .. vx,vy,vz .. ")" .. "\nH: " .. height .. "\nexplosion dist: " .. height - myConfig.spawndist)
			end
			if distance < myConfig.spawndist and not myConfig["isBomb"] then
				SpawnSubProjectiles(id,wd)
				if debugMode then
					spEcho("distance")
				end
				return
			elseif myConfig["proxy"] then
				local units
				if myConfig.use2ddist then
					units = spGetUnitsInCylinder(x2,z2, myConfig["proxydist"])
				else 
					units = spGetUnitsInSphere(x2,y2,z2, myConfig["proxydist"])
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
		RegisterProjectile(proID, proOwnerID, proOwnerDefID, spGetProjectileTeamID(proID), weaponDefID)
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
