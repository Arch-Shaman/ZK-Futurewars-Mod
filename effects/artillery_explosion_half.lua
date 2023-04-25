-- artillery_explosion

return {
  ["artillery_explosion_half"] = {
    dirt = {
      count              = 4,
      ground             = true,
      properties = {
        alphafalloff       = 2,
        alwaysvisible      = true,
        color              = [[0.2, 0.1, 0.05]],
        pos                = [[r-25 r25, 0, r-25 r25]],
        size               = 30,
        speed              = [[r1.5 r-1.5, 2, r1.5 r-1.5]],
      },
    },
    groundflash = {
      air                = true,
      alwaysvisible      = true,
      circlealpha        = 0.6,
      circlegrowth       = 9,
      flashalpha         = 0.9,
      flashsize          = 75,
      ground             = true,
      ttl                = 13,
      water              = true,
      color = {
        [1]  = 1,
        [2]  = 0.20000000298023,
        [3]  = 0.10000000149012,
      },
    },
    poof01 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.8,
        alwaysvisible      = true,
        colormap           = [[1.0 1.0 1.0 0.04	0.9 0.2 0.2 0.01	0.8 0.1 0.0 0.01]],
        directional        = true,
        emitrot            = 45,
        emitrotspread      = 32,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.05, 0]],
        numparticles       = 8,
        particlelife       = 10,
        particlelifespread = 0,
        particlesize       = 30,
        particlesizespread = 0,
        particlespeed      = 2.5,
        particlespeedspread = 2.5,
        pos                = [[0, 2, 0]],
        sizegrowth         = 1,
        sizemod            = 1.0,
        texture            = [[flashside1]],
        useairlos          = false,
      },
    },
    pop1 = {
      air                = true,
      class              = [[heatcloud]],
      count              = 2,
      ground             = true,
      water              = true,
      properties = {
        alwaysvisible      = true,
        heat               = 10,
        heatfalloff        = 1.1,
        maxheat            = 15,
        pos                = [[r-2 r2, 5, r-2 r2]],
        size               = 1,
        sizegrowth         = 8,
        speed              = [[0, 1 0, 0]],
        texture            = [[crimsonnovaexplo]],
      },
    },
    smoke = {
      air                = true,
      count              = 4,
      ground             = true,
      water              = true,
      properties = {
        agespeed           = 0.01,
        alwaysvisible      = true,
        color              = 0.1,
        pos                = [[r-20 r20, 34, r-20 r20]],
        size               = 50,
        sizeexpansion      = 0.6,
        sizegrowth         = 8,
        speed              = [[r-2 r2, 1 r2.3, r-2 r2]],
        startsize          = 10,
      },
    },
    whiteglow = {
      air                = true,
      class              = [[heatcloud]],
      count              = 2,
      ground             = true,
      water              = true,
      properties = {
        alwaysvisible      = true,
        heat               = 10,
        heatfalloff        = 3.5,
        maxheat            = 15,
        pos                = [[0, 0, 0]],
        size               = 5,
        sizegrowth         = 20,
        speed              = [[0, 0, 0]],
        texture            = [[laserend]],
      },
    },
  },

}
