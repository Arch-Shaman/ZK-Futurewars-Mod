local name = "commexplosion_default"
local weaponDef = {
	name                    = [[Merkityksetön räjähdys]], -- katseletko minua? :P
	areaOfEffect            = 420,
	--cegTag                  = [[nucleartrail]],
	collideFriendly         = false,
	collideFeature          = false,
	--commandfire             = true,
	craterBoost             = 1,
	craterMult              = 3.5,

	customParams              = {
		blastwave_size = 64.5,
		blastwave_impulse = 5,
		blastwave_speed = 5.5,
		blastwave_life = 21,
		blastwave_lossfactor = 0.85,
		blastwave_damage = 750,
	},

	damage                  = {
		default = 0,
	},

	edgeEffectiveness       = 0.3,
	explosionGenerator      = [[custom:FLASHNUKE360]],
	fireStarter             = 0,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 65,
	--model                   = [[staticnuke_projectile.s3o]],
	noSelfDamage            = false,
	range                   = 550,
	reloadtime              = 10,
	soundHit                = [[explosion/ex_med12]],
	texture1                = [[null]], --flare
	tolerance               = 4000,
	weaponType              = [[Cannon]],
	weaponVelocity          = 800,
	size = 0.1,
}

return name, weaponDef
