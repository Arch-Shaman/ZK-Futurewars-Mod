return {
	["waketrail"] = {
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
				colormap           = [[0.239 0.643 0.784 0.01 0.1294 0.4549 0.8313 0.01 0 0 0 0.01]],
				dir                = [[dir]],
				frontoffset        = 0,
				fronttexture       = [[muzzlefront]],
				length             = -45,
				sidetexture        = [[muzzleside]],
				size               = -8,
				sizegrowth         = 0.75,
				ttl                = 8,
			},
		},
	}
}
