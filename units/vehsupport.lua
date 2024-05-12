return { 
	vehsupport = {
		unitname               = "vehsupport",
		name                   = "Fractal",
		description            = "Deployable Disruptor Missile Rover (must stop to fire)",
		acceleration           = 0.15,
		brakeRate              = 0.3,
		buildCostMetal         = 160,
		builder                = false,
		buildPic               = "vehsupport.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND",
		collisionVolumeOffsets = "0 5 0",
		collisionVolumeScales  = "26 30 36",
		collisionVolumeType    = "box",
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "68 68 68",
		selectionVolumeType    = "ellipsoid",
		corpse                 = "DEAD",
		customParams           = {
			modelradius    = "13",
			aimposoffset   = "0 10 0",
			chase_everything = "1", -- Does not get stupidtarget added to noChaseCats
			outline_x = 80,
			outline_y = 80,
			outline_yoff = 12.5,
			okp_damage = 115,
		},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 3,
		footprintZ             = 3,
		iconType               = "vehiclesupport",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		health                 = 750,
		maxSlope               = 18,
		speed                  = 2.6,
		maxReverseVelocity     = 2.6,
		maxWaterDepth          = 22,
		movementClass          = "TANK3",
		moveState              = 0,
		noAutoFire             = false,
		noChaseCategory        = "TERRAFORM SATELLITE SUB",
		objectName             = "cormist_512.s3o",
		script                 = "vehsupport.lua",
		pushResistant          = 0,
		selfDestructAs         = "BIG_UNITEX",
		sfxtypes               = {
			explosiongenerators = {
				"custom:SLASHMUZZLE",
				"custom:SLASHREARMUZZLE",
			},
		},
		sightDistance          = 660,
		trackOffset            = -6,
		trackStrength          = 5,
		trackStretch           = 1,
		trackType              = "StdTank",
		trackWidth             = 34,
		turninplace            = 0,
		turnRate               = 420,
		weapons                = {

			{
				def                = "CORTRUCK_MISSILE",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
			{
				def 			   = "PARTICLEBEAM",
			},
		},
		weaponDefs             = {
			CORTRUCK_MISSILE = {
				name                    = "Frostshard Disruptor Missile",
				areaOfEffect            = 64,
				avoidFeature            = true,
				cegTag                  = "missiletrailpurple",
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					light_camera_height = 2000,
					light_radius = 200,
					timeslow_damagefactor = 1.25,
					numprojectiles1 = 8,
					projectile1 = "vehsupport_particlebeam",
					keepmomentum1 = 20,
					proxy = 1, 
					timeoutspawn = 0,
					spawndist = 90,
					groundimpact = 0,
					spawnsfx1 = 2049,
					damage_vs_shield = 80*8*0.5,
				},
				damage                  = {
					default = 115,
				},
				explosionGenerator      = "custom:riotballplus2_purple_small_darker",
				fireStarter             = 70,
				flightTime              = 3,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = "wep_m_frostshard.s3o",
				range                   = 690,
				reloadtime              = 1.5,
				smokeTrail              = true,
				soundHit                = "explosion/ex_med17",
				soundStart              = "weapon/missile/missile_fire11",
				startVelocity           = 109,
				trajectoryHeight        = 1,
				texture2                = "lightsmoketrail",
				tolerance               = 8000,
				tracks                  = true,
				turnRate                = 33000,
				turret                  = true,
				weaponAcceleration      = 200,
				weaponType              = "MissileLauncher",
				weaponVelocity          = 545,
			},
			PARTICLEBEAM = {
				name                    = "Superplastic Stream",
				beamDecay               = 0.85,
				beamTime                = 0.1,
				beamttl                 = 45,
				canattackground         = false,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					light_color = "0.5 0.0 0.5",
					light_radius = 80,
					damage_vs_shield = 84 * 0.25,
					bogus = 1,
					armorpiercing = 1/3,
					timeslow_damagefactor = 1.5,
				},
				damage                  = {
					default = 80.01,
				},
				dynDamageExp            = 1,
				dynDamageRange          = 135,
				dynDamageInverted       = false,
				explosionGenerator      = "custom:flash1red",
				fireStarter             = 100,
				impactOnly              = true,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				laserFlareSize          = 7.5,
				minIntensity            = 1,
				range                   = 125,
				reloadtime              = 0.3,
				rgbColor                = "0.5 0.1 0.5",
				sprayAngle              = 5000,
				soundStart              = "weapon/laser/mini_laser",
				soundStartVolume        = 6,
				thickness               = 5,
				tolerance               = 8192,
				turret                  = true,
				weaponType              = "BeamLaser",
			},
		},
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 3,
				footprintZ       = 3,
				object           = "cormist_dead_new.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = "debris3x3c.s3o",
			},
		},
	} 
}
