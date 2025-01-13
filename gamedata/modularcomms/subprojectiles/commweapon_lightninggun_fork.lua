local name = "chainlightning_hack"
local weaponDef = {
	name                    = "Chainlightning hax",
	areaOfEffect            = 40,
	craterBoost             = 0,
	craterMult              = 0,
	--highTrajectory			= 1,
	customParams            = {
		is_unit_weapon = 1,
		extra_damage_mult = 2.5,
		slot = "5",
		muzzleeffectshot = "custom:zeus_fire_fx",
		reaim_time = 1,
		chainlightning_hax = 1,
	},
	cylinderTargeting       = 0,
	damage                  = {
		default = 85.1,
	},
	explosionGenerator      = "custom:comm_shockhit",
	edgeEffectiveness       = 0.05,
	paralyzeTime            = 1,
	impactOnly              = false,
	interceptedByShieldType = 1,
	range					= 340,
	myGravity               = 0,
	reloadtime              = 2,
	soundHit                = "weapon/cannon/emp_arty_hit",
	soundStart              = "weapon/emp/commweapon_emplight_fire",
	size					= 0,
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 6000,
}
}

return name, weaponDef
