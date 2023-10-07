return { chicken_rafflesia = {
	name                          = "Rafflesia",
	description                   = "Massive Chicken Shield (Static)",
	activateWhenBuilt             = true,
	builder                       = false,
	buildPic                      = "chicken_rafflesia.png",
	category                      = "SINK",

	customParams                  = {
		shield_emit_offset = -4,
	},

	explodeAs                     = "NOWEAPON",
	footprintX                    = 3,
	footprintZ                    = 3,
	iconType                      = "defenseshield",
	idleAutoHeal                  = 50,
	idleTime                      = 600,
	levelGround                   = false,
	health                        = 5000,
	maxSlope                      = 36,
	speed                         = 0,
	maxWaterDepth                 = 20,
	buildTime                     = 4800,
	noAutoFire                    = false,
	noChaseCategory               = "FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER",
	objectName                    = "chicken_rafflesia.s3o",
	onoffable                     = true,
	power                         = 4800,
	reclaimable                   = false,
	selfDestructAs                = "NOWEAPON",

	sfxtypes                      = {

		explosiongenerators = {
			"custom:blood_spray",
			"custom:blood_explode",
			"custom:dirt",
		},

	},
	sightDistance                 = 512,
	upright                       = false,
	useBuildingGroundDecal        = false,
	workerTime                    = 0,
	yardMap                       = "ooooooooo",
	weapons                       = {
		{
			def = "SHIELD",
		},
	},
	weaponDefs                    = {
		SHIELD      = {
			name                    = "Shield",
			craterMult              = 0,
			customParams = {
				unlinked                = true,
				shield_recharge_delay   = 30,
			},
			damage                  = {
				default = 10,
			},
			exteriorShield          = true,
			impulseFactor           = 0,
			interceptedByShieldType = 1,
			shieldAlpha             = 0.15,
			shieldBadColor          = "1.0 1 0.1 1",
			shieldGoodColor         = "0.1 1.0 0.1 1",
			shieldInterceptType     = 3,
			shieldPower             = 50000,
			shieldPowerRegen        = 1440,
			shieldPowerRegenEnergy  = 0,
			shieldRadius            = 1400,
			shieldRepulser          = false,
			smartShield             = true,
			visibleShield           = false,
			visibleShieldRepulse    = false,
			--texture1                = "wakelarge",
			--visibleShield           = true,
			--visibleShieldHitFrames  = 30,
			--visibleShieldRepulse    = false,
			weaponType              = "Shield",
		},

	},

} }
