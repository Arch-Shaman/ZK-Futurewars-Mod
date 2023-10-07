return { chickenspire = {
	name                          = "Chicken Spire",
	description                   = "Static Artillery",
	activateWhenBuilt             = true,
	builder                       = false,
	buildingGroundDecalDecaySpeed = 30,
	buildingGroundDecalSizeX      = 12,
	buildingGroundDecalSizeY      = 12,
	buildingGroundDecalType       = "chickenspire_aoplane.dds",
	buildPic                      = "chickenspire.png",
	category                      = "SINK",
	collisionVolumeOffsets        = "0 96 0",
	collisionVolumeScales         = "112 352 112",
	collisionVolumeType           = "CylY",

	customParams                  = {
		outline_x = 310,
		outline_y = 400,
		outline_yoff = 150,
	},

	energyMake                    = 0,
	explodeAs                     = "NOWEAPON",
	floater                       = true,
	footprintX                    = 4,
	footprintZ                    = 4,
	highTrajectory                = 1,
	iconType                      = "staticarty",
	idleAutoHeal                  = 20,
	idleTime                      = 300,
	levelGround                   = false,
	health                        = 16500,
	maxSlope                      = 36,
	speed                         = 0,
	maxWaterDepth                 = 20,
	metalCost                     = 0,
	energyCost                    = 0,
	buildTime                     = 12500,
	noAutoFire                    = false,
	noChaseCategory               = "FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER",
	objectName                    = "spire.s3o",
	onoffable                     = true,
	power                         = 12500,
	reclaimable                   = false,
	selfDestructAs                = "NOWEAPON",
	script                        = "chickenspire.lua",

	sfxtypes                      = {

		explosiongenerators = {
			"custom:blood_spray",
			"custom:blood_explode",
			"custom:dirt",
		},

	},
	sightDistance                 = 512,
	upright                       = false,
	useBuildingGroundDecal        = true,
	yardMap                       = "oooooooooooooooo",

	weapons                       = {

		{
			def                = "SLAMSPORE",
			badTargetCategory  = "MOBILE",
			onlyTargetCategory = "LAND SINK TURRET SHIP SWIM FLOAT HOVER",
		},

	},


	weaponDefs                    = {
		SLAMSPORE = {
			name                    = "Slammer Spore",
			areaOfEffect            = 200,
			avoidFriendly           = false,
			collideFriendly         = false,
			burst                   = 10,
			burstrate               = 0.033,
			projectiles             = 2,
			craterBoost             = 1,
			craterMult              = 2,
						
			customParams            = {
				light_radius = 0,
				cruisealt = 1600,
				cruisedist = 2400,
				cruise_ascendradius = 800,
				reveal_unit = 24,
				cruisetracking = 0,
				cruise_nolock = 1,
				cruiserandomradius = 800,
				cruise_ignoreterrain = "1",
				armorpiercing = 0.2,
			},

			damage                  = {
				default = 3000,
			},

			dance                   = 40,
			explosionGenerator      = "custom:large_green_goo",
			fireStarter             = 0,
			flightTime              = 30,
			groundbounce            = 1,
			heightmod               = 0.5,
			impulseBoost            = 0,
			impulseFactor           = 0.4,
			interceptedByShieldType = 2,
			model                   = "chickenegggreen_big.s3o",
			range                   = 100000,
			reloadtime              = 14,
			smokeTrail              = true,
			startVelocity           = 0,
			texture1                = "none",
			texture2                = "sporetrail2",
			tolerance               = 10000,
			tracks                  = true,
			turnRate                = 10000,
			turret                  = true,
			waterweapon             = true,
			weaponAcceleration      = 40,
			weaponType              = "MissileLauncher",
			weaponVelocity          = 10000,
			wobble                  = 16000,
		},

	},

} }
