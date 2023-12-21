local name = "commweapon_disruptorbomb"
local weaponDef = {
	name                    = "Disruptor Bomb",
	accuracy                = 256,
	areaOfEffect            = 512,
	cegTag                  = "beamweapon_muzzle_purple",
	commandFire             = true,
	craterBoost             = 0,
	craterMult              = 0,

	customParams            = {
		is_unit_weapon = 1,
		slot = "3",
		--timeslow_preset       = "module_disruptorbomb",
		timeslow_damagefactor = "6",
		muzzleEffectFire = "custom:RAIDMUZZLE",
		manualfire = 1,
		nofriendlyfire = "needs hax",

		light_camera_height = 2500,
		light_color = "1.5 0.75 1.8",
		light_radius = 280,
		reaim_time = 1,
		antibaitbypass = "ärsytät minua",
		blastwave_size = 30,
		blastwave_impulse = 0,
		blastwave_speed = 5,
		blastwave_life = 45,
		blastwave_lossfactor = 0.82,
		blastwave_damage = 780,
		blastwave_nofriendly = "Your life is the price of progress.",
		blastwave_slowdmg = 4680,
	},

	damage                  = {
		default = 100,
	},

	explosionGenerator      = "custom:riotballplus2_purple",
	explosionSpeed          = 5,
	fireStarter             = 100,
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 2,
	model                   = "wep_b_fabby.s3o",
	range                   = 450,
	reloadtime              = 25,
	smokeTrail              = true,
    soundHit                = "weapon/aoe_aura2",
	soundHitVolume          = 8,
	soundStart              = "weapon/cannon/cannon_fire3",
	--startVelocity           = 350,
	--trajectoryHeight        = 0.3,
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 350,
}

return name, weaponDef
