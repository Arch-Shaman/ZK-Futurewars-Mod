-- External:
-- liberation_plasmatrail
-- liberation_disarmtrail
-- liberation_slowtrail
-- liberation_disarmimpact
-- liberation_slowimpact
-- Internal:
-- liberation_disarmimpactspark

VFS.Include("LuaRules/Utilities/tablefunctions.lua")

local CopyTable = Spring.Utilities.CopyTable
local OverwriteTableInplace = Spring.Utilities.OverwriteTableInplace

local liberation_basetrail = {
	usedefaultexplosions = false,
	exhale = {
		air                = true,
		class              = [[CSimpleParticleSystem]],
		count              = 1,
		ground             = true,
		water              = true,
		properties = {
			airdrag            = 0.8,
			colormap           = [[0.239 0.643 0.784 0.01 0.1294 0.4549 0.8313 0.01 0 0 0 0.01]],
			directional        = false,
			emitrot            = 80,
			emitrotspread      = 5,
			emitvector         = [[0, 1, 0]],
			gravity            = [[0, 0, 0]],
			numparticles       = 5,
			particlelife       = 7,
			particlelifespread = 5,
			particlesize       = 16,
			particlesizespread = 3,
			particlespeed      = 3,
			particlespeedspread = 3,
			pos                = [[0, 1, 0]],
			sizegrowth         = 0.4,
			sizemod            = 1.0,
			texture            = [[smoke]],
		},
	},
	exhale2 = {
		air                = true,
		class              = [[CSimpleParticleSystem]],
		count              = 1,
		ground             = true,
		water              = true,
		properties = {
			airdrag            = 0.8,
			colormap           = [[0.239 0.239 0.784 0.01 0.1294 0.1294 0.8313 0.01 0 0 0 0.01]],
			directional        = false,
			emitrot            = 80,
			emitrotspread      = 5,
			emitvector         = [[0, 1, 0]],
			gravity            = [[0, 0, 0]],
			numparticles       = 5,
			particlelife       = 7,
			particlelifespread = 5,
			particlesize       = 16,
			particlesizespread = 3,
			particlespeed      = 3,
			particlespeedspread = 3,
			pos                = [[0, 1, 0]],
			sizegrowth         = 0.4,
			sizemod            = 1.0,
			texture            = [[smoke]],
		},
	},
	spikes = {
		air                = true,
		class              = [[CExploSpikeProjectile]],
		count              = 3,
		ground             = true,
		water              = true,
		properties = {
			alpha              = 1,
			alphadecay         = 0.15,
			color              = [[0, 1.0, 1.0]],
			dir                = [[-10 r20,-10 r20,-10 r20]],
			length             = 3,
			width              = 50,
		},
	},
}



local cegs = {}


cegs.liberation_disarmimpactspark = {
	bluebolts = {
		air                = true,
		class              = [[CSimpleParticleSystem]],
		count              = 1,
		ground             = true,
		water              = true,
		properties = {
			airdrag            = 1,
			colormap           = [[1 1 1 0.01  1 1 1 0.01 0.5 0.5 0.5 0.01  1 1 1 0.01   0 0 0 0.01]],
			directional        = true,
			emitrot            = 0,
			emitrotspread      = 180,
			emitvector         = [[0, 1, 0]],
			gravity            = [[0, 0, 0]],
			numparticles       = 5,
			particlelife       = 15,
			particlelifespread = 10,
			particlesize       = 40,
			particlesizespread = 40,
			particlespeed      = 1,
			particlespeedspread = 4,
			pos                = [[0, 1.0, 0]],
			sizegrowth         = 0,
			sizemod            = 0.95,
			texture            = [[whitelightb]],
		},
	},
}

-- All 3 trails are modified off of vulcanfx
cegs.liberation_plasmatrail = CopyTable(liberation_basetrail, true)
OverwriteTableInplace(cegs.liberation_plasmatrail, {
	exhale = {
		properties = {
			airdrag            = 1.2,
			emitrot            = 0,
			emitrotspread      = 180,
			particlespeed      = 5,
			particlespeedspread = 5,
			particlesize       = 20,
			particlesizespread = 4,
		},
	},
	exhale2 = {
		properties = {
			airdrag            = 1.2,
			emitrot            = 0,
			emitrotspread      = 180,
			particlespeed      = 5,
			particlespeedspread = 5,
			particlesize       = 20,
			particlesizespread = 4,
		},
	},
}, false)


cegs.liberation_disarmtrail = CopyTable(liberation_basetrail, true)
cegs.liberation_disarmtrail.bluebolts = CopyTable(cegs.liberation_disarmimpactspark.bluebolts, true)
OverwriteTableInplace(cegs.liberation_disarmtrail, {
	exhale = {
		properties = {
			colormap = [[1.0 1.0 0.5 0.2    0.8 0.8 0.8 0.6    0.0 0.0 0.0 0.01]],
		},
	},
	exhale2 = {
		properties = {
			colormap = [[1.0 1.0 0.0 0.2    1.0 1.0 1.0 0.6    0.0 0.0 0.0 0.01]],
		},
	},
	spikes = {
		properties = {
			color = [[1.0, 1.0, 0.5]]
		},
	},
	bluebolts = {
		properties = {
			numparticles       = 1,
			particlelife = 45,
			particlelifespread = 30,
		},
	},
}, false)


cegs.liberation_slowtrail = CopyTable(liberation_basetrail, true)
OverwriteTableInplace(cegs.liberation_slowtrail, {
	exhale = {
		properties = {
			colormap = [[1.0 1.0 1.0 0.2    1.0 0.5 1.0 0.6    0.5 0.0 0.5 0.6    0.0 0.0 0.0 0.01]],
		},
	},
	exhale2 = {
		properties = {
			colormap = [[1.0 0.7 1.0 0.2    0.5 0.0 0.5 0.6    1.0 0.5 1.0 0.6    0.0 0.0 0.0 0.01]],
		},
	},
	spikes = {
		properties = {
			color = [[1.0, 0.0, 1.0]],
			length = 10,
			width = 100,
		},
	}
}, false)


cegs.liberation_disarmtrailspark = CopyTable(cegs.liberation_disarmimpactspark, true)
OverwriteTableInplace(cegs.liberation_disarmtrailspark.bluebolts.properties, {
	particlelife = 60,
	particlelifespread = 40,
}, true)


cegs.liberation_disarmimpact = {
	electricstorm = {
		air                = true,
		class              = [[CExpGenSpawner]],
		count              = 530,
		ground             = true,
		water              = true,
		properties = {
		  delay              = [[i0.01 y1 -1 x1x1 y1 28 a1]],
		  explosiongenerator = [[custom:liberation_disarmimpactspark]],
		  pos                = [[i0.04 y10 -1 x10x10 y10 450 a10 y10      r6.283 y11 -3.1415 a11 y11 -0.5x11x11         y0 0.0417x11x11x11x11 y1 -0.00139x11x11x11x11x11x11 y2 0.0000248015x11x11x11x11x11x11x11x11 y3 -0.000000275573x11x11x11x11x11x11x11x11x11x11 y4 0.00000000208768x11x11x11x11x11x11x11x11x11x11x11x11 y5 1 a0 a1 a2 a3 a4 a5 x10, 10 r30, -0.1667x11x11x11 y0 0.00833x11x11x11x11x11 y1 -0.000198412x11x11x11x11x11x11x11 y2 0.00000275573192x11x11x11x11x11x11x11x11x11 y3 -0.00000002505210838x11x11x11x11x11x11x11x11x11x11x11 y4 0 a11 a0 a1 a2 a3 a4 x10 ]] -- Taken from `napalm_missile by Googlefrog in napalm.lua
		},
	},
	sphere = {
		air                = true,
		class              = [[CSpherePartSpawner]],
		count              = 1,
		ground             = true,
		water              = true,
		properties = {
			alpha              = 1,
			color              = [[1,1,1]],
			expansionspeed     = 16,
			ttl                = 28,
		},
	},
	groundflash = {
		air                = true,
		alwaysvisible      = true,
		circlealpha        = 0.8,
		circlegrowth       = 16,
		flashalpha         = 0.9,
		flashsize          = 100,
		ground             = true,
		ttl                = 35,
		water              = true,
		underwater         = true,
		color = {
			[1]  = 0,
			[2]  = 0.5,
			[3]  = 1,
		},
	},
}


cegs.liberation_slowimpact = {
	spikes = {
		air                = true,
		class              = [[CExploSpikeProjectile]],
		count              = 20,
		ground             = true,
		water              = true,
		properties = {
			alpha              = 1,
			alphadecay         = 0.015,
			color              = [[1.0, 0, 1.0]],
			dir                = [[-5 r10, -5 r10, -5 r10]],
			length             = 0,
			lengthGrowth       = 1,
			width              = 100,
		},
	},
	ball1 = {
		air                = true,
		class              = [[CSimpleParticleSystem]],
		count              = 20,
		ground             = true,
		water              = true,
		properties = {
			airdrag            = 0.9,
			colormap           = [[1.0 0.5 1.0 0.4   1.0 0.0 1.0 0.3    1.0 0.0 1.0 0.2  0 0 0 0.01]],
			directional        = true,
			emitrot            = 0,
			emitrotspread      = 100,
			emitvector         = [[0, 1, 0]],
			gravity            = [[0, 0, 0]],
			numparticles       = 1,
			particlelife       = 40,
			particlelifespread = 20,
			particlesize       = 40,
			particlesizespread = 40,
			particlespeed      = [[r3 y0 -1 x0x0x0 y0 27 a0]],
			particlespeedspread = 0,
			pos                = [[0, 0, 0]],
			sizegrowth         = 0,
			sizemod            = 1,
			texture            = [[wakelarge]],
		},
	},
}
cegs.liberation_slowimpact.ball2 = CopyTable(cegs.liberation_slowimpact.ball1, true)
cegs.liberation_slowimpact.ball3 = CopyTable(cegs.liberation_slowimpact.ball1, true)
OverwriteTableInplace(cegs.liberation_slowimpact, {
	ball2 = {
		properties = {
			colormap = [[0.5 0.4 0.9 0.4    0.5 0.0 0.9 0.3    0.5 0.0 0.9 0.2    0 0 0 0.01]],
		},
	},
	ball3 = {
		properties = {
			colormap = [[0.9 0.4 0.5 0.4    0.9 0.0 0.5 0.3    0.9 0.0 0.5 0.2    0 0 0 0.01]],
		},
	},
}, false)

return cegs
