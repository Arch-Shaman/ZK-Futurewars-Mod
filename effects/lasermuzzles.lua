return {
	["beamweapon_muzzle_yellow"] = {
		usedefaultexplosions = false,
		glow = {
			air                = true,
			class              = [[explspike]],
			count              = 12,
			ground             = true,
			water              = true,
			properties = {
				alpha              = 1,
				alphadecay         = 0.125,
				alwaysvisible      = false,
				color              = [[0.902,0.682,0.145]],
				dir                = [[-4 r8, -4 r8, -4 r8]],
				length             = 1,
				lengthgrowth       = 1,
				width              = 4,
			},
		},
		white = {
			air                = true,
			class              = [[explspike]],
			count              = 2,
			ground             = true,
			water              = true,
			properties = {
				alpha              = 1,
				alphadecay         = 0.125,
				alwaysvisible      = false,
				color              = [[1,1,1]],
				dir                = [[-2 r4, -2 r4, -2 r4]],
				length             = 1,
				lengthgrowth       = 1,
				width              = 2,
			},
		},
	},
}