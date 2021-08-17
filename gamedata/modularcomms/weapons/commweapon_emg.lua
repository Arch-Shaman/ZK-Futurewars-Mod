local name = "commweapon_emg"
local weaponDef = {
	name                    = [[Medium EMG Rifle]],
	areaOfEffect            = 8,
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectFire = [[custom:HEAVY_CANNON_MUZZLE]],
		miscEffectFire = [[custom:emg_shells_l]],
		antibaitbypass = "ärsytät minua",
		light_color = [[0.8 0.76 0.38]],
		light_radius = 120,
		reaim_time = 1,
	},

	damage                  = {
		default = 27.1,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = [[custom:EMG_HIT_HE]],
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 1,
	myGravity               = 0.1,
	range                   = 300,
	reloadtime              = .1,
	soundHit                = [[weapon/cannon/cannon_hit1]],
	soundStart              = [[weapon/heavy_machinegun]],
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 580,
}

return name, weaponDef
