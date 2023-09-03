local name = "commweapon_heatray"
local weaponDef = {
	name                    = [[Heat Ray]],
	areaOfEffect            = 20,
	beamtime				= 4/30,
	coreThickness           = 1,
	craterBoost             = 0,
	craterMult              = 0,
	cylinderTargeting 		= 0.6,

	customParams            = {
		is_unit_weapon = 1,
		slot = [[5]],

		light_camera_height = 1500,
		light_color = [[0.9 0.4 0.12]],
		light_radius = 180,
		light_fade_time = 25,
		light_fade_offset = 10,
		light_beam_mult_frames = 9,
		light_beam_mult = 8,
		reaim_time = 1,
	},

	damage                  = {
		default = 88.01,
	},

	duration                = 0.3,
	dynDamageExp            = 1,
	dynDamageInverted       = false,
	explosionGenerator      = [[custom:HEATRAY_HIT]],
	fallOffRate             = 1,
	fireStarter             = 150,
	heightMod               = 1,
	impactOnly              = true,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 1,
	lodDistance             = 10000,
	proximityPriority       = 4,
	range                   = 330,
	reloadtime              = 0.1,
	rgbColor                = [[1 0.1 0]],
	rgbColor2               = [[1 1 0.25]],
	soundStart              = [[weapon/heatray_fire]],
	thickness               = 3,
	tolerance               = 5000,
	turret                  = true,
	weaponType              = [[BeamLaser]],
	weaponVelocity          = 500,
}

return name, weaponDef
