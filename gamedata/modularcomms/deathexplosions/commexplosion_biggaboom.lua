local name = "commexplosion_biggaboom"
local weaponDef = {
	--name               = [[Hyvää huomenta räjähdys]],
	areaOfEffect       = 384,
	craterBoost        = 1,
	craterMult         = 3.5,
	customParams       = {
		blastwave_size = 25,
		blastwave_impulse = 30,
		blastwave_speed = 30,
		blastwave_life = 4,
		blastwave_lossfactor = 0.55,
		blastwave_damage = 3500,
		numprojectiles1 = 22, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile1 = "commexplosion_biggaboom_fragment_dummy",
		--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
		clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		keepmomentum1 = 0,
		timeoutspawn = 0,
		vradius1 = "-2,4,-2,2,8,2",
		noairburst = "by your powers combined", -- if true, this projectile will skip all airburst checks
		onexplode = "how can this fail", -- if true, this projectile will cluster when it explodes
		spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
	},
	edgeEffectiveness  = 0.4,
	explosionGenerator = "custom:ROACHPLOSION",
	explosionSpeed     = 10000,
	impulseBoost       = 0,
	impulseFactor      = 0.3,
	name               = "Explosion",
	--soundHit           = "explosion/mini_nuke",
	damage = {
		default          = 0,
	},
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
