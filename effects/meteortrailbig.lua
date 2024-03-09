return {
	["meteorbig_tag"] = {
		usedefaultexplosions = false,
		fire = {
			air                = true,
			class              = [[CBitmapMuzzleFlame]],
			count              = 1,
			ground             = true,
			underwater         = 1,
			water              = true,
			properties = {
				alwaysvisible      = true,
				colormap           = [[1 1 1 0.01	1 0.5 0 0.01	0 0 0 0.01]],
				dir                = [[dir]],
				frontoffset        = 1,
				fronttexture       = "muzzlefront",
				sidetexture        = "muzzleside",
				length             = -300,
				size               = 100,
				sizegrowth         = 0.8,
				ttl                = 3,
			},
		},
	},
}