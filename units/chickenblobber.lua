local ravepartyBase = {
	sprayAngle              = 800,
	projectiles             = 2,
	avoidFeature            = false,
	avoidGround             = false,
	craterBoost             = 0.25,
	craterMult              = 0.5,
	interceptedByShieldType = 1,
	myGravity               = 0.1,
	range                   = 3350,
	reloadtime              = 10,
	size                    = 15,
	sizeDecay               = 0.03,
	soundStart              = "weapon/cannon/acid_fire",
	stages                  = 30,
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 600,
}

local MergeWithDefault = Spring.Utilities.MergeWithDefault

return {
	chickenblobber = {
		name                = "Blobber",
		description         = "Heavy Artillery",
		acceleration        = 1.3,
		activateWhenBuilt   = true,
		brakeRate           = 1.5,
		builder             = false,
		buildPic            = "chickenblobber.png",
		buildTime           = 3600,
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = "LAND",

		customParams        = {
			chicken = "uwu",
			model_rescale = 1.5,
			chicken_spawncost = 3600,
		},

		explodeAs           = "NOWEAPON",
		footprintX          = 4,
		footprintZ          = 4,
		health              = 21600,
		highTrajectory      = 1,
		iconType            = "walkerlrarty",
		idleAutoHeal        = 20,
		idleTime            = 300,
		leaveTracks         = true,
		maxSlope            = 90,
		maxWaterDepth       = 5000,
		movementClass       = "ATKBOT3",
		noAutoFire          = false,
		noChaseCategory     = "TERRAFORM FIXEDWING SATELLITE GUNSHIP SUB MOBILE STUPIDTARGET MINE",
		objectName          = "chickenblobber.s3o",
		reclaimable         = false,
		selfDestructAs      = "NOWEAPON",
		

		sfxtypes            = {

			explosiongenerators = {
				"custom:blood_spray",
				"custom:blood_explode",
				"custom:dirt",
			},

		},
		sightDistance       = 1200,
		sonarDistance       = 1200,
		script              = "chickenblobber.lua",
		speed               = 122,
		trackOffset         = 6,
		trackStrength       = 8,
		trackStretch        = 1,
		trackType           = "ChickenTrack",
		trackWidth          = 30,
		turnRate            = 1289,
		upright             = false,
		waterline           = 24,

		weapons             = {
			{
				def                = "RED",
				badTargetCategory  = "SWIM SHIP HOVER MOBILE",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
			},
			{
				def                = "ORANGE",
				badTargetCategory  = "SWIM SHIP HOVER MOBILE",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
				slaveTo            = 1,
			},
			{
				def                = "YELLOW",
				badTargetCategory  = "SWIM SHIP HOVER MOBILE",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
				slaveTo            = 1,
			},
			{
				def                = "GREEN",
				badTargetCategory  = "SWIM SHIP HOVER MOBILE",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
				slaveTo            = 1,
			},
			{
				def                = "BLUE",
				badTargetCategory  = "SWIM SHIP HOVER MOBILE",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
				slaveTo            = 1,
			},
			{
				def                = "PURPLE",
				badTargetCategory  = "SWIM SHIP HOVER MOBILE",
				mainDir            = "0 0 1",
				maxAngleDif        = 120,
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER",
				slaveTo            = 1,
			},
		},

		weaponDefs          = {
			RED = MergeWithDefault(ravepartyBase, {
				name                    = "Red Killer",
				areaOfEffect            = 192,
				craterBoost             = 4,
				craterMult              = 3,

				customParams              = {
					armorpiercing = 1,
				},

				damage                  = {
					default = 7000.1,
				},

				edgeeffectiveness       = 0.5,
				explosionGenerator      = "custom:NUKE_150",
				impulseBoost            = 0.5,
				impulseFactor           = 0.2,
				rgbColor                = "1 0.1 0.1",
				soundHit                = "explosion/mini_nuke",
			}, true),

			ORANGE = MergeWithDefault(ravepartyBase, {
				name                    = "Orange Roaster",
				areaOfEffect            = 800,
				craterAreaOfEffect      = 80,
				craterBoost             = 0.25,
				craterMult              = 0.5,

				customParams              = {
					setunitsonfire = "1",
					burntime = 480,
					burnchance = 1,

					area_damage = 1,
					area_damage_radius = 400,
					area_damage_dps = 100,
					area_damage_duration = 8,
				},

				damage                  = {
					default = 500.1,
				},

				edgeeffectiveness       = 0.25,
				explosionGenerator      = "custom:napalm_drp",
				impulseBoost            = 0.2,
				impulseFactor           = 0.1,
				rgbColor                = "0.9 0.3 0",
				soundHit                = "weapon/missile/nalpalm_missile_hit",
			}, true),

			YELLOW = MergeWithDefault(ravepartyBase, {
				name                    = "Yellow Slammer",
				areaOfEffect            = 384,
				craterBoost             = 0.25,
				craterBoost             = 0.5,
				craterMult              = 1,

				damage                  = {
					default = 2000.1,
				},

				edgeeffectiveness       = 0.5,
				explosionGenerator      = "custom:330rlexplode",
				explosionSpeed          = 500,
				impulseBoost            = 400,
				impulseFactor           = 5,
				rgbColor                = "0.7 0.7 0",
				soundHit                = "weapon/cannon/earthshaker",
			}, true),

			GREEN = MergeWithDefault(ravepartyBase, {
				name                    = "Green Stamper",
				areaOfEffect            = 384,
				craterBoost             = 32,
				craterMult              = 1,

				customParams            = {
					gatherradius = "540",
					smoothradius = "300",
					smoothmult   = "0.9",
					smoothexponent = "0.8",
					movestructures = "1",
				},

				damage                  = {
					default = 2500.1,
				},

				explosionGenerator      = "custom:blobber_goo",
				impulseBoost            = 0.7,
				impulseFactor           = 0.5,
				rgbColor                = "0.1 1 0.1",
				soundHit                = "weapon/ex_large4",
			}, true),

			BLUE = MergeWithDefault(ravepartyBase, {
				name                    = "Blue Shocker",
				areaOfEffect            = 320,
				craterBoost             = 0.25,
				craterMult              = 0.5,

				damage                  = {
					default = 45000,
				},

				explosionGenerator      = "custom:POWERPLANT_EXPLOSION",
				impulseBoost            = 0,
				impulseFactor           = 0,
				paralyzer               = true,
				paralyzeTime            = 25,
				rgbColor                = "0.1 0.1 1",
				soundHit                = "weapon/more_lightning",
			}, true),

			PURPLE = MergeWithDefault(ravepartyBase, {
				name                    = "Blue Shocker",
				areaOfEffect            = 320,
				craterBoost             = 0.25,
				craterMult              = 0.5,

				customparams = {
					timeslow_damagefactor = 10,
					nofriendlyfire = "needs hax",
					timeslow_overslow_frames = 2*30, --2 seconds before slow decays
				},

				damage                  = {
					default = 2000.1,
				},

				explosionGenerator      = "custom:riotballplus2_purple",
				explosionScar           = false,
				explosionSpeed          = 6.5,
				impulseBoost            = 0.2,
				impulseFactor           = 0.1,
				rgbColor                = "0.7 0 0.7",
				soundHit                = "weapon/aoe_aura2",
			}, true),
		}
	}
}
