if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Chain Lightning",
		desc      = "Lightning that chains to other targets.",
		author    = "Shaman",
		date      = "13.10.2022",
		license   = "CC-0",
		layer     = 0,
		enabled   = true,
	}
end

local config = {}
local wantedWeapons = {}

local spGetFeaturesInSphere        = Spring.GetFeaturesInSphere 
local spGetUnitsInSphere           = Spring.GetUnitsInSphere
local spGetUnitPosition            = Spring.GetUnitPosition
local spGetFeaturePosition         = Spring.GetFeaturePosition
local spGetUnitAllyTeam            = Spring.GetUnitAllyTeam
local spGetUnitsInBox              = Spring.GetUnitsInBox
local spSpawnSFX                   = Spring.SpawnSFX
local spGetUnitDefID               = Spring.GetUnitDefID
local spGetUnitCollisionVolumeData = Spring.GetUnitCollisionVolumeData
local spGetFeatureCollisionVolumeData = Spring.GetFeatureCollisionVolumeData
--local spSpawnProjectile            = Spring.SpawnProjectile 
local spGetUnitWeaponTarget        = Spring.GetUnitWeaponTarget

local debugMode = false
local subProjectileDefs = {}
local invalidFeatures = {}

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	if cp.chainlightning_index then
		wantedWeapons[#wantedWeapons + 1] = i
		config[i] = {
			targetSearchDistance = tonumber(cp.chainlightning_searchdist),
			maxTargets = tonumber(cp.chainlightning_maxtargets),
			friendlyFire = cp.chainlightning_ff == nil,
			weaponIndex = tonumber(cp.chainlightning_index),
			forksub = cp.chainlightning_sub ~= nil,
			weaponNum = tonumber(cp.chainlightning_num) or 1,
			canTargetFeature = cp.chainlightning_donttargetfeature == nil,
		}
		Spring.Echo("[ChainLightning] Added " .. i)
		Script.SetWatchExplosion(i, true)
		if config[i].forksub then
			subProjectileDefs[i] = true
		end
	end
end

for i = 1, #FeatureDefs do
	local name = FeatureDefs[i].description
	if string.find(name, "Shards") or string.find(name, "Debris -") or name == "Metal Vein" or name == "Coagulation Node" or name == "contains metal" then
		invalidFeatures[i] = true
	elseif FeatureDefs[i].damage > 1000000 then -- probably some untargetable thing
		invalidFeatures[i] = true
	end
end

function gadget:Explosion_GetWantedWeaponDef()
	return wantedWeapons
end

local function GetValidTargets(x, y, z, radius, allowFriendlyFire, attackerTeam, disallowedUnitIDs)
	local potentialTargets = spGetUnitsInSphere(x, y, z, radius)
	local validTargets = {}
	for i = 1, #potentialTargets do
		local unitID = potentialTargets[i]
		if not disallowedUnitIDs[unitID] then
			if allowFriendlyFire then
				validTargets[#validTargets + 1] = unitID
			else
				if spGetUnitAllyTeam(unitID) == attackerTeam then
					disallowedUnitIDs[unitID] = true
				else
					validTargets[#validTargets + 1] = unitID
				end
			end
		end
	end
	return validTargets, disallowedUnitIDs
end

local function GetValidFeatureTargets(x, y, z, radius, disallowedFeatureIDs) 
	local potentialTargets = spGetFeaturesInSphere(x, y, z, radius)
	local validTargets = {}
	for i = 1, #potentialTargets do
		local featureID = potentialTargets[i]
		if not disallowedFeatureIDs[featureID] then
			if invalidFeatures[Spring.GetFeatureDefID(featureID)] then
				disallowedFeatureIDs[featureID] = true
			else
				validTargets[#validTargets + 1] = featureID
			end
		end
	end
	return validTargets, disallowedFeatureIDs
end

local function PointToDir(targetX, targetY, targetZ, originX, originY, originZ)
	local vx = originX - targetX 
	local vy = originY - targetY
	local vz = originZ - targetZ -- points -> vector
	local mag = math.sqrt(vx * vx + vy * vy + vz * vz)
	return vx / mag, vy / mag, vz / mag
end

local function Distance(x, z, x2, z2)
	return math.sqrt((x2 - x) * (x2 - x) + (z2 - z) * (z2 - z) )
end

local function GetPointOutsideOfColvol(target, dirX, dirY, dirZ)
	Spring.Echo("Dir: " .. dirX .. ", " .. dirY .. ", " .. dirZ)
	local _, _, _, cx, cy, cz = spGetUnitPosition(target, true) -- midpos position
	local scaleX, scaleY, scaleZ, offX, offY, offZ = spGetUnitCollisionVolumeData(target)
	cx, cy, cz = cx + offX, cy + offY, cz + offZ
	scaleX = scaleX / 2 + 1 -- take half the scale, add 0.5
	scaleY = scaleY / 2 + 1
	scaleZ = scaleZ / 2 + 1
	--Spring.MarkerAddPoint(cx + (scaleX * dirX), cy + (scaleY * dirY), cz + (scaleZ * dirZ), "v", true)
	return cx + (scaleX * dirX), cy + (scaleY * dirY), cz + (scaleZ * dirZ)
end

local function GetPointOutsideOfFeatureColvol(featureID, dirX, dirY, dirZ)
	Spring.Echo("Dir: " .. dirX .. ", " .. dirY .. ", " .. dirZ)
	local _, _, _, cx, cy, cz = spGetFeaturePosition(featureID, true) -- base position
	local scaleX, scaleY, scaleZ, offX, offY, offZ = spGetFeatureCollisionVolumeData(featureID)
	cx, cy, cz = cx + offX, cy + offY, cz + offZ
	scaleX = scaleX / 2 + 1 -- take half the scale so we're outside of the colvol and add 1.
	scaleY = scaleY / 2 + 1
	scaleZ = scaleZ / 2 + 1
	if debugMode then
		Spring.MarkerAddPoint(cx + (scaleX * dirX), cy + (scaleY * dirY), cz + (scaleZ * dirZ), dirY, true)
	end
	return cx + (scaleX * dirX), cy + (scaleY * dirY), cz + (scaleZ * dirZ)
end


local function SpawnLightning(attackerID, index, x, y, z, targetX, targetY, targetZ, dirx, diry, dirz)
	dirx, diry, dirz = PointToDir(x, y, z, targetX, targetY, targetZ)
	if debugMode then
		Spring.Echo("Chain Lightning: Spawning using weaponIndex ", index)
		Spring.MarkerAddLine(x, y, z, targetX, targetY, targetZ)
	end
	if Distance(x, z, targetX, targetZ) <= 5 then
		spSpawnSFX(attackerID, 2047 + index, targetX, targetY, targetZ, 1, 1, 1, true)
	else
		spSpawnSFX(attackerID, 2047 + index, x, y, z, dirx, diry, dirz, true)
	end
end

local function GetDirectionFromSomething(targetID, originX, originY, originZ, isFeature)
	local targetX, targetY, targetZ
	if not isFeature then
		_, _, _, targetX, targetY, targetZ = spGetUnitPosition(targetID, true)
	else
		_, _, _, targetX, targetY, targetZ = spGetFeaturePosition(targetID, true)
	end
	local dirx, diry, dirz = PointToDir(originX, originY, originZ, targetX, targetY, targetZ)
	return targetX, targetY, targetZ, dirx, diry, dirz
end

local function DoChainLightning(weaponDefID, px, py, pz, AttackerID, damagedUnit, isFeature)
	local c = config[weaponDefID]
	if debugMode then
		Spring.Echo("DoChainLightning: ", px, py, pz, AttackerID, damagedUnit, isFeature)
	end
	local attackerTeam = spGetUnitAllyTeam(AttackerID)
	local badTargets = {}
	local badFeatures = {}
	if damagedUnit and not isFeature then
		badTargets[damagedUnit] = true
		_, _, _, px, py, pz = spGetUnitPosition(damagedUnit, true)
	elseif damagedUnit and isFeature then
		px, py, pz = spGetFeaturePosition(damagedUnit)
		badFeatures[damagedUnit] = true
	end
	local potentialTargets, potentialFeatures = {}, {}
	local canTargetFeatures = c.canTargetFeature
	for targetNum = 1, c.maxTargets do
		potentialTargets, badTargets = GetValidTargets(px, py, pz, c.targetSearchDistance, c.friendlyFire, attackerTeam, badTargets)
		if canTargetFeatures then
			potentialFeatures, badFeatures = GetValidFeatureTargets(px, py, pz, c.targetSearchDistance, badFeatures)
		end
		local x2, y2, z2, dirx, diry, dirz
		local sx, sy, sz, newTarget, targetFeature
		if #potentialTargets > 0 and (not canTargetFeatures or #potentialFeatures == 0) then
			newTarget = potentialTargets[math.random(1, #potentialTargets)]
			badTargets[newTarget] = true
			targetFeature = false
			if debugMode then
				Spring.Echo("ChainLightning DoChainLightning: Target " .. targetNum .. ": " .. newTarget)
			end
		elseif #potentialTargets > 0 and (canTargetFeatures and #potentialFeatures > 0) then -- pick a feature or target at random
			local fChance = 1 - (#potentialFeatures / (#potentialTargets + #potentialFeatures)) -- chance to pick a feature instead of a unit
			if math.random() * 100 >= fChance then -- we picked a feature.
				newTarget = potentialFeatures[math.random(1, #potentialFeatures)]
				badFeatures[newTarget] = true
				targetFeature = true
			else
				newTarget = potentialTargets[math.random(1, #potentialTargets)]
				badTargets[newTarget] = true
				targetFeature = false
			end
		elseif #potentialTargets == 0 and canTargetFeatures and #potentialFeatures > 0 then -- pick a feature at random
			newTarget = potentialFeatures[math.random(1, #potentialFeatures)]
			badFeatures[newTarget] = true
			targetFeature = true
		else -- nothing left.
			if debugMode then Spring.Echo("Breaking due to no valid targets") end
			return
		end
		x2, y2, z2, dirx, diry, dirz = GetDirectionFromSomething(newTarget, px, py, pz, targetFeature)
		if damagedUnit then
			if isFeature then
				sx, sy, sz = GetPointOutsideOfFeatureColvol(damagedUnit, dirx, diry, dirz)
			else
				sx, sy, sz = GetPointOutsideOfColvol(damagedUnit, dirx, diry, dirz)
			end
		else
			sx, sy, sz = px, py, pz
		end
		if sx == nil then
			Spring.Echo("ChainLightning: Fallback due to nil sx")
			sx, sy, sz = px, py, pz
		end
		SpawnLightning(AttackerID, c.weaponIndex, sx, sy, sz, x2, y2, z2, dirx, diry, dirz)
	end
end

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if debugMode then
		Spring.Echo("Chainlightning: Explosion: ", px, py, pz, AttackerID, ProjectileID)
	end
	local num, _, target = spGetUnitWeaponTarget(AttackerID, config[weaponDefID].weaponNum)
	if subProjectileDefs[weaponDefID] then -- we can't rely on checking target (for obvious reasons, we're not actually aiming at any of these sub targets!)
		local potentialUnits = spGetUnitsInSphere(px, py, pz, 30) -- did we hit another unit?
		if potentialUnits and #potentialUnits > 0 then
			DoChainLightning(weaponDefID, px, py, pz, AttackerID, potentialUnits[1])
			return false
		end
		local potentialFeatures = Spring.GetFeaturesInSphere(px, py, pz, 20) -- did we unintentionally hit a feature?
		if potentialFeatures and #potentialFeatures > 0 then
			local x, y, z = spGetFeaturePosition(potentialFeatures[1], true)
			DoChainLightning(weaponDefID, x, y, z, AttackerID, potentialFeatures[1], true)
			return false
		end
		-- probably a shield?
		return false
	elseif num == 1 then
		local ux, uy, uz = spGetUnitPosition(target)
		if not ux then
			Spring.Echo("[ChainLightning]: Invalid UnitID!")
			return false
		end
		local d = math.sqrt(((px - ux) * (px - ux)) + ((pz - uz) * (pz - uz)))
		if d < 15 then -- this is probably a direct hit.
			local _, _, _, x, y, z = spGetUnitPosition(target, true)
			DoChainLightning(weaponDefID, x, y, z, AttackerID, target, false)
			return false
		else
			local potentialUnits = spGetUnitsInSphere(px, py, pz, 30) -- did we hit another unit unintentionally?
			if potentialUnits and #potentialUnits > 0 then
				DoChainLightning(weaponDefID, px, py, pz, AttackerID, potentialUnits[1], false)
				return false
			end
			local potentialFeatures = Spring.GetFeaturesInSphere(px, py, pz, 20) -- did we unintentionally hit a feature?
			if potentialFeatures and #potentialFeatures > 0 then
				--local x, y, z = spGetFeaturePosition(potentialFeatures[1], true)
				DoChainLightning(weaponDefID, px, py, pz, AttackerID, potentialFeatures[1], true)
				return false
			end
			-- probably a shield?
			return false
		end
	else
		DoChainLightning(weaponDefID, px, py, pz, AttackerID, nil, false)
		return false
	end
end

--[[function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if subProjectileDefs[weaponDefID] then
		--Spring.Echo("ChainLightning: UnitPreDamaged")
		local x, y, z = spGetUnitPosition(unitID, true)
		DoChainLightning(weaponDefID, x, y, z, attackerID, unitID)
	end
end]]
