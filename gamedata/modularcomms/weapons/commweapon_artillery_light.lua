local name = "commweapon_artillery_light"
local weaponDef = {
	name                    = [[Rapid Fire Plasma Battery]],
	accuracy                = 550,
	areaOfEffect            = 64,

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectFire = [[custom:thud_fire_fx]],
		reaim_time = 1,
	},

	craterBoost             = 0,
	craterMult              = 0,

	damage                  = {
		default = 40,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = [[custom:INGEBORG]],
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	noSelfDamage            = true,
	range                   = 800,
	reloadtime              = 8/30,
	soundHit                = [[explosion/ex_med5]],
	soundStart              = [[weapon/cannon/cannon_fire1]],
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 420,
	myGravity               = 0.1,
}

return name, weaponDef
