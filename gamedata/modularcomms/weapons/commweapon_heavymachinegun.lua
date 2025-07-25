local name = "commweapon_heavymachinegun"
local weaponDef = {
	name                    = "Heavy Chain Gun",
	accuracy                = 1024,
	alphaDecay              = 0.7,
	areaOfEffect            = 96,
	burnblow                = false,
	craterBoost             = 0,
	craterMult              = 0,
	cegtag					= "hmg_trail",

	customParams            = {
		is_unit_weapon = 1,
		slot = "5",
		muzzleEffectShot = "custom:WARMUZZLE",
		miscEffectShot = "custom:DEVA_SHELLS",
		light_color = "0.8 0.76 0.38",
		light_radius = 180,
		reaim_time = 1,
		script_reload = "0.7",
		recycler = 1,
		recycle_reductiontime = 0.2,
		recycle_reduction = 0.3,
		recycle_bonus = 0.5,
		recycle_reductionframes = 0.5,
		recycle_maxbonus = 20,
	},

	damage                  = {
		default = 30.1,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = "custom:EMG_HIT_HE",
	firestarter             = 70,
	impulseBoost            = 0,
	impulseFactor           = 0.2,
	intensity               = 0.7,
	interceptedByShieldType = 1,
	impactOnly              = false,
	noSelfDamage            = true,
	range                   = 285,
	reloadtime              = 1/30,
	rgbColor                = "1 0.95 0.4",
	separation              = 1.5,
	soundHit                = "weapon/cannon/emg_hit",
	soundStart              = "weapon/sd_emgv7",
	soundStartVolume        = 7,
	stages                  = 10,
	size					= 1.8,
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 650,
}

return name, weaponDef
