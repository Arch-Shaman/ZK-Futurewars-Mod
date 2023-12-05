return {
	chickenr = {
		name                = "Lobber",
		description         = "Artillery",
		acceleration        = 1.3,
		activateWhenBuilt   = true,
		brakeRate           = 1.5,
		builder             = false,
		buildPic            = "chickenr.png",
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "LAND",

		customParams        = {
			chicken = "uwu",
			outline_x = 85,
			outline_y = 85,
			outline_yoff = 20,
			model_rescale = 1.2,
		},

		explodeAs           = "NOWEAPON",
		footprintX          = 2,
		footprintZ          = 2,
		health              = 785,
		highTrajectory      = 1,
		iconType            = "chickenr",
		idleAutoHeal        = 20,
		idleTime            = 300,
		leaveTracks         = true,
		maxSlope            = 84,
		maxWaterDepth       = 5000,
		metalCost           = 0,
		energyCost          = 0,
		buildTime           = 625,
		movementClass       = "ATKBOT3",
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM FIXEDWING SATELLITE GUNSHIP SUB MOBILE STUPIDTARGET MINE",
		objectName          = "chickenr.s3o",
		reclaimable         = false,
		selfDestructAs      = "NOWEAPON",

		sfxtypes            = {

			explosiongenerators = {
				"custom:blood_spray",
				"custom:blood_explode",
				"custom:dirt",
			},

		},
		sightDistance       = 1000,
		sonarDistance       = 1000,
		script              = "chickenr.lua",
		speed               = 112,
		trackOffset         = 6,
		trackStrength       = 8,
		trackStretch        = 1,
		trackType           = "ChickenTrack",
		trackWidth          = 30,
		turnRate            = 1289,
		upright             = false,
		waterline           = 24,
		workerTime          = 0,

		weapons             = {
			{
				def                = "WEAPON",
				badTargetCategory  = "SWIM SHIP HOVER MOBILE",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
			},
		},


		weaponDefs          = {
			WEAPON = {
				name                    = "Blob",
				areaOfEffect            = 96,
				craterBoost             = 0,
				craterMult              = 0,
							
				customParams            = {
					light_radius = 0,
				},
							
				damage                  = {
					default = 850,
				},

				explosionGenerator      = "custom:goo_v2_green",
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				mygravity               = 0.3,
				noSelfDamage            = true,
				range                   = 1150,
				reloadtime              = 5,
				rgbColor                = "0.2 0.6 0.0",
				size                    = 8,
				sizeDecay               = 0,
				soundHit                = "chickens/acid_hit",
				soundStart              = "chickens/acid_fire",
				sprayAngle              = 256,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 900,
				waterWeapon             = true,
			},
		},
	}
}
