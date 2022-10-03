if not gadgetHandler:IsSyncedCode() then -- SYNCED
	return
end

function gadget:GetInfo()
  return {
    name      = "Lightning bolts",
    desc      = "Lightning from the sky!",
    author    = "Shaman",
    date      = "2 Oct 2022",
    license   = "CC-0",
    layer     = 0,
    enabled   = true,
  }
end

local projectileAttributes = {pos = {0, 0, 0}, speed = {0,-10,0}, gravity = -1, owner = 0, team = 0, maxRange = 1000, ttl = 3}
projectileAttributes["end"] = {0, 0, 0}

do -- Create a local area so our id variable isn't global
	local id = WeaponDefNames["planelightscout_laser_actual"].id
	Script.SetWatchExplosion(id, true)
end

local weaponDefID = WeaponDefNames["planelightscout_laser_dgun"].id

function gadget:Explosion_GetWantedWeaponDef()
	return {[1] = WeaponDefNames["planelightscout_laser_actual"].id}
end

function gadget:Explosion(weaponID, px, py, pz, ownerID, proID)
	if Spring.ValidUnitID(ownerID) then
		projectileAttributes.pos[1], projectileAttributes.pos[2], projectileAttributes.pos[3] = Spring.GetUnitPosition(ownerID)
		projectileAttributes["end"][1], projectileAttributes["end"][2], projectileAttributes["end"][3] = px, py, pz
		projectileAttributes.owner = ownerID
		projectileAttributes.team = Spring.GetUnitTeam(ownerID)
		Spring.SpawnProjectile(weaponDefID, projectileAttributes)
	end
end
	