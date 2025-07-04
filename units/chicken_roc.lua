return {
	chicken_roc = {
		name                = "Roc",
		description         = "Heavy Attack Flyer",
		acceleration        = 1.2,
		activateWhenBuilt   = true,
		airHoverFactor      = 0,
		brakeRate           = 0.8,
		builder             = false,
		buildPic            = "chicken_roc.png",
		buildTime           = 2540,
		canFly              = true,
		canGuard            = true,
		canLand             = true,
		canMove             = true,
		canPatrol           = true,
		canSubmerge         = false,
		category            = "GUNSHIP",
		collide             = false,
		cruiseAltitude      = 150,

		customParams        = {
			chicken = "uwu",
			
			outline_x = 180,
			outline_y = 180,
			outline_yoff = 17.5,
			model_rescale = 1.5,
			chicken_spawncost = 2540,
		},

		explodeAs           = "NOWEAPON",
		floater             = true,
		footprintX          = 2,
		footprintZ          = 2,
		health              = 36400,
		hoverattack         = true,
		iconType            = "heavygunship",
		idleAutoHeal        = 20,
		idleTime            = 300,
		leaveTracks         = true,
		maneuverleashlength = "64000",
		maxSlope            = 36,
		metalCost           = 0,
		power               = 1,
		energyCost          = 0,
		minCloakDistance    = 250,
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM FIXEDWING SATELLITE GUNSHIP STUPIDTARGET MINE",
		objectName          = "chicken_roc.s3o",
		reclaimable         = false,
		script              = "chicken_roc.lua",
		selfDestructAs      = "NOWEAPON",

		sfxtypes            = {

			explosiongenerators = {
				"custom:blood_spray",
				"custom:blood_explode",
				"custom:dirt",
			},

		},
		sightDistance       = 750,
		sonarDistance       = 750,
		speed               = 222,
		turnRate            = 1350,
		workerTime          = 0,

		weapons             = {
			{
				def                = "GOO",
				badTargetCategory  = "GUNSHIP",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
			{
				def                = "AEROSPORES",
				onlyTargetCategory = "FIXEDWING GUNSHIP",
			},
			{
				def                = "SPORES",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},


		weaponDefs          = {

		
			GOO          = {
				name                    = "Blob",
				areaOfEffect            = 96,
				burst                   = 7,
				burstrate               = 0.033,
				craterBoost             = 0,
				craterMult              = 0,
							
				customParams            = {
					light_radius = 0,
					armorpiercing = 0.15,
				},

				damage                  = {
					default = 250,
				},

				explosionGenerator      = "custom:goo_v2_green",
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				proximityPriority       = -4,
				range                   = 550,
				reloadtime              = 3,
				rgbColor                = "0.2 0.6 0",
				size                    = 16,
				sizeDecay               = 0,
				soundHit                = "chickens/acid_hit",
				soundStart              = "chickens/acid_fire",
				sprayAngle              = 1200,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = "Cannon",
				waterweapon             = true,
				weaponVelocity          = 350,
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
					combatrange = 500,
				},
				
				damage                  = {
					default  = 600,
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
				startVelocity           = 50,
				texture1                = "",
				texture2                = "sporetrailblue",
				tolerance               = 10000,
				tracks                  = true,
				turnRate                = 60000,
				turret                  = true,
				waterweapon             = true,
				weaponAcceleration      = 300,
				weaponType              = "MissileLauncher",
				weaponVelocity          = 2000,
				wobble                  = 96000,
			},
			SPORES       = {
				name                    = "Spores",
				areaOfEffect            = 96,
				avoidFriendly           = false,
				burst                   = 8,
				burstrate               = 4/30,
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				
				customParams            = {
					light_radius = 0,
					armorpiercing = 0.4,
					combatrange = 500,
				},

				damage                  = {
					default = 250,
				},

				dance                   = 90,
				explosionGenerator      = "custom:goo_v2_red",
				fireStarter             = 0,
				fixedlauncher           = true,
				flightTime              = 5,
				groundbounce            = 1,
				heightmod               = 0.5,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				metalpershot            = 0,
				model                   = "chickeneggpink.s3o",
				noSelfDamage            = true,
				range                   = 1000,
				reloadtime              = 6,
				smokeTrail              = true,
				startVelocity           = 500,
				texture1                = "",
				texture2                = "sporetrail",
				tolerance               = 10000,
				tracks                  = true,
				trajectoryHeight        = 2,
				turnRate                = 24000,
				turret                  = true,
				waterweapon             = true,
				weaponAcceleration      = 100,
				weaponType              = "MissileLauncher",
				weaponVelocity          = 1000,
				wobble                  = 48000,
			},
		},
	}
}
