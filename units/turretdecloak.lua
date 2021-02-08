return { 
	turretdecloak = {
		unitname                      = [[turretdecloak]],
		name                          = [[Clarity]],
		description                   = [[Cloak Detection System]],
		acceleration                  = 0,
		activateWhenBuilt             = true,
		brakeRate                     = 0,
		buildCostMetal                = 240,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 4,
		buildingGroundDecalSizeY      = 4,
		buildingGroundDecalType       = [[staticradar_aoplane.dds]],
		buildPic                      = [[turretanticloak.png]],
		canMove                       = false,
		category                      = [[FLOAT UNARMED]],
		collisionVolumeOffsets        = [[0 -32 0]],
		collisionVolumeScales         = [[32 90 32]],
		collisionVolumeType           = [[CylY]],
		corpse                        = [[DEAD]],
  
		customParams = {
			modelradius    = [[16]],

			priority_misc  = 2, -- High
		},
  
		energyUse                     = 6,
		explodeAs                     = [[SMALL_BUILDINGEX]],
		floater                       = true,
		footprintX                    = 2,
		footprintZ                    = 2,
		iconType                      = [[turretdecloak]],
		idleAutoHeal                  = 10,
		idleTime                      = 1800,
		levelGround                   = false,
		maxDamage                     = 2600,
		maxSlope                      = 36,
		maxVelocity                   = 0,
		minCloakDistance              = 150,
		noAutoFire                    = false,
		objectName                    = [[turretdecloak.3do]],
		script                        = [[turretdecloak.lua]],
		onoffable                     = true,
		selfDestructAs                = [[SMALL_BUILDINGEX]],
		sightDistance                 = 600,
		turnRate                      = 0,
		useBuildingGroundDecal        = true,
		workerTime                    = 0,
		yardMap                       = [[oooo]],
		weapons             = {
			{
				def                = [[DECLOAK]],
				mainDir            = [[0 -1 0]],
				maxAngleDif        = 150,
				onlyTargetCategory = [[LAND TURRET SHIP SWIM FLOAT HOVER]],
			},
		},
		weaponDefs = {
			DECLOAK    = {
				name                    = [[Cloak Disruptor Pulse]],
				areaOfEffect            = 1200,
				craterBoost             = 0,
				craterMult              = 0,
				damage                  = {
					default = 1,
				},

				customParams           = {
					light_radius = 0,
					--lups_explodespeed = 0.5,
					--lups_explodelife = 2.0,
					nofriendlyfire = "needs hax",
					puredecloaktime = 200,
					norealdamage = 1,
					stats_hide_damage = 1,
				},

				edgeeffectiveness       = 0.4,
				explosionGenerator      = [[custom:scanner_ping]],
				explosionSpeed          = 12,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				myGravity               = 10,
				noSelfDamage            = true,
				range                   = 10,
				reloadtime              = 2.0,
				soundHitVolume          = 1,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 230,
			},
		},
  
		sfxtypes               = {
			explosiongenerators = {
				[[custom:scanner_ping]],
			},
		},
		featureDefs                   = {
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[turretdecloak_dead.3do]],
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2c.s3o]],
			},

		},
	} 
}
