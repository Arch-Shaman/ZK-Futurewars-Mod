local name = "commweapon_canistercannon"
local weaponDef = {
	name                    = [[Medium Canister Cannon]],
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
		numprojectiles1 = 6, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile1 = "commweapon_impulsecannon_secondary",
		--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
		clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		spawndist = 100, -- at what distance should we spawn the projectile(s)? REQUIRED.
		timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
		vradius1 = "-4,-1,-4,4,0,4", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
		groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
		proxy = 1, -- check for nearby units?
		proxydist = 100, -- how far to check for units? Default: spawndist
		dyndamage = "Never gonna let you down...",
		reaim_time = 60, -- Fast update not required (maybe dangerous)
		light_camera_height = 1500,
		light_color = [[0.8 0.76 0.38]],
		light_radius = 40,
	},
	
	damage                  = {
		default = 70*6,
	},
	
	edgeEffectiveness       = 0.75,
	explosionGenerator      = [[custom:FLASH64]],
	impulseBoost            = 30,
	impulseFactor           = 0.6,
	interceptedByShieldType = 1,
	noSelfDamage            = true,
	range                   = 280,
	reloadtime              = 2,
	soundHit                = [[weapon/clusters/cluster_light]],
	soundStart              = [[weapon/cannon/cannonfire_001]],
	soundStartVolume        = 3,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 550,
}

return name, weaponDef
