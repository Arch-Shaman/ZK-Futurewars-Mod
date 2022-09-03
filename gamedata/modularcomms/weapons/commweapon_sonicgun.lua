local name = "commweapon_sonicgun"
local weaponDef = {
	name                    = "Heavy Sonic Cannon",
	areaOfEffect            = 256,
	avoidFeature            = true,
	avoidFriendly           = true,
	burnblow                = true,
	craterBoost             = 0,
	craterMult              = 0,
	customParams            = {
		force_ignore_ground = "1",
		lups_explodelife = 1.0,
		is_unit_weapon = 1,
		muzzleEffectFire = "custom:sonicfire",
		lups_explodespeed = 0.8,
		light_radius = 120,
		blastwave_size = 8,
		blastwave_impulse = 4.2,
		blastwave_speed = 4,
		blastwave_life = 30,
		blastwave_lossfactor = 0.85,
		blastwave_damage = 200,
		damage_vs_shield = 95*4,
	},

	damage                  = {
		default = 95.01,
	},

	cegTag                  = "sonicarcher",
	cylinderTargeting       = 1,
	explosionGenerator      = "custom:sonic_128",
	edgeEffectiveness       = 0.5,
	fireStarter             = 150,
	impulseBoost            = 100,
	impulseFactor           = 0.5,
	interceptedByShieldType = 1,
	myGravity               = 0.01,
	noSelfDamage            = true,
	range                   = 340,
	reloadtime              = 2.2,
	size                    = 50,
	sizeDecay               = 0.2,
	soundStart              = "weapon/cannon/heavy_sonic2_hit",
	soundHit                = "weapon/cannon/comm_sonic_fire",
	soundStartVolume        = 6,
	soundHitVolume          = 10,
	stages                  = 1,
	texture1                = "sonic_glow2",
	texture2                = "null",
	texture3                = "null",
	rgbColor                = {0.2, 0.6, 0.8},
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 780,
	waterweapon             = true,
	duration                = 0.15,
}

return name, weaponDef
