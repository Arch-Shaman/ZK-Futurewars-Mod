local chickend = {
	name                          = "Chicken Tube",
	description                   = "Defence and energy source",
	activateWhenBuilt             = true,
	builder                       = false,
	buildingGroundDecalDecaySpeed = 30,
	buildingGroundDecalSizeX      = 5,
	buildingGroundDecalSizeY      = 5,
	buildingGroundDecalType       = "chickend_aoplane.dds",
	buildPic                      = "chickend.png",
	buildTime                     = 200,
	category                      = "SINK",
	customParams                  = {
		chicken = "uwu",
		chicken_structure = "^w^",
		model_rescale_script = 1,
		--armored_regen  = "30",
		--armortype = 1, -- for context menu.
	},

	--damageModifier                = 0.4,
	energyMake                    = 8,
	explodeAs                     = "NOWEAPON",
	floater                       = true,
	footprintX                    = 3,
	footprintZ                    = 3,
	health                        = 1200,
	iconType                      = "defense",
	idleAutoHeal                  = 20,
	idleTime                      = 300,
	levelGround                   = false,
	maxSlope                      = 36,
	maxWaterDepth                 = 20,
	noAutoFire                    = false,
	noChaseCategory               = "FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER",
	objectName                    = "tube.s3o",
	onoffable                     = true,
	power                         = 210,
	reclaimable                   = false,
	script                        = "chickend.lua",
	selfDestructAs                = "NOWEAPON",
	sfxtypes                      = {
		explosiongenerators = {
			"custom:blood_spray",
			"custom:blood_explode",
			"custom:dirt",
		},
	},
	sightDistance                 = 1000,
	sonarDistance                 = 1000,
	upright                       = false,
	useBuildingGroundDecal        = true,
	workerTime                    = 0,
	yardMap                       = "yyyyyyyyy",
	weapons                       = {
		{
			def                = "HIGHSPORES",
			onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
		},
	},
	weaponDefs                    = {
		HIGHSPORES = {
			name                    = "Explosive Spores",
			areaOfEffect            = 24,
			avoidFriendly           = false,
			burst                   = 4,
			burstrate               = 0.2,
			collideFriendly         = false,
			craterBoost             = 0,
			craterMult              = 0,

			customParams            = {
				light_radius = 0,
			},

			damage                  = {
				default = 38,
				planes  = 38,
			},
			dance                   = 60,
			explosionGenerator      = "custom:goo_v2_red",
			impactOnly              = false,
			fireStarter             = 0,
			flightTime              = 8,
			groundbounce            = 1,
			heightmod               = 0.5,
			impulseBoost            = 0,
			impulseFactor           = 0,
			interceptedByShieldType = 2,
			model                   = "chickeneggyellow.s3o",
			range                   = 680,
			reloadtime              = 4,
			smokeTrail              = true,
			startVelocity           = 500,
			texture1                = "",
			texture2                = "sporetrail",
			tolerance               = 10000,
			tracks                  = true,
			trajectoryHeight        = 2,
			turnRate                = 24000,
			turret                  = true,
			waterweapon             = true,
			weaponAcceleration      = 100,
			weaponType              = "MissileLauncher",
			weaponVelocity          = 1000,
			wobble                  = 32000,
		},
	},
}


local MergeWithDefault = Spring.Utilities.MergeWithDefault

local chickend_improved = MergeWithDefault(chickend, {
	name = "Greater Chicken Tube",
	customParams                  = {
		model_rescale_script = 1.5,
	},
	energyMake = 30,
	buildTime = 750,
	health = 6200,
	idleAutoHeal = 100,
	weaponDefs = {
		HIGHSPORES = {
			damage = {
				default = 113,
				planes  = 113,
			},
			range = 884,
		},
	},
}, true)

local chickend_advanced = MergeWithDefault(chickend, {
	name = "Chicken Hive Tube",
	customParams                  = {
		model_rescale_script = 2,
	},
	energyMake = 140,
	buildTime = 3500,
	health = 37900,
	idleAutoHeal = 600,
	weaponDefs = {
		HIGHSPORES = {
			damage = {
				default = 375,
				planes  = 375,
			},
			range = 1360,
		},
	},
}, true)


return {
	chickend = chickend,
	chickend_improved = chickend_improved,
	chickend_advanced = chickend_advanced,
}
