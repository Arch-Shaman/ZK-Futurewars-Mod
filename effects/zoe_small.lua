-- zoe_cap
-- zoe_cap3
-- zoe_cap4
-- zoe_cap2
-- zoe
-- zoe_ring

return {
	["zoe_cap_small"] = {
		rocks = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 10,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				airdrag            = 0.96,
				alwaysvisible      = true,
				colormap           = [[0.0 0.00 0.0 0.01
									   0.9 0.90 0.0 0.50
									   0.9 0.90 0.0 0.50
									   0.9 0.90 0.0 0.50
									   0.9 0.90 0.0 0.50
									   0.9 0.90 0.0 0.50
									   0.8 0.80 0.1 0.50
									   0.7 0.70 0.2 0.50
									   0.5 0.35 0.0 0.50
									   0.5 0.35 0.0 0.50
									   0.5 0.35 0.0 0.50
									   0.5 0.35 0.0 0.50
									   0.0 0.00 0.0 0.01]],
				directional        = true,
				emitrot            = 70,
				emitrotspread      = 0,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0.001 r-0.002, 0.0, 0.001 r-0.002]],
				numparticles       = 1,
				particlelife       = 80*.4,
				particlelifespread = 20*.4,
				particlesize       = 120*.4,
				particlesizespread = 120*.4,
				particlespeed      = 24*.4,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0.05,
				sizemod            = 1,
				texture            = [[fireball]],
			},
		},
	},

	["zoe_cap3_small"] = {
		rocks = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 0,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				airdrag            = 0.98,
				alwaysvisible      = true,
				colormap           = [[0 0 0 0.01
									   1 1 1 1.00
									   1 1 1 1.00
									   1 1 1 1.00
									   1 1 1 1.00
									   1 1 1 1.00
									   0 0 0 0.01 ]],
				directional        = true,
				emitrot            = 70,
				emitrotspread      = 0,
				emitvector         = [[0, 1, 0]],
				numparticles       = 1,
				particlelife       = 240*.4,
				particlelifespread = 40*.4,
				particlesize       = 60*.4,
				particlesizespread = 60*.4,
				particlespeed      = 24*.4,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0.05,
				sizemod            = 1,
				texture            = [[fireball]],
			},
		},
		smoke = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 10,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				airdrag            = 0.98,
				alwaysvisible      = true,
				colormap           = [[0.0 0.0 0.0 0.01
									   1.0 0.7 0.3 0.90
									   1.0 0.7 0.5 1.00
									   1.0 0.7 0.5 1.00
									   1.0 0.7 0.5 1.00
									   1.0 0.8 0.6 1.00
									   1.0 0.8 0.6 1.00
									   1.0 0.8 0.6 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.0 0.0 0.0 0.01]],
				directional        = false,
				emitrot            = 70,
				emitrotspread      = 0,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0.001 r-0.002, 0.00, 0.001 r-0.002]],
				numparticles       = 1,
				particlelife       = 240*.4,
				particlelifespread = 40*.4,
				particlesize       = 120*.4,
				particlesizespread = 120*.4,
				particlespeed      = 24*.4,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0.05,
				sizemod            = 1,
				texture            = [[smokesmall]],
			},
		},
	},

	["zoe_cap4_small"] = {
		smoke = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 10,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				airdrag            = 0.98,
				alwaysvisible      = true,
				colormap           = [[0.0 0.0 0.0 0.01
									   1.0 0.8 0.6 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.0 0.0 0.0 0.01]],
				directional        = false,
				emitrot            = 90,
				emitrotspread      = 0,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0.001 r-0.002, 0.00, 0.001 r-0.002]],
				numparticles       = 1,
				particlelife       = 525*.4,
				particlelifespread = 40*.4,
				particlesize       = [[96 i24]],
				particlesizespread = 40*.4,
				particlespeed      = [[24 i-2.3]],
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0.05,
				sizemod            = 1,
				texture            = [[smokesmall]],
			},
		},
	},

	["zoe_cap2_small"] = {
		rocks = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 10,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				airdrag            = 0.97,
				alwaysvisible      = true,
				colormap           = [[0.0 0.00 0.0 0.01
									   0.9 0.90 0.0 0.50
									   0.9 0.90 0.0 0.50
									   0.9 0.90 0.0 0.50
									   0.9 0.90 0.0 0.50
									   0.9 0.90 0.0 0.50
									   0.8 0.80 0.1 0.50
									   0.7 0.70 0.2 0.50
									   0.5 0.35 0.0 0.50
									   0.5 0.35 0.0 0.50
									   0.5 0.35 0.0 0.50
									   0.5 0.35 0.0 0.50
									   0.0 0.00 0.0 0.01]],
				directional        = true,
				emitrot            = 70,
				emitrotspread      = 0,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0.001 r-0.002, 0.05, 0.001 r-0.002]],
				numparticles       = 1,
				particlelife       = 160*.4,
				particlelifespread = 40*.4,
				particlesize       = 90*.4,
				particlesizespread = 90*.4,
				particlespeed      = 24*.4,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = -0.1,
				sizemod            = 1,
				texture            = [[fireball]],
			},
		},
		smoke = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 10,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				airdrag            = 0.98,
				alwaysvisible      = true,
				colormap           = [[0.0 0.0 0.0 0.01
									   1.0 0.7 0.3 0.60
									   1.0 0.7 0.5 1.00
									   1.0 0.7 0.5 1.00
									   1.0 0.7 0.5 1.00
									   1.0 0.8 0.6 1.00
									   1.0 0.8 0.6 1.00
									   1.0 0.8 0.6 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.8 0.8 0.8 1.00
									   0.0 0.0 0.0 0.01]],
				directional        = false,
				emitrot            = 70,
				emitrotspread      = 0,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0.001 r-0.002, 0.00, 0.001 r-0.002]],
				numparticles       = 1,
				particlelife       = 190*.4,
				particlelifespread = 40*.4,
				particlesize       = 120*0.4,
				particlesizespread = 120*0.4,
				particlespeed      = 24*.4,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0.05,
				sizemod            = 1,
				texture            = [[smokesmall]],
			},
		},
	},

	["zoe_small"] = {
		cap = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 50,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[0 i4]],
				explosiongenerator = [[custom:ZOE_CAP_SMALL]],
				pos                = [[-10 r20, 0 i20, -10 r20]],
			},
		},
		cap2 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 50,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[200 i4]],
				explosiongenerator = [[custom:ZOE_CAP2_SMALL]],
				pos                = [[-10 r20, 1000 i20, -10 r20]],
			},
		},
		cap3 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 50,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[400 i4]],
				explosiongenerator = [[custom:ZOE_CAP3_SMALL]],
				pos                = [[-10 r20, 2000 i20, -10 r20]],
			},
		},
		cap4 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 50,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[600 i4]],
				explosiongenerator = [[custom:ZOE_CAP4_SMALL]],
				pos                = [[-10 r20, 3100 i5, -10 r20]],
			},
		},
		ring = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 10,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[330 i4]],
				explosiongenerator = [[custom:ZOE_RING_SMALL]],
				pos                = [[-10 r20, 1500 i3, -10 r20]],
			},
		},
		solange = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 1,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[0 i200]],
				explosiongenerator = [[custom:SOLANGE_SMALL]],
				pos                = [[0, 0, 0]],
			},
		},
		theora = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 2,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[400 i200]],
				explosiongenerator = [[custom:THEORA_SMALL]],
				pos                = [[0, 0, 0]],
			},
		},
		transtheora = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 1,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				delay              = [[200 i200]],
				explosiongenerator = [[custom:TRANSTHEORA_SMALL]],
				pos                = [[0, 0, 0]],
			},
		},
	},

	["zoe_ring_small"] = {
    smoke = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 10,
      ground             = true,
      water              = true,
      underwater         = true,
      properties = {
        airdrag            = 0.96,
        alwaysvisible      = true,
        colormap           = [[0.0 0.0 0.0 0.01
                               1.0 0.7 0.3 0.60
                               1.0 0.7 0.5 1.00
                               1.0 0.7 0.5 1.00
                               1.0 0.7 0.5 1.00
                               1.0 0.8 0.6 1.00
                               1.0 0.8 0.6 1.00
                               1.0 0.8 0.6 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.8 0.8 0.8 1.00
                               0.0 0.0 0.0 0.01]],
        directional        = false,
        emitrot            = 70,
        emitrotspread      = 0,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0.001 r-0.002, 0.00, 0.001 r-0.002]],
        numparticles       = 1,
        particlelife       = 395*.4,
        particlelifespread = 40*.4,
        particlesize       = 120*.4,
        particlesizespread = 120*.4,
        particlespeed      = 48*.4,
        particlespeedspread = 0,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0.05,
        sizemod            = 1,
        texture            = [[smokesmall]],
      },
    },
  },

}

