return { 
	spiderskirm = {
		unitname               = [[spiderskirm]],
		name                   = [[Twilight]],
		description            = [[Skirmisher Spider (Indirect Line Fire)]],
		acceleration           = 0.234,
		brakeRate              = 1.38,
		buildCostMetal         = 340,
		buildPic               = [[spiderskirm.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND]],
		corpse                 = [[DEAD]],

		customParams           = {
			turnatfullspeed = [[1]],
			modelradius     = [[24]],
		},

		explodeAs              = [[BIG_UNITEX]],
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = [[spiderskirm]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 780,
		maxSlope               = 72,
		maxVelocity            = 2.1,
		maxWaterDepth          = 22,
		movementClass          = [[TKBOT3]],
		noChaseCategory        = [[TERRAFORM FIXEDWING GUNSHIP SATELLITE SUB]],
		objectName             = [[recluse.s3o]],
		script                 = [[spiderskirm.lua]],
		selfDestructAs         = [[BIG_UNITEX]],
		sightDistance          = 627,
		trackOffset            = 0,
		trackStrength          = 10,
		trackStretch           = 1,
		trackType              = [[ChickenTrackPointyShort]],
		trackWidth             = 52,
		turnRate               = 1400,

		weapons                = {

			{
				def                = [[ADV_ROCKET]],
				onlyTargetCategory = [[LAND SINK TURRET SHIP SWIM FLOAT HOVER]],
			},

		},

		weaponDefs             = {

			ADV_ROCKET = {
				name                    = [[Rocket Volley]],
				areaOfEffect            = 48,
				burst                   = 3,
				burstrate               = 0.3,
				cegTag                  = [[missiletrailpurple]],
				craterBoost             = 0,
				craterMult              = 0,

				customParams        = {
					light_camera_height = 2500,
					light_color = [[0.90 0.65 0.30]],
					light_radius = 250,
					numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "spiderskirm_disruptorbomb",
					--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 1, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					keepmomentum1 = 0,
					spawndist = 180, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 0, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = "-1,-5,-1,1,-3,1", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					useheight = 0, -- check the distance between ground and projectile? OPTIONAL.
					clustercharges = 7,
					clusterdelay = 4,
					cruisealt = 420,
					airlaunched = 1,
					cruisedist = -1,
					timeslow_damagefactor = 1.7,
					reveal_unit = 3,
				},

				damage                  = {
					default = 69*7,
				},

				edgeEffectiveness       = 0.5,
				fireStarter             = 70,
				flightTime              = 4,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = [[recluse_missile.s3o]],
				noSelfDamage            = true,
				predictBoost            = 0.75,
				range                   = 680,
				reloadtime              = 7,
				smokeTrail              = false,
				soundHit                = [[weapon/laser/small_laser_fire3]],
				soundHitVolume          = 2.2,
				soundStart              = [[weapon/missile/missile_fire4]],
				soundTrigger            = true,
				startVelocity           = 125,
				trajectoryHeight        = 1.8,
				turnRate                = 4000,
				turret                  = true,
				weaponAcceleration      = 150,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 350,
				wobble                  = 9000,
			},

			DISRUPTORBOMB = {
				name                    = [[Fake Disruption Cannon]],
				accuracy                = 200,
				areaOfEffect            = 120,
				cegTag                  = [[beamweapon_muzzle_purple]],
				craterBoost             = 1,
				craterMult              = 2,

				customparams = {
					timeslow_damagefactor = 1.7,
					bogus = 1,
					nofriendlyfire = 1,
				},

				damage                  = {
					default = 69,
				},

				explosionGenerator      = [[custom:riotballplus2_purple_small120]],
				fireStarter             = 180,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				interceptedByShieldType = 2,
				myGravity               = 1,
				range                   = 450,
				reloadtime              = 1.8,
				size                      = 5,
				rgbcolor                = [[0.9 0.1 0.9]],
				soundHit                = [[weapon/aoe_aura2]],
				soundHitVolume          = 3.5,
				stages                  = 7,
				soundTrigger            = true,
				turret                  = true,
				waterWeapon             = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 340,
			},
		},
		
		featureDefs            = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				collisionVolumeOffsets = [[0 0 0]],
				collisionVolumeScales  = [[50 30 50]],
				collisionVolumeType    = [[ellipsoid]],
				object           = [[recluse_wreck.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[debris3x3a.s3o]],
			},
		},
	} 
}
