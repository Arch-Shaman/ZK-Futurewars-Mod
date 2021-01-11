return { 
	shieldaa = {
		unitname               = [[shieldaa]],
		name                   = [[Vandal]],
		description            = [[Anti-Air Bot]],
		acceleration           = 1.35,
		brakeRate              = 8.1,
		buildCostMetal         = 90,
		buildPic               = [[shieldaa.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND]],
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[30 41 30]],
		collisionVolumeType    = [[cylY]],
		corpse                 = [[DEAD]],
		customParams           = {},
		explodeAs              = [[BIG_UNITEX]],
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = [[walkeraa]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 650,
		maxSlope               = 36,
		maxVelocity            = 2.7,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = [[KBOT2]],
		moveState              = 0,
		noChaseCategory        = [[TERRAFORM LAND SINK TURRET SHIP SWIM FLOAT SUB HOVER]],
		objectName             = [[crasher.s3o]],
		radarDistance          = 1400,
		radarEmitHeight        = 32,
		script                 = [[shieldaa.lua]],
		selfDestructAs         = [[BIG_UNITEX]],
		sfxtypes               = {
			explosiongenerators = {
				[[custom:CRASHMUZZLE]],
			},
		},
		sightDistance          = 660,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = [[ComTrack]],
		trackWidth             = 22,
		turnRate               = 2640,
		upright                = true,
		weapons                = {

			{
				def                = [[ARMKBOT_MISSILE]],
				--badTargetCategory  = [[GUNSHIP]],
				onlyTargetCategory = [[GUNSHIP FIXEDWING]],
			},
			{
				def = [[shield]],
			},
		},
		weaponDefs             = {

			ARMKBOT_MISSILE = {
				name                    = [[Homing Missiles]],
				areaOfEffect            = 48,
				burst					= 2,
				burstrate				= 0.5,
				canattackground         = false,
				cegTag                  = [[missiletrailblue]],
				craterBoost             = 1,
				craterMult              = 2,
				cylinderTargeting       = 1,

				customParams              = {
					burst = Shared.BURST_RELIABLE,
					disarmDamageMult = 1.5,
					disarmDamageOnly = 0,
					disarmTimer      = 3, -- seconds
					isaa = [[1]],
					light_color = [[0.5 0.6 0.6]],
					light_radius = 380,
				},

				damage                  = {
					default = 7.0,
					planes  = 70.1,
				},
				explosionGenerator      = [[custom:mixed_white_lightning_bomb_small]],
				fireStarter             = 70,
				flightTime              = 3,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = [[wep_m_fury.s3o]],
				noSelfDamage            = true,
				range                   = 880,
				reloadtime              = 2,
				smokeTrail              = true,
				soundHit                = [[weapon/missile/small_lightning_missile]],
				soundStart              = [[weapon/missile/missile_fire7]],
				startVelocity           = 650,
				texture2                = [[AAsmoketrail]],
				tolerance               = 9000,
				tracks                  = true,
				turnRate                = 63000,
				turret                  = true,
				weaponAcceleration      = 141,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 850,
			},
			SHIELD = {
				name                    = [[Energy Shield]],	
				damage                  = {	
					default = 10,	
				},	
				exteriorShield          = true,	
				shieldAlpha             = 0.2,	
				shieldBadColor          = [[1 0.1 0.1 1]],	
				shieldGoodColor         = [[0.1 0.1 1 1]],	
				shieldInterceptType     = 3,	
				shieldPower             = 1000,	
				shieldPowerRegen        = 10,	
				shieldPowerRegenEnergy  = 0.2,	
				shieldRadius            = 80,	
				shieldRepulser          = false,	
				shieldStartingPower     = 1000,	
				smartShield             = true,	
				visibleShield           = false,	
				visibleShieldRepulse    = false,	
				weaponType              = [[Shield]],
			},
		},

		featureDefs            = {

			DEAD = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[crasher_dead.s3o]],
			},

			HEAP = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2a.s3o]],
			},

		},

	}
}
