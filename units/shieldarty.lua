return { 
	shieldarty = {
		unitname               = "shieldarty",
		name                   = "Preserver",
		description            = "Disarming Artillery",
		acceleration           = 0.75,
		brakeRate              = 4.5,
		buildCostMetal         = 550,
		buildPic               = "SHIELDARTY.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND",
		corpse                 = "DEAD",
		activateWhenBuilt	   = true,
		customParams           = {},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = "walkerlrarty",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		health                 = 660,
		maxSlope               = 36,
		speed                  = 1.7,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = "KBOT2",
		noChaseCategory        = "TERRAFORM FIXEDWING GUNSHIP UNARMED",
		objectName             = "dominator.s3o",
		script                 = "shieldarty.lua",
		selfDestructAs         = "BIG_UNITEX",
		sfxtypes               = {
			explosiongenerators = {
				"custom:STORMMUZZLE",
				"custom:STORMBACK",
			},
		},
		sightDistance          = 325,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = "ComTrack",
		trackWidth             = 22,
		turnRate               = 2160,
		upright                = true,
		weapons                = {
			{
				def                = "EMP_ROCKET",
				onlyTargetCategory = "FIXEDWING GUNSHIP SWIM LAND SINK TURRET FLOAT SHIP HOVER",
			},
			{
				def                = "SHIELD",
			},
		},
		weaponDefs             = {
			EMP_ROCKET = {
				name                    = "Disarm Cruise Missile",
				areaOfEffect            = 24,
				cegTag                  = "disarmtrail",
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				avoidground				= false,
				customParams        = {
					burst = Shared.BURST_RELIABLE,
					disarmDamageMult = 1,
					disarmDamageOnly = 1,
					disarmTimer      = 6, -- seconds
					numprojectiles1 = 25,
					projectile1 = "shieldarty_lightning",
					--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0,
					spawndist = 250,
					keepmomentum1 = true,
					timeoutspawn = 1, 
					velspread1 = "-10,-7,-10,10,2,10", -- velocity that is randomly added. covers range of +-velspread. OPTIONAL. Default: 4.2
					groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					light_camera_height = 1500,
					light_color = "1 1 1",
					cruisealt = 500,
					cruisedist = 250,
					useheight = 1,
					cruisetracking = true,
					reveal_unit = 10,
				},
				damage                  = {
					default        = 10000,
				},
				edgeEffectiveness       = 0.4,
				explosionGenerator      = "custom:WHITE_LIGHTNING_BOMB",
				fireStarter             = 0,
				flightTime              = 6,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 2,
				model                   = "wep_merl.s3o",
				noSelfDamage            = true,
				range                   = 1050,
				reloadtime              = 10,
				smokeTrail              = false,
				soundHit                = "weapon/more_lightning_fast",
				soundHitVolume          = 9.0,
				soundStart              = "weapon/missile/missile_launch_high",
				soundStartVolume        = 11.0,
				startvelocity           = 250,
				--texture1                = "spark", --flare
				texture3                = "spark", --flame
				tolerance               = 4000,
				tracks                  = true,
				turnRate                = 38000,
				weaponAcceleration      = 275,
				weaponType              = "StarburstLauncher",
				weaponVelocity          = 800,
			},
			LIGHTNING = {
				name                    = "Lightning Burst",
				accuracy                = 1000,
				--areaOfEffect            = 64,
				corethickness           = 0.1,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					light_camera_height = 1800,
					light_color = "2 2 2",
					light_radius = 20,
					disarmDamageMult = 1,
					disarmDamageOnly = 1,
					disarmTimer      = 12, -- seconds
				},
				damage                  = {
					default = 400,
				},
				duration                = 0.1,
				edgeEffectiveness       = 0.4,
				explosionGenerator      = "custom:mixed_white_lightning_bomb_small",
				explosionScar           = false,
				flightTime              = 1,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				hardStop                = true,
				fallOffRate             = 1,
				largebeamlaser			= true,
				range                   = 1000,
				reloadtime              = 1.4,
				targetborder            = 1,
				texture1                = "lightning",
				texture2                = "",
				texture3                = "",
				texture4                = "",
				tileLength              = 50,
				thickness               = 18,
				rgbColor                = "1 1 1",
				soundHit                = "PreserverSecondaryHit",
				soundHitVolume          = 0.1,
				turret                  = true,
				weaponType              = "LaserCannon",
				weaponVelocity          = 2500,
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
				shieldPower             = 1500,	
				shieldPowerRegen        = 30,	
				shieldPowerRegenEnergy  = 3,	
				shieldRadius            = 120,	
				shieldRepulser          = false,	
				shieldStartingPower     = 1125,	
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
				object           = "dominator_dead.s3o",
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
