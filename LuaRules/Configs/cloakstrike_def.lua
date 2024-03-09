local StrikeWepDefs = {}

-- Some of the old code here did not work as expected due to the way lua handles tables! This has been rewritten to allow balance changes.

for i = 1, #UnitDefs do
	local def = UnitDefs[i]
	local cp = def.customParams
	local duration = tonumber(cp.cloakstrikeduration)
	if duration then
		local wepmodifiers = {}
		local speed = tonumber(cp.cloakstrikespeed) or 1
		local slowdown = tonumber(cp.cloakstrikeslow) or 1
		local wepstats = {}
		for j = 1, #def.weapons do
			local weapon = WeaponDefs[def.weapons[j].weaponDef]
			local bonus = tonumber(weapon.customParams.cloakstrike)
			if bonus then
				local damagetable = weapon.damages
				wepstats[j] = {
					cloakedWeaponStates = {}, -- no idea if this is NYI or what?
					decloakedWeaponStates = {}, -- ditto
					cloakedWeaponDamages = {},
					decloakedWeaponDamages = {},
				}
				local defaultvalue = damagetable[0] or 0
				for k = 0, 5 do
					--Spring.Echo(k .. ": ", damagetable[k])
					wepstats[j].cloakedWeaponDamages[k] = (damagetable[k] or defaultvalue) * bonus
					wepstats[j].decloakedWeaponDamages[k] = (damagetable[k] or defaultvalue)
				end
			end
		end
		StrikeWepDefs[i] = {
			persistance = duration,
			cloakRecharge = 2,    -- NYI
			maxRecharge = 60,     -- NYI
			attackDecharge = -1,  -- NYI apparently (None of this matters anyways because Persistence is a thing.)
			WeaponStats = wepstats,
			cloakedRulesParam = { selfMoveSpeedChange = speed},
			decloakedRulesParam = { selfMoveSpeedChange = slowdown},
			updateAttributes = speed ~= slowdown,
		}
		--Spring.Echo("[CloakStrike] Added " .. i .. "\nDuration: " .. duration .. "\nCloak Speed: " .. speed .. "\nnormal speed: " .. slowdown)
	end
end

return StrikeWepDefs
