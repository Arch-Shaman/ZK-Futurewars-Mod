return { 
	gunshipkrow = {
		unitname               = [[gunshipkrow]],
		name                   = [[Purifier]],
		description            = [[Flying Battlestation]],
		acceleration           = 0.09,
		activateWhenBuilt      = true,
		airStrafe              = 0,
		bankingAllowed         = false,
		brakeRate              = 0.04,
		buildCostMetal         = 6000,
		builder                = false,
		buildPic               = [[gunshipkrow.png]],
		canFly                 = true,
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		canSubmerge            = false,
		category               = [[GUNSHIP]],
		collide                = true,
		collisionVolumeOffsets = [[0 0 5]],
		collisionVolumeScales  = [[86 22 86]],
		collisionVolumeType    = [[cylY]],
		corpse                 = [[DEAD]],
		cruiseAlt              = 400,

		customParams           = {
			modelradius    = [[10]],
		},

		explodeAs              = [[LARGE_BUILDINGEX]],
		floater                = true,
		footprintX             = 5,
		footprintZ             = 5,
		hoverAttack            = true,
		iconType               = [[supergunship]],
		idleAutoHeal           = 200,
		idleTime               = 1800,
		maneuverleashlength    = [[500]],
		maxDamage              = 36000,
		maxVelocity            = 3.5,
		minCloakDistance       = 150,
		noAutoFire             = false,
		noChaseCategory        = [[TERRAFORM FIXEDWING SATELLITE SUB]],
		objectName             = [[krow.s3o]],
		script                 = [[gunshipkrow.lua]],
		selfDestructAs         = [[LARGE_BUILDINGEX]],

		sfxtypes               = {

			explosiongenerators = {
				[[custom:beamweapon_muzzle_green]],
				[[custom:DOT_Pillager_Explo]],
			},

		},
		sightDistance          = 633,
		turnRate               = 250,
		upright                = true,
		workerTime             = 0,
  
		weapons                = {

			{
				def                = [[KROWLASER]],
				mainDir            = [[0.38 0.1 0.2]],
				maxAngleDif        = 180,
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},


			{
				def                = [[KROWLASER]],
				mainDir            = [[-0.38 0.1 0.2]],
				maxAngleDif        = 180,
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

			{
				def                = [[CLUSTERBOMBER]],
				mainDir            = [[0 0 1]],
				maxAngleDif        = 360,
			},

			{
				def                = [[KROWLASER]],
				mainDir            = [[0 0.1 -0.38]],
				maxAngleDif        = 180,
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},

		},
		weaponDefs             = {

			KROWLASER  = {
				name                    = [[High Intensity Scattergun]],
				areaOfEffect            = 30,
				avoidFeature            = false,
				canattackground         = true,
				collideFriendly         = false,
				coreThickness           = 0.8,
				craterBoost             = 0,
				craterMult              = 0,
				projectiles				= 7,
				burst					= 2,
				cylinderTargeting		= 1,
				burstRate				= 10/30,
				sprayangle				= 1390,
				edgeeffectiveness		= 0.05,

				customParams        = {
					light_camera_height = 1800,
					light_radius = 160,
				},

				damage                  = {
					default = 37.8,
				},

				duration                = 0.1,
				explosionGenerator      = [[custom:beamlaser_hit_emerald]],
				fireStarter             = 50,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				range                   = 620,
				reloadtime              = 1.8,
				rgbColor                = [[0.043 0.7 0.274]],
				soundHit                = [[weapon/laser/emerald_hit]],
				soundStart              = [[weapon/laser/emerald_fire]],
				soundStartVolume        = 0.7,
				soundTrigger            = false,
				thickness               = 4.25,
				tolerance               = 10000,
				turret                  = true,
				largebeamlaser			= true,
				texture1                = [[lightlaser]],
				texture2                = [[flare]],
				texture3                = [[flare]],
				beamDecay 				= 0.8,
				beamBurst				= true,
				beamTTL					= 13,
				weaponType              = [[BeamLaser]],
				--weaponVelocity          = 880,
			},
			CLUSTERBOMBER = {
				name                    = [[Heavy Cluster Bomb]],
				accuracy                = 200,
				areaOfEffect            = 128,
				burst                   = 45,
				burstRate               = 0.066, -- real value in script; here for widgets
				commandFire             = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams			= {
					numprojectiles1 = 4, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "gunshipkrow_clusterbomb",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					proxy = 0, -- check for nearby units?
					useheight = 1,
					spawndist = 180, -- at what distance should we spawn the projectile(s)? REQUIRED.
					vradius1 = "-12,0,-12,12,4,12", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 1,
				},
				damage                  = {
					default = 250*4,
				},

				explosionGenerator      = [[custom:WEAPEXP_PUFF]],
				fireStarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				interceptedByShieldType = 2,
				model                   = [[hovermissile.s3o]],
				range                   = 200,
				reloadtime              = 30, -- if you change this redo the value in oneclick_weapon_defs EMPIRICALLY
				smokeTrail              = true,
				soundHit                = [[weapon/cannon/cannonfire_001]],
				soundHitVolume          = 8,
				soundStart              = [[weapon/cannon/mini_cannon]],
				soundStartVolume        = 2,
				sprayangle              = 1800,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 200,
			},
			CLUSTERBOMB = {
				name                    = [[Cluster Bomb]],
				accuracy                = 200,
				areaOfEffect            = 128,
				burst                   = 75,
				burstRate               = 0.066, -- real value in script; here for widgets
				commandFire             = true,
				craterBoost             = 10,
				craterMult              = 3,

				damage                  = {
					default = 250,
				},

				explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],
				fireStarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				interceptedByShieldType = 2,
				model                   = [[wep_b_fabby.s3o]],
				range                   = 200,
				reloadtime              = 30, -- if you change this redo the value in oneclick_weapon_defs EMPIRICALLY
				smokeTrail              = true,
				soundHit                = [[explosion/ex_med6]],
				soundHitVolume          = 8,
				soundStart              = [[weapon/cannon/mini_cannon]],
				soundStartVolume        = 2,
				sprayangle              = 14400,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 400,
			},
		},


		featureDefs            = {

			DEAD  = {
				blocking         = true,
				collisionVolumeOffsets = [[0 0 0]],
				collisionVolumeScales  = [[80 30 80]],
				collisionVolumeType    = [[ellipsoid]],
				featureDead      = [[HEAP]],
				footprintX       = 5,
				footprintZ       = 5,
				object           = [[krow_dead.s3o]],
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 4,
				footprintZ       = 4,
				object           = [[debris4x4a.s3o]],
			},
		},
	} 
}
