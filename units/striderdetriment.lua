return { 
	striderdetriment = {
		unitname               = [[striderdetriment]],
		name                   = [[Detriment]],
		description            = [[Ultimate Assault Strider]],
		acceleration           = 0.328,
		activateWhenBuilt      = true,
		autoheal               = 200,
		brakeRate              = 1.435,
		buildCostMetal         = 25000,
		builder                = false,
		buildPic               = [[striderdetriment.png]],
		canGuard               = true,
		--canManualFire          = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND]],
		collisionVolumeOffsets = [[0 14 0]],
		collisionVolumeScales  = [[92 158 92]],
		collisionVolumeType    = [[cylY]],
		corpse                 = [[DEAD]],

		customParams           = {
			modelradius    = [[95]],
			extradrawrange = 925,
		},
		explodeAs              = [[NUCLEAR_MISSILE]],
		footprintX             = 6,
		footprintZ             = 6,
		iconType               = [[krogoth]],
		leaveTracks            = true,
		losEmitHeight          = 100,
		maxDamage              = 160000,
		maxSlope               = 37,
		maxVelocity            = 1.0,
		maxWaterDepth          = 5000,
		movementClass          = [[AKBOT4]],
		noAutoFire             = false,
		noChaseCategory        = [[TERRAFORM SATELLITE SUB]],
		objectName             = [[detriment.s3o]],
		script                 = [[striderdetriment.lua]],
		selfDestructAs         = [[NUCLEAR_MISSILE]],
		selfDestructCountdown  = 10,
		sightDistance          = 1700,
		sonarDistance          = 1700,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 0.8,
		trackType              = [[ComTrack]],
		trackWidth             = 60,
		turnRate               = 482,
		upright                = true,

		weapons                = {

			{
				def                = [[GAUSS]],
				onlyTargetCategory = [[LAND SINK TURRET SUB SHIP SWIM FLOAT HOVER GUNSHIP]],
			},

			{
				def                = [[FLAK]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING GUNSHIP]],
			},

		},
		weaponDefs             = {

			SECONDARY = {
				name                    = [[Fragmentation]],
				areaOfEffect            = 108,
				craterBoost             = 20,
				craterMult              = 4,
				burnblow				= true,
				customParams            = {
					burst = Shared.BURST_RELIABLE,
					force_ignore_ground = [[1]],
					light_color = [[3 2.33 1.5]],
					light_radius = 150,
					isFlak = 3,
					flaktime = -1/30,
				},
		  
				damage                  = {
					default = 720.1,
				},
				edgeEffectiveness = 0.4,
				explosionGenerator      = [[custom:TESS]],
				impulseBoost            = 0,
				impulseFactor           = 2,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 450,
				reloadtime              = 3,
				soundHit                = [[explosion/ex_large9.wav]],
				--soundStart              = [[weapon/cannon/rhino]],
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 470,
				waterWeapon 			= true,
			},

			GAUSS         = {
				name                    = [[Decimator Cannon Barrage]],
				alphaDecay              = 0.12,
				areaOfEffect            = 1,
				avoidfeature            = false,
				bouncerebound           = 0.15,
				bounceslip              = 1,
				burst                   = 6,
				burstrate               = 1.2,
				cegTag                  = [[vulcanfx]],
				craterBoost             = 0,
				craterMult              = 0,
      
				customParams = {
					reaim_time = 1,	
					smoothradius     = [[120]],
					smoothmult       = [[0.8]],
					muzzleEffectFire = [[custom:RAIDMUZZLE]],
					numprojectiles1 = 7, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "striderdetriment_secondary",
					--spreadradius1 = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					proxy = 1, -- check for nearby units?
					proxydist = 200, -- how far to check for units? Default: spawndist
					spawndist = 200, -- at what distance should we spawn the projectile(s)? REQUIRED.
					vradius1 = "-6,-4,-6,2,3,6", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
				},

				damage                  = {
					default = 720.1*7,
				},

				explosionGenerator      = [[custom:100rlexplode]],
				groundbounce            = 1,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 20,
				interceptedByShieldType = 0,
				noSelfDamage            = true,
				range                   = 1600,
				reloadtime              = 9,
				separation              = 0.5,
				size                    = 0.8,
				sizeDecay               = -0.1,
				soundHit                = [[weapon/cannon/outlaw_gun]],
				soundStart              = [[weapon/cannon/cannon_fire9]],
				sprayangle              = 800,
				stages                  = 32,
				tolerance               = 4096,
				turret                  = true,
				waterweapon             = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 900,
			},

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
					projectile1 = "striderdetriment_tritary", -- the weapondef name. we will convert this to an ID in init. REQUIRED. If defined in the unitdef, it will be unitdefname_weapondefname.
					--spreadradius1 = 3, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 200, -- at what distance should we spawn the projectile(s)? REQUIRED.
					vradius1 = "-1,-1,-1,1,1,1", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
					proxy = 1, -- check for nearby units?
					proxydist = 300, -- how far to check for units? Default: spawndist
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
				range                   = 800,
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
					flaktime = -4,
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
				footprintX       = 6,
				footprintZ       = 6,
				object           = [[Detriment_wreck.s3o]],
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
