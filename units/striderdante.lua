return {
	striderdante = {
		unitname            = [[striderdante]],
		name                = [[Vulcan]],
		description         = [[Assault/Riot Strider]],
		acceleration        = 0.295,
		brakeRate           = 1.435,
		buildCostMetal      = 4500,
		builder             = false,
		buildPic            = [[striderdante.png]],
		canGuard            = true,
		canManualFire       = true,
		canMove             = true,
		canPatrol           = true,
		category            = [[LAND]],
		corpse              = [[DEAD]],
		
		customParams        = {
		},
		
		explodeAs           = [[CRAWL_BLASTSML]],
		footprintX          = 4,
		footprintZ          = 4,
		iconType            = [[t3riot]],
		idleAutoHeal        = 600,
		idleTime            = 600,
		leaveTracks         = true,
		losEmitHeight       = 50,
		maxDamage           = 24400,
		maxSlope            = 36,
		maxVelocity         = 1.75,
		maxWaterDepth       = 22,
		minCloakDistance    = 75,
		movementClass       = [[KBOT4]],
		noAutoFire          = false,
		noChaseCategory     = [[TERRAFORM SATELLITE SUB]],
		objectName          = [[dante.s3o]],
		script              = [[striderdante.lua]],
		selfDestructAs      = [[CRAWL_BLASTSML]],
		
		sfxtypes            = {
		
			explosiongenerators = {
				[[custom:SLASHMUZZLE]],
				[[custom:SLASHREARMUZZLE]],
				[[custom:RAIDMUZZLE]],
			},
		},
		sightDistance       = 600,
		trackOffset         = 0,
		trackStrength       = 8,
		trackStretch        = 0.6,
		trackType           = [[ComTrack]],
		trackWidth          = 38,
		turnRate            = 597,
		upright             = true,
		workerTime          = 0,
		
		weapons             = {
		
			{
				def                = [[NAPALM_ROCKETS]],
				badTargetCategory  = [[FIXEDWING GUNSHIP]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		
		
			{
				def                = [[HEATRAY]],
				badTargetCategory  = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		
		
			{
				def                = [[NAPALM_ROCKETS_SALVO]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		
		
			{
				def                = [[DANTE_FLAMER]],
				badTargetCategory  = [[FIREPROOF]],
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP FIXEDWING]],
			},
		
		},
		
		
		weaponDefs          = {
		
			DANTE_FLAMER         = {
				name                    = [[Wide-Coverage Flamethrower]],
				areaOfEffect            = 96,
				avoidGround             = false,
				avoidFeature            = false,
				avoidFriendly           = false,
				collideFeature          = false,
				collideGround           = false,
				coreThickness           = 0,
				craterBoost             = 0,
				craterMult              = 0,
				cegTag                  = [[flamer]],
			
				customParams              = {
					flamethrower = [[1]],
					setunitsonfire = "1",
					burnchance = "0.4", -- Per-impact
					burntime = [[450]],
			
					light_camera_height = 1800,
					light_color = [[0.6 0.39 0.18]],
					light_radius = 260,
					light_fade_time = 13,
					light_beam_mult_frames = 5,
					light_beam_mult = 5,
					reaim_time = 1,
					
					stats_custom_tooltip_1 = " - Coverage:",
					stats_custom_tooltip_entry_1 = "60deg",
				},
				
				damage                  = {
					default = 25,
					subs    = 0.15,
				},
			
				duration                  = 0.01,
				explosionGenerator      = [[custom:SMOKE]],
				fallOffRate             = 1,
				fireStarter             = 100,
				heightMod               = 1,
				impulseBoost            = 0,
				impulseFactor           = 0,
				intensity               = 0.3,
				interceptedByShieldType = 1,
				noExplode               = true,
				noSelfDamage            = true,
				projectiles             = 1,
				range                   = 340,
				reloadtime              = 0.133,
				rgbColor                = [[1 1 1]],
				soundStart              = [[weapon/flamethrower]],
				soundTrigger            = true,
				texture1                = [[flame]],
				thickness               = 0,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = [[LaserCannon]],
				weaponVelocity          = 800,
			},
		
		
			
			HEATRAY = {
				name                    = [[Rotary Heatray Array]],
				areaOfEffect            = 20,
				beamtime				= 1/30,
				coreThickness           = 1.4,
				craterBoost             = 0,
				craterMult              = 0,
				cylinderTargeting 		= 0.6,
				explosionScar			= false,
				customParams        = {
					light_camera_height = 1500,
					light_color = [[0.9 0.4 0.12]],
					light_radius = 100,
					light_fade_time = 25,
					light_fade_offset = 10,
					light_beam_mult_frames = 9,
					light_beam_mult = 8,
					stats_hide_damage = 1,
					
					stats_custom_tooltip_1 = " - Rotary Beams:",
					stats_custom_tooltip_entry_1 = "4 per weapon",
					stats_custom_tooltip_2 = " - Rotary Beam Angle:",
					stats_custom_tooltip_entry_2 = "10deg",
					stats_custom_tooltip_3 = " - Beam Rotation Speed:",
					stats_custom_tooltip_entry_3 = "100deg/s",
				},
				damage                  = {
					default = 20,
				},
				duration                = 0.3,
				dynDamageExp            = 1,
				dynDamageInverted       = false,
				explosionGenerator      = [[custom:HEATRAY_HIT]],
				fallOffRate             = 1,
				fireStarter             = 90,
				impactOnly              = true,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				leadLimit               = 0.1,
				lodDistance             = 10000,
				noSelfDamage            = true,
				projectiles             = 2,
				proximityPriority       = 10,
				range                   = 430,
				reloadtime              = 0.033,
				rgbColor                = [[1 0.54 0]],
				rgbColor2               = [[1 1 0.25]],
				soundStart              = [[weapon/heatray_fire]],
				thickness               = 3,
				tolerance               = 5000,
				turret                  = true,
				weaponType              = [[BeamLaser]],
				weaponVelocity          = 500,
			},
		
			NAPALM_ROCKETS       = {
				name                    = [[Napalm Rockets]],
				areaOfEffect            = 228,
				burst                   = 2,
				burstrate               = 0.1,
				cegTag                  = [[missiletrailredsmall]],
				craterBoost             = 0,
				craterMult              = 0,
			
				customParams              = {
					setunitsonfire = "1",
					burnchance = "1",
					burntime = [[1000]],
					reaim_time = 1,
					
					numprojectiles1 = 10, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "striderdante_napalm_fragment_dummy",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-1.5,6,-1.5,1.5,10,1.5",
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					onexplode = "by the power of god, disco and hentai...", -- if true, this projectile will cluster when it explodes
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
				},
				
				damage                  = {
					default = 120.8,
					subs    = 6,
				},
			
				edgeEffectiveness       = 0.75,
				explosionGenerator      = [[custom:napalm_phoenix]],
				fireStarter             = 250,
				fixedlauncher           = true,
				flightTime              = 1.8,
				impulseBoost            = 0,
				impulseFactor           = 0.1,
				interceptedByShieldType = 2,
				model                   = [[wep_m_hailstorm.s3o]],
				range                   = 460,
				reloadtime              = 2,
				smokeTrail              = true,
				soundHit                = [[weapon/missile/rapid_rocket_hit]],
				soundStart              = [[weapon/missile/rapid_rocket_fire]],
				sprayAngle              = 1000,
				startVelocity           = 150,
				tolerance               = 6500,
				tracks                  = false,
				turnRate                = 8000,
				turret                  = true,
				weaponAcceleration      = 100,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 800,
				wobble                  = 10000,
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
					projectile1 = "striderdante_napalm_fragment",
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
					shield_damage = 100,
				},
				damage                  = {
					default = 0,
				},

				explosionGenerator      = [[custom:napalm_phoenix]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.2,
				noExplode               = true,
				projectiles             = 10,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 5,
				--soundHit                = [[weapon/burn_mixed]],
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
					burnchance = "1",
					burntime = [[1000]],
					

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
				},
				damage                  = {
					default = 100,
				},

				explosionGenerator      = [[custom:napalm_phoenix]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.2,
				projectiles             = 10,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 5,
				soundHit                = [[weapon/burn_mixed]],
				soundStart              = [[weapon/cannon/wolverine_fire]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},
		
		
			NAPALM_ROCKETS_SALVO = {
				name                    = [[Napalm Rocket Salvo]],
				areaOfEffect            = 228,
				avoidFeature            = false,
				avoidFriendly           = false,
				avoidNeutral            = false,
				burst                   = 10,
				burstrate               = 0.1,
				cegTag                  = [[missiletrailredsmall]],
				commandfire             = true,
				craterBoost             = 0,
				craterMult              = 0,
			
				customParams              = {
					setunitsonfire = "1",
					burnchance = "1",
					
					light_color = [[0.8 0.4 0.1]],
					light_radius = 320,
					reaim_time = 1,
					
					numprojectiles1 = 10, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "striderdante_napalm_fragment_dummy",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-1.5,4,-1.5,1.5,6,1.5",
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					onexplode = "by the power of god, disco and hentai...", -- if true, this projectile will cluster when it explodes
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
				},
				
				damage                  = {
					default = 120.8,
					subs    = 6,
				},
			
				dance                   = 15,
				edgeEffectiveness       = 0.75,
				explosionGenerator      = [[custom:napalm_phoenix]],
				fireStarter             = 250,
				fixedlauncher           = true,
				flightTime              = 1.8,
				impulseBoost            = 0,
				impulseFactor           = 0.1,
				interceptedByShieldType = 2,
				model                   = [[wep_m_hailstorm.s3o]],
				projectiles             = 2,
				range                   = 460,
				reloadtime              = 20,
				smokeTrail              = true,
				soundHit                = [[weapon/missile/rapid_rocket_hit]],
				soundStart              = [[weapon/missile/rapid_rocket_fire]],
				sprayAngle              = 8000,
				startVelocity           = 200,
				tolerance               = 6500,
				tracks                  = false,
				trajectoryHeight        = 0.18,
				turnRate                = 3000,
				turret                  = true,
				weaponAcceleration      = 100,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 800,
				wobble                  = 8000,
			},
		
		},
		
		
		featureDefs         = {
		
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[dante_dead.s3o]],
			},
		
		
			HEAP  = {
				blocking         = false,
				footprintX       = 4,
				footprintZ       = 4,
				object           = [[debris4x4c.s3o]],
			},
		
		},
		
	}
}
