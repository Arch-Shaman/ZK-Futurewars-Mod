return { 
	turretimpulse = {
		unitname                      = [[turretimpulse]],
		name                          = [[Newton]],
		description                   = [[Gravity Turret]],
		activateWhenBuilt             = true,
		buildCostMetal                = 200,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 4,
		buildingGroundDecalSizeY      = 4,
		buildingGroundDecalType       = [[turretimpulse_aoplane.dds]],
		buildPic                      = [[turretimpulse.png]],
		category                      = [[SINK]],
		collisionVolumeOffsets        = [[0 0 0]],
		collisionVolumeScales         = [[50 50 50]],
		collisionVolumeType           = [[ellipsoid]],
		corpse                        = [[DEAD]],

		customParams                  = {
			modelradius    = [[25]],
		},

		explodeAs                     = [[MEDIUM_BUILDINGEX]],
		footprintX                    = 2,
		footprintZ                    = 2,
		iconType                      = [[defensesupport]],
		levelGround                   = false,
		maxDamage                     = 2000,
		maxSlope                      = 36,
		maxWaterDepth                 = 0,
		noAutoFire                    = false,
		noChaseCategory               = [[FIXEDWING LAND SINK TURRET SHIP SATELLITE SWIM GUNSHIP FLOAT SUB HOVER]],
		objectName                    = [[CORGRAV]],
		onoffable                     = true,
		selfDestructAs                = [[MEDIUM_BUILDINGEX]],
		sightDistance                 = 554, -- Range*1.1 + 48 for radar overshoot
		useBuildingGroundDecal        = true,
		workerTime                    = 0,
		yardMap                       = [[oooo]],

		weapons                       = {

			{
				def                = [[GRAVITY_POS]],
				badTargetCategory  = [[]],
				onlyTargetCategory = [[FIXEDWING HOVER SWIM LAND SHIP GUNSHIP]],
			},


			{
				def                = [[GRAVITY_NEG]],
				badTargetCategory  = [[]],
				onlyTargetCategory = [[FIXEDWING HOVER SWIM LAND SHIP GUNSHIP]],
			},

		},


		weaponDefs                    = {

			GRAVITY_NEG = {
				name                    = [[Attractive Gravity]],
				areaOfEffect            = 8,
				avoidFriendly           = false,
				avoidFeature			= false,
				beamtime				= 1/30,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting 		= 100,
				customParams            = {
					impulse = [[-150]],
					stats_hide_damage = 1, -- continuous laser
					stats_hide_reload = 1,
					light_color = [[0.33 0.33 1.28]],
					light_radius = 140,
				},

				damage                  = {
					default = 0.001,
				},
				explosionGenerator      = [[custom:NONE]],
				impactOnly              = true,
				intensity               = 0.7,
				interceptedByShieldType = 0,
				largeBeamLaser          = true,
				laserFlareSize          = 2,
				noSelfDamage            = true,
				proximityPriority       = -15,
				range                   = 480,
				reloadtime              = 1/30,
				rgbColor                = [[0 0 1]],
				rgbColor2               = [[1 0.5 1]],
				sweepfire				= true,
				size                    = 2,
				soundStart              = [[weapon/beam/newtonpull_fixed]],
				thickness               = 4,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 2200,
				texture1                = [[largelaser]],
				texture2                = [[flare]],
				texture3                = [[flare]],
				texture4                = [[smallflare]],
			},


			GRAVITY_POS = {
				name                    = [[Repulsive Gravity]],
				areaOfEffect            = 8,
				avoidFriendly           = false,
				avoidFeature			= false,
				beamtime				= 1/30,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting 		= 100,
				customParams            = {
					impulse = [[150]],
					stats_hide_damage = 1, -- continuous laser
					stats_hide_reload = 1,
					light_color = [[0.85 0.2 0.2]],
					light_radius = 140,
				},

				damage                  = {
					default = 0.001,
				},
				largeBeamLaser          = true,
				laserFlareSize          = 2,
				duration				= 2/30,
				explosionGenerator      = [[custom:NONE]],
				impactOnly              = true,
				intensity               = 0.7,
				interceptedByShieldType = 0,
				noSelfDamage            = true,
				proximityPriority       = 15,
				range                   = 480,
				reloadtime              = 1/30,
				rgbColor                = [[1 0 0]],
				rgbColor2               = [[1 0.5 1]],
				sweepfire				= true,
				size                    = 2,
				texture1                = [[largelaser]],
				texture2                = [[flare]],
				texture3                = [[flare]],
				texture4                = [[smallflare]],
				soundStart              = [[weapon/beam/newtonpush_fix2]],
				thickness               = 4,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 2200,
			},

		},
		featureDefs                   = {
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 5,
				footprintZ       = 5,
				object           = [[corgrav_dead]],
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 5,
				footprintZ       = 5,
				object           = [[debris3x3c.s3o]],
			},
		},
	} 
}
