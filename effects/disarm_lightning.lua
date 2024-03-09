local circleString = "r%.5f y10 -1 x10x10 y10 %d a10 y10      r6.283 y11 -3.1415 a11 y11 -0.5x11x11         y0 0.0417x11x11x11x11 y1 -0.00139x11x11x11x11x11x11 y2 0.0000248015x11x11x11x11x11x11x11x11 y3 -0.000000275573x11x11x11x11x11x11x11x11x11x11 y4 0.00000000208768x11x11x11x11x11x11x11x11x11x11x11x11 y5 1 a0 a1 a2 a3 a4 a5 x10, %d, -0.1667x11x11x11 y0 0.00833x11x11x11x11x11 y1 -0.000198412x11x11x11x11x11x11x11 y2 0.00000275573192x11x11x11x11x11x11x11x11x11 y3 -0.00000002505210838x11x11x11x11x11x11x11x11x11x11x11 y4 0 a11 a0 a1 a2 a3 a4 x10"

local function GetCircle(radius, yPos)
	radius = radius
	local weightedRadius = radius^(1/2)
	return circleString:format(weightedRadius, radius, yPos)
end

return {
	["disarm_explosion_600"] = {
		usedefaultexplosions = false,
		sphere = {
			air                = true,
			class              = [[CSpherePartSpawner]],
			count              = 1,
			ground             = true,
			water              = true,
			underwater 		 = true,
			properties = {
				alpha              = 0.5,
				color              = [[0.75 0.75 0.75 0.3]],
				expansionspeed     = 7.5,
				ttl                = 40,
			},
		},
		electricstorm = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[5]],
				explosiongenerator = [[custom:disarmplosion_smallbolts_centered_alwaysshow]],
				pos                = GetCircle(37, 0),
			},
		},
		electricstorm2 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 10,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[10]],
				explosiongenerator = [[custom:disarmplosion_smallbolts_centered_alwaysshow]],
				pos                = GetCircle(75, 0),
			},
		},
		electricstorm3 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 10,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[15]],
				explosiongenerator = [[custom:disarmplosion_smallbolts_centered_alwaysshow]],
				pos                = GetCircle(112, 0),
			},
		},
		electricstorm4 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 10,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[20]],
				explosiongenerator = [[custom:disarmplosion_smallbolts_centered_alwaysshow]],
				pos                = GetCircle(150, 0),
			},
		},
		electricstorm5 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 10,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[25]],
				explosiongenerator = [[custom:disarmplosion_smallbolts_centered_alwaysshow]],
				pos                = GetCircle(187, 0),
			},
		},
		electricstorm5 = {
			air                = true,
			class              = [[CExpGenSpawner]],
			count              = 10,
			ground             = true,
			water              = true,
			properties = {
				delay              = [[30]],
				explosiongenerator = [[custom:disarmplosion_smallbolts_centered_alwaysshow]],
				pos                = GetCircle(225, 0),
			},
		},
	},
	["disarmplosion_smallbolts_centered_alwaysshow"] = {
		["electric thingies2"] = {
			air                = true,
			class              = [[CSimpleParticleSystem]],
			count              = 1,
			ground             = true,
			water              = true,
			properties = {
				airdrag            = 0.1,
				colormap           = [[0.7 0.7 0.7 0.01  1 1 1 0.01   0.7 0.7 0.7 0.01  1 1 1 0.01  0.7 0.7 0.7 0.01 0 0 0 0.01]],
				directional        = true,
				emitrot            = 0,
				emitrotspread      = 80,
				emitvector         = [[0, 1, 0]],
				gravity            = [[0, 0, 0]],
				numparticles       = [[r2 1]],
				particlelife       = 3,
				particlelifespread = 4,
				particlesize       = 15,
				particlesizespread = 15,
				particlespeed      = 20,
				particlespeedspread = 20,
				pos                = [[0, 0, 0]],
				sizegrowth         = 0,
				sizemod            = 1.0,
				texture            = [[lightb]],
			},
		},
	},
}
