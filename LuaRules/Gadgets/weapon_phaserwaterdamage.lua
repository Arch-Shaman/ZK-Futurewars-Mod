if not (gadgetHandler:IsSyncedCode()) then
	return false
end

function gadget:GetInfo()
  return {
    name      = "Underwater Phaser Damage Reduction",
    desc      = "Handle phaser damage underwater",
    author    = "Shaman",
    date      = "03/20/2021",
    license   = "CC-0",
    layer     = 0,
    enabled   = true,
  }
end

local config = {}

for i = 1, #WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams.underwaterdamagereduction then
		config[i] = tonumber(wd.customParams.underwaterdamagereduction) or 1
		--Script.SetWatchWeapon(i, true)
	end
end

local spGetUnitPosition = Spring.GetUnitPosition
local sqrt = math.sqrt
local min = math.min
local abs = math.abs

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	if config[weaponDefID] then
		local _, depth = spGetUnitPosition(unitID)
		if depth >= -10 then
			return damage, 1.0
		else
			local mult = config[weaponDefID]
			depth = abs(depth)
			local depthmod = min(1/(sqrt(depth) * mult), 1)
			return damage * depthmod, 1.0
		end
	else
		return damage, 1.0
	end
end
