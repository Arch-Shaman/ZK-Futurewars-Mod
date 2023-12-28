return {
	chickenblobber = {
		name                = "Blobber",
		description         = "Heavy Artillery",
		acceleration        = 1.3,
		activateWhenBuilt   = true,
		brakeRate           = 1.5,
		builder             = false,
		buildPic            = "chickenblobber.png",
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "LAND",

		customParams        = {
			chicken = "uwu",
			model_rescale = 1.5,
		},

		explodeAs           = "NOWEAPON",
		footprintX          = 4,
		footprintZ          = 4,
		health              = 10800,
		highTrajectory      = 1,
		iconType            = "walkerlrarty",
		idleAutoHeal        = 20,
		idleTime            = 300,
		leaveTracks         = true,
		maxSlope            = 84,
		maxWaterDepth       = 5000,
		buildTime           = 3600,
		movementClass       = "ATKBOT3",
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM FIXEDWING SATELLITE GUNSHIP SUB MOBILE STUPIDTARGET MINE",
		objectName          = "chickenblobber.s3o",
		reclaimable         = false,
		selfDestructAs      = "NOWEAPON",
		

		sfxtypes            = {

			explosiongenerators = {
				"custom:blood_spray",
				"custom:blood_explode",
				"custom:dirt",
			},

		},
		sightDistance       = 1200,
		sonarDistance       = 1200,
		script              = "chickenblobber.lua",
		speed               = 122,
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
				name                    = "Scatterblob",
				areaOfEffect            = 200,
				burst                   = 11,
				burstrate               = 0.033,
				craterBoost             = 0,
				craterMult              = 0,
							
				customParams            = {
					light_radius = 0,
					armorpiercing = 0.25,
					gatherradius = "260",
					smoothradius = "200",
					detachmentradius = "200",
					smoothmult   = "0.5",
					smoothexponent = "0.75",
					movestructures = "0.25",
				},

				damage                  = {
					default = 800,
					planes  = 800,
				},

				explosionGenerator      = "custom:goo_v2_green_large",
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				mygravity               = 0.3,
				range                   = 3350,
				reloadtime              = 6,
				rgbColor                = "0.2 0.6 0.0",
				size                    = 20,
				sizeDecay               = 0,
				soundHit                = "chickens/acid_hit",
				soundStart              = "chickens/acid_fire",
				sprayAngle              = 800,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = "Cannon",
				waterWeapon             = true,
				weaponVelocity          = 900,
			},
		},
	}
}
