return {
	chickend = {
		name                          = "Chicken Tube",
		description                   = "Defence and energy source",
		activateWhenBuilt             = true,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 5,
		buildingGroundDecalSizeY      = 5,
		buildingGroundDecalType       = "chickend_aoplane.dds",
		buildPic                      = "chickend.png",
		category                      = "SINK",

		customParams                  = {
			chicken = "uwu",
			chicken_structure = "^w^",
			model_rescale_script = 1,
			--armored_regen  = "30",
			--armortype = 1, -- for context menu.
		},
		
		--damageModifier                = 0.4,
		energyMake                    = 8,
		explodeAs                     = "NOWEAPON",
		floater                       = true,
		footprintX                    = 3,
		footprintZ                    = 3,
		health                        = 2400,
		iconType                      = "defense",
		idleAutoHeal                  = 20,
		idleTime                      = 300,
		levelGround                   = false,
		maxSlope                      = 36,
		maxWaterDepth                 = 20,
		metalCost                     = 0,
		energyCost                    = 0,
		buildTime                     = 280,
		noAutoFire                    = false,
		noChaseCategory               = "FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER",
		objectName                    = "tube.s3o",
		onoffable                     = true,
		power                         = 580,
		reclaimable                   = false,
		script                        = "chickend.lua",
		selfDestructAs                = "NOWEAPON",

		sfxtypes                      = {
			explosiongenerators = {
				"custom:blood_spray",
				"custom:blood_explode",
				"custom:dirt",
			},
		},
		sightDistance                 = 512,
		sonarDistance                 = 512,
		upright                       = false,
		useBuildingGroundDecal        = true,
		workerTime                    = 0,
		yardMap                       = "yyyyyyyyy",

		weapons                       = {
			{
				def                = "HIGHSPORES",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},


		weaponDefs                    = {
			HIGHSPORES = {
				name                    = "Explosive Spores",
				areaOfEffect            = 24,
				avoidFriendly           = false,
				burst                   = 4,
				burstrate               = 0.2,
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				
				customParams            = {
					light_radius = 0,
				},
				
				damage                  = {
					default = 75,
					planes  = 75,
				},

				dance                   = 60,
				explosionGenerator      = "custom:goo_v2_red",
				impactOnly              = false,
				fireStarter             = 0,
				flightTime              = 5,
				groundbounce            = 1,
				heightmod               = 0.5,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 2,
				model                   = "chickeneggyellow.s3o",
				range                   = 680,
				reloadtime              = 4,
				smokeTrail              = true,
				startVelocity           = 271,
				texture1                = "",
				texture2                = "sporetrail",
				tolerance               = 10000,
				tracks                  = true,
				trajectoryHeight        = 1.3,
				turnRate                = 24000,
				turret                  = true,
				waterweapon             = true,
				--weaponAcceleration      = 100,
				weaponType              = "MissileLauncher",
				weaponVelocity          = 271,
				wobble                  = 32000,
			},
		},
	}
}
