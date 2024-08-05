return { 
	hoverskirm = {
		unitname            = "hoverskirm",
		name                = "Pike",
		description         = "Sonic Strike Hovercraft",
		acceleration        = 0.030,
		activateWhenBuilt   = true,
		brakeRate           = 0.15,
		buildCostMetal      = 325,
		builder             = false,
		buildPic            = "hoversonic.png",
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "HOVER",
		corpse              = "DEAD",
		customParams        = {
			modelradius    = "25",
			nanoregen = 30,
			nano_maxregen = 5.0,
			bait_level_default = 1,
		},
		explodeAs           = "BIG_UNITEX",
		footprintX          = 3,
		footprintZ          = 3,
		iconType            = "hoverskirm",
		idleAutoHeal        = 5,
		idleTime            = 1800,
		health              = 2200,
		maxSlope            = 36,
		speed               = 4.5,
		movementClass       = "HOVER3",
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM FIXEDWING SATELLITE SUB",
		objectName          = "hovershotgun.s3o",
		script              = "hovershotgun.cob",
		selfDestructAs      = "BIG_UNITEX",

		sfxtypes            = {
			explosiongenerators = {
				"custom:HEAVYHOVERS_ON_GROUND",
				"custom:sonicfire_80",
			},
		},
		sightDistance       = 550,
		turninplace         = 0,
		turnRate            = 190,
		weapons             = {
			{
				def                = "SONIC",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SUB SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs          = {
			SONIC         = {
				name                    = "Heavy Sonic Cannon",
				areaOfEffect            = 80,
				avoidFeature            = true,
				avoidFriendly           = true,
				burnblow                = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					force_ignore_ground = "1",
					lups_explodelife = 1.0,
					lups_explodespeed = 0.5,
					light_radius = 80,
					blastwave_size = 35,
					blastwave_impulse = 1.6,
					blastwave_speed = 1.5,
					blastwave_life = 30,
					blastwave_lossfactor = 0.80,
					blastwave_damage = 75,
					damage_vs_shield = 700,
				},
				damage                  = {
					default = 350.01,
				},
				cegTag                  = "sonicarcher",
				cylinderTargeting       = 1,
				explosionGenerator      = "custom:sonic_80",
				edgeEffectiveness       = 0.5,
				fireStarter             = 150,
				impulseBoost            = 100,
				impulseFactor           = 0.5,
				interceptedByShieldType = 1,
				myGravity               = 0.01,
				noSelfDamage            = true,
				range                   = 500,
				reloadtime              = 4.5,
				size                    = 50,
				sizeDecay               = 0.2,
				soundStart              = "weapon/cannon/heavy_sonic2_fire",
				soundHit                = "weapon/cannon/heavy_sonic2_hit",
				soundStartVolume        = 6,
				soundHitVolume          = 10,
				stages                  = 1,
				texture1                = "sonic_glow2",
				texture2                = "null",
				texture3                = "null",
				rgbColor                = {0.2, 0.6, 0.8},
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 580,
				waterweapon             = true,
				duration                = 0.15,
			}
		},
		featureDefs         = {
			DEAD  = {
				blocking         = false,
				featureDead      = "HEAP",
				footprintX       = 3,
				footprintZ       = 3,
				object           = "hoverassault_dead.s3o",
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = "debris3x3c.s3o",
			},

		},
	} 
}