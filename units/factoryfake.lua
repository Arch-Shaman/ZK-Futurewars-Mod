return { 
	factoryfake = {
		name                          = "Fake Factory",
		description                   = "YOU SHOULD NOT SEE THIS OR THE GAME IS BROKEN.",
		activateWhenBuilt             = false,
		builder                       = true,
		buildDistance                 = 1,
		buildPic                      = "levelterra.png",
		buildOptions                  = {
			"fakeunit",
		},
		
		canMove                       = true,
		canPatrol                     = true,
		canAttack					  = true,
		category                      = "STUPIDTARGET",
		customparams                  = {
			completely_hidden = 1,
			buggeroff_radius = 0, -- completely disable this because fake factories dont build anything
			factorytab = 1,
		},
		footprintX                    = 1,
		footprintZ                    = 1,
		health                        = 100000,
		iconType                      = "none",
		levelGround                   = false,
		maxSlope                      = 255,
		maxWaterDepth                 = 99999,
		metalCost                     = 0.01,
		noAutoFire                    = false,
		noChaseCategory               = "FIXEDWING LAND SINK TURRET SHIP SATELLITE SWIM GUNSHIP FLOAT SUB HOVER",
		objectName                    = "debris1x1b.s3o",
		onoffable                     = false,
		script                        = "nullfactoryscript.lua",
		showNanoSpray                 = false,
		selfDestructCountdown         = 0,
		sightDistance                 = 0.1,
		useBuildingGroundDecal        = false,
		workerTime                    = 0.1,
		yardMap                       = "c",
	} 
}
