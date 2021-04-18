return { 
	gunshipheavyskirm = {
		unitname            = [[gunshipheavyskirm]],
		name                = [[Aurora Boralis]],
		description         = [[Fire Support Gunship]],
		acceleration        = 0.2,
		brakeRate           = 0.16,
		buildCostMetal      = 1720,
		builder             = false,
		buildPic            = [[gunshipheavyskirm.png]],
		canFly              = true,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		canSubmerge         = false,
		category            = [[GUNSHIP]],
		collide             = true,
		collisionVolumeOffsets = [[0 0 -5]],
		collisionVolumeScales  = [[40 20 60]],
		collisionVolumeType    = [[box]],
		corpse              = [[DEAD]],
		cruiseAlt           = 330,

		customParams        = {
			airstrafecontrol = [[0]],
			modelradius      = [[10]],
			aim_lookahead    = 200,
		},

		explodeAs           = [[GUNSHIPEX]],
		floater             = true,
		footprintX          = 3,
		footprintZ          = 3,
		hoverAttack         = true,
		iconType            = [[heavygunshipskirm]],
		idleAutoHeal        = 5,
		idleTime            = 1800,
		maneuverleashlength = [[1280]],
		maxDamage           = 5280,
		maxVelocity         = 3.3,
		minCloakDistance    = 75,
		noAutoFire          = false,
		noChaseCategory     = [[TERRAFORM SATELLITE SUB]],
		objectName          = [[stingray.s3o]],
		script              = [[gunshipheavyskirm.lua]],
		selfDestructAs      = [[GUNSHIPEX]],

		sfxtypes            = {

		explosiongenerators = {
			[[custom:flashmuzzle1]],
			[[custom:emg_shells_m]], --not used
			[[custom:SLASHMUZZLE]],
		},

		},
		sightDistance       = 600,
		turnRate            = 600,
		workerTime          = 0,

		weapons             = {

			{
				def                = [[GUASS_REPEATER]],
				mainDir            = [[0 0 1]],
				maxAngleDif        = 70,
				onlyTargetCategory = [[SWIM LAND SHIP SINK TURRET FLOAT GUNSHIP FIXEDWING HOVER]],
			},

			{
				def                = [[TORPEDO_BATTERY]],
				onlyTargetCategory = [[SWIM LAND SHIP SINK TURRET FLOAT GUNSHIP FIXEDWING HOVER]],
			},

		},


		weaponDefs          = {

			GUASS_REPEATER = {
				name                    = [[Guass Autocannon]],
				alphaDecay              = 0.12,
				areaOfEffect            = 96,
				avoidfeature            = false,
				bouncerebound           = 0.15,
				bounceslip              = 1,
				cegTag                  = [[gauss_tag_l]],
				collideFriendly         = false,
				craterBoost             = 0.3,
				craterMult              = 0.15,

				customparams = {
					combatrange = 980,
					single_hit_multi = true,
					--light_camera_height = 2000,
					--light_color = [[0.9 0.84 0.45]],
					--light_ground_height = 120,
				},

				damage                  = {
					default = 40.6, --Statwise looks OP, but you have to consider that A LOT of the guass shots miss. ends up being roughly just as good as the missiles
					--also, the 609 dps was not intended, but nice nonetheless
				},

				explosionGenerator      = [[custom:gauss_hit_m]],
				groundbounce            = 1,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				noExplode               = true,
				noSelfDamage            = true,
				numbounce               = 10,
				range                   = 930,
				reloadtime              = 1/15,
				rgbColor                = [[0.5 1 1]],
				separation              = 0.5,
				size                    = 0.8,
				sizeDecay               = -0.1,
				soundHit                = [[weapon/gauss_hit]],
				soundHitVolume          = 3,
				soundStart              = [[weapon/gauss_fire]],
				soundStartVolume        = 2.5,
				sprayAngle              = 2000,
				stages                  = 32,
				turret                  = true,
				waterbounce             = 1,
				waterweapon				= true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 1600,
			},
			TORPEDO_BATTERY = {
				name                    = [[Kinetic Missile Battery]],
				areaOfEffect            = 24,
				cegTag                  = [[missiletrailgreen]],
				burst                   = 8,
				burstrate               = 0.1,
				collideFriendly         = false,
				craterBoost             = 1,
				craterMult              = 2,
			
				customParams        = {
					burst = Shared.BURST_RELIABLE,
					reaim_time = 15, -- Some script bug. It does not need fast aim updates anyway.
					light_camera_height = 2500,
					light_color = [[1 0.8 0.2]],
				},
			
				damage         = {
					default = 80.1,
				},
			
				--texture1=[[null]], --flare, reference: http://springrts.com/wiki/Weapon_Variables#Texture_Tags
				--texture2 = [[lightsmoketrail]],
				--texture3=[[null]], --flame
			
				edgeEffectiveness       = 0.5,
				explosionGenerator      = [[custom:DOT_Merl_Explo]],
				fireStarter             = 100,
				fixedlauncher           = true,
				flightTime              = 3,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				metalpershot            = 0,
				model                   = [[wep_merl.s3o]],
				noSelfDamage            = true,
				projectiles             = 2,
				range                   = 930,
				reloadtime              = 6,
				smokeTrail              = false,
				soundHit                = [[weapon/missile/vlaunch_hit]],
				soundStart              = [[weapon/missile/missile_launch]],
				soundStartVolume        = 4.5,
				startVelocity           = 450,
				tolerance               = 4000,
				turnRate                = 33000,
				weaponAcceleration      = 189,
				weaponTimer             = 0.15,
				weaponType              = [[StarburstLauncher]],
				weaponVelocity          = 700,
			},
		},
		featureDefs         = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[brawler_d.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2c.s3o]],
			},
		},
	} 
}
