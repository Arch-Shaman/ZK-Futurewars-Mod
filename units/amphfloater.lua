return { 
	amphfloater = {
		unitname               = [[amphfloater]],
		name                   = [[Bully]],
		description            = [[Amphibious Assault Bot]],
		acceleration           = 0.6,
		activateWhenBuilt      = true,
		brakeRate              = 2.4,
		buildCostMetal         = 330,
		buildPic               = [[amphfloater.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND SINK]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[42 42 42]],
		selectionVolumeType    = [[ellipsoid]],
		corpse                 = [[DEAD]],

		customParams           = {
			bait_level_default = 0,
			aim_lookahead      = 60,
			amph_regen         = 40,
			amph_submerged_at  = 80,
			sink_on_emp        = 0,
			floattoggle        = [[1]],
			selection_scale    = 0.85,
		},

		explodeAs              = [[BIG_UNITEX]],
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = [[amphskirm]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 2200,
		maxSlope               = 36,
		maxVelocity            = 1.7,
		minCloakDistance       = 75,
		movementClass          = [[AKBOT3]],
		noChaseCategory        = [[TERRAFORM FIXEDWING GUNSHIP]],
		objectName             = [[can.s3o]],
		script                 = [[amphfloater.lua]],
		selfDestructAs         = [[BIG_UNITEX]],

		sfxtypes               = {
			explosiongenerators = {},
		},

		sightDistance          = 500,
		sonarDistance          = 500,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = [[ComTrack]],
		trackWidth             = 22,
		turnRate               = 1200,
		upright                = true,

		weapons                = {
			{
				def                = [[CANNON]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
			{
				def                = [[FAKE_CANNON]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		},

		weaponDefs             = {
			
			CANNON = {
				name                    = [[Assault Disruptor]],
				accuracy                = 400,
				areaOfEffect            = 32,
				burst					= 5,
				burstRate				= 0.1,
				projectiles				= 2,
				cegTag                  = [[beamweapon_muzzle_purple]],
				craterBoost             = 1,
				craterMult              = 2,

				customparams = {
					burst = Shared.BURST_RELIABLE,

					timeslow_damagefactor = 0.75,

					light_camera_height = 2500,
					light_color = [[1.36 0.68 1.5]],
					light_radius = 180,
				},

				damage                  = {
					default = 56.1,
				},
				
				sprayAngle				= 1100,
				explosionGenerator      = [[custom:flashslowwithsparks]],
				fireStarter             = 180,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				interceptedByShieldType = 2,
				myGravity               = 0.2,
				range                   = 310,
				reloadtime              = 3 + 1/3,
				rgbcolor                = [[0.9 0.1 0.9]],
				soundHit                = [[weapon/laser/small_laser_fire]],
				soundHitVolume          = 2.2,
				soundStart              = [[weapon/cannon/disruptor_cannon]],
				soundStartVolume        = 3.5,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 340,
				waterWeapon				= true,
			},

			FAKE_CANNON = {
				name                    = [[Fake Disruption Cannon]],
				accuracy                = 200,
				areaOfEffect            = 32,
				cegTag                  = [[beamweapon_muzzle_purple]],
				craterBoost             = 1,
				craterMult              = 2,

				customparams = {
					timeslow_damagefactor = 1.7,
					bogus = 1,
				},

				damage                  = {
					default = 150,
				},

				explosionGenerator      = [[custom:flashslowwithsparks]],
				fireStarter             = 180,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				interceptedByShieldType = 2,
				myGravity               = 0.2,
				range                   = 310,
				reloadtime              = 1.8,
				rgbcolor                = [[0.9 0.1 0.9]],
				soundHit                = [[weapon/laser/small_laser_fire]],
				soundHitVolume          = 2.2,
				soundStart              = [[weapon/laser/small_laser_fire3]],
				soundStartVolume        = 3.5,
				soundTrigger            = true,
				turret                  = true,
				waterWeapon             = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 340,
			},
		},

		featureDefs            = {

			DEAD      = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[can_dead.s3o]],
			},

			HEAP      = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2c.s3o]],
			},

		},
	} 
}
