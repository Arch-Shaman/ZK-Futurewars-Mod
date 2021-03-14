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
		idleAutoHeal           = 15,
		idleTime               = 1800,
		maxDamage              = 3500,
		maxVelocity            = 4.1,
		noChaseCategory        = [[TERRAFORM SUB]],
		objectName             = [[rapier.s3o]],
		script                 = [[gunshipskirm.lua]],
		selfDestructAs         = [[GUNSHIPEX]],

		sfxtypes               = {

			explosiongenerators = {
				[[custom:PULVMUZZLE]],
			},

		},

		sightDistance          = 550,
		turnRate               = 594,
		weapons                = {

			{
				def                = [[VTOL_ROCKET]],
				onlyTargetCategory = [[LAND SINK TURRET SHIP SWIM FLOAT HOVER]],
			},

		},

		weaponDefs             = {

			VTOL_ROCKET = {
				name                    = [[ATG Rocket Pods]],
				areaOfEffect            = 96,
				avoidFeature            = false,
				cegTag                  = [[rocket_trail_bar]],
				collideFriendly         = false,
				craterBoost             = 4,
				craterMult              = 2.25,
				burst					= 8,
				burstrate				= 0.1,
				customparams = {
					burst = Shared.BURST_UNRELIABLE,
					--cruise_permoffset = 1,
					cruiserandomradius = 130,
					cruisealt = 300,
					airlaunched = 1,
					cruisedist = 270,
					cruisetracking = 1,
					cruise_nolock = 1,
					light_camera_height = 2500,
        			light_color = [[0.90 0.65 0.30]],
        			light_radius = 250,
				},
				damage                  = {
					default = 220.1,
				},
				explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],
				fireStarter             = 70,
				flightTime              = 6,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = [[wep_m_maverick.s3o]],
				range                   = 750,
				reloadtime              = 12,
				smokeTrail              = true,
				soundHit                = [[weapon/missile/rapid_rocket_hit]],
				soundStart              = [[weapon/missile/rocket_fire]],
				startVelocity           = 100,
				texture2                = [[darksmoketrail]],
				tolerance               = 32767,
				tracks                  = true,
				turnRate                = 60000,
				turret                  = false,
				weaponAcceleration      = 200,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 700,
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
