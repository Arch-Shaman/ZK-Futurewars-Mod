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

for i = 1, #WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams.armorpiercing then
		local percent = tonumber(wd.customParams.armorpiercing)
		if percent then
			config[i] = percent
		end
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	if config[weaponDefID] then
		local isArmored, armorValue = spGetUnitArmored(unitID)
		if not isArmored then
			return damage, 1
		else
			return (damage * (1/armorValue)) * config[weaponDefID], 1
		end
	else
		return damage, 1
	end
end
