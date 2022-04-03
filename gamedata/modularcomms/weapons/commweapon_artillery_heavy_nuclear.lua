local name = "commweapon_artillery_heavy_nuclear"
local weaponDef = {
	name                    = [[Heavy Nuclear Artillery]],
	accuracy                = 600,
	areaOfEffect            = 192,
	craterBoost             = 20,
	craterMult              = 2.5,

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectFire = [[custom:HEAVY_CANNON_MUZZLE]],
		miscEffectFire = [[custom:RIOT_SHELL_H]],

		light_color = [[1.4 0.8 0.3]],
		reaim_time = 1,
		reveal_unit = 20,
		use_okp = 1,
		okp_speedmult = 0.3,
		okp_radarmult = 1,
		okp_timeout = 80,
		okp_damage = 2500,
	},

	damage                  = {
		default = 2500,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = [[custom:NUKE_150]],
	model                   = [[wep_m_phoenix.s3o]],
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 1,
	myGravity               = 0.05,
	range                   = 800,
	reloadtime              = 16,
	noselfdamage			= false,
	soundHit                = [[explosion/mini_nuke_2]],
	soundStart              = [[weapon/cannon/battleship_fire]],
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 220,
}

return name, weaponDef
