local name = "commweapon_shotgun"
local weaponDef = {
	name                    = [[Shotgun]],
	areaOfEffect            = 32,
	coreThickness           = 0.5,
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		slot = [[5]],
		muzzleEffectShot = [[custom:HEAVY_CANNON_MUZZLE]],
		altforms = {
			green = {
				explosionGenerator = [[custom:BEAMWEAPON_HIT_GREEN]],
				rgbColor = [[0 1 0]],
			},
		},

		light_camera_height = 2000,
		light_color = [[0.3 0.3 0.05]],
		light_radius = 120,
		reaim_time = 1,
	},

	damage                  = {
		default = 40.1,
	},

	duration                = 0.02,
	explosionGenerator      = [[custom:EMG_HIT_HE]],
	fireStarter             = 50,
	heightMod               = 1,
	impulseBoost            = 0,
	impulseFactor           = 1.1,
	interceptedByShieldType = 1,
	projectiles             = 20,
	range                   = 250,
	reloadtime              = 1.3,
	rgbColor                = [[1 1 0]],
	soundHit                = [[impacts/shotgun_impactv5]],
	soundStart              = [[weapon/shotgun_firev4]],
	soundStartVolume        = 0.6,
	soundTrigger            = true,
	sprayangle              = 3200,
	thickness               = 2,
	tolerance               = 10000,
	stages                  = 40,
	size					= 5,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 880,
}

return name, weaponDef
