local name = "commweapon_disintegrator"
local weaponDef = {
	name                    = "Heavy Disintegrator Rifle",
	areaOfEffect            = 64,
	avoidFeature            = false,
	avoidFriendly           = true,
	avoidGround             = false,
	avoidNeutral            = false,
	craterBoost             = 6,
	craterMult              = 6,
	cegtag					= "dgun_trail",

	customParams            = {
		is_unit_weapon = 1,
		muzzleEffectShot = "custom:ataalaser",
		slot = "3",
		reaim_time = 1,
		antibaitbypass = "ärsytät minua",
		mass = 600.5,
	},

	damage                  = {
		default    = 500,
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
	reloadtime              = 2.0,
	size                    = 6,
	soundHit                = "explosion/ex_med6",
	soundStart              = "weapon/laser/dgun_fire",
	soundTrigger            = true,
	turret                  = true,
	targetBorder            = 1, -- aim for the close border instead of the center.
	waterWeapon             = true,
	weaponType              = "Cannon",
	weaponVelocity          = 400,
}

return name, weaponDef
