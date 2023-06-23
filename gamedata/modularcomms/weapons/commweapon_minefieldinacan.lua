local name = "commweapon_minefieldinacan"
local weaponDef = {
	name                    = "Minefield In A Can",
	areaOfEffect            = 256,
	avoidFeature            = true,
	--cegTag                  = "RAVENTRAIL_Light",
	commandFire             = true,
	craterBoost             = 20,
	craterMult              = 1,

	customParams        = {
		is_unit_weapon = 1,
		slot = "3",
		light_camera_height = 3500,
		light_color = "0.75 0.4 0.15",
		light_radius = 220,
		manualfire = 1,
		numprojectiles1 = 18, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile1 = "commweapon_minefield_dummy",
		--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
		clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		keepmomentum1 = 0,
		timeoutspawn = 0,
		vradius1 = "-5,4,-5,5,14,5",
		noairburst = "by your powers combined", -- if true, this projectile will skip all airburst checks
		onexplode = "how can this fail", -- if true, this projectile will cluster when it explodes
		spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
		nofriendlyfire = "needs hax",
		shield_damage = 6080,
		antibaitbypass = "ärsytät minua",
	},

	damage                  = {
		default = 800,
	},

	explosionGenerator      = "custom:MEDMISSILE_EXPLOSION",
	fireStarter             = 70,
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 2,
	model                   = "depthcharge.s3o", --TODO: replace with SharkGameDev's better model. delete this once it's done.
	range                   = 520,
	reloadtime              = 20,
	smokeTrail              = true,
	soundHit                = "weapon/clusters/cluster_grenade_hit",
	soundHitVolume          = 8,
	SoundStart				= "weapon/cannon/light_launcher",
	trajectoryHeight        = 1,
	texture2                = "lightsmoketrail",
	tolerance               = 8000,
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 400,
}

return name, weaponDef
