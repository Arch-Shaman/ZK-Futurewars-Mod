return { 
	tankriot = {
		unitname            = [[tankriot]],
		name                = [[Ogre]],
		description         = [[Heavy Riot Support Tank]],
		acceleration        = 0.109,
		brakeRate           = 0.428,
		buildCostMetal      = 500,
		builder             = false,
		buildPic            = [[tankriot.png]],
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = [[LAND]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[55 55 55]],
		selectionVolumeType    = [[ellipsoid]],
		corpse              = [[DEAD]],

		customParams        = {
			cus_noflashlight  = 1,
			selection_scale   = 0.92,
			aim_lookahead     = 160,
		},

		explodeAs           = [[BIG_UNITEX]],
		footprintX          = 4,
		footprintZ          = 4,
		iconType            = [[tankriot]],
		idleAutoHeal        = 5,
		idleTime            = 1800,
		leaveTracks         = true,
		maxDamage           = 1850,
		maxSlope            = 18,
		maxVelocity         = 2.3,
		maxWaterDepth       = 22,
		minCloakDistance    = 75,
		movementClass       = [[TANK4]],
		noAutoFire          = false,
		noChaseCategory     = [[TERRAFORM SATELLITE SUB]],
		objectName          = [[corbanish.s3o]],
		script              = [[tankriot.lua]],
		selfDestructAs      = [[BIG_UNITEX]],
		sightDistance       = 400,
		trackOffset         = 8,
		trackStrength       = 10,
		trackStretch        = 1,
		trackType           = [[StdTank]],
		trackWidth          = 50,
		turninplace         = 0,
		turnRate            = 568,
		workerTime          = 0,

		weapons             = {

			{
				def                = [[TAWF_BANISHER]],
				mainDir            = [[0 0 1]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

		},
		weaponDefs          = {
	
			fragment = {
				name                    = [[R-62 Canister Cannon Fragment]],
				areaOfEffect            = 144,
				avoidFeature            = true,
				avoidFriendly           = true,
				burnblow                = true,
				craterBoost             = 1,
				craterMult              = 0.5,

				customParams            = {
					gatherradius = [[120]],
					smoothradius = [[80]],
					smoothmult   = [[0.25]],
					force_ignore_ground = [[1]],
					isFlak = 3,
					flaktime = 1/30,
					light_camera_height = 1500,
				},

				damage                  = {
					default = 30.2,
				},

				edgeEffectiveness       = 0.75,
				explosionGenerator      = [[custom:FLASH64]],
				impulseBoost            = 30,
				impulseFactor           = 0.6,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				soundHit                = [[weapon/cannon/generic_cannon]],
				soundStart              = [[weapon/cannon/outlaw_gun]],
				soundStartVolume        = 3,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 750,
			},
	
			TAWF_BANISHER = {
				name                    = [[R-22 Heavy Canister Missile]],
				areaOfEffect            = 160,
				cegTag                  = [[BANISHERTRAIL]],
				craterBoost             = 1,
				craterMult              = 2,

				customParams            = {
					burst = Shared.BURST_RELIABLE,

					gatherradius = [[120]],
					smoothradius = [[80]],
					smoothmult   = [[0.25]],
					force_ignore_ground = [[1]],

					script_reload = [[3.4]],
					script_burst = [[4]],
					numprojectiles1 = 6, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "tankriot_fragment",
					--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 110, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = "-1,-2,-1,1,-1,1", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
					proxy = 1, -- check for nearby units?
					proxydist = 110, -- how far to check for units? Default: spawndist
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					light_color = [[1.4 1 0.7]],
					light_radius = 320,
				},

      
				damage                  = {
					default = 30.2 * 6,
				},

				edgeEffectiveness       = 0.4,
				explosionGenerator      = [[custom:xamelimpact]],
				fireStarter             = 20,
				flightTime              = 4,
				impulseBoost            = 0,
				impulseFactor           = 0.6,
				interceptedByShieldType = 2,
				leadlimit               = 0,
				model                   = [[corbanishrk.s3o]],
				noSelfDamage            = true,
				range                   = 320,
				reloadtime              = 0.233,
				smokeTrail              = false,
				soundHit                = [[weapon/cannon/outlaw_gun]],
				soundStart              = [[weapon/missile/banisher_fire]],
				startVelocity           = 400,
				tolerance               = 9000,
				tracks                  = true,
				trajectoryHeight        = 0.15,
				turnRate                = 22000,
				turret                  = true,
				weaponAcceleration      = 70,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 400,
			},
		},
		featureDefs         = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[corbanish_dead.s3o]],
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
