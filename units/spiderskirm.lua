return { spiderskirm = {
  unitname               = [[spiderskirm]],
  name                   = [[Twilight]],
  description            = [[Skirmisher Spider (Indirect Fire)]],
  acceleration           = 0.78,
  brakeRate              = 4.68,
  buildCostMetal         = 340,
  buildPic               = [[spiderskirm.png]],
  canGuard               = true,
  canMove                = true,
  canPatrol              = true,
  category               = [[LAND]],
  corpse                 = [[DEAD]],

  customParams           = {
    midposoffset   = [[0 -5 0]],
  },

  explodeAs              = [[BIG_UNITEX]],
  footprintX             = 3,
  footprintZ             = 3,
  iconType               = [[spiderskirm]],
  idleAutoHeal           = 5,
  idleTime               = 1800,
  leaveTracks            = true,
  maxDamage              = 650,
  maxSlope               = 72,
  maxVelocity            = 1.5,
  maxWaterDepth          = 22,
  minCloakDistance       = 75,
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
      badTargetCategory  = [[FIXEDWING GUNSHIP]],
      onlyTargetCategory = [[LAND SINK TURRET SHIP SWIM FLOAT HOVER FIXEDWING GUNSHIP]],
    },

    {
      def                = [[PARTICLEBEAM]],
      onlyTargetCategory = [[NONE]],
    },

  },

  weaponDefs             = {

    ADV_ROCKET = {
      name                    = [[ASD Rocket Volley]],
      areaOfEffect            = 48,
      burst                   = 3,
      burstrate               = 0.4,
      cegTag                  = [[missiletrailgreen]],
      craterBoost             = 0,
      craterMult              = 0,

      customParams        = {
		numprojectiles1 = 13, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile1 = "spiderskirm_particlebeam",
		--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
		clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		keepmomentum1 = 20,
		use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		proxy = 1, -- check for nearby units?
		useheight = 0,
		timeoutspawn = 0,
		spawndist = 150, -- at what distance should we spawn the projectile(s)? REQUIRED.
		vradius1 = "0,0,0,0,0,0", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
		groundimpact = 0,
		spawnsfx1 = 2049,
		
        light_camera_height = 2500,
        light_color = [[0.90 0.65 0.30]],
        light_radius = 250,
      },

      damage                  = {
        default = 174,
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
      range                   = 590,
      reloadtime              = 6,
      smokeTrail              = true,
      soundHit                = [[explosion/ex_small13]],
      soundStart              = [[weapon/missile/missile_fire4]],
      soundTrigger            = true,
      startVelocity           = 150,
      trajectoryHeight        = 1.7,
      turnRate                = 4000,
      turret                  = true,
      weaponAcceleration      = 150,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 400,
      wobble                  = 9000,
    },
	
	PARTICLEBEAM = {
      name                    = [[Auto Particle Beam]],
      beamDecay               = 0.85,
      beamTime                = 0.1,
      beamttl                 = 45,
      canattackground         = false,
      coreThickness           = 0.5,
      craterBoost             = 0,
      craterMult              = 0,

      customParams            = {
        light_color = [[0.9 0.22 0.22]],
        light_radius = 80,
      },

      damage                  = {
        default = 95.42,
      },


      dynDamageExp            = 1,
	  dynDamageRange          = 300,
      dynDamageInverted       = false,
      explosionGenerator      = [[custom:flash1red]],
      fireStarter             = 100,
      impactOnly              = true,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      laserFlareSize          = 7.5,
      minIntensity            = 1,
      range                   = 225,
      reloadtime              = 0.3,
      rgbColor                = [[0.2 1 0.2]],
      sprayAngle              = 3000,
      soundStart              = [[weapon/laser/mini_laser]],
      soundStartVolume        = 6,
      thickness               = 5,
      tolerance               = 8192,
      turret                  = true,
      weaponType              = [[BeamLaser]],
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

} }
