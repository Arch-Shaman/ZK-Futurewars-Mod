-- Idea shamelessly stolen from Tankium's More Units mod.
-- TODO: 
-- * Replace model at some point or get the weapons to actually work.

return {
	factorycomm = {
		health    = 10000,
		unitname = "factorycomm",
		name = "Commander Chassis Factory",
		description = "Produces Commanders",
		objectname = "pw_dropfac.dae",
		icontype = "pw_dropfac",
		script = "pw_dropfac.lua",
		footprintx = 20,
		footprintz = 16,
		buildCostMetal                = Shared.FACTORY_COST * 2,
		buildDistance                 = Shared.FACTORY_PLATE_RANGE,
		builder                       = true,
		buildpic			          = "pw_dropfac.png",
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 20,
		buildingGroundDecalSizeY      = 16,
		category			          = "UNARMED SINK LAND",
		customParams = {
		},
		energyUse                     = 0,
		explodeAs                     = "LARGE_BUILDINGEX",
		footprintX                    = 20,
		footprintZ                    = 16,
		collisionvolumescales         = "275 120 215",
		showNanoSpray                 = false,
		canmove                       = true,
		canattack                     = true,
		workertime                    = 10,
		maxSlope                      = 15,
		maxDepth					  = 2500,
		sightDistance    			  = 500,
		sonarDistance		          = 500,
		buildoptions                  = { 		
			"dynsupport0",
			"dynrecon0",
			"dynassault0",
			"dynstrike0",
			"dynriot0",
		},
		yardmap                       = "ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo ooooooooyyyyyyoooooo",
		featureDefs                   = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "pw_dropfac_dead.dae",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris8x8b.s3o",
			},
		},
	},
}