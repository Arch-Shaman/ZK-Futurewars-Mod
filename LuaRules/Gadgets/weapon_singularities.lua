if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Singularities",
		desc      = "Sucked up, spit out.",
		author    = "Shaman",
		date      = "10-22-2020",
		license   = "PD",
		layer     = 0,
		enabled   = true,
	}
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

local singularities = IterableMap.New() -- {position = {x,y,z}, lifespan = frames, def = weapondefID}
local ignoreexplosion = {}

local singularitydefs = {}

--local singuexplosion = {weapondef = WeaponDefNames["energysingu_singularity"].id}

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	if cp and cp.singularity then
		singularitydefs[i] = {radius = (tonumber(cp.singuradius) or 400)/2, lifespan = math.max(tonumber(cp.singulifespan) or 300, 10), strength = tonumber(cp.singustrength) or 20, height = tonumber(cp.singuheight) or 0, ceg = cp.singuceg or 'black_hole_singu', finalceg = cp.singufinalceg or 'riotballgrav'}
		singularitydefs[i].push = singularitydefs[i].strength < 0
	end
end

local sqrt = math.sqrt
local max = math.max
local min = math.min
local abs = math.abs
local spGetProjectilePosition = Spring.GetProjectilePosition
local spGetProjectileVelocity = Spring.GetProjectileVelocity
local spGetProjectileDefID = Spring.GetProjectileDefID
local spSetProjectileVelocity = Spring.SetProjectileVelocity
local spGetUnitsInSphere = Spring.GetUnitsInSphere
local spSetUnitVelocity = Spring.SetUnitVelocity
local spGetUnitVelocity = Spring.GetUnitVelocity
local spGetUnitPosition = Spring.GetUnitPosition
local spGetProjectilesInRectangle = Spring.GetProjectilesInRectangle
local spSetProjectileMoveControl = Spring.SetProjectileMoveControl
local spSetProjectileGravity = Spring.SetProjectileGravity
local spGetFeaturesInSphere = Spring.GetFeaturesInSphere
local spGetFeaturePosition = Spring.GetFeaturePosition
local spSetFeatureVelocity = Spring.SetFeatureVelocity
local spGetFeatureVelocity = Spring.GetFeatureVelocity
local spGetGameFrame = Spring.GetGameFrame
local spSetFeatureMoveControl = Spring.SetFeatureMoveCtrl
local spGetUnitMass = Spring.GetUnitMass
local spGetFeatureMass = Spring.GetFeatureMass
local spEcho = Spring.Echo
local spGetUnitDefID = Spring.GetUnitDefID
local gravity = Game.gravity
local spSpawnCEG = Spring.SpawnCEG
local spPlaySoundFile = Spring.PlaySoundFile
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetFeatureDefID = Spring.GetFeatureDefID

local projectiles = {}

local illegalFeatureDefs = {
	["Metal Vein"] = true,
	["Coagulation Node"] = true,
	["contains metal"] = true, -- Zed
} -- Some maps have metal spot markers. Don't mess with these.

local function Distance3d(x1,y1,z1,x2,y2,z2) -- TODO: make this the spring utilities thing.
	return sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2) + (z1 - z2)*(z1 - z2))
end

local function GetIsBeamWeapon(projectileID)
	local weapondef = WeaponDefs[spGetProjectileDefID(projectileID)]
	if weapondef == nil or weapondef.type == nil then -- fix for death particle things
		return false
	end
	return weapondef.type == "BeamLaser" or weapondef.customParams.singuimmune ~= nil
end

local function GetEffectStrength(radius, strength, distance, mass)
	local mass = mass or 1
	local strength = strength
	if mass <= 1 then
		strength = strength/30 -- convert from elmo/sec
	end
	mass = max(mass, 0.01) -- prevent divbyzero
	local distance = max(distance, 0.01) -- gate to prevent divbyzero
	return min(((radius/distance) * strength)^(0.95), 2 * strength) / mass
end

local function GetFinalEffectStrength(radius, strength, distance, mass)
	local strength = strength
	if mass <= 1 then
		strength = 10 -- affect projectiles weakly.
	end
	local distance = max(distance, 0.01)
	return max(- ((radius/distance) * strength)^(0.95), -2 * strength) / mass
end

local function ProcessProjectiles(sx, sy, sz, radius, strength, list, rev)
	local frame = spGetGameFrame() + 1
	for i = 1, #list do
		local projectileID = list[i]
		local px, py, pz = spGetProjectilePosition(projectileID)
		local distance = Distance3d(sx, sy, sz, px, py, pz)
		--local radiussqr = radius * radius -- no idea why this was sqr.
		--spEcho("Distance: " .. distance .. "\nBeamWeapon: " .. tostring(GetIsBeamWeapon(projectileID)))
		if distance <= radius and not GetIsBeamWeapon(projectileID) then -- this is affected.
			local projectileDefID = spGetProjectileDefID(projectileID)
			if projectileDefID then
				local cp = WeaponDefs[projectileDefID].customParams
				if cp.bogus and cp.projectile1 then -- fake projectiles need their real projectile mass.
					cp = WeaponDefNames[cp.projectile1]
				end
				local mass = tonumber(cp.mass) or 1
				--spSetProjectileMoveControl(projectileID, true)
				local vx, vy, vz = spGetProjectileVelocity(projectileID)
				--spEcho("projectileID: " .. projectileID .. "\nVelocity: " .. vx .. "," .. vy .. "," .. vz)
				local ex, ey, ez = 0, 0, 0 -- effect's velocity change
				if rev then
					ex = GetFinalEffectStrength(radius, strength, abs(sx - px), mass)
					ey = GetFinalEffectStrength(radius, strength, abs(sy - py), mass)
					ez = GetFinalEffectStrength(radius, strength, abs(sz - pz), mass)
				else
					ex = GetEffectStrength(radius, strength, abs(sx - px), mass)
					ey = GetEffectStrength(radius, strength, abs(sy - py), mass)
					ez = GetEffectStrength(radius, strength, abs(sz - pz), mass)
				end
				if sx - px < 0 then
					ex = - ex
				elseif sx - px == 0 and not rev then
					ex = 0
					vx = 0
				end
				if sy - py < 0 then
					ey = - ey
				elseif sy - py == 0 and not rev then
					ey = 0
					vy = 0
				end
				if sz - pz < 0 then
					ez = -ez
				elseif sz - pz == 0 and not rev then
					ez = 0
					vz = 0
				end
				spSetProjectileVelocity(projectileID, ex + vx, ey + vy, ez + vz)
				--spSetProjectileGravity(projectileID, -ey)
				--projectiles[projectileID] = frame
			end
		end
	end
end

local function ProcessUnits(sx, sy, sz, radius, strength, list, rev)
	for i = 1, #list do
		local unitID = list[i]
		local vx, vy, vz = spGetUnitVelocity(unitID)
		local px, py, pz = spGetUnitPosition(unitID)
		local ex, ey, ez = 0, 0, 0 -- effect's velocity change
		local gy = Spring.GetGroundHeight(px, pz)
		local mass = spGetUnitMass(unitID)
		local unitdefID = spGetUnitDefID(unitID)
		if not (UnitDefs[unitdefID].isBuilding or UnitDefs[unitdefID].isImmobile or UnitDefs[unitdefID].customParams.singuimmune) then
			if rev then
				ex = GetFinalEffectStrength(radius, strength, abs(sx - px), mass)
				ey = GetFinalEffectStrength(radius, strength, abs(sy - py), mass)
				ez = GetFinalEffectStrength(radius, strength, abs(sz - pz), mass)
			else
				ex = GetEffectStrength(radius, strength, abs(sx - px), mass)
				ey = GetEffectStrength(radius, strength, abs(sy - py), mass)
				ez = GetEffectStrength(radius, strength, abs(sz - pz), mass)
			end
			if sx - px < 0 then
				ex = - ex
			end
			if sy - py < 0 then
				ey = - ey
			end
			if sz - pz < 0 then
				ez = -ez
			end
			--spEcho("Wanted velocity: " .. ex .. "," .. ey .. "," .. ez)
			GG.DetatchFromGround(unitID, 0.5, 0.1, 1)
			spSetUnitVelocity(unitID, ex + vx, ey + vy, ez + vz)
			GG.SetUnitFallDamageImmunity(unitID, spGetGameFrame() + 2)
			--spSetUnitVelocity(unitID, vx, vy, vz)
		end
	end
end

local function ProcessFeatures(sx, sy, sz, radius, strength, list, rev, sid)
	local frame = spGetGameFrame() + 1
	for i = 1, #list do
		local featureID = list[i]
		if illegalFeatureDefs[FeatureDefs[spGetFeatureDefID(featureID)].tooltip] == nil then
			local vx, vy, vz = spGetFeatureVelocity(featureID)
			local px, py, pz = spGetFeaturePosition(featureID)
			local ex, ey, ez = 0, 0, 0
			local mass = spGetFeatureMass(featureID) or 1
			if rev then
				ex = GetFinalEffectStrength(radius, strength, abs(sx - px), mass)
				ey = GetFinalEffectStrength(radius, strength, abs(sy - py), mass)
				ez = GetFinalEffectStrength(radius, strength, abs(sz - pz), mass)
			else
				ex = GetEffectStrength(radius, strength, abs(sx - px), mass)
				ey = GetEffectStrength(radius, strength, abs(sy - py), mass)
				ez = GetEffectStrength(radius, strength, abs(sz - pz), mass)
			end
			if sx - px < 0 then
				ex = - ex
			elseif sx - px == 0 and not rev then
				ex = 0
				vx = 0
			end
			if sy - py < 0 then
				ey = - ey
			elseif sy - py == 0 and not rev then
				ey = 0
				vy = 0
			end
			if sz - pz < 0 then
				ez = -ez
			elseif sz - pz == 0 and not rev then
				ez = 0
				vz = 0
			end
			spSetFeatureMoveControl(featureID,false,1,1,1,1,1,1,1,1,1)
			spSetFeatureVelocity(featureID, ex + vx, ey + vy, ez + vz)
		end
	end
end

local function ProcessSingularity(singu, data)
	--local data = IterableMap.Get(singularities, singu)
	local sx = data.position[1]
	local sy = data.position[2]
	local sz = data.position[3]
	local lifespan = data.lifespan
	local radius = data.radius
	local strength = data.strength
	local ceg = data.ceg
	local finalceg = data.finalceg
	local push = strength < 0
	local finale = lifespan == 0
	if strength < 0 then
		strength = -strength
	end
	if lifespan == 1 then
		--spSpawnCEG("opticblast_charge", sx, sy, sz, 0, 0, 0 , radius, 3000) -- note: radius doesn't seem to do anything here.
	elseif lifespan%15 == 0 and lifespan > 20 then
		spSpawnCEG(ceg, sx, sy, sz, 0, 0, 0 , radius, 0) -- hence why we need to make separate cegs :(
	end
	if lifespan < 20 and lifespan%4 == 0 then
		spSpawnCEG(finalceg, sx, sy, sz, 0, 0, 0, radius, 0)
	end
	local units = spGetUnitsInSphere(sx, sy, sz, radius)
	if #units > 0 then
		ProcessUnits(sx, sy, sz, radius, strength, units, finale or push)
	end
	local projectiles = spGetProjectilesInRectangle(sx - radius, sz - radius, sx + radius, sz + radius, false, false)
	if #projectiles > 0 then
		ProcessProjectiles(sx, sy, sz, radius, strength, projectiles, finale or push)
	end
	local features = spGetFeaturesInSphere(sx, sy, sz, radius)
	if #features > 0 then
		ProcessFeatures(sx, sy, sz, radius, strength, features, finale or push)
	end
	--if lifespan%30 == 0 then
		--Spring.Echo("Projectiles: " .. #projectiles .. ", " .. #features) 
	--end
end
	

function gadget:GameFrame(f)
	for id, data in IterableMap.Iterator(singularities) do
		if data.lifespan > 0 then
			ProcessSingularity(id, data)
			data.lifespan = data.lifespan - 1
			if data.lifespan%30 == 0 and data.lifespan > 50 then
				spPlaySoundFile("sounds\\blackholeloop.ogg", 15, data.position[1], data.position[2], data.position[3], 0, 0, 0, "battle")
			elseif data.lifespan == 15 then
				spPlaySoundFile("sounds\\blackhole_final.ogg", 30, data.position[1], data.position[2], data.position[3], 0, 0, 0, "battle")
			elseif data.lifespan == 1 then
				--spPlaySoundFile("sounds\\explosions\\ex_burn1.wav", 12, data.position[1], data.position[2], data.position[3]) -- needs replacement file?
			end
		else
			IterableMap.Remove(singularities, id)
		end
	end
	--for projectile, frame in pairs(projectiles) do
		--if f == frame then
			--projectiles[projectile] = nil
			--spSetProjectileGravity(projectile, gravity)
			--spSetProjectileMoveControl(projectile, false)
		--end
	--end
end

local function AddSingularity(x, y, z, strength, radius, lifespan, ceg, finalceg)
	local n = 0
	ceg = ceg or 'black_hole_singu'
	finalceg = finalceg or 'riotballgrav'
	repeat
		n = -math.random(1, 336559)
	until IterableMap.InMap(singularities, n) == false
	IterableMap.Add(singularities, n, {position = {[1] = x, [2] = y, [3] = z}, lifespan = lifespan, strength = strength, radius = radius, ceg = ceg, finalceg = finalceg})
end

GG.AddSingularity = AddSingularity

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if singularitydefs[weaponDefID] and ProjectileID then
		local def = singularitydefs[weaponDefID]
		local bonus = (AttackerID and Spring.ValidUnitID(AttackerID) and spGetUnitRulesParam(AttackerID, "comm_damage_mult")) or 1
		IterableMap.Add(singularities, ProjectileID, {position = {[1] = px, [2] = py + def.height, [3] = pz}, lifespan = def.lifespan, strength = def.strength * bonus, radius = def.radius, ceg = def.ceg, finalceg = def.finalceg})
	end
end
