local name = "commweapon_shockrifle"
local weaponDef = {
	name                    = "Sniper Rifle",
	areaOfEffect            = 16,
	colormap                = "0 0 0 0   0 0 0.2 0.2   0 0 0.5 0.5   0 0 0.7 0.7   0 0 1 1   0 0 1 1",
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		slot = "5",
		light_radius = 0,
		reaim_time = 1,
		reveal_unit = 12,
		use_okp = 1,
		okp_speedmult = 0.8,
		okp_radarmult = 1,
		okp_timeout = 60,
		okp_damage = 1200.01,
		aimdelay = 3*30,
		shield_disruption = 15*30,
		armorpiercing = 0.10,
		allowedpitcherror = 10,
		allowedheadingerror = 10,
		groundnoexplode = 1,
	},

	damage                  = {
		default = 1200.01,
	},

	explosionGenerator      = "custom:spectre_hit",
	impactOnly              = true,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 9,
	noSelfDamage            = true,
	noExplode				= true,
	range                   = 1250,
	reloadtime              = 9,
	rgbColor                = "1 0.2 0.2",
	separation              = 0.5,
	size                    = 5,
	sizeDecay               = 0,
	soundHit                = "explosion/ex_med5",
	soundStart              = "weapon/gauss_fire",
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 1000,
}

return name, weaponDef
