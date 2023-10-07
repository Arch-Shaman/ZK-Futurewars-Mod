local name = "commweapon_artillery_light_nuclear"
local weaponDef = {
	name                    = "Heavy Rapid Fire Plasma Battery",
	accuracy                = 550,
	areaOfEffect            = 128,

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectFire = "custom:thud_fire_fx",
		reaim_time = 1,
	},

	craterBoost             = 40,
	craterMult              = 2,

	damage                  = {
		default = 80,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = "custom:MEDMISSILE_EXPLOSION",
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	noSelfDamage            = true,
	range                   = 800,
	reloadtime              = 10/30,
	soundHit                = "explosion/explosion_roach",
	soundStart              = "weapon/cannon/tremor_fire",
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 420,
	myGravity               = 0.1,
}

return name, weaponDef
