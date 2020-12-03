return { 
	tankarty = {
		unitname            = [[tankarty]],
		name                = [[Emissary]],
		description         = [[Light Cluster Artillery]],
		acceleration        = 0.141,
		brakeRate           = 1.36,
		buildCostMetal      = 700,
		builder             = false,
		buildPic            = [[tankarty.png]],
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = [[LAND]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[42 42 42]],
		selectionVolumeType    = [[ellipsoid]],
		corpse              = [[DEAD]],

		customParams        = {},

		explodeAs           = [[BIG_UNITEX]],
		footprintX          = 3,
		footprintZ          = 3,
		iconType            = [[tankarty]],
		idleAutoHeal        = 5,
		idleTime            = 1800,
		leaveTracks         = true,
		maxDamage           = 840,
		maxSlope            = 18,
		maxVelocity         = 2,
		maxWaterDepth       = 22,
		minCloakDistance    = 75,
		movementClass       = [[TANK3]],
		moveState           = 0,
		noAutoFire          = false,
		noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE GUNSHIP]],
		objectName          = [[cormart.s3o]],
		pushResistant       = 0,
		selfDestructAs      = [[BIG_UNITEX]],
		script              = [[tankarty.lua]],
		sightDistance       = 660,
		trackOffset         = 8,
		trackStrength       = 8,
		trackStretch        = 1,
		trackType           = [[StdTank]],
		trackWidth          = 34,
		turninplace         = 0,
		turnRate            = 640,
		workerTime          = 0,

		weapons             = {
			{
				def                = [[CORE_ARTILLERY]],
				mainDir            = [[0 0 1]],
				--maxAngleDif        = 180,
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER]],
			},

		},
		weaponDefs          = {
			
			SECONDARY = {
				name                    = [[Heavy Pulse MG]],
				accuracy                = 350,
				alphaDecay              = 0.7,
				areaOfEffect            = 96,
				burnblow                = true,
				burst                   = 3,
				burstrate               = 0.1,
				craterBoost             = 2,
				craterMult              = 1,

				customParams        = {
					gatherradius = [[90]],
					smoothradius = [[60]],
					smoothmult   = [[0.08]],
					light_camera_height = 1600,
					light_color = [[0.8 0.76 0.38]],
					light_radius = 40,
				},
				
				damage                  = {
					default = 100.1,
				},

				edgeEffectiveness       = 0.5,
				explosionGenerator      = [[custom:DOT_Pillager_Explo]],
				firestarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 275,
				reloadtime              = 0.5,
				rgbColor                = [[1 0.95 0.4]],
				separation              = 1.5,
				soundHit                = [[weapon/cannon/rhino3]],
				soundStart              = [[weapon/heavy_emg]],
				stages                  = 10,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 550,
				
			},
			
			CORE_ARTILLERY = {
				name                    = [[Plasma Artillery]],
				accuracy                = 180,
				areaOfEffect            = 0,
				avoidFeature            = false,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					burst = Shared.BURST_RELIABLE,
					reaim_time = 8, -- COB
					light_color = [[1.4 0.8 0.3]],
					numprojectiles = 6, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile = "tankarty_secondary",
					--spreadradius = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 220, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					useheight = 1,
					vradius = "-2,0,-2,2,1,2", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					light_camera_height = 1500,
					light_color = [[0.8 0.76 0.38]],
					light_radius = 40,
				},
				damage                  = {
					default = 600.6,
				},
				edgeEffectiveness       = 0.5,
				explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.095,
				noSelfDamage            = true,
				range                   = 1120,
				reloadtime              = 7,
				soundHit                = [[weapon/cannon/mini_cannon]],
				soundStart              = [[weapon/cannon/pillager_fire]],
				turret                  = true,
				highTrajectory		= 1,
				weaponType              = [[Cannon]],
				weaponVelocity          = 350,
			},

		},
		featureDefs         = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[cormart_dead.s3o]],
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2a.s3o]],
			},

		},

	} 
}
