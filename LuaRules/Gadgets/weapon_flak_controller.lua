function gadget:GetInfo()
	return {
		name      = "Flak Controller",
		desc      = "Implements flak weaponry.",
		author    = "_Shaman",
		date      = "March 17, 2019",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local config = {} -- stores table
local projectiles = {}
local debug = false

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
local spValidUnitID = Spring.ValidUnitID
local random = math.random
local sqrt = math.sqrt
local byte = string.byte
local abs = math.abs
local pi = math.pi
local blanktable = {}

local ground = byte("g")
local feature = byte("f")
local unit = byte("u")
local projectile = byte("p")

local lastlocation = {}

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if curRef and curRef.isflak then -- found it!
		spEcho("FlakCon: Discovered " .. i .. "(" .. wd.name .. ")")
		Script.SetWatchWeapon(i, true)
		config[i] = {type = tonumber(curRef.isflak)} -- 1 = 2d, 2 = 3d, 3 = timed explosion
		if config[i].type == 3 then
			config[i]["timer"] = tonumber(curRef.flaktime)
		else
			config[i]["timer"] = 0
		end
	end
	wd = nil
	curRef = nil
end
spEcho("FlakCon: done.")
for name,data in pairs(config) do
	for k,v in pairs(data) do
		spEcho(k .. ": " .. tostring(v))
	end
end

local function distance3d(x1,y1,z1,x2,y2,z2)
	return sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)
end

local function distance2d(x1,y1,x2,y2)
	return sqrt((x2-x1)^2+(y2-y1)^2)
end

local function ExplodeProjectile(id,wd,x,y,z)
	spSpawnExplosion(x,y,z,0,0,0,{weaponDef = wd, owner = spGetProjectileOwnerID(id), craterAreaOfEffect = WeaponDefs[wd].craterAreaOfEffect, damageAreaOfEffect = WeaponDefs[wd].damageAreaOfEffect, edgeEffectiveness = WeaponDefs[wd].edgeEffectiveness, explosionSpeed = WeaponDefs[wd].explosionSpeed, impactOnly = WeaponDefs[wd].impactOnly, ignoreOwner = WeaponDefs[wd].noSelfDamage, damageGround = true})
	spPlaySoundFile(WeaponDefs[wd].hitSound[1].name,WeaponDefs[wd].hitSound[1].volume,x,y,z)
	spDeleteProjectile(id)
	projectiles[id] = nil
end

local function CheckProjectile(id,wd)
	--spEcho(id .. " : " .. tostring(wd))
	local x,y,z = spGetProjectilePosition(id)
	if x == nil then
		projectiles[id] = nil
		return
	end
	if config[wd]["timer"] > 0 then
		projectiles[id].timer = projectiles[id].timer - 2
		local explode = 100 - random(10,80) + projectiles[id].timer
		if debug then spEcho("Explode: " .. explode) end
		if explode <= 0  then
			ExplodeProjectile(id,wd,x,y,z)
		end
		return
	end
	local ttype,target = spGetProjectileTarget(id)
	local vx,vy,vz = spGetProjectileVelocity(id)
	local olddistance = 0
	local x2,y2,z2
	olddistance = projectiles[id].distance
	--spEcho("Target: " .. target .. "(" .. ttype .. ")")
	if ttype == ground then
		local gy = spGetGroundHeight(x, z)
		if vy < -0.5 and y - gy < 10 then 
			ExplodeProjectile(id,wd,x,y,z)
		end
		return
	elseif ttype == unit then
		if not spValidUnitID(target) then
			ExplodeProjectile(id,wd,x,y,z)
			return
		end
		if not spGetUnitIsCloaked(target) then
			x2,y2,z2 = spGetUnitPosition(target)
			if lastlocation[target] then
				lastlocation[target][1] = x2
				lastlocation[target][2] = y2
				lastlocation[target][3] = z2
			else
				lastlocation[target] = {[1] = x2, [2] = y2, [3] = z2}
			end
		else
			x2 = lastlocation[target][1]
			y2 = lastlocation[target][2]
			z2 = lastlocation[target][3]
		end
	elseif ttype == feature then
		x2,y2,z2 = spGetFeaturePosition(target)
	elseif ttype == projectile then
		x2,y2,z2 = spGetProjectilePosition(target)
	else
		projectiles[id] = nil
		spEcho("Weird projectile: " .. id)
		return
	end
	if config[wd].type == 1 then
		projectiles[id].distance = distance2d(x,z,x2,z2)
	elseif config[wd].type == 2 then
		projectiles[id].distance = distance3d(x,y,z,x2,y2,z2)
	else
		projectiles[id] = nil
		return
	end
	if olddistance < projectiles[id].distance or projectiles[id].distance <= WeaponDefs[wd].damageAreaOfEffect/4 then
		ExplodeProjectile(id,wd,x,y,z)
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if config[weaponDefID] then
		if config[weaponDefID]["timer"] > 0 then
			projectiles[proID] = {timer = config[weaponDefID]["timer"] * 30, defid = weaponDefID}
			--spEcho("Timed demo charge for " .. proID)
		else
			projectiles[proID] = {distance = 999999999, defid = weaponDefID} -- distance stored here 
		end
	end
end

function gadget:UnitDestroyed(unitID)
	lastlocation[unitID] = nil
end

function gadget:GameFrame(f)
	if f%2 == 1 then
		for id, data in pairs(projectiles) do
			CheckProjectile(id,data.defid)
		end
	end
end
