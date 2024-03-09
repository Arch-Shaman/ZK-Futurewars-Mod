return { 
	blastwavebombtest = {
		unitname               = "blastwavebombtest",
		name                   = "Blastwave Test Unit",
		description            = "Development unit",
		acceleration           = 0.75,
		activateWhenBuilt      = true,
		brakeRate              = 2.4,
		buildCostMetal         = 160,
		buildPic               = "shieldbomb.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND TOOFAST",
		cloakCost              = 0,
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "16 16 16",
		collisionVolumeType    = "ellipsoid",
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "28 28 28",
		selectionVolumeType    = "ellipsoid",
		corpse                 = "DEAD",

		customParams           = {
			modelradius    = "7",
			idle_cloak = 1,
			selection_scale = 1, -- Maybe change later
		},

		explodeAs              = "blastwavebomb_DEATH",
		fireState              = 0,
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = "walkerbomb",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		kamikaze               = true,
		kamikazeDistance       = 80,
		kamikazeUseLOS         = true,
		leaveTracks            = true,
		health                 = 60,
		maxSlope               = 36,
		speed                  = 4,
		maxWaterDepth          = 15,
		minCloakDistance       = 75,
		movementClass          = "SKBOT2",
		noChaseCategory        = "FIXEDWING LAND SINK TURRET SHIP SWIM GUNSHIP FLOAT SUB HOVER",
		objectName             = "logroach.s3o",
		pushResistant          = 0,
		script                 = "shieldbomb.lua",
		selfDestructAs         = "blastwavebomb_DEATH",
		selfDestructCountdown  = 0,

		sfxtypes               = {

			explosiongenerators = {
				"custom:RAIDMUZZLE",
				"custom:VINDIBACK",
				"custom:digdig",
			},

		},

		sightDistance          = 240,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = "ChickenTrackPointy",
		trackWidth             = 20,
		turnRate               = 3000,
  
		featureDefs            = {

			DEAD      = {
				blocking         = false,
				featureDead      = "HEAP",
				footprintX       = 2,
				footprintZ       = 2,
				object           = "logroach_dead.s3o",
			},

			HEAP      = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2c.s3o",
			},

		},
		weaponDefs = {
			blastwavebomb_DEATH = {
				areaOfEffect       = 384,
				craterBoost        = 1,
				craterMult         = 3.5,
				customParams       = {
					blastwave_size = 25,
					blastwave_impulse = 30,
					blastwave_speed = 30,
					blastwave_life = 4,
					blastwave_lossfactor = 0.55,
					blastwave_damage = 1500,
				},
				edgeEffectiveness  = 0.4,
				explosionGenerator = "custom:ROACHPLOSION",
				explosionSpeed     = 10000,
				impulseBoost       = 0,
				impulseFactor      = 0.3,
				name               = "Explosion",
				soundHit           = "explosion/mini_nuke",
				damage = {
					default          = 0,
				},
			},
		}
	} 
}
