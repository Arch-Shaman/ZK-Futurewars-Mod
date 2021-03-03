return { 
	energyfusion = {
		unitname                      = [[energyfusion]],
		name                          = [[Fusion Reactor]],
		description                   = [[Medium Powerplant: +28e, increases over time]],
		activateWhenBuilt             = true,
		buildCostMetal                = 1000,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 6,
		BuildingGroundDecalSizeY      = 6,
		BuildingGroundDecalType       = [[energyfusion_ground.dds]],
		buildPic                      = [[energyfusion.png]],
		category                      = [[SINK UNARMED]],
		corpse                        = [[DEAD]],

		customParams                  = {
			pylonrange = 150,
			removewait = 1,
			removestop = 1,
			decay_rate = -0.025,
			decay_time = 2,
			decay_maxoutput = 2.4,
			initialrate = 0.8,
		},

		energyMake                    = 35,
		energyUse                     = 0,
		explodeAs                     = [[ESTOR_BUILDINGEX]],
		footprintX                    = 5,
		footprintZ                    = 4,
		iconType                      = [[energyfusion]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		maxDamage                     = 2200,
		maxSlope                      = 18,
		minCloakDistance              = 150,
		objectName                    = [[energyfusion.s3o]],
		script                        = "energyfusion.lua",
		selfDestructAs                = [[ESTOR_BUILDINGEX]],
		sightDistance                 = 273,
		useBuildingGroundDecal        = true,
		yardMap                       = [[ooooo ooooo ooooo ooooo]],

		featureDefs                   = {

			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 5,
				footprintZ       = 4,
				object           = [[energyfusion_dead.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 5,
				footprintZ       = 4,
				object           = [[debris4x4b.s3o]],
			},

		},

	} 
}
