return { 
	droneheavyslowplus = {
		unitname            = "droneheavyslowplus",
		name                = "Viper v2",
		description         = "Advanced Battle Drone",
		acceleration        = 0.4,
		airHoverFactor      = 7,
		brakeRate           = 0.4,
		buildCostMetal      = 5,
		builder             = false,
		buildPic            = "droneheavyslow.png",
		canBeAssisted       = false,
		canFly              = true,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		canSubmerge         = false,
		category            = "GUNSHIP DRONE",
		collide             = false,
		cruiseAlt           = 200,
		explodeAs           = "TINY_BUILDINGEX",
		floater             = true,
		footprintX          = 2,
		footprintZ          = 2,
		hoverAttack         = true,
		iconType            = "droneskirm",
		idleAutoHeal        = 30, --10
		idleTime            = 80, --150
		maxDamage           = 720, --480
		speed               = 9.7, --7.8
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM SATELLITE SUB",
		objectName          = "battledrone.s3o",
		reclaimable         = false,
		repairable          = false, -- mostly not to waste constructor attention on area-repair; has regen anyway
		script              = "droneheavyslow.lua",
		selfDestructAs      = "TINY_BUILDINGEX",
		customParams        = {
			bait_level_target      = 2,
			is_drone = 1,
		},
		sfxtypes            = {
			explosiongenerators = {},
		},
		sightDistance       = 900, --600
		turnRate            = 1200, --1000
		upright             = true,
		weapons             = {
			{
				def                = "DISRUPTOR",
				badTargetCategory  = "FIXEDWING",
				mainDir            = "0 0 1",
				maxAngleDif        = 20,
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs          = {
			DISRUPTOR      = {
				name                    = "Disruptor Pulse Beam",
				areaOfEffect            = 48, --24
				beamdecay               = 0.9,
				beamTime                = 1/30,
				beamttl                 = 50,
				coreThickness           = 0.25,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					timeslow_damagefactor = "4",
					light_camera_height = 2000,
					light_color = "0.85 0.33 1",
					light_radius = 150,
				},
				damage                  = {
					default = 250.01,
				},
				explosionGenerator      = "custom:flash2purple",
				fireStarter             = 30,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				largeBeamLaser          = true,
				laserFlareSize          = 4.33,
				minIntensity            = 1,
				noSelfDamage            = true,
				range                   = 350, --320 --250
				reloadtime              = 1.2, --2.0
				rgbColor                = "0.3 0 0.4",
				soundStart              = "weapon/laser/heavy_laser5",
				soundStartVolume        = 3,
				soundTrigger            = true,
				sweepfire               = false,
				texture1                = "largelaser",
				texture2                = "flare",
				texture3                = "flare",
				texture4                = "smallflare",
				thickness               = 8,
				tolerance               = 18000,
				turret                  = false,
				weaponType              = "BeamLaser",
				weaponVelocity          = 500,
			},
		},
	} 
}
