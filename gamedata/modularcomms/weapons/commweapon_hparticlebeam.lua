local name = "commweapon_hparticlebeam"
local weaponDef = {
	name                    = "Heavy Particle Beam",
	beamDecay               = 0.9,
	beamTime                = 4/30,
	beamTTL                 = 50,
	beamDecay               = 0.85,
	coreThickness           = 0.8,
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		slot = "5",

		light_color = "0.4 1.6 0.4",
		light_radius = 100,
		use_okp = 1,
		okp_speedmult = 1,
		okp_radarmult = 1,
		okp_timeout = 20,
		okp_damage = 900,
	},

	damage                  = {
		default = 1140,
	},

	explosionGenerator      = "custom:atagreen_smoll",
	fireStarter             = 100,
	impactOnly              = true,
	impulseFactor           = 1.2,
	interceptedByShieldType = 1,
	laserFlareSize          = 13,
	minIntensity            = 0.8,
	range                   = 550,
	reloadtime              = 3.8,
	rgbColor                = "0.203 0.631 0.196",
	soundStart              = "weapon/laser/hpbeam",
	soundStartVolume        = 5,
	thickness               = 8,
	tolerance               = 8192,
	turret                  = true,
	weaponType              = "BeamLaser",
}

return name, weaponDef
