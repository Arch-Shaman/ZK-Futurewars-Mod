local name = "commweapon_revealaura"
local weaponDef = {
	name                    = "Cloak Disruptor Pulse",
	areaOfEffect            = 1000,
	craterBoost             = 0,
	craterMult              = 0,
	collideFriendly         = false,
	burnblow                = true,
	damage                  = {
		default = 5.0, -- decloak time is 2x longer for recon.
	},
	customParams           = {
		light_radius = 0,
		--lups_explodespeed = 0.5,
		--lups_explodelife = 2.0,
		nofriendlyfire = "needs hax",
		puredecloaktime = 120,
		norealdamage = 1,
		stats_hide_damage = 1,
		lups_noshockwave = "1",
	},
	edgeeffectiveness       = 0.7,
	explosionGenerator      = "custom:scanner_ping",
	explosionSpeed          = 500,
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	myGravity               = 10,
	noSelfDamage            = true,
	size                    = 0,
	range                   = 10,
	reloadtime              = 2.0,
	soundHitVolume          = 1,
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 230,
}

return name, weaponDef
