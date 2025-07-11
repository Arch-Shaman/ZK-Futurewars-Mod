return { 
	dynriot1 = {
		unitname            = "dynriot1",
		name                = "Riot Commander",
		description         = "Heavy Combat Commander",
		acceleration        = 0.54,
		activateWhenBuilt   = true,
		autoHeal            = 5,
		brakeRate           = 2.25,
		buildCostMetal      = 1200,
		buildDistance       = 250,
		builder             = true,
		buildoptions        = {},
		buildPic            = "corcom.png",
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "LAND",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "45 54 45",
		collisionVolumeType    = "CylY",
		corpse              = "DEAD",
		customParams        = {
			level = "1",
			statsname = "dynriot1",
			soundok = "heavy_bot_move",
			soundselect = "bot_select",
			soundok_vol = "0.58",
			soundselect_vol = "0.5",
			soundbuild = "builder_start",
			commtype = "2",
			dynamic_comm   = 1,
			aimposoffset   = "0 5 0",
		},
		explodeAs           = "ESTOR_BUILDINGEX",
		footprintX          = 2,
		footprintZ          = 2,
		iconType            = "commander1",
		leaveTracks         = true,
		losEmitHeight       = 40,
		health              = 5500,
		maxSlope            = 36,
		speed               = 1.1,
		maxWaterDepth       = 5000,
		movementClass       = "AKBOT2",
		noChaseCategory     = "TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET",
		objectName          = "corcomAlt.s3o",
		script              = "dynriot.lua",
		selfDestructAs      = "ESTOR_BUILDINGEX",
		sfxtypes            = {
			explosiongenerators = {
				"custom:RAIDMUZZLE",
				"custom:LEVLRMUZZLE",
				"custom:RAIDMUZZLE",
			},
		},
		showNanoSpray       = false,
		showPlayerName      = true,
		sightDistance       = 500,
		trackOffset         = 0,
		trackStrength       = 8,
		metalStorage        = 500,
		trackStretch        = 1,
		trackType           = "ComTrack",
		trackWidth          = 22,
		turnRate            = 1377,
		upright             = true,
		workerTime          = 7,
		featureDefs         = {
			DEAD      = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "corcom_dead.s3o",
			},
			HEAP      = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2c.s3o",
			},
		},
	} 
}
