return { 
	plateplane = {
		unitname                      = "plateplane",
		name                          = "Airplane Plate",
		description                   = "Parallel Unit Production",
		activateWhenBuilt             = false,
		buildCostMetal                = Shared.FACTORY_PLATE_COST,
		buildDistance                 = Shared.FACTORY_PLATE_RANGE,
		builder                       = true,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 10,
		buildingGroundDecalSizeY      = 10,
		buildingGroundDecalType       = "plateplane_aoplane.dds",
		buildoptions                  = {
			"planecon",
			"planefighter",
			"planeheavyfighter",
			"bomberprec",
			"bomberstrike",
			"bomberriot",
			"bomberdisarm",
			"bomberheavy",
			"planescout",
			"planelightscout",
		},
		buildPic                      = "plateplane.png",
		canMove                       = true,
		canPatrol                     = true,
		category                      = "FLOAT UNARMED",
		collisionVolumeOffsets        = "0 10 -8",
		collisionVolumeScales         = "60 34 34",
		collisionVolumeType           = "box",
		selectionVolumeOffsets        = "0 0 16",
		selectionVolumeScales         = "87 41 95",
		selectionVolumeType           = "box",
		corpse                        = "DEAD",
		customParams                  = {
			landflystate       = "1",
			factory_land_state = 1,
			sortName           = "4",
			modelradius        = "51", -- at 50 planefighter won't respond to Bugger Off calls
			midposoffset       = "0 0 -16",
			aimposoffset       = "0 15 -20",
			nongroundfac       = "1",
			default_spacing    = 4,
			child_of_factory   = "factoryplane",
			outline_x = 165,
			outline_y = 165,
			outline_yoff = 27.5,
		},
		energyUse                     = 0,
		explodeAs                     = "FAC_PLATEEX",
		fireState                     = 0,
		footprintX                    = 6,
		footprintZ                    = 7,
		iconType                      = "padair",
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		health                        = Shared.FACTORY_PLATE_HEALTH,
		maxSlope                      = 15,
		minCloakDistance              = 150,
		noAutoFire                    = false,
		objectName                    = "plate_plane.s3o",
		script                        = "plateplane.lua",
		selfDestructAs                = "FAC_PLATEEX",
		showNanoSpray                 = false,
		sightDistance                 = 273,
		useBuildingGroundDecal        = true,
		waterline                     = 0,
		workerTime                    = Shared.FACTORY_BUILDPOWER,
		weapons					= {
			{
				def					= "MISSILE",
				onlyTargetCategory	= "GUNSHIP FIXEDWING",
			},
		},
		weaponDefs             = {
			MISSILE = {
				name					= "AA Launcher",
				areaOfEffect			= 48,
				avoidFriendly			= false,
				canAttackGround			= false,
				cegTag					= "missiletrailblue",
				craterBoost				= 0,
				craterMult				= 0,
				cylinderTargeting		= 1,
				collideFriendly			= false,
				customParams			= {
					isaa					= "1",
					light_color				= "0.5 0.6 0.6",
					light_radius			= 75,
				},
				dance					= 55,
				damage					= {
					default					= 125.01,
				},
				explosionGenerator		= "custom:FLASH2",
				fireStarter				= 70,
				flightTime				= 14,
				impactOnly				= false,
				impulseBoost			= 0,
				impulseFactor			= 0,
				interceptedByShieldType	= 1,
				model					= "wep_m_phoenix.s3o",
				noSelfDamage			= true,
				range					= 900,
				reloadtime				= 54/30,
				smokeTrail				= true,
				soundHit				= "weapon/missile/rocket_hit",
				soundStart				= "missile_fire5",
				startVelocity			= 350,
				texture2				= "AAsmoketrail",
				fireTolerance 			= 65000,
				tolerance				= 65000,
				tracks					= true,
				turnRate				= 23000,
				turret					= true,
				weaponAcceleration		= 200,
				weaponType				= "MissileLauncher",
				weaponVelocity			= 950,
			},
		},
		yardMap                       = "oooooo oooooo oooooo oooooo oooooo oooooo oooooo",
		featureDefs                   = {
			DEAD = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 6,
				footprintZ       = 7,
				object           = "plate_plane_dead.s3o",
			},
			HEAP = {
				blocking         = false,
				footprintX       = 6,
				footprintZ       = 7,
				object           = "debris4x4c.s3o",
			},
		},
	} 
}
