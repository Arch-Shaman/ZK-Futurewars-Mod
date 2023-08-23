return { 
	spideraa = {
		unitname               = "spideraa",
		name                   = "Lynx",
		description            = "Heavy AA Laser Spider",
		acceleration           = 0.66,
		brakeRate              = 3.96,
		buildCostMetal         = 380,
		buildPic               = "spideraa.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND",
		corpse                 = "DEAD",
		customParams           = {
			bait_level_default = 3,
			cus_noflashlight = 1,
			dontfireatradarcommand = '0',
			aimdelay = 60,
		},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = "spideraa",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 1600,
		maxSlope               = 72,
		maxVelocity            = 2.3,
		maxWaterDepth          = 22,
		movementClass          = "TKBOT3",
		moveState              = 0,
		noChaseCategory        = "TERRAFORM LAND SINK TURRET SHIP SATELLITE SWIM FLOAT SUB HOVER",
		objectName             = "tarantula.s3o",
		script                 = "spideraa.lua",
		selfDestructAs         = "BIG_UNITEX",
		sightDistance          = 900,
		trackOffset            = 0,
		trackStrength          = 10,
		trackStretch           = 1,
		trackType              = "ChickenTrackPointyShort",
		trackWidth             = 55,
		turnRate               = 1125,
		weapons                = {
			{
				def                = "AA",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "GUNSHIP FIXEDWING",
			},
			{
				def                = "TRACKER",
				badTargetCategory  = "FIXEDWING",
				slaveTo			   = 1,
				onlyTargetCategory = "GUNSHIP FIXEDWING",
			},
		},
		weaponDefs             = {
			AA = {
				name                    = "Heavy AA Laser",
				areaOfEffect            = 20,
				avoidFeature = false,
				avoidGround  = false,
				canAttackGround         = false,
				beamDecay               = 0.9,
				beamTime                = 6/30,
				beamTTL                 = 30,
				craterBoost             = 0,
				craterMult              = 0,
				coreThickness           = 0.9,
				customParams            = {
					burst = Shared.BURST_RELIABLE,
					aimdelay = 60, -- 2 seconds
					light_color = "0.203 0.631 0.196",
					light_radius = 320,
					reveal_unit = 8,
					allowedpitcherror = 15,
					allowedheadingerror = 45,
					isaa = "1",
					aimdelayresettime = 20,
				},
				damage                  = {
					default = 2000.1,
				},
				explosionGenerator      = "custom:atagreen_flattened",
				fireTolerance           = 8192, -- 45 degrees
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 1.0,
				interceptedByShieldType = 1,
				largeBeamLaser          = true,
				laserFlareSize          = 13,
				leadLimit               = 18,
				minIntensity            = 0.8,
				noSelfDamage            = true,
				range                   = 1500,
				reloadtime              = 4.0,
				rgbColor                = "0.203 0.631 0.196",
				soundStart              = "weapon/laser/aa_laser",
				soundStartVolume        = 15,
				sweepfire               = true,
				texture1                = "largelaser",
				texture2                = "flare",
				texture3                = "flare",
				texture4                = "smallflare",
				thickness               = 8,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = "BeamLaser",
				weaponVelocity          = 1500,
			},
			TRACKER = {
				name                    = "Tracking Beam",
				areaOfEffect            = 20,
				collideEnemy = true,
				avoidFeature = false,
				collideFeature = true,
				canAttackGround         = false,
				beamTime                = 3/30,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					--burst = Shared.BURST_RELIABLE,
					stats_hide_damage = 1, -- continuous laser
					stats_hide_reload = 1,
					light_color = "1.25 0 0",
					light_radius = 120,
					norealdamage = 1,
				},
				damage                  = {
					default = 0,
				},
				--explosionGenerator      = "custom:flash1red",
				fireTolerance           = 8192, -- 45 degrees
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				largeBeamLaser          = true,
				laserFlareSize          = 2,
				leadLimit               = 18,
				minIntensity            = 0.01,
				noSelfDamage            = true,
				range                   = 1500,
				reloadtime              = 1/30,
				rgbColor                = "0.7 0 0",
				soundStart              = "weapon/laser/tracker",
				soundStartVolume        = 15,
				sweepfire               = true,
				texture1                = "tracker",
				texture2                = "flare",
				--texture3                = "flare",
				--texture4                = "smallflare",
				thickness               = 2,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = "BeamLaser",
				weaponVelocity          = 1500,
			},
		},
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 3,
				footprintZ       = 3,
				collisionVolumeOffsets = "0 -5 0",
				collisionVolumeScales  = "40 30 40",
				collisionVolumeType    = "ellipsoid",
				object           = "tarantula_dead.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = "debris3x3a.s3o",
			},
		},
	} 
}
