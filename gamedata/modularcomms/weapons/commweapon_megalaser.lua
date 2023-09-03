local name = "commweapon_megalaser"
local weaponDef = {
	name                    = "Brillant Star Tactical Laser",
	areaOfEffect            = 255,
	avoidFeature 			= false,
	avoidGround  			= false,
	beamTime                = 1.5,
	coreThickness           = 0.5,
	craterBoost             = 4,
	craterMult              = 10,
	commandFire             = true,
	customParams            = {
		is_unit_weapon = 1,
		manualfire = 1,
		slot = "3",
		light_color = "1.25 0.8 1.75",
		light_radius = 255,
		reveal_unit = 66,
		shield_damage = 9000*(3/4),
		use_okp = 1,
		okp_speedmult = 1,
		okp_radarmult = 1,
		okp_timeout = 120,
		okp_damage = 9000.1,
	},
	damage                  = {
		default = 9000.1,
	},
	explosionGenerator      = "custom:craterpuncher_short",
	explosionScar           = false,
	fireTolerance           = 8192, -- 45 degrees
	impactOnly              = false,
	cameraShake				= 100,
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	largeBeamLaser          = true,
	laserFlareSize          = 3,
	leadLimit               = 18,
	minIntensity            = 0.4,
	noSelfDamage            = true,
	range                   = 800,
	reloadtime              = 45,
	rgbColor                = "0.25 0.11 1",
	soundStart              = "weapon/laser/heavy_tactical_laser_fire",
	soundStartVolume        = 15,
	sweepfire               = true,
	texture1                = "largelaser",
	texture2                = "flare",
	texture3                = "flare",
	thickness               = 33.8747693719086,
	tolerance               = 10000,
	turret                  = true,
	weaponType              = "BeamLaser",
}

return name, weaponDef
