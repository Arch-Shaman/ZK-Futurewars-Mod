return { 
	planecon = {
		unitname            = "planecon",
		name                = "Crane",
		description         = "Construction Aircraft",
		acceleration        = 0.22,
		airStrafe           = 0,
		brakeRate           = 0.44,
		buildCostMetal      = 250,
		buildDistance       = 250,
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "42 42 42",
		selectionVolumeType    = "ellipsoid",
		builder             = true,
		buildoptions        = {},
		buildPic            = "planecon.png",
		buildRange3D        = false,
		canFly              = true,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		canSubmerge         = false,
		category            = "GUNSHIP UNARMED",
		collisionVolumeOffsets        = "0 0 -5",
		collisionVolumeScales         = "42 8 42",
		collisionVolumeType           = "cylY",
		collide             = true,
		corpse              = "DEAD",
		cruiseAlt           = 120,

		customParams        = {
			airstrafecontrol = "0",
			modelradius    = "10",
			midposoffset   = "0 4 0",
			specialreloadtime = "1200",
			boost_speed_mult = 3.5,
			boost_accel_mult = 6,
			boost_duration = 40, -- frames
		},

		energyUse           = 0,
		explodeAs           = "GUNSHIPEX",
		floater             = true,
		footprintX          = 2,
		footprintZ          = 2,
		hoverAttack         = true,
		iconType            = "builderair",
		idleAutoHeal        = 5,
		idleTime            = 1800,
		health              = 1200,
		speed               = 4,
		minCloakDistance    = 75,
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET",
		objectName          = "crane.s3o",
		script              = "planecon.lua",
		selfDestructAs      = "GUNSHIPEX",
		showNanoSpray       = false,
		sightDistance       = 375,
		turnRate            = 500,
		workerTime          = 7.5,
		sfxtypes               = {
			explosiongenerators = {
				"custom:MUZZLE_ORANGE",
				"custom:FF_PUFF",
				"custom:BEAMWEAPON_MUZZLE_RED",
				"custom:FLAMER",
			},
		},
		featureDefs         = {

			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "crane_d.dae",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2b.s3o",
			},
		},
	} 
}
