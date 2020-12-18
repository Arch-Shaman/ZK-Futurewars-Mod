return { 
	shieldraid = {
		unitname               = [[shieldraid]],
		name                   = [[Bandit]],
		description            = [[Medium-Light Raider Bot]],
		acceleration           = 1.5,
		activateWhenBuilt      = true,
		brakeRate              = 2.4,
		buildCostMetal         = 90,
		buildPic               = [[shieldraid.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND TOOFAST]],
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[24 29 24]],
		collisionVolumeType    = [[cylY]],
		corpse                 = [[DEAD]],

		customParams           = {
			--modelradius        = [[12]],
			aim_lookahead      = 80,
			shield_emit_height = 17,
		},

		explodeAs              = [[SMALL_UNITEX]],
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = [[walkerraider]],
		idleAutoHeal           = 10,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 330,
		maxSlope               = 36,
		maxVelocity            = 2.8,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = [[KBOT2]],
		noChaseCategory        = [[TERRAFORM FIXEDWING SUB]],
		objectName             = [[mbot.s3o]],
		script                 = [[shieldraid.lua]],
		selfDestructAs         = [[SMALL_UNITEX]],

		sfxtypes               = {
			explosiongenerators = {
				[[custom:BEAMWEAPON_MUZZLE_RED]],
			},
		},

		sightDistance          = 560,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = [[ComTrack]],
		trackWidth             = 18,
		turnRate               = 3000,
		upright                = true,

		weapons                = {

			{
				def                = [[LASER]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
			{
				def                = [[SHIELD]],
			},

		},

		weaponDefs             = {
			LASER = {
				name                    = [[Orange Micropulse Laser]],
				areaOfEffect            = 8,
				accuracy				= 550,
				coreThickness           = 0.5,
				beamTime                = 1/30,
				craterBoost             = 0,
				craterMult              = 0,
				
				customParams        = {
					light_camera_height = 1200,
					light_radius = 20,
				},
      
				damage                  = {
					default = 7.51,
				},

				duration                = 2/30,
				explosionGenerator      = [[custom:beamweapon_hit_orange]],
				fireStarter             = 50,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				leadLimit               = 0,
				noSelfDamage            = true,
				range                   = 255,
				reloadtime              = 2/30,
				rgbColor                = [[1 0.27059 0]],
				soundStart              = [[weapon/laser/orange_micropulse]],
				soundstartvolume	    = 75,
				thickness               = 2.55,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 880,
			},
			SHIELD = {
				name                    = [[Energy Shield]],	
				damage                  = {	
					default = 10,	
				},	
				
				exteriorShield          = true,	
				shieldAlpha             = 0.2,	
				shieldBadColor          = [[1 0.1 0.1 1]],	
				shieldGoodColor         = [[0.1 0.1 1 1]],	
				shieldInterceptType     = 3,	
				shieldPower             = 400,	
				shieldPowerRegen        = 10,	
				shieldPowerRegenEnergy  = 0.3,
				shieldRadius            = 60,	
				shieldRepulser          = false,	
				shieldStartingPower     = 400,	
				smartShield             = true,	
				visibleShield           = false,	
				visibleShieldRepulse    = false,	
				weaponType              = [[Shield]],	
			},
		},

		featureDefs            = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[mbot_d.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2b.s3o]],
			},

		},
	} 
}
