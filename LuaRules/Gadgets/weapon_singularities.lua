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

if not (gadgetHandler:IsSyncedCode()) then
	return
end

local singularities = {} -- {position = {x,y,z}, lifespan = frames, def = weapondefID}
local ignoreexplosion = {}

local singularitydefs = {}

local singuexplosion = {weapondef = WeaponDefNames["energysingu_singularity"].id}

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	if cp and cp.singularity then
		singularitydefs[i] = {radius = tonumber(cp.singuradius) or 400, lifespan = math.max(tonumber(cp.singulifespan) or 300, 10), strength = tonumber(cp.singustrength) or 20}
	end
end

local sqrt = math.sqrt
local max = math.max
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
local spGetGameFrame = Spring.GetGameFrame
local spSetFeatureMoveControl = Spring.SetFeatureMoveCtrl
local gravity = Game.gravity

local function Distance3d(x1, y1, z1, x2, y2, z2)
	return sqrt(((x2 - x1)*(x2 - x1)) + ((y2 - y1)*(y2 - y1)) + ((z2 - z1)*(z2 - z1)))
end

local function GetIsBeamWeapon(projectileID)
	local weapondef = WeaponDefs[spGetProjectileDefID(projectileID)]
	return weapondef.type == "BeamLaser"
end

local function ProcessProjectiles(sx, sy, sz, radius, strength, list, rev)
	for i = 1, #list do
		local projectileID = list[i]
		local px, py, pz = spGetProjectilePosition(projectileID)
		local distance = Distance3d(sx, px, sy, py, sz, pz)
		if distance <= radius and not GetIsBeamWeapon(projectileID) then -- this is affected.
			spSetProjectileMoveControl(projectileID, true)
			local effectstrength
			if not rev then
				effectstrength = max(distance/radius, 0.05) * strength
			else
				effectstrength = - radius/(max(distance, 0.01)) * strength * 2
			end
			local vx, vy, vz = spGetProjectileVelocity(projectileID)
			local ex, ey, ez = 0, 0, 0 -- effect's velocity change
			if sx - px >= 0 then
				ex = effectstrength
			elseif sx - px < 0 then
				ex = -effectstrength
			end
			if sy - py >= 0 then
				ey = effectstrength
			elseif sy - py < 0 then
				ey = -effectstrength
			end
			if sz - pz >= 0 then
				ez = effectstrength
			elseif sz - pz < 0 then
				ez = -effectstrength
			end
			if distance < 10 and not rev then
				vx = 0
				vy = 0
				vz = 0
			else
				vx = vx + ex
				vy = vy + ey
				vz = vz + ez
			end
			spSetProjectileVelocity(projectileID, vx, vy, vz)
			spSetProjectileGravity(projectileID, 0)
		end
		if rev then
			spSetProjectileMoveControl(projectileID, false)
			spSetProjectileGravity(projectileID, gravity)
		end
	end
end

local function ProcessUnits(sx, sy, sz, radius, strength, list, rev)
	for i = 1, #list do
		local unitID = list[i]
		local vx, vy, vz = spGetUnitVelocity(unitID)
		local ux, uy, uz = spGetUnitPosition(unitID)
		local distance = Distance3d(sx, ux, sy, uy, sz, uz)
		local effect = strength * (distance/radius)
		if not rev then
			effect = sqrt(max(radius/distance, 0.05) * strength)
		else
			if distance < 40 then
				distance = distance / 20
			end
			effect = - radius/(max(distance, 0.01)) * strength * 2
		end
		local ex, ey, ez = 0, 0, 0
		if sx - ux > 0 then
			ex = effect
		elseif sx - ux < 0 then
			ex = -effect
		end
		if sy - uy > 0 then
			ey = effect
		elseif sy - uy < 0 then
			ey = -effect
		end
		if sz - uz > 0 then
			ez = effect
		elseif sy - uy < 0 then
			ez = -effect
		end
		if distance < 10 and not rev then
			vx = 0
			vy = 0
			vz = 0
			spSetUnitVelocity(unitID, vx, vy, vz)
		--else
			--vx = vx + ex
			--vy = vy + ey
			--vz = vz + ez
		end
		Spring.AddUnitImpulse(unitID, ex, ey, ez)
		GG.SetUnitFallDamageImmunity(unitID, Spring.GetGameFrame() + 2)
		--spSetUnitVelocity(unitID, vx, vy, vz)
	end
end

local function ProcessFeatures(sx, sy, sz, radius, strength, list, rev)
	for i = 1, #list do
		local featureID = list[i]
		local vx, vy, vz = 0, 0, 0
		local ux, uy, uz = spGetFeaturePosition(featureID)
		local ex, ey, ez = 0, 0, 0
		local distance = Distance3d(sx, ux, sy, uy, sz, uz)
		local effect = strength * (distance/radius)
		if not rev then
			effect = sqrt(max(radius/distance, 0.05) * strength)
			spSetFeatureMoveControl(featureID,false,1,1,1,1,1,1,1,1,1)
			spSetFeatureMoveControl(featureID,true,0,1,0)
		else
			if distance < 40 then
				distance = distance / 20
			end
			effect = - radius/(max(distance, 0.01)) * strength
		end
		local ex, ey, ez = 0, 0, 0
		spSetFeatureMoveControl(featureID, true)
		if sx - ux > 0 then
			ex = effect
		elseif sx - ux < 0 then
			ex = -effect
		end
		if sy - uy > 0 then
			ey = effect
		elseif sy - uy < 0 then
			ey = -effect
		end
		if sz - uz > 0 then
			ez = effect
		elseif sy - uy < 0 then
			ez = -effect
		end
		spSetFeatureVelocity(featureID, ex, ey, ez)
		if rev then
			spSetFeatureMoveControl(featureID,false,0,0,0,0,0,0,0,0,0)
		end
		--spSetUnitVelocity(unitID, vx, vy, vz)
	end
end

local function ProcessSingularity(singu)
	local sx = singularities[singu].position[1]
	local sy = singularities[singu].position[2]
	local sz = singularities[singu].position[3]
	local lifespan = singularities[singu].lifespan
	local radius = singularities[singu].radius
	local strength = singularities[singu].strength
	if lifespan == 1 then
		Spring.SpawnCEG("opticblast_charge", sx, sy, sz, 0, 0, 0 , radius, 3000)
	elseif lifespan%15 == 0 and lifespan > 20 then
		Spring.SpawnCEG("black_hole_singu", sx, sy, sz, 0, 0, 0 , radius, 0)
	end
	if lifespan < 20 and lifespan%4 == 0 then
		Spring.SpawnCEG("riotballgrav", sx, sy, sz, 0, 0, 0, radius, 0)
	end
	local units = spGetUnitsInSphere(sx, sy, sz, radius)
	if #units > 0 then
		ProcessUnits(sx, sy, sz, radius, strength, units, lifespan == 0)
	end
	local projectiles = spGetProjectilesInRectangle(sx - radius, sz - radius, sx + radius, sz + radius, false, false)
	if #projectiles > 0 then
		ProcessProjectiles(sx, sy, sz, radius, strength, projectiles, lifespan == 0)
	end
	local features = spGetFeaturesInSphere(sx, sy, sz, radius)
	if #features > 0 then
		ProcessFeatures(sx, sy, sz, radius, strength, features, lifespan == 0)
	end
	if lifespan%30 == 0 then
		Spring.Echo("Projectiles: " .. #projectiles .. ", " .. #features) 
	end
end
	

function gadget:GameFrame(f)
	for id, data in pairs(singularities) do
		if data.lifespan > 0 then
			ProcessSingularity(id)
			data.lifespan = data.lifespan - 1
			if data.lifespan%30 == 0 and data.lifespan > 50 then
				Spring.PlaySoundFile("sounds\\blackholeloop.ogg", 15, data.position[1], data.position[2], data.position[3])
			elseif data.lifespan == 15 then
				Spring.PlaySoundFile("sounds\\blackhole_final.ogg", 30, data.position[1], data.position[2], data.position[3])
			elseif data.lifespan == 1 then
				Spring.PlaySoundFile("sounds\\explosions\\ex_burn1.wav", 12, data.position[1], data.position[2], data.position[3])
			end
		else
			singularities[id] = nil
		end
	end
end

local function AddSingularity(x, y, z, strength, radius, lifespan)
	local n = 0
	repeat
		n = -math.random(1, 336559)
	until singularities[n] == nil
	singularities[n] = {position = {[1] = x, [2] = y, [3] = z}, lifespan = lifespan, strength = strength, radius = radius}
end

GG.AddSingularity = AddSingularity

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if singularitydefs[weaponDefID] and ProjectileID then
		singularities[ProjectileID] = {position = {[1] = px, [2] = py + 200, [3] = pz}, lifespan = singularitydefs[weaponDefID].lifespan, strength = singularitydefs[weaponDefID].strength, radius = singularitydefs[weaponDefID].radius}
	end
end