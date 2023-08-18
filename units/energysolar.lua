return { 
	energysolar = {
		unitname                      = "energysolar",
		name                          = "Solar Collector",
		description                   = "Small Powerplant (+3)",
		activateWhenBuilt             = true,
		buildCostMetal                = 75,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 6,
		buildingGroundDecalSizeY      = 6,
		buildingGroundDecalType       = "energysolar_aoplane.dds",
		buildPic                      = "energysolar.png",
		category                      = "SINK UNARMED STUPIDTARGET SOLAR",
		corpse                        = "DEAD",
		customParams                  = {
			bait_level_target = 1,
			pylonrange      = 100,
			aimposoffset    = "0 16 0",
			midposoffset    = "0 0 0",
			auto_close_time = 4, -- Unit AI off time.
			removewait      = 1,
			removestop      = 1,
			default_spacing = 0,
			outline_x = 150,
			outline_y = 110,
			outline_yoff = 20,
		},
		damageModifier                = 0.2,
		energyMake                    = 3,
		explodeAs                     = "SMALL_BUILDINGEX",
		footprintX                    = 5,
		footprintZ                    = 5,
		iconType                      = "energy_med",
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		maxDamage                     = 1000,
		maxSlope                      = 18,
		maxWaterDepth                 = 0,
		noAutoFire                    = false,
		objectName                    = "arm_solar.s3o",
		onoffable                     = true,
		script                        = "energysolar.lua",
		selfDestructAs                = "SMALL_BUILDINGEX",
		sightDistance                 = 150,
		useBuildingGroundDecal        = true,
		yardMap                       = "ooooooooooooooooooooooooo",
		featureDefs                   = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 5,
				footprintZ       = 5,
				object           = "arm_solar_dead.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 5,
				footprintZ       = 5,
				object           = "debris4x4a.s3o",
			},
		},
	} 
}
