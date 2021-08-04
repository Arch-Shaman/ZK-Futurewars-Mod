local name = "commexplosion_boom"
local weaponDef = {
	name               = [[Hyvää huomenta räjähdys]],
	areaOfEffect       = 384,
	craterBoost        = 1,
	craterMult         = 3.5,
	customParams       = {
		blastwave_size = 25,
		blastwave_impulse = 30,
		blastwave_speed = 30,
		blastwave_life = 4,
		blastwave_lossfactor = 0.55,
		blastwave_damage = 4500,
	},
	edgeEffectiveness  = 0.4,
	explosionGenerator = "custom:ROACHPLOSION",
	explosionSpeed     = 10000,
	impulseBoost       = 0,
	impulseFactor      = 0.3,
	name               = "Explosion",
	soundHit           = "explosion/mini_nuke",
	damage = {
		default          = 0,
	},
	--model                   = [[crblmsslr.s3o]],
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
