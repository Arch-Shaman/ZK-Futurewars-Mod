local unitDef = {
	unitname            = "bomberriot",
	name                = "Firebrand",
	description         = "Thermite Bomber",
	brakerate           = 0.4,
	buildCostMetal      = 300,
	builder             = false,
	buildPic            = "bomberriot.png",
	canFly              = true,
	canGuard            = true,
	canMove             = true,
	canPatrol           = true,
	canSubmerge         = false,
	category            = "FIXEDWING",
	collide             = false,
	collisionVolumeOffsets = "0 0 -5",
	collisionVolumeScales  = "55 15 70",
	collisionVolumeType    = "box",
	selectionVolumeOffsets = "0 0 0",
	selectionVolumeScales  = "108 27 108",
	selectionVolumeType    = "cylY",
	corpse              = "DEAD",
	cruiseAlt           = 250,
	customParams        = {
		modelradius    = "10",
		refuelturnradius = "80",
		requireammo    = "1",
		reammoseconds    = "7",
		ammocount = 3,
		ammotexture_1 = "States/ammostates/firebrand_napalm.png",
		ammotexture_2 = "States/ammostates/firebrand_singularity.png",
		ammotexture_3 = "States/ammostates/firebrand_seismic.png",
		ammoname_1 = "Thermite Bomb",
		ammoname_2 = "Gravitron Bomb",
		ammoname_3 = "Seismic Bomb",
		ammodesc_1 = "Bombards an area with napalm, dealing area damage.",
		ammodesc_2 = "Drops a blackhole, which sucks nearby units up.",
		ammodesc_3 = "Drops a Seismic bomb, breaking terraform.",
	},
	explodeAs           = "GUNSHIPEX",
	floater             = true,
	footprintX          = 4,
	footprintZ          = 4,
	iconType            = "bomberraider",
	idleAutoHeal        = 5,
	idleTime            = 1800,
	maxAcc              = 0.5,
	health              = 1600,
	maxAileron          = 0.018,
	maxElevator         = 0.02,
	maxRudder           = 0.008,
	maxFuel             = 1000000,
	speed               = 9.2,
	noAutoFire          = false,
	noChaseCategory     = "TERRAFORM FIXEDWING GUNSHIP SUB",
	objectName          = "firestorm.s3o",
	script			  = "bomberriot.lua",
	selfDestructAs      = "GUNSHIPEX",
	sfxtypes            = {
		explosiongenerators = {
			"custom:BEAMWEAPON_MUZZLE_RED",
			"custom:light_red",
			"custom:light_green",
		},
	},
	sightDistance       = 660,
	turnRadius          = 200,
	workerTime          = 0,
	weapons             = {
		{
			def                = "NAPALM",
			badTargetCategory  = "SWIM LAND SHIP HOVER GUNSHIP",
			onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
		},
		{
			def                = "BLACK_HOLE",
			badTargetCategory  = "SWIM LAND SHIP HOVER GUNSHIP",
			onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
		},
		{
			def                = "SEISMIC",
			badTargetCategory  = "SWIM LAND SHIP HOVER GUNSHIP",
			onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
		},
	},
	weaponDefs          = {
		NAPALM_SECONDARY = {
			name 					= "Thermite",
			cegTag                  = "flamer",
			areaOfEffect            = 216,
			avoidFeature            = false,
			avoidFriendly           = false,
			collideFeature          = false,
			collideFriendly         = false,
			craterBoost             = 0,
			craterMult              = 0,
			--model                   = "wep_b_fabby.s3o",
			damage                  = {
				default = 25,
			},
			customParams              = {
				setunitsonfire = "1",
				burntime = 30,
				area_damage = 1,
				area_damage_radius = 108,
				area_damage_dps = 18,
				area_damage_duration = 16,
				light_camera_height = 2500,
				light_color = "0.25 0.13 0.05",
				light_radius = 460,
				lups_napalm_fx = 1,
			},
			explosionGenerator      = "custom:napalm_koda",
			fireStarter             = 250,
			impulseBoost            = 0,
			impulseFactor           = 0.1,
			interceptedByShieldType = 1,
			soundHit                = "weapon/burn_mixed",
			--soundStart              = "weapon/flak_hit2",
			myGravity               = 0.2,
			rgbColor                = "1 0.5 0.2",
			weaponType              = "Cannon",
			weaponVelocity          = 320,
		},
		BLACK_HOLE = {
			name                    = "Micro gravity well",
			accuracy                = 350,
			areaOfEffect            = 400,
			avoidFeature            = false,
			avoidFriendly           = false,
			collideFeature          = false,
			collideFriendly         = false,
			craterBoost             = 0,
			craterMult              = 0,
			customParams            = {
				singularity = "1",
				singu_radius = 400,
				singu_lifespan = 250,
				singu_strength = 275,
				singu_height = 150,
				singu_finalstrength = 300,
				singu_ceg	= "black_hole_800",
				light_color = "1 1 1",
				cruisealt = 600,
				airlaunched = 1,
				cruisedist = 280,
				cruise_ignoreterrain = 1,
			},
			damage                  = {
				default = 0,
			},
			explosionGenerator      = "custom:FLASHSMALLUNITEX",
			explosionSpeed          = 50,
			impulseBoost            = 150,
			impulseFactor           = -2.5,
			intensity               = 0.9,
			interceptedByShieldType = 1,
			myGravity               = 0.6,
			model                   = "missilesingu.dae",
			projectiles             = 1,
			reloadtime              = 18,
			rgbColor                = "0.05 0.05 0.05",
			range                   = 300,
			size                    = 16,
			soundHit                = "explosion/ex_med11",
			soundStart              = "weapon/bomb_drop",
			soundStartVolume        = 5,
			soundHitVolume          = 5,
			turret                  = true,
			tracks					= true,
			startVelocity           = 300,
			turnrate			    = 65536/4, -- 90 degrees
			tolerance               = 65536/2, -- 180 degrees
			fireTolerance		    = 65536/2,
			weaponAcceleration      = 200,
			weaponType              = "MissileLauncher",
			weaponVelocity          = 800,
		},
		NAPALM = {
			name                    = "Thermite Bomb",
			areaOfEffect            = 216,
			avoidFeature            = false,
			avoidFriendly           = false,
			burst                   = 3,
			burstrate               = 0.4,
			collideFeature          = false,
			collideFriendly         = false,
			craterBoost             = 0,
			craterMult              = 0,
			customParams        	  = {
				numprojectiles1 = 9,
				projectile1 = "bomberriot_napalm_secondary",
				spawndist = 220,
				timeoutspawn = 0, 
				velspread1 = "10.19, -2, 10.19",
				useheight = 1,
				reaim_time = 60, -- Fast update not required (maybe dangerous)
			},
			damage                  = {
				default = 25*9,
			},
			edgeEffectiveness       = 0.7,
			explosionGenerator      = "custom:STARFIRE", --custom:napalm_phoenix
			fireStarter             = 250,
			fireTolerance		    = 65536/2,
			myGravity               = 0.4,
			impulseBoost            = 0,
			impulseFactor           = 0,
			interceptedByShieldType = 1,
			model                   = "wep_b_fabby.s3o",
			myGravity               = 0.4,
			noSelfDamage            = true,
			firetolerance			= 32000,
			tolerance				= 32000,
			reloadtime              = 1,
			soundHit                = "weapon/flak_hit2",
			soundStart              = "weapon/bomb_drop",
			--sprayangle              = 64000,
			weaponType              = "AircraftBomb",
		},
		SEISMIC = {
				name                    = "Seismic Bomb",
				areaOfEffect            = 640,
				avoidFriendly           = false,
				collideFriendly         = false,
				craterBoost             = 32,
				craterMult              = 1,
				customParams            = {
					gatherradius = "520",
					smoothradius = "400",
					detachmentradius = "400",
					smoothmult   = "1",
					smoothexponent = "0.75",
					movestructures = "1",
					stats_hide_dps = 1, -- one use
					stats_hide_reload = 1,
					light_color = "1.2 1.6 0.55",
					light_radius = 550,
					cruisealt = 600,
					airlaunched = 1,
					cruisedist = 280,
					cruise_ignoreterrain = 1,
				},
				damage                  = {
					default = 150,
				},
				edgeEffectiveness       = 0.4,
				explosionGenerator      = "custom:bull_fade",
				fireStarter             = 0,
				myGravity               = 0.4,
				interceptedByShieldType = 0,
				model                   = "wep_seismic.s3o",
				noSelfDamage            = true,
				reloadtime              = 1,
				range                   = 300,
				smokeTrail              = false,
				soundHit                = "explosion/ex_large4",
				soundStart              = "weapon/bomb_drop",
				firetolerance			= 32000,
				tolerance				= 32000,
				waterWeapon             = true,
				tracks					= true,
				startVelocity           = 300,
				turnrate			    = 65536/4, -- 90 degrees
				tolerance               = 65536/2, -- 180 degrees
				fireTolerance		    = 65536/2,
				weaponAcceleration      = 200,
				weaponType              = "MissileLauncher",
				weaponVelocity          = 800,
			},
	},
	featureDefs         = {
		DEAD  = {
			blocking         = true,
			featureDead      = "HEAP",
			footprintX       = 2,
			footprintZ       = 2,
			object           = "firestorm_dead.s3o",
		},
		HEAP  = {
			blocking         = false,
			footprintX       = 2,
			footprintZ       = 2,
			object           = "debris3x3c.s3o",
		},
	},
}

return { bomberriot = unitDef }
