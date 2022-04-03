local name = "commweapon_rocketlauncher_nuclear"
local weaponDef = {
	name                    = [[Nuclear Cruise Missile Launcher]],
	areaOfEffect            = 800,
	cegTag                  = [[NUCKLEARMINI]],
	craterBoost             = 1,
	craterMult              = 4,

	customParams            = {
		is_unit_weapon = 1,
		slot = [[5]],
		muzzleEffectShot = [[custom:SLAM_MUZZLE]],

		light_camera_height = 2200,
		light_color = [[0.95 0.65 0.30]],
		light_radius = 280,
		reaim_time = 1,
		cruiserandomradius = 100,
		cruisealt = 200,
		airlaunched = 1,
		cruisedist = 280,
		cruisetracking = 1,
		cruise_nolock = 1,
		reveal_unit = 33,
	},

	damage                  = {
		default = 5000.1,
	},

	edgeEffectiveness       = 0.4,
	explosionGenerator      = [[custom:nukebigland]],
	fireStarter             = 180,
	flightTime              = 30,
	impulseBoost            = 0,
	impulseFactor           = 1.15,
	interceptedByShieldType = 2,
	model                   = [[nuclear_missile_small.dae]],
	range                   = 800,
	reloadtime              = 30,
	smokeTrail              = false,
	noSelfDamage            = false,
	soundHit                = [[weapon/missile/mininuke_hit]],
	soundHitVolume          = 15,
	soundStart              = [[weapon/missile/mininuke_launch]],
	soundStartVolume        = 7,
	startVelocity           = 100,
	tracks                  = true,
	turnrate				= 28000,
	trajectoryHeight        = 1.5,
	turret                  = true,
	weaponAcceleration      = 200,
	--dance					= 100,
	weaponType              = [[MissileLauncher]],
	weaponVelocity          = 420,
}

return name, weaponDef
