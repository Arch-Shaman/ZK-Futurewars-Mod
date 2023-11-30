if (not gadgetHandler:IsSyncedCode()) then
	return
end


function gadget:GetInfo()
	return {
		name      = "Armor Ignoring Damage",
		desc      = "Implements armor ignoring damage.",
		author    = "Shaman",
		date      = "April 2st, 2023",
		license   = "CC BY-NC-ND",
		layer     = 1000,
		enabled   = true,
	}
end

local config = {}

local spGetUnitArmored = Spring.GetUnitArmored
local debugMode = true
local watchWeapons = {}

for i = 1, #WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams.armorpiercing then
		local percent = tonumber(wd.customParams.armorpiercing)
		if percent then
			config[i] = percent
			watchWeapons[#watchWeapons + 1] = i
		end
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	if config[weaponDefID] then
		local isArmored, armorValue = spGetUnitArmored(unitID)
		if not isArmored or armorValue >= 1 then
			return damage, 1
		else -- EX: 500 damage, 75% AP against 80% armor should yield 375 damage.
			local originalDamage = damage * (1/armorValue)
			local effectiveArmorNegation = 1 - ((1 - armorValue) * (1 - config[weaponDefID]))
			return originalDamage * effectiveArmorNegation, 1
		end
	else
		return damage, 1
	end
end

function gadget:UnitPreDamaged_GetWantedWeaponDef() -- only do certain weapons.
	return watchWeapons
end