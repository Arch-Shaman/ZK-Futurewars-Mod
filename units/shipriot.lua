local shipriot = {
	name                   = "Kingstad",
	description            = "Raider/Riot Corvette",
	acceleration           = 0.25,
	activateWhenBuilt      = true,
	brakeRate              = 1.7,
	builder                = false,
	buildPic               = "shipriot.png",
	canGuard               = true,
	canMove                = true,
	canPatrol              = true,
	category               = "SHIP",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeScales  = "32 32 102",
	collisionVolumeType    = "cylZ",
	corpse                 = "DEAD",

	customParams           = {
		turnatfullspeed = "1",
		--extradrawrange = 420,
		boost_postsprint_speed = 0.8,
		boost_postsprint_duration = 510,
		boost_speed_mult = 2,
		boost_duration = 90,
		specialreloadtime = 600,
	},

	explodeAs              = "SMALL_UNITEX",
	floater                = true,
	footprintX             = 4,
	footprintZ             = 4,
	health                 = 3000,
	iconType               = "shipriot",
	idleAutoHeal           = 75,
	idleTime               = 300,
	metalCost              = 330,
	minWaterDepth          = 10,
	movementClass          = "BOAT4",
	noAutoFire             = false,
	noChaseCategory        = "TERRAFORM FIXEDWING SATELLITE",
	objectName             = "shipriot.s3o",
	script                 = "shipriot.lua",
	selfDestructAs         = "SMALL_UNITEX",
	sightDistance          = 500,
	
	sfxtypes               = {
		explosiongenerators = {
			"custom:RAIDMUZZLE",
			"custom:RAIDDUST",
			"custom:FLAMER",
		},
	},
	
	sonarDistance          = 500,
	speed                  = 100,
	turninplace            = 0,
	turnRate               = 800,
	waterline              = 0,
	workerTime             = 0,

	weapons                = {
		{
			def                = "FEMBOY_BWAST",
			badTargetCategory  = "FIXEDWING",
			onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
		},
		{
			def                = "FEMBOY_BWAST",
			badTargetCategory  = "FIXEDWING",
			onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
		},
	},

	weaponDefs             = {
		FEMBOY_BWAST = {
			name                    = "Medium Railgun",
			alphaDecay              = 0.3,
			areaOfEffect            = 48,
			burnBlow                = true,
			collideFriendly         = false, -- This may be dangerous
			burst                   = 2,
			burstRate               = 0.266,
			cegtag                  = "amphraid_trail",
			coreThickness           = 0.5,
			craterBoost             = 0,
			craterMult              = 0,
			
			customParams            = {
				light_camera_height = 2000,
				light_color = "0.3 0.3 0.05",
				light_radius = 50,
			},
			
			damage                  = {
				default = 100,
			},

			explosionGenerator      = "custom:artillery_explosion_half",
			fireStarter             = 50,
			heightMod               = 1,
			impulseBoost            = 0,
			impulseFactor           = 0.4,
			interceptedByShieldType = 1,
			noSelfDamage            = true,
			range                   = 450,
			reloadtime              = 1.6,
			rgbColor                = "0.329 0.78 0.8196",
			separation              = 1.2,
			size                    = 3,
			sizeDecay               = 0.1,
			soundHit                = "impacts/shotgun_impactv5",
			soundHitVolume          = 6,
			soundStart              = "weapon/cannon/cannon_fire4",
			soundStartVolume        = 1.2,
			soundTrigger            = true,
			sprayangle              = 200,
			stages                  = 20,
			tolerance               = 10000,
			turret                  = true,
			waterweapon             = true,
			weaponType              = "Cannon",
			weaponVelocity          = 880,
		},	
	},
	featureDefs            = {
		DEAD = {
			blocking         = false,
			featureDead      = "HEAP",
			footprintX       = 3,
			footprintZ       = 3,
			object           = "shipriot_dead.s3o",
		},
	
		HEAP  = {
			blocking         = false,
			footprintX       = 3,
			footprintZ       = 3,
			object           = "debris3x3b.s3o",
		},
	},
}

return {shipriot = shipriot}
