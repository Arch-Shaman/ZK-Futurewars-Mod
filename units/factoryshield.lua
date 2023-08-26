return { 
	factoryshield = {
		unitname                      = "factoryshield",
		name                          = "Shieldbot Factory",
		description                   = "Produces Tough, Shielded Robots",
		buildCostMetal                = Shared.FACTORY_COST,
		buildDistance                 = Shared.FACTORY_PLATE_RANGE,
		builder                       = true,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 12,
		buildingGroundDecalSizeY      = 12,
		buildingGroundDecalType       = "factoryshield_aoplane.dds",
		buildoptions                  = {
			"shieldcon",
			"shieldscout",
			"shieldraid",
			"shieldskirm",
			"shieldassault",
			"shieldriot",
			"shieldfelon",
			"shieldarty",
			"shieldaa",
			"shieldbomb",
			"shieldshield",
		},
		buildPic                      = "factoryshield.png",
		canMove                       = true,
		canPatrol                     = true,
		category                      = "SINK UNARMED",
		corpse                        = "DEAD",
		customParams                  = {
			sortName          = "1",
			midposoffset      = "0 0 -24",
			solid_factory     = "6",
			unstick_help      = "1",
			factorytab        = 1,
			shared_energy_gen = 1,
			parent_of_plate   = "plateshield",
			priority_misc = 0, -- low
			outline_x = 250,
			outline_y = 250,
			outline_yoff = 5,
			buggeroff_offset    = 28,
		},
		energyUse                     = 0,
		explodeAs                     = "LARGE_BUILDINGEX",
		footprintX                    = 7,
		footprintZ                    = 9,
		iconType                      = "facwalker",
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		health                        = 4000,
		maxSlope                      = 15,
		maxWaterDepth                 = 0,
		minCloakDistance              = 150,
		moveState                     = 1,
		noAutoFire                    = false,
		objectName                    = "factory.s3o",
		script                        = "factoryshield.lua",
		selfDestructAs                = "LARGE_BUILDINGEX",
		showNanoSpray                 = false,
		sightDistance                 = 500,
		sonarDistance		          = 500,
		useBuildingGroundDecal        = true,
		workerTime                    = Shared.FACTORY_BUILDPOWER,
		yardMap                       = "ooooooo occccco occccco occccco occccco occccco yyyyyyy yyyyyyy yyyyyyy",
		weapons						  = {
			{
				def                = "SHIELD",
			},
		},
		weaponDefs					  = {
			SHIELD = {
				name                    = "Energy Shield",	
				damage                  = {	
					default = 10,	
				},	
				exteriorShield          = true,	
				shieldAlpha             = 0.2,	
				shieldBadColor          = "1 0.1 0.1 1",	
				shieldGoodColor         = "0.1 0.1 1 1",	
				shieldInterceptType     = 3,	
				shieldPower             = 6000,	
				shieldPowerRegen        = 40,	
				shieldPowerRegenEnergy  = 6,	
				shieldRadius            = 800,	
				shieldRepulser          = false,	
				shieldStartingPower     = 6000,	
				smartShield             = true,	
				visibleShield           = false,	
				visibleShieldRepulse    = false,	
				weaponType              = "Shield",
			},
		},
		featureDefs                   = {

			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 5,
				footprintZ       = 6,
				object           = "factory_dead.s3o",
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 5,
				footprintZ       = 5,
				object           = "debris4x4a.s3o",
			},
		},
	} 
}
