return { 
	turretriot = {
		unitname                      = [[turretriot]],
		name                          = [[Bombard]],
		description                   = [[Anti-Swarm Turret (Needs 4E Grid)]],
		activateWhenBuilt             = true,
		buildCostMetal                = 200,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 5,
		buildingGroundDecalSizeY      = 5,
		buildingGroundDecalType       = [[turretriot_aoplane.dds]],
		buildPic                      = [[turretriot.png]],
		category                      = [[FLOAT TURRET]],
		collisionVolumeOffsets        = [[0 0 0]],
		collisionVolumeScales         = [[45 45 45]],
		collisionVolumeType           = [[ellipsoid]],
		corpse                        = [[DEAD]],

		customParams                  = {
			aimposoffset   = [[0 12 0]],
			midposoffset   = [[0 4 0]],
			aim_lookahead  = 100,
			neededlink  = 4,
			pylonrange  = 30,
		},

		explodeAs                     = [[LARGE_BUILDINGEX]],
		floater                       = true,
		footprintX                    = 3,
		footprintZ                    = 3,
		iconType                      = [[defenseriot]],
		levelGround                   = false,
		maxDamage                     = 1600,
		maxSlope                      = 18,
		minCloakDistance              = 150,
		noChaseCategory               = [[FIXEDWING LAND SHIP SWIM GUNSHIP SUB HOVER]],
		objectName                    = [[afury.s3o]],
		script                        = "turretriot.lua",
		selfDestructAs                = [[LARGE_BUILDINGEX]],
		sfxtypes                      = {

			explosiongenerators = {
				[[custom:WARMUZZLE]],
				[[custom:DEVA_SHELLS]],
			},

		},

		sightDistance                 = 351, -- Range*1.1 + 48 for radar overshoot
		useBuildingGroundDecal        = true,
		yardMap                       = [[ooo ooo ooo]],
		weapons                       = {

			{
				def                = [[turretriot_WEAPON]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
				mainDir            = [[0 1 0]],
				maxAngleDif        = 240,
			},

		},

		weaponDefs                    = {
			secondary = {
				name                    = [[Fragment]],
				accuracy                = 350,
				alphaDecay              = 0.7,
				areaOfEffect            = 96,
				burnblow                = true,
				burst                   = 3,
				burstrate               = 0.1,
				craterBoost             = 0.15,
				craterMult              = 0.3,

				customParams        = {
					light_camera_height = 1600,
					light_color = [[0.8 0.76 0.38]],
					light_radius = 40,
					isFlak = 3,
					flaktime = -15,
				},
				
				damage                  = {
					default = 22,
				},

				edgeEffectiveness       = 0.5,
				explosionGenerator      = [[custom:EMG_HIT_HE]],
				firestarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 275,
				reloadtime              = 0.5,
				rgbColor                = [[1 0.95 0.4]],
				separation              = 1.5,
				soundHit                = [[weapon/cannon/emg_hit]],
				soundStart              = [[weapon/heavy_emg]],
				stages                  = 10,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 550,
			},
			turretriot_WEAPON = {
				name                    = [[Canister Autocannon]],
				accuracy                = 200,
				alphaDecay              = 0.7,
				areaOfEffect            = 96,
				avoidFeature            = false,
				burnblow                = true,
				craterBoost             = 0.15,
				craterMult              = 0.3,

				customparams = {
					light_color = [[0.8 0.76 0.38]],
					light_radius = 180,
					--proximity_priority = 5, -- Don't use this unless required as it causes O(N^2) seperation checks per slow update.
					numprojectiles1 = 3, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "turretriot_secondary",
					--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 95, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = "-1,-1,-1,1,1,1", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					proxy = 1, -- check for nearby units?
				},

				damage                  = {
					default = 66,
				},

				edgeEffectiveness       = 0.5,
				explosionGenerator      = [[custom:NONE]],
				firestarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				intensity               = 0.7,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 380,
				reloadtime              = 5/30,
				rgbColor                = [[1 0.95 0.4]],
				separation              = 1.5,
				soundHit                = [[weapon/clusters/cluster_light]],
				soundHitVolume			= 0.7,
				soundStart              = [[weapon/heavy_emg]],
				soundStartVolume        = 2.5,
				stages                  = 10,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 550,
			},
		},

		featureDefs                   = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[afury_dead.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[debris4x4b.s3o]],
			},

		},
	} 
}
