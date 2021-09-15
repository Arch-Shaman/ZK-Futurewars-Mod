return { 
	jumpaa = {
		unitname            = [[jumpaa]],
		name                = [[Archangle]],
		description         = [[No More Zephyr Syndrom!]],
		acceleration        = 0.54,
		brakeRate           = 1.2,
		buildCostMetal      = 500,
		buildPic            = [[jumpaa.png]],
		canMove             = true,
		category            = [[LAND]],
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[30 48 30]],
		collisionVolumeType    = [[cylY]],
		corpse              = [[DEAD]],
		
		customParams        = {
			canjump            = 1,
			jump_range         = 400,
			jump_speed         = 6,
			jump_reload        = 10,
			jump_from_midair   = 0,
			modelradius    = [[15]],
		},
		
		explodeAs           = [[BIG_UNITEX]],
		footprintX          = 2,
		footprintZ          = 2,
		iconType            = [[jumpjetaa]],
		idleAutoHeal        = 5,
		idleTime            = 1800,
		leaveTracks         = true,
		maxDamage           = 2100,
		maxSlope            = 36,
		maxVelocity         = 2.017,
		maxWaterDepth       = 22,
		movementClass       = [[KBOT2]],
		moveState           = 0,
		noChaseCategory     = [[TERRAFORM LAND SINK TURRET SHIP SATELLITE SWIM FLOAT SUB HOVER]],
		objectName          = [[hunchback.s3o]],
		script              = [[jumpaa.lua]],
		selfDestructAs      = [[BIG_UNITEX]],
		sightDistance       = 900,
		trackOffset         = 0,
		trackStrength       = 8,
		trackStretch        = 1,
		trackType           = [[ComTrack]],
		trackWidth          = 28,
		turnRate            = 1680,
		upright             = true,
		
		weapons             = {
	
			{
				def                = [[HEATRAY]],
				--badTargetCategory  = [[GUNSHIP]],
				onlyTargetCategory = [[GUNSHIP FIXEDWING]],
			},
		
			{
				def                = [[GRAVITY_MISSILE]],
				--badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING GUNSHIP]],
			},
	
		},


		weaponDefs          = {

			GRAVITY_MISSILE = {
				name                    = [[Graviton Missiles]],
				areaOfEffect            = 48,
				avoidFeature            = true,
				burst                   = 4,
				burstrate               = 0.1,
				canattackground         = false,
				projectiles             = 2,
				cegTag                  = [[missiletrailgravattract]],
				craterBoost             = 0,
				craterMult              = 0,

				customParams        = {
					light_camera_height = 2500,
					light_radius = 300,
					light_color = [[0.33 0.33 1.28]],
					impulse = [[-600]],
					
					stats_custom_tooltip_1 = " - Large amounts of impulse",
				},

				damage                  = {
					default = 0.001,
				},

				explosionGenerator      = [[custom:FLASH2]],
				flightTime              = 3,
				--impulseBoost            = 0,
				--impulseFactor           = 0.4,
				interceptedByShieldType = 0,
				model                   = [[wep_m_frostshard.s3o]],
				range                   = 1150,
				reloadtime              = 3,
				smokeTrail              = true,
				sprayAngle              = 10000,
				soundHit                = [[weapon/gravity_fire]],
				soundStart              = [[weapon/missile/rapid_rocket_fire]],
				soundStartVolume        = 20,
				startVelocity           = 300,
				trajectoryHeight        = 0,
				texture2                = [[lightsmoketrail]],
				tolerance               = 8000,
				tracks                  = true,
				turnRate                = 13000,
				turret                  = true,
				weaponAcceleration      = 190,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 645,
			},


			HEATRAY = {
				name                    = [[Dual Anti-Air Heat Ray]],
				areaOfEffect            = 20,
				beamtime				= 4/30,
				canattackground         = false,
				coreThickness           = 1.4,
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting 		= 0.6,
				explosionScar			= false,
				customParams        = {
					light_camera_height = 1500,
					light_color = [[0.9 0.4 0.12]],
					light_radius = 100,
					light_fade_time = 25,
					light_fade_offset = 10,
					light_beam_mult_frames = 9,
					light_beam_mult = 8,
				},
				damage                  = {
					default = 9.5,
					planes = 95,
				},
				duration                = 0.3,
				dynDamageExp            = 1,
				dynDamageInverted       = false,
				explosionGenerator      = [[custom:HEATRAY_HIT]],
				fallOffRate             = 1,
				fireStarter             = 90,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = -1,
				interceptedByShieldType = 1,
				leadLimit               = 0.1,
				lodDistance             = 10000,
				noSelfDamage            = true,
				projectiles             = 2,
				proximityPriority       = 10,
				range                   = 900,
				reloadtime              = 0.1,
				rgbColor                = [[1 0.54 0]],
				rgbColor2               = [[1 1 0.25]],
				soundStart              = [[weapon/heatray_fire]],
				soundStartVolume        = 5,
				thickness               = 3,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 1500,
			},

  },


  featureDefs         = {

    DEAD  = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 4,
      footprintZ       = 4,
      object           = [[hunchback_dead.s3o]],
    },


    HEAP  = {
      blocking         = false,
      footprintX       = 4,
      footprintZ       = 4,
      object           = [[debris4x4c.s3o]],
    },

  },

} }
