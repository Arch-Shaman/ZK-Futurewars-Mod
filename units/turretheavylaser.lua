return { 
	turretheavylaser = {
		unitname                      = [[turretheavylaser]],
		name                          = [[Rampart]],
		description                   = [[Medium Range Plasma Bombarder (Needs Grid: 8E)]],
		acceleration                  = 0,
		brakeRate                     = 0,
		buildCostMetal                = 500,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 4,
		buildingGroundDecalSizeY      = 4,
		buildingGroundDecalType       = [[turretheavylaser_aoplane.dds]],
		buildPic                      = [[turretheavylaser.png]],
		category                      = [[FLOAT TURRET]],
		collisionVolumeOffsets        = [[0 17 0]],
		collisionVolumeScales         = [[36 110 36]],
		collisionVolumeType           = [[CylY]],
		corpse                        = [[DEAD]],

		customParams                  = {
			aimposoffset   = [[0 15 0]],
			keeptooltip = [[any string i want]],
			neededlink  = 8,
			pylonrange  = 50,
		},

		explodeAs                     = [[MEDIUM_BUILDINGEX]],
		floater                       = true,
		footprintX                    = 3,
		footprintZ                    = 3,
		iconType                      = [[defenseheavy]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		levelGround                   = false,
		losEmitHeight                 = 80,
		maxDamage                     = 3000,
		maxSlope                      = 36,
		maxVelocity                   = 0,
		minCloakDistance              = 150,
		noAutoFire                    = false,
		noChaseCategory               = [[FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER]],
		objectName                    = [[hlt.s3o]],
		script                        = [[turretheavylaser.lua]],
		selfDestructAs                = [[MEDIUM_BUILDINGEX]],

		sfxtypes                      = {

			explosiongenerators = {
				[[custom:HLTRADIATE0]],
				[[custom:RAIDMUZZLE]],
			},

		},
		sightDistance                 = 796, -- Range*1.1 + 48 for radar overshoot
		turnRate                      = 0,
		useBuildingGroundDecal        = true,
		workerTime                    = 0,
		yardMap                       = [[ooo ooo ooo]],

		weapons                       = {

			{
				def                = [[LASER]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

		},


		weaponDefs                    = {

			LASER = {
				name                    = [[Medium Range Plasma Cannon]],
				areaOfEffect            = 64,
				burst                   = 3,
				burstRate               = 3/30,
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting 		= 0.8,
				customParams        = {
					burst = Shared.BURST_UNRELIABLE,
				},

				damage                  = {
					default = 160,
				},

				explosionGenerator      = [[custom:TESS]],
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 600,
				heightBoostFactor 		= 1.1,
				reloadtime              = 2,
				soundHit                = [[weapon/cannon/reaper_hit]],
				soundStart              = [[weapon/cannon/cannon_fire4]],
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 740,
			},

		},


		featureDefs                   = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[corhlt_d.s3o]],
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[debris3x3a.s3o]],
			},

		},

	} 
}
