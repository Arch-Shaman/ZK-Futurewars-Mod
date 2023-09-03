local name = "commweapon_heavy_disruptor"
local weaponDef = {
	name                    = [[Heavy Disruptor Pulse Beam]],
	beamdecay               = 0.9,
	beamTime                = 4/30,
	beamttl                 = 50,
	beamDecay               = 0.85,
	coreThickness           = 0.8,
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		--timeslow_preset       = [[module_disruptorbeam]],
		timeslow_damagefactor = [[3]],
		timeslow_overslow_frames = 4*30,
		light_color = [[1.047 0.741 2.525]],
		light_radius = 100,
		reaim_time = 1,
		use_okp = 1,
		okp_speedmult = 1,
		okp_radarmult = 1,
		okp_timeout = 20,
		okp_damage = 720,
	},

	damage                  = {
		default = 912, 
	},

	explosionGenerator      = [[custom:atapurple]],
	fireStarter             = 100,
	impactOnly              = true,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	laserFlareSize          = 13,
	minIntensity            = 0.8,
	noSelfDamage            = true,
	range                   = 550,
	reloadtime              = 3.8,
	rgbColor                = [[0.239 0.006 0.341]],
	soundStart              = [[weapon/laser/hpbeamslow]],
	soundStartVolume        = 7,
	thickness               = 8,
	tolerance               = 8192,
	turret                  = true,
	weaponType              = [[BeamLaser]],
}

return name, weaponDef
