return { turretaaflak = {
		unitname                      = [[turretaaflak]],
		name                          = [[Thresher]],
		description                   = [[Flak Canister AAA]],
		acceleration                  = 0,
		brakeRate                     = 0,
		buildCostMetal                = 450,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 5,
		buildingGroundDecalSizeY      = 5,
		buildingGroundDecalType       = [[turretaaflak_aoplane.dds]],
		buildPic                      = [[turretaaflak.png]],
		category                      = [[FLOAT]],
		collisionVolumeOffsets        = [[0 11 -4]],
		collisionVolumeScales         = [[50 86 50]],
		collisionVolumeType	        = [[CylY]],
		corpse                        = [[DEAD]],

		customParams                  = {
			aimposoffset   = [[0 16 0]],
		},

		explodeAs                     = [[MEDIUM_BUILDINGEX]],
		floater                       = true,
		footprintX                    = 3,
		footprintZ                    = 3,
		iconType                      = [[staticaa]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		levelGround                   = false,
		maxDamage                     = 3000,
		maxSlope                      = 18,
		maxVelocity                   = 0,
		maxWaterDepth                 = 5000,
		minCloakDistance              = 150,
		noAutoFire                    = false,
		noChaseCategory               = [[FIXEDWING LAND SINK TURRET SHIP SATELLITE SWIM GUNSHIP FLOAT SUB HOVER]],
		objectName                    = [[corflak.s3o]],
		selfDestructAs                = [[MEDIUM_BUILDINGEX]],

		sfxtypes               = {

		explosiongenerators = {
				[[custom:HEAVY_CANNON_MUZZLE]],
			},

		},
		sightDistance                 = 660,
		turnRate                      = 0,
		useBuildingGroundDecal        = true,
		workerTime                    = 0,
		yardMap                       = [[ooo ooo ooo]],

		weapons                       = {
			{
				def                = [[ARMFLAK_GUN]],
				--badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING GUNSHIP]],
			},

		},


		weaponDefs                    = {

			ARMFLAK_GUN = {
				name                    = [[Flak Canister]],
				accuracy                = 900,
				areaOfEffect            = 0,
				burnblow                = true,
				canattackground         = false,
				--cegTag                  = [[vulcanfx]],
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting       = 1,

				customParams        	  = {
					reaim_time = 8, -- COB
					isaa = [[1]],
					light_radius = 0,
					numprojectiles = 4, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile = "turretaaflak_tritary", -- the weapondef name. we will convert this to an ID in init. REQUIRED. If defined in the unitdef, it will be unitdefname_weapondefname.
					--spreadradius = 3, -- used in clusters. OPTIONAL. Default: 100.
					clustervec = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 400, -- at what distance should we spawn the projectile(s)? REQUIRED.
					vradius = "-1,-1,-1,1,1,1", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
					proxy = 1, -- check for nearby units?
					proxydist = 300, -- how far to check for units? Default: spawndist
				},

				damage  = {
					default = 28*4,
					planes  = 180*4,
				},
				--interceptor = 2,
				edgeEffectiveness       = 0.25,
				explosionGenerator      = [[custom:EMG_HIT_HE]],
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 2000,
				reloadtime              = 1/3,
				size                    = 8,
				soundHit                = [[weapon/cannon/cannon_fire4]],
				soundHitVolume	        = 0.25,
				soundStart              = [[weapon/cannon/cannon_fire9]],
				soundStartVolume	    = 0.75,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 600,
				--coverage = 2200,
			},
	
			TRITARY = {
				name                    = [[Flechette]],
				cegTag                  = [[flak_trail]],
				areaOfEffect            = 128,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,

				customParams            = {
					light_camera_height = 2000,
					light_color = [[1 0.2 0.2]],
					light_radius = 128,
					reaim_time = 8, -- COB
					isaa = [[1]],
					light_radius = 0,
					isFlak = 3,
					flaktime = 1/30,
				},

				damage = {
					default = 18,
					planes  = 180,
				},
				--interceptor = 2,
				edgeEffectiveness       = 0.3,
				duration                = 0.02,
				explosionGenerator      = [[custom:flakplosion]],
				fireStarter             = 50,
				heightMod               = 1,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				range                   = 300,
				reloadtime              = 0.8,
				rgbColor                = [[0.2 0.2 0.2]],
				soundHit                = [[weapon/flak_hit2]],
				soundHitVolume	      = 0.25,
				--soundTrigger            = true,
				sprayangle              = 1500,
				size = 3,
				thickness               = 2,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 880,
				--coverage = 1000,
			},

		},
		featureDefs                   = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[corflak_dead.s3o]],
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