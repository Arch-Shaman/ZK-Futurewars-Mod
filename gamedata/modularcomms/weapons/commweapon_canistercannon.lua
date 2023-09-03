local name = "commweapon_canistercannon"
local weaponDef = {
	name                    = [[Heavy Canister Cannon]],
	areaOfEffect            = 0,
	avoidFeature            = true,
	avoidFriendly           = true,
	burnblow                = true,
	craterBoost             = 1,
	craterMult              = 0.5,

	customParams            = {
		gatherradius = [[90]],
		smoothradius = [[60]],
		smoothmult   = [[0.08]],
		force_ignore_ground = [[1]],
		is_unit_weapon = 1,
		slot = [[5]],
		numprojectiles1 = 8,
		projectile1 = "commweapon_impulsecannon_secondary",
		spawndist = 170,
		velspread1 = "-5.1, -1, -5.1, _, 0, _",
		proxy = 1,
		proxydist = 100,
		dyndamage = "Never gonna let you down...",
		reaim_time = 60, -- Fast update not required (maybe dangerous)
		light_camera_height = 1500,
		light_color = [[0.8 0.76 0.38]],
		light_radius = 40,
		areaofeffectoverride = 144,
	},
	
	damage                  = {
		default = 90*8,
	},
	
	edgeEffectiveness       = 0.75,
	explosionGenerator      = [[custom:FLASH64]],
	impulseBoost            = 30,
	impulseFactor           = 0.6,
	interceptedByShieldType = 1,
	noSelfDamage            = true,
	range                   = 330,
	reloadtime              = 1.4,
	soundHit                = [[weapon/clusters/cluster_light]],
	soundStart              = [[weapon/cannon/cannonfire_001]],
	soundStartVolume        = 3,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 550,
}

return name, weaponDef
