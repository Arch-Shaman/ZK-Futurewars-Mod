return { 
	bomberheavy = {
		unitname            = [[bomberheavy]],
		name                = [[Hella]],
		description         = [[Strategic Bomber]],
		--autoheal          = 25,
		brakerate           = 0.4,
		buildCostMetal      = 5000,
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
			refuelturnradius = [[550]],
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
		maxDamage           = 15000,
		maxFuel             = 1000000,
		maxRudder           = 0.02,
		maxVelocity         = 5.5,
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
				name                    = [[BN-22 Atomic Bomb]],
				areaOfEffect            = 800,
				avoidFeature            = false,
				avoidFriendly           = false,
				burnblow                = true,
				cegTag                  = [[NUCKLEARMINI]],
				collideFriendly         = false,
				craterBoost             = 1,
				craterMult              = 4,

				customParams            = {
					burst = Shared.BURST_UNRELIABLE,
					reaim_time = 15, -- Fast update not required (maybe dangerous)
					light_color = [[1.6 0.85 0.38]],
					light_radius = 750,
				},

				damage                  = {
					default = 10000.1,
				},

				edgeEffectiveness       = 0.25,
				explosionGenerator      = [[custom:nukebigland]],
				fireStarter             = 100,
				fireTolerance		    = 65536/2,
				impulseBoost            = 0,
				impulseFactor           = 2.3,
				interceptedByShieldType = 2,
				model                   = [[zeppelin_bomb.dae]],
				mygravity				= 0.5,
				range                   = 150,
				reloadtime              = 1,
				smokeTrail              = false,
				soundHit                = [[weapon/missile/mininuke_hit]],
				soundStart              = [[weapon/missile/liche_fire]],
				startVelocity           = 100,
				tolerance               = 65536/2, -- 180 degrees
				weaponAcceleration      = 200,
				weaponType              = [[AircraftBomb]],
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
