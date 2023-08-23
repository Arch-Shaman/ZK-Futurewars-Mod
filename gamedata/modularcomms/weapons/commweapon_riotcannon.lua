local name = "commweapon_riotcannon"
local weaponDef = {
	name                    = [[Heavy Riot Burst]],
	areaOfEffect            = 144,
	avoidFeature            = true,
	avoidFriendly           = true,
	craterBoost             = 1,
	craterMult              = 2,
	customParams            = {
		is_unit_weapon = 1,
		slot = [[5]],
		muzzleEffectFire = [[custom:HEAVY_CANNON_MUZZLE]],
		miscEffectFire   = [[custom:RIOT_SHELL_L]],
		
		light_camera_height = 1500,
		reaim_time = 1,
		numprojectiles1 = 9,
		projectile1 = "commweapon_riotcannon_fragment_dummy",
		velspread1 = "2.55 , 4, 2.55, _, 10, _",
		noairburst = "by your powers combined",
		onexplode = "how can this fail",
	},

	damage                  = {
		default = 520.2,
	},
	edgeEffectiveness       = 0.75,
	explosionGenerator      = [[custom:FLASH64]],
	fireStarter             = 150,
	impulseBoost            = 60,
	impulseFactor           = 0.5,
	interceptedByShieldType = 1,
	noSelfDamage            = true,
	range                   = 300,
	reloadtime              = 95/30,
	soundHit                = [[weapon/cannon/generic_cannon]],
	soundStart              = [[weapon/cannon/outlaw_gun]],
	soundStartVolume        = 3,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 700,
}

return name, weaponDef
