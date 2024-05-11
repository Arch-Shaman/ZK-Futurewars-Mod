return { 
	shieldshield = {
		unitname               = "shieldshield",
		name                   = "Aspis",
		description            = "Area Shield Walker",
		acceleration           = 0.75,
		activateWhenBuilt      = true,
		brakeRate              = 4.5,
		buildCostMetal         = 675,
		buildPic               = "shieldshield.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND UNARMED",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "34 39 29",
		collisionVolumeType    = "box",
		corpse                 = "DEAD",
		customParams           = {
			modelradius    = "17",
			morphto = "staticshield",
			morphtime = 5,
			combatmorph = "1",
			morphspeed = 0.001,
			priority_misc = 1, -- Medium
			unarmed       = true,
			outline_x = 80,
			outline_y = 80,
			outline_yoff = 12.5,
		},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = "walkershield",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		health                 = 1600,
		maxSlope               = 36,
		speed                  = 2.1,
		maxWaterDepth          = 5000,
		movementClass          = "AKBOT2",
		moveState              = 0,
		objectName             = "m-8.s3o",
		onoffable              = true,
		pushResistant          = 0,
		script                 = "shieldshield.lua",
		selfDestructAs         = "BIG_UNITEX",
		sightDistance          = 300,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = "ChickenTrackPointy",
		trackWidth             = 30,
		turnRate               = 2520,
		upright                = false,
		weapons                = {
			{
				def = "COR_SHIELD_SMALL",
			},
		},
		weaponDefs             = {
			COR_SHIELD_SMALL = {
				name                    = "Energy Shield",
				customParams = {
					shield_power_gfx_override = 3500,
				},
				damage                  = {
					default = 10,
				},
				exteriorShield          = true,
				shieldAlpha             = 0.2,
				shieldBadColor          = "1 0.1 0.1 1",
				shieldGoodColor         = "0.1 0.1 1 1",
				shieldInterceptType     = 3,
				shieldPower             = 9000,
				shieldStartingPower     = 6750,	
				shieldPowerRegen        = 90,
				shieldPowerRegenEnergy  = 15,
				shieldRadius            = 350,
				shieldRepulser          = false,
				smartShield             = true,
				visibleShield           = false,
				visibleShieldRepulse    = false,
				--texture1                = "shield3mist",
				--visibleShield           = true,
				--visibleShieldHitFrames  = 4,
				--visibleShieldRepulse    = true,
				weaponType              = "Shield",
			},
		},
		featureDefs            = {
			DEAD = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 1,
				footprintZ       = 1,
				object           = "shield_dead.s3o",
			},
			HEAP = {
				blocking         = false,
				footprintX       = 1,
				footprintZ       = 1,
				object           = "debris1x1a.s3o",
			},
		},
	} 
}
