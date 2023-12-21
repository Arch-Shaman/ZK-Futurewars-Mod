if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "No Ground Bounce for Noexplodes",
		desc      = "Implements groundbounceless NoExplodes",
		author    = "Shaman",
		date      = "May 13, 2023",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

local wantedDefs = {}

for i = 1, #WeaponDefs do
	if WeaponDefs[i].customParams.groundnoexplode then
		wantedDefs[#wantedDefs + 1] = i
		Script.SetWatchExplosion(i, true)
	end
end

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if py <= Spring.GetGroundHeight(px, pz) + 2 then
		Spring.DeleteProjectile(ProjectileID)
	end
end

function gadget:Explosion_GetWantedWeaponDef()
	return wantedDefs
end
