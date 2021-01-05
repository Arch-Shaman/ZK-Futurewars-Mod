function gadget:GetInfo()
	return {
		name      = "Grenades",
		desc      = "Implements bounce off projectiles",
		author    = "Shaman",
		date      = "12/19/2020",
		license   = "CC-0",
		layer     = 1,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local spSetProjectileVelocity = Spring.SetProjectileVelocity
local spGetProjectileVelocity = Spring.GetProjectileVelocity
local spGetProjectileCollsion = GG.GetProjectileCollision
local spGetProjectileDirection = Spring.GetProjectileDirection
local spGetProjectilePosition = Spring.GetProjectilePosition
local spSpawnExplosion = Spring.SpawnExplosion
local spGetUnitsInSphere = Spring.GetUnitsInSphere
local spDestroyProjectile = Spring.DeleteProjectile
local spGetUnitPosition = Spring.GetUnitPosition


local tan = math.tan
local atan = math.atan
local abs = math.abs
local sqrt = math.sqrt

local config = {}
local projectiles = {} -- {ttl = somenumber
local explosionbase = {}
local cache = {}

for i = 1, #WeaponDefs do
	local wep = WeaponDefs[i].customParams
	if wep.grenade_ttl then
		config[i] = {}
		config[i].bouncefactor = tonumber(wep.grenade_bouncefactor) or 1 -- total momentum absorbed by impact.
		config[i].ttl = tonumber(wep.grenade_ttl) or 300 -- 10 seconds
		config[i].bouncecost = tonumber(wep.grenade_bouncecost) or 30
		config[i].weaponnum = tonumber(wep.grenade_weaponnum) -- needed.
		explosionbase[i] = {
			weaponDef = i,
			owner = 0,
			edgeEffectiveness = WeaponDefs[i].edgeEffectiveness,
			explosionSpeed = WeaponDefs[i].explosionSpeed,
			damageGround = true,
			ignoreOwner = false,
			impactOnly = false,
			--damages = {}
		}
		--[[for name, value in pairs(WeaponDefs[i].damages) do
			Spring.Echo(name .. ": " .. value)
			if tonumber(name) == nil then
				explosionbase[i].damages[name] = value
			end
		end]]
		Script.SetWatchWeapon(i, true)
	end
end

--[[reflection_normal = projectile_bounce_point - unit_centre
reflected_v = 2 * Dot(reflection_normal, V) * reflection_normal - V]]

local function GetTTL(proID)
	return projectiles[proID].ttl or 0
end

GG.GetProjectileTTL = GetTTL

local function Dot(v1, v2)
	if v1[3] then
		return v1[1]*v2[1] + v1[2]*v2[2] + v1[3]*v2[3]
	else
		return v1[1]*v2[1] + v1[2]*v2[2]
	end
end

local function GetAngle(vx, vz)
	return atan(vz / vx)
end

local function GetTotalVelocity(vx, vy, vz)
	return sqrt((vx * vx) + (vz * vz) + (vy * vy))
end


local function ProjectileCollision(proID, unitID, px, py, pz, ttl)
	local weapondef = projectiles[proID].weapondef
	local vx, vy, vz = spGetProjectileVelocity(proID)
	local ux, uy, uz = spGetUnitPosition(unitID)
	local bounceefficiency = config[weapondef].bouncefactor
	local normal = {[1] = px - ux, [2] = py - uy, [3] = pz - uz}
	local squareroot = sqrt(Dot(normal, normal))
	local speed = GetTotalVelocity(vx, vy, vz)
	for i = 1, 3 do
		normal[i] = (normal[i] / squareroot)
	end
	local normalv = {[1] = vx / speed, [2] = vy / speed, [3] = vz / speed}
	local normaldot = 2 * Dot(normal, normalv) -- optimization
	local nx = (normaldot * normal[1] - normalv[1]) * (bounceefficiency * speed)
	local ny = (normaldot * normal[2] - normalv[2]) * (bounceefficiency * speed)
	local nz = (normaldot * normal[3] - normalv[3]) * (bounceefficiency * speed)
	spSetProjectileVelocity(proID, nx, ny, nz)
	projectiles[proID].ttl = ttl - config[weapondef].bouncecost
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if config[weaponDefID] then
		local config = config[weaponDefID]
		projectiles[proID] = {ttl = config.ttl, weapondef = weaponDefID, owner = proOwnerID}
	end
end

function gadget:ProjectileDestroyed(proID)
	projectiles[proID] = nil
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if config[weaponDefID] then
		Spring.Echo("Predamage grenade: " ..damage)
	end
end

function gadget:GameFrame(f)
	for id, data in pairs(projectiles) do
		projectiles[id].ttl = projectiles[id].ttl - 1
		local x, y, z = spGetProjectilePosition(id)
		local vx, vy, vz = spGetProjectileVelocity(id)
		local velocity = GetTotalVelocity(vx, vy, vz)
		Spring.Echo(id .. ": " .. data.ttl .. "/" .. velocity)
		if data.ttl - 1 == 0 or data.ttl < 0 then
			Spring.Echo("Boom")
			local dx, dy, dz = spGetProjectileDirection(id)
			local explosionparams = explosionbase[data.weapondef]
			explosionparams.owner = data.owner
			spSpawnExplosion(x, y, z, dx, dy, dz, explosionparams)
			spDestroyProjectile(proID)
			projectiles[proID] = nil
		else
			local units = spGetUnitsInSphere(x, y, z, velocity + 10)
			if #units > 0 then
				if units[1] ~= data.owner then
					ProjectileCollision(id, units[1], x, y, z, data.ttl)
					Spring.Echo("Bounce")
				elseif #units > 1 then
					ProjectileCollision(id, units[1], x, y, z, data.ttl)
					Spring.Echo("Bounce")
				end
			end
		end
	end
end
