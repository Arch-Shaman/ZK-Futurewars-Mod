return {
	roost = {
		name              = "Roost",
		description       = "Spawns Chicken",
		activateWhenBuilt = true,
		builder           = false,
		buildPic          = "roost.png",
		category          = "SINK",

		customParams      = {
			chicken = "uwu",
			chicken_structure = "^w^",
			chicken_roost = ">w<",
		},
		
		energyMake        = 12,
		explodeAs         = "NOWEAPON",
		footprintX        = 3,
		footprintZ        = 3,
		health            = 4200,
		iconType          = "special",
		idleAutoHeal      = 20,
		idleTime          = 300,
		levelGround       = false,
		maxSlope          = 36,
		buildTime         = 540,
		--metalMake         = 3,
		noAutoFire        = false,
		power             = 540,
		objectName        = "roost.s3o",
		script            = "roost.lua",
		selfDestructAs    = "NOWEAPON",

		sfxtypes          = {
			explosiongenerators = {
				"custom:dirt2",
				"custom:dirt3",
			},
		},
		sightDistance     = 273,
		upright           = false,
		waterline         = 0,
		workerTime        = 0,
		yardMap           = "yyyyyyyyy",

		weapons           = {
			{
				def                = "AEROSPORES",
				onlyTargetCategory = "FIXEDWING GUNSHIP",
			},
		},


		weaponDefs        = {
			AEROSPORES  = {
				name                    = "Anti-Air Spores",
				areaOfEffect            = 96,
				avoidFriendly           = false,
				burst                   = 5,
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
				reloadtime              = 7,
				smokeTrail              = true,
				startVelocity           = 50,
				texture1                = "",
				texture2                = "sporetrailblue",
				tolerance               = 10000,
				tracks                  = true,
				turnRate                = 54000,
				turret                  = true,
				waterweapon             = true,
				weaponAcceleration      = 300,
				weaponType              = "MissileLauncher",
				weaponVelocity          = 2000,
				wobble                  = 96000,
			},
		},

		featureDefs       = {
		},
	}
}
