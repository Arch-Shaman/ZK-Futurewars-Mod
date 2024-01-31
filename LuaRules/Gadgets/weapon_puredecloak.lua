if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

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

--[[ 
				WARNING:
ALL DECLOAK DAMAGE MUST BE 1 FOR THIS TO WORK.
]]

local config = {}
local watchWeapons = {}
for i = 1, #WeaponDefs do
	if WeaponDefs[i].customParams and WeaponDefs[i].customParams.puredecloaktime then
		config[i] = tonumber(WeaponDefs[i].customParams.puredecloaktime)
		wantedList[i] = true
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	if config[weaponDefID] and damage > 0 then
		GG.BlockCloakForUnit(unitID, config[weaponDefID] * damage)
		return damage, 1
	end
end

function gadget:UnitPreDamaged_GetWantedWeaponDef() -- only do certain weapons.
	return watchWeapons
end