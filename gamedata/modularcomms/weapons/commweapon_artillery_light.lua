local name = "commweapon_artillery_light"
local weaponDef = {
	name                    = [[Light Plasma Artillery Battery]],
	accuracy                = 550,
	areaOfEffect            = 64,
	burst = 4,
	burstrate = 4/30,

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
	myGravity               = 0.09,
	noSelfDamage            = true,
	range                   = 800,
	reloadtime              = 20/30,
	sprayAngle              = 550,
	soundHit                = [[explosion/ex_med5]],
	soundStart              = [[weapon/cannon/cannon_fire1]],
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 300,
}

return name, weaponDef
