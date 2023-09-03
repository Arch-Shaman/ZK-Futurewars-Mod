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
		numprojectiles1 = 8,
		projectile1 = "commweapon_clusterbomb_secondary",
		manualfire = 1,
		spawndist = 180,
		velspread1 = "3.82, -2, 3.82, _, 1, _",
		dyndamage = "Never gonna give you up...",
		light_camera_height = 2500,
		light_color = [[0.22 0.19 0.05]],
		light_radius = 380,
		reaim_time = 1,
		antibaitbypass = "ärsytät minua",
	},

	damage                  = {
		default = 500*8,
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
