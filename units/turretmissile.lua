return { 
	turretmissile = {
		unitname                      = [[turretmissile]],
		name                          = [[Mirador]],
		description                   = [[Missile Barrage Tower]],
		acceleration                  = 0,
		brakeRate                     = 0,
		buildCostMetal                = 140,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 4,
		buildingGroundDecalSizeY      = 4,
		buildingGroundDecalType       = [[turretmissile_aoplane.dds]],
		buildPic                      = [[turretmissile.png]],
		category                      = [[FLOAT TURRET CHEAP]],
		collisionVolumeOffsets        = [[0 0 0]],
		collisionVolumeScales         = [[24 70 24]],
		collisionVolumeType           = [[CylY]],
		corpse                        = [[DEAD]],

		customParams                  = {
			aimposoffset   = [[0 20 0]],
			bait_level_default = 0,
		},

		explodeAs                     = [[BIG_UNITEX]],
		floater                       = true,
		footprintX                    = 2,
		footprintZ                    = 2,
		iconType                      = [[defenseskirm]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		levelGround                   = false,
		losEmitHeight                 = 40,
		maxDamage                     = 560,
		maxSlope                      = 36,
		maxVelocity                   = 0,
		noAutoFire                    = false,
		noChaseCategory               = [[FIXEDWING LAND SINK TURRET SHIP SATELLITE SWIM GUNSHIP FLOAT SUB HOVER]],
		objectName                    = [[lmt2.s3o]],
		script                        = [[turretmissile.lua]],
		selfDestructAs                = [[BIG_UNITEX]],

		sfxtypes                      = {
			explosiongenerators = {
				[[custom:PULVMUZZLE]],
				[[custom:PULVBACK]],
			},
		},
		sightDistance                 = 800, -- Range*1.1 + 48 for radar overshoot
		turnRate                      = 0,
		useBuildingGroundDecal        = true,
		workerTime                    = 0,
		yardMap                       = [[oo oo]],

		weapons                       = {
			{
				def                = [[MISSILE]],
				--badTargetCategory  = [[HOVER SWIM LAND SINK FLOAT SHIP]],
				onlyTargetCategory = [[LAND SINK TURRET SHIP SWIM FLOAT HOVER]],
			},
		},

		weaponDefs                    = {
		
			BOMBLET = {
				name                    = [[Palvo Bomblet]],
				areaOfEffect            = 96,
				avoidFriendly			= false,
				collideFriendly			= false,
				craterBoost             = 0,
				craterMult              = 0,
				customParams = {
					light_camera_height = 200,
					light_color = [[0.90 0.65 0.30]],
					light_radius = 600,
				},
				damage                  = {
					default = 40.01,
				},

				edgeEffectiveness		= 1/3,
				explosionGenerator      = [[custom:STARFIRE]],
				fireStarter             = 70,
				fixedlauncher           = 1,
				flightTime              = 1,
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = [[wep_b_fabby.s3o]],
				range                   = 115,
				reloadtime              = 20,
				smokeTrail              = true,
				soundHit                = [[weapon/missile/sabot_hit]],
				soundHitVolume          = 5,
				soundStart              = [[weapon/missile/sabot_fire_short]],
				soundStartVolume        = 9,
				soundTrigger            = 1,
				startVelocity           = 50,
				texture2                = [[darksmoketrail]],
				tracks                  = false,
				turnRate                = 180,
				turret                  = true,
				weaponAcceleration      = 200,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 300,
			},
			MISSILE = {
				name                    = [[Palvo Rocket Barrage]],
				areaOfEffect            = 96,
				burnblow                = true,
				cegTag                  = [[missiletrailyellow]],
				craterBoost             = 0,
				craterMult              = 0,
				--avoidGround				= false,
				avoidFeature			= false,

				customParams        = {
					burst = Shared.BURST_RELIABLE,
					light_camera_height = 1600,
					light_color = [[0.90 0.65 0.30]],
					light_radius = 250,
					script_reload = [[13.5]],
					script_burst = [[3]],
					numprojectiles1 = 6, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "turretmissile_bomblet",
					--spreadradius1 = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 180, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = "-4,-1,-4,4,1,4", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
				},

				damage                  = {
					default = 40.01*6,
				},

				fireStarter             = 70,
				flightTime              = 8.45,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = [[wep_m_ajax.s3o]],
				noSelfDamage            = true,
				predictBoost            = 0.75,
				range                   = 630,
				reloadtime              = 0.2,
				smokeTrail              = false,
				soundHit                = [[weapon/missile/sabot_fire_short]],
				soundHitVolume          = 8,
				soundStart              = [[weapon/missile/sabot_fire]],
				soundStartVolume        = 7,
				startVelocity           = 100,
				tracks                  = true,
				trajectoryHeight        = 1.85,
				turnrate                = 12000,
				turret                  = true,
				weaponAcceleration      = 200,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 450,
			},
		},
		featureDefs                   = {
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[Pulverizer_d.s3o]],
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[debris3x3b.s3o]],
			},
		},
	} 
}