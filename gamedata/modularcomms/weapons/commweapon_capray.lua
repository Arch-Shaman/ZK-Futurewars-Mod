local name = "commweapon_capray"
local weaponDef = {
	name                    = "Capture Ray",
	beamdecay               = 0.9,
	beamTime                = 1/30,
	beamttl                 = 3,
	coreThickness           = 0,
	craterBoost             = 0,
	craterMult              = 0,

	customparams = {
		is_unit_weapon = 1,
		capture_scaling = 1,
		is_capture = 1,
		post_capture_reload = 360,

		stats_hide_damage = 1, -- continuous laser
		stats_hide_reload = 1,
		disarmDamageMult = 5/3,
		disarmDamageOnly = 0,
		disarmTimer      = 5, -- seconds
		light_radius = 120,
		light_color = "0 0.6 0.15",
		
		reload_override = 12,
	},

	damage                  = {
		default = 17.1,
	},

	explosionGenerator      = "custom:NONE",
	fireStarter             = 30,
	impactOnly              = true,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 0,
	largeBeamLaser          = true,
	laserFlareSize          = 0,
	minIntensity            = 1,
	range                   = 450,
	reloadtime              = 1/30,
	rgbColor                = "0 0.8 0.2",
	scrollSpeed             = 2,
	soundStart              = "weapon/laser/pulse_laser2",
	soundStartVolume        = 0.5,
	soundTrigger            = true,
	sweepfire               = false,
	texture1                = "dosray",
	texture2                = "flare",
	texture3                = "flare",
	texture4                = "smallflare",
	thickness               = 4.2,
	tolerance               = 5000,
	turret                  = true,
	weaponType              = "BeamLaser",
	weaponVelocity          = 500,
	waterweapon				= true,
}

return name, weaponDef
