return { 
	vehscout = {
		unitname               = [[vehscout]],
		name                   = [[Flare]],
		description            = [[Disruptive Scout]],
		acceleration           = 0.84,
		brakeRate              = 1.866,
		buildCostMetal         = 70,
		builder                = false,
		buildPic               = [[vehscout.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND TOOFAST]],
		collisionVolumeOffsets = [[0 0 2]],
		collisionVolumeScales  = [[14 14 40]],
		collisionVolumeType    = [[cylZ]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[25 25 30]],
		selectionVolumeType    = [[cylZ]],
		corpse                 = [[DEAD]],

		customParams           = {
			modelradius    = [[7]],
			aim_lookahead  = 80,
		},

		explodeAs              = [[SMALL_UNITEX]],
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = [[vehiclescout]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 120,
		maxSlope               = 18,
		maxVelocity            = 5.09,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = [[TANK2]],
		moveState              = 0,
		noAutoFire             = false,
		noChaseCategory        = [[TERRAFORM FIXEDWING SATELLITE SUB]],
		objectName             = [[vehscout.s3o]],
		script                 = [[vehscout.lua]],
		selfDestructAs         = [[SMALL_UNITEX]],
		sightDistance          = 660,
		trackOffset            = 0,
		trackStrength          = 1,
		trackStretch           = 0.1,
		trackType              = [[Motorbike]],
		trackWidth             = 24,
		turninplace            = 0,
		turnRate               = 1755,
		workerTime             = 0,

		weapons                = {

			{
				def                = [[DISRUPTOR]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

		},


		weaponDefs             = {

			DISRUPTOR      = {
				name                    = [[Disruptor Pulse Bomb]],
				areaOfEffect            = 90,
				accuracy                = 256,
				burst					= 3,
				burstrate				= 0.5,
				coreThickness           = 0.25,
				craterBoost             = 0,
				craterMult              = 0,
				cegTag                  = [[beamweapon_muzzle_purple]],
				customParams            = {
					timeslow_damagefactor = 10,

					light_camera_height = 2500,
					light_color = [[1.5 0.75 1.8]],
					light_radius = 280,
					nofriendlyfire = "needs hax",
					
				},
      
				damage                  = {
					default = 20,
				},
  
				explosionGenerator      = [[custom:riotballplus2_purple_small]],
				explosionSpeed          = 5,
				fireStarter             = 100,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				minIntensity            = 1,
				noSelfDamage            = true,
				myGravity               = 0.18,
				rgbcolor                = [[0.9 0.1 0.9]],
				range                   = 350,
				reloadtime              = 4,
				rgbColor                = [[0.3 0 0.4]],
				soundHit				= [[weapon/aoe_aura2]],
				soundHitVolume          = 2.2,
				soundStart              = [[weapon/laser/small_laser_fire3]],
				soundStartVolume        = 3.5,
				tolerance               = 18000,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 350,
			},

		},


		featureDefs            = {

			DEAD  = {
				blocking         = false,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[vehscout_dead.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2a.s3o]],
			},

		},

	} 
}
