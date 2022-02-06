return { 
	amphraid = {
		unitname               = [[amphraid]],
		name                   = [[Milta]],
		description            = [[Amphibious Light Skirmisher (Anti-Sub)]],
		acceleration           = 0.54,
		activateWhenBuilt      = true,
		brakeRate              = 2.25,
		buildCostMetal         = 150,
		buildPic               = [[amphraid.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND SINK]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[28 28 28]],
		selectionVolumeType    = [[ellipsoid]],
		corpse                 = [[DEAD]],

		customParams           = {
			amph_regen        = 15,
			amph_submerged_at = 40,
			aim_lookahead     = 80,
		},

		explodeAs              = [[BIG_UNITEX]],
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = [[amphtorpraider]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 480,
		maxSlope               = 36,
		maxVelocity            = 1.6,
		movementClass          = [[AKBOT2]],
		noChaseCategory        = [[TERRAFORM FIXEDWING GUNSHIP]],
		objectName             = [[amphraider3.s3o]],
		script                 = [[amphraid.lua]],
		selfDestructAs         = [[BIG_UNITEX]],

		sfxtypes               = {
			explosiongenerators = {},
		},

		sightDistance          = 660,
		sonarDistance          = 660,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = [[ComTrack]],
		trackWidth             = 22,
		turnRate               = 2100,
		upright                = true,

		weapons                = {
			{
				def                = [[TORPMISSILE]],
				onlyTargetCategory = [[SWIM HOVER LAND SINK TURRET FLOAT SHIP]],
			},
			{
				def                = [[TORPEDO]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[SWIM FIXEDWING HOVER LAND SINK TURRET FLOAT SHIP GUNSHIP SUB]],
			},
		},

		weaponDefs             = {
			secondary = {
				name                    = [[Hurricane Sonic Bomblet]],
				areaOfEffect            = 80,
				avoidFriendly           = false,
				bouncerebound           = 0.5,
				bounceslip              = 0.4,
				canAttackGround         = false, -- also workaround for range hax
				craterBoost             = 0,
				craterMult              = 0,
				cegTag                  = [[torpedo_trail]],
				customParams			= {
					blastwave_size = 30,
					blastwave_impulse = 0.5,
					blastwave_speed = 10,
					blastwave_life = 5,
					blastwave_lossfactor = 0.88,
					blastwave_damage = 100,
					damage_vs_shield = 200,
				},
				damage                  = {
					default = 5.01,
				},

				edgeEffectiveness       = 0.6,
				explosionGenerator      = [[custom:sonic_80]],
				flightTime              = 1.5,
				groundbounce            = 1,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0.6,
				interceptedByShieldType = 1,
				leadlimit               = 1,
				myGravity               = 0.4,
				model                   = [[diskball.s3o]],
				numBounce               = 3,
				range                   = 300,
				reloadtime              = 2,
				soundHit                = [[weapon/cannon/ultrasonic_fire]],
				soundHitVolume          = 8.6,
				--soundStart            = [[weapon/torpedo]],
				startVelocity           = 90,
				tracks                  = true,
				turnRate                = 70000,
				turret                  = true,
				waterWeapon             = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 380,
			},
			TORPMISSILE = {
				name                    = [[Sawhead Torpedo]],
				areaOfEffect            = 32,
				accuracy				= 220,
				--cegTag                  = [[missiletrailyellow]],
				craterBoost             = 1,
				craterMult              = 2,

				customparams = {
					numprojectiles1 = 3, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "amphraid_secondary",
					--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 180, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 0, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = "-2,-1,-2,2,2,2", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					useheight = 1, -- check the distance between ground and projectile? OPTIONAL.
					proxy = 0, -- check for nearby units?
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					light_color = [[1 0.6 0.2]],
					light_radius = 180,
				},

				damage                  = {
					default = 130.01,
				},

				explosionGenerator      = [[custom:INGEBORG]],
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				model                   = [[wep_m_ajax.s3o]],
				noSelfDamage            = true,
				projectiles             = 1,
				range                   = 470,
				reloadtime              = 4,
				mygravity				= 0.25,
				smokeTrail              = true,
				soundHit                = [[weapon/clusters/cluster_grenade_hit]],
				soundStart              = [[weapon/missile/air_launched_missile]],
				startVelocity           = 140,
				texture2                = [[lightsmoketrail]],
				tolerance               = 1000,
				highTrajectory          = 1,
				heightBoostFactor		= 1.01,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 420,
			},

			TORPEDO = {
				name                    = [[Sawhead Torpedo]],
				areaOfEffect            = 32,
				avoidFriendly           = false,
				bouncerebound           = 0.5,
				bounceslip              = 0.8,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[torpedo_trail]],
				customParams            = {
					numprojectiles1 = 3, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "amphraid_secondary",
					--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 90, -- at what distance should we spawn the projectile(s)? REQUIRED.
					--timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = "-2,1,-2,2,2,2", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 0, -- check the distance between ground and projectile? OPTIONAL.
					proxy = 1, -- check for nearby units?
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					cruisealt = -0.05,
					cruisedist = 100,
					cruise_ascendradius = 80,
					cruisetracking = 1,
					cruise_nolock = 1,
					cas_nocruisecheck = "periksiantamattomuus ja omista virheistään oppiminen ovat kaiken a ja o", -- katseletko? :D
					--keepinwater = 1,
				},
				damage                  = {
					default = 130.01,
				},

				edgeEffectiveness       = 0.99,
				explosionGenerator      = [[custom:TORPEDO_HIT]],
				flightTime              = 30.0,
				groundbounce            = 1,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				leadlimit               = 0,
				model                   = [[wep_m_ajax.s3o]],
				numbounce               = 4,
				noSelfDamage            = true,
				projectiles             = 1,
				range                   = 470,
				reloadtime              = 4,
				soundHit                = [[weapon/torpedo/torpedohit_light]],
				soundStart              = [[weapon/torpedo/torp_launch_amph_light]],
				soundStartVolume        = 0.7,
				soundHitVolume          = 0.7,
				startVelocity           = 40,
				tolerance               = 1000,
				tracks                  = true,
				turnRate                = 35000,
				turret                  = true,
				waterWeapon             = true,
				weaponAcceleration      = 75,
				weaponType              = [[TorpedoLauncher]],
				weaponVelocity          = 280,
			},
		},

		featureDefs            = {

			DEAD      = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[amphraider3_dead.s3o]],
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
