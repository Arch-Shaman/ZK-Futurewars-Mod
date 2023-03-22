return {
	["armor_ring600"] = {
		usedefaultexplosions = false, -- TODO: Remove groundflashes and replace with dynlighting
		groundflash = {
			alwaysvisible      = false,
			circlealpha        = 0.1,
			circlegrowth       = 3.6,
			flashalpha         = 0.1,
			flashsize          = 600,
			ttl                = 90,
			color = {
				[1]  = 0.41960784,
				[2]  = 0.73333333,
				[3]  = 0.89019608,
			},
		},
		ring1 = {
			air                = true,
			useAirLos 		   = true,
			class              = [[CBitmapMuzzleFlame]],
			ground             = true,
			water              = true,
			unit               = true,
			count              = 1,
			properties = {
				colormap           = [[0.41960784 0.73333333 0.89019608 0.1   0.443137 0.6 0.851 .2    0.2784313 0.3568627 0.4784313 0.1   0 0 0 0]],
				dir                = [[-0.01 r0.01, 1, -0.01 r0.01]],
				frontoffset        = 0,
				fronttexture       = [[shockwave]],
				sidetexture        = [[null]],
				length             = 1,
				pos                = [[0, 0, 0]],
				size               = 1,
				sizegrowth         = 600,
				ttl                = 30,
			},
		},
	},
	["armor_ring1200"] = {
		usedefaultexplosions = false, -- TODO: Remove groundflashes and replace with dynlighting
		groundflash = {
			alwaysvisible      = false,
			circlealpha        = 0.1,
			circlegrowth       = 3.6,
			flashalpha         = 0.1,
			flashsize          = 600,
			ttl                = 90,
			color = {
				[1]  = 0.41960784,
				[2]  = 0.73333333,
				[3]  = 0.89019608,
			},
		},
		ring1 = {
			air                = true,
			useAirLos 		   = true,
			class              = [[CBitmapMuzzleFlame]],
			ground             = true,
			water              = true,
			unit               = true,
			count              = 1,
			properties = {
				colormap           = [[0.41960784 0.73333333 0.89019608 0.1   0.443137 0.6 0.851 .2    0.2784313 0.3568627 0.4784313 0.1   0 0 0 0]],
				dir                = [[-0.01 r0.01, 1, -0.01 r0.01]],
				frontoffset        = 0,
				fronttexture       = [[shockwave]],
				sidetexture        = [[null]],
				length             = 1,
				pos                = [[0, 0, 0]],
				size               = 1,
				sizegrowth         = 1200,
				ttl                = 30,
			},
		},
	},
	["armor_vaporspawner"] = {
		vapor = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 4,
			ground             = true,
			water              = true,
			underwater            = true,
			properties = {
				delay              = [[0]],
				explosiongenerator = [[custom:armorvapor]],
				pos                = [[-10 r20, 1, -10 r20]],
			},
		},
	},
	["armorvapor"] = {
		groundflash = {
			circlealpha        = 1,
			circlegrowth       = 0,
			flashalpha         = 0.4,
			flashsize          = 15,
			ttl                = 25,
			color = {
				[1]  = 0.41960784,
				[2]  = 0.73333333,
				[3]  = 0.89019608,
			},
		},
		vapor_particle = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				airdrag            = 1,
				colormap           = [[0 0 0 0.01 0.41960784 0.73333333 0.89019608 0.01 0 0 0 0.01]],
				directional        = true,
				emitrot            = 80,
				emitrotspread      = 0,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, 0.15, 0]],
				numparticles       = 1,
				particlelife       = 18,
				particlelifespread = 6,
				particlesize       = 8,
				particlesizespread = 3,
				particlespeed      = 0.01,
				particlespeedspread = 0,
				pos                = [[-10 r20, 1.0, -10 r20]],
				sizegrowth         = -0.3,
				sizemod            = 1.0,
				texture            = [[dirt]],
			},
		},
	},	
}