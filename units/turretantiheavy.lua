return { 
	turretantiheavy = {
		unitname                      = [[turretantiheavy]],
		name                          = [[Azimuth]],
		description                   = [[Tachyonic Anti-Heavy Turret - Requires connection to a 225 energy grid]],
		activateWhenBuilt             = true,
		buildCostMetal                = 4000,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 6,
		buildingGroundDecalSizeY      = 6,
		buildingGroundDecalType       = [[turretantiheavy_aoplane.dds]],
		buildPic                      = [[turretantiheavy.png]],
		category                      = [[SINK TURRET]],
		collisionVolumeOffsets        = [[0 0 0]],
		--collisionVolumeScales         = [[75 100 75]],
		--collisionVolumeType           = [[CylY]],
		corpse                        = [[DEAD]],

		customParams                  = {
			keeptooltip    = [[any string I want]],
			neededlink     = 300,
			pylonrange     = 50,
			aimposoffset   = [[0 32 0]],
			midposoffset   = [[0 0 0]],
			modelradius    = [[40]],
			bait_level_default = 3,
			--dontfireatradarcommand = '0',
		},

		damageModifier                = 0.15,
		explodeAs                     = [[ESTOR_BUILDING]],
		footprintX                    = 4,
		footprintZ                    = 4,
		iconType                      = [[fixedtachyon]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		losEmitHeight                 = 65,
		maxDamage                     = 8000,
		maxSlope                      = 18,
		maxWaterDepth                 = 0,
		minCloakDistance              = 150,
		noChaseCategory               = [[FIXEDWING LAND SHIP SWIM GUNSHIP SUB HOVER]],
		objectName                    = [[arm_annihilator.s3o]],
		onoffable                     = true,
		radarDistance                 = 2850,
		radarEmitHeight               = 100,
		script                        = [[turretantiheavy.lua]],
		selfdestructas                = [[ESTOR_BUILDING]],
		sfxtypes               = {
		},
		sightDistance                 = 560,
		useBuildingGroundDecal        = true,
		yardMap                       = [[oooo oooo oooo oooo]],

		weapons                       = {

			{
				def                = [[ATA]],
				badTargetCategory  = [[FIXEDWING GUNSHIP]],
				onlyTargetCategory = [[SWIM LAND SHIP SINK TURRET FLOAT GUNSHIP FIXEDWING HOVER]],
			},        
			{
				def                = [[BOGUS_PHASER]],
				badTargetCategory  = [[]],
				onlyTargetCategory = [[]],
			},  
		},

		weaponDefs                    = {

			ATA = { -- changing the name causes an Vanilla gadget to become borked
				name                    = [[Tachyonic Feedback Loop]],
				areaOfEffect            = 20,
				avoidFeature            = false,
				avoidNeutral            = false,
				beamTime                = 1/30, --llt has a rof of 10/s. domi has 30/s. 
				beamttl                 = 6,
				coreThickness           = 0.5,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					light_color = [[1.6 1.05 2.25]],
					light_radius = 320,
					
					stats_hide_damage = 1, -- continuous laser
					stats_hide_reload = 1,
					
					--poweruse_overdrive_
					
					dmg_scaling = 1/30,
					--dmg_scaling_overdrive_subtrahend = 225,
					--dmg_scaling_overdrive_divisor = 420,
					--dmg_scaling_overdrive_exponent = 0.5,
					dmg_scaling_max = 10000,
					--dmg_scaling_max_overdrive_subtrahend = 0,
					--dmg_scaling_max_overdrive_divisor = 50,
					--dmg_scaling_max_overdrive_exponent = 1,
					dmg_scaling_keeptime = 4,
					dmg_scaling_falloff = 10000,
					
					reload_override = 20,
						
					ceg_d_override = 2,
					explosion_generator = [[ataalasergrow]],
				},

				damage                  = {
					default = 40.1,
				},

				explosionGenerator      = [[custom:ataalaser]],
				fireTolerance           = 8192, -- 45 degrees
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 0, --maybe set back to 1?
				largeBeamLaser          = true,
				laserFlareSize          = 16.94,
				leadLimit               = 18,
				minIntensity            = 1,
				noSelfDamage            = true,
				range                   = 1200,
				reloadtime              = 1/30,
				rgbColor                = [[1 0.25 0]],
				soundStart              = [[weapon/laser/heavy_laser6]],
				soundStartVolume        = 15,
				texture1                = [[largelaser]],
				texture2                = [[flare]],
				texture3                = [[flare]],
				texture4                = [[smallflare]],
				thickness               = 16.94,
				tolerance               = 10000,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 1400,
			},

		},

		featureDefs                   = {

			DEAD = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 4,
				footprintZ       = 4,
				object           = [[arm_annihilator_dead.s3o]],
			},
			HEAP = {
				blocking         = false,
				footprintX       = 4,
				footprintZ       = 4,
				object           = [[debris3x3a.s3o]],
			},

		},
	} 
}
