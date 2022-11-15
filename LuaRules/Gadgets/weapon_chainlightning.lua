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

local spGetUnitsInSphere           = Spring.GetUnitsInSphere
local spGetUnitPosition            = Spring.GetUnitPosition
local spGetUnitAllyTeam            = Spring.GetUnitAllyTeam
local spGetUnitsInBox              = Spring.GetUnitsInBox
local spSpawnSFX                   = Spring.SpawnSFX
local spGetUnitDefID               = Spring.GetUnitDefID
local spGetUnitCollisionVolumeData = Spring.GetUnitCollisionVolumeData

local debug = true

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	if cp.chainlightning_index then
		wantedWeapons[#wantedWeapons + 1] = i
		config[i] = {
			targetSearchDistance = tonumber(cp.chainlightning_searchdist),
			maxTargets = tonumber(cp.chainlightning_maxtargets),
			friendlyFire = cp.chainlightning_ff == nil,
			weaponIndex = tonumber(cp.chainlightning_index),
		}
		Spring.Echo("[ChainLightning] Added " .. i)
		Script.SetWatchExplosion(i, true)
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

local function PointToDir(originX, originY, originZ, targetX, targetY, targetZ)
	local vx, vy, vz = originX - targetX, originY - targetY, originZ - targetZ -- points -> vector
	local mag = math.sqrt(vx * vx + vy * vy + vz * vz)
	return vx / mag, vy / mag, vz / mag
end

local function GetPointOutsideOfColvol(target, dirX, dirY, dirZ)
	Spring.Echo("Dir: " .. dirX .. ", " .. dirY .. ", " .. dirZ)
	local cx, cy, cz = spGetUnitPosition(target) -- base position
	local scaleX, scaleY, scaleZ, offX, offY, offZ = spGetUnitCollisionVolumeData(target)
	cx, cy, cz = cx + offX, cy + offY, cz + offZ
	scaleX = scaleX/2 + 0.5 -- take half the scale, add 0.5
	scaleY = scaleY/2 + 0.5
	scaleZ = scaleZ/2 + 0.5
	return cx + (scaleX * dirX), cy + (scaleY * dirY), cz + (scaleZ * dirZ)
end

local function SpawnLightningFromUnit(attackerID, index, x, y, z, targetX, targetY, targetZ, dirx, diry, dirz)
	--local dirx, diry, dirz = PointToDir(targetX, targetY, targetZ, x, y, z)
	if debug then
		Spring.Echo("Chain Lightning: Spawning using weaponIndex ", index)
		Spring.MarkerAddLine(x, y, z, targetX, targetY, targetZ)
	end
	spSpawnSFX(attackerID, 2047 + index, x, y, z, dirx, diry, dirz, true)
end

local function SpawnLightningFromPoint(attackerID, index, x, y, z, dirx, diry, dirz)
	if debug then
		Spring.Echo("Chain Lightning: Spawning using weaponIndex ", index)
	end
	spSpawnSFX(attackerID, 2047 + index, x, y, z, dirx, diry, dirz, true)
end


local function GetDirectionFromUnit(targetID, originX, originY, originZ)
	local _, _, _, _, _, _, x2, y2, z2 = spGetUnitPosition(targetID, true, true)
	local dirx, diry, dirz = PointToDir(x2, y2, z2, originX, originY, originZ)
	return x2, y2, z2, dirx, diry, dirz
end

local function DoChainLightning(weaponDefID, px, py, pz, AttackerID, damagedUnit)
	local c = config[weaponDefID]
	if debug then
		Spring.Echo("DoChainLightning: ", px, py, pz, AttackerID, damagedUnit)
	end
	local attackerTeam = spGetUnitAllyTeam(AttackerID)
	local badTargets = {}
	if damagedUnit then
		badTargets[damagedUnit] = true
	end
	local potentialTargets
	for targetNum = 1, c.maxTargets do
		potentialTargets, badTargets = GetValidTargets(px, py, pz, c.targetSearchDistance, c.friendlyFire, attackerTeam, badTargets)
		if #potentialTargets > 0 then
			local newTarget = potentialTargets[math.random(1, #potentialTargets)]
			badTargets[newTarget] = true
			local x2, y2, z2, dirx, diry, dirz = GetDirectionFromUnit(newTarget, px, py, pz)
			if damagedUnit then
				local sx, sy, sz = GetPointOutsideOfColvol(damagedUnit, dirx, diry, dirz)
				SpawnLightningFromUnit(AttackerID, c.weaponIndex, sx, sy, sz, x2, y2, z2, dirx, diry, dirz)
			else
				SpawnLightningFromPoint(AttackerID, c.weaponIndex, px, py, pz, dirx, diry, dirz)
			end
			if debug then
				Spring.Echo("ChainLightning DoChainLightning: Target " .. targetNum .. ": " .. newTarget)
			end
		else
			if debug then Spring.Echo("Breaking due to no valid targets") end
			break
		end
	end
end

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if debug then
		Spring.Echo("Chainlightning: Explosion: ", px, py, pz, AttackerID)
	end
	DoChainLightning(weaponDefID, px, py, pz, AttackerID)
	return false
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if config[weaponDefID] then
		Spring.Echo("ChainLightning: UnitPreDamaged")
		local x, y, z = spGetUnitPosition(unitID, true)
		DoChainLightning(weaponDefID, x, y, z, attackerID, unitID)
	end
end