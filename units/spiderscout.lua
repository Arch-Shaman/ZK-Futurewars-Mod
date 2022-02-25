return { 
	spiderscout = {
		unitname            = [[spiderscout]],
		name                = [[Wolf]],
		description         = [[Light Scout/Raider Spider]],
		acceleration        = 2.1,
		brakeRate           = 12.6,
		buildCostMetal      = 65,
		buildPic            = [[spiderscout.png]],
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = [[LAND TOOFAST]],
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[20 20 20]],
		collisionVolumeType    = [[ellipsoid]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[28 28 28]],
		selectionVolumeType    = [[ellipsoid]],
		corpse              = [[DEAD]],

		customParams        = {
			modelradius        = [[10]],
			selection_scale    = 1, -- Maybe change later
			aim_lookahead      = 80,
		},

		explodeAs           = [[TINY_BUILDINGEX]],
		footprintX          = 2,
		footprintZ          = 2,
		iconType            = [[spiderscout]],
		idleAutoHeal        = 5,
		idleTime            = 1800,
		leaveTracks         = true,
		maxDamage           = 240,
		maxSlope            = 72,
		maxVelocity         = 4.2,
		maxWaterDepth       = 15,
		minCloakDistance    = 75,
		movementClass       = [[TKBOT2]],
		moveState           = 0,
		noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE SUB]],
		objectName          = [[arm_flea.s3o]],
		pushResistant       = 0,
		script              = [[spiderscout.lua]],
		selfDestructAs      = [[TINY_BUILDINGEX]],

		sfxtypes            = {
			explosiongenerators = {
				[[custom:digdig]],
			},
		},

		sightDistance       = 620,
		trackOffset         = 0,
		trackStrength       = 8,
		trackStretch        = 1,
		trackType           = [[ChickenTrackPointy]],
		trackWidth          = 18,
		turnRate            = 2100,

		weapons             = {
			{
				def                = [[LASER]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		},

		weaponDefs          = {
			LASER = {
				name                    = [[Micro Laser]],
				areaOfEffect            = 8,
				beamTime                = 0.1,
				burstrate               = 0.2,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,

				customParams            = {
					light_color = [[1 0.2 1]],
					light_radius = 50,
					timeslow_damagefactor = 1.3676, -- 120 DPS slow
					sweepfire = 1,
					sweepfire_maxangle = 15,
					sweepfire_step = 1.5,
					sweepfire_fastupdate = 1,
				},

				damage                  = {
					default = 35.1,
				},

				explosionGenerator      = [[custom:beamweapon_hit_purple_tiny]],
				fireStarter             = 50,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				laserFlareSize          = 3.22,
				minIntensity            = 1,
				noSelfDamage            = true,
				range                   = 200,
				reloadtime              = 0.4,
				rgbColor                = [[1 0.2 1]],
				soundStart              = [[weapon/laser/small_laser_fire]],
				soundTrigger            = true,
				thickness               = 2.14476105895272,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = [[LaserCannon]],
				weaponVelocity          = 500,
			},
		},

		featureDefs                   = {
			DEAD = {
				blocking         = false,
				featureDead      = [[HEAP]],
				footprintX       = 1,
				footprintZ       = 1,
				object           = [[flea_d.dae]],
			},

			HEAP = {
				blocking         = false,
				footprintX       = 1,
				footprintZ       = 1,
				object           = [[debris1x1b.s3o]],
			},
		},
	} 
}
