return { 
	cloakraid = {
		unitname               = "cloakraid",
		name                   = "Lurker",
		description            = "Stealth Raider Bot (Radar Invisible)",
		acceleration           = 1.5,
		brakeRate              = 2.4,
		buildCostMetal         = 50,
		buildPic               = "cloakraid.png",
		canGuard               = true,
		canMove                = true,
		stealth                = true,
		activateWhenBuilt      = true,
		cloakCost              = 0,
		canPatrol              = true,
		category               = "LAND TOOFAST",
		collisionVolumeOffsets = "0 -2 0",
		collisionVolumeScales  = "18 28 18",
		collisionVolumeType    = "cylY",
		corpse                 = "DEAD",
		customParams           = {
			modelradius        = "16",
			cus_noflashlight   = 1,
			aim_lookahead      = 80,
			cloakregen		   = 15,
			idle_cloak = 1,
			cloakstrikeduration = 45,
			cloakstrikespeed = 1.3,
			cloakstrikeslow = 1.0,
		},
		explodeAs              = "SMALL_UNITEX",
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = "kbotraider",
		leaveTracks            = true,
		health                 = 110,
		maxSlope               = 36,
		speed                  = 5.0,
		maxWaterDepth          = 22,
		minCloakDistance       = 75,
		movementClass          = "KBOT2",
		noAutoFire             = false,
		noChaseCategory        = "TERRAFORM FIXEDWING SUB",
		objectName             = "spherebot.dae",
		script                 = "cloakraid.lua",
		selfDestructAs         = "SMALL_UNITEX",
		sfxtypes               = {
			explosiongenerators = {
				"custom:emg_shells_l",
				"custom:RAIDMUZZLE",
			},
		},
		sightDistance          = 560,
		radarDistance		   = 700,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 0.9,
		trackType              = "ComTrack",
		trackWidth             = 14,
		turnRate               = 3000,
		upright                = true,
		weapons                = {

			{
				def                = "EMG",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},

		},
		weaponDefs             = {
			EMGSUB = {
				name                    = "Flechette",
				alphaDecay              = 0.8,
				areaOfEffect            = 24,
				colormap                = "1 0.95 0.4 1   1 0.95 0.4 1    0 0 0 0.01    1 0.7 0.2 1",
				craterBoost             = 0,
				projectiles             = 16,
				craterMult              = 0,
				cylinderTargeting 		= 1,
				customParams        = {
					light_camera_height = 1200,
					light_color = "0.8 0.76 0.38",
					light_radius = 10,
					isflak = 1,
				},
				damage                  = {
					default = 10.1,
				},
				explosionGenerator      = "custom:emg_hit_le",
				impactOnly              = false,
				edgeEffectiveness       = 0.1,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				noGap                   = true,
				noSelfDamage            = true,
				range                   = 230,
				mygravity               = 0.05,
				reloadtime              = 25/30,
				rgbColor                = "1 0.95 0.4",
				separation              = 0.02,
				size                    = 0.65,
				sizeDecay               = 0.01,
				soundhit			    = "LurkerHit",
				soundStart              = "LurkerFire",
				soundHitVolume          = 0.2,
				soundStartVolume        = 0.2,
				soundTrigger            = true,
				sprayAngle              = 1700,
				stages                  = 18,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 1100,
			},
			EMG = {
				name                    = "TRV-886 Shotgun",
				alphaDecay              = 0.8,
				areaOfEffect            = 24,
				colormap                = "1 0.95 0.4 1   1 0.95 0.4 1    0 0 0 0.01    1 0.7 0.2 1",
				craterBoost             = 0,
				projectiles             = 1,
				craterMult              = 0,
				cylinderTargeting 		= 1,
				customParams        = {
					light_camera_height = 1200,
					light_color = "0.8 0.76 0.38",
					light_radius = 10,
					numprojectiles1 = 16,
					projectile1 = "cloakraid_emgsub",
					spawndist = 160,
					velspread1 = "10, 1, 10",
					reaim_time = 10,
					light_camera_height = 1500,
					light_color = "0.8 0.76 0.38",
					light_radius = 40,
				},
				damage                  = {
					default = 10.1*16,
				},
				explosionGenerator      = "custom:emg_hit_le",
				impactOnly              = false,
				edgeEffectiveness       = 0.1,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				noGap                   = true,
				noSelfDamage            = true,
				range                   = 230,
				mygravity               = 0.05,
				reloadtime              = 25/30,
				rgbColor                = "1 0.95 0.4",
				separation              = 0.02,
				size                    = 1.3,
				sizeDecay               = 0.01,
				soundhit			    = "weapon/cannon/emg_hit",
				soundStart              = "LurkerFire",
				soundHitVolume          = 0.2,
				soundStartVolume        = 0.2,
				soundTrigger            = true,
				stages                  = 18,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 1100,
			},
		},

		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "spherebot_dead.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2b.s3o",
			},

		},
	} 
}
