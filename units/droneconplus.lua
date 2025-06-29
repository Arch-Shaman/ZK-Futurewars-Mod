return { 
	droneconplus = {
		unitname            = "droneconplus",
		name                = "Responder v2",
		description         = "Repair Drone",
		acceleration        = 0.3,
		airHoverFactor      = 4,
		brakeRate           = 0.24,
		buildCostMetal      = 5,
		builder             = true,
		canAssist           = false,
		buildPic            = "dronecon.png",
		canBeAssisted       = false,
		canFly              = true,
		canGuard            = true,
		canMove             = true,
		canReclaim          = false,
		canPatrol           = true,
		canSubmerge         = false,
		category            = "GUNSHIP DRONE",
		collide             = false,
		cruiseAlt           = 85,
		explodeAs           = "TINY_BUILDINGEX",
		floater             = true,
		footprintX          = 2,
		footprintZ          = 2,
		hoverAttack         = true,
		iconType            = "dronecon",
		idleAutoHeal        = 30, --10
		idleTime            = 80, --120
		health              = 700, --350
		speed               = 8.5, --6.5
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM SATELLITE SUB",
		objectName          = "condrone.dae",
		reclaimable         = false,
		repairable          = false, -- mostly not to waste constructor attention on area-repair; has regen anyway
		script              = "dronecon.lua",
		selfDestructAs      = "TINY_BUILDINGEX",
		customParams        = {
			bait_level_target      = 2,
			is_drone = 1,
		},
		sfxtypes            = {
			explosiongenerators = {},
		},
		sightDistance       = 800, --500
		turnRate            = 792,
		workerTime          = 40, --20
		upright             = true,
		weapons             = {
			{
				def                = "SHIELD",
			},
		},
		weaponDefs          = {
			SHIELD      = {
				name                    = "Energy Shield",
				damage                  = {
					default = 10,
				},
				exteriorShield          = true,
				shieldAlpha             = 0.2,
				shieldBadColor          = "1 0.1 0.1 1",
				shieldGoodColor         = "0.1 0.1 1 1",
				shieldInterceptType     = 3,
				shieldPower             = 3000, --2000
				shieldPowerRegen        = 50, --20
				shieldPowerRegenEnergy  = 12,
				shieldRadius            = 200, --150
				shieldRepulser          = true,
				shieldStartingPower     = 3000, --2000
				smartShield             = true,
				visibleShield           = false,
				visibleShieldRepulse    = false,
				weaponType              = "Shield",
			},
		},
	} 
}
