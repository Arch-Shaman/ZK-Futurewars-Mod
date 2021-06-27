return { 
	jumpraid = {
		unitname              = [[jumpraid]],
		name                  = [[Arsonist]],
		description           = [[Raider/Riot Jumper]],
		acceleration          = 1.2,
		brakeRate             = 7.2,
		buildCostMetal        = 220,
		builder               = false,
		buildPic              = [[jumpraid.png]],
		canGuard              = true,
		canManualFire          = true,
		canMove               = true,
		canPatrol             = true,
		category              = [[LAND FIREPROOF]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[30 30 30]],
		selectionVolumeType    = [[ellipsoid]],
		corpse                = [[DEAD]],
		
		customParams          = {
			canjump            = 1,
			jump_range         = 400,
			jump_speed         = 7,
			jump_reload        = 10,
			jump_from_midair   = 1,
			fireproof      = [[1]],
			stats_show_death_explosion = 1,
		},
		
		explodeAs             = [[PYRO_DEATH]],
		footprintX            = 2,
		footprintZ            = 2,
		iconType              = [[jumpjetraider]],
		idleAutoHeal          = 5,
		idleTime              = 1800,
		leaveTracks           = true,
		maxDamage             = 880,
		maxSlope              = 36,
		maxVelocity           = 3,
		maxWaterDepth         = 22,
		minCloakDistance      = 75,
		movementClass         = [[KBOT2]],
		noAutoFire            = false,
		noChaseCategory       = [[FIXEDWING GUNSHIP SUB]],
		objectName            = [[m-5.s3o]],
		script                = [[jumpraid.lua]],
		selfDestructAs        = [[PYRO_DEATH]],
		selfDestructCountdown = 5,
		
		sfxtypes              = {
		
			explosiongenerators = {
			[[custom:PILOT]],
			[[custom:PILOT2]],
			[[custom:RAIDMUZZLE]],
			[[custom:VINDIBACK]],
			},
		
		},
		
		sightDistance         = 560,
		trackOffset           = 0,
		trackStrength         = 8,
		trackStretch          = 1,
		trackType             = [[ComTrack]],
		trackWidth            = 22,
		turnRate              = 1800,
		upright               = true,
		workerTime            = 0,

		weapons               = {

			{
				def                = [[FLAMETHROWER]],
				badTargetCategory  = [[FIREPROOF]],
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP FIXEDWING]],
			},
			{
				def                = [[SWEEPER]],
				badTargetCategory  = [[]],
				onlyTargetCategory = [[]],
			},
			{
				def                = [[COCKTAIL]],
				badTargetCategory  = [[FIREPROOF]],
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP]],
			},
			{
				def                = [[SWEEPER]],
				badTargetCategory  = [[]],
				onlyTargetCategory = [[]],
			},

		},


		weaponDefs            = {
			FLAMETHROWER = {
				name                    = [[Primary Flamethrower]],
				areaOfEffect            = 64,
				avoidGround             = false,
				avoidFeature            = false,
				avoidFriendly           = true,
				collideFeature          = false,
				collideGround           = false,
				coreThickness           = 0,
				craterBoost             = 0,
				craterMult              = 0,
				cegTag                  = [[flamer]],
			
				customParams            = {
					flamethrower = [[1]],
					setunitsonfire = "1",
					burnchance = "0.4", -- Per-impact
					burntime = [[150]],
					
					light_camera_height = 2800,
					light_color = [[0.6 0.39 0.18]],
					light_radius = 260,
					light_fade_time = 10,
					light_beam_mult_frames = 5,
					light_beam_mult = 5,
				
					combatrange = 280,
				},
				
				damage                  = {
					default = 6.8,
				},
			
				duration                = 0.01,
				explosionGenerator      = [[custom:SMOKE]],
				fallOffRate             = 1,
				fireStarter             = 100,
				heightMod               = 1,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 0.3,
				interceptedByShieldType = 1,
				leadLimit               = 10,
				noExplode               = true,
				noSelfDamage            = true,
				range                   = 280,
				reloadtime              = 0.133,
				rgbColor                = [[1 1 1]],
				soundStart              = [[weapon/flamethrower]],
				soundTrigger            = true,
				texture1                = [[flame]],
				thickness               = 0,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = [[LaserCannon]],
				weaponVelocity          = 840,
			},


			SWEEPER = {
				name                    = [[Sweeping Flamethrower]],
				areaOfEffect            = 64,
				avoidGround             = false,
				avoidFeature            = false,
				avoidFriendly           = true,
				collideFeature          = false,
				collideGround           = false,
				canattackground         = false,
				coreThickness           = 0,
				craterBoost             = 0,
				craterMult              = 0,
				cegTag                  = [[flamer]],
			
				customParams            = {
					flamethrower = [[1]],
					setunitsonfire = "1",
					burnchance = "1", -- Per-impact
					burntime = [[540]],
					
					light_camera_height = 2800,
					light_color = [[0.6 0.39 0.18]],
					light_radius = 260,
					light_fade_time = 10,
					light_beam_mult_frames = 5,
					light_beam_mult = 5,
				
					combatrange = 220,
					
					stats_custom_tooltip_1 = " - Sweeping Arc:",
					stats_custom_tooltip_entry_1 = "80 deg",
					stats_custom_tooltip_2 = " - Sweeping Speed:",
					stats_custom_tooltip_entry_2 = "60 deg/s",
				},
				
				damage                  = {
					default = 4.7,
				},
			
				duration                = 0.01,
				explosionGenerator      = [[custom:SMOKE]],
				fallOffRate             = 1,
				fireStarter             = 100,
				heightMod               = 1,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 0.3,
				interceptedByShieldType = 1,
				leadLimit               = 10,
				noExplode               = true,
				noSelfDamage            = true,
				range                   = 280,
				reloadtime              = 0.133,
				rgbColor                = [[1 1 1]],
				soundStart              = [[weapon/flamethrower]],
				soundTrigger            = true,
				texture1                = [[flame]],
				thickness               = 0,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = [[LaserCannon]],
				weaponVelocity          = 840,
			},
			
			
			COCKTAIL = {
				name                    = [[Molotov Cocktail]], --CREDITS: Cliver5
				areaOfEffect            = 48,
				avoidFeature            = true,
				--cegTag                  = [[missiletrailred]],
				commandFire             = true,
				craterBoost             = 0,
				craterMult              = 0,

				customParams        = {
					light_camera_height = 3500,
					light_color = [[0.75 0.4 0.15]],
					light_radius = 220,
					
					manualfire = 1,
					
					numprojectiles1 = 24, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "jumpraid_napalm_fragment_dummy",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-1.5,4,-1.5,1.5,6,1.5",
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					onexplode = "by the power of god, disco and hentai...", -- if true, this projectile will cluster when it explodes
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					
					area_damage = 1,
					area_damage_radius = 70,
					area_damage_dps = 40,
					area_damage_duration = 12,
					
					stats_damage = (35*24) + 200,
					shield_damage = (35*24) + 200,
					stats_shield_damage = (35*24) + 200,
				},

				damage                  = {
					default = 200,
				},

				explosionGenerator      = [[custom:napalm_hellfire]],
				fireStarter             = 70,
				flightTime              = 3,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				model                   = [[wep_b_fabby.s3o]], --TODO: replace with SharkGameDev's better model. delete this once it's done.
				range                   = 340,
				reloadtime              = 45,
				smokeTrail              = true,
				soundHit                = [[weapon/cannon/wolverine_hit]],
				soundHitVolume          = 8,
				soundStart              = [[weapon/cannon/cannon_fire3]],
				trajectoryHeight        = 1,
				texture2                = [[lightsmoketrail]],
				tolerance               = 8000,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 255,
			},
		

			NAPALM_FRAGMENT_DUMMY = {
				name                    = [[Napalm Fragment]],
				accuracy                = 400,
				areaOfEffect            = 162,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[flamer]],
				customParams              = {

					numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "jumpraid_napalm_fragment",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "derpderpderpderpderpderpderpderpderpderp", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 1,
					timeoutspawn = 0,
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeddeploy = 20,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
					shield_damage = 40,
					bogus = 1
				},
				damage                  = {
					default = 0,
				},

				--explosionGenerator      = [[custom:napalm_firewalker_small]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.1,
				noExplode               = true,
				projectiles             = 10,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 5,
				soundHit                = [[nosound]],
				soundStart              = [[weapon/cannon/wolverine_fire]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},

			NAPALM_FRAGMENT = {
				name                    = [[Napalm Fragment]],
				accuracy                = 400,
				areaOfEffect            = 162,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[flamer]],
				customParams              = {
					setunitsonfire = "1",
					burntime = 60,
					
					area_damage = 1,
					area_damage_radius = 48,
					area_damage_dps = 15,
					area_damage_duration = 10,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
				},
				damage                  = {
					default = 35,
				},

				explosionGenerator      = [[custom:napalm_firewalker_small]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.1,
				projectiles             = 10,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 5,
				soundHit                = [[weapon/clusters/napalm_break]],
				soundStart              = [[weapon/cannon/wolverine_fire]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},

			PYRO_DEATH = {
				name                    = [[Napalm Blast]],
				areaofeffect            = 256,
				craterboost             = 1,
				cratermult              = 3.5,
		
				customparams              = {
					setunitsonfire = "1",
					burnchance     = "1",
					burntime       = 60,
		
					area_damage = 1,
					area_damage_radius = 128,
					area_damage_dps = 80,
					area_damage_duration = 13.3,
				},
		
				damage                  = {
					default = 50,
				},
		
				edgeeffectiveness       = 0.5,
				explosionGenerator      = [[custom:napalm_pyro]],
				impulseboost            = 0,
				impulsefactor           = 0,
				soundhit                = [[explosion/ex_med3]],
			},
		},

		featureDefs           = {
			DEAD  = {
			blocking         = false,
			featureDead      = [[HEAP]],
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[m-5_dead.s3o]],
			},
			HEAP  = {
			blocking         = false,
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[debris2x2c.s3o]],
			},
		},
	}
}
