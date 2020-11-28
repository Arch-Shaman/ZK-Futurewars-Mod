return { cloakskirm = {
  unitname               = [[cloakskirm]],
  name                   = [[Ronin]],
  description            = [[Skirmisher Bot (Direct-Fire)]],
  acceleration           = 0.9,
  brakeRate              = 1.2,
  buildCostMetal         = 90,
  buildPic               = [[cloakskirm.png]],
  canGuard               = true,
  canMove                = true,
  canPatrol              = true,
  category               = [[LAND]],
  collisionVolumeOffsets = [[0 -5 0]],
  collisionVolumeScales  = [[26 39 26]],
  collisionVolumeType    = [[CylY]],
  corpse                 = [[DEAD]],

  customParams           = {
    modelradius    = [[18]],
    midposoffset   = [[0 6 0]],
    --reload_move_penalty = 0.8,
    cus_noflashlight = 1,
  },

  explodeAs              = [[BIG_UNITEX]],
  footprintX             = 2,
  footprintZ             = 2,
  iconType               = [[kbotskirm]],
  idleAutoHeal           = 5,
  idleTime               = 1800,
  leaveTracks            = true,
  maxDamage              = 420,
  maxSlope               = 36,
  maxVelocity            = 2.3,
  maxWaterDepth          = 20,
  minCloakDistance       = 75,
  movementClass          = [[KBOT2]],
  noChaseCategory        = [[TERRAFORM FIXEDWING SUB]],
  objectName             = [[sphererock.s3o]],
  script                 = "cloakskirm.lua",
  selfDestructAs         = [[BIG_UNITEX]],

  sfxtypes               = {

    explosiongenerators = {
      [[custom:rockomuzzle]],
    },

  },

  sightDistance          = 523,
  trackOffset            = 0,
  trackStrength          = 8,
  trackStretch           = 0.8,
  trackType              = [[ComTrack]],
  trackWidth             = 16,
  turnRate               = 2040,
  upright                = true,

  weapons                = {

    {
      def                = [[BOT_ROCKET]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
	{
      def                = [[TRACKER]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

  },

  weaponDefs             = {

    BOT_ROCKET = {
      name                    = [[Laser guided Rocket]],
      areaOfEffect            = 48,
      burnblow                = true,
      cegTag                  = [[missiletrailyellow]],
      craterBoost             = 0,
      craterMult              = 0,

      customParams        = {
        burst = Shared.BURST_RELIABLE,

        light_camera_height = 1600,
        light_color = [[0.90 0.65 0.30]],
        light_radius = 250,
        reload_move_mod_time = 3,
		tracker = 1,
      },

      damage                  = {
        default = 180,
        subs    = 9,
      },

      fireStarter             = 70,
      flightTime              = 6,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 2,
      model                   = [[wep_m_ajax.s3o]],
      noSelfDamage            = true,
      tolerance               = 65536/4,
      turnRate                = 9000,
      range                   = 520,
      reloadtime              = 3.5,
      smokeTrail              = false,
      soundHit                = [[weapon/missile/sabot_hit]],
      soundHitVolume          = 8,
      soundStart              = [[weapon/missile/sabot_fire]],
      soundStartVolume        = 7,
      startVelocity           = 100,
      tracks                  = true,
      turret                  = true,
      weaponAcceleration      = 500,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 600,
    },
	TRACKER = {
			name                    = [[Missile Target Painter]],
			areaOfEffect            = 20,
			beamTime                = 0.01,
			coreThickness           = 0.5,
			craterBoost             = 0,
			craterMult              = 0,

			customParams            = {
				targeter = 1,
				--burst = Shared.BURST_RELIABLE,
				stats_hide_damage = 1, -- continuous laser
				stats_hide_reload = 1,
				light_color = [[1.25 0 0]],
				light_radius = 120,
			},
			damage                  = {
				default = 0.00,
				planes  = 0.00,
				subs    = 0.00,
			},
			--explosionGenerator      = [[custom:flash1red]],
			fireTolerance           = 8192, -- 45 degrees
			impactOnly              = true,
			impulseBoost            = 0,
			impulseFactor           = 0.4,
			interceptedByShieldType = 0,
			largeBeamLaser          = true,
			laserFlareSize          = 2,
			leadLimit               = 18,
			minIntensity            = 0.01,
			noSelfDamage            = true,
			range                   = 520,
			reloadtime              = 1/15,
			sweapfire = false,
			rgbColor                = [[0.3 0 0]],
			rgbColor2				  = [[0.5 0 0]],
			soundStart              = [[weapon/laser/tracker]],
			--soundHit		= [[trackercompleted.wav]]
			soundStartVolume        = 15,
			texture1                = [[largelaser]],
			--texture2                = [[flare]],
			texture3                = [[flare]],
			texture4                = [[smallflare]],
			thickness               = 2,
			tolerance               = 10000,
			turret                  = true,
			weaponType              = [[BeamLaser]],
			weaponVelocity          = 1500,
		},
  },

  featureDefs            = {

    DEAD  = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 2,
      footprintZ       = 2,
      object           = [[rocko_d.dae]],
    },

    HEAP  = {
      blocking         = false,
      footprintX       = 2,
      footprintZ       = 2,
      object           = [[debris2x2c.s3o]],
    },

  },

} }
