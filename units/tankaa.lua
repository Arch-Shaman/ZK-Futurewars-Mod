return { 
	tankaa = {
		unitname               = [[tankaa]],
		name                   = [[Pestle]],
		description            = [[Canister Flak AA Tank]],
		acceleration           = 0.36,
		brakeRate              = 1.8,
		buildCostMetal         = 600,
		builder                = false,
		buildPic               = [[tankaa.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND]],
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[38 52 38]],
		collisionVolumeType    = [[cylY]],
		corpse                 = [[DEAD]],

		customParams           = {
			modelradius    = [[19]],
		},

		explodeAs              = [[BIG_UNITEX]],
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = [[tankaa]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maneuverleashlength    = [[30]],
		maxDamage              = 1400,
		maxSlope               = 18,
		maxVelocity            = 3.2,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = [[TANK3]],
		moveState              = 0,
		noAutoFire             = false,
		noChaseCategory        = [[TERRAFORM LAND SINK TURRET SHIP SATELLITE SWIM FLOAT SUB HOVER]],
		objectName             = [[corsent.s3o]],
		selfDestructAs         = [[BIG_UNITEX]],
		sfxtypes               = {

			explosiongenerators = {
				[[custom:HEAVY_CANNON_MUZZLE]],
			},

		},
		sightDistance          = 660,
		trackOffset            = 6,
		trackStrength          = 5,
		trackStretch           = 1,
		trackType              = [[StdTank]],
		trackWidth             = 38,
		turninplace            = 0,
		turnRate               = 1044,
		upright                = false,
		workerTime             = 0,
		weapons                = {
			{
				def                = [[FLAK]],
				--badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING GUNSHIP]],
			},

		},
		weaponDefs             = {

			FLAK = {
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
					numprojectiles1 = 3, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "tankaa_tritary", -- the weapondef name. we will convert this to an ID in init. REQUIRED. If defined in the unitdef, it will be unitdefname_weapondefname.
					--spreadradius1 = 3, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 200, -- at what distance should we spawn the projectile(s)? REQUIRED.
					vradius1 = "-1,-1,-1,1,1,1", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
					proxy = 1, -- check for nearby units?
					proxydist = 200, -- how far to check for units? Default: spawndist
					damage_vs_shield = [[90]]
				},

				damage  = {
					default = 8*3,
					planes  = 60*3,
				},
				--interceptor = 2,
				edgeEffectiveness       = 0.25,
				explosionGenerator      = [[custom:EMG_HIT_HE]],
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 1100,
				reloadtime              = 1/3,
				myGravity				= 0.03,
				size                    = 8,
				soundHit                = [[weapon/cannon/cannon_fire4]],
				soundHitVolume	        = 0.5,
				soundStart              = [[weapon/cannon/cannon_fire9]],
				soundStartVolume	= 1,
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
					flaktime = -15,
				},

				damage = {
					default = 8,
					planes  = 60,
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
				soundHitVolume	      = 0.4,
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
		featureDefs            = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[corsent_dead.s3o]],
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
