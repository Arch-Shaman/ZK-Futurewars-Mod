return
{

	["serpent_splosh"] = {
		splosh = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = false,
			water              = false,
			underwater		   = true,
			properties = {
				airdrag            = 0.6,
				colormap           = [[0.7 0.7 0.9 0.8    0.7 0.7 0.9 0.8     0.5 0.5 0.6 0.6     0 0 0 0.01]],
				directional        = true,
				emitrot            = 0,
				emitrotspread      = 180,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, 0, 0]],
				numparticles       = [[3r 1]],
				particlelife       = 15,
				particlelifespread = 0,
				particlesize       = 6,
				particlesizespread = 1,
				particlespeed      = 0.001,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 2,
				sizemod            = 1.0,
				texture            = [[kfoam]],
			},
		},
	},
	["serpent_trail"]= {
        bubbles = {
            air                = false,
            class              = [[CSimpleParticleSystem]],
            count              = 2,
            ground             = false,
            water              = false,
            underwater         = true,
            properties = {
                airdrag            = [[0.95]],
                --alwaysvisible      = true,
                colormap           = [[0.9 0.9 0.9 0.8
                               0.8 0.8 0.8 0.2
                               0.5 0.5 0.5 0.1
                               0 0 0 0]],
                directional        = true,
                emitrot            = 0,
                emitrotspread      = 50,
                emitvector         = [[0, 1, 0]],
                gravity            = [[0, 0.01, 0]],
                numparticles       = [[r3 1]],
                particlelife       = 10,
                particlelifespread = 6,
                particlesize       = 0.3,
                particlesizespread = 1,
                particlespeed      = 0.5,
                particlespeedspread = 0.3,
                pos                = [[-4 r8, -4 r8, -4 r8]],
                sizegrowth         = 0.03,
                sizemod            = [[0.98 r0.01]],
                texture            = [[circularthingy]],
                useairlos          = false,
            },
        },
    },
}