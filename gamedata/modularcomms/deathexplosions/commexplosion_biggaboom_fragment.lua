local name = "commexplosion_biggaboom_fragment"
local weaponDef = {
	name                    = [[Cluster Grenade Fragment]],
	accuracy                = 400,
	areaOfEffect            = 160,
	avoidFeature            = false,
	craterBoost             = 1,
	craterMult              = 4,
	--cegTag                  = [[flamer]],
	customParams              = {
		--lups_heat_fx = [[firewalker]],
		light_camera_height = 2500,
		light_color = [[0.25 0.13 0.05]],
		light_radius = 500,
		blastwave_size = 25,
		blastwave_impulse = 1.3,
		blastwave_speed = 30,
		blastwave_life = 4,
		blastwave_lossfactor = 0.55,
		blastwave_damage = 3500,
		shield_damage = 1500,
	},
	damage                  = {
		default = 0,
	},
	model                   = [[diskball.s3o]],
	explosionGenerator      = [[custom:ROACHPLOSION]],
	firestarter             = 180,
	impulseBoost            = 6,
	impulseFactor           = 5,
	interceptedByShieldType = 1,
	myGravity               = 0.25,
	range                   = 900,
	reloadtime              = 12,
	rgbColor                = [[1 0.5 0.2]],
	size                    = 5,
	soundHit                = [[explosion/ex_med12]],
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
