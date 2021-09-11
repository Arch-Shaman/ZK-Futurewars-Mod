return { 
	gunshipkrow = {
		unitname               = [[gunshipkrow]],
		name                   = [[Purifier]],
		description            = [[Flying Battlestation]],
		acceleration           = 0.15,
		activateWhenBuilt      = true,
		airStrafe              = 0,
		bankingAllowed         = false,
		brakeRate              = 0.15,
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
		cruiseAlt              = 250,

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
		maxVelocity            = 4.1,
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
				def                = [[ATA]],
				mainDir            = [[0 0 1]],
				maxAngleDif        = 360,
			},
			--{
				--def                = [[CLUSTERBOMBER]],
				--mainDir            = [[0 0 1]],
				--maxAngleDif        = 360,
			--},
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
				edgeeffectiveness		= 0.4,
				minIntensity            = 0.95,
				customParams        = {
					light_camera_height = 1800,
					light_radius = 160,
					combatrange	= 300,
				},

				damage                  = {
					default = 60.1,
				},

				duration                = 0.1,
				explosionGenerator      = [[custom:beamlaser_hit_emerald]],
				fireStarter             = 50,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				range                   = 620,
				reloadtime              = 1.4,
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
					spawndist = 140, -- at what distance should we spawn the projectile(s)? REQUIRED.
					vradius1 = "-12,0,-12,12,4,12", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 1,
				},
				damage                  = {
					default = 175*3,
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
					default = 175,
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
			ATA = {
				name                    = [[Annihilator Beam]],
				areaOfEffect            = 255,
				beamTime                = 8,
				commandFire             = true,
				coreThickness           = 3,
				craterBoost             = 8,
				craterMult              = 20,
      
				customParams            = {
					light_color = [[1.25 0.8 1.75]],
					light_radius = 480,
				},
				damage                  = {
					default = 40100,
				},
				cameraShake				= 500,
				explosionGenerator      = [[custom:craterpuncher_short]],
				explosionScar           = false,
				fireTolerance           = 8192, -- 45 degrees
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				largeBeamLaser          = true,
				laserFlareSize          = 4.5,
				leadLimit               = 18,
				minIntensity            = 1,
				noSelfDamage            = true,
				range                   = 1000,
				reloadtime              = 30,
				rgbColor                = [[0.25 0 1]],
				soundStart              = [[weapon/laser/heavy_laser6]],
				soundStartVolume        = 45,
				texture1                = [[largelaser]],
				texture2                = [[flare]],
				texture3                = [[flare]],
				texture4                = [[smallflare]],
				thickness               = 33.8747693719086,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 1500,
				waterweapon				= true,
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
