local name = "commweapon_gaussrepeater"
local weaponDef = {
	name                    = [[Gauss Repeater]],
	alphaDecay              = 0.12,
	areaOfEffect            = 16,
	avoidfeature            = false,
	bouncerebound           = 0.15,
	bounceslip              = 1,
	burst					= 4,
	burstrate				= 4/30,
	cegTag                  = [[gauss_tag_l]],
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		slot = [[5]],
		muzzleEffectFire = [[custom:flashmuzzle1]],
		single_hit_multi = true,
		reaim_time = 1,
	},

	damage                  = {
		default = 33.1,
	},

	explosionGenerator      = [[custom:gauss_hit_m]],
	groundbounce            = 1,
	impactOnly              = true,
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	noExplode               = true,
	noSelfDamage            = true,
	numbounce               = 10,
	range                   = 220,
	reloadtime              = 2/3,
	rgbColor                = [[0.5 1 1]],
	separation              = 0.5,
	size                    = 0.8,
	sizeDecay               = -0.1,
	soundHit                = [[weapon/gauss_hit]],
	soundHitVolume          = 3,
	soundStart              = [[weapon/cannon/gauss_rapid.wav]],
	soundStartVolume        = 2.5,
	stages                  = 32,
	turret                  = true,
	waterbounce             = 1,
	waterweapon				= true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 2200,
}

return name, weaponDef
