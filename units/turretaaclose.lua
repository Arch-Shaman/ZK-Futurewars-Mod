return { 
	turretaaclose = {
		unitname                      = [[turretaaclose]],
		name                          = [[Archer]],
		description                   = [[Laser Guided Anti-Air Turret]],
		buildCostMetal                = 300,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 4,
		buildingGroundDecalSizeY      = 4,
		buildingGroundDecalType       = [[turretaaclose_aoplane.dds]],
		buildPic                      = [[turretaaclose.png]],
		category                      = [[FLOAT]],
		collisionVolumeOffsets        = [[0 12 0]],
		collisionVolumeScales         = [[42 53 42]],
		collisionVolumeType            = [[CylY]],
		corpse                        = [[DEAD]],

		customParams                  = {
			aim_lookahead      = 120,
		},

		explodeAs                     = [[SMALL_BUILDINGEX]],
		floater                       = true,
		footprintX                    = 3,
		footprintZ                    = 3,
		iconType                      = [[defenseskirmaa]],
		levelGround                   = false,
		maxDamage                     = 2500,
		maxSlope                      = 18,
		minCloakDistance              = 150,
		noAutoFire                    = false,
		noChaseCategory               = [[FIXEDWING LAND SINK TURRET SHIP SATELLITE SWIM GUNSHIP FLOAT SUB HOVER]],
		objectName                    = [[missiletower.dae]],
		script                        = [[turretaaclose.lua]],
		selfDestructAs                = [[SMALL_BUILDINGEX]],

		sfxtypes                      = {

		explosiongenerators = {
			[[custom:STORMMUZZLE]],
			[[custom:STORMBACK]],
		},

		},
		sightDistance                 = 1025,
		useBuildingGroundDecal        = true,
		waterline                     = 10,
		workerTime                    = 0,
		yardMap                       = [[ooooooooo]],

		weapons                       = {

			{
				def                = [[MISSILE]],
				badTargetCategory  = [[GUNSHIP]],
				onlyTargetCategory = [[FIXEDWING GUNSHIP]],
			},
			{
				def                = [[TRACKER]],
				badTargetCategory  = [[GUNSHIP]],
				onlyTargetCategory = [[FIXEDWING GUNSHIP]],
			},

		},
		weaponDefs                    = {

			MISSILE = {
				name                    = [[LGAAM-4 Salvo]],
				areaOfEffect            = 24,
				canattackground         = false,
				cegTag                  = [[missiletrailbluebig]],
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting       = 3,

				customParams = {
					burst = Shared.BURST_RELIABLE,
					isaa = [[1]],
					script_reload = [[6]],
					script_burst = [[4]],
					light_color = [[0.5 0.6 0.6]],
					tracker = 1,
				},

				damage                  = {
					default = 40.1,
					planes  = 400.1,
				},

				explosionGenerator      = [[custom:FLASH2]],
				fireStarter             = 70,
				flightTime              = 14,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				leadLimit               = 0,
				model                   = [[wep_m_phoenix.s3o]],
				noSelfDamage            = true,
				range                   = 1000,
				reloadtime              = 0.1,
				smokeTrail              = true,
				soundHit                = [[explosion/ex_med11]],
				soundStart              = [[weapon/missile/missile_fire3]],
				startVelocity           = 420,
				texture2                = [[AAsmoketrail]],
				tracks                  = true,
				turnRate                = 130000,
				turret                  = true,
				weaponAcceleration      = 100,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 820,
			},
			TRACKER = {
				name                    = [[Missile Target Painter]],
				areaOfEffect            = 20,
				beamTime                = 0.01,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting       = 1,
				customParams            = {
					targeter = 1,
					--burst = Shared.BURST_RELIABLE,
					stats_hide_damage = 1, -- continuous laser
					stats_hide_reload = 1,
					light_color = [[1.25 0 0]],
					light_radius = 120,
				},
				damage                  = {
					default = 0.00,
				},
				--explosionGenerator      = [[custom:flash1red]],
				fireTolerance           = 8192, -- 45 degrees
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 0,
				largeBeamLaser          = true,
				laserFlareSize          = 2,
				leadLimit               = 18,
				minIntensity            = 0.01,
				noSelfDamage            = true,
				range                   = 1020,
				reloadtime              = 1/15,
				sweapfire = false,
				rgbColor                = [[0.8 0 0]],
				rgbColor2				  = [[0.5 0 0]],
				soundStart              = [[weapon/laser/archertracker]],
				--soundHit		= [[trackercompleted.wav]]
				soundStartVolume        = 15,
				texture1                = [[tracker]],
				--texture2                = [[flare]],
				texture3                = [[flare]],
				texture4                = [[smallflare]],
				thickness               = 2,
				tolerance               = 65536/4,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 1500,
			},
		},
		featureDefs                   = {
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[missiletower_dead.s3o]],
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
