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
local spSpawnProjectile            = Spring.SpawnProjectile 
local spGetUnitWeaponTarget        = Spring.GetUnitWeaponTarget
local spGetFeatureDefID            = Spring.GetFeatureDefID

local debugMode = false
local subProjectileDefs = {}
local invalidFeatures = {}
local invalidDefs = {}

for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	if ud.customParams and ud.customParams.dontkill then
		invalidDefs[i] = true
	end
end

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	if cp.chainlightning_index or cp.chainlightning_spawndef then
		wantedWeapons[#wantedWeapons + 1] = i
		config[i] = {
			targetSearchDistance = tonumber(cp.chainlightning_searchdist),
			maxTargets = tonumber(cp.chainlightning_maxtargets),
			friendlyFire = cp.chainlightning_ff == nil,
			weaponIndex = tonumber(cp.chainlightning_index),
			forksub = cp.chainlightning_sub ~= nil,
			weaponNum = tonumber(cp.chainlightning_num) or 1,
			canTargetFeature = cp.chainlightning_donttargetfeature == nil,
			canStrikeTwice = cp.chainlightning_hittwice ~= nil,
			dontspawn = cp.chainlightning_blockexplosion ~= nil,
			forceSpawn = cp.chainlightning_spawndef,
		}
		if config[i].forceSpawn then
			local wd = WeaponDefNames[config[i].forceSpawn]
			if wd then
				config[i].forceSpawn = wd.id
			else
				Spring.Echo("[Chainlightning]: Invalid weapondef! " .. tostring(config[i].forceSpawn) .. " does not exist!")
			end
		end
		--Spring.Echo("[ChainLightning] Added " .. i)
		Script.SetWatchExplosion(i, true)
		if config[i].forksub then
			subProjectileDefs[i] = true
		end
	end
end

for i = 1, #FeatureDefs do
	local name = string.lower(FeatureDefs[i].tooltip)
	--Spring.Echo(i .. ": " .. tostring(name))
	
	if string.find(name, "shards") or string.find(name, "debris -") or (string.find(name, "geothermal") and not string.find(name, "wreck")) or name == "metal vein" or name == "coagulation node" or name == "contains metal" then
		invalidFeatures[i] = true
		--Spring.Echo(i .. " ( " .. name .. ") is invalid")
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
		if not disallowedUnitIDs[unitID] and not invalidDefs[spGetUnitDefID(unitID)] then
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
			if invalidFeatures[spGetFeatureDefID(featureID)] then
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
	if debugMode then Spring.Echo("Dir: " .. dirX .. ", " .. dirY .. ", " .. dirZ) end
	local _, _, _, cx, cy, cz = spGetUnitPosition(target, true) -- midpos position
	local scaleX, scaleY, scaleZ, offX, offY, offZ = spGetUnitCollisionVolumeData(target)
	cx, cy, cz = cx + offX, cy + offY, cz + offZ
	scaleX = scaleX / 2 + 1 -- take half the scale, add 1, this should get us outside the colvol at any point.
	scaleY = scaleY / 2 + 1
	scaleZ = scaleZ / 2 + 1
	--Spring.MarkerAddPoint(cx + (scaleX * dirX), cy + (scaleY * dirY), cz + (scaleZ * dirZ), "v", true)
	return cx + (scaleX * dirX), cy + (scaleY * dirY), cz + (scaleZ * dirZ)
end

local function GetPointOutsideOfFeatureColvol(featureID, dirX, dirY, dirZ)
	if debugMode then Spring.Echo("Dir: " .. dirX .. ", " .. dirY .. ", " .. dirZ) end
	local _, _, _, cx, cy, cz = spGetFeaturePosition(featureID, true) -- midpoint
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

local function SpawnLightningProjectile(attackerID, def, x, y, z, targetX, targetY, targetZ, dirx, diry, dirz, targetID)
	dirx, diry, dirz = PointToDir(x, y, z, targetX, targetY, targetZ)
	if debugMode then
		Spring.Echo("Chain Lightning: Spawning using weaponIndex ", index)
		Spring.MarkerAddLine(x, y, z, targetX, targetY, targetZ)
	end
	local params = {
		pos = {x, y, z},
		speed = {dirx, diry, dirz},
		owner = attackerID,
		tracking = targetID,
	}
	params["end"] = {targetX, targetY, targetZ} -- why recoil INSISTS on using a lua keyword is beyond me.
	spSpawnProjectile(def, params)
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
	local canStrikeTwice = c.canStrikeTwice
	if damagedUnit and not isFeature then
		if not canStrikeTwice then
			badTargets[damagedUnit] = true
		end
		_, _, _, px, py, pz = spGetUnitPosition(damagedUnit, true)
	elseif damagedUnit and isFeature then
		px, py, pz = spGetFeaturePosition(damagedUnit)
		if not canStrikeTwice then
			badFeatures[damagedUnit] = true
		end
	end
	local potentialTargets, potentialFeatures = {}, {}
	potentialTargets, badTargets = GetValidTargets(px, py, pz, c.targetSearchDistance, c.friendlyFire, attackerTeam, badTargets) 
	if c.canTargetFeature then
		potentialFeatures, badFeatures = GetValidFeatureTargets(px, py, pz, c.targetSearchDistance, badFeatures)
	end
	for targetNum = 1, c.maxTargets do
		local x2, y2, z2, dirx, diry, dirz
		local sx, sy, sz, newTarget, targetFeature
		if #potentialTargets > 0 and #potentialFeatures == 0 then
			local selection = math.random(1, #potentialTargets)
			newTarget = potentialTargets[selection]
			badTargets[newTarget] = true
			if not canStrikeTwice then
				if #potentialTargets ~= 1 then
					local n = potentialTargets[#potentialTargets]
					potentialTargets[selection] = n
					potentialTargets[#potentialTargets] = nil
				else
					potentialTargets[1] = nil
				end
			end 
			targetFeature = false
			if debugMode then
				Spring.Echo("ChainLightning DoChainLightning: Target " .. targetNum .. ": " .. newTarget)
			end
		elseif #potentialTargets > 0 and #potentialFeatures > 0 then -- pick a feature or target at random
			local fChance = 1 - (#potentialFeatures / (#potentialTargets + #potentialFeatures)) -- chance to pick a feature instead of a unit
			if math.random() * 100 >= fChance then -- we picked a feature.
				local selection = math.random(1, #potentialFeatures)
				newTarget = potentialFeatures[selection]
				badFeatures[newTarget] = true
				if not canStrikeTwice then
					if #potentialFeatures == 1 then
						potentialFeatures[1] = nil
					else
						local n = potentialFeatures[#potentialFeatures]
						potentialFeatures[selection] = n
						potentialFeatures[#potentialFeatures] = nil
					end
				end
				targetFeature = true
			else
				local selection = math.random(1, #potentialTargets)
				newTarget = potentialTargets[selection]
				badTargets[newTarget] = true
				if not canStrikeTwice then
					if #potentialTargets ~= 1 then
						local n = potentialTargets[#potentialTargets]
						potentialTargets[selection] = n
						potentialTargets[#potentialTargets] = nil
					else
						potentialTargets[1] = nil
					end
				end
				targetFeature = false
			end
		elseif #potentialTargets == 0 and #potentialFeatures > 0 then -- pick a feature at random
			local selection = math.random(1, #potentialFeatures)
			newTarget = potentialFeatures[selection]
			badFeatures[newTarget] = true
			if not canStrikeTwice then
				if #potentialFeatures == 1 then
					potentialFeatures[1] = nil
				else
					local n = potentialFeatures[#potentialFeatures]
					potentialFeatures[selection] = n
					potentialFeatures[#potentialFeatures] = nil
				end
			end
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
		if c.forceSpawn then
			SpawnLightningProjectile(AttackerID, c.forceSpawn, sx, sy, sz, x2, y2, z2, dirx, diry, dirz, targetID)
		else
			SpawnLightning(AttackerID, c.weaponIndex, sx, sy, sz, x2, y2, z2, dirx, diry, dirz)
		end
	end
end

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if debugMode then
		Spring.Echo("Chainlightning: Explosion: ", px, py, pz, AttackerID, ProjectileID)
	end
	if AttackerID == nil or config[weaponDefID].dontspawn then
		return
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
			DoChainLightning(weaponDefID, px, py, pz, AttackerID, nil, false)
			return false
		end
	else
		DoChainLightning(weaponDefID, px, py, pz, AttackerID, nil, false)
		return false
	end
end

--[[function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if subProjectileDefs[weaponDefID] then
		--Spring.Echo("ChainLightning: UnitDamaged")
		local x, y, z = spGetUnitPosition(unitID, true)
		DoChainLightning(weaponDefID, x, y, z, attackerID, unitID)
	end
end]]
