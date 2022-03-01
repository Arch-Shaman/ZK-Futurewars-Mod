local name = "commweapon_rocketlauncher"
local weaponDef = {
	name                    = [[Multiple Light Rocket Launcher]],
	areaOfEffect            = 96,
	cegTag                  = [[rocket_trail_bar_flameboosted]],
	craterBoost             = 0,
	craterMult              = 0,
	burst = 15,
	burstrate = 2/30,

	customParams            = {
		is_unit_weapon = 1,
		slot = [[5]],
		muzzleEffectShot = [[custom:rocket_trail_bar_flameboosted]],

		light_camera_height = 2200,
		light_color = [[0.95 0.65 0.30]],
		light_radius = 280,
		reaim_time = 1,
		cruiserandomradius = 220,
		cruisealt = 200,
		airlaunched = 1,
		cruisedist = 280,
		cruisetracking = 1,
		cruise_nolock = 1,
		reveal_unit = 10,
	},

	damage                  = {
		default = 240,
	},

	fireStarter             = 180,
	flightTime              = 15,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 2,
	model                   = [[wep_m_hailstorm.s3o]],
	range                   = 720,
	reloadtime              = 8.5,
	smokeTrail              = false,
	soundHit                = [[weapon/missile/rapid_rocket_hit]],
	soundHitVolume          = 7,
	soundStart              = [[weapon/missile/rapid_rocket_fire]],
	soundStartVolume        = 7,
	startVelocity           = 200,
	tracks                  = true,
	turnrate				= 28000,
	trajectoryHeight        = 1.5,
	turret                  = true,
	weaponAcceleration      = 100,
	dance					= 100,
	weaponType              = [[MissileLauncher]],
	weaponVelocity          = 450,
}

return name, weaponDef
