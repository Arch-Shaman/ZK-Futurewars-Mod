return { 
	amphriot = {
		unitname               = [[amphriot]],
		name                   = [[Frother]],
		description            = [[Amphibious Riot Bot]],
		acceleration           = 0.54,
		activateWhenBuilt      = true,
		brakeRate              = 2.25,
		buildCostMetal         = 300,
		buildPic               = [[amphriot.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND SINK]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[30 30 30]],
		selectionVolumeType    = [[ellipsoid]],
		corpse                 = [[DEAD]],

		customParams           = {
			amph_regen = 30,
			amph_submerged_at = 40,
			sink_on_emp    = 1,
			floattoggle    = [[1]],
		},

		explodeAs              = [[BIG_UNITEX]],
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = [[amphtorpriot]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 1410,
		maxSlope               = 36,
		maxVelocity            = 1.6,
		minCloakDistance       = 75,
		movementClass          = [[AKBOT2]],
		noChaseCategory        = [[TERRAFORM FIXEDWING GUNSHIP HOVER]],
		objectName             = [[amphriot.s3o]],
		script                 = [[amphriot.lua]],
		selfDestructAs         = [[BIG_UNITEX]],

		sfxtypes               = {
			explosiongenerators = {
				[[custom:HEAVY_CANNON_MUZZLE]],
				[[custom:RIOT_SHELL_L]],
			},
		},

		sightDistance          = 480,
		sonarDistance          = 480,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = [[ChickenTrackPointy]],
		trackWidth             = 28,
		turnRate               = 1000,
		upright                = false,

		weapons                = {

			{
				def                = [[FLECHETTE]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

			--{
				--def                = [[TORPEDO]],
				--badTargetCategory  = [[FIXEDWING]],
				--onlyTargetCategory = [[SWIM LAND SUB SINK TURRET FLOAT SHIP HOVER]],
			--},

		},

		weaponDefs             = {
			TORPEDO = {
				name                    = [[Undersea Charge Launcher]],
				areaOfEffect            = 48,
				burst                   = 2,
				burstRate               = 0.3,
				avoidFriendly           = false,
				bouncerebound           = 0.7,
				bounceslip              = 1,
				burnblow                = true,
				canAttackGround         = false, -- also workaround for range hax
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				cegTag                  = [[torpedo_trail]],

				damage                  = {
					default = 48.01,
				},

				edgeEffectiveness       = 0.6,
				explosionGenerator      = [[custom:TORPEDO_HIT_SMALL_WEAK]],
				flightTime              = 1.5,
				groundbounce            = 1,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0.6,
				interceptedByShieldType = 1,
				leadlimit               = 1,
				myGravity               = 2,
				model                   = [[diskball.s3o]],
				numBounce               = 4,
				range                   = 270,
				reloadtime              = 2,
				soundHit                = [[TorpedoHitVariable]],
				soundHitVolume          = 2.6,
				--soundStart            = [[weapon/torpedo]],
				startVelocity           = 90,
				tracks                  = true,
				turnRate                = 70000,
				turret                  = true,
				waterWeapon             = true,
				weaponAcceleration      = 700,
				weaponType              = [[TorpedoLauncher]],
				weaponVelocity          = 300,
			},

			FLECHETTE = {
				name                    = [[Quad Grenade Launcher]],
				areaOfEffect            = 96,
				bouncerebound           = 0.5,
				bounceslip              = 0.4,
				burst                   = 4,
				burstRate               = 4/30,
				craterBoost             = 0,
				craterMult              = 1,
				burnblow                = false,
				cegTag                  = [[hydromissile]],
				damage                  = {
					default = 180.01,
				},

				edgeEffectiveness       = 0.6,
				explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],
				flightTime              = 1.5,
				groundbounce            = 1,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 1.45,
				interceptedByShieldType = 1,
				leadlimit               = 100,
				myGravity               = 0.4,
				model                   = [[diskball.s3o]],
				numBounce               = 3,
				range                   = 440,
				reloadtime              = 1.3,
				soundHit                = [[weapon/clusters/light_cluster_grenade_hit]],
				soundHitVolume          = 8.6,
				soundStart              = [[weapon/cannon/light_launcher]],
				sprayAngle				= 6420,
				turret                  = true,
				waterWeapon             = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 380,
			}
		},

		featureDefs            = {

			DEAD      = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[amphriot_wreck.s3o]],
			},

			HEAP      = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2c.s3o]],
			},
		},
	} 
}
