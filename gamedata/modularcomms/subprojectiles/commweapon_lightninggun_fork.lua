local name = "commweapon_lightninggun_fork"
local weaponDef = {
	name                    = "Chainlightning hax",
	areaOfEffect            = 40,
	craterBoost             = 0,
	craterMult              = 0,
	--highTrajectory			= 1,
	customParams            = {
		is_unit_weapon = 1,
		extra_damage_mult = 2.5,
		reaim_time = 1,
		chainlightning_hax = 1,
		chainlightning_visual = "commweapon_chainlightning_visual",
		light_color = "0.66 0.32 0.90",
		light_radius = 0,
	},
	cylinderTargeting       = 0,
	damage                  = {
		default = 20.1,
	},
	explosionGenerator      = "custom:comm_shockhit",
	edgeEffectiveness       = 0.05,
	paralyzeTime            = 1,
	impactOnly              = true,
	interceptedByShieldType = 1,
	range					= 340,
	myGravity               = 0,
	reloadtime              = 2,
	soundHit                = "weapon/constant_electric",
	size					= 0.00001,
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 6000,
}

return name, weaponDef
