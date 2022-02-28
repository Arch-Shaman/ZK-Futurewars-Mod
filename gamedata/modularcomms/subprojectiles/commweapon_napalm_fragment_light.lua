local name = "commweapon_napalmgrenade_fragment_light"
weaponDef = {
	name                    = [[Napalm Fragment]],
	accuracy                = 400,
	areaOfEffect            = 128,
	avoidFeature            = false,
	craterBoost             = 0,
	craterMult              = 0,
	cegTag                  = [[flamer]],
	customParams              = {
		setunitsonfire = "1",
		burntime = 60,
		area_damage = 1,
		area_damage_radius = 64,
		area_damage_dps = 15,
		area_damage_duration = 10,
		--lups_heat_fx = [[firewalker]],
		light_camera_height = 2500,
		light_color = [[0.25 0.13 0.05]],
		light_radius = 500,
	},
	damage                  = {
		default = 30,
	},

	explosionGenerator      = [[custom:napalm_firewalker_small]],
	firestarter             = 180,
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 1,
	myGravity               = 0.25,
	projectiles             = 10,
	range                   = 900,
	reloadtime              = 12,
	rgbColor                = [[1 0.5 0.2]],
	size                    = 5,
	soundHit                = [[weapon/clusters/napalm_break]],
	soundStart              = [[weapon/cannon/wolverine_fire]],
	soundStartVolume        = 3.2,
	sprayangle              = 2500,
	turret                  = true,
	weaponType              = [[Cannon]],
	weaponVelocity          = 320,
}

return name, weaponDef
-- NOTE: This weapon is a SECONDARY STAGE PROJECTILE. It is not intended for use as an actual weapon!
