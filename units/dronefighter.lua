return { dronefighter = {
  unitname               = "dronefighter",
  name                   = "Spicula",
  description            = "Fighter Drone",
  brakerate              = 0.4,
  buildCostMetal         = 100,
  buildPic               = "dronefighter.png",
  canBeAssisted          = false,
  canFly                 = true,
  canGuard               = true,
  canMove                = true,
  canPatrol              = true,
  canSubmerge            = false,
  category               = "FIXEDWING DRONE",
  collide                = false,
  collisionVolumeOffsets = "0 0 5",
  collisionVolumeScales  = "25 8 40",
  collisionVolumeType    = "box",
  crashDrag              = 0.02,
  cruiseAlt              = 250,
  canLand                = false,

  customParams           = {
    bait_level_target      = 1,
    modelradius    = "5",
    refuelturnradius = "80",
    is_drone = 1,
  },

  explodeAs              = "GUNSHIPEX",
  fireState              = 2,
  floater                = true,
  footprintX             = 2,
  footprintZ             = 2,
  frontToSpeed           = 0,
  iconType               = "fighter",
  idleAutoHeal           = 30,
  idleTime               = 90,
  maneuverleashlength    = "400",
  maxAcc                 = 0.7,
  health                 = 1440,
  speed                  = 8,
  maxElevator            = 0.02,
  maxRudder              = 0.006,
  --maxPitch               = 0.1,
  mygravity              = 1,
  noAutoFire             = false,
  noChaseCategory        = "TERRAFORM SUB",
  objectName             = "fighterdrone.dae",
  reclaimable            = false,
  repairable             = false, -- mostly not to waste constructor attention on area-repair; has regen anyway
  script                 = "dronefighter.lua",
  selfDestructAs         = "GUNSHIPEX",

  sfxtypes               = {

    explosiongenerators = {
      "custom:MUZZLE_ORANGE",
      "custom:FF_PUFF",
      "custom:BEAMWEAPON_MUZZLE_RED",
      "custom:FLAMER",
    },

  },
  sightDistance          = 520,
  speedToFront           = 0,
  turnRate               = 9001,
  turnRadius             = 90,

  weapons                = {

    {
      def                = "LASER",
      mainDir            = "0 0 1",
      maxAngleDif        = 90,
      onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
    },
  },

  weaponDefs          = {

    LASER      = {
      name                    = "Rapid-Fire Particle Beam",
      beamDecay               = 0.9,
      beamTime                = 1/30,
      beamttl                 = 10,
      coreThickness           = 0.5,
      craterBoost             = 0,
      craterMult              = 0,
      cylinderTargeting      = 1,

      damage                  = {
        default = 33,
      },

      explosionGenerator      = "custom:BEAMWEAPON_HIT_RED",
      fireStarter             = 100,
      impactOnly              = true,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      laserFlareSize          = 3.25,
      minIntensity            = 1,
      range                   = 650,
      reloadtime              = 0.2,
      rgbColor                = "1 0 0",
      soundStart              = "weapon/laser/mini_laser",
      soundStartVolume        = 4,
      thickness               = 3,
      tolerance               = 8192,
      turret                  = true,
      weaponType              = "BeamLaser",
    },
  },
} }
