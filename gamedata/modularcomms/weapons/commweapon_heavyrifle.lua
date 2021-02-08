local name = "commweapon_heavyrifle"
local weaponDef = {
	name                    = [[Heavy Rifle]],
	areaOfEffect            = 48,
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectFire = [[custom:HEAVY_CANNON_MUZZLE]],
		miscEffectFire = [[custom:emg_shells_l]],

		light_color = [[0.8 0.76 0.38]],
		light_radius = 120,
		reaim_time = 1,
	},

	damage                  = {
		default = 125.1,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = [[custom:EMG_HIT_HE]],
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 1,
	myGravity               = 0.1,
	range                   = 370,
	reloadtime              = .5,
	soundHit                = [[weapon/cannon/cannon_hit1]],
	soundStart              = [[weapon/cannon/med_rifle_fire]],
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 420,
}

return name, weaponDef
