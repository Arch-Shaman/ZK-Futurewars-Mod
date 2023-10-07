return {
	factoryamph = {
		unitname                      = "factoryamph",
		name                          = "Amphbot Factory",
		description                   = "Produces Amphibious Bots",
		activatewhenbuilt             = true,
		buildCostMetal                = Shared.FACTORY_COST,
		buildDistance                 = Shared.FACTORY_PLATE_RANGE,
		builder                       = true,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 10,
		buildingGroundDecalSizeY      = 10,
		buildingGroundDecalType       = "factoryamph_aoplane.dds",
		buildoptions     = {
			"amphcon",
			"amphraid",
			"amphskirm",
			"amphimpulse",
			"amphfloater",
			"amphriot",
			"amphsupport",
			"amphassault",
			"amphlaunch",
			"amphaa",
			"amphbomb",
			"amphtele",
		},
		buildPic         = "factoryamph.png",
		canMove          = true,
		canPatrol        = true,
		category         = "UNARMED SINK",
		collisionVolumeOffsets = "0 0 -16",
		collisionVolumeScales  = "104 70 36",
		collisionVolumeType    = "box",
		selectionVolumeOffsets = "0 0 14",
		selectionVolumeScales  = "104 70 96",
		selectionVolumeType    = "box",
		corpse           = "DEAD",
		customParams     = {
			modelradius    = "60",
			aimposoffset   = "0 0 -26",
			midposoffset   = "0 0 -10",
			sortName = "8",
			solid_factory = "3",
			default_spacing = 8,
			unstick_help   = 1,
			factorytab       = 1,
			shared_energy_gen = 1,
			cus_noflashlight = 1,
			parent_of_plate   = "plateamph",
			amph_regen = 60,
			amph_submerged_at = 40,
			teleporter = 1,
			teleporter_throughput = 550, -- mass per second
			teleporter_beacon_spawn_time = 10,
			teleporter_offset = 180,
			outline_x = 250,
			outline_y = 250,
			outline_yoff = 5,
		},
		energyUse        = 0,
		explodeAs        = "LARGE_BUILDINGEX",
		footprintX       = 7,
		footprintZ       = 7,
		iconType         = "facamph",
		idleAutoHeal     = 5,
		idleTime         = 1800,
		health           = 5600,
		maxSlope         = 15,
		moveState        = 1,
		noAutoFire       = false,
		objectName       = "factory2.s3o",
		script           = "factoryamph.lua",
		selfDestructAs   = "LARGE_BUILDINGEX",
		showNanoSpray    = false,
		sightDistance    = 500,
		useBuildingGroundDecal = true,
		workerTime       = Shared.FACTORY_BUILDPOWER,
		yardMap          = "ooooooo ooooooo ooooooo ccccccc ccccccc ccccccc ccccccc",
		featureDefs      = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 7,
				footprintZ       = 7,
				object           = "FACTORY2_DEAD.s3o",
				collisionVolumeOffsets = "0 0 -16",
				collisionVolumeScales  = "104 70 36",
				collisionVolumeType    = "box",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 7,
				footprintZ       = 7,
				object           = "debris4x4c.s3o",
			},
		},
	} 
}
