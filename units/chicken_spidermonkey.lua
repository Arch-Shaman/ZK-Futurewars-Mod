return { 
	chicken_spidermonkey = {
		unitname            = "chicken_spidermonkey",
		name                = "Spidermonkey",
		description         = "All-Terrain Support",
		acceleration        = 1.08,
		activateWhenBuilt   = true,
		brakeRate           = 1.23,
		buildCostMetal      = 1,
		builder             = false,
		buildPic            = "chicken_spidermonkey.png",
		buildTime           = 625,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "LAND",
		customParams        = {
			chicken = "uwu",
			outline_x = 145,
			outline_y = 145,
			outline_yoff = 30,
			model_rescale = 1.2,
		},
		explodeAs           = "NOWEAPON",
		footprintX          = 3,
		footprintZ          = 3,
		iconType            = "spiderskirm",
		idleAutoHeal        = 20,
		idleTime            = 300,
		leaveTracks         = true,
		health              = 3750,
		maxSlope            = 84,
		waterline           = 22,
		movementClass       = "ATKBOT3",
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM STUPIDTARGET MINE",
		objectName          = "chicken_spidermonkey.s3o",
		reclaimable         = false,
		selfDestructAs      = "NOWEAPON",
		sfxtypes            = {
			explosiongenerators = {
				"custom:blood_spray",
				"custom:blood_explode",
				"custom:dirt",
			},
		},
		sightDistance       = 700,
	    script              = "chicken_spidermonkey.lua",
		speed               = 164,
		trackOffset         = 0.5,
		trackStrength       = 9,
		trackStretch        = 1,
		trackType           = "ChickenTrackPointy",
		trackWidth          = 70,
		turnRate            = 1440,
		upright             = false,
		weapons             = {
			{
				def                = "WEB",
				badTargetCategory  = "UNARMED",
				onlyTargetCategory = "LAND SINK TURRET SHIP SWIM FLOAT HOVER",
				mainDir            = "0 0 1",
				maxAngleDif        = 180,
			},
			{
				def                = "AEROSPORES",
				onlyTargetCategory = "FIXEDWING GUNSHIP",
			},
		},
		weaponDefs          = {
			WEB    = {
				name                    = "Bio-Disruptor",
				areaOfEffect            = 300,
				avoidFeature            = true,
				cegTag                  = "beamweapon_muzzle_purple",
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					timeslow_damagefactor = 4,
					light_camera_height = 3500,
					light_color = "0.5 0.0 0.5",
					light_radius = 220,
					timeslow_overslow_frames = 5*30,
					nofriendlyfire = 1,
				},

				damage                  = {
					default = 300,
				},
				edgeeffectiveness       = 0.6,
				explosionGenerator      = "custom:goo_v2_purple_large",
				explosionScar           = false,
				fireStarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 2,
				range                   = 800,
				mygravity				= 0.10,
				reloadtime              = 5.5,
				rgbColor				= "0.5 0 0.5",
				smokeTrail              = true,
				size 					= 8,
				soundHit                = "weapon/cannon/heavy_disrupter_hit",
				soundHitVolume          = 8,
				soundStart              = "weapon/cannon/funnel_fire",
				highTrajectory          = 0,
				tolerance               = 8000,
				turret                  = true,
				waterweapon             = true,
				weaponType              = "Cannon",
				weaponVelocity          = 420,
			},
			AEROSPORES  = {
				name                    = "Anti-Air Spores",
				areaOfEffect            = 96,
				avoidFriendly           = false,
				burst                   = 3,
				burstrate               = 0.266,
				canAttackGround         = false,
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				
				customParams            = {
					light_radius = 0,
					armorpiercing = 0.2,
					isaa = ">w<",
					combatrange = 750,
				},
				
				damage                  = {
					default  = 200,
				},

				dance                   = 120,
				explosionGenerator      = "custom:goo_v2_blue",
				explosionScar           = false,
				fireStarter             = 0,
				fixedlauncher           = 1,
				flightTime              = 3,
				groundbounce            = 1,
				heightmod               = 0.5,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = "chickeneggblue.s3o",
				noSelfDamage            = true,
				range                   = 1200,
				reloadtime              = 8,
				smokeTrail              = true,
				startVelocity           = 300,
				texture1                = "",
				texture2                = "sporetrailblue",
				tolerance               = 10000,
				tracks                  = true,
				trajectoryHeight        = 1,
				turnRate                = 60000,
				turret                  = true,
				waterweapon             = true,
				weaponAcceleration      = 150,
				weaponType              = "MissileLauncher",
				weaponVelocity          = 2000,
				wobble                  = 96000,
			},
		},
	} 
}
