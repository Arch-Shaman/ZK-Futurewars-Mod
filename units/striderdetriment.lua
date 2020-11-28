return { striderdetriment = {
  unitname               = [[striderdetriment]],
  name                   = [[Detriment]],
  description            = [[Ultimate Assault Strider]],
  acceleration           = 0.328,
  activateWhenBuilt      = true,
  autoheal               = 125,
  brakeRate              = 1.435,
  buildCostMetal         = 20000,
  builder                = false,
  buildPic               = [[striderdetriment.png]],
  canGuard               = true,
  --canManualFire          = true,
  canMove                = true,
  canPatrol              = true,
  category               = [[LAND]],
  collisionVolumeOffsets = [[0 14 0]],
  collisionVolumeScales  = [[92 158 92]],
  collisionVolumeType    = [[cylY]],
  corpse                 = [[DEAD]],

  customParams           = {
    modelradius    = [[95]],
    extradrawrange = 925,
  },
  explodeAs              = [[NUCLEAR_MISSILE]],
  footprintX             = 6,
  footprintZ             = 6,
  iconType               = [[krogoth]],
  leaveTracks            = true,
  losEmitHeight          = 100,
  maxDamage              = 160000,
  maxSlope               = 37,
  maxVelocity            = 1.0,
  maxWaterDepth          = 5000,
  minCloakDistance       = 150,
  movementClass          = [[AKBOT4]],
  noAutoFire             = false,
  noChaseCategory        = [[TERRAFORM SATELLITE SUB]],
  objectName             = [[detriment.s3o]],
  script                 = [[striderdetriment.lua]],
  selfDestructAs         = [[NUCLEAR_MISSILE]],
  selfDestructCountdown  = 10,
  sightDistance          = 1600,
  sonarDistance          = 1600,
  trackOffset            = 0,
  trackStrength          = 8,
  trackStretch           = 0.8,
  trackType              = [[ComTrack]],
  trackWidth             = 60,
  turnRate               = 482,
  upright                = true,

  weapons                = {

    {
      def                = [[GAUSS]],
      onlyTargetCategory = [[LAND SINK TURRET SUB SHIP SWIM FLOAT HOVER]],
    },

    {
      def                = [[AALASER]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING GUNSHIP]],
    },

  },


  weaponDefs             = {

	SECONDARY = {
		name                    = [[Fragmentation]],
		areaOfEffect            = 108,
		craterBoost             = 20,
		craterMult              = 4,
		burnblow				= true,
		customParams            = {
			burst = Shared.BURST_RELIABLE,
			force_ignore_ground = [[1]],
			light_color = [[3 2.33 1.5]],
			light_radius = 150,
		},
      
			damage                  = {
				default = 720.1,
			},
			edgeEffectiveness = 0.4,
			explosionGenerator      = [[custom:TESS]],
			impulseBoost            = 0,
			impulseFactor           = 2,
			interceptedByShieldType = 1,
			noSelfDamage            = true,
			range                   = 450,
			reloadtime              = 3,
			soundHit                = [[explosion/ex_large9.wav]],
			--soundStart              = [[weapon/cannon/rhino]],
			turret                  = true,
			weaponType              = [[Cannon]],
			weaponVelocity          = 470,
			waterWeapon 			= true,
	},

    GAUSS         = {
      name                    = [[Decimator Cannon Barrage]],
      alphaDecay              = 0.12,
      areaOfEffect            = 1,
      avoidfeature            = false,
      bouncerebound           = 0.15,
      bounceslip              = 1,
      burst                   = 6,
      burstrate               = 1.2,
      cegTag                  = [[vulcanfx]],
      craterBoost             = 0,
      craterMult              = 0,
      
      customParams = {
        reaim_time = 1,	
		smoothradius     = [[120]],
        smoothmult       = [[0.8]],
		muzzleEffectFire = [[custom:RAIDMUZZLE]],
		numprojectiles = 7, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile = "striderdetriment_secondary",
		--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
		clustervec = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		proxy = 1, -- check for nearby units?
		proxydist = 200, -- how far to check for units? Default: spawndist
		spawndist = 200, -- at what distance should we spawn the projectile(s)? REQUIRED.
		vradius = "-6,-4,-6,2,3,6", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
      },

      damage                  = {
        default = 720.1*7,
      },

      explosionGenerator      = [[custom:100rlexplode]],
      groundbounce            = 1,
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 20,
      interceptedByShieldType = 0,
      noSelfDamage            = true,
      range                   = 1600,
      reloadtime              = 9,
      separation              = 0.5,
      size                    = 0.8,
      sizeDecay               = -0.1,
      soundHit                = [[weapon/cannon/outlaw_gun]],
      soundStart              = [[weapon/cannon/cannon_fire9]],
      sprayangle              = 800,
      stages                  = 32,
      tolerance               = 4096,
      turret                  = true,
      waterweapon             = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 900,
    },

    AALASER         = {
      name                    = [[Flak Disperser]],
	  sprayangle			  = 2200,
      areaOfEffect            = 128,
      burnblow                = true,
	  burst					  = 2,
	  burstrate				  = 0.5,
	  projectiles			  = 6,
      canattackground         = false,
      cegTag                  = [[flak_trail]],
      craterBoost             = 0,
      craterMult              = 0,
      cylinderTargeting       = 1,

      customParams              = {
        isaa = [[1]],
        light_radius = 0,
		isFlak = 1,
      },

      damage                  = {
        default = 20.2,
        planes  = 200,
        subs    = 10.1,
      },

      edgeEffectiveness       = 0.5,
      explosionGenerator      = [[custom:flakplosion]],
      impulseBoost            = 0,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      range                   = 1900,
      reloadtime              = 1.233,
      size                    = 0.01,
      soundHitVolume	      = 0.3,
      soundHit                = [[weapon/flak_hit2]],
      soundStart              = [[weapon/flak_fire]],
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 2000,
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