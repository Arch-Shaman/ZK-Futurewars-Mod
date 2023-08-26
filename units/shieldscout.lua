return { 
	shieldscout = {
		unitname               = "shieldscout",
		name                   = "Sapper",
		description            = "Shielded Nuisence",
		acceleration           = 0.6,
		brakeRate              = 3.6,
		buildCostMetal         = 45,
		buildPic               = "shieldscout.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND STUPIDTARGET",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "34 45 27",
		collisionVolumeType    = "box",
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "34 45 34",
		selectionVolumeType    = "cylY",
		corpse                 = "DEAD",
		customParams           = {
			canjump            = 1,
			jump_range         = 400,
			jump_speed         = 8,
			jump_reload        = 3,
			jump_from_midair   = 0,
			jump_spread_exception = 1,
		},
		explodeAs              = "CLOGGER_EXPLODE",
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = "clogger",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		health                 = 360,
		maxSlope               = 36,
		speed                  = 2.8,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = "KBOT2",
		moveState              = 0, -- Used to make blockages.
		noChaseCategory        = "TERRAFORM FIXEDWING GUNSHIP",
		objectName             = "clogger.s3o",
		script                 = "shieldscout.lua",
		selfDestructAs         = "CLOGGER_EXPLODE",
		selfDestructCountdown  = 0,
		sightDistance          = 720,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = "ComTrack",
		trackWidth             = 22,
		turnRate               = 2000,
		upright                = true,
		weapons             = {
			{
				def                = "Headbutt",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP FIXEDWING",
			},
			{
				def                = "SHIELD",
			},
		},
		weaponDefs          = {	
			Headbutt = {
				name                    = "Headbutt",
				beamTime                = 1/30,
				avoidFeature            = false,
				avoidFriendly           = false,
				avoidGround             = false,
				canattackground         = true,
				collideFeature          = false,
				collideFriendly         = false,
				collideGround           = false,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,
				customParams              = {
					light_radius = 0,
					combatrange = 15,
					armorpiercing = 1,
				},
				damage                  = {
					default = 70.01,
				},
				explosionGenerator      = "custom:none",
				fireStarter             = 90,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 0,
				lodDistance             = 10000,
				noSelfDamage            = true,
				range                   = 80,
				reloadtime              = 1,
				rgbColor                = "1 0.25 0",
				soundStart              = "explosion/ex_small4_2",
				soundStartVolume        = 25,
				targetborder            = 0.9,
				thickness               = 0,
				tolerance               = 1000000,
				turret                  = true,
				waterweapon             = true,
				weaponType              = "BeamLaser",
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
				shieldPower             = 600,	
				shieldPowerRegen        = 10,	
				shieldPowerRegenEnergy  = 0,
				shieldRadius            = 75,
				shieldRepulser          = false,
				smartShield             = true,	
				visibleShield           = false,	
				visibleShieldRepulse    = false,	
				weaponType              = "Shield",	
			},
			CLOGGER_EXPLODE = {
				areaOfEffect       = 8,
				craterMult         = 0,
				edgeEffectiveness  = 0,
				explosionGenerator = "custom:dirt2",
				impulseFactor      = 0,
				name               = "Dirt Spill",
				soundHit           = "explosion/clogger_death",
				damage = {
					default = 1,
				},
			},
		},
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris1x1a.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris1x1a.s3o",
			},
		},
	} 
}
