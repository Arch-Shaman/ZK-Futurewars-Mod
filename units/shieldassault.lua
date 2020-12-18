return { 
	shieldassault = {
		unitname            = [[shieldassault]],
		name                = [[Ward]],
		description         = [[Shielded Skirmisher/Assault Bot]],
		acceleration        = 0.75,
		activateWhenBuilt   = true,
		brakeRate           = 1.32,
		buildCostMetal      = 175,
		buildPic            = [[shieldassault.png]],
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = [[LAND]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[45 45 45]],
		selectionVolumeType    = [[ellipsoid]],
		corpse              = [[DEAD]],

		customParams        = {
			shield_emit_height = 17,
			cus_noflashlight   = 1,
			selection_scale    = 0.82,
		},

		explodeAs           = [[BIG_UNITEX]],
		footprintX          = 3,
		footprintZ          = 3,
		iconType            = [[walkerassault]],
		idleAutoHeal        = 5,
		idleTime            = 1800,
		leaveTracks         = true,
		maxDamage           = 960,
		maxSlope            = 36,
		maxVelocity         = 1.925,
		maxWaterDepth       = 22,
		minCloakDistance    = 75,
		movementClass       = [[KBOT3]],
		noChaseCategory     = [[TERRAFORM FIXEDWING SUB]],
		objectName          = [[thud.s3o]],
		onoffable           = false,
		script              = [[shieldassault.lua]],
		selfDestructAs      = [[BIG_UNITEX]],

		sfxtypes            = {

			explosiongenerators = {
				[[custom:THUDMUZZLE]],
				[[custom:THUDSHELLS]],
				[[custom:THUDDUST]],
			},

		},

		sightDistance       = 420,
		trackOffset         = 0,
		trackStrength       = 8,
		trackStretch        = 1,
		trackType           = [[ComTrack]],
		trackWidth          = 22,
		turnRate            = 2400,
		upright             = true,

		weapons             = {

			{
				def                = [[THUD_WEAPON]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

			{
				def = [[SHIELD]],
			},

		},

		weaponDefs          = {

			SHIELD      = {
				name                    = [[Energy Shield]],

				damage                  = {
					default = 10,
				},

				exteriorShield          = true,
				shieldAlpha             = 0.2,
				shieldBadColor          = [[1 0.1 0.1 1]],
				shieldGoodColor         = [[0.1 0.1 1 1]],
				shieldInterceptType     = 3,
				shieldPower             = 2000,
				shieldPowerRegen        = 30,
				shieldPowerRegenEnergy  = 1.2,
				shieldRadius            = 80,
				shieldRepulser          = false,
				shieldStartingPower     = 1650,
				smartShield             = true,
				visibleShield           = false,
				visibleShieldRepulse    = false,
				weaponType              = [[Shield]],
			},

			THUD_WEAPON = {
				name                    = [[Medium Plasma Cannon]],
				areaOfEffect            = 36,
				craterBoost             = 0,
				craterMult              = 0,
				burst = 2,
				burstrate = 0.5,

				customParams        = {
					light_camera_height = 1400,
					light_color = [[0.80 0.54 0.23]],
					light_radius = 200,
				},

				damage                  = {
					default = 125.1,
				},

				explosionGenerator      = [[custom:MARY_SUE]],
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				range                   = 420,
				reloadtime              = 3 + 1/3,
				soundHit                = [[shotgun_impactv5]],
				soundStart              = [[weapon/cannon/cannon_fire4]],
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 400,
			},
		},

		featureDefs         = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[thug_d.s3o]],
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
