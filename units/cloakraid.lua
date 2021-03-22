return { 
	cloakraid = {
		unitname               = [[cloakraid]],
		name                   = [[Lurker]],
		description            = [[Ambush Raider Bot]],
		acceleration           = 1.5,
		brakeRate              = 2.4,
		buildCostMetal         = 70,
		buildPic               = [[cloakraid.png]],
		canGuard               = true,
		canMove                = true,
		canCloak			   = true,
		stealth                = true,
		activateWhenBuilt      = true,
		cloakCost              = 0,
		canPatrol              = true,
		category               = [[LAND TOOFAST]],
		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales  = [[18 28 18]],
		collisionVolumeType    = [[cylY]],
		corpse                 = [[DEAD]],
		customParams           = {
			modelradius        = [[16]],
			cus_noflashlight   = 1,
			aim_lookahead      = 80,
			cloakregen		   = 15,
			idle_cloak = 1,
		},

		explodeAs              = [[SMALL_UNITEX]],
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = [[kbotraider]],
		leaveTracks            = true,
		maxDamage              = 200,
		maxSlope               = 36,
		maxVelocity            = 4.5,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = [[KBOT2]],
		noAutoFire             = false,
		noChaseCategory        = [[TERRAFORM FIXEDWING SUB]],
		objectName             = [[spherebot.s3o]],
		script                 = [[cloakraid.lua]],
		selfDestructAs         = [[SMALL_UNITEX]],
		sfxtypes               = {
			explosiongenerators = {
				[[custom:emg_shells_l]],
				[[custom:flashmuzzle1]],
			},
		},
		sightDistance          = 560,
		radarDistance		   = 700,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 0.9,
		trackType              = [[ComTrack]],
		trackWidth             = 14,
		turnRate               = 3000,
		upright                = true,

		weapons                = {

			{
				def                = [[EMG]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

		},

		weaponDefs             = {

			EMG = {
				name                    = [[Heavy Burst EMG]],
				alphaDecay              = 0.1,
				areaOfEffect            = 24,
				colormap                = [[1 0.95 0.4 1   1 0.95 0.4 1    0 0 0 0.01    1 0.7 0.2 1]],
				craterBoost             = 0,
				burst					= 6,
				burstrate				= 3/30,
				craterMult              = 0,
				cylinderTargeting 		= 1,
				customParams        = {
					light_camera_height = 1200,
					light_color = [[0.8 0.76 0.38]],
					light_radius = 60,
				},

				damage                  = {
					default = 30.1,
				},

				explosionGenerator      = [[custom:EMG_HIT_HE]],
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				leadLimit               = 0,
				noGap                   = false,
				noSelfDamage            = true,
				range                   = 220,
				reloadtime              = 1.8,
				rgbColor                = [[1 0.95 0.4]],
				separation              = 1.5,
				size                    = 3,
				sizeDecay               = 0,
				soundhit			    = [[weapon/cannon/cannon_hit1]],
				soundStart              = [[weapon/heavy_machinegun]],
				soundStartVolume        = 4,
				sprayAngle              = 380,
				stages                  = 10,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 500,
			},
		},

		featureDefs            = {

			DEAD  = {
				blocking         = false,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[spherebot_dead.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2b.s3o]],
			},

		},
	} 
}
