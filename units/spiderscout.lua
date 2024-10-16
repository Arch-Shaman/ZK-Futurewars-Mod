return { 
	spiderscout = {
		unitname            = "spiderscout",
		name                = "Wolf",
		description         = "Light Scout/Raider Spider",
		acceleration        = 2.1,
		brakeRate           = 12.6,
		buildCostMetal      = 70,
		buildPic            = "spiderscout.png",
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "LAND TOOFAST",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "20 20 20",
		collisionVolumeType    = "ellipsoid",
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "42 42 42",
		selectionVolumeType    = "ellipsoid",
		corpse              = "DEAD",
		customParams        = {
			modelradius        = "10",
			selection_scale    = 1, -- Maybe change later
			aim_lookahead      = 80,
		},
		explodeAs           = "TINY_BUILDINGEX",
		footprintX          = 2,
		footprintZ          = 2,
		iconType            = "spiderscout",
		idleAutoHeal        = 5,
		idleTime            = 1800,
		leaveTracks         = true,
		health              = 240,
		maxSlope            = 72,
		speed               = 5.1,
		maxWaterDepth       = 15,
		minCloakDistance    = 75,
		movementClass       = "TKBOT2",
		moveState           = 0,
		noChaseCategory     = "TERRAFORM FIXEDWING SATELLITE SUB",
		objectName          = "arm_flea.s3o",
		pushResistant       = 0,
		script              = "spiderscout.lua",
		selfDestructAs      = "TINY_BUILDINGEX",
		sfxtypes            = {
			explosiongenerators = {
				"custom:digdig",
			},
		},
		sightDistance       = 620,
		trackOffset         = 0,
		trackStrength       = 8,
		trackStretch        = 1,
		trackType           = "ChickenTrackPointy",
		trackWidth          = 18,
		turnRate            = 2100,
		weapons             = {
			{
				def                = "LASER",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs          = {
			LASER = {
				name                    = "Tracer Beam",
				areaOfEffect            = 8,
				coreThickness           = 0.4,
				beamTime                = 2/30,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					light_camera_height = 1200,
					light_radius = 60,
					light_color = "1 0.2 1",
					timeslow_damagefactor = 0.5,
					sweepfire = 1,
					sweepfire_maxangle = 15,
					sweepfire_step = 1.5,
					sweepfire_fastupdate = 1,
					sensortag = 25,
				},
				damage                  = {
					default = 10.5,
				},
				duration                = 3/30,
				explosionGenerator      = "custom:beamweapon_hit_purple_tiny",
				fireStarter             = 100,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				paralyzeTime			= 1,
				range                   = 200,
				reloadtime              = 0.1,
				texture1                = "ecmnoise",
				rgbColor                = "1 0.2 1",
				rgbColor2				= "0.5 0.1 0.5",
				soundStart              = "weapon/laser/small_laser_fire",
				soundstartvolume	    = 0.1,
				thickness               = 2.25,
				tolerance               = 10000,
				turret                  = true,
				waterWeapon             = true,
				weaponType              = "BeamLaser",
				weaponVelocity          = 880,
			},
			DGUN = {
				name                    = "Overload",
				areaOfEffect            = 600,
				craterBoost             = 0,
				craterMult              = 0,
				commandFire				= true,
				customParams            = {
					timeslow_damage = 850,
					timeslow_onlyslow = 1,
					timeslow_overslow_frames = 2*30,
					nofriendlyfire = 1,
					sensortag = 40,
					hideweapon = 1,
				},
				damage                  = {
					default = 12.5,
				},
				explosionGenerator      = "custom:scanner_ping_600",
				explosionSpeed          = 600,
				fireStarter             = 50,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 1,
				reloadtime              = 30,
				size					= 0,
				soundStart              = "weapon/cannon/emp_hit",
				soundTrigger            = true,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = "Cannon",
			},
		},
		featureDefs                   = {
			DEAD = {
				blocking         = false,
				featureDead      = "HEAP",
				footprintX       = 1,
				footprintZ       = 1,
				object           = "flea_d.dae",
			},
			HEAP = {
				blocking         = false,
				footprintX       = 1,
				footprintZ       = 1,
				object           = "debris1x1b.s3o",
			},
		},
	} 
}
