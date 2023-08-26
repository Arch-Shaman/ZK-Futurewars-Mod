return { 
	tankaa = {
		unitname               = "tankaa",
		name                   = "Pestle",
		description            = "Canister Flak AA Tank",
		acceleration           = 0.36,
		brakeRate              = 1.8,
		buildCostMetal         = 520,
		builder                = false,
		buildPic               = "tankaa.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "38 52 38",
		collisionVolumeType    = "cylY",
		corpse                 = "DEAD",
		customParams           = {
			modelradius    = "19",
		},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = "tankaa",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maneuverleashlength    = "30",
		health                 = 4000,
		maxSlope               = 18,
		speed                  = 2.4,
		maxWaterDepth          = 22,
		movementClass          = "TANK3",
		moveState              = 0,
		noAutoFire             = false,
		noChaseCategory        = "TERRAFORM LAND SINK TURRET SHIP SATELLITE SWIM FLOAT SUB HOVER",
		objectName             = "corsent.s3o",
		selfDestructAs         = "BIG_UNITEX",
		sfxtypes               = {
			explosiongenerators = {
				"custom:HEAVY_CANNON_MUZZLE",
			},
		},
		script = "tankaa.lua",
		sightDistance          = 660,
		trackOffset            = 6,
		trackStrength          = 5,
		trackStretch           = 1,
		trackType              = "StdTank",
		trackWidth             = 38,
		turninplace            = 0,
		turnRate               = 1044,
		upright                = false,
		workerTime             = 0,
		weapons                = {
			{
				def                = "FLAK",
				--badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING GUNSHIP",
			},
		},
		weaponDefs             = {
			FLAK = {
				name                    = "Flak Canister",
				areaOfEffect            = 0,
				burnblow                = true,
				canattackground         = false,
				--cegTag                  = "vulcanfx",
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting       = 1,
				customParams        	  = {
					reaim_time = 8, -- COB
					isaa = "1",
					light_radius = 0,
					numprojectiles1 = 5,
					projectile1 = "tankaa_tritary",
					spawndist = 300,
					velspread1 = "6.37, 1, 6.37",
					proxy = 1, 
					damage_vs_shield = "150"
				},
				damage  = {
					default = 60.1*5,
				},
				--interceptor = 2,
				edgeEffectiveness       = 0.25,
				explosionGenerator      = "custom:EMG_HIT_HE",
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 1200,
				reloadtime              = 1/3,
				myGravity				= 0.03,
				size                    = 8,
				soundHit                = "weapon/cannon/cannon_fire4",
				soundHitVolume	        = 0.5,
				soundStart              = "weapon/cannon/cannon_fire9",
				soundStartVolume	    = 1,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 900,
				--coverage = 2200,
			},
			TRITARY = {
				name                    = "Flechette",
				cegTag                  = "flak_trail",
				areaOfEffect            = 128,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					light_camera_height = 2000,
					light_color = "1 0.2 0.2",
					isaa = "1",
					light_radius = 0,
					isFlak = 1,
				},
				damage = {
					default = 60.1,
				},
				--interceptor = 2,
				edgeEffectiveness       = 0.95,
				duration                = 0.02,
				explosionGenerator      = "custom:flakplosion",
				fireStarter             = 50,
				heightMod               = 1,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				range                   = 300,
				reloadtime              = 0.8,
				rgbColor                = "0.2 0.2 0.2",
				soundHit                = "weapon/flak_hit2",
				soundHitVolume	      = 0.4,
				--soundTrigger            = true,
				sprayangle              = 1500,
				size = 3,
				thickness               = 2,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 880,
				--coverage = 1000,
			},
		},
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "corsent_dead.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2a.s3o",
			},
		},
	} 
}
