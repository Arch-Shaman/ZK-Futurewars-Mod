return {
	["bully_trail"] = {
		usedefaultexplosions = false,
		glow = {
			air                = true,
			class              = [[explspike]],
			count              = 3,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				alpha              = 0.9,
				alphadecay         = 0.13,
				alwaysvisible      = false,
				color              = [[1,0.1,1]],
				dir                = [[-4 r8, -4 r8, -4 r8]],
				length             = 6.5,
				speed              = [[-0.06 r0.12, -0.06 r0.12, -0.06 r0.12]], -- speed allows for control over lengthgrowth.
				width              = 9.8,
			},
		},
		white = {
			air                = true,
			class              = [[explspike]],
			count              = 2,
			ground             = true,
			water              = true,
			underwater         = true,
			properties = {
				alpha              = 0.95,
				alphadecay         = 0.13,
				alwaysvisible      = false,
				color              = [[0.5,0,0.5]],
				dir                = [[-2 r4, -2 r4, -2 r4]],
				length             = 2.2,
				--speed              = [[-0.06 r0.12, -0.06 r0.12, -0.06 r0.12]],
				width              = 3.4,
			},
		},
	},
}
