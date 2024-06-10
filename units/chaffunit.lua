return {
	chaffunit = {
		name                  = "Chaff",
		description           = "I exist for you to waste your shots at.",
		acceleration          = 1,
		brakeRate             = 0.8,
		autoheal              = 900000,
		builder               = false,
		buildPic              = "levelterra.png",
		canGuard              = true,
		canMove               = true,
		canPatrol             = true,
		canSubmerge           = false,
		canSelfDestruct       = false,
		category              = "FAKEUNIT",
		
		customParams          = {
			dontcount         = 1,
			dontkill          = 1,
			completely_hidden = 1, -- for widget-senpai not to notice me >w<
			singuimmune = 1,
		},
		
		floater               = true,
		footprintX            = 3,
		footprintZ            = 3,
		health                = 900000,
		hoverAttack           = true,
		iconType              = [[none]],
		idleAutoHeal          = 10,
		idleTime              = 300,
		levelGround           = false,
		maxWaterDepth         = 0,
		metalCost             = 0.45,
		minCloakDistance      = 9,
		noAutoFire            = false,
		objectName            = "debris1x1b.s3o",
		script                = "fakeunit_los.lua",
		sightDistance         = 0,
		speed                 = 150,
		stealth               = true,
		turnRate              = 0,
	}
}
