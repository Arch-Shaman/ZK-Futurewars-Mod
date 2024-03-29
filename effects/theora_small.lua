-- theora_pillar
-- transtheora_pillar
-- transtheora
-- theora

return {
  ["theora_pillar_small"] = {
    rocks = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      underwater         = true,
      properties = {
        airdrag            = 0.97,
        colormap           = [[0.0 0.0 0.0 0.01
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.0 0.0 0.0 0.01]],
        directional        = false,
        emitrot            = 120,
        emitrotspread      = 10,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0.001 r-0.002, 0.01 r-0.02, 0.001 r-0.002]],
        numparticles       = 1,
        particlelife       = 150,
        particlelifespread = 150,
        particlesize       = 170*0.4,
        particlesizespread = 170*0.4,
        particlespeed      = 5,
        particlespeedspread = 5,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0.05,
        sizemod            = 1,
        texture            = [[smokesmall]],
      },
    },
  },

  ["transtheora_pillar_small"] = {
    rocks = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      underwater         = true,
      properties = {
        airdrag            = 0.97,
        colormap           = [[0.0 0.0 0.0 0.01
                               1.0 0.6 0.0 1.00
                               1.0 0.7 0.3 1.00
                               1.0 0.7 0.5 1.00
                               1.0 0.8 0.6 1.00
                               0.8 0.8 0.8 1.00
                               0.0 0.0 0.0 0.01]],
        directional        = false,
        emitrot            = 90,
        emitrotspread      = 10,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0.001 r-0.002, 0.01 r-0.02, 0.001 r-0.002]],
        numparticles       = 1,
        particlelife       = 150,
        particlelifespread = 150,
        particlesize       = 90*0.4,
        particlesizespread = 90*0.4,
        particlespeed      = 5,
        particlespeedspread = 5,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0.05,
        sizemod            = 1,
        texture            = [[smokesmall]],
      },
    },
  },

  ["transtheora_small"] = {
    nw = {
      air                = true,
      class              = [[CExpGenSpawner]],
      count              = 150,
      ground             = true,
      water              = true,
      underwater         = true,
      properties = {
        delay              = [[0  i4]],
        explosiongenerator = [[custom:TRANSTHEORA_PILLAR_SMALL]],
        pos                = [[20 r40, i5, -20 r40]],
      },
    },
  },

  ["theora_small"] = {
    nw = {
      air                = true,
      class              = [[CExpGenSpawner]],
      count              = 150,
      ground             = true,
      water              = true,
      underwater         = true,
      properties = {
        delay              = [[0  i4]],
        explosiongenerator = [[custom:THEORA_PILLAR_SMALL]],
        pos                = [[20 r40, i5, -20 r40]],
      },
    },
  },

}

