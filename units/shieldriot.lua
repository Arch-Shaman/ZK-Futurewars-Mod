return { 
	shieldriot = {
		unitname               = "shieldriot",
		name                   = "Sentry",
		description            = "Shielded Wave Projector",
		acceleration           = 0.75,
		activateWhenBuilt      = true,
		brakeRate              = 4.5,
		buildCostMetal         = 200,
		buildPic               = "shieldriot.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND",
		corpse                 = "DEAD",
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "68 68 68",
		selectionVolumeType    = "ellipsoid",
		customParams           = {
			selection_scale   = 0.85,
			outline_x = 80,
			outline_y = 80,
			outline_yoff = 15.5,
		},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = "walkerriot",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		health                 = 560,
		maxSlope               = 36,
		speed                  = 1.9,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = "KBOT3",
		noChaseCategory        = "TERRAFORM FIXEDWING GUNSHIP SUB",
		objectName             = "behethud.s3o",
		onoffable              = false,
		selfDestructAs         = "BIG_UNITEX",
		script                 = "shieldriot.lua",
		sfxtypes               = {
			explosiongenerators = {
				"custom:RIOTBALL",
				"custom:RAIDMUZZLE",
				"custom:LEVLRMUZZLE",
				"custom:RIOT_SHELL_L",
				"custom:BEAMWEAPON_MUZZLE_RED",
			},
		},
		sightDistance          = 400,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = "ComTrack",
		trackWidth             = 22,
		turnRate               = 2000,
		upright                = true,
		weapons                = {
			{
				def                = "FAKEGUN1",
				badTargetCategory  = "FIXEDWING GUNSHIP",
				onlyTargetCategory = "LAND SINK TURRET SHIP SWIM FLOAT HOVER GUNSHIP FIXEDWING",
			},
			{
				def                = "BLAST",
				badTargetCategory  = "FIXEDWING GUNSHIP",
				onlyTargetCategory = "LAND SINK TURRET SHIP SWIM FLOAT HOVER GUNSHIP FIXEDWING",
			},
			{
				def                = "FAKEGUN2",
				badTargetCategory  = "FIXEDWING GUNSHIP",
				onlyTargetCategory = "LAND SINK TURRET SHIP SWIM FLOAT HOVER GUNSHIP FIXEDWING",
			},
			{
				def = "SHIELD",
			},
		},
		weaponDefs             = {
			BLAST    = {
				name                    = "Disruptor Pulser",
				areaOfEffect            = 575,
				craterBoost             = 0,
				craterMult              = 0,
				damage                  = {
					default = 0,
				},
				customParams           = {
					light_radius = 0,
					lups_explodespeed = 1,
					lups_explodelife = 0.6,
					nofriendlyfire = 1,
					featuredamagemult = 0,
					blastwave_nofriendly = "By the powers of Vittu, Saatana, ja Perkele, I am Captain Suomi!",
					blastwave_size = 12,
					blastwave_impulse = 1.3,
					blastwave_speed = 12,
					blastwave_life = 23,
					blastwave_lossfactor = 0.925,
					blastwave_damage = 40,
					blastwave_slowdmg = 60,
					--norealdamage = "yes", -- stop us from having to deal with that.
				},
				edgeeffectiveness       = 0.8,
				explosionGenerator      = "custom:NONE",
				explosionSpeed          = 12,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				myGravity               = 10,
				noSelfDamage            = true,
				range                   = 110,
				reloadtime              = 0.5,
				soundHitVolume          = 1,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 230,
			},
			FAKEGUN1 = {
				name                    = "Fake Weapon",
				areaOfEffect            = 8,
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				damage                  = {
					default = 1E-06,
				},
				explosionGenerator      = "custom:NONE",
				fireStarter             = 0,
				flightTime              = 1,
				impactOnly              = true,
				interceptedByShieldType = 1,
				range                   = 32,
				reloadtime              = 0.933,
				size                    = 1E-06,
				smokeTrail              = false,
				textures                = {
					"null",
					"null",
					"null",
				},
				turnrate                = 10000,
				turret                  = true,
				weaponAcceleration      = 200,
				weaponTimer             = 0.1,
				weaponType              = "StarburstLauncher",
				weaponVelocity          = 200,
			},
			FAKEGUN2 = {
				name                    = "Fake Weapon",
				areaOfEffect            = 8,
				avoidFriendly           = false,
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				damage                  = {
					default = 1E-06,
				},
				explosionGenerator      = "custom:NONE",
				fireStarter             = 0,
				flightTime              = 1,
				impactOnly              = true,
				interceptedByShieldType = 1,
				range                   = 110,
				reloadtime              = 0.933,
				size                    = 1E-06,
				smokeTrail              = false,
				textures                = {
					"null",
					"null",
					"null",
				},
				turnrate                = 10000,
				turret                  = true,
				weaponAcceleration      = 200,
				weaponTimer             = 0.1,
				weaponType              = "StarburstLauncher",
				weaponVelocity          = 200,
			},
			SHIELD = {
				name                    = "Energy Shield",	
				damage                  = {	
					default = 10,	
				},
				exteriorShield          = true,	
				shieldAlpha             = 0.2,	
				shieldBadColor          = "1 0.1 0.1 1",	
				shieldGoodColor         = "0.1 0.1 1 1",	
				shieldInterceptType     = 3,	
				shieldPower             = 2200,	
				shieldPowerRegen        = 20,	
				shieldPowerRegenEnergy  = 0.5,
				shieldRadius            = 120,	
				shieldRepulser          = false,	
				shieldStartingPower     = 1650,	
				smartShield             = true,	
				visibleShield           = false,	
				visibleShieldRepulse    = false,	
				weaponType              = "Shield",	
			},
		},
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "behethud_dead.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2c.s3o",
			},
		},
	} 
}
