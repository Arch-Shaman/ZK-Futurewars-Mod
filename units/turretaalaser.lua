return { turretaalaser = {
  unitname                      = [[turretaalaser]],
  name                          = [[Razor]],
  description                   = [[Hardened Anti-Air Laser]],
  buildCostMetal                = 260,
  builder                       = false,
  buildingGroundDecalDecaySpeed = 30,
  buildingGroundDecalSizeX      = 6,
  buildingGroundDecalSizeY      = 6,
  buildingGroundDecalType       = [[turretaalaser_aoplane.dds]],
  buildPic                      = [[turretaalaser.png]],
  category                      = [[FLOAT UNARMED STUPIDTARGET]],
  collisionVolumeOffsets        = [[0 0 0]],
  collisionVolumeScales         = [[50 36 50]],
  collisionVolumeType            = [[CylY]],
  corpse                        = [[DEAD]],

  customParams                  = {
  },

  damageModifier                = 0.25,
  explodeAs                     = [[SMALL_BUILDINGEX]],
  floater                       = true,
  footprintX                    = 3,
  footprintZ                    = 3,
  iconType                      = [[defenseaa]],
  levelGround                   = false,
  maxDamage                     = 3000,
  maxSlope                      = 18,
  minCloakDistance              = 150,
  noAutoFire                    = false,
  noChaseCategory               = [[FIXEDWING LAND SINK TURRET SHIP SATELLITE SWIM GUNSHIP FLOAT SUB HOVER]],
  objectName                    = [[aapopup.dae]],
  selfDestructAs                = [[SMALL_BUILDINGEX]],

  sfxtypes                      = {

    explosiongenerators = {
      [[custom:BEAMWEAPON_MUZZLE_RED]],
    },

  },

  script                        = [[turretaalaser.lua]],
  sightDistance                 = 660,
  useBuildingGroundDecal        = true,
  workerTime                    = 0,
  yardMap                       = [[ooooooooo]],

  weapons                       = {

    {
      def                = [[AAGUN]],
      --badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING GUNSHIP]],
    },

  },


  weaponDefs                    = {

    AAGUN  = {
				name                    = [[High Intensity Micropulse Laser]],
				areaOfEffect            = 8,
				accuracy				= 250,
				coreThickness           = 0.5,
				beamTime                = 1/30,
				craterBoost             = 0,
				craterMult              = 0,
				
				customParams        = {
					light_camera_height = 1200,
					light_radius = 20,
				},
      
				damage                  = {
					default = 50.1,
				},

				duration                = 2/30,
				explosionGenerator      = [[custom:beamweapon_hit_orange]],
				fireStarter             = 50,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				leadLimit               = 0,
				noSelfDamage            = true,
				range                   = 1000,
				reloadtime              = 6/30,
				rgbColor                = [[1 0.40059 0]],
				soundStart              = [[weapon/laser/heavy_pulser]],
				soundstartvolume	    = 135,
				thickness               = 2.55,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 880,
			},

  },


  featureDefs                   = {

    DEAD  = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 3,
      footprintZ       = 3,
      object           = [[aapopup_dead.s3o]],
    },

    HEAP  = {
      blocking         = false,
      footprintX       = 3,
      footprintZ       = 3,
      object           = [[debris3x3a.s3o]],
    },

  },

} }
