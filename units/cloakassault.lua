return { 
	cloakassault = {
		unitname               = "cloakassault",
		name                   = "Snare",
		description            = "Shock and Awe Ambusher",
		acceleration           = 0.6,
		brakeRate              = 3.6,
		buildCostMetal         = 400,
		buildPic               = "cloakassault.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		canCloak			   = true,
		category               = "LAND",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "36 60 36",
		collisionVolumeType    = "cylY",
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "45 45 45",
		selectionVolumeType    = "ellipsoid",
		corpse                 = "DEAD",
		initCloaked            = true,
		cloakCostMoving        = 2.0,
		cloakCost              = 0.2,
		damageModifier         = 0.2,
		customParams           = {
			modelradius    = "12",
			cus_noflashlight = 1,
			cloakregen		   = 20,
			recloaktime 	   = 330,
			cloaker_bestowed_radius = 75,
			bait_level_default = 1,
			cloakstrikeduration = 40,
			cloakstrikeslow = 1.0,
			hasarmorstate 	= 1,
			armortype = 1, -- for context menu.
			armored_slowdown = 0.2,
		},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = "kbotassault",
		idleAutoHeal           = 0,
		idleTime               = 1800,
		leaveTracks            = true,
		losEmitHeight          = 35,
		health                 = 2000,
		maxSlope               = 36,
		speed                  = 2.0,
		maxWaterDepth          = 22,
		minCloakDistance       = 260,
		movementClass          = "KBOT3",
		noChaseCategory        = "TERRAFORM FIXEDWING SUB",
		objectName             = "spherezeus.dae",
		script                 = "cloakassault.lua",
		selfDestructAs         = "BIG_UNITEX",
		sfxtypes               = {
			explosiongenerators = {
				"custom:zeusmuzzle",
				"custom:zeusgroundflash",
			},
		},
		sightDistance          = 420,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 0.8,
		trackType              = "ComTrack",
		trackWidth             = 24,
		turnRate               = 1680,
		upright                = true,
		weapons                = {
			{
				def                = "LIGHTNING",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs             = {
			LIGHTNING = {
				name                    = "Lightning Gun",
				areaOfEffect            = 64,
				craterBoost             = 0,
				craterMult              = 0,
				cegtag					= "antagonist_spark",
				customParams            = {
					extra_damage = 1200,
					light_camera_height = 2000,
					light_color = "0.85 0.85 1.2",
					light_radius = 220,
					cloakstrike = 1 + 1/3,
				},
				cylinderTargeting      = 0,
				damage                  = {
					default        = 660.1,
				},
				duration                = 10,
				explosionGenerator      = "custom:lightningplosion_nopost",
				edgeeffectiveness		= 0.05,
				fireStarter             = 50,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 12,
				interceptedByShieldType = 1,
				paralyzeTime            = 1,
				range                   = 320,
				reloadtime              = 3.1,
				size                    = 0.3,
				mygravity				= 0.02,
				rgbColor                = "0.54 0.54 1",
				soundHit				= "explosion/small_emp_explode",
				soundStart              = "weapon/more_lightning_fast",
				sprayAngle              = 400,
				thickness               = 10,
				turret                  = true,
				waterweapon             = false,
				weaponType              = "Cannon",
				weaponVelocity          = 420,
			},
		},
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "spherezeus_dead.s3o",
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
