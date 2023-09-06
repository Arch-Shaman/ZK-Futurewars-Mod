if (not gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Teleportation",
		desc      = "Units can teleport on the battlefield.",
		author    = "Shaman",
		date      = "July 19, 2022",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end


local targetypes = {}
targetypes[string.byte('g')] = "ground"
targetypes[string.byte('u')] = "unit"
targetypes[string.byte('f')] = "feature"
targetypes[string.byte('p')] = "projectile"

local spTestMoveOrder = Spring.TestMoveOrder
local spTestBuildOrder = Spring.TestBuildOrder
local spGetUnitPosition = Spring.GetUnitPosition
local spSetUnitVelocity = Spring.SetUnitVelocity


local config = {}
local overrides = {}

for i = 1, #WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams and wd.customParams.teleportation then
		config[i] = {sound = wd.customParams.teleportsound, weaponID = tonumber(wd.customParams.teleportid), resetMomentum = wd.customParams.teleport_nomomentum ~= nil}
		Script.SetWatchWeapon(i, true)
	end
end

local offset = {
	[0] = {x = 1, z = 0},
	[1] = {x = 1, z = 1},
	[2] = {x = 0, z = 1},
	[3] = {x = -1, z = 1},
	[4] = {x = 0, z = -1},
	[5] = {x = -1, z = -1},
	[6] = {x = 1, z = -1},
	[7] = {x = -1, z = 0},
}

local function GetTeleTargetPos(unitDefID, tx, tz)
	local ud = UnitDefs[unitDefID]
	local size = ud.xsize
	local startCheck = math.floor(math.random(8))
	local direction = (math.random() < 0.5 and -1) or 1
	for j = 0, 7 do
		local spot = (j*direction+startCheck)%8
		local sx, sz = offset[spot].x*(size*4+40), offset[spot].z*(size*4+40)
		if ud.canFly then
			return sx, sz
		end
		local place, feature = Spring.TestBuildOrder(ud.id, tx + sx, 0, tz + sz, 1)

		-- also test move order to prevent getting stuck on terrains with 0 speed mult
		if (place == 2 and feature == nil) and spTestMoveOrder(unitDefID, tx + sx, 0, tz + sz, 0, 0, 0, true, true, true) then
			return sx, sz
		end
	end
	return nil
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if config[weaponDefID] then
		local targetType, targetParam = Spring.GetProjectileTarget(proID)
		local targetX, targetY, targetZ, teleportX, teleportY, teleportZ
		local ownerDefID = Spring.GetUnitDefID(proOwnerID)
		local teleported = false
		local cfg = config[weaponDefID]
		targetType = targetypes[targetType] or "nil"
		Spring.DeleteProjectile(proID)

		if targetType == "unit" then
			targetX, targetY, targetZ = spGetUnitPosition(targetParam)
		elseif targetType == "feature" then
			targetX, targetY, targetZ = Spring.GetFeaturePosition(targetParam)
		elseif targetType == "ground" then
			targetX = targetParam[1]
			targetY = targetParam[2]
			targetZ = targetParam[3]
		else
			Spring.Echo("[unit_microrifts.lua]: Bad target type. Got: " .. tostring(targetType))
		end
		if targetX and targetZ then
			teleportX, teleportZ = GetTeleTargetPos(ownerDefID, targetX, targetZ)
			if teleportX and teleportZ then
				teleportX = teleportX + targetX
				teleportZ = teleportZ + targetZ
				teleportY = Spring.GetGroundHeight(teleportX, teleportZ)
				teleported = true
			end
		else
			Spring.Echo("[unit_microrifts.lua]: Bad target Position!")
		end
		
		if teleported then
			local x, y, z = spGetUnitPosition(proOwnerID)
			local rotation = math.atan2(targetZ - teleportZ, targetX - teleportX)
			local cx, cy, cz = Spring.GetUnitRotation(proOwnerID)
			Spring.SpawnCEG("teleport_out", x, y, z)
			Spring.SpawnCEG("teleport_in", teleportX, teleportY, teleportZ)
			Spring.MoveCtrl.Enable(proOwnerID)
			Spring.MoveCtrl.SetPosition(proOwnerID, teleportX, teleportY, teleportZ)
			Spring.MoveCtrl.SetHeading(proOwnerID, 1)
			Spring.MoveCtrl.SetRotation(proOwnerID, 0, rotation, 0)
			Spring.MoveCtrl.Disable(proOwnerID)
			if cfg.resetMomentum then
				spSetUnitVelocity(proOwnerID, 0, 0, 0)
			end
			GG.PlayFogHiddenSound(cfg.sound, 10, x, y, z)
		else
			local weaponNum = overrides[proOwnerID] or cfg.weaponID
			if weaponNum then
				Spring.SetUnitWeaponState(proOwnerID, weaponNum, "reloadFrame", Spring.GetGameFrame()) -- Reload the weapon.
			end
		end
	end
end

local function AddOverride(unitID, weaponNum)
	overrides[unitID] = weaponNum
end

function gadget:UnitDestroyed(unitID)
	overrides[unitID] = nil
end

GG.Microrifts_AddUnitOverride = AddOverride
