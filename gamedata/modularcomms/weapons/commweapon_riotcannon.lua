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
		numprojectiles1 = 9, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile1 = "commweapon_riotcannon_fragment_dummy",
		--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
		clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		keepmomentum1 = 0,
		timeoutspawn = 0,
		vradius1 = "-2,4,-2,2,14,2",
		noairburst = "by your powers combined", -- if true, this projectile will skip all airburst checks
		onexplode = "how can this fail", -- if true, this projectile will cluster when it explodes
		spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
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
