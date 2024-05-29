-- flamer
-- fire1_burn1_flame1
-- fire1_smoke1
-- fire1_burnlight
-- fire1_burn1_flame3
-- fire1_burn1_flame4
-- fire1_burn1
-- fire1_burn1_flame2
-- fire1

local defs = {
	["flamer"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.975,
				animParams         = [[8,8,16 r64]],
				colormap           = [[0.45 0.45 0.45 0.01      0.9 0.65 0.55 0.05      0.9 0.65 0.55 0.1   0.4 0.22 0.22 0.08     0 0 0 0]],
				directional        = true,
				--emitmul            = [[0, 2, 0]],
				emitrot            = 0,
				emitrotspread      = 0.05,
				emitvector         = [[dir]],
				gravity            = [[0.1 r-0.2, 0.05, 0.1 r-0.2]],
				numparticles       = 4,
				particlelife       = 7,
				particlelifespread = 4,
				particlesize       = 12,
				particlesizespread = 7,
				particlespeed      = 0.08,
				particlespeedspread = 0.18,
				pos                = [[16 r-32, 16 r-32, 16 r-32]],
				sizegrowth         = 0.45,
				sizemod            = 1.0,
				texture            = [[FireBall02_8x8]],
			},
		},
	},
	["flamer_cartoon"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.95,
				colormap           = [[0.7 0.7 0.7 0.01  1 0.3 0.3 0.5   0 0 0 0]],
				directional        = true,
				--emitmul            = [[0, 2, 0]],
				emitrot            = 0,
				emitrotspread      = 0,
				emitvector         = [[dir]],
				gravity            = [[0.2 r-0.4, 0.2, 0.2 r-0.4]],
				numparticles       = 1,
				particlelife       = 12,
				particlelifespread = 6,
				particlesize       = 8,
				particlesizespread = 4,
				particlespeed      = 0.1,
				particlespeedspread = 0.1,
				pos                = [[6 r-12, 6 r-12, 6 r-12]],
				sizegrowth         = 1,
				sizemod            = 1.0,
				texture            = [[flame]],
			},
		},
	},
	["flamer_koda"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.95,
				colormap           = [[0.7 0.7 0.7 0.01  1 0.5 0.5 0.5   0 0 0 0]],
				directional        = true,
				emitrot            = 0,
				emitrotspread      = 0,
				emitvector         = [[dir]],
				gravity            = [[0.15 r-0.3, 0.2 r-0.3, 0.15 r-0.3]],
				numparticles       = 1,
				particlelife       = 8,
				particlelifespread = 5,
				particlesize       = 8,
				particlesizespread = 4,
				particlespeed      = 0.1,
				particlespeedspread = 0.1,
				pos                = [[6 r-12, 6 r-12, 6 r-12]],
				sizegrowth         = 0.7,
				sizemod            = 1.0,
				texture            = [[flame]],
			},
		},
	},

	["gravityless_flamer"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.95,
				colormap           = [[0.7 0.7 0.7 0.01  1 0.3 0.3 0.5   0 0 0 0]],
				directional        = true,
				--emitmul            = [[0, 2, 0]],
				emitrot            = 0,
				emitrotspread      = 0,
				emitvector         = [[dir]],
				gravity            = [[0.2 r-0.4, 0.2-r0.4, 0.2 r-0.4]],
				numparticles       = 1,
				particlelife       = 12,
				particlelifespread = 6,
				particlesize       = 8,
				particlesizespread = 4,
				particlespeed      = 0.1,
				particlespeedspread = 0.1,
				pos                = [[6 r-12, 6 r-12, 6 r-12]],
				sizegrowth         = 1,
				sizemod            = 1.0,
				texture            = [[flame]],
			},
		},
	},

	["fire1_burn1_flame1"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.95,
				colormap           = [[0 0 0 0.01  1 1 1 0.01  0 0 0 0.01]],
				directional        = false,
				emitrot            = 0,
				emitrotspread      = 1,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, 0, 0]],
				numparticles       = 1,
				particlelife       = 15.3,
				particlelifespread = 0,
				particlesize       = 5.23,
				particlesizespread = 10.23,
				particlespeed      = 0,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0,
				sizemod            = 1.0,
				texture            = [[fire1]],
			},
		},
	},

	["fire1_smoke1"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 1,
				colormap           = [[0 0 0 0.01    1 1 1 1    0.7 0.7  0.7 1     0.5 0.5 0.5 0.7      0 0 0 0.01]],
				directional        = false,
				emitrot            = 0,
				emitrotspread      = 5,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, 0, 0.05]],
				numparticles       = 1,
				particlelife       = 30,
				particlelifespread = 30,
				particlesize       = 9,
				particlesizespread = 11,
				particlespeed      = 2,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0.05,
				sizemod            = 1.0,
				texture            = [[orangesmoke]],
			},
		},
	},

	["fire1_burnlight"] = {
		air                = true,
		count              = 1,
		ground             = true,
		usedefaultexplosions = false,
		water              = true,
		groundflash = {
			circlealpha        = 1,
			circlegrowth       = 1,
			flashalpha         = 1,
			flashsize          = 20,
			ttl                = 15,
			color = {
				[1]  = 1,
				[2]  = 0.44999998807907,
				[3]  = 0.69999998807907,
			},
		},
	},

	["fire1_burn1_flame3"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.95,
				colormap           = [[0 0 0 0.01  1 1 1 0.01  0 0 0 0.01]],
				directional        = false,
				emitrot            = 0,
				emitrotspread      = 1,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, 0, 0]],
				numparticles       = 1,
				particlelife       = 15.3,
				particlelifespread = 0,
				particlesize       = 5.23,
				particlesizespread = 10.23,
				particlespeed      = 0,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0,
				sizemod            = 1.0,
				texture            = [[fire3]],
			},
		},
	},

	["fire1_burn1_flame4"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.95,
				colormap           = [[0 0 0 0.01  1 1 1 0.01  0 0 0 0.01]],
				directional        = false,
				emitrot            = 0,
				emitrotspread      = 1,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, 0, 0]],
				numparticles       = 1,
				particlelife       = 15.3,
				particlelifespread = 0,
				particlesize       = 5.23,
				particlesizespread = 10.23,
				particlespeed      = 0,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0,
				sizemod            = 1.0,
				texture            = [[fire4]],
			},
		},
	},

	["fire1_burn1"] = {
		flame1 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				delay              = 0,
				explosiongenerator = [[custom:FIRE1_BURN1_FLAME1]],
				pos                = [[0, 1, 0]],
			},
		},
		flame2 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				delay              = 5,
				explosiongenerator = [[custom:FIRE1_BURN1_FLAME2]],
				pos                = [[0, 1, 0]],
			},
		},
		flame3 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				delay              = 10,
				explosiongenerator = [[custom:FIRE1_BURN1_FLAME3]],
				pos                = [[0, 1, 0]],
			},
		},
		flame4 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				delay              = 15,
				explosiongenerator = [[custom:FIRE1_BURN1_FLAME4]],
				pos                = [[0, 1, 0]],
			},
		},
	},

	["fire1_burn1_flame2"] = {
		fire = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.95,
				colormap           = [[0 0 0 0.01  1 1 1 0.01  0 0 0 0.01]],
				directional        = false,
				emitrot            = 0,
				emitrotspread      = 1,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, 0, 0]],
				numparticles       = 1,
				particlelife       = 15.3,
				particlelifespread = 0,
				particlesize       = 5.23,
				particlesizespread = 10.23,
				particlespeed      = 0,
				particlespeedspread = 0,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0,
				sizemod            = 1.0,
				texture            = [[fire2]],
			},
		},
	},

	["fire1"] = {
		flame = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 5,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[0 i20]],
				explosiongenerator = [[custom:FIRE1_BURN1]],
				pos                = [[0, 1, 0]],
			},
		},
		groundflash = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 100,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[0 i1]],
				explosiongenerator = [[custom:FIRE1_BURNLIGHT]],
				pos                = [[0, 1, 0]],
			},
		},
		smoke1 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 100,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[0 i1]],
				explosiongenerator = [[custom:FIRE1_SMOKE1]],
				pos                = [[0, 1, 0]],
			},
		},
	},
}

defs["flamer_240_range"] = Spring.Utilities.MergeTable({
		fire = {
			properties = {
				particlesize       = [[d10.5 y0 -1 x0 100 p0.75]],
				particlesizespread = 2,
				numparticles       = [[d0.65 p1.15 r0.7 1 k1]],
				emitrotspread      = [[-0.12 d0.015]],
				particlelifespread = 3,
			}
		}
	}, defs["flamer"], true)

-- 450
defs["flamer_320_range"] = Spring.Utilities.MergeTable({
		fire = {
			properties = {
				particlesize       = [[d9 y0 -1 x0 105 p0.8]],
				particlesizespread = 2,
				numparticles       = [[d0.3 p1.5 r0.8 2.1 k]],
				emitrotspread      = [[-0.12 d0.01]],
				particlelifespread = 3,
			}
		}
	}, defs["flamer"], true)

return defs
