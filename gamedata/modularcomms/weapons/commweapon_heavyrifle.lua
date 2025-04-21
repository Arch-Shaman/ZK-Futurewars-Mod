local name = "commweapon_heavyrifle"
local weaponDef = {
	name                    = "Heavy Rifle",
	areaOfEffect            = 96,
	burst                   = 6,
	burstrate               = 0.1,
	craterBoost             = 0,
	craterMult              = 0,
	cegtag					= "hmg_trail",
	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectShot = "custom:HEAVY_CANNON_MUZZLE",
		miscEffectFire = "custom:emg_shells_l",
		--muzzleEffectShot = "custom:LEVLRMUZZLE_CLOUDLESS",
		light_color = "0.8 0.76 0.38",
		light_radius = 120,
		reaim_time = 1,
		antibaitbypass = "ärsytät minua",
	},
	damage                  = {
		default = 89.1,
	},
	edgeEffectiveness       = 0.5,
	explosionGenerator      = "custom:EMG_HIT_HE",
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 1,
	myGravity               = 0.1,
	range                   = 320,
	reloadtime              = 2,
	soundHit                = "weapon/cannon/cannon_hit1",
	soundStart              = "weapon/cannon/med_rifle_fire",
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 1050,
}

return name, weaponDef
