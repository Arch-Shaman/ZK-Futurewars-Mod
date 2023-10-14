-- superflamer
-- goo_v2_green
-- goo_v2_red_small
-- goo_v2_red

VFS.Include("LuaRules/Utilities/tablefunctions.lua")

local MergeWithDefault = Spring.Utilities.MergeWithDefault


--local rainbow1 = "1.000 0.625 0.788 0.01 1.000 0.705 0.463 0.01 0.674 0.826 0.446 0 0 0 0"
local goo_shared = {
	groundflash = {
		circlealpha        = .4,
		circlegrowth       = 0,
		flashalpha         = .3,
		flashsize          = 42,
		ttl                = 256,
		color = {
			[1]  = 0.2,
			[2]  = 0.8,
			[3]  = 0,
		},
	},
	pop = {
		air                = true,
		class              = "CSimpleParticleSystem",
		ground             = true,
		properties = {
			airdrag            = .9,
			colormap           = "0.4 0.8 0 0.5   0.4 0.8 0 0.5   0 0 0 0",
			directional        = false,
			emitrot            = 45,
			emitrotspread      = 30,
			emitvector         = "0, 1, 0",
			gravity            = "0, 0.3, 0",
			numparticles       = 1,
			particlelife       = 20,
			particlelifespread = 0,
			particlesize       = 20,
			particlesizespread = 13,
			particlespeed      = 0,
			particlespeedspread = 0,
			pos                = "0, 1.0, 0",
			sizegrowth         = "10 r3",
			sizemod            = 0.9,
			texture            = "bloodblastjustwhite",
		},
	},
	splashes = {
		air                = true,
		class              = "CSimpleParticleSystem",
		ground             = true,
		properties = {
			airdrag            = .96,
			colormap           = "0.2 0.6 0 1   0.2 0.6 0 1   0 0 0 0",
			directional        = true,
			emitrot            = 0,
			emitrotspread      = 80,
			emitvector         = "0, 1, 0",
			gravity            = "0, -0.4, 0",
			numparticles       = 5,
			particlelife       = 16,
			particlelifespread = 8,
			particlesize       = 24,
			particlesizespread = 16,
			particlespeed      = 4,
			particlespeedspread = 6,
			pos                = "0, 1.0, 0",
			sizegrowth         = -.2,
			sizemod            = 1,
			texture            = "blooddropwhite",
		},
	},
}

return {
	["superflamer"] = {
		usedefaultexplosions = false,
		fire = {
			air                = true,
			class              = "CSimpleParticleSystem",
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.95,
				colormap           = "1.000 0.625 0.788 0.01 1.000 0.705 0.463 0.01 0.674 0.826 0.446 0 0 0 0",
				directional        = true,
				emitrot            = 0,
				emitrotspread      = 0,
				emitvector         = "dir",
				gravity            = "0.5 r-1, 0.5, 0.5 r-1",
				numparticles       = 1,
				particlelife       = "21 d-0.5",
				particlelifespread = "10 d-0.25",
				particlesize       = "24 d-0.571",
				particlesizespread = "12 d-0.286",
				particlespeed      = 0.5,
				particlespeedspread = 0.5,
				pos                = "12 r-24, 12 r-24, 12 r-24",
				sizegrowth         = 4,
				sizemod            = 1.0,
				texture            = "flame",
			},
		},
	},
	["goo_v2_green"] = MergeWithDefault(goo_shared, {
	}),
	["goo_v2_green_large"] = MergeWithDefault(goo_shared, {
		groundflash = {
			flashsize = 84,
			ttl = 512,
		},
		pop = {
			properties = {
				particlelife = 40,
				sizegrowth = "15 r5",
				sizemod = 0.93,
			},
		},
		splashes = {
		},
	}),
	["goo_v2_red"] = MergeWithDefault(goo_shared, {
		groundflash = {
			color = {
				[1]  = 0.6,
				[2]  = 0.2,
				[3]  = 0,
			},
		},
		pop = {
			properties = {
				gravity = "0 0 0",
				colormap = "0.8 0 0 0.5   0.8 0 0 0.5   0 0 0 0",
				particlelife = 16,
				sizegrowth = "7 r2",
			},
		},
		splashes = {
			properties = {
				particlelife = 12,
				particlelifespread = 6,
				colormap = "0.8 0 0 0.5   0.8 0 0 0.5   0 0 0 0",
			},
		},
	}),
	["goo_v2_blue"] = MergeWithDefault(goo_shared, {
		groundflash = {
			color = {
				[1]  = 0.0,
				[2]  = 0.4,
				[3]  = 0.8,
			},
		},
		pop = {
			properties = {
				gravity = "0 0 0",
				colormap = "0 0.4 0.8 0.5   0 0.4 0.8 0.5   0 0 0 0",
			},
		},
		splashes = {
			properties = {
				colormap = "0 0.4 0.8 0.5   0 0.4 0.8 0.5   0 0 0 0",
			},
		},
	}),
	["goo_v2_blue_large"] = MergeWithDefault(goo_shared, {
		groundflash = {
			flashsize = 84,
			color = {
				[1]  = 0.0,
				[2]  = 0.4,
				[3]  = 0.8,
			},
		},
		pop = {
			properties = {
				particlelife = 30,
				sizegrowth = "15 r5",
				sizemod = 0.9,
				colormap = "0 0.4 0.8 0.5   0 0.4 0.8 0.5   0 0 0 0",
			},
		},
		splashes = {
			properties = {
				colormap = "0 0.4 0.8 0.5   0 0.4 0.8 0.5   0 0 0 0",
			},
		},
	}),
	["goo_v2_purple_large"] = MergeWithDefault(goo_shared, {
		groundflash = {
			flashsize = 84,
			color = {
				[1]  = 0.8,
				[2]  = 0,
				[3]  = 0.8,
			},
		},
		pop = {
			properties = {
				particlelife = 30,
				sizegrowth = "15 r5",
				sizemod = 0.9,
				colormap = "0.8 0 0.8 0.5   0.8 0 0.8 0.5   0 0 0 0",
			},
		},
		splashes = {
			properties = {
				colormap = "0.8 0 0.8 0.5   0.8 0 0.8 0.5   0 0 0 0",
			},
		},
	}),
}
