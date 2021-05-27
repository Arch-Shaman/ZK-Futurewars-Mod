return { 
	cloakarty = {
		unitname               = [[cloakarty]],
		name                   = [[Sparky]],
		description            = [[Light EMP Artillery Bot]],
		acceleration           = 0.75,
		brakeRate              = 4.5,
		buildCostMetal         = 100,
		buildPic               = [[cloakarty.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		canCloak			   = true,
		category               = [[LAND]],
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[28 43 28]],
		collisionVolumeType    = [[cylY]],
		corpse                 = [[DEAD]],

		customParams           = {
			modelradius        = [[14]],
			selection_scale    = 0.85,
			cloakregen		   = 10,
			recloaktime 	   = 330,
			cloaker_bestowed_radius = 75,
		},
		initCloaked 		   = true,
		cloakCostMoving 	   = 0.5,
		cloakCost    		   = 0.0,
		explodeAs              = [[BIG_UNITEX]],
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = [[kbotarty]],
		idleAutoHeal           = 0,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 220,
		maxSlope               = 36,
		maxVelocity            = 2.1,
		maxWaterDepth          = 22,
		minCloakDistance       = 300,
		movementClass          = [[KBOT3]],
		noChaseCategory        = [[TERRAFORM FIXEDWING GUNSHIP TOOFAST]],
		objectName             = [[cloakarty.s3o]],
		script                 = [[cloakarty.lua]],
		selfDestructAs         = [[BIG_UNITEX]],
		sfxtypes               = {

			explosiongenerators = {
				[[custom:zeusmuzzle]],
				[[custom:sonicfire_80]],
				[[custom:sonicfire_80]],
			},

		},

		sightDistance          = 660,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 0.9,
		trackType              = [[ComTrack]],
		trackWidth             = 22,
		turnRate               = 1800,
		upright                = true,

		weapons                = {
			{
				def                = [[HAMMER_WEAPON]],
				badTargetCategory  = [[GUNSHIP]],
				onlyTargetCategory = [[SWIM LAND SHIP SINK TURRET FLOAT GUNSHIP HOVER]],
			},
		},

		weaponDefs             = {

			HAMMER_WEAPON = {
				name                    = [[Light EMP Shockcannon]],
				accuracy                = 80,
				movingAccuracy			= 400,
				areaOfEffect            = 120,
				cegtag					= [[artillery_spark_small]],
				craterBoost             = 0,
				craterMult              = 0,
				--highTrajectory			= 1,
				burst					= 1,

				customParams        = {
					light_camera_height = 1400,
					light_color = [[0.3 0.3 0.7]],
					light_radius = 100,
					extra_damage = 400,
					reveal_unit = 6,
				},

				damage                  = {
					default = 200,
				},

				edgeEffectiveness       = 0.05,
				paralyzeTime            = 1,
				explosionGenerator      = [[custom:hammer_artillery_hit]],
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.07,
				noSelfDamage            = true,
				range                   = 800,
				reloadtime              = 6,
				size					= 0.01,
				soundHit                = [[weapon/cannon/emp_arty_hit]],
				soundStart              = [[weapon/cannon/emparty_fire]],
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 235,
			},
		},

		featureDefs            = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[cloakarty_dead.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2c.s3o]],
			},

		},
	} 
}
