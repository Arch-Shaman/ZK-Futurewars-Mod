tankheavyarty = {
	unitname               = "tankheavyarty",
	name                   = "Orion",
	description            = "Earth-Shattering Artillery Tank",
	acceleration           = 0.3,
	brakeRate              = 1.24,
	buildCostMetal         = 7000,
	builder                = false,
	buildPic               = "tankheavyarty.png",
	canGuard               = true,
	canMove                = true,
	canPatrol              = true,
	category               = "LAND",
	collisionVolumeOffsets = "-3.8 17 -17",
	collisionVolumeScales  = "68 50 133",
	collisionVolumeType    = "cylZ",
	corpse                 = "DEAD",
	customParams           = {
		modelradius       = "17",
		cus_noflashlight  = 1,
		selection_scale   = 0.92,
		bait_level_default = 1,
		dontfireatradarcommand = '0',
	},
	explodeAs              = "BIG_UNIT",
	footprintX             = 5,
	footprintZ             = 5,
	iconType               = "tanklrarty",
	idleAutoHeal           = 5,
	idleTime               = 1800,
	leaveTracks            = true,
	health                 = 21000,
	maxSlope               = 18,
	speed                  = 1.25,
	maxWaterDepth          = 22,
	minCloakDistance       = 150,
	movementClass          = "TANK4",
	moveState              = 0,
	noAutoFire             = false,
	noChaseCategory        = "TERRAFORM FIXEDWING SATELLITE GUNSHIP",
	objectName             = "cortrem.dae",
	selfDestructAs         = "BIG_UNIT",
	script                 = "tankheavyarty.lua",
	sfxtypes            = {
		explosiongenerators = {
			"custom:LARGE_MUZZLE_FLASH_FX",
		},
	},
	sightDistance          = 660,
	trackOffset            = 20,
	trackStrength          = 8,
	trackStretch           = 1,
	trackType              = "StdTank",
	trackWidth             = 60,
	turninplace            = 0,
	turnRate               = 312,
	workerTime             = 0,
	weapons                = {
		{
			def                = "PLASMA",
			badTargetCategory  = "SWIM LAND SHIP HOVER",
			mainDir            = "0 0 1",
			onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
		},
	},
	weaponDefs             = {
		PLASMA = {
			name                    = "Desolation Cannon",
			accuracy                = 0,
			areaOfEffect            = 192,
			avoidFeature            = false,
			avoidGround             = true,
			craterBoost             = 10,
			craterMult              = 1.7,
			cegtag                  = "liberation_cannontrail",
			customParams            = {
				gatherradius = "234",
				smoothradius = "180",
				detachmentradius = "180",
				smoothmult   = "0.5",
				smoothexponent = "0.75",
				movestructures = "0.25",
			},
			damage                  = {
				default = 8500.01,
			},
			explosionGenerator      = "custom:NUKE_150",
			edgeEffectiveness		= 0.1,
			fireTolerance           = 1820, -- 10 degrees
			impulseBoost            = 2,
			impulseFactor           = 1.3,
			interceptedByShieldType = 1,
			mygravity               = 1,
			noSelfDamage            = true,
			range                   = 3000,
			reloadtime              = 15,
			rgbColor                = "0.615 0.447 0.412",
			soundHit                = "weapon/cannon/supergun_bass_boost",
			soundStart              = "weapon/cannon/behe_fire2",
			size                    = 15,
			turret                  = true,
			weaponType              = "Cannon",
			weaponVelocity          = 3000,
		},
	},
	featureDefs            = {
		DEAD  = {
			blocking         = true,
			featureDead      = "HEAP",
			footprintX       = 2,
			footprintZ       = 2,
			object           = "tremor_dead_new.s3o",
		},
		HEAP  = {
			blocking         = false,
			footprintX       = 2,
			footprintZ       = 2,
			object           = "debris2x2a.s3o",
		},
	},
}

return { tankheavyarty = tankheavyarty }
