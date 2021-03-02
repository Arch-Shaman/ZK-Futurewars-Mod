return { strideremp = {
    unitname            = [[strideremp]],
    name                = [[Blackout]],
    description         = [[EMP Discharge Generator]],
    acceleration        = 0.141,
    brakeRate           = 0.52,
    buildCostMetal      = 2200,
    builder             = false,
    buildPic            = [[tankheavyassault.png]],
    canGuard            = true,
    canMove             = true,
    canPatrol           = true,
    category            = [[LAND]],
    corpse              = [[DEAD]],

    customParams        = {
    },

    explodeAs           = [[BIG_UNIT]],
    footprintX          = 4,
    footprintZ          = 4,
    iconType            = [[tankskirm]],
    idleAutoHeal        = 5,
    idleTime            = 1800,
    leaveTracks         = true,
    maxDamage           = 12000,
    maxSlope            = 18,
    maxVelocity         = 1.9,
    maxWaterDepth       = 22,
    minCloakDistance    = 75,
    movementClass       = [[TANK4]],
    noAutoFire          = false,
    noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE GUNSHIP SUB]],
    objectName          = [[sprawler.dae]],
    script              = [[striderbomb.lua]],
    selfDestructAs      = [[BIG_UNIT]],

    sfxtypes            = {

        explosiongenerators = {
            [[custom:LARGE_MUZZLE_FLASH_FX]],
        },

    },
    sightDistance       = 540,
    trackOffset         = 8,
    trackStrength       = 10,
    trackStretch        = 1,
    trackType           = [[StdTank]],
    trackWidth          = 50,
    turninplace         = 0,
    turnRate            = 312,
    workerTime          = 0,

    weapons             = {
    },

    weaponDefs          = {
    },

    featureDefs         = {

        DEAD       = {
            blocking         = true,
            featureDead      = [[HEAP]],
            footprintX       = 4,
            footprintZ       = 4,
            object           = [[golly_d.s3o]],
        },


        HEAP       = {
            blocking         = false,
            footprintX       = 4,
            footprintZ       = 4,
            object           = [[debris4x4c.s3o]],
        },

    },

} }
