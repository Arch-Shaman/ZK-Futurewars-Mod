local name = "commweapon_heavy_disruptor"
local weaponDef = {
	name                    = [[Heavy Disruptor Pulse Beam]],
	beamdecay               = 0.9,
	beamTime                = 3/30,
	beamttl                 = 90,
	coreThickness           = 0.5,
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		--timeslow_preset       = [[module_disruptorbeam]],
		timeslow_damagefactor = [[3]],
		timeslow_overslow_frames = 5*30,
		light_color = [[2.093 1.481 5.049]],
		light_radius = 120,
		reaim_time = 1,
		use_okp = 1,
		okp_speedmult = 1,
		okp_radarmult = 1,
		okp_timeout = 20,
		okp_damage = 720,
	},

	damage                  = {
		default = 720, 
	},

	explosionGenerator      = [[custom:atapurple]],
	fireStarter             = 100,
	impactOnly              = true,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	laserFlareSize          = 10,
	minIntensity            = 1,
	noSelfDamage            = true,
	range                   = 550,
	reloadtime              = 3.0,
	rgbColor                = [[0.334 0.851 0.80784]],
	soundStart              = [[weapon/laser/hpbeamslow]],
	soundStartVolume        = 7,
	thickness               = 8,
	tolerance               = 8192,
	turret                  = true,
	weaponType              = [[BeamLaser]],
}

return name, weaponDef
