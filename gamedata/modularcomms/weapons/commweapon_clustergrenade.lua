local name = "commweapon_clustergrenade"
local weaponDef = {
	name                    = [[Cluster Grenade]],
	areaOfEffect            = 256,
	avoidFeature            = true,
	cegTag                  = [[RAVENTRAIL_Light]],
	commandFire             = true,
	craterBoost             = 20,
	craterMult              = 1,

	customParams        = {
		is_unit_weapon = 1,
		slot = [[3]],
		light_camera_height = 3500,
		light_color = [[0.75 0.4 0.15]],
		light_radius = 220,
		manualfire = 1,
		numprojectiles1 = 24,
		projectile1 = "commweapon_clustergrenade_fragment_dummy",
		velspread1 = "5.73, 4, 5.73, _, 6, _",
		noairburst = "by your powers combined",
		onexplode = "how can this fail",
	},

	damage                  = {
		default = 1920,
	},

	explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],
	fireStarter             = 70,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 2,
	model                   = [[wep_b_fabby.s3o]], --TODO: replace with SharkGameDev's better model. delete this once it's done.
	range                   = 440,
	reloadtime              = 14,
	smokeTrail              = true,
	soundHit                = [[weapon/clusters/cluster_grenade_hit]],
	soundHitVolume          = 8,
	SoundStart				= [[weapon/cannon/light_launcher]],
	trajectoryHeight        = 1,
	texture2                = [[lightsmoketrail]],
	tolerance               = 8000,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 400,
}

return name, weaponDef
