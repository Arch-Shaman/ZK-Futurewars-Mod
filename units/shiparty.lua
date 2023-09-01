return { 
	shiparty = {
		unitname               = [[shiparty]],
		name                   = [[Tsumani]],
		description            = [[Naval Superemecy Vessel]],
		acceleration           = 0.25,
		activateWhenBuilt      = true,
		brakeRate              = 1.7,
		buildCostMetal         = 800,
		builder                = false,
		buildPic               = [[shiparty.png]],
		canMove                = true,
		category               = [[SHIP]],
		collisionVolumeOffsets = [[0 1 3]],
		collisionVolumeScales  = [[32 32 132]],
		collisionVolumeType    = [[cylZ]],
		corpse                 = [[DEAD]],

		customParams           = {
			bait_level_default = 1,
			--extradrawrange = 200,
			modelradius    = [[55]],
			turnatfullspeed = [[1]],
			outline_x = 160,
			outline_y = 160,
			outline_yoff = 25,
		},

		explodeAs              = [[BIG_UNITEX]],
		floater                = true,
		footprintX             = 4,
		footprintZ             = 4,
		iconType               = [[shiparty]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		losEmitHeight          = 25,
		health                 = 6800,
		speed                  = 1.4,
		minWaterDepth          = 10,
		movementClass          = [[BOAT4]],
		moveState              = 0,
		noChaseCategory        = [[TERRAFORM FIXEDWING GUNSHIP TOOFAST]],
		objectName             = [[shiparty.s3o]],
		script                 = [[shiparty.lua]],
		selfDestructAs         = [[BIG_UNITEX]],
		sightDistance          = 660,
		turninplace            = 0,
		turnRate               = 370,
		waterline              = 0,

		weapons                = {
			{
				def                = [[PLASMA]],
				badTargetCategory  = [[GUNSHIP]],
				onlyTargetCategory = [[SWIM LAND SHIP SINK TURRET FLOAT GUNSHIP HOVER]],
			},
		},

		weaponDefs             = {
			PLASMA = {
				name                    = [[Anti-Ship Plasma Battery]],
				areaOfEffect            = 32,
				avoidFeature            = false,
				avoidGround             = true,
				craterBoost             = 1,
				craterMult              = 2,
				burst = 2,
				burstrate = 0.8,

				customParams = {
					burst = Shared.BURST_RELIABLE,
				},

				damage                  = {
					default = 300.1,
				},
				edgeeffectiveness		= 0.3,
				explosionGenerator      = [[custom:plasma_hit_32]],
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.06,
				range                   = 700,
				reloadtime              = 3,
				soundHit                = [[weapon/cannon/cannon_hit2]],
				soundStart              = [[weapon/cannon/battleship_fire]],
				soundStartVolume		= 40,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 600,
			},
		},
		featureDefs            = {

			DEAD  = {
				blocking         = false,
				featureDead      = [[HEAP]],
				footprintX       = 4,
				footprintZ       = 4,
				object           = [[shiparty_dead.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 4,
				footprintZ       = 4,
				object           = [[debris4x4b.s3o]],
			},

		},
	}
}
