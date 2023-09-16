local name = "commweapon_vacuumgun"
local weaponDef = {
	name                    = [[Vacuum Gun]],
	areaOfEffect            = 400,
	commandfire             = true,
	avoidFeature            = false,
	avoidFriendly           = false,
	burnblow                = false,
	craterBoost             = 0,
	craterMult              = 0,
	cegtag                  = [[energeticblackhole_trail]],
	customParams            = {
		is_unit_weapon = 1,
		manualfire = 1,
		light_color = [[0 .8 1 .1]],
		light_radius = 500,
		lups_explodelife = 1.0,
		lups_explodespeed = 0.5,
		light_radius = 80,
		blastwave_size = 200,
		blastwave_impulse = -2.5,
		blastwave_speed = -6.6,
		blastwave_life = 30,
		blastwave_lossfactor = 0.85,
		blastwave_damage = 40,
	},

	damage                  = {
		default = 1000, --make it not suck vs shields
	},

	explosionGenerator      = [[custom:energeticblackhole_112]], -- technically it's 400, but i can't be assed to rename.
	explosionSpeed          = 50,
	impulseBoost            = 150,
	impulseFactor           = -2.5,
	intensity               = 0.9,
	interceptedByShieldType = 1,
	myGravity               = 0.1,
	projectiles             = 1,
	range                   = 500,
	reloadtime              = 30,
	rgbColor                = [[0.05 0.05 0.05]],
	size                    = 3,
	soundHit                = [[weapon/impacts/impulsewave1]],
	soundStart              = [[weapon/cannon/commblackhole_fire]],
	soundStartVolume        = 100,
	soundHitVolume          = 100,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 550,
}

return name, weaponDef
