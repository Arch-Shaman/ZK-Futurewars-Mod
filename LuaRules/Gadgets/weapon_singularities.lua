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

local singularities = IterableMap.New() -- {position = {x,y,z}, lifespan = frames, def = weapondefID}
local ignoreexplosion = {}

local singularitydefs = {}
local projectileMasses = {}

--local singuexplosion = {weapondef = WeaponDefNames["energysingu_singularity"].id}

local function getProjMass(weapondef)
	local cp = weapondef.customParams
	if cp.bogus and cp.projectile1 then
		return getProjMass(WeaponDefNames[cp.projectile1])
	end
	if cp.mass then
		return tonumber(cp.mass)
	end
	local baseDamage = tonumber(cp.stats_damage) or cp.shield_damage or 0
	return max(baseDamage^0.4, ((weapondef.areaOfEffect or 0)^2)/20000, weapondef.range/100, 1)
end

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	if cp and cp.singularity then
		local singuDef = {}
		singuDef.radius = tonumber(cp.singu_radius)/2
		singuDef.lifespan = tonumber(cp.singu_lifespan)
		singuDef.strength = tonumber(cp.singu_strength)
		if not (singuDef.radius and singuDef.lifespan and singuDef.strength) then
			Spring.Log(GetInfo().name, "fatal", "[weapon_singularities.lua] Weapondefs Error: invalid singularity defs for "..WeaponDefs[i].name)
		end
		singuDef.finalStrength = tonumber(cp.singu_finalstrength) or singuDef.strength * 10
		singuDef.height = tonumber(cp.singu_height) or 0
		singuDef.ceg = cp.singu_ceg
		singuDef.finalceg = cp.singu_finalceg
		singuDef.edgeEffect = tonumber(cp.singu_edgeeffect) or 0
		singuDef.baseEffect = tonumber(cp.singu_baseeffect) or 0.25
		singuDef.nodamageimmunity = cp.singu_nodamageimmunity and true or false
		singularitydefs[i] = singuDef
	end
	projectileMasses[i] = getProjMass(WeaponDefs[i])
end

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

local function GetEffect(px, py, pz, mass, data)
	mass = max(mass or 1, 0.01)
	local pos = data.position
	local dx, dy, dz = px - pos[1], py - pos[2], pz - pos[3]
	local dist = sqrt(dx*dx + dy*dy + dz*dz)
	local strength
	if data.lifespan == 1 then
		strength = data.finalStrength
	else
		strength = -data.strength
	end
	local power = ((dist/data.radius)^data.edgeEffect + data.baseEffect) * strength / mass
	local mult = power / dist
	return dx*mult, dy*mult, dz*mult
end

local function ProcessProjectiles(data, list)
	local frame = spGetGameFrame() + 1
	for i = 1, #list do
		local projectileID = list[i]
		local px, py, pz = spGetProjectilePosition(projectileID)
		if (px*px + py*py + pz*pz) <= data.radius^2 and not GetIsBeamWeapon(projectileID) then -- this is affected.
			local projectileDefID = spGetProjectileDefID(projectileID)
			if projectileDefID then
				local mass = projectileMasses[projectileDefID]
				local vx, vy, vz = spGetProjectileVelocity(projectileID)
				local ex, ey, ez = GetEffect(px, py, pz, mass, data)
				spSetProjectileVelocity(projectileID, ex + vx, ey + vy, ez + vz)
			end
		end
	end
end

local function ProcessUnits(data, list)
	for i = 1, #list do
		local unitID = list[i]
		local unitdefID = spGetUnitDefID(unitID)
		if not (UnitDefs[unitdefID].isBuilding or UnitDefs[unitdefID].isImmobile or UnitDefs[unitdefID].customParams.singuimmune) then
			local vx, vy, vz = spGetUnitVelocity(unitID)
			local px, py, pz = spGetUnitPosition(unitID)
			local mass = spGetUnitMass(unitID)
			local ex, ey, ez = GetEffect(px, py, pz, mass, data)
			GG.DetatchFromGround(unitID, 0.5, 0.1, 1)
			spSetUnitVelocity(unitID, ex + vx, ey + vy, ez + vz)
			if not data.nodamageimmunity then
				GG.SetUnitFallDamageImmunity(unitID, spGetGameFrame() + 2)
			end
		end
	end
end

local function ProcessFeatures(data, list)
	local frame = spGetGameFrame() + 1
	for i = 1, #list do
		local featureID = list[i]
		if illegalFeatureDefs[FeatureDefs[spGetFeatureDefID(featureID)].tooltip] == nil then
			local vx, vy, vz = spGetFeatureVelocity(featureID)
			local px, py, pz = spGetFeaturePosition(featureID)
			local mass = spGetFeatureMass(featureID) or 1
			local ex, ey, ez = GetEffect(px, py, pz, mass, data)
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
	if lifespan == 1 then
		--spSpawnCEG("opticblast_charge", sx, sy, sz, 0, 0, 0 , radius, 3000) -- note: radius doesn't seem to do anything here.
	elseif lifespan%15 == 0 and lifespan > 20 and data.ceg then
		spSpawnCEG(data.ceg, sx, sy, sz, 0, 0, 0 , radius, 0) -- hence why we need to make separate cegs :(
	end
	if lifespan < 20 and lifespan%4 == 0 and data.finalceg then
		spSpawnCEG(data.finalceg, sx, sy, sz, 0, 0, 0, radius, 0)
	end
	local units = spGetUnitsInSphere(sx, sy, sz, radius)
	if #units > 0 then
		ProcessUnits(data, units)
	end
	local projectiles = spGetProjectilesInRectangle(sx - radius, sz - radius, sx + radius, sz + radius, false, false)
	if #projectiles > 0 then
		ProcessProjectiles(data, projectiles)
	end
	local features = spGetFeaturesInSphere(sx, sy, sz, radius)
	if #features > 0 then
		ProcessFeatures(data, features)
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

local function AddSingularity(x, y, z, defID, defOverride)
	local n = 0
	local def = Spring.Utilities.MergeTable(singularitydefs[defID], defOverride, true)
	def.position = {[1] = x, [2] = y + def.height, [3] = z}
	repeat
		n = -math.random(1, 336559)
	until IterableMap.InMap(singularities, n) == false
	IterableMap.Add(singularities, n, def)
end

GG.AddSingularity = AddSingularity

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if singularitydefs[weaponDefID] and ProjectileID then
		local def = singularitydefs[weaponDefID]
		local bonus = (AttackerID and Spring.ValidUnitID(AttackerID) and spGetUnitRulesParam(AttackerID, "comm_damage_mult")) or 1
		AddSingularity(px, py, pz, weaponDefID, {strength = def.strength * bonus})
	end
end
