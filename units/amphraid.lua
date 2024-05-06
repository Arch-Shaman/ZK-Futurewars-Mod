return { 
	amphraid = {
		unitname               = "amphraid",
		name                   = "Surge",
		description            = "Amphibious Raider Bot",
		acceleration           = 0.6,
		activateWhenBuilt      = true,
		brakeRate              = 2.4,
		buildCostMetal         = 120,
		buildPic               = "grebe.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND SINK",
		corpse                 = "DEAD",
		customParams           = {
			battery = 100,
			batterygain = 4,
			initialbattery = 100,
			amph_regen        = 35,
			amph_submerged_at = 40,
		},
		explodeAs              = "BIG_UNITEX",
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = "amphraider",
		leaveTracks            = true,
		health                 = 480,
		maxSlope               = 36,
		speed                  = 2.9,
		maxWaterDepth          = 5000,
		movementClass          = "AKBOT2",
		noChaseCategory        = "TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET",
		objectName             = "amphraider.s3o",
		script                 = "grebe.lua",
		selfDestructAs         = "BIG_UNITEX",
		sfxtypes               = {
			explosiongenerators = {
				"custom:waketrail_small",
			},
		},
		sightDistance          = 700,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = "ComTrack",
		trackWidth             = 22,
		turnRate               = 1440,
		upright                = true,
		weapons                = {
			{
				def                = "GAUSS",
				badTargetCategory  = "FIXEDWING",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs             = {
			GAUSS = {
				name                    = "Light Railgun",
				alphaDecay              = 0.12,
				areaOfEffect            = 70,
				avoidfeature            = false,
				cegtag                  = "amphraid_trail",
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting       = 0.5,
				customParams = {
					light_camera_height = 1200,
					light_radius        = 30,
					light_color = "0 0.1843 0.4235",
					batterydrain = 8,
					batterychecklevel = 9,
					armorpiercing = 0.75,
				},
				damage                  = {
					default = 85.1,
				},
				explosionGenerator      = "custom:70rlexplode_blue",
				impactOnly              = false,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 300,
				reloadtime              = 3/30,
				rgbColor                = "0.329 0.78 0.8196",
				size                    = 1.1,
				seperation				= 0.1,
				nogap					= true,
				soundHit                = "weapon/cannon/amph_light_mg_hit",
				soundHitVolume          = 2.5,
				soundStart              = "weapon/cannon/amph_light_mg_fire",
				soundStartVolume        = 1.5,
				turret                  = true,
				waterweapon             = true,
				weaponType              = "Cannon",
				weaponVelocity          = 950,
			},
		},
		featureDefs            = {
			DEAD      = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 3,
				footprintZ       = 3,
				object           = "wreck2x2b.s3o",
			},
			HEAP      = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = "debris2x2c.s3o",
			},

		},
	} 
}
