return { 
	cloakriot = {
		unitname               = [[cloakriot]],
		name                   = [[Assailant]],
		description            = [[Stealthy Machine Gun Bot]],
		acceleration           = 0.75,
		brakeRate              = 1.2,
		buildCostMetal         = 225,
		buildPic               = [[cloakriot.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		canCloak			   = true,
		category               = [[LAND]],
		collisionVolumeOffsets = [[0 1 -1]],
		collisionVolumeScales  = [[26 36 26]],
		collisionVolumeType    = [[cylY]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[45 45 45]],
		selectionVolumeType    = [[ellipsoid]],
		corpse                 = [[DEAD]],
		stealth = true,
		activateWhenBuilt = true,
		initCloaked = true,
		cloakCostMoving = 3,
		cloakCost    = 0.3,
		customParams           = {
			modelradius       = [[7]],
			cus_noflashlight  = 1,
			selection_scale   = 0.85,
			aim_lookahead     = 120,
			cloakregen		  = 15,
			recloaktime 	  = 300,
			cloaker_bestowed_radius = 92,
			outline_x = 80,
			outline_y = 80,
			outline_yoff = 15.5,
		},
		explodeAs              = [[SMALL_UNITEX]],
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = [[kbotriot]],
		leaveTracks            = true,
		maxDamage              = 950,
		maxSlope               = 36,
		maxVelocity            = 2.3,
		maxWaterDepth          = 22,
		minCloakDistance       = 230,
		movementClass          = [[KBOT3]],
		noChaseCategory        = [[TERRAFORM FIXEDWING SUB]],
		objectName             = [[Spherewarrior.s3o]],
		script                 = [[cloakriot.lua]],
		selfDestructAs         = [[SMALL_UNITEX]],

		sfxtypes               = {

			explosiongenerators = {
				[[custom:RAIDMUZZLE]],
				[[custom:emg_shells_l]],
			},

		},
		sightDistance          = 350,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 0.8,
		trackType              = [[ComTrack]],
		trackWidth             = 20,
		turnRate               = 2160,
		upright                = true,
		weapons                = {

			{
				def                = [[WARRIOR_WEAPON]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

		},

		weaponDefs             = {

			WARRIOR_WEAPON = {
				name                    = [[Burst fire MG]],
				accuracy                = 350,
				alphaDecay              = 0.7,
				areaOfEffect            = 96,
				burnblow                = true,
				craterBoost             = 0.15,
				craterMult              = 0.3,
				customParams        = {
					light_camera_height = 1600,
					light_color = [[0.8 0.76 0.38]],
					light_radius = 150,
					sweepfire = 1,
					sweepfire_maxangle = 15,
					sweepfire_step = 5,
					sweepfire_maxrangemult = 0.98,
				},

				damage                  = {
					default = 60.1,
				},

				edgeEffectiveness       = 0.5,
				explosionGenerator      = [[custom:EMG_HIT_HE]],
				firestarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 300,
				reloadtime              = 6/30,
				rgbColor                = [[1 0.95 0.4]],
				separation              = 1.5,
				soundHit                = [[weapon/cannon/emg_hit]],
				soundStart              = [[weapon/sd_emgv7]],
				stages                  = 10,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 550,
			},

		},

		featureDefs            = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[spherewarrior_dead.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris3x3a.s3o]],
			},

		},

	} 
}
