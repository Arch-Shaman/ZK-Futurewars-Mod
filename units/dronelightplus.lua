return { 
	dronelight = {
		unitname            = "dronelightplus",
		name                = "Firefly v2",
		description         = "Attack Drone",
		acceleration        = 0.8,
		airHoverFactor      = 15,
		brakeRate           = 0.8,
		buildCostMetal      = 5,
		builder             = false,
		buildPic            = "dronelight.png",
		canBeAssisted       = false,
		canFly              = true,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		canSubmerge         = false,
		category            = "GUNSHIP DRONE",
		collide             = false,
		cruiseAlt           = 120,
		explodeAs           = "TINY_BUILDINGEX",
		floater             = true,
		footprintX          = 2,
		footprintZ          = 2,
		hoverAttack         = true,
		iconType            = "droneraid",
		idleAutoHeal        = 15, --10
		idleTime            = 80, --150
		health              = 360, --240
		speed               = 10.0, --8.0
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM SATELLITE SUB",
		objectName          = "attackdrone.s3o",
		reclaimable         = false,
		repairable          = false, -- mostly not to waste constructor attention on area-repair; has regen anyway
		refuelTime          = 10,
		script              = "dronelight.lua",
		selfDestructAs      = "TINY_BUILDINGEX",
		customParams        = {
			bait_level_target      = 1,
			is_drone = 1,
		},
		sfxtypes            = {
			explosiongenerators = {},
		},
		sightDistance       = 800, --600
		turnRate            = 3900,
		upright             = true,
		weapons             = {
			{
				def                = "LASER",
				badTargetCategory  = "FIXEDWING",
				mainDir            = "0 0 1",
				maxAngleDif        = 130,
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs          = {
			LASER      = {
				name                    = "Light Particle Beam",
				beamDecay               = 0.9,
				beamTime                = 1/30,
				beamttl                 = 20,
				coreThickness           = 0.25,
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting       = 1,
				customParams            = {
					light_camera_height = 1800,
					light_color = "0.917 0.454 0.0039",
					light_radius = 40,
					combatrange = 150,
				},
				damage                  = {
					default = 25.1, --20.1
				},
				explosionGenerator      = "custom:drone_flash17",
				fireStarter             = 100,
				impactOnly              = true,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				laserFlareSize          = 3.25,
				minIntensity            = 1,
				range                   = 230, --200
				reloadtime              = 5/30, --7/30
				rgbColor                = "0.917 0.454 0.0039",
				soundStart              = "weapon/laser/mini_laser",
				soundStartVolume        = 4,
				texture1                = "largelaser",
				thickness               = 2.165,
				tolerance               = 8192,
				turret                  = true,
				weaponType              = "BeamLaser",
			},
		},
	} 
}
