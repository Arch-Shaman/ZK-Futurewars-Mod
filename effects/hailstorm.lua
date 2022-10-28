return {
	["hailstorm_trail"] = {
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
				colormap           = [[0.8 0.7412 0.1412 0.01  0.7137 0.5647 0.1255 0.01 0.7059 0.4667 0.1255 0.01  0.8706 0.3843 0.2706 0.01  0.8706 0.3451 0.2706 0.01 0 0 0 0.01]],
				dir                = [[dir]],
				frontoffset        = 0,
				fronttexture       = [[muzzlefront]],
				length             = -1.1,
				sidetexture        = [[muzzleside]],
				size               = -8,
				sizegrowth         = 0.75,
				ttl                = 3,
			},
		},
	},
}