return { gunshipassault = {
  unitname            = [[gunshipassault]],
  name                = [[Revenant]],
  description         = [[Heavy Canister Support Gunship]],
  acceleration        = 0.15,
  brakeRate           = 0.13,
  buildCostMetal      = 1000,
  builder             = false,
  buildPic            = [[gunshipassault.png]],
  canFly              = true,
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  canSubmerge         = false,
  category            = [[GUNSHIP]],
  collide             = true,
  collisionVolumeOffsets = [[0 0 0]],
  collisionVolumeScales  = [[50 15 50]],
  collisionVolumeType    = [[cylY]],
  corpse              = [[DEAD]],
  cruiseAlt           = 300,

  customParams        = {
    airstrafecontrol = [[1]],
    modelradius    = [[10]],
  },

  explodeAs           = [[GUNSHIPEX]],
  floater             = true,
  footprintX          = 3,
  footprintZ          = 3,
  hoverAttack         = true,
  iconType            = [[heavygunshipassault]],
  maxDamage           = 7250,
  maxVelocity         = 5,
  minCloakDistance    = 75,
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE GUNSHIP SUB]],
  objectName          = [[Black_Dawn.s3o]],
  script              = [[gunshipassault.lua]],
  selfDestructAs      = [[GUNSHIPEX]],
  sightDistance       = 585,
  turnRate            = 1000,

  weapons             = {

    {
      def                = [[VTOL_SALVO]],
      mainDir            = [[0 -0.35 1]],
      maxAngleDif        = 90,
      badTargetCategory  = [[FIXEDWING GUNSHIP]],
      onlyTargetCategory = [[SWIM LAND SHIP SINK TURRET FLOAT GUNSHIP FIXEDWING HOVER]],
    },

  },


  weaponDefs          = {
	secondary = {
		name                    = [[Heavy Pulse MG]],
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
			flaktime = 1/30,
		},
		
		damage                  = {
			default = 45,
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
    VTOL_SALVO = {
      name                    = [[Heavy Fragmentation Rocket]],
      areaOfEffect            = 96,
      avoidFeature            = false,
      avoidFriendly           = false,
      burst                   = 4,
      burstrate               = 22/30,
      cegTag                  = [[BANISHERTRAIL]],
      collideFriendly         = false,
      craterBoost             = 0.123,
      craterMult              = 0.246,

      customparams = {
        burst = Shared.BURST_UNRELIABLE,
		numprojectiles = 6, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile = "vehriot_secondary",
		--spreadradius = 4, -- used in clusters. OPTIONAL. Default: 100.
		clustervec = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		spawndist = 95, -- at what distance should we spawn the projectile(s)? REQUIRED.
		timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
		vradius = "-4,-8,-4,4,-3,4", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
		groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
		proxy = 1, -- check for nearby units?
		proxydist = 135, -- how far to check for units? Default: spawndist
        light_camera_height = 2500,
        light_color = [[0.55 0.27 0.05]],
        light_radius = 360,
		instantcruise = [[1]],
		cruisedist = 100,
        combatrange = 480,
		useheight = 1,
      },

      damage                  = {
        default = 45*6,
      },

      dance                   = 30,
      edgeEffectiveness       = 0.5,
      explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],
      fireStarter             = 70,
      flightTime              = 5,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 2,
      model                   = [[hobbes.s3o]],
      noSelfDamage            = true,
      range                   = 480,
      reloadtime              = 6,
      smokeTrail              = false,
      soundHit                = [[weapon/missile/cluster_light]],
      soundStart              = [[weapon/missile/heavy_missile_fire]],
      startVelocity           = 150,
      tolerance               = 15000,
      tracks                  = true,
      turnRate                = 2800,
      turret                  = true,
      weaponAcceleration      = 100,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 650,
    },

  },


  featureDefs         = {

    DEAD  = {
      blocking         = true,
      collisionVolumeScales  = [[65 20 65]],
      collisionVolumeType    = [[CylY]],
      featureDead      = [[HEAP]],
      footprintX       = 2,
      footprintZ       = 2,
      object           = [[blackdawn_d.dae]],
    },


    HEAP  = {
      blocking         = false,
      footprintX       = 2,
      footprintZ       = 2,
      object           = [[debris2x2c.s3o]],
    },

  },

} }
