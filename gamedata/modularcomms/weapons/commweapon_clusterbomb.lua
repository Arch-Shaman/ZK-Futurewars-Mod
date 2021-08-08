local name = "commweapon_clusterbomb"
local weaponDef = {
	name                    = [[Cluster Bomb Launcher]],
	avoidFeature            = false,
	avoidNeutral            = false,
	areaOfEffect            = 160,
	burst                   = 1,
	--burstRate               = 0.5,
	commandFire             = true,
	craterBoost             = 1,
	craterMult              = 2,

	customParams            = {
		is_unit_weapon = 1,
		miscEffectFire = [[custom:RIOT_SHELL_H]],
		projectile1 = "commweapon_clusterbomb_secondary",
		numprojectiles1 = 6,
		manualfire = 1,
		clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		spawndist = 180, -- at what distance should we spawn the projectile(s)? REQUIRED.
		timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
		vradius1 = "-2,-1,-2,2,0,2", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
		dyndamage = "Never gonna give you up...",
		light_camera_height = 2500,
		light_color = [[0.22 0.19 0.05]],
		light_radius = 380,
		reaim_time = 1,
		antibaitbypass = "ärsytät minua",
	},

	damage                  = {
		default = 500*6,
	},

	explosionGenerator      = [[custom:WEAPEXP_PUFF]],
	fireStarter             = 180,
	impulseBoost            = 0,
	impulseFactor           = 0.2,
	interceptedByShieldType = 2,
	model                   = [[hovermissile.s3o]],
	mygravity				= 0.06,
	range                   = 400,
	reloadtime              = 12,
	smokeTrail              = true,
	soundHit                = [[weapon/cannon/cannonfire_001]],
	SoundStart				= [[weapon/cannon/medium_launcher]],
	soundHitVolume          = 8,
	soundStartVolume		= 75,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 400,
}

return name, weaponDef
