local name = "commweapon_napalmgrenade"
local weaponDef = {
	name                    = "Hellfire Grenade", --CREDITS: Cliver5
	areaOfEffect            = 256,
	avoidFeature            = true,
	--cegTag                  = "missiletrailred",
	commandFire             = true,
	craterBoost             = 0,
	craterMult              = 0,

	customParams        = {
		is_unit_weapon = 1,
		slot = "3",
		light_camera_height = 3500,
		light_color = "0.75 0.4 0.15",
		light_radius = 220,
		manualfire = 1,
		numprojectiles1 = 48,
		projectile1 = "commweapon_napalm_fragment_dummy",
		velspread1 = "5.73, 4, 5.73, _, 6, _",
		noairburst = "by your powers combined",
		onexplode = "how can this fail",
		area_damage = 1,
		area_damage_radius = 128,
		area_damage_dps = 120,
		area_damage_duration = 12,
		antibaitbypass = "ärsytät minua",
	},

	damage                  = {
		default = 120,
	},

	explosionGenerator      = "custom:napalm_hellfire",
	fireStarter             = 70,
	flightTime              = 3,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 2,
	model                   = "wep_b_fabby.s3o", --TODO: replace with SharkGameDev's better model. delete this once it's done.
	range                   = 440,
	reloadtime              = 14,
	smokeTrail              = true,
	soundHit                = "weapon/missile/nalpalm_missile_hit",
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
