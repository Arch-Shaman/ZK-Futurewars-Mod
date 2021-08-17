return { 
	bomberheavy = {
		unitname            = [[bomberheavy]],
		name                = [[Hella]],
		description         = [[Strategic Bomber]],
		--autoheal          = 25,
		brakerate           = 0.4,
		buildCostMetal      = 4000,
		builder             = false,
		buildPic            = [[bomberheavy.png]],
		canFly              = true,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		canSubmerge         = false,
		category            = [[FIXEDWING]],
		collide             = false,
		collisionVolumeOffsets = [[-2 0 0]],
		collisionVolumeScales  = [[32 12 40]],
		collisionVolumeType    = [[box]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[65 25 65]],
		selectionVolumeType    = [[cylY]],
		corpse              = [[DEAD]],
		crashDrag           = 0.02,
		cruiseAlt           = 450,

		customParams        = {
			modelradius      = [[10]],
			requireammo      = [[1]],
			reammoseconds    = [[60]],
			refuelturnradius = [[150]],
			reallyabomber    = [[1]],
			fighter_pullup_dist = 1500, -- pullup at the end of attack dive to avoid hitting terrain
		},

		explodeAs           = [[GUNSHIPEX]],
		floater             = true,
		footprintX          = 3,
		footprintZ          = 3,
		iconType            = [[bombernuke]],
		idleAutoHeal        = 5,
		idleTime            = 1800,
		maneuverleashlength = [[1280]],
		maxAcc              = 0.75,
		maxDamage           = 16000,
		maxFuel             = 1000000,
		maxRudder           = 0.0045,
		maxVelocity         = 6,
		minCloakDistance    = 75,
		mygravity           = 1,
		noAutoFire          = false,
		noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE GUNSHIP SUB]],
		objectName          = [[ARMCYBR]],
		refuelTime          = 20,
		script              = [[bomberheavy.lua]],
		selfDestructAs      = [[GUNSHIPEX]],
		sightDistance       = 780,
		turnRadius          = 20,
		workerTime          = 0,

		weapons             = {

			{
				def                = [[ARM_PIDR]],
				badTargetCategory  = [[GUNSHIP FIXEDWING]],
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP FIXEDWING]],
			},

		},


		weaponDefs          = {

			ARM_PIDR = {
				name                    = [[Mininuke]],
				areaOfEffect            = 768,
				avoidFeature            = false,
				avoidFriendly           = false,
				burnblow                = true,
				cegTag                  = [[raventrail]],
				collideFriendly         = false,

				craterBoost             = 1,
				craterMult              = 2,

				customParams            = {
					burst = Shared.BURST_UNRELIABLE,
					cruisealt = 250,
					airlaunched = 1,
					cruisedist = [[200]],
					reaim_time = 15, -- Fast update not required (maybe dangerous)
					light_color = [[1.6 0.85 0.38]],
					light_radius = 750,
				},

				damage                  = {
					default = 12000.1,
				},

				edgeEffectiveness       = 0.5,
				explosionGenerator      = [[custom:nukebigland]],
				fireStarter             = 100,
				flightTime              = 3,
				impulseBoost            = 0,
				impulseFactor           = -0.8,
				interceptedByShieldType = 2,
				model                   = [[wep_m_deathblow.s3o]],
				range                   = 1450,
				reloadtime              = 1,
				smokeTrail              = false,
				soundHit                = [[weapon/missile/mininuke_hit]],
				soundStart              = [[weapon/missile/mininuke_launch]],
				startVelocity           = 100,
				tolerance               = 16000,
				tracks                  = true,
				turnRate                = 30000,
				weaponAcceleration      = 200,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 800,
			},

		},


		featureDefs         = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[licho_d.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris3x3b.s3o]],
			},

		},
	} 
}
