return { 
	tankheavyraid = {
		unitname               = "tankheavyraid",
		name                   = "Thunderclap",
		description            = "Lightning Riot Tank",
		acceleration           = 0.75,
		brakeRate              = 1.65,
		buildCostMetal         = 300,
		builder                = false,
		buildPic               = "tankheavyraid.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND TOOFAST",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "28 12 28",
		collisionVolumeType    = "box",
		corpse                 = "DEAD",
		customParams           = {
			modelradius       = "10",
			selection_scale   = 0.85,
			aim_lookahead     = 120,
			bait_level_default = 0,
			outline_x = 80,
			outline_y = 80,
			outline_yoff = 12.5,
		},
		explodeAs              = "NOWEAPON",
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = "tankraider",
		leaveTracks            = true,
		maxDamage              = 1950,
		maxSlope               = 18,
		maxVelocity            = 2.8,
		maxWaterDepth          = 22,
		movementClass          = "TANK3",
		noAutoFire             = false,
		noChaseCategory        = "TERRAFORM FIXEDWING SATELLITE SUB",
		objectName             = "corseal.s3o",
		script                 = "tankheavyraid.lua",
		selfDestructAs         = "NOWEAPON",
		sfxtypes               = {
			explosiongenerators = {
				"custom:PANTHER_SPARK",
				"custom:zeusmuzzle",
			},
		},
		sightDistance          = 600,
		trackOffset            = 6,
		trackStrength          = 5,
		trackStretch           = 1,
		trackType              = "StdTank",
		trackWidth             = 32,
		turninplace            = 0,
		turnRate               = 880,
		workerTime             = 0,
		weapons                = {
			{
				def                = "ARMLATNK_WEAPON",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
			{
				def                = "sublightning_1",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
			{
				def                = "sublightning_2",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
			{
				def                = "hacky_dead_lightning",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs             = {
			panther_death = {
				name = "death explosion initiator (FAKE)",
				areaOfEffect       = 1,
				craterBoost        = 0,
				craterMult         = 0,
				customParams       = {
					bogus = 1,
					chainlightning_num = 2,
					chainlightning_searchdist = 220,
					chainlightning_ff = 0,
					chainlightning_maxtargets = 4,
					chainlightning_index = 4,
					chainlightning_sub = 1,
				},
				edgeEffectiveness  = 0,
				explosionGenerator = "custom:lightningplosion_nopost",
				impulseBoost       = 0,
				impulseFactor      = 0,
				damage = {
					default          = 0,
				},
			},
			panther_death_final = {
				areaOfEffect       = 352,
				craterBoost        = 0,
				craterMult         = 0,
				edgeEffectiveness  = 0.5,
				explosionGenerator = "custom:electric_explosion2",
				explosionSpeed     = 10,
				impulseBoost       = 0,
				impulseFactor      = 0,
				name               = "EMP Explosion",
				paralyzer          = true,
				paralyzeTime       = 16,
				soundHit           = "explosion/small_emp_explode",
				damage = {
					default          = 0,
				},
				customParams = {
					blastwave_speed = 15,
					blastwave_life = 10,
					blastwave_lossfactor = 0.88,
					blastwave_damage = 0,
					blastwave_empdmg = 1000,
					blastwave_emptime = 3,
					blastwave_slowdmg = 0,
					blastwave_size = 25,
					blastwave_impulse = 0,
					blastwave_nofriendly = "MIKAELIN JOULUJUHLA",
				},
			},
			ARMLATNK_WEAPON = {
				name                    = "X-09 Fulminator",
				areaOfEffect            = 8,
				beamTTL                 = 1,
				burst                   = 20,
				burstrate               = 1/30,
				craterBoost             = 0,
				craterMult              = 0,
				avoidFeature            = false,
				customParams            = {
					burst = Shared.BURST_RELIABLE,
					extra_damage = 33,
					light_camera_height = 1600,
					light_color = "0.85 0.85 1.2",
					light_radius = 180,
					stats_custom_tooltip_1 = " - Forks to up to 6 targets up to 180 elmos away",
					stats_custom_tooltip_2 = " - Forking Efficiency: 33%",
					stats_custom_tooltip_3 = " - Forks bounce to 4 additional targets each",
					chainlightning_num = 1,
					chainlightning_searchdist = 180,
					chainlightning_ff = 0,
					chainlightning_maxtargets = 3,
					chainlightning_index = 2,
				},
				cylinderTargeting      = 0,
				damage                  = {
					default        = 18.01,
				},
				duration                = 10,
				xplosionGenerator       = "custom:lightningplosion_nopost",
				fireStarter             = 150,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 12,
				interceptedByShieldType = 1,
				paralyzeTime            = 1,
				range                   = 300,
				reloadtime              = 2.6,
				rgbColor                = "0.5 0.5 1",
				soundStart              = "weapon/emp/lightningcannon_fire",
				soundTrigger            = true,
				texture1                = "lightning",
				thickness               = 10,
				turret                  = true,
				weaponType              = "LightningCannon",
				weaponVelocity          = 400,
			},
			sublightning_1 = {
				name                    = "Forked Lightning",
				areaOfEffect            = 8,
				craterBoost             = 0,
				craterMult              = 0,
				beamTTL                 = 3,
				customParams            = {
					burst = Shared.BURST_RELIABLE,
					extra_damage = 11,
					light_camera_height = 1600,
					light_color = "0.1875 0.1875 0.75",
					light_radius = 20,
					chainlightning_num = 2,
					chainlightning_searchdist = 180,
					chainlightning_ff = 0,
					chainlightning_maxtargets = 4,
					chainlightning_index = 3,
					chainlightning_sub = 1,
					hideweapon = 1,
				},
				cylinderTargeting      = 0,
				damage                  = {
					default        = 6.01,
				},
				duration                = 10,
				explosionGenerator      = "custom:NONE",
				fireStarter             = 150,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 12,
				interceptedByShieldType = 1,
				paralyzeTime            = 1,
				range                   = 245,
				reloadtime              = 2.6,
				rgbColor                = "0.1875 0.1875 0.75",
				soundHit                = "weapon/emp/lightningcannon_hit",
				texture1                = "lightning",
				thickness               = 7,
				turret                  = true,
				weaponType              = "LightningCannon",
				weaponVelocity          = 400,
			},
			sublightning_2 = {
				name                    = "Forked Lightning 2",
				areaOfEffect            = 8,
				craterBoost             = 0,
				craterMult              = 0,
				beamTTL                 = 4,
				customParams            = {
					burst = Shared.BURST_RELIABLE,
					extra_damage = 3,
					light_camera_height = 1600,
					light_color = "0.14 0.14 0.5625",
					light_radius = 10,
					hideweapon = 1,
				},
				cylinderTargeting      = 0,
				damage                  = {
					default        = 2.01,
				},
				duration                = 10,
				explosionGenerator      = "custom:NONE",
				fireStarter             = 150,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 12,
				interceptedByShieldType = 1,
				paralyzeTime            = 1,
				range                   = 245,
				reloadtime              = 2.6,
				rgbColor                = "0.14 0.14 0.5625",
				soundHit                = "weapon/emp/lightningcannon_hit",
				texture1                = "lightning",
				thickness               = 5,
				turret                  = true,
				weaponType              = "LightningCannon",
				weaponVelocity          = 400,
			},
			hacky_dead_lightning = {
				name                    = "EMP Overload (Death Explosion)",
				areaOfEffect            = 8,
				craterBoost             = 0,
				craterMult              = 0,
				beamTTL                 = 4,
				customParams            = {
					burst = Shared.BURST_RELIABLE,
					extra_damage = 203,
					light_camera_height = 1600,
					light_color = "0.1875 0.1875 0.75",
					light_radius = 10,
					stats_custom_tooltip_1 = " - Forks to up to 12 targets up to 220 elmos away",
					stats_custom_tooltip_2 = " - Finishes with an EMP blast, impacting enemy units only",
					stats_custom_tooltip_3 = " - Forks may strike multiple times",
				},
				cylinderTargeting      = 0,
				damage                  = {
					default        = 50.01,
				},
				duration                = 10,
				explosionGenerator      = "custom:NONE",
				fireStarter             = 150,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 12,
				interceptedByShieldType = 1,
				paralyzeTime            = 3,
				range                   = 245,
				reloadtime              = 2.6,
				rgbColor                = "0.1875 0.1875 0.75",
				soundHit                = "weapon/emp/lightningcannon_hit",
				texture1                = "lightning",
				thickness               = 5,
				turret                  = true,
				weaponType              = "LightningCannon",
				weaponVelocity          = 400,
			},
		},
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "corseal_dead.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2c.s3o",
			},
		},
	} 
}