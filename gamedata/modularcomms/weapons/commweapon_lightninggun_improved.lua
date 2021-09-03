local name = "commweapon_lightninggun_improved"
local weaponDef = {
	name                    = [[Heavy EMP Rifle]],
	areaOfEffect            = 64,
	cegtag					= [[antagonist_spark]],
	craterBoost             = 0,
	craterMult              = 0,
	--highTrajectory			= 1,
	burst					= 2,
	burstrate				= 0.5,
	customParams            = {
		is_unit_weapon = 1,
		extra_damage_mult = 5,
		slot = [[5]],
		muzzleeffectshot = [[custom:zeus_fire_fx]],

		light_camera_height = 1600,
		light_color = [[0.85 0.85 1.2]],
		light_radius = 200,
		reaim_time = 1,
	},
	cylinderTargeting       = 0,
	damage                  = {
		default = 600,
	},
	explosionGenerator      = [[custom:lightningplosion_nopost]],
	edgeEffectiveness       = 0.05,
	paralyzeTime            = 4,
	impactOnly              = false,
	interceptedByShieldType = 1,
	myGravity               = 0.04,
	reloadtime              = 4,
	range					= 440,
	soundHit                = [[explosion/small_emp_explode]],
	soundStart              = [[weapon/more_lightning_fast]],
	size					= 0.01,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 600,
}

return name, weaponDef
