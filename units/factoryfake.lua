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
		weapons             = {
			{
				def                = "AI_HAX",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SUB SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs = {
			AI_HAX = {
				name                    = "Hackzy hax, you now can attack!",
				accuracy                = 0,
				areaOfEffect            = 32,
				avoidFriendly           = false,
				avoidFeature            = false,
				avoidGround             = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					restrict_in_widgets = 1,
					bogus = 1,
				},
				damage                  = {
					default = 0.0,
				},
				fireTolerance           = 1820, -- 10 degrees
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				impactOnly				= true,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				myGravity				= 0.03,
				range                   = 1,
				reloadtime              = 0.2,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 1600,
			},
		},
	} 
}
