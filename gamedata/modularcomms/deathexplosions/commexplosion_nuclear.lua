local name = "commexplosion_nuclear"
local weaponDef = {
	name                    = [[Nuclear Overload]],
	areaOfEffect            = 1920,
	--cegTag                  = [[nucleartrail]],
	collideFriendly         = false,
	collideFeature          = false,
	--commandfire             = true,
	craterBoost             = 6,
	craterMult              = 6,

	customParams              = {
		light_color = [[2.92 2.64 1.76]],
		light_radius = 3000,
		blastwave_size = 460,
		blastwave_impulse = 13,
		blastwave_speed = 12,
		blastwave_life = 80,
		blastwave_lossfactor = 0.8,
		blastwave_damage = 700,
	},

	damage                  = {
		default = 18000.1,
	},

	edgeEffectiveness       = 0.3,
	explosionGenerator      = [[custom:LONDON_FLAT]],
	fireStarter             = 0,
	impulseBoost            = 0.5,
	impulseFactor           = 0.2,
	interceptedByShieldType = 65,
	--model                   = [[staticnuke_projectile.s3o]],
	noSelfDamage            = false,
	range                   = 72000,
	reloadtime              = 10,
	soundHit                = [[explosion/ex_ultra8]],
	texture1                = [[null]], --flare
	tolerance               = 4000,
	weaponAcceleration      = 0,
	weaponTimer             = 10,
	weaponType              = [[Cannon]],
	weaponVelocity          = 800,
	size = 0.1,
}

return name, weaponDef
