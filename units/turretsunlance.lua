local aimTime = 300 -- in frames

return { turretsunlance = {
  unitname                      = [[turretsunlance]],
  name                          = [[Sunlance]],
  description                   = [[Anti-Tank Turret - Requires 25 Power]],
  activateWhenBuilt             = true,
  buildCostMetal                = 700,
  builder                       = false,
  buildingGroundDecalDecaySpeed = 30,
  buildingGroundDecalSizeX      = 5,
  buildingGroundDecalSizeY      = 5,
  buildingGroundDecalType       = [[turretsunlance_decal.dds]],
  buildPic                      = [[turretsunlance.png]],
  canGuard                      = true,
  category                      = [[FLOAT]],
  corpse                        = [[DEAD]],

  customParams                  = {
    keeptooltip    = [[any string I want]],
    neededlink     = 25,
    pylonrange     = 50,
    specialreloadtime = tostring(aimTime),
  },

  explodeAs                     = [[LARGE_BUILDINGEX]],
  floater                       = true,
  footprintX                    = 4,
  footprintZ                    = 4,
  iconType                      = [[staticassault]],
  levelGround                   = false,
  maxDamage                     = 5600,
  maxSlope                      = 18,
  minCloakDistance              = 150,
  noAutoFire                    = false,
  noChaseCategory               = [[FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER]],
  objectName                    = [[heavyturret.s3o]],
  script                        = [[turretsunlance.lua]],
  selfDestructAs                = [[LARGE_BUILDINGEX]],

  sfxtypes               = {

    explosiongenerators = {
      [[custom:none]],
    },

  },
  sightDistance                 = 660,
  useBuildingGroundDecal        = true,
  workerTime                    = 0,
  yardMap                       = [[oooo oooo oooo oooo]],

  weapons                       = {

    {
      def                = [[PLASMA]],
      badTargetCategory  = [[]],
      onlyTargetCategory = [[SINK TURRET FLOAT]],
    },

  },


  weaponDefs                    = {

    PLASMA = {
      name                    = [[Very Heavy Plasma Cannon]],
      accuracy                = 0,
      areaOfEffect            = 176,
      avoidFeature            = false,
      avoidGround             = false,
      cegTag                  = [[vulcanfx]],
      craterBoost             = 0,
      craterMult              = 0,

      customParams            = {
        restrict_in_widgets = 1,

        gatherradius = [[128]],
        smoothradius = [[96]],
        smoothmult   = [[0.4]],
        
        light_color = [[2.4 1.5 0.6]],
        
        aimdelay = aimTime,
      },
      
      damage                  = {
        default = 2002.4,
        subs    = 100,
      },

      explosionGenerator      = [[custom:lrpc_expl]],
      fireTolerance           = 1820, -- 10 degrees
      impulseBoost            = 0.5,
      impulseFactor           = 0.2,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      range                   = 5600,
      reloadtime              = 0.8,
      soundHit                = [[weapon/cannon/lrpc_hit]],
      soundStart              = [[weapon/cannon/big_begrtha_gun_fire]],
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 880,
    },

  },


  featureDefs                   = {

    DEAD = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 3,
      footprintZ       = 3,
      object           = [[heavyturret_dead.s3o]],
    },


    HEAP = {
      blocking         = false,
      footprintX       = 3,
      footprintZ       = 3,
      object           = [[debris4x4b.s3o]],
    },

  },

} }
