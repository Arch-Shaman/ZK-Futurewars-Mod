local name = "commweapon_artillery_heavy_nuclear"
local weaponDef = {
	name                    = "Heavy Nuclear Artillery",
	accuracy                = 1100,
	sprayangle				= 1100,
	areaOfEffect            = 192,
	craterBoost             = 20,
	craterMult              = 2.5,
	burst = 6,
	burstrate = 1/3,

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectFire = "custom:HEAVY_CANNON_MUZZLE",
		miscEffectFire = "custom:RIOT_SHELL_H",

		light_color = "1.4 0.8 0.3",
		reaim_time = 1,
		reveal_unit = 30,
		onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
	},

	damage                  = {
		default = 1500,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = "custom:NUKE_150",
	model                   = "wep_m_phoenix_fixed.dae",
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 9,
	myGravity               = 0.3,
	hightrajectory          = 1,
	range                   = 800,
	reloadtime              = 25,
	noselfdamage			= false,
	soundHit                = "explosion/mini_nuke_2",
	soundStart              = "weapon/cannon/crabe_cannon",
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 1000,
}

return name, weaponDef
