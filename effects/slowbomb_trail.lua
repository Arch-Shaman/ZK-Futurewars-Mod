return {
	["slowbomb_trail"] = {
		alwaysvisible      = false,
		usedefaultexplosions = false,
		largeflash = {
			air                = true,
			class              = [[CBitmapMuzzleFlame]],
			count              = 1,
			ground             = true,
			underwater         = 1,
			water              = true,
			properties = {
				colormap           = [[0.8235 0.568627 1.0 0.01     0.6823 0.2156 1.0 0.01     0.7764 0.4509 1.0 0.01      0.466 0.0 0.78431 0.01    0.235 0.0 0.3921 0.01     0 0 0 0.01]],
				dir                = [[dir]],
				frontoffset        = 0,
				fronttexture       = [[muzzlefront]],
				length             = -3,
				sidetexture        = [[muzzleside]],
				size               = -6,
				sizegrowth         = 1,
				ttl                = 6,
			},
		},
		pikes1 = {
			air                = true,
			class              = [[explspike]],
			count              = 3,
			ground             = true,
			water              = true,
			underwater		   = true,
			properties = {
				alpha              = 1,
				alphadecay         = 0.5,
				color              = [[0.4666,0.0,0.7843]],
				dir                = [[-2 r4,-2 r4,-2 r4]],
				length             = 11,
				width              = 6,
			},
		},
		pikes2 = {
			air                = true,
			class              = [[explspike]],
			count              = 3,
			ground             = true,
			water              = true,
			underwater		   = true,
			properties = {
				alpha              = 1,
				alphadecay         = 0.5,
				color              = [[0.235 0.0 0.3921]],
				dir                = [[-2 r4,-2 r4,-2 r4]],
				length             = 11,
				width              = 6,
			},
		},
		pikes3 = {
			air                = true,
			class              = [[explspike]],
			count              = 3,
			ground             = true,
			water              = true,
			underwater		   = true,
			properties = {
				alpha              = 1,
				alphadecay         = 0.5,
				color              = [[0.33 0.33 1.0]],
				dir                = [[-2 r4,-2 r4,-2 r4]],
				length             = 11,
				width              = 6,
			},
		},
	},
}