return { 
	shieldbomb = {
		unitname               = "shieldbomb",
		name                   = "Parcel",
		description            = "Shielded Cluster Bomb",
		acceleration           = 2.4,
		activateWhenBuilt      = true,
		brakeRate              = 4.8,
		buildCostMetal         = 160,
		buildPic               = "shieldbomb.png",
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = "LAND TOOFAST",
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "16 16 16",
		collisionVolumeType    = "ellipsoid",
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "28 28 28",
		selectionVolumeType    = "ellipsoid",
		corpse                 = "DEAD",

		customParams           = {
			modelradius    = "7",
			selection_scale = 1, -- Maybe change later
		},

		explodeAs              = "shieldbomb_DEATH",
		fireState              = 0,
		footprintX             = 2,
		footprintZ             = 2,
		iconType               = "walkerbomb",
		idleAutoHeal           = 5,
		idleTime               = 1800,
		kamikaze               = true,
		kamikazeDistance       = 40,
		kamikazeUseLOS         = true,
		leaveTracks            = true,
		health                 = 270,
		maxSlope               = 36,
		speed                  = 5.2,
		maxWaterDepth          = 15,
		movementClass          = "SKBOT2",
		noChaseCategory        = "FIXEDWING LAND SINK TURRET SHIP SWIM GUNSHIP FLOAT SUB HOVER",
		objectName             = "logroach.s3o",
		pushResistant          = 0,
		script                 = "shieldbomb.lua",
		selfDestructAs         = "shieldbomb_DEATH",
		selfDestructCountdown  = 0,
		sfxtypes               = {
			explosiongenerators = {
				"custom:RAIDMUZZLE",
				"custom:VINDIBACK",
				"custom:digdig",
			},
		},
		sightDistance          = 400,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = "ChickenTrackPointy",
		trackWidth             = 20,
		turnRate               = 3600,
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
		weapons = {
			{
				def                = "SHIELD",
			},
		},
		weaponDefs = {
			SHIELD = {
				name                    = "Energy Shield",	
				customParams = {
					shield_recharge_delay   = 3,
				},
				damage                  = {	
					default = 10,	
				},	
				exteriorShield          = true,	
				shieldAlpha             = 0.2,	
				shieldBadColor          = "1 0.1 0.1 1",	
				shieldGoodColor         = "0.1 0.1 1 1",	
				shieldInterceptType     = 3,	
				shieldPower             = 2200,	
				shieldPowerRegen        = 50,	
				shieldPowerRegenEnergy  = 2,	
				shieldRadius            = 60,	
				shieldRepulser          = false,	
				shieldStartingPower     = 1500,	
				smartShield             = true,	
				visibleShield           = false,	
				visibleShieldRepulse    = false,	
				weaponType              = "Shield",	
			},
			death = {
				name                    = "Cluster Bomb Dispenser",
				areaOfEffect            = 290,
				avoidFeature            = true,
				--cegTag                  = "missiletrailred",
				commandFire             = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					light_camera_height = 3500,
					light_color = "0.75 0.4 0.15",
					light_radius = 220,
					blastwave_size = 25,
					blastwave_impulse = 0.075,
					blastwave_speed = 30,
					blastwave_life = 4,
					blastwave_lossfactor = 0.8,
					blastwave_damage = 800,
					numprojectiles1 = 10,
					projectile1 = "shieldbomb_fragment_dummy",
					velspread1 = "5.09, 1.5, 5.09, _, 2.5, _",
					noairburst = "Merkityksetön räjähdys",
					onexplode = "Sattuu ihan vitusti",
					timeddeploy = -1,
				},

				damage                  = {
					default = 100,
				},

				explosionGenerator      = "custom:ROACHPLOSION",
				fireStarter             = 70,
				flightTime              = 3,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				--model                   = "wep_b_fabby.s3o", --TODO: replace with SharkGameDev's better model. delete this once it's done.
				range                   = 340,
				reloadtime              = 45,
				smokeTrail              = true,
				soundHit                = "explosion/shieldbomb_deploy",
				soundHitVolume          = 100,
				soundStart              = "weapon/cannon/cannon_fire3",
				trajectoryHeight        = 1,
				texture2                = "lightsmoketrail",
				tolerance               = 8000,
				size = 0.1,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 255,
			},
			shieldbomb_death = { -- compat for zw?
				name                    = "Cluster Bomb Dispenser",
				areaOfEffect            = 216,
				avoidFeature            = true,
				--cegTag                  = "missiletrailred",
				commandFire             = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					light_camera_height = 3500,
					light_color = "0.75 0.4 0.15",
					light_radius = 220,
					blastwave_size = 25,
					blastwave_impulse = 4,
					blastwave_speed = 30,
					blastwave_life = 4,
					blastwave_lossfactor = 0.8,
					blastwave_damage = 800,
					numprojectiles1 = 10,
					projectile1 = "shieldbomb_fragment_dummy",
					velspread1 = "3.82, 1.5, 3.82, _, 2.5, _",
					noairburst = "Merkityksetön räjähdys",
					onexplode = "Sattuu ihan vitusti",
					timeddeploy = -1,
				},

				damage                  = {
					default = 500,
				},

				explosionGenerator      = "custom:ROACHPLOSION",
				fireStarter             = 70,
				flightTime              = 3,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				--model                   = "wep_b_fabby.s3o", --TODO: replace with SharkGameDev's better model. delete this once it's done.
				range                   = 340,
				reloadtime              = 45,
				smokeTrail              = true,
				soundHit                = "explosion/shieldbomb_deploy",
				soundHitVolume          = 100,
				soundStart              = "weapon/cannon/cannon_fire3",
				trajectoryHeight        = 1,
				texture2                = "lightsmoketrail",
				tolerance               = 8000,
				size = 0.1,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 255,
			},
			FRAGMENT_DUMMY = {
				name                    = "merkityksetön räjähdys", -- nobody should read this anyways?
				accuracy                = 400,
				areaOfEffect            = 162,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = "flamer",
				customParams              = {
					numprojectiles1 = 1,
					projectile1 = "shieldbomb_cluster_fragment",
					keepmomentum1 = 1,
					noairburst = "I belive I can fly...",
					timeddeploy = 10,
					shield_damage = 600,
					bogus = 1
				},
				damage                  = {
					default = 0,
				},
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.1,
				noExplode               = true,
				model                   = "wep_b_fabby.s3o",
				projectiles             = 10,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = "1 0.5 0.2",
				size                    = 2.5,
				soundHit                = "nosound",
				soundStart              = "weapon/cannon/wolverine_fire",
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 320,
				waterWeapon             = true,
			},
			cluster_fragment = {
				name                    = "High Explosive Bomblet",
				accuracy                = 200,
				areaOfEffect            = 128,
				craterBoost             = 10,
				craterMult              = 5,
				damage                  = {
					default = 600,
				},
				edgeEffectiveness		= 0.4,
				explosionGenerator      = "custom:MEDMISSILE_EXPLOSION",
				fireStarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 2,
				model                   = "wep_b_fabby.s3o",
				range                   = 200,
				reloadtime              = 1,
				smokeTrail              = true,
				size                    = 2.5,
				soundHit                = "explosion/explosion_roach",
				soundHitVolume          = 8,
				soundStart              = "weapon/cannon/mini_cannon",
				soundStartVolume        = 2,
				sprayangle              = 14400,
				turret                  = true,
				tolerance				= 32000,
				firetolerance			= 32000,
				weaponType              = "Cannon",
				weaponVelocity          = 400,
				waterWeapon             = true,
			},
		}
	} 
}
