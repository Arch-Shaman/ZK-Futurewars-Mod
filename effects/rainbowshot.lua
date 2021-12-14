-- Disco Rave Party Shot

return  {
	["rainbowshot"] = {
		bitmapmuzzleflame = {
			air                = true,
			class              = [[CBitmapMuzzleFlame]],
			count              = 1,
			ground             = true,
			underwater         = 1,
			water              = true,
			properties = {
				colormap           = [[r1 r1 r1 0.03
									   r1 r1 r1 0.02
									   r1 r1 r1 0.01]],
				dir                = [[dir]],
				frontoffset        = 0,
				fronttexture       = [[muzzlefront]],
				length             = 6,
				sidetexture        = [[muzzleside]],
				size               = 5,
				sizegrowth         = 3,
				ttl                = 2,
			},
		},
	}
}