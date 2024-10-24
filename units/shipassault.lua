local shipassault = {
	unitname               = "shipassault",
	name                   = "Tsumani",
	description            = "Naval Superemecy Vessel",
	acceleration           = 0.25,
	activateWhenBuilt      = true,
	brakeRate              = 1.7,
	buildCostMetal         = 1200,
	builder                = false,
	buildPic               = "shipassault.png",
	canMove                = true,
	category               = "SHIP",
	collisionVolumeOffsets = "0 1 3",
	collisionVolumeScales  = "32 32 132",
	collisionVolumeType    = "cylZ",
	corpse                 = "DEAD",

	customParams           = {
		bait_level_default = 1,
		--extradrawrange = 200,
		modelradius    = "55",
		turnatfullspeed = "1",
		outline_x = 160,
		outline_y = 160,
		outline_yoff = 25,
	},

	explodeAs              = "BIG_UNITEX",
	floater                = true,
	footprintX             = 4,
	footprintZ             = 4,
	iconType               = "shiparty",
	idleAutoHeal           = 5,
	idleTime               = 1800,
	losEmitHeight          = 25,
	health                 = 15000,
	speed                  = 84,
	minWaterDepth          = 10,
	movementClass          = "BOAT4",
	moveState              = 0,
	noChaseCategory        = "TERRAFORM FIXEDWING GUNSHIP TOOFAST",
	objectName             = "shiparty.s3o",
	script                 = "shipassault.lua",
	selfDestructAs         = "BIG_UNITEX",
	sightDistance          = 660,
	turninplace            = 0,
	turnRate               = 370,
	waterline              = 0,

	weapons                = {
		{
			def                = "PLASMA",
			badTargetCategory  = "GUNSHIP",
			onlyTargetCategory = "SWIM LAND SHIP SINK TURRET FLOAT GUNSHIP HOVER",
		},
		{
			def                = "DEPTHCHARGE",
			onlyTargetCategory = "SUB SINK",
		},
	},

	weaponDefs             = {
		PLASMA = {
			name                    = "Naval Artillery",
			collideFriendly         = false, -- This may be dangerous
			accuracy                = 480,
			alphadecay			  = 1.5,
			areaOfEffect            = 140,
			burst                   = 2,
			burstrate               = 0.5,
			craterBoost             = 0,
			craterMult              = 3,
			colorMap				= [[0.7843 0.0627 0.1803  0 0.1843 0.4235  0.7294 0.04705 0.1843  0 0.125 0.3568]],
			cegtag                  = "waketrail_small",
			customParams        = {
				light_camera_height = 1400,
				light_color = "0.80 0.54 0.23",
				light_radius = 230,
				reveal_unit = 20,
				armorpiercing = 0.50,
				combatrange = 350,
			},
			damage                  = {
				default = 600.1,
			},
			edgeEffectiveness       = 0.1,
			explosionGenerator      = "custom:bigbulletimpact",
			impulseBoost            = 0,
			impulseFactor           = 2,
			interceptedByShieldType = 1,
			myGravity               = 0.42,
			noSelfDamage            = true,
			range                   = 500,
			reloadtime              = 4,
			sizeDecay               = -1.4,
			seperation              = 8,
			soundHit                = "explosion/ex_small14",
			soundStart              = "weapon/cannon/amphsupport_fire",
			stages                  = 15,
			turret                  = true,
			weaponType              = "Cannon",
			weaponVelocity          = 700,
			waterWeapon             = true,
		},
		DEPTHCHARGE = {
			name                    = "Depth Charge",
			areaOfEffect            = 160,
			avoidFriendly           = false,
			bounceSlip              = 0.94,
			bounceRebound           = 0.8,
			collideFriendly         = false,
			craterBoost             = 1,
			craterMult              = 2,
			cegTag                  = "torpedo_trail",
			customParams = {
				burst = Shared.BURST_UNRELIABLE,
				stays_underwater = "owo",
				combatrange = 350,
			},

			damage                  = {
				default = 360.1,
			},
			edgeEffectiveness       = 0.4,
			explosionGenerator      = "custom:TORPEDOHITHUGE",
			fixedLauncher           = true,
			flightTime              = 2.3,
			groundBounce            = true,
			heightMod               = 0,
			impulseBoost            = 0.2,
			impulseFactor           = 0.9,
			interceptedByShieldType = 1,
			leadLimit               = 0,
			model                   = "depthcharge_big.s3o",
			myGravity               = 0.2,
			noSelfDamage            = true,
			numbounce               = 3,
			range                   = 370,
			reloadtime              = 2.8,
			soundHitDry             = "explosion/mini_nuke",
			soundHitWet             = "explosion/wet/ex_underwater",
			soundStart              = "weapon/torp_land",
			soundStartVolume        = 5,
			startVelocity           = 5,
			tolerance               = 1000000,
			tracks                  = true,
			turnRate                = 60000,
			turret                  = true,
			waterWeapon             = true,
			weaponAcceleration      = 25,
			weaponType              = "TorpedoLauncher",
			weaponVelocity          = 400,
		},
	},
	featureDefs            = {

		DEAD  = {
			blocking         = false,
			featureDead      = "HEAP",
			footprintX       = 4,
			footprintZ       = 4,
			object           = "shiparty_dead.s3o",
		},

		HEAP  = {
			blocking         = false,
			footprintX       = 4,
			footprintZ       = 4,
			object           = "debris4x4b.s3o",
		},

	},
}

return {shipassault = shipassault}
