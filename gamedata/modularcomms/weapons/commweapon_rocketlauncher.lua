local name = "commweapon_rocketlauncher"
local weaponDef = {
	name                    = [[Rocket Launcher]],
	areaOfEffect            = 96,
	cegTag                  = [[rocket_trail_bar_flameboosted]],
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		slot = [[5]],
		muzzleEffectFire = [[custom:STORMMUZZLE]],

		light_camera_height = 2200,
		light_color = [[0.95 0.65 0.30]],
		light_radius = 280,
		reaim_time = 1,
		use_okp = 1,
		okp_speedmult = 0.3,
		okp_radarmult = 1,
		okp_timeout = 30,
		okp_damage = 750,
	},

	damage                  = {
		default = 750,
	},

	fireStarter             = 180,
	flightTime              = 6,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 2,
	model                   = [[wep_m_hailstorm.s3o]],
	range                   = 530,
	reloadtime              = 3,
	smokeTrail              = false,
	soundHit                = [[explosion/ex_med4]],
	soundHitVolume          = 7,
	soundStart              = [[weapon/missile/sabot_fire]],
	soundStartVolume        = 7,
	startVelocity           = 200,
	tracks                  = false,
	trajectoryHeight        = 0.1,
	turret                  = true,
	weaponAcceleration      = 100,
	weaponType              = [[MissileLauncher]],
	weaponVelocity          = 270,
}

return name, weaponDef
