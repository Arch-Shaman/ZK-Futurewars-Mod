return { 
	factoryhover = {
		unitname                      = "factoryhover",
		name                          = "Hovercraft Platform",
		description                   = "Produces Hovercraft",
		buildCostMetal                = Shared.FACTORY_COST,
		buildDistance                 = Shared.FACTORY_PLATE_RANGE,
		builder                       = true,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 15,
		buildingGroundDecalSizeY      = 15,
		buildingGroundDecalType       = "factoryhover_aoplane.dds",
		buildoptions     = {
			"hovercon",
			"hoverraid",
			"hoverheavyraid",
			"hoverskirm",
			"hoverassault",
			"hoverdepthcharge",
			"hoverriot",
			"hoverarty",
			"hoveraa",
		},
		buildPic         = "factoryhover.png",
		canMove          = true,
		canPatrol        = true,
		category         = "UNARMED FLOAT",
		collisionVolumeOffsets  = "0 -2 0",
		collisionVolumeScales   = "124 32 124",
		collisionVolumeType     = "cylY",
		selectionVolumeOffsets  = "0 0 0",
		selectionVolumeScales   = "130 20 130",
		selectionVolumeType     = "box",
		corpse           = "DEAD",
		customParams     = {
			ploppable = 1,
			sortName            = "8",
			modelradius         = "60",
			default_spacing     = 8,
			aimposoffset        = "0 0 -32",
			midposoffset        = "0 0 -32",
			solid_factory       = "8",
			unstick_help        = "1",
			unstick_help_buffer = 0.3,
			factorytab          = 1,
			shared_energy_gen   = 1,
			parent_of_plate     = "platehover",
			buggeroff_radius   = 40,
			buggeroff_offset   = 5,
			stats_show_death_explosion = 1,
			outline_x = 250,
			outline_y = 250,
			outline_yoff = 5,
		},
		energyUse        = 0,
		explodeAs        = "LARGE_BUILDINGEX",
		footprintX       = 8,
		footprintZ       = 12,
		iconType         = "fachover",
		levelGround      = false,
		health           = 5600 * 0.4,
		maxSlope         = 15,
		speed            = 0,
		moveState        = 1,
		noAutoFire       = false,
		objectName       = "factoryhover.s3o",
		script           = "factoryhover.lua",
		selfDestructAs   = "LARGE_BUILDINGEX",
		showNanoSpray    = false,
		sightDistance    = 500,
		useBuildingGroundDecal = true,
		waterline        = 1,
		workerTime       = Shared.FACTORY_BUILDPOWER,
		yardMap          = "xoooooox oooooooo oooooooo ooccccoo ooccccoo ooccccoo ooccccoo xoccccox yyyyyyyy yyyyyyyy yyyyyyyy yyyyyyyy",
		weapons             = {
			{
				def                = "ARMORFIELD",
				mainDir            = "0 0 0",
				onlyTargetCategory = "LAND TURRET SHIP SWIM FLOAT HOVER",
			},
		},
		weaponDefs = {
			ARMORFIELD    = {
				name                    = "Heavy Nanosheath Emitter",
				areaOfEffect            = 1200,
				craterBoost             = 0,
				craterMult              = 0,
				cameraShake				= 0,
				damage                  = {
					default = 100.0,
				},
				customParams           = {
					light_radius = 0,
					--lups_explodespeed = 0.5,
					--lups_explodelife = 2.0,
					stats_hide_damage = 1,
					lups_noshockwave = "1",
					armor_duration = 6,
					notimescaling = 1,
					grants_armor = 0.95,
					stats_hide_range = 1,
					stats_hide_dps = 1,
					norealdamage = 1,
				},
				edgeeffectiveness       = 0,
				explosionGenerator      = "custom:armor_ring600",
				explosionSpeed          = 800,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				myGravity               = 10,
				noSelfDamage            = true,
				range                   = 10,
				reloadtime              = 2.0,
				soundHitVolume          = 1,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 230,
			},
		},
		featureDefs      = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 8,
				footprintZ       = 7,
				object           = "factoryhover_dead.s3o",
				collisionVolumeOffsets  = "0 -2 -50",
				collisionVolumeScales   = "124 32 124",
				collisionVolumeType     = "cylY",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 8,
				footprintZ       = 7,
				object           = "debris4x4c.s3o",
			},
		},
	} 
}
