function gadget:GetInfo()
	return {
		name      = "Pure Decloak",
		desc      = "Blocks cloaking for X seconds.",
		author    = "Shaman",
		date      = "January 10, 2021",
		license   = "CC-0",
		layer     = -5,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local config = {}
for i = 1, #WeaponDefs do
	if WeaponDefs[i].customParams and WeaponDefs[i].customParams.puredecloaktime then
		config[i] = tonumber(WeaponDefs[i].customParams.puredecloaktime)
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if config[weaponDefID] and damage > 0 then
		GG.BlockCloakForUnit(unitID, config[weaponDefID])
		return 0, 0
	end
end
