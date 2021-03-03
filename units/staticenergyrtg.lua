return { 
	staticenergyrtg = {
		unitname                      = [[staticenergyrtg]],
		name                          = [[RTG]],
		description                   = [[Medium Powerplant (+18e, decays over time) - HAZARDOUS]],
		activateWhenBuilt             = true,
		buildCostMetal                = 150,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 9,
		buildingGroundDecalSizeY      = 9,
		buildingGroundDecalType       = [[staticenergyrtg_aoplane.dds]],
		buildPic                      = [[staticenergyrtg.png]],
		category                      = [[UNARMED FLOAT]],
		collisionVolumeOffsets        = [[0 0 0]],
		collisionVolumeScales         = [[96 140 96]],
		collisionVolumeType           = [[CylY]],
		corpse                        = [[DEAD]],

		customParams                  = {
			removewait     = 1,
			removestop     = 1,
			priority_misc  = 2, -- High
			decay_time     = 2,
			decay_minoutput= 1,
			decay_initialrate = 10,
			decay_rate     = 0.025,
			modelradius    = [[60]],
			pylonrange = 100,
			realenergy = 18,
			dangerous_reclaim = [[gimme that radioactive goodness]],
		},
		energyMake                    = 1.8,
  		energyUse                     = 0,
		explodeAs                     = [[ATOMIC_BLAST]],
		floater                       = true,
		footprintX                    = 6,
		footprintZ                    = 6,
		iconType                      = [[energysingu]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		levelGround                   = false,
		maxDamage                     = 1400,
		maxSlope                      = 36,
		minCloakDistance              = 150,
		objectName                    = [[staticenergyrtg.dae]],
		script                        = [[staticenergyrtg.lua]],
		onoffable                     = false,
		selfDestructAs                = [[ATOMIC_BLAST]],
		useBuildingGroundDecal        = true,
		modelCenterOffset			  = [[0,70,0]],
		sightDistance                 = 200,
		yardMap                       = [[oooooooooooooooooooooooooooooooooooo]],
		
		featureDefs                   = {
			
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 6,
				footprintZ       = 6,
				object           = [[staticenergyrtg_wreck.dae]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2b.s3o]],
			},

		},
	}
}
