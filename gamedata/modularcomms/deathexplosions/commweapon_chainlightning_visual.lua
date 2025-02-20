local name = "commweapon_chainlightning_visual"
local weaponDef = {
	name                    = "Visual Chain Lightning",
	areaOfEffect            = 8,
	craterBoost             = 0,
	craterMult              = 0,
	beamTTL                 = 3,
	customParams            = {
		light_camera_height = 1600,
		light_color = "0.1875 0.1875 0.75",
		light_radius = 20,
		hideweapon = 1,
	},
	cylinderTargeting      = 0,
	damage                  = {
		default        = 0,
	},
	duration                = 10,
	explosionGenerator      = "custom:NONE",
	fireStarter             = 150,
	impactOnly              = true,
	impulseBoost            = 0,
	impulseFactor           = 0,
	intensity               = 12,
	interceptedByShieldType = 1,
	paralyzeTime            = 2,
	range                   = 9000,
	reloadtime              = 2.6,
	rgbColor                = "0.1875 0.1875 0.75",
	soundHit                = "weapon/emp/lightningcannon_hit",
	texture1                = "lightning",
	thickness               = 7,
	turret                  = true,
	weaponType              = "LightningCannon",
	weaponVelocity          = 400,
}

return name, weaponDef
