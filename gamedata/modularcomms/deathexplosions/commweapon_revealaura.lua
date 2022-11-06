local name = "commweapon_revealaura"
local weaponDef = {
	name                    = [[Cloak Disruptor Pulse]],
	areaOfEffect            = 400,
	craterBoost             = 0,
	craterMult              = 0,
	damage                  = {
		default = 2, -- decloak time is 2x longer for recon.
	},
	customParams           = {
		light_radius = 0,
		--lups_explodespeed = 0.5,
		--lups_explodelife = 2.0,
		nofriendlyfire = "needs hax",
		puredecloaktime = 200,
		norealdamage = 1,
		stats_hide_damage = 1,
		lups_noshockwave = [[1]],
	},
	edgeeffectiveness       = 0.4,
	explosionGenerator      = [[custom:scanner_ping_400]],
	explosionSpeed          = 12,
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	myGravity               = 10,
	noSelfDamage            = true,
	range                   = 10,
	reloadtime              = 2.0,
	soundHitVolume          = 1,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 230,
}

return name, weaponDef
