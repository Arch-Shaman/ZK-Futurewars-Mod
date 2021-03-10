function gadget:GetInfo()
	return {
		name      = "No Feature Damage",
		desc      = "Blocks feature damage for wave based damagers.",
		author    = "Shaman",
		date      = "11/26/2020",
		license   = "CC-0",
		layer     = 0,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then
	return
end

local damagemult = {}

for w = 1, #WeaponDefs do
	local cp = WeaponDefs[w].customParams
	if cp.featuredamagemult or cp.featureimpulsemult then
		local mult = tonumber(cp.featuredamagemult) or 1
		local imp = tonumber(cp.featureimpulsemult) or mult
		--Spring.Echo("[Feature Mult]: Added weapon with " .. mult .. ", " .. imp)
		damagemult[w] = {damage = mult, impulse = imp}
	end
end

function gadget:FeaturePreDamaged(featureID, featureDefID, featureTeam, damage, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	Spring.Echo("A feature was damaged")
	if damagemult[weaponDefID] then
		Spring.Echo("Damaged Feature!")
		return damagemult[weaponDefID].damage * damage, damagemult[weaponDefID].impulse
	end
	return damage, 1
end