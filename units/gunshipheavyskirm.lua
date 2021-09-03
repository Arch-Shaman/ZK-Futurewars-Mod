return { 
	gunshipheavyskirm = {
		unitname            = [[gunshipheavyskirm]],
		name                = [[Aurora]],
		description         = [[Fire Support Gunship]],
		acceleration        = 0.2,
		brakeRate           = 0.16,
		buildCostMetal      = 1000,
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
		maxDamage           = 3500,
		maxVelocity         = 3.0,
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
		sightDistance       = 800,
		sonarDistance		= 800,
		turnRate            = 600,
		workerTime          = 0,

		weapons             = {

			{
				def                = [[emg]],
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

			emg = {
				name                    = [[Gauss Autocannon]],
				alphaDecay              = 0.12,
				areaOfEffect            = 96,
				avoidfeature            = false,
				cegTag                  = [[gauss_tag_l]],
				collideFriendly         = false,
				craterBoost             = 0.3,
				craterMult              = 0.15,
				burst					= 2,
				burstrate				= 2/30,

				customparams = {
					combatrange = 850,
					single_hit_multi = true,
					--light_camera_height = 2000,
					--light_color = [[0.9 0.84 0.45]],
					--light_ground_height = 120,
				},

				damage                  = {
					default = 22.1, --Statwise looks OP, but you have to consider that A LOT of the guass shots miss. ends up being roughly just as good as the missiles
				},

				explosionGenerator      = [[custom:gauss_hit_m]],
				heightBoostFactor       = 0,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 850,
				reloadtime              = 6/30,
				rgbColor                = [[0.5 1 1]],
				separation              = 0.5,
				size                    = 0.8,
				sizeDecay               = -0.1,
				soundHit                = [[weapon/cannon/heavy_gauss_hit]],
				soundHitVolume          = 6,
				soundStart              = [[weapon/cannon/gauss_rapid]],
				soundStartVolume        = 2.5,
				sprayAngle              = 1000,
				stages                  = 32,
				turret                  = true,
				waterweapon				= true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 900,
			},
			TORPEDO_BATTERY = {
				name                    = [[Kinetic Missile Battery]],
				areaOfEffect            = 24,
				cegTag                  = [[missiletrailgreen]],
				burst                   = 4,
				burstrate               = 0.1,
				collideFriendly         = false,
				craterBoost             = 1,
				craterMult              = 2,
			
				customParams        = {
					burst = Shared.BURST_RELIABLE,
					reaim_time = 15,
					light_camera_height = 2500,
					light_color = [[1 0.8 0.2]],
					reveal_unit = 7,
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
				range                   = 850,
				reloadtime              = 7,
				smokeTrail              = false,
				soundHit                = [[weapon/missile/vlaunch_hit]],
				soundStart              = [[weapon/missile/aurora_missile_fire]],
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
