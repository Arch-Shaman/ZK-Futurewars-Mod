return { 
	gunshipskirm = {
		unitname               = [[gunshipskirm]],
		name                   = [[Longbow]],
		description            = [[Fire Support Gunship]],
		acceleration           = 0.152,
		brakeRate              = 0.1216,
		buildCostMetal         = 500,
		builder                = false,
		buildPic               = [[gunshipskirm.png]],
		canFly                 = true,
		canMove                = true,
		canSubmerge            = false,
		category               = [[GUNSHIP]],
		collide                = true,
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[42 16 42]],
		collisionVolumeType    = [[cylY]],
		corpse                 = [[DEAD]],
		cruiseAlt              = 300,

		customParams           = {
			airstrafecontrol = [[1]],
			modelradius    = [[16]],
		},

		explodeAs              = [[GUNSHIPEX]],
		floater                = true,
		footprintX             = 3,
		footprintZ             = 3,
		hoverAttack            = true,
		iconType               = [[gunshipskirm]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		maxDamage              = 3000,
		maxVelocity            = 2.9,
		minCloakDistance       = 75,
		noChaseCategory        = [[TERRAFORM SUB]],
		objectName             = [[rapier.s3o]],
		script                 = [[gunshipskirm.lua]],
		selfDestructAs         = [[GUNSHIPEX]],

		sfxtypes               = {

			explosiongenerators = {
				[[custom:rapiermuzzle]],
			},

		},

		sightDistance          = 550,
		turnRate               = 594,
		weapons                = {

			{
				def                = [[VTOL_ROCKET]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

		},

		weaponDefs             = {

			VTOL_ROCKET = {
				name                    = [[ATG Rocket Pods]],
				areaOfEffect            = 96,
				avoidFeature            = false,
				burnblow                = true,
				cegTag                  = [[rocket_trail_bar]],
				collideFriendly         = false,
				craterBoost             = 4,
				craterMult              = 2.25,
				burst					= 6,
				burstrate				= 0.1,
				customparams = {
					burst = Shared.BURST_RELIABLE,

					timeslow_damagefactor = 3,
					cruise_permoffset = 1,
					cruiserandomradius = 200,
					cruisealt = 300,
					airlaunched = 1,
					cruisedist = 200,
					light_camera_height = 2500,
					light_color = [[1.3 0.5 1.6]],
					light_radius = 220,
				},
				damage                  = {
					default = 200.1,
				},
				explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],
				fireStarter             = 70,
				flightTime              = 2.2,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = [[wep_m_maverick.s3o]],
				range                   = 900,
				reloadtime              = 8,
				smokeTrail              = true,
				soundHit                = [[explosion/ex_med11]],
				soundStart              = [[weapon/missile/rocket_fire]],
				soundTrigger            = true,
				startVelocity           = 250,
				--texture2                = [[purpletrail]],
				tolerance               = 32767,
				tracks                  = true,
				turnRate                = 60000,
				turret                  = false,
				weaponAcceleration      = 200,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 1000,
			},

		},

		featureDefs            = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[rapier_d.s3o]],
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[debris2x2c.s3o]],
			},
		
		},
	
	} 
}
