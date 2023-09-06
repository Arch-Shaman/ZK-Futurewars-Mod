local name = "commweapon_light_disintegrator"
local weaponDef = {
	name                    = "Light Disintegrator Rifle",
	areaOfEffect            = 32,
	avoidFeature            = false,
	avoidFriendly           = true,
	avoidGround             = false,
	avoidNeutral            = false,
	craterBoost             = 0,
	craterMult              = 0,
	cegtag					= "light_dgun_trail",

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectShot = "custom:ataalaser",
		slot = "3",
		reaim_time = 1,
		antibaitbypass = "ärsytät minua",
		mass = 150.5,
		groundnoexplode = 1,
	},

	damage                  = {
		default    = 175,
	},

	explosionGenerator      = "custom:DGUNTRACE",
	explosionScar			= false,
	impulseBoost            = 0,
	impulseFactor           = 0,
	interceptedByShieldType = 0,
	intensity				= 0, -- hide the projectile from user, use CEG trail instead! FIXME: check graphics to set to 0.2?
	myGravity				= 0.03,
	noExplode               = true,
	noSelfDamage            = true,
	range                   = 270,
	reloadtime              = 1.5,
	size                    = 6,
	soundHit                = "explosion/light_dgun_hit",
	soundStart              = "weapon/laser/light_dgun_fire",
	soundTrigger            = true,
	turret                  = true,
	targetBorder            = 1, -- aim for the close border instead of the center.
	waterWeapon             = true,
	weaponType              = "Cannon",
	weaponVelocity          = 400,
}

return name, weaponDef
