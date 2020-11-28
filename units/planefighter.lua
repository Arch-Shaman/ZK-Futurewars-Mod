local unitDef = {
	unitname               = [[planefighter]],
	name                   = [[Proliferator]],
	description            = [[Fighter-Bomber]],
	brakerate              = 0.4,
	buildCostMetal         = 150,
	buildPic               = [[planefighter.png]],
	canFly                 = true,
	canGuard               = true,
	canMove                = true,
	canPatrol              = true,
	canSubmerge            = false,
	category               = [[FIXEDWING]],
	collide                = false,
	collisionVolumeOffsets = [[0 0 5]],
	collisionVolumeScales  = [[25 8 40]],
	collisionVolumeType    = [[box]],
	selectionVolumeOffsets = [[0 0 10]],
	selectionVolumeScales  = [[50 50 70]],
	selectionVolumeType    = [[cylZ]],
	corpse                 = [[DEAD]],
	crashDrag              = 0.01,
	cruiseAlt              = 350,

	customParams           = {
		--specialreloadtime = [[850]],
		--boost_speed_mult = 5,
		--boost_accel_mult = 6,
		--boost_duration = 30, -- frames
		--refuelturnradius = [[80]],
		requireammo    = [[1]],
		fighter_pullup_dist = 300,

		midposoffset   = [[0 3 0]],
		modelradius    = [[5]],
		refuelturnradius = [[80]],
	},

	explodeAs              = [[GUNSHIPEX]],
	fireState              = 2,
	floater                = true,
	footprintX             = 2,
	footprintZ             = 2,
	frontToSpeed           = 0,
	iconType               = [[fighter]],
	idleAutoHeal           = 5,
	idleTime               = 1800,
	maneuverleashlength    = [[1280]],
	maxAcc                 = 0.5,
	maxDamage              = 300,
	maxRudder              = 0.007,
	maxVelocity            = 10,
	minCloakDistance       = 75,
	mygravity              = 1,
	noAutoFire             = false,
	noChaseCategory        = [[TERRAFORM SATELLITE SUB LAND SINK TURRET SHIP SWIM FLOAT HOVER]],
	objectName             = [[fighter.s3o]],
	script                 = [[planefighter.lua]],
	selfDestructAs         = [[GUNSHIPEX]],

	sfxtypes               = {

		explosiongenerators = {
			[[custom:MUZZLE_ORANGE]],
			[[custom:FF_PUFF]],
			[[custom:BEAMWEAPON_MUZZLE_RED]],
			[[custom:FLAMER]],
		},

	},
	sightDistance          = 520,
	speedToFront           = 0,
	turnRadius             = 150,
	turnRate               = 839,

	weapons                = {
		{
			def                = [[MISSILE_AA]],
			badTargetCategory  = [[GUNSHIP]],
			onlyTargetCategory = [[FIXEDWING GUNSHIP]],
			maxAngleDif        = 120,
		},

		{
			def                = [[MISSILE_AG]],
			badTargetCategory  = [[GUNSHIP]],
			onlyTargetCategory = [[LAND SINK TURRET SHIP SWIM FLOAT HOVER SINK SUB]],
			maxAngleDif        = 120,
		},
	},

	weaponDefs             = {
		CANNON = {
			name                    = [[Main Cannon]],
			alphaDecay              = 0.1,
			areaOfEffect            = 8,
			burst                   = 6,
			burstrate               = 0.03333334,
			projectiles = 4,
			colormap                = [[1 0.95 0.4 1   1 0.95 0.4 1    0 0 0 0.01    1 0.7 0.2 1]],
			craterBoost             = 0,
			craterMult              = 0,

			customParams        = {
				light_camera_height = 1200,
				light_color = [[0.8 0.76 0.38]],
				light_radius = 120,
			},

			damage                  = {
				default = 4,
				subs    = 0.25,
			},

			explosionGenerator      = [[custom:FLASHPLOSION]],
			impactOnly              = true,
			impulseBoost            = 0,
			impulseFactor           = 0.4,
			intensity               = 0.7,
			interceptedByShieldType = 1,
			noGap                   = false,
			noSelfDamage            = true,
			range                   = 185,
			reloadtime              = 0.3,
			rgbColor                = [[1 0.95 0.4]],
			separation              = 1.5,
			size                    = 1.75,
			sizeDecay               = 0,
			soundStart              = [[weapon/brawler_emg_v2]],
			soundStartVolume        = 4,
			sprayAngle              = 1180,
			stages                  = 10,
			tolerance               = 5000,
			turret                  = true,
			weaponType              = [[Cannon]],
			weaponVelocity          = 500,
		},
		AG = {
			name                    = [[Plasma Submunition]],
			accuracy                = 180,
			areaOfEffect            = 96,
			avoidFeature            = false,
			avoidGround             = false,
			craterBoost             = 1,
			craterMult              = 2,

			customParams            = {
				burst = Shared.BURST_RELIABLE,
				isFlak = 3,
				flaktime = 8,
				reaim_time = 8, -- COB
				light_color = [[1.4 0.8 0.3]],
			},

			damage                  = {
				default = 55,
			},
			groundbounce = false,
			--bounceslip = 0.25,
			--bouncerebound = 0.1,
			--numbounce = 10,
			edgeEffectiveness       = 0.5,
			explosionGenerator      = [[custom:DOT_Pillager_Explo]],
			impulseBoost            = 0,
			impulseFactor           = 0.4,
			interceptedByShieldType = 1,
			myGravity               = 0.1,
			noSelfDamage            = true,
			--range                   = 1180,
			reloadtime              = 7,
			soundHit                = [[weapon/cannon/plasma_hit]],
			turret                  = true,
			weaponType              = [[Cannon]],
			weaponVelocity          = 330,
		},

	MISSILE_AG = {
		burst = 2,
		burstRate = 0.5,
		name                    = [[Hurricane Surface Attack Missile]],
		areaOfEffect            = 96,
		avoidFriendly           = true,
		canattackground         = true,
		cegTag                  = [[missiletrailblue]],
		collideFriendly         = false,
		craterBoost             = 1,
		craterMult              = 2,
		--cylinderTargeting       = 6,

		customParams        	  = {
			burst = Shared.BURST_RELIABLE,
			light_color = [[0.5 0.6 0.6]],
			reaim_time = 60, -- Fast update not required (maybe dangerous)
			--CAS--
			numprojectiles = 3, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
			projectile = "planefighter_ag",
			--spreadradius = 6, -- used in clusters. OPTIONAL. Default: 100.
			clustervec = "randomxz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
			use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
			spawndist = 140, -- at what distance should we spawn the projectile(s)? REQUIRED.
			timeoutspawn = 0, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
			vradius = 6, -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
			--useheight = 1,
			damage_vs_shield = [[165]],
			--groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
			--proxy = 1, -- check for nearby units?
			--proxydist = 100, -- how far to check for units? Default: spawndist
		},

		damage                  = {
			default = 100,
		},

		edgeEffectiveness		= 0.2,
		explosionGenerator      = [[custom:WEAPEXP_PUFF]],
		fireStarter             = 70,
		flightTime              = 7,
		impulseBoost            = 0,
		impulseFactor           = 0.4,
		interceptedByShieldType = 2,
		metalpershot            = 0,
		model                   = [[wep_m_avalanche.s3o]],
		noSelfDamage            = true,
		range                   = 700,
		reloadtime              = 5.2,
		smokeTrail              = true,
		soundHit                = [[weapon/missile/sabot_fire]],
		soundStart              = [[weapon/missile/large_missile_fire]],
		startVelocity           = 100,
		texture2                = [[darksmoketrail]],
		tolerance               = 22000,
		tracks                  = true,
		turnRate                = 40000,
		weaponAcceleration      = 200,
		weaponType              = [[MissileLauncher]],
		weaponVelocity          = 350,
    },

	AA = {
		burst = 2,
		burstRate = 0.5,
		name                    = [[ATA Sidewinder]],
		areaOfEffect            = 96,
		avoidFriendly           = true,
		canattackground         = false,
		cegTag                  = [[missiletrailblue]],
		collideFriendly         = false,
		craterBoost             = 1,
		craterMult              = 2,
		--cylinderTargeting       = 6,

		customParams        	  = {
			burst = Shared.BURST_RELIABLE,
			isaa = [[1]],
			light_color = [[0.5 0.6 0.6]],
			reaim_time = 60, -- Fast update not required (maybe dangerous)
			--groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
			--proxy = 1, -- check for nearby units?
			--proxydist = 100, -- how far to check for units? Default: spawndist
			--damage_vs_shield = [[475]],
		},

		damage                  = {
			default = 2.5,
			planes  = 25,
			subs    = 2.5/8,
		},

		explosionGenerator      = [[custom:WEAPEXP_PUFF]],
		fireStarter             = 70,
		flightTime              = 7,
		impulseBoost            = 0,
		impulseFactor           = 0.4,
		interceptedByShieldType = 2,
		metalpershot            = 0,
		model                   = [[wep_m_avalanche.s3o]],
		noSelfDamage            = true,
		range                   = 700,
		reloadtime              = 5.2,
		smokeTrail              = true,
		soundHit                = [[weapon/missile/rocket_hit]],
		soundStart               = [[weapon/missile/sidewinder]],
		startVelocity           = 100,
		texture2                = [[AAsmoketrail]],
		tolerance               = 22000,
		tracks                  = true,
		turnRate                = 10000,
		weaponAcceleration      = 200,
		weaponType              = [[MissileLauncher]],
		weaponVelocity          = 550,
    },
	
    MISSILE_AA = {
		burst = 2,
		burstRate = 0.5,
		name                    = [[ATA Sidewinder]],
		areaOfEffect            = 96,
		avoidFriendly           = true,
		canattackground         = false,
		cegTag                  = [[missiletrailblue]],
		collideFriendly         = false,
		craterBoost             = 1,
		craterMult              = 2,
		--cylinderTargeting       = 6,

		customParams        	  = {
			burst = Shared.BURST_RELIABLE,
			isaa = [[1]],
			light_color = [[0.5 0.6 0.6]],
			reaim_time = 60, -- Fast update not required (maybe dangerous)
			--CAS--
			numprojectiles = 4, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
			projectile = "proliferator_aa",
			spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
			clustervec = "evenx", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
			use2ddist = 1, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
			spawndist = 870, -- at what distance should we spawn the projectile(s)? REQUIRED.
			timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
			vradius = 5, -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
			--groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
			--proxy = 1, -- check for nearby units?
			--proxydist = 100, -- how far to check for units? Default: spawndist
			--damage_vs_shield = [[475]],
		},

		damage                  = {
			default = 135,
			planes  = 135,
			subs    = 135,
		},

		explosionGenerator      = [[custom:WEAPEXP_PUFF]],
		fireStarter             = 70,
		flightTime              = 7,
		impulseBoost            = 0,
		impulseFactor           = 0.4,
		interceptedByShieldType = 2,
		metalpershot            = 0,
		model                   = [[wep_m_avalanche.s3o]],
		noSelfDamage            = true,
		range                   = 700,
		reloadtime              = 5.2,
		smokeTrail              = true,
		soundHit                = [[weapon/missile/rocket_hit]],
		soundStart               = [[weapon/missile/sidewinder]],
		startVelocity           = 100,
		texture2                = [[AAsmoketrail]],
		tolerance               = 22000,
		tracks                  = true,
		turnRate                = 40000,
		weaponAcceleration      = 200,
		weaponType              = [[MissileLauncher]],
		weaponVelocity          = 550,
    },

  },


	featureDefs            = {

		DEAD  = {
			blocking         = true,
			featureDead      = [[HEAP]],
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[fighter_dead.s3o]],
		},


		HEAP  = {
		  blocking         = false,
		  footprintX       = 2,
		  footprintZ       = 2,
		  object           = [[debris2x2c.s3o]],
		},

	},

}

return { planefighter = unitDef }