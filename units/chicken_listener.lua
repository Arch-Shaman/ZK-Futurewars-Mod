return {
	chicken_listener = {
		name                = "Listener",
		description         = "Burrowing Mobile Seismic Detector",
		acceleration        = 0.48,
		activateWhenBuilt   = true,
		brakeRate           = 1.23,
		builder             = false,
		buildPic            = "chicken_listener.png",
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "LAND UNARMED",

		customParams        = {
			chicken = "uwu",	
			outline_x = 85,
			outline_y = 85,
			outline_yoff = 9,
		},

		explodeAs           = "SMALL_UNITEX",
		floater             = false,
		footprintX          = 4,
		footprintZ          = 4,
		health              = 700,
		iconType            = "chicken",
		idleAutoHeal        = 20,
		idleTime            = 300,
		leaveTracks         = true,
		maxSlope            = 36,
		maxWaterDepth       = 22,
		metalCost           = 0,
		energyCost          = 0,
		buildTime           = 300,
		movementClass       = "KBOT4",
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET",
		objectName          = "chicken_listener.s3o",
		onoffable           = true,
		power               = 300,
		reclaimable         = false,
		seismicDistance     = 1000,
		selfDestructAs      = "SMALL_UNITEX",

		sfxtypes            = {
			explosiongenerators = {
				"custom:blood_spray",
				"custom:blood_explode",
				"custom:dirt",
			},
		},
		sightDistance       = 700,
		script              = "chicken_listener.lua",
		speed               = 69,
		trackOffset         = 0,
		trackStrength       = 8,
		trackStretch        = 1,
		trackType           = "ChickenTrack",
		trackWidth          = 50,
		turnRate            = 758,
		upright             = false,
		waterline           = 8,
		workerTime          = 0,
	}
}
