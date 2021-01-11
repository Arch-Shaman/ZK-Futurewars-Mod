return { techdetri = {
  unitname               = [[techdetri]],
  name                   = [[Detriment]],
  description            = [[Ultimate Assault Strider (TechAUmNu)]],
  acceleration           = 0.328,
  activateWhenBuilt      = true,
  autoheal               = 60,
  brakeRate              = 1.435,
  buildCostMetal         = 22000,
  builder                = false,
  buildPic               = [[striderdetriment.png]],
  canGuard               = true,
  canManualFire          = true,
  canMove                = true,
  canPatrol              = true,
  category               = [[LAND]],
  collisionVolumeOffsets = [[0 14 0]],
  collisionVolumeScales  = [[92 158 92]],
  collisionVolumeType    = [[cylY]],
  corpse                 = [[DEAD]],

  customParams           = {
	canjump            = 1,
    jump_range         = 1500,
    jump_height        = 1000,
    jump_speed         = 12,
    jump_delay         = 100,
    jump_reload        = 100,
    jump_from_midair   = 1,
    jump_rotate_midair = 1,
	jump_freefall      = 1,
	--aimposoffset   = [[0 10 0]],
    --midposoffset   = [[0 10 0]],
    modelradius    = [[95]],
    extradrawrange = 925,
  },

  explodeAs              = [[NUCLEAR_MISSILE]],
  footprintX             = 6,
  footprintZ             = 6,
  iconType               = [[krogoth]],
  leaveTracks            = true,
  losEmitHeight          = 100,
  maxDamage              = 100000,
  maxSlope               = 37,
  maxVelocity            = 1.2,
  maxWaterDepth          = 5000,
  minCloakDistance       = 150,
  movementClass          = [[AKBOT4]],
  noAutoFire             = false,
  noChaseCategory        = [[TERRAFORM SATELLITE SUB]],
  objectName             = [[detriment.s3o]],
  radarDistance          = 1200,
  radarEmitHeight        = 12,
  script                 = [[striderdetriment.lua]],
  selfDestructAs         = [[NUCLEAR_MISSILE]],
  selfDestructCountdown  = 10,
  sfxtypes            = {

    explosiongenerators = {
      [[custom:sumosmoke]],
	  [[custom:WARMUZZLE]],
      [[custom:emg_shells_l]],
	  [[custom:extra_large_muzzle_flash_flame]],
	  [[custom:extra_large_muzzle_flash_smoke]],
	  [[custom:extra_large_muzzle_flash_smoke2]],	 
	  [[custom:vindiback_large]],
	  [[custom:RAIDMUZZLE_LARGE]],
    },

  },
  
  sightDistance          = 910,
  sonarDistance          = 910,
  trackOffset            = 0,
  trackStrength          = 8,
  trackStretch           = 0.8,
  trackType              = [[ComTrack]],
  trackWidth             = 60,
  turnRate               = 482,
  upright                = true,

  weapons                = {

    {
      def                = [[PLASMA]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SUB SHIP SWIM FLOAT GUNSHIP HOVER]],
    },	
		
	{
      def                = [[CHAINGUN]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SUB SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
	
	{
      def                = [[PLASMA]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SUB SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
	
	{
      def                = [[CHAINGUN]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SUB SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

    {
      def                = [[ORCONE_ROCKET]],
      onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER]],
    },

    {
      def                = [[TRILASER]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
	
	{
      def                = [[LANDING]],
      badTargetCategory  = [[]],
      mainDir            = [[1 0 0]],
      maxAngleDif        = 0,
      onlyTargetCategory = [[]],
    },
	
	
  },


  weaponDefs             = {
  
	PLASMA  = {
      name                    = [[Heavy Plasma Impulse Cannon]],
      areaOfEffect            = 192,
      avoidFeature            = false,
      burnBlow                = true,
	  --burst                   = 3,
	  --burstRate				  = 1.1,
      craterBoost             = 1.5,
      craterMult              = 4.2,

      customParams            = {
        light_color = [[2.2 1.6 0.9]],
        light_radius = 550,
      },

      damage                  = {
        default = 800,
        subs    = 60,
      },

      edgeEffectiveness       = 0.7,
      explosionGenerator      = [[custom:FLASHBIGBUILDING]],	  
      fireStarter             = 99,
      --fireTolerance		      = 8192,
	  highTrajectory          = 2,
	  impulseBoost            = 4000,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      proximityPriority       = 6,
      range                   = 450,
      reloadtime              = 5,
      soundHit                = [[weapon/cannon/plasma_hit]],
      soundHitVolume          = 15,
      soundStart              = [[weapon/cannon/plasma_fire]],
	  soundStartVolume        = 16,
      --sprayangle              = 768,
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 750,
    },
	
	CHAINGUN = {
      name                    = [[Heavy Chaingun]],
      accuracy                = 1500,
      alphaDecay              = 0.7,
      areaOfEffect            = 120,
      burnblow                = true,
      --burst                   = 1,
      --burstrate               = 0.1,
      craterBoost             = 0.8,
      craterMult              = 2.2,

      customParams        = {
        light_camera_height = 1600,
        light_color = [[0.8 0.76 0.38]],
        light_radius = 450,
      },

      damage                  = {
        default = 300,
        planes  = 300,
        subs    = 2.25,
      },

      edgeEffectiveness       = 0.5,
      explosionGenerator      = [[custom:EMG_HIT_HE]],
      firestarter             = 70,
	  --fireTolerance		      = 8192,
	  highTrajectory          = 2,
      impulseBoost            = 500,
      impulseFactor           = 0.4,
      intensity               = 1.3,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      range                   = 450,
      reloadtime              = 0.2,
      rgbColor                = [[1 0.95 0.4]],
      separation              = 1.5,
      soundHit                = [[weapon/cannon/emg_hit]],
	  soundHitVolume          = 7,
      soundStart              = [[weapon/sd_emgv7]],
	  soundStartVolume        = 7,
	  --sprayangle              = 768,
      stages                  = 10,
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 550,
    },
  

    GAUSS         = {
      name                    = [[Rapid-fire Gauss Battery]],
      alphaDecay              = 0.12,
      areaOfEffect            = 16,
      avoidfeature            = false,
      bouncerebound           = 0.15,
      bounceslip              = 1,
      burst                   = 3,
      burstrate               = 0.6,
      cegTag                  = [[gauss_tag_h]],
      craterBoost             = 0,
      craterMult              = 0,
      
      customParams = {
        single_hit_multi = true,
        reaim_time = 1,
      },

      damage                  = {
        default = 800.1,
        planes  = 800.1,
      },

      explosionGenerator      = [[custom:gauss_hit_h]],
	  fireTolerance		      = 4096,
      groundbounce            = 1,
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      noExplode               = true,
      noSelfDamage            = true,
      numbounce               = 40,
      range                   = 600,
      reloadtime              = 5,
      rgbColor                = [[0.5 1 1]],
      separation              = 0.5,
      size                    = 1,0,
      sizeDecay               = -0.1,
      soundHit                = [[weapon/gauss_hit]],
      soundStart              = [[weapon/gauss_fire]],
      sprayangle              = 800,
      stages                  = 32,
      tolerance               = 4096,
      turret                  = true,
      waterweapon             = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 900,
    },
	
	ORCONE_ROCKET = {
      name                    = [[Snitch Rain]],
      areaOfEffect       	  = 384,     
      avoidFeature            = false,
      avoidFriendly           = false,
      burst                   = 10,
      burstrate               = 0.2,      
      commandFire             = true,
      craterBoost             = 2,
      craterMult              = 5,
      
      customParams            = {
	    burst = Shared.BURST_RELIABLE,        
		
        light_color = [[0.65 0.65 0.18]],
        light_radius = 380,        
		reaim_time = 8, -- COB
      },

      damage                  = {
        default        = 1200,
      },
      
      edgeEffectiveness  = 0.4,
      explosionGenerator = "custom:ROACHPLOSION",
	  explosionSpeed     = 10000,
      fireStarter             = 100,    
      highTrajectory		  = 1,
      impulseBoost            = 2,
      impulseFactor           = 2.8,
      interceptedByShieldType = 2,
      model                   = [[logroach.s3o]], 
	  myGravity               = 0.095,
      noSelfDamage            = true,         
      range                   = 900,
      reloadtime              = 60,
      
      soundHit           	  = "explosion/mini_nuke",
      soundStart              = [[weapon/cannon/pillager_fire]],
      soundStartVolume        = 5,
	  sprayAngle              = 1000,      
      
      
      tolerance               = 512,
      turret                  = true,   
      weaponType              = [[Cannon]],
      weaponVelocity          = 500,
      
    },
    

    AALASER         = {
      name                    = [[Anti-Air High Energy Laser Battery]],
      areaOfEffect            = 12,
      beamDecay               = 0.736,
      beamTime                = 1/30,
      beamttl                 = 15,
      canattackground         = false,
      coreThickness           = 2.5,
      craterBoost             = 0,
      craterMult              = 0,
      cylinderTargeting       = 1,

      customParams              = {
        isaa = [[1]],
        reaim_time = 1,
      },

      damage                  = {
        default = 2.05,
        planes  = 75.5,
        subs    = 1.125,
      },
      
      explosionGenerator      = [[custom:flash_teal7]],
      fireStarter             = 100,
      impactOnly              = true,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      laserFlareSize          = 3.75,
      minIntensity            = 1,
      noSelfDamage            = true,
      range                   = 820,
      reloadtime              = 0.1,
      rgbColor                = [[0 1 1]],
      soundStart              = [[weapon/laser/rapid_laser]],
      thickness               = 3.5,
      tolerance               = 8192,
      turret                  = true,
      weaponType              = [[BeamLaser]],
      weaponVelocity          = 2200,
    },

    DISRUPTOR = {
      name                    = [[Disruptor Pulse Beam]],
      areaOfEffect            = 32,
      beamdecay               = 0.95,
      beamTime                = 1/30,
      beamttl                 = 90,
      coreThickness           = 0.25,
      craterBoost             = 0,
      craterMult              = 0,
  
      customParams            = {
        --timeslow_preset = [[module_disruptorbeam]],
        timeslow_damagefactor = [[2]],
        reaim_time = 1,
      },
      
      damage                  = {
        default = 600,
      },
  
      explosionGenerator      = [[custom:flash2purple]],
      fireStarter             = 30,
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      largeBeamLaser          = true,
      laserFlareSize          = 4.33,
      minIntensity            = 1,
      noSelfDamage            = true,
      range                   = 350,
      reloadtime              = 2,
      rgbColor                = [[0.3 0 0.4]],
      soundStart              = [[weapon/laser/heavy_laser5]],
      soundStartVolume        = 3,
      soundTrigger            = true,
      sweepfire               = false,
      texture1                = [[largelaser]],
      texture2                = [[flare]],
      texture3                = [[flare]],
      texture4                = [[smallflare]],
      thickness               = 18,
      tolerance               = 18000,
      turret                  = true,
      weaponType              = [[BeamLaser]],
      weaponVelocity          = 500,
    },
    
    TRILASER = {
      name                    = [[High-Energy Obliteration Laser]],
      areaOfEffect            = 20,
      beamTime                = 1.2,
      beamttl                 = 1,
      coreThickness           = 0.5,
      craterBoost             = 0,
      craterMult              = 0,
      
      customParams            = {
        light_color = [[0.2 0.8 0.2]],
        reaim_time = 1,
      },
      
      damage                  = {
        default = 2500,
        planes  = 2500,
        subs    = 45,
      },

      explosionGenerator      = [[custom:ataalaser]],
      fireStarter             = 90,
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      largeBeamLaser          = true,
      laserFlareSize          = 10.4,
      leadLimit               = 18,
      minIntensity            = 1,
      noSelfDamage            = true,
      projectiles             = 3,
      range                   = 650,
      reloadtime              = 15,
      rgbColor                = [[0 1 0]],
      scrollSpeed             = 5,
      soundStart              = [[weapon/laser/heavy_laser3]],
      soundStartVolume        = 2,
      sweepfire               = false,
      texture1                = [[largelaser]],
      texture2                = [[flare]],
      texture3                = [[flare]],
      texture4                = [[smallflare]],
      thickness               = 20,
      tileLength              = 300,
      tolerance               = 10000,
      turret                  = true,
      weaponType              = [[BeamLaser]],
      weaponVelocity          = 2250,
    },      	
	
	
	
	LANDING = {
      name                    = [[Detriment Landing]],
      areaOfEffect            = 900,
      canattackground         = false,
      craterBoost             = 10,
      craterMult              = 12,

      damage                  = {
        default = 3000,
      },

      edgeEffectiveness       = 0,
      explosionGenerator      = [[custom:FLASH64]],
      impulseBoost            = 6000,
      impulseFactor           = 25,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      range                   = 5,
      reloadtime              = 13,
      soundHit           	  = "explosion/mini_nuke",
      soundStart              = [[krog_stomp]],
      soundStartVolume        = 10,
      turret                  = false,
      weaponType              = [[Cannon]],
      weaponVelocity          = 5,

      customParams            = {
        hidden = true
      }
    },
	
  },


  featureDefs            = {

    DEAD  = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 6,
      footprintZ       = 6,
      object           = [[Detriment_wreck.s3o]],
    },

    
    HEAP  = {
      blocking         = false,
      footprintX       = 4,
      footprintZ       = 4,
      object           = [[debris4x4b.s3o]],
    },

  },

} }