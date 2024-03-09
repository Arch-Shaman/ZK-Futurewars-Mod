return {
	["healingbomb_300"] = {
		usedefaultexplosions = false,
		pop1 = {
			air                = true,
			class              = [[heatcloud]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				alwaysvisible      = true,
				heat               = 30,
				heatfalloff        = 1,
				maxheat            = 30,
				pos                = [[0, 5, 0]],
				size               = 150,
				sizegrowth         = 0,
				speed              = [[0, 0, 0]],
				texture            = [[greennovaexplo]],
			},
		},
		vapor = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 50,
			ground             = true,
			water              = true,
			underwater            = true,
			properties = {
				delay              = [[0]],
				explosiongenerator = [[custom:GREEN_VAPOR]],
				pos                = [[-140 r280, 1, -140 r280]],
			},
		},
	},
}
