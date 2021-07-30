return {  tankraid = {
  unitname            = [[tankraid]],
  name                = [[Kodachi]],
  description         = [[Raider Tank]],
  acceleration        = 0.725,
  brakeRate           = 1.45,
  buildCostMetal      = 180,
  builder             = false,
  buildPic            = [[tankraid.png]],
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  category            = [[LAND]],
  collisionVolumeOffsets = [[0 0 0]],
  collisionVolumeScales  = [[34 26 34]],
  collisionVolumeType    = [[ellipsoid]],
  selectionVolumeOffsets = [[0 0 0]],
  selectionVolumeScales  = [[42 42 42]],
  selectionVolumeType    = [[ellipsoid]],
  corpse              = [[DEAD]],

  customParams        = {
    fireproof      = [[1]],
    specialreloadtime = [[850]],
    modelradius       = [[20]],
    aimposoffset      = [[0 5 0]],
    selection_scale   = 0.85,
    aim_lookahead     = 180,
    percieved_range   = 270, -- How much range enemy units think Kodachi has
  },

  explodeAs           = [[BIG_UNITEX]],
  footprintX          = 3,
  footprintZ          = 3,
  highTrajectory      = 0,
  iconType            = [[tankscout]],
  idleAutoHeal        = 5,
  idleTime            = 300,
  leaveTracks         = true,
  maxDamage           = 670,
  maxSlope            = 18,
  maxVelocity         = 4.7,
  maxWaterDepth       = 22,
  minCloakDistance    = 75,
  movementClass       = [[TANK3]],
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE SUB]],
  objectName          = [[logkoda.s3o]],
  script              = [[tankraid.lua]],
  selfDestructAs      = [[BIG_UNITEX]],
  sightDistance       = 600,
  trackOffset         = 6,
  trackStrength       = 5,
  trackStretch        = 1,
  trackType           = [[StdTank]],
  trackWidth          = 30,
  turninplace         = 0,
  turnRate            = 720,
  workerTime          = 0,
  
  explosiongenerators = {
    [[custom:flamer]],
  },

  weapons             = {

    {
      def                = [[NAPALM_SPRAYER]],
      badTargetCategory  = [[GUNSHIP]],
      onlyTargetCategory = [[LAND SINK TURRET SHIP SWIM FLOAT HOVER GUNSHIP]],
    },
    {
      def                = [[NAPALM_BOOST]],
      badTargetCategory  = [[]],
      onlyTargetCategory = [[]],
    },
  
    --{
    --  def                = [[BOGUS_FAKE_NAPALM_BOMBLET]],
    --  badTargetCategory  = [[GUNSHIP]],
    --  onlyTargetCategory = [[]],
    --},

  },
  weaponDefs             = {
  
    NAPALM_SPRAYER = {
      name                    = [[Napalm Machine Gun]],
      accuracy                = 500,
      areaOfEffect            = 128,
      avoidFeature            = false,
      craterBoost             = 1,
      craterMult              = 2,
      cegTag                  = [[flamer]],
    
      customParams              = {
        setunitsonfire = "1",
        
		sweepfire = 1,
		sweepfire_maxangle = 15,
		sweepfire_step = 3,
		sweepfire_maxrangemult = 0.98,
		
        stats_custom_tooltip_1 = " - Slowdown while Firing:",
        stats_custom_tooltip_entry_1 = "60%",
      },
      
      damage                  = {
        default = 12,
      },
    
      explosionGenerator      = [[custom:napalm_phoenix]],
      firestarter             = 180,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      myGravity               = 0.55,
      --projectiles             = 10,
      range                   = 240,
      reloadtime              = 0.133,
      rgbColor                = [[1 0.5 0.2]],
      size                    = 5,
      soundHit                = [[weapon/cannon/wolverine_hit]],
      soundStart              = [[weapon/cannon/wolverine_fire]],
      soundStartVolume        = 3.2,
      sprayangle              = 2500,
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 400,
    },
    NAPALM_BOOST = {
      name                    = [[Afterburner Overload]],
      accuracy                = 0,
      areaOfEffect            = 80,
      avoidFeature            = false,
      burst                   = 50,
      burstrate               = 0.1,
      canattackground         = false,
      craterBoost             = 1,
      craterMult              = 2,
      cegTag                  = [[flamer]],
    
      customParams              = {
        setunitsonfire = "1",
        
        area_damage = 1,
        area_damage_radius = 80,
        area_damage_dps = 120,
        area_damage_duration = 16,

        --lups_heat_fx = [[firewalker]],
        light_camera_height = 2500,
        light_color = [[0.25 0.13 0.05]],
        light_radius = 460,
        
        stats_custom_tooltip_1 = " - Health Cost per Usage:",
        stats_custom_tooltip_entry_1 = "150 hp",
        stats_custom_tooltip_2 = " - Mininium Health to remain Active:",
        stats_custom_tooltip_entry_2 = "100 hp",
      },
      
      damage                  = {
        default = 0,
      },
    
      explosionGenerator      = [[custom:napalm_firewalker_small]],
      firestarter             = 180,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      myGravity               = 0,
      noSelfDamage            = true,
      --projectiles             = 10,
      range                   = 0,
      reloadtime              = 30,
      rgbColor                = [[1 0.5 0.2]],
      size                    = 5,
      --soundHit                = [[weapon/cannon/wolverine_hit]],
      soundStart              = [[weapon/cannon/wolverine_fire]],
      soundStartVolume        = 3.2,
      sprayangle              = 0,
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 100,
    },
    
  },


  featureDefs         = {

    DEAD = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 2,
      footprintZ       = 2,
      object           = [[logkoda_dead.s3o]],
    },


    HEAP = {
      blocking         = false,
      footprintX       = 2,
      footprintZ       = 2,
      object           = [[debris2x2c.s3o]],
    },

  },
}  }
