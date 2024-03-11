if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

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

local IterableMap = Spring.Utilities.IterableMap

local config = {} -- stores table
local projectiles = IterableMap.New()
local debugMode = false

--Speedups--
local spEcho = Spring.Echo
local spGetProjectilePosition = Spring.GetProjectilePosition
local spGetProjectileTarget = Spring.GetProjectileTarget
local spDeleteProjectile = Spring.DeleteProjectile
local spGetProjectileOwnerID = Spring.GetProjectileOwnerID
local spGetProjectileVelocity = Spring.GetProjectileVelocity
local spPlaySoundFile = Spring.PlaySoundFile
local spSpawnExplosion = Spring.SpawnExplosion
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitIsCloaked = Spring.GetUnitIsCloaked
local spValidUnitID = Spring.ValidUnitID
local random = math.random
local sqrt = math.sqrt

local ground = string.byte("g")
local feature = string.byte("f")
local unit = string.byte("u")
local projectile = string.byte("p")

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if curRef and curRef.isflak then -- found it!
		if debugMode then
			spEcho("FlakCon: Discovered " .. i .. "(" .. wd.name .. ")")
		end
		Script.SetWatchWeapon(i, true)
		config[i] = {type = tonumber(curRef.isflak)} -- 1 = 2d, 2 = 3d, 3 = timed explosion
		if config[i].type == 3 then
			config[i]["timer"] = tonumber(curRef.flaktime)
		end
	end
end
spEcho("FlakCon: done.")
if debugMode then
	for name,data in pairs(config) do
		for k,v in pairs(data) do
			spEcho(k .. ": " .. tostring(v))
		end
	end
end

local function distance3d(x1,y1,z1,x2,y2,z2)
	return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1))+((z2-z1)*(z2-z1)))
end

local function distance2d(x1,y1,x2,y2)
	return sqrt((x2-x1)^2+(y2-y1)^2)
end

local function ExplodeProjectile(id, wd, x, y, z)
	spSpawnExplosion(x, y, z, 0, 0, 0, {weaponDef = wd, owner = spGetProjectileOwnerID(id), craterAreaOfEffect = WeaponDefs[wd].craterAreaOfEffect, damageAreaOfEffect = WeaponDefs[wd].damageAreaOfEffect, edgeEffectiveness = WeaponDefs[wd].edgeEffectiveness, explosionSpeed = WeaponDefs[wd].explosionSpeed, impactOnly = WeaponDefs[wd].impactOnly, ignoreOwner = WeaponDefs[wd].noSelfDamage, damageGround = true})
	spPlaySoundFile(WeaponDefs[wd].hitSound[1].name, WeaponDefs[wd].hitSound[1].volume,x,y,z, 0, 0, 0, "battle")
	spDeleteProjectile(id)
	IterableMap.Remove(projectiles, id)
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if config[weaponDefID] then
		if config[weaponDefID].type == 3 then
			IterableMap.Add(projectiles, proID, {timer = config[weaponDefID]["timer"], defid = weaponDefID})
			--spEcho("Timed demo charge for " .. proID)
		else
			IterableMap.Add(projectiles, proID, {distance = 999999999, defid = weaponDefID, targetlastposition = {}}) -- distance stored here 
		end
	end
end

function gadget:GameFrame(f)
	if f%2 == 1 then
		for id, data in IterableMap.Iterator(projectiles) do
			local wd = data.defid
			local x, y, z = spGetProjectilePosition(id)
			if x == nil then
				IterableMap.Remove(projectiles, id) -- invalid id
			elseif config[wd].type == 3 then
				data.timer = data.timer - 2
				local explode = 100 - random(10, 80) + data.timer
				if debugMode then spEcho("Explode: " .. explode) end
				if explode <= 0 then
					ExplodeProjectile(id, wd, x, y, z)
				end
			else
				local ttype,target = spGetProjectileTarget(id)
				--spEcho("Target: " .. target .. "(" .. ttype .. ")")
				if ttype == unit or ttype == feature or ttype == projectile or ttype == ground then
					local x2,y2,z2
					local vx,vy,vz = spGetProjectileVelocity(id)
					local olddistance = data.distance or 0
					if ttype == ground then
						x2 = target[1]
						y2 = target[2]
						z2 = target[3]
					elseif ttype == unit and spValidUnitID(target) then
						if not spGetUnitIsCloaked(target) then
							x2,y2,z2 = spGetUnitPosition(target, false, true)
							data.targetlastposition[1] = x2
							data.targetlastposition[2] = y2
							data.targetlastposition[3] = z2
						else
							x2 = data.targetlastposition[1]
							y2 = data.targetlastposition[2]
							z2 = data.targetlastposition[3]
						end
					elseif ttype == feature then
						x2,y2,z2 = spGetFeaturePosition(target)
					elseif ttype == projectile then
						x2,y2,z2 = spGetProjectilePosition(target)
					end
					if x2 == nil or y2 == nil or z2 == nil then
						ExplodeProjectile(id, wd, x, y, z)
					else
						if config[wd].type == 1 then
							data.distance = distance2d(x,z,x2,z2)
						else
							data.distance = distance3d(x,y,z,x2,y2,z2)
						end
						if olddistance < data.distance and data.distance >= WeaponDefs[wd].damageAreaOfEffect/2 then
							ExplodeProjectile(id, wd, x, y, z)
						end
					end
				else
					IterableMap.Remove(projectiles, id)
					spEcho("[FlakCon] Weird projectile: " .. id)
				end
			end
		end
	end
end
