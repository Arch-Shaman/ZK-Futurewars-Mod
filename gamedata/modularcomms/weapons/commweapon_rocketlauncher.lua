local name = "commweapon_rocketlauncher"
local weaponDef = {
	name                    = [[EOS-CR launcher]],
	areaOfEffect            = 192,
	cegTag                  = [[tactrail]],
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		slot = [[5]],
		muzzleEffectShot = [[custom:RAIDMUZZLE]],

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
		reveal_unit = 14,
	},

	damage                  = {
		default = 1200.1,
	},

	edgeEffectiveness       = 0.4,
	explosionGenerator      = [[custom:NUKE_150]],
	fireStarter             = 180,
	flightTime              = 30,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 2,
	model                   = [[wep_minitacnuke.dae]],
	range                   = 720,
	reloadtime              = 12.2,
	smokeTrail              = false,
	soundHit                = [[explosion/mini_nuke]],
	soundHitVolume          = 15,
	soundStart              = [[weapon/missile/rapid_rocket_fire]],
	soundStartVolume        = 7,
	startVelocity           = 100,
	tracks                  = true,
	turnrate				= 28000,
	trajectoryHeight        = 1.5,
	turret                  = true,
	weaponAcceleration      = 200,
	--dance					= 100,
	weaponType              = [[MissileLauncher]],
	weaponVelocity          = 750,
}

return name, weaponDef
