return {
	spiderriot = {
		unitname               = "spiderriot",
		name                   = "Commando",
		description            = "Heavy Riot Spider",
		acceleration           = 0.66,
		--autoheal               = 30,
		brakeRate              = 3.96,
		buildCostMetal         = 400,
		buildPic               = "spiderriot.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND",
		collisionVolumeOffsets = "0 5 0",
		collisionVolumeScales  = "36 36 36",
		collisionVolumeType    = "ellipsoid",
		corpse                 = "DEAD",
		
		customParams           = {
			aimposoffset   = "0 10 0",
			nanoregen = 10,
			nano_maxregen = 5,
			aim_lookahead = 80,
			firecycle = 1,
		},
		
		explodeAs              = "BIG_UNITEX",
		footprintX             = 3,
		footprintZ             = 3,
		highTrajectory         = 2,
		iconType               = "spiderriot",
		idleAutoHeal           = 20,
		idleTime               = 900,
		leaveTracks            = true,
		losEmitHeight          = 40,
		health                 = 1600,
		maxSlope               = 72,
		speed                  = 1.6,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = "TKBOT3",
		noChaseCategory        = "TERRAFORM FIXEDWING SUB",
		objectName             = "spiderriot.s3o",
		script                 = "spiderriot.lua",
		selfDestructAs         = "BIG_UNITEX",
		sightDistance          = 400,
		trackOffset            = 0,
		trackStrength          = 10,
		trackStretch           = 1,
		trackType              = "ChickenTrackPointyShort",
		trackWidth             = 55,
		turnRate               = 1700,
		
		weapons                = {
		
			{
				def                = "NAPALM_SPRAYER",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		
		},
		
		weaponDefs             = {
			NAPALM_SPRAYER = {
				name                    = "Thermite Sprayer",
				--accuracy                = 500,
				areaOfEffect            = 128,
				avoidFeature            = false,
				craterBoost             = 0,
				craterMult              = 0,
				projectiles             = 4,
				cegTag                  = "flamer",
				customParams              = {
					setunitsonfire = "1",
					burnchance = "1", -- Per-impact
					burntime = "120",
					sweepfire = 1,
					sweepfire_maxangle = 25,
					sweepfire_step = 3,
					sweepfire_fastupdate = 1,
					sweepfire_maxrangemult = 0.95,
					usefirecycle = 1,
					light_color = "0.6 0.39 0.18",
					light_radius = 100,
				},
				
				damage                  = {
					default = 20.1,
				},
				edgeEffectiveness       = 0.8,
				explosionGenerator      = "custom:napalm_phoenix",
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				myGravity               = 0.49,
				--projectiles             = 10,
				range                   = 370,
				reloadtime              = 7/30,
				rgbColor                = "1 0.5 0.2",
				size                    = 5,
				soundHit                = "flamethrowerhit",
				soundStart              = "flamethrowerfire",
				soundStartVolume        = 3.2,
				sprayangle              = 1600,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 500,
			},
		},
		
		featureDefs            = {
		
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 3,
				footprintZ       = 3,
				object           = "tarantula_dead.s3o",
			},
		
			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = "debris3x3a.s3o",
			},
		
		},

} }
