local name = "commweapon_impulsecannon_secondary"
local weaponDef = {
	name                    = [[Heavy Canister Shot]],
	accuracy                = 350,
	alphaDecay              = 0.7,
	areaOfEffect            = 96,
	burnblow                = true,
	burst                   = 3,
	burstrate               = 0.1,
	craterBoost             = 0.15,
	craterMult              = 0.3,

	customParams        = {
		gatherradius = [[90]],
		smoothradius = [[60]],
		smoothmult   = [[0.08]],
		light_camera_height = 1600,
		light_color = [[0.8 0.76 0.38]],
		light_radius = 40,
		isFlak = 2,
		blastwave_size = 10,
		blastwave_impulse = 0.9,
		blastwave_speed = 3,
		blastwave_life = 10,
		blastwave_lossfactor = 0.88,
		blastwave_damage = 1.25,
	},
	
	damage                  = {
		default = 90.01,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = [[custom:EMG_HIT_HE]],
	firestarter             = 70,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	intensity               = 0.7,
	interceptedByShieldType = 1,
	noSelfDamage            = true,
	range                   = 275,
	reloadtime              = 0.5,
	rgbColor                = [[1 0.95 0.4]],
	separation              = 1.5,
	soundHit                = [[weapon/cannon/emg_hit]],
	soundStart              = [[weapon/heavy_emg]],
	stages                  = 10,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 550,
}

return name, weaponDef

-- NOTE: This weapon is a SECONDARY STAGE PROJECTILE. It is not intended for use as an actual weapon!