return { 
	subscout = {
		unitname              = "subscout",
		name                  = "Lancelet",
		description           = "Self-Guided Torpedo",
		acceleration          = 0.192,
		activateWhenBuilt     = true,
		brakeRate             = 3.0,
		buildCostMetal        = 100,
		builder               = false,
		buildPic              = "subscout.png",
		canGuard              = true,
		canMove               = true,
		canPatrol             = true,
		category              = "SUB FIREPROOF",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "18 12 38",
		collisionVolumeType    = "cylZ",
		customParams          = {
			fireproof = "1",
			turnatfullspeed = "1",
			ispuppy = 1,
		},
		explodeAs             = "SUBSCOUT_DEATH",
		fireState              = 0,
		footprintX            = 2,
		footprintZ            = 2,
		iconType              = "subbomb",
		idleAutoHeal          = 5,
		idleTime              = 1800,
		health                = 200,
		speed                 = 4.1,
		minCloakDistance      = 75,
		minWaterDepth         = 5,
		movementClass         = "UBOAT3",
		noChaseCategory       = "FIXEDWING SATELLITE HOVER",
		objectName            = "subscout.s3o",
		script                = "subscout.lua",
		selfDestructAs        = "SUBSCOUT_DEATH",
		selfDestructCountdown = 0,
		sightDistance         = 650,
		sonarDistance         = 650,
		turnRate              = 800,
		upright               = true,
		waterline             = 15,
		weapons = {
			{
				def                = "TORPEDO",
				mainDir            = [[0 0 1]],
				maxAngleDif        = 60,
				onlyTargetCategory = "SWIM LAND SUB SINK TURRET FLOAT SHIP HOVER",
			},
			{
				def                = "FAKELANDCHECK",
				onlyTargetCategory = "SWIM LAND SUB SINK TURRET FLOAT SHIP HOVER",
			},
		},
		weaponDefs = {
			TORPEDO = {
				name                    = "TN-12 Nuclear Tipped Torpedo",
				areaofeffect            = 150,
				craterboost             = 1,
				cratermult              = 4,
				--cegtag				    = [[serpent_trail]],
				craterBoost             = 0,
				craterMult              = 0,
				customParams			= {
					stays_underwater = 1,
					cruisealt = -15,
					cruisetracking = 1,
					cruise_nolock = 1,
					cruisedist = 140,
				},
				damage = {
					default = 3500.01,
				},
				explosionGenerator      = "custom:NUKE_150",
				edgeeffectiveness       = 0.5,
				fireStarter             = 200,
				flightTime              = 8,
				fireSubmersed           = true,
				impactOnly              = false,
				impulseboost            = 0,
				impulsefactor           = 2,
				interceptedByShieldType = 1,
				leadlimit               = 0,
				model                   = [[subscout.s3o]],
				reloadtime              = 2,
				range                   = 380,
				soundStart              = [[weapon/torpedo/torplaunch_underwater]],
				soundStartVolume        = 7,
				soundhit                = "explosion/mini_nuke",
				startVelocity           = 150,
				tolerance               = 200,
				tracks                  = true,
				turnRate                = 30000,
				turret                  = true,
				waterWeapon             = true,
				weaponAcceleration      = 150,
				weaponType              = [[TorpedoLauncher]],
				weaponVelocity          = 520,
			},
			SUBSCOUT_DEATH = {
				name                    = "TN-2800 Nuclear Tipped Torpedo",
				areaofeffect            = 150,
				craterboost             = 1,
				cratermult              = 4,
				edgeeffectiveness       = 0.5,
				explosionGenerator      = "custom:NUKE_150",
				fireStarter             = 200,
				impulseboost            = 0,
				impulsefactor           = 2,
				interceptedbyshieldtype = 1,
				range                   = 200,
				reloadtime              = 3.6,
				soundhit                = "explosion/mini_nuke",
				turret                  = 1,
				weaponvelocity          = 250,
				damage = {
					default = 3500.01,
				},
			},
			FAKELANDCHECK = {
				name                    = "Fake Land Suicide Check",
				areaofeffect            = 150,
				avoidground             = false,
				avoidfriendly           = false,
				craterboost             = 1,
				cratermult              = 4,
				craterBoost             = 0,
				craterMult              = 0,
				customParams			= {
					bogus = 1,
				},
				damage = {
					default = 0,
				},
				explosionGenerator      = "custom:NUKE_150",
				edgeeffectiveness       = 0.5,
				fireStarter             = 200,
				flightTime              = 8,
				impactOnly              = false,
				impulseboost            = 0,
				impulsefactor           = 2,
				interceptedByShieldType = 1,
				leadlimit               = 0,
				model                   = [[subscout.s3o]],
				reloadtime              = 2,
				range                   = 75,
				soundhit                = "explosion/mini_nuke",
				startVelocity           = 350,
				tracks                  = true,
				turnRate                = 15800,
				turret                  = true,
				weaponAcceleration      = 300,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 520,
			},
		},
	}
}
