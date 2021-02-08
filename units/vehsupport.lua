return { vehsupport = {
  unitname               = [[vehsupport]],
  name                   = [[Fractal]],
  description            = [[Deployable HEAT Missile Rover (must stop to fire)]],
  acceleration           = 0.15,
  brakeRate              = 0.3,
  buildCostMetal         = 140,
  builder                = false,
  buildPic               = [[vehsupport.png]],
  canGuard               = true,
  canMove                = true,
  canPatrol              = true,
  category               = [[LAND]],
  collisionVolumeOffsets = [[0 5 0]],
  collisionVolumeScales  = [[26 30 36]],
  collisionVolumeType    = [[box]],
  selectionVolumeOffsets = [[0 0 0]],
  selectionVolumeScales  = [[45 45 45]],
  selectionVolumeType    = [[ellipsoid]],
  corpse                 = [[DEAD]],

  customParams           = {
    modelradius    = [[13]],
    aimposoffset   = [[0 10 0]],
    chase_everything = [[1]], -- Does not get stupidtarget added to noChaseCats
  },

  explodeAs              = [[BIG_UNITEX]],
  footprintX             = 3,
  footprintZ             = 3,
  iconType               = [[vehiclesupport]],
  idleAutoHeal           = 5,
  idleTime               = 1800,
  leaveTracks            = true,
  maxDamage              = 560,
  maxSlope               = 18,
  maxVelocity            = 2.8,
  maxWaterDepth          = 22,
  minCloakDistance       = 75,
  movementClass          = [[TANK3]],
  moveState              = 0,
  noAutoFire             = false,
  noChaseCategory        = [[TERRAFORM SATELLITE SUB]],
  objectName             = [[cormist_512.s3o]],
  script                 = [[vehsupport.lua]],
  pushResistant          = 0,
  selfDestructAs         = [[BIG_UNITEX]],

  sfxtypes               = {

    explosiongenerators = {
      [[custom:SLASHMUZZLE]],
      [[custom:SLASHREARMUZZLE]],
    },

  },
  sightDistance          = 660,
  trackOffset            = -6,
  trackStrength          = 5,
  trackStretch           = 1,
  trackType              = [[StdTank]],
  trackWidth             = 34,
  turninplace            = 0,
  turnRate               = 420,
  workerTime             = 0,

  weapons                = {

    {
      def                = [[CORTRUCK_MISSILE]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
    {
      def                = [[PARTICLEBEAM]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

  },


  weaponDefs             = {

    CORTRUCK_MISSILE = {
      name                    = [[Frostshard HEAT Missiles]],
      areaOfEffect            = 48,
      avoidFeature            = true,
      burst                   = 2,
      burstrate               = 0.166,
      cegTag                  = [[missiletrailgreen]],
      craterBoost             = 0,
      craterMult              = 0,

      customParams        = {
        light_camera_height = 2000,
        light_radius = 200,
		
		
		numprojectiles1 = 8, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile1 = "vehsupport_particlebeam",
		--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
		clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		keepmomentum1 = 20,
		use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		proxy = 1, -- check for nearby units?
		useheight = 0,
		timeoutspawn = 0,
		spawndist = 80, -- at what distance should we spawn the projectile(s)? REQUIRED.
		vradius1 = "0,0,0,0,0,0", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
		groundimpact = 0,
		spawnsfx1 = 2049,
      },

      damage                  = {
        default = 55.02,
      },

      explosionGenerator      = [[custom:FLASH2]],
      fireStarter             = 70,
      flightTime              = 3,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 2,
      model                   = [[wep_m_frostshard.s3o]],
      range                   = 600,
      reloadtime              = 1.633,
      smokeTrail              = true,
      soundHit                = [[explosion/ex_med17]],
      soundStart              = [[weapon/missile/missile_fire11]],
      startVelocity           = 450,
      texture2                = [[lightsmoketrail]],
      tolerance               = 8000,
      tracks                  = true,
      turnRate                = 33000,
      turret                  = true,
      weaponAcceleration      = 109,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 545,
    },
	
	PARTICLEBEAM = {
      name                    = [[HEAT Fragment]],
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
		
		bogus = 1,
      },

      damage                  = {
        default = 34,
      },


      dynDamageExp            = 1,
      dynDamageInverted       = false,
      explosionGenerator      = [[custom:flash1red]],
      fireStarter             = 100,
      impactOnly              = true,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      laserFlareSize          = 7.5,
      minIntensity            = 1,
      range                   = 125,
      reloadtime              = 0.3,
      rgbColor                = [[0.2 1 0.2]],
      sprayAngle              = 5000,
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
      object           = [[cormist_dead_new.s3o]],
    },

    HEAP  = {
      blocking         = false,
      footprintX       = 3,
      footprintZ       = 3,
      object           = [[debris3x3c.s3o]],
    },

  },

} }
