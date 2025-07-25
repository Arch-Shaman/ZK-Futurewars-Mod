return { 
	staticheavyshield = {
		unitname                      = "staticheavyshield",
		name                          = "Safeguard",
		description                   = "Massive Area Shield",
		activateWhenBuilt             = true,
		buildCostMetal                = 5000,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 4,
		buildingGroundDecalSizeY      = 4,
		buildingGroundDecalType       = "staticshield_aoplane.dds",
		buildPic                      = "staticheavyshield.png",
		canMove                       = false,
		category                      = "SINK UNARMED",
		collisionVolumeOffsets        = "0 0 0",
		collisionVolumeScales         = "60 70 60",
		collisionvolumetype	          = "CylY",
		corpse                        = "DEAD",
		explodeAs                     = "BIG_UNITEX",
		floater                       = true,
		footprintX                    = 4,
		footprintZ                    = 4,
		iconType                      = "defenseshield",
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		levelGround                   = false,
		health                        = 6000,
		maxSlope                      = 36,
		speed                         = 0,
		noAutoFire                    = false,
		objectName                    = "pw_artefact.dae",
		onoffable                     = true,
		script                        = "staticheavyshield.lua",
		selfDestructAs                = "BIG_UNITEX",
		sightDistance                 = 200,
		useBuildingGroundDecal        = true,
		yardMap                       = "oooo oooo oooo oooo",
		customParams        = {
			removewait     = 1,
			priority_misc = 1, -- Medium
			unarmed       = true,
			soundselect = "cloaker_select",
			shield_power_gfx_override = 10000,
			neededlink     = 200,
			pylonrange     = 150,
    		superweapon    = 1,
			keeptooltip = "by janitor's request, please don't remove the tooltips Machine God.",
		},
		weapons                       = {
			{
				def         = "BIG_SHIELD",
			},
		},
		weaponDefs                    = {
			BIG_SHIELD = {
				name                    = "Energy Shield",
				craterMult              = 0,
				customParams = {
					unlinked                = true,
					shield_recharge_delay   = 5,
				},
				damage                  = {
					default = 10,
				},
				exteriorShield          = true,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				shieldAlpha             = 0.2,
				shieldBadColor          = "1 0.1 0.1 1",
				shieldGoodColor         = "0.1 0.1 1 1",
				shieldInterceptType     = 3,
				shieldPower             = 100000,
				shieldPowerRegen        = 1000,
				shieldPowerRegenEnergy  = 140,
				shieldRadius            = 850,
				shieldRepulser          = false,
				smartShield             = true,
				visibleShield           = false,
				visibleShieldRepulse    = false,
				weaponType              = "Shield",
			},
		},
		featureDefs                   = {
			DEAD = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 4,
				footprintZ       = 4,
				object           = "pw_artefact_dead.dae",
			},
			HEAP = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2a.s3o",
			},
		},
	} 
}
