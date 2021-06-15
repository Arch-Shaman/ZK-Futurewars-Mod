return { 
	spiderantiheavy = {
		unitname              = [[spiderantiheavy]],
		name                  = [[Widow]],
		description           = [[Cloaked Scout/Anti-Heavy]],
		acceleration          = 0.9,
		activateWhenBuilt     = true,
		brakeRate             = 5.4,
		buildCostMetal        = 300,
		buildPic              = [[spiderantiheavy.png]],
		canGuard              = true,
		canMove               = true,
		canPatrol             = true,
		category              = [[LAND]],
		cloakCost              = 5,
		cloakCostMoving        = 15,
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[30 30 30]],
		selectionVolumeType    = [[ellipsoid]],
		corpse                = [[DEAD]],

		customParams          = {
			bait_level_default = 2,
			dontfireatradarcommand = '1',
			cus_noflashlight = 1,
			cloakregen		   = 10,
			recloaktime 	   = 330,
		},

		explodeAs             = [[BIG_UNITEX]],
		fireState             = 0,
		footprintX            = 2,
		footprintZ            = 2,
		iconType              = [[spiderspecialscout]],
		idleAutoHeal          = 5,
		idleTime              = 1800,
		leaveTracks           = true,
		initCloaked           = true,
		maxDamage             = 270,
		maxSlope              = 36,
		maxVelocity           = 2.9,
		maxWaterDepth         = 22,
		minCloakDistance      = 60,
		movementClass         = [[TKBOT3]],
		moveState             = 0,
		noChaseCategory       = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET]],
		objectName            = [[infiltrator.s3o]],
		script                = [[spiderantiheavy.lua]],
		selfDestructAs        = [[BIG_UNITEX]],
		sightDistance         = 650,
		trackOffset           = 0,
		trackStrength         = 8,
		trackStretch          = 1,
		trackType             = [[ChickenTrackPointyShort]],
		trackWidth            = 45,
		turnRate              = 2160,

		weapons               = {

			{
				def                = [[spy]],
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER FIXEDWING GUNSHIP]],
			},

		},

		weaponDefs            = {
			FINAL = {
				name                    = [[Light EMP Shockcannon]],
				accuracy                = 80,
				movingAccuracy			= 400,
				areaOfEffect            = 120,
				cegtag					= [[artillery_spark_small]],
				craterBoost             = 0,
				craterMult              = 0,
				--highTrajectory			= 1,
				burst					= 1,

				customParams        = {
					light_camera_height = 1400,
					light_color = [[0.3 0.3 0.7]],
					light_radius = 100,
					extra_damage = 200,
				},

				damage                  = {
					default = 100,
				},

				edgeEffectiveness       = 0.05,
				paralyzeTime            = 1,
				explosionGenerator      = [[custom:hammer_artillery_hit]],
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.07,
				noSelfDamage            = true,
				range                   = 800,
				reloadtime              = 6,
				size					= 0.01,
				soundHit                = [[weapon/cannon/emp_arty_hit]],
				soundStart              = [[weapon/cannon/emparty_fire]],
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 235,
			},
			FRAGMENT_DUMMY = {
				name                    = [[Fragment]],
				accuracy                = 400,
				areaOfEffect            = 162,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				--cegTag                  = [[flamer]],
				customParams              = {

					numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "spiderantiheavy_final",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "derpderpderpderpderpderpderpderpderpderp", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 1,
					timeoutspawn = 0,
					noairburst = "Burning time", -- if true, this projectile will skip all airburst checks
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeddeploy = 3,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
					shield_damage = 250,
				},
				damage                  = {
					default = 0,
				},

				--explosionGenerator      = [[custom:napalm_firewalker_small]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.33,
				noExplode               = true,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[0.3 0.3 0.7]],
				size 					= 6,
				soundHit                = [[nosound]],
				soundStart              = [[weapon/cannon/frag_impact]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},
			spy = {
				name                    = [[Electro-Stunner]],
				areaOfEffect            = 8,
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,

				customParams            = {
					burst = Shared.BURST_RELIABLE,
					light_color = [[1.85 1.85 0.45]],
					light_radius = 300,
					numprojectiles1 = 10, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "spiderantiheavy_fragment_dummy",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-2.5,3,-2.5,2.5,6,2.5",
					noairburst = "March of progress", -- if true, this projectile will skip all airburst checks
					onexplode = "The unity prevails", -- if true, this projectile will cluster when it explodes
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					stats_damage = 3000,
					shield_damage = (250*10) + 14000,
				},

				damage                  = {
					default        = 14000.1,
				},

				duration                = 8,
				explosionGenerator      = [[custom:YELLOW_LIGHTNINGPLOSION]],
				fireStarter             = 0,
				heightMod               = 1,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 12,
				interceptedByShieldType = 1,
				paralyzer               = true,
				paralyzeTime            = 30,
				range                   = 220,
				reloadtime              = 35,
				rgbColor                = [[1 1 0.25]],
				soundStart              = [[weapon/LightningBolt]],
				soundTrigger            = true,
				targetborder            = 0.9,
				texture1                = [[lightning]],
				thickness               = 10,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = [[LightningCannon]],
				weaponVelocity          = 450,
			},
		},

		featureDefs           = {

			DEAD = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[Infiltrator_wreck.s3o]],
			},

			HEAP = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2a.s3o]],
			},
		},
	} 
}
