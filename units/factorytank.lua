return { 
	factorytank = {
		unitname                      = [[factorytank]],
		name                          = [[Tank Foundry]],
		description                   = [[Armed Tank Production Facility]],
		acceleration                  = 0,
		brakeRate                     = 0,
		buildCostMetal                = Shared.FACTORY_COST,
		buildDistance                 = Shared.FACTORY_PLATE_RANGE,
		builder                       = true,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 11,
		buildingGroundDecalSizeY      = 11,
		buildingGroundDecalType       = [[factorytank_aoplane.dds]],

		buildoptions                  = {
			[[tankcon]],
			[[tankraid]],
			[[tankheavyraid]],
			[[tankriot]],
			[[tankassault]],
			[[tankheavyassault]],
			[[tankarty]],
			[[tankheavyarty]],
			[[tankaa]],
		},

		buildPic                      = [[factorytank.png]],
		canMove                       = true,
		canPatrol                     = true,
		category                      = [[SINK UNARMED]],
		corpse                        = [[DEAD]],
		collisionVolumeOffsets        = [[0 0 -25]],
		collisionVolumeScales         = [[110 28 44]],
		collisionVolumeType           = [[box]],
		selectionVolumeOffsets        = [[0 0 10]],
		selectionVolumeScales         = [[120 28 120]],
		selectionVolumeType           = [[box]],

		customParams                  = {
			sortName = [[6]],
			solid_factory = [[4]],
			default_spacing = 8,
			aimposoffset   = [[0 15 -35]],
			midposoffset   = [[0 15 -10]],
			modelradius    = [[100]],
			unstick_help   = 1,
			selectionscalemult = 1,
			factorytab       = 1,
			shared_energy_gen = 1,
			parent_of_plate   = [[platetank]],
			nanoregen = 13,
			nano_maxregen = 5.2,
			aim_lookahead = 80,
		},

		energyUse                     = 0,
		explodeAs                     = [[LARGE_BUILDINGEX]],
		footprintX                    = 8,
		footprintZ                    = 8,
		iconType                      = [[factank]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		levelGround                   = false,
		maxDamage                     = 7000,
		maxSlope                      = 15,
		maxVelocity                   = 0,
		maxWaterDepth                 = 0,
		moveState                     = 1,
		noAutoFire                    = false,
		objectName                    = [[factorytank.s3o]],
		script                        = [[factorytank.lua]],
		selfDestructAs                = [[LARGE_BUILDINGEX]],
		showNanoSpray                 = false,
		sightDistance                 = 660,
		turnRate                      = 0,
		useBuildingGroundDecal        = true,
		workerTime                    = Shared.FACTORY_BUILDPOWER,
		yardMap                       = "oooooooo oooooooo oooooooo oooooooo yccccccy yccccccy yccccccy yccccccy",
		
		weapons             = {
			{
				def                = [[CANNON]],
				--maxAngleDif        = 45,
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP]],
			},
		},
		weaponDefs          = {
			CANNON = {
				name                    = [[Fragmentation Shell]],
				accuracy                = 0,
				areaOfEffect            = 32,
				avoidFeature            = false,
				avoidGround             = true,
				craterBoost             = 0,
				craterMult              = 0,

				customParams            = {
					restrict_in_widgets = 1,
					light_color = [[3 2.33 1.5]],
					light_radius = 150,
					light_camera_height = 3500,
					light_color = [[0.75 0.4 0.15]],
					light_radius = 220,
					numprojectiles1 = 20, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "factorytank_fragment_dummy",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-2.5,3,-2.5,2.5,6,2.5",
					noairburst = "March of progress", -- if true, this projectile will skip all airburst checks
					onexplode = "The unity prevails", -- if true, this projectile will cluster when it explodes
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					stats_damage = (35*20) + 400,
					shield_damage = (35*20) + 400,
					stats_shield_damage = (35*20) + 400,
				},

				damage                  = {
					default = 400.2,
				},
				
				explosionGenerator      = [[custom:DOT_Pillager_Explo]],
				fireTolerance           = 1820, -- 10 degrees
				impulseBoost            = 0.5,
				impulseFactor           = 0.2,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 600,
				reloadtime              = 6,
				rgbColor                = [[0.2 0.2 0.2]],
				soundHit                = [[weapon/cannon/frag_impact]],
				soundStart              = [[explosion/ex_large5]],
				size                    = 8,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 880,
			},
			FRAGMENT_DUMMY = {
				name                    = [[Plasma Bomblet]],
				accuracy                = 400,
				areaOfEffect            = 162,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				--cegTag                  = [[flamer]],
				customParams              = {

					numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "factorytank_final",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "derpderpderpderpderpderpderpderpderpderp", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 1,
					timeoutspawn = 0,
					noairburst = "Burning time", -- if true, this projectile will skip all airburst checks
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeddeploy = 10,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
					shield_damage = 35,
				},
				damage                  = {
					default = 0,
				},

				--explosionGenerator      = [[custom:napalm_firewalker_small]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.25,
				noExplode               = true,
				projectiles             = 10,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[1 0.95 0.4]],
				size 					= 2,
				soundHit                = [[nosound]],
				soundStart              = [[weapon/cannon/frag_impact]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},
			FINAL = {
				name                    = [[Plasma Flechette]],
				--cegTag                  = [[flak_trail]],
				areaOfEffect            = 96,
				alphaDecay              = 0.7,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,

				customParams            = {
					light_camera_height = 2000,
					light_color = [[1 0.2 0.2]],
					light_radius = 128,
					reaim_time = 8, -- COB
					isaa = [[1]],
					light_radius = 0,
					isFlak = 3,
					flaktime = 15,
				},

				damage = {
					default = 35,
				},
				--interceptor = 2,
				edgeEffectiveness       = 0.8,
				--duration                = 0.02,
				explosionGenerator      = [[custom:EMG_HIT_HE]],
				fireStarter             = 50,
				heightMod               = 1,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				range                   = 300,
				reloadtime              = 0.8,
				rgbColor                = [[1 0.95 0.4]],
				soundHit                = [[weapon/cannon/emg_hit]],
				soundHitVolume	        = 0.4,
				--soundTrigger            = true,
				sprayangle              = 1500,
				size 					= 2,
				thickness               = 2,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 880,
				--coverage = 1000,
			},
		},
		featureDefs                   = {
			DEAD = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 8,
				footprintZ       = 8,
				object           = [[factorytank_dead.s3o]],
				collisionVolumeOffsets = [[0 14 -34]],
				collisionVolumeScales  = [[110 28 44]],
				collisionVolumeType    = [[box]],
			},
			HEAP = {
				blocking         = false,
				footprintX       = 6,
				footprintZ       = 6,
				object           = [[debris4x4a.s3o]],
			},
		},
	} 
}
