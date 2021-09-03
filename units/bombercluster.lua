return { 
	bombercluster = {
		unitname            = [[bombercluster]],
		name                = [[Divinity]],
		description         = [[Cluster Bomber]],
		brakerate           = 0.4,
		buildCostMetal      = 625,
		builder             = false,
		buildPic            = [[bomberprec.png]],
		canFly              = true,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		canSubmerge         = false,
		category            = [[FIXEDWING]],
		collide             = false,
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[80 10 30]],
		collisionVolumeType    = [[box]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[95 25 60]],
		selectionVolumeType    = [[box]],
		corpse              = [[DEAD]],
		cruiseAlt           = 300,

		customParams        = {
			modelradius    = [[15]],
			refuelturnradius = [[220]],
			reammoseconds    = [[8]],
			requireammo    = [[1]],
			reallyabomber    = [[1]],
		},

		explodeAs           = [[GUNSHIPEX]],
		floater             = true,
		footprintX          = 3,
		footprintZ          = 3,
		iconType            = [[bomberassault]],
		idleAutoHeal        = 10,
		idleTime            = 1800,
		maneuverleashlength = [[1380]],
		maxAcc              = 0.5,
		maxBank             = 0.6,
		maxDamage           = 2400,
		maxElevator         = 0.02,
		maxRudder           = 0.013,
		maxFuel             = 1000000,
		maxPitch            = 0.4,
		maxVelocity         = 6.2,
		noAutoFire          = false,
		noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE GUNSHIP]],
		objectName          = [[corshad.s3o]],
		script              = [[bombercluster.lua]],
		selfDestructAs      = [[GUNSHIPEX]],

		sfxtypes            = {

			explosiongenerators = {
				[[custom:light_red]],
				[[custom:light_green]],
			},

		},
		sightDistance       = 780,
		turnRadius          = 300,
		workerTime          = 0,

		weapons             = {
			{
				def                = [[BOMBSABOT]],
				mainDir            = [[0 -1 0]],
				onlyTargetCategory = [[LAND TURRET SHIP SWIM FLOAT HOVER UNARMED]],
			},
		},
		weaponDefs          = {

			BOGUS_BOMB = {
				name                    = [[Fake Bomb]],
				areaOfEffect            = 80,
				craterBoost             = 0,
				craterMult              = 0,

				customParams            = {
					reaim_time = 15, -- Fast update not required (maybe dangerous)
					bogus = 1,
				},

				damage                  = {
					default = 0,
				},

				edgeEffectiveness       = 0,
				explosionGenerator      = [[custom:NONE]],
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				model                   = [[]],
				myGravity               = 1000,
				range                   = 10,
				reloadtime              = 10,
				weaponType              = [[AircraftBomb]],
			},
			BOMBSABOT  = {
				name                    = [[Cluster Bomb]],
				areaOfEffect            = 0,
				avoidFeature            = false,
				avoidFriendly           = false,
				--cegTag                  = [[WEAPEXP_PUFF]],
				collideFeature          = false,
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting       = 1,
				burst					= 2,
				burstRate				= 10/30,
				projectiles				= 1,

				damage                  = {
					default = 1000,
				},
      
				customParams            = {
					light_color = [[1.1 0.9 0.45]],
					light_radius = 220,
					--torp_underwater = [[bomberprec_a_torpedo]],
					numprojectiles1 = 12, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "bombercluster_bomblet",
					--spreadradius1 = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					proxy = 0, -- check for nearby units?
					useheight = 1,
					spawndist = 180, -- at what distance should we spawn the projectile(s)? REQUIRED.
					vradius1 = "-5,0,-5,5,2,5", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 1,
					reaim_time = 60, -- see what the hell this does.
				},

				explosionGenerator      = [[custom:WEAPEXP_PUFF]],
				fireStarter             = 70,
				flightTime              = 3,
				heightmod               = 0,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				leadlimit               = 0,
				model                   = [[hobbes.s3o]],
				leadLimit               = 20,
				mygravity		        = 0.25,
				reloadtime              = 5,
				range			        = 50,
				texture2                = [[darksmoketrail]],
				soundHit                = [[weapon/cannon/cannonfire_001]],
				soundStart              = [[weapon/bomb_drop]],
				startVelocity           = 150,
				tolerance               = 65536/2, -- 180 degrees
				fireTolerance		    = 65536/2,
				accuracy		        = 2800,
				sprayangle		        = 300,
				turnRate                = 2500,
				turret                  = true,
				weaponAcceleration      = 150,
				weaponType              = [[AircraftBomb]],
				weaponVelocity          = 440,
			},
			BOMBLET = {
				name                    = [[High Explosive Bomblet]],
				accuracy                = 200,
				areaOfEffect            = 128,
				craterBoost             = 10,
				craterMult              = 5,

				damage                  = {
					default = 125,
				},

				explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],
				fireStarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				interceptedByShieldType = 2,
				model                   = [[wep_b_fabby.s3o]],
				range                   = 200,
				reloadtime              = 1,
				smokeTrail              = true,
				soundHit                = [[explosion/ex_med6]],
				soundHitVolume          = 8,
				soundStart              = [[weapon/cannon/mini_cannon]],
				soundStartVolume        = 2,
				sprayangle              = 14400,
				turret                  = true,
				tolerance				= 32000,
				firetolerance			= 32000,
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
				object           = [[spirit_dead.s3o]],
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
