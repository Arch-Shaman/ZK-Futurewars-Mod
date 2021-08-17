local name = "commweapon_napalmgrenade"
local weaponDef = {
	name                    = [[Hellfire Grenade]], --CREDITS: Cliver5
	areaOfEffect            = 256,
	avoidFeature            = true,
	--cegTag                  = [[missiletrailred]],
	commandFire             = true,
	craterBoost             = 0,
	craterMult              = 0,

	customParams        = {
		is_unit_weapon = 1,
		slot = [[3]],
		light_camera_height = 3500,
		light_color = [[0.75 0.4 0.15]],
		light_radius = 220,
		manualfire = 1,
		numprojectiles1 = 24, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile1 = "commweapon_napalm_fragment_dummy",
		--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
		clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		keepmomentum1 = 0,
		timeoutspawn = 0,
		vradius1 = "-4.5,4,-4.5,4.5,6,4.5",
		noairburst = "by your powers combined", -- if true, this projectile will skip all airburst checks
		onexplode = "how can this fail", -- if true, this projectile will cluster when it explodes
		spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
		area_damage = 1,
		area_damage_radius = 128,
		area_damage_dps = 40,
		area_damage_duration = 12,
		antibaitbypass = "ärsytät minua",
	},

	damage                  = {
		default = 1440,
	},

	explosionGenerator      = [[custom:napalm_hellfire]],
	fireStarter             = 70,
	flightTime              = 3,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 2,
	model                   = [[wep_b_fabby.s3o]], --TODO: replace with SharkGameDev's better model. delete this once it's done.
	range                   = 440,
	reloadtime              = 14,
	smokeTrail              = true,
	soundHit                = [[weapon/missile/nalpalm_missile_hit]],
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
