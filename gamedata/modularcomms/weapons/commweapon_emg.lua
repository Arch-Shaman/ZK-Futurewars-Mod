local name = "commweapon_emg"
local weaponDef = {
	name                    = "Medium EMG Rifle",
	areaOfEffect            = 8,
	craterBoost             = 0,
	craterMult              = 0,
	accuracy				= 100,

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectShot = "custom:LEVLRMUZZLE_CLOUDLESS",
		--miscEffectShot = "custom:emg_shells_l",
		antibaitbypass = "ärsytät minua",
		light_color = "0.8 0.76 0.38",
		light_radius = 120,
		reaim_time = 1,
	},

	damage                  = {
		default = 37.1,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = "custom:EMG_HIT_HE",
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	predictBoost			= 1,
	myGravity               = 0.1,
	range                   = 300,
	reloadtime              = .1,
	soundHit                = "weapon/cannon/cannon_hit1",
	soundStart              = "weapon/cannon/heavy_rifle_fire",
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 580,
}

return name, weaponDef
