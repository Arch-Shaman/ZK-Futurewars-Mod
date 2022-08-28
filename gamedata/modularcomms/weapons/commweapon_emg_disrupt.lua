local name = "commweapon_emg_disrupt"
local weaponDef = {
	name                    = [[Medium EMG Disruption Rifle]],
	areaOfEffect            = 8,
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectFire = [[custom:HEAVY_CANNON_MUZZLE]],
		miscEffectFire = [[custom:emg_shells_l]],
		timeslow_damageFactor = 2,
		light_color = [[1.3 0.5 1.6]],
		light_radius = 120,
		reaim_time = 1,
		antibaitbypass = "ärsytät minua",
	},

	damage                  = {
		default = 37.1*0.85,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = [[custom:BEAMWEAPON_HIT_PURPLE]],
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	myGravity               = 0.1,
	range                   = 300,
	reloadtime              = .1,
	rgbColor				= "0.9 0.1 0.9",
	soundHit                = [[weapon/cannon/cannon_hit1]],
	soundStart              = [[weapon/heavy_machinegun]],
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 580,
}

return name, weaponDef
