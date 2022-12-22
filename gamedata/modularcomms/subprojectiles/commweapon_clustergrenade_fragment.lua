local name = "commweapon_clustergrenade_fragment"
weaponDef = {
	name                    = [[Riot Cannon Fragment]],
	areaOfEffect            = 80,
	avoidFriendly			= false,
	collideFriendly			= false,
	craterBoost             = 100,
	craterMult              = 3,
	customparams = {
		nofriendlyfire = "needs hax",
		stats_hide_dps = 1, -- one use
		stats_hide_reload = 1,
		light_color = [[0.75 0.4 0.15]],
		light_radius = 100,
		lups_noshockwave = [[1]],
	},

	damage                  = {
		default = 150.01,
	},

	edgeEffectiveness		= 1/3,
	explosionGenerator      = [[custom:mineboom]],
	firestarter             = 180,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 1,
	myGravity               = 0.25,
	range                   = 900,
	reloadtime              = 12,
	rgbColor                = [[1 0.5 0.2]],
	size                    = 5,
	soundHit                = [[weapon/clusters/cluster_grenade_hit]],
	soundStart              = [[weapon/cannon/wolverine_fire]],
	soundStartVolume        = 3.2,
	sprayangle              = 2500,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 320,
	waterweapon				= true,
}

return name, weaponDef
-- NOTE: This weapon is a SECONDARY STAGE PROJECTILE. It is not intended for use as an actual weapon!
