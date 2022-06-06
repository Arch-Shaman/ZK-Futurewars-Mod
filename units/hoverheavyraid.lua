return { 
	hoverheavyraid = {
		unitname            = [[hoverheavyraid]],
		name                = [[Blade]],
		description         = [[Phaser Support Hovercraft]],
		acceleration        = 0.25,
		brakeRate           = 0.516,
		buildCostMetal      = 210,
		builder             = false,
		buildPic            = [[hoverheavyraid.png]],
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = [[HOVER]],
		collisionVolumeOffsets = [[0 -4 0]],
		collisionVolumeScales  = [[22 22 40]],
		collisionVolumeType    = [[cylZ]],
		corpse              = [[DEAD]],
		customParams        = {
			modelradius       = [[25]],
			selection_scale   = 0.85,
			aim_lookahead     = 120,
		},
		explodeAs           = [[BIG_UNITEX]],
		footprintX          = 3,
		footprintZ          = 3,
		iconType            = [[hoversupport]],
		maxDamage           = 820,
		maxSlope            = 36,
		maxVelocity         = 3.1,
		movementClass       = [[HOVER3]],
		noChaseCategory     = [[TERRAFORM FIXEDWING SUB]],
		objectName          = [[hoverskirm.s3o]],
		script              = [[hoverheavyraid.lua]],
		selfDestructAs      = [[BIG_UNITEX]],
		sfxtypes            = {
			explosiongenerators = {
				[[custom:HOVERS_ON_GROUND]],
				[[custom:RAIDMUZZLE]],
				[[custom:flashmuzzle1]],
				[[custom:disruptor_cannon_muzzle]],
			},
		},
		sightDistance       = 600,
		sonarDistance       = 600,
		turninplace         = 0,
		turnRate            = 575,
		weapons             = {
			{
				def                = [[DISRUPTOR]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		},
		weaponDefs          = {
			DISRUPTOR      = {
				name                    = [[Disruptor Phaser]],
				areaOfEffect            = 60,
				beamdecay               = 0.9,
				beamTime                = 4/30,
				beamttl                 = 50,
				coreThickness           = 0.15,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					timeslow_damagefactor     = 3.5,
					light_camera_height       = 2000,
					light_color               = [[0.85 0.33 1]],
					light_radius              = 120,
					underwaterdamagereduction = 0.7,
					nofriendlyfire            = 1,
					script_reload = [[6]],
					script_burst = [[3]],
				},
				damage                  = {
					default = 210.1,
				},
				duration                = 0.4,
				edgeEffectiveness		= 0.1,
				explosionGenerator      = [[custom:riotballplus2_purple_small60]],
				fireStarter             = 30,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				largeBeamLaser          = true,
				laserFlareSize          = 4.33,
				minIntensity            = 1,
				noSelfDamage            = true,
				range                   = 380,
				reloadtime              = 10/30,
				rgbColor                = [[0.3 0 0.4]],
				soundStart              = [[weapon/impacts/aoe_aurafast]],
				soundHit                = [[weapon/laser/disruptor_3]],
				soundStartVolume        = 3,
				sweepfire               = false,
				texture1                = [[lightlaser]],
				texture2                = [[flare]],
				texture3                = [[flare]],
				texture4                = [[smallflare]],
				thickness               = 3,
				tolerance               = 18000,
				turret                  = true,
				weaponType              = [[LaserCannon]],
				weaponVelocity          = 700,
				waterweapon				= true,
			},
		},
		featureDefs         = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[hoverskirm_dead.s3o]],
			},


			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2c.s3o]],
			},
		},
	} 
}
