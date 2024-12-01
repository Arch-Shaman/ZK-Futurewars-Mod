return {
	chickenwurm = {
		name                = "Wurm",
		description         = "Burrowing Flamer (Assault/Riot)",
		acceleration        = 1.08,
		activateWhenBuilt   = true,
		brakeRate           = 1.23,
		builder             = false,
		buildPic            = "chickenwurm.png",
		buildTime           = 1270,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "LAND",

		customParams        = {
			chicken = "uwu",
			fireproof         = 1,
			outline_x = 160,
			outline_y = 160,
			outline_yoff = 8,
			model_rescale = 1.3,
			chicken_spawncost = 1270,
		},

		explodeAs           = "CHICKENWURM_DEATH",
		footprintX          = 4,
		footprintZ          = 4,
		health              = 16800,
		iconType            = "spidergeneric",
		idleAutoHeal        = 20,
		idleTime            = 300,
		leaveTracks         = true,
		maxSlope            = 90,
		maxWaterDepth       = 5000,
		movementClass       = "ATKBOT3",
		noAutoFire          = false,
		noChaseCategory     = "SHIP FLOAT SWIM TERRAFORM FIXEDWING GUNSHIP SATELLITE STUPIDTARGET MINE",
		objectName          = "chickenwurm.s3o",
		reclaimable         = false,
		script              = "chickenwurm.lua",
		selfDestructAs      = "CHICKENWURM_DEATH",

		sfxtypes            = {
			explosiongenerators = {
				"custom:blood_spray",
				"custom:blood_explode",
				"custom:dirt",
			},
		},
		sightDistance       = 384,
		sonarDistance       = 384,
		speed               = 132,
		stealth             = true,
		turnRate            = 967,
		upright             = false,
		workerTime          = 0,

		weapons             = {
			{
				def                = "NAPALM_SPRAYER",
				badTargetCategory  = "GUNSHIP",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT GUNSHIP SHIP HOVER",
			},
		},


		weaponDefs          = {	
			NAPALM_SPRAYER = {
				name                    = "Thermite Sprayer",
				areaOfEffect            = 128,
				avoidFeature            = false,
				craterBoost             = 0,
				craterMult              = 0,
				cegTag                  = "flamer",
				customParams              = {
					setunitsonfire = "1",
					burnchance = "1", -- Per-impact
					burntime = "200",
					light_color = "0.6 0.39 0.18",
					light_radius = 100,
					combatrange = 400,
					armorpiercing = 0.15,
				},
				
				damage                  = {
					default = 42.1,
				},
				edgeEffectiveness       = 0.8,
				explosionGenerator      = "custom:napalm_phoenix",
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				myGravity               = 0.49,
				--projectiles             = 10,
				range                   = 430,
				reloadtime              = 2/30,
				rgbColor                = "1 0.5 0.2",
				size                    = 5,
				soundHit                = "flamethrowerhit",
				soundStart              = "flamethrowerfire",
				soundStartVolume        = 3.2,
				sprayangle              = 1600,
				turret                  = true,
				waterweapon             = true,
				weaponType              = "Cannon",
				weaponVelocity          = 500,
			},
			DEATH = {
				name                    = "Napalm Blast",
				areaofeffect            = 256,
				craterboost             = 1,
				cratermult              = 3.5,

				customparams            = {
					setunitsonfire = "1",
					burnchance     = "1",
					burntime       = 60,

					area_damage = 1,
					area_damage_radius = 128,
					area_damage_dps = 20,
					area_damage_duration = 13.3,
				},

				damage                  = {
					default = 50,
				},

				edgeeffectiveness       = 0.5,
				explosionGenerator      = "custom:napalm_pyro",
				impulseboost            = 0,
				impulsefactor           = 0,
				soundhit                = "explosion/ex_med3",
			},
		},
	}
}
