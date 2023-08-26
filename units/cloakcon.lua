return { 
	cloakcon = {
		unitname               = "cloakcon",
		name                   = "Mirage",
		description            = "Cloaked Construction Bot",
		acceleration           = 1.5,
		activateWhenBuilt      = true,
		brakeRate              = 9.0,
		buildCostMetal         = 100,
		buildDistance          = 250,
		builder                = true,
		buildoptions           = {},
		buildPic               = "cloakcon.png",
		canMove                = true,
		canPatrol              = true,
		category               = "LAND UNARMED",
		canCloak               = true,
		cloakCost              = 0,
		cloakCostMoving        = 0,
		collisionVolumeOffsets = "0 4 0",
		collisionVolumeScales  = "28 40 28",
		collisionVolumeType    = "cylY",
		corpse                 = "DEAD",
		customParams           = {
			modelradius    = "14",
			cus_noflashlight = 1,
			cloakregen = 10,
			area_cloak = 1,
			area_cloak_init = 0,
			area_cloak_upkeep = 4,
			area_cloak_radius = 300,
			area_cloak_decloak_distance = 75,
			area_cloak_self_decloak_distance = 40,
			area_cloak_grow_rate = 350,
			area_cloak_shrink_rate = 1400,
			recloaktime = 60,
			priority_misc = 2, -- High
			cloakstrikeduration = 30,
			cloakstrikespeed = 1.25,
			cloakstrikeslow = 0.85,
		},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = "builder",
		idleAutoHeal           = 0,
		idleTime               = 1800,
		initCloaked            = true,
		leaveTracks            = true,
		health                 = 270,
		maxSlope               = 36,
		speed                  = 2.0,
		maxWaterDepth          = 22,
		minCloakDistance       = 40,
		movementClass          = "KBOT2",
		objectName             = "spherecon.s3o",
		radarDistanceJam       = 450,
		script                 = "cloakcon.lua",
		selfDestructAs         = "BIG_UNITEX",
		showNanoSpray          = false,
		sightDistance          = 375,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = "ComTrack",
		trackWidth             = 18,
		turnRate               = 2640,
		upright                = true,
		workerTime             = 5,
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "spherejeth_dead.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2c.s3o",
			},
		},
	} 
}
