return {  
	tankraid = {
		unitname            = [[tankraid]],
		name                = [[Trailblazer]],
		description         = [[Raider Tank]],
		acceleration        = 0.725,
		brakeRate           = 1.45,
		buildCostMetal      = 230,
		builder             = false,
		buildPic            = [[tankraid.png]],
		canGuard            = true,
		canMove             = true,
		canPatrol           = true,
		category            = [[LAND]],
		collisionVolumeOffsets = [[0 0 0]],
		collisionVolumeScales  = [[34 26 34]],
		collisionVolumeType    = [[ellipsoid]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[42 42 42]],
		selectionVolumeType    = [[ellipsoid]],
		corpse              = [[DEAD]],
		customParams        = {
			fireproof      = [[1]],
			specialreloadtime = [[850]],
			modelradius       = [[20]],
			aimposoffset      = [[0 5 0]],
			selection_scale   = 0.85,
			aim_lookahead     = 180,
			percieved_range   = 300, -- How much range enemy units think Kodachi has
			stats_show_death_explosion = true,
		},

		explodeAs           = [[DEATHEXPLO]],
		footprintX          = 3,
		footprintZ          = 3,
		highTrajectory      = 0,
		iconType            = [[tankscout]],
		idleAutoHeal        = 5,
		idleTime            = 300,
		leaveTracks         = true,
		maxDamage           = 1120,
		maxSlope            = 18,
		maxVelocity         = 4.7,
		maxWaterDepth       = 22,
		minCloakDistance    = 75,
		movementClass       = [[TANK3]],
		noAutoFire          = false,
		noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE SUB]],
		objectName          = [[logkoda.s3o]],
		script              = [[tankraid.lua]],
		selfDestructAs      = [[DEATHEXPLO]],
		sightDistance       = 600,
		trackOffset         = 6,
		trackStrength       = 5,
		trackStretch        = 1,
		trackType           = [[StdTank]],
		trackWidth          = 30,
		turninplace         = 0,
		turnRate            = 720,
		workerTime          = 0,
		sfxtypes               = {
			explosiongenerators = {
				[[custom:flamer]],
				[[custom:napalm_phoenix]],
			},
		},
		weapons             = {

			{
				def                = [[NAPALM_SPRAYER]],
				badTargetCategory  = [[GUNSHIP]],
				onlyTargetCategory = [[LAND SINK TURRET SHIP SWIM FLOAT HOVER GUNSHIP]],
			},
			{
				def                = [[NAPALM_BOOST]],
				badTargetCategory  = [[]],
				onlyTargetCategory = [[]],
			},
			--{
			--  def                = [[BOGUS_FAKE_NAPALM_BOMBLET]],
			--  badTargetCategory  = [[GUNSHIP]],
			--  onlyTargetCategory = [[]],
			--},
		},
		weaponDefs             = {
			NAPALM_SPRAYER = {
				name                    = [[Napalm Machine Gun]],
				accuracy                = 500,
				areaOfEffect            = 128,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[flamer]],

				customParams              = {
					setunitsonfire = "1",

					sweepfire = 1,
					sweepfire_maxangle = 15,
					sweepfire_step = 3,
					sweepfire_maxrangemult = 0.98,

					stats_custom_tooltip_1 = " - Slowdown while Firing:",
					stats_custom_tooltip_entry_1 = "60%",
				},

				damage                  = {
					default = 19,
				},

				explosionGenerator      = [[custom:napalm_phoenix]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.55,
				--projectiles             = 10,
				range                   = 270,
				reloadtime              = 0.133,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 5,
				soundHit                = [[flamethrowerhit]],
				soundStart              = [[flamethrowerfire]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 400,
			},
			NAPALM_BOOST = {
				name                    = [[Afterburner Overload]],
				accuracy                = 0,
				areaOfEffect            = 80,
				avoidFeature            = false,
				burst                   = 50,
				burstrate               = 0.1,
				canattackground         = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[flamer]],
				customParams              = {
					setunitsonfire = "1",

					area_damage = 1,
					area_damage_radius = 80,
					area_damage_dps = 80,
					area_damage_duration = 16,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 460,

					stats_custom_tooltip_1 = " - Health Cost per Usage:",
					stats_custom_tooltip_entry_1 = "450 hp",
					stats_custom_tooltip_2 = " - Mininium Health to remain Active:",
					stats_custom_tooltip_entry_2 = "100 hp",
				},
      
				damage                  = {
					default = 0,
				},
    
				explosionGenerator      = [[custom:napalm_firewalker_small]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0,
				noSelfDamage            = true,
				--projectiles             = 10,
				range                   = 0,
				reloadtime              = 15,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 5,
				--soundHit                = [[weapon/cannon/wolverine_hit]],
				soundStart              = [[weapon/cannon/flamethrower_fire_dash]],
				soundStartVolume        = 3.2,
				sprayangle              = 0,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 100,
			},
			DEATHEXPLO = {
				name                    = [[Fuel Tank Rupture]], --CREDITS: Cliver5
				areaOfEffect            = 216,
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

					numprojectiles1 = 12, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "tankraid_napalm_fragment_dummy",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-2.5,3,-2.5,2.5,6,2.5",
					noairburst = "Sattuu ihan perkeleesti", -- if true, this projectile will skip all airburst checks
					onexplode = "Sattuu ihan vitusti", -- if true, this projectile will cluster when it explodes
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					
					area_damage = 1,
					area_damage_radius = 108,
					area_damage_dps = 20,
					area_damage_duration = 16,
					
					stats_damage = (35*24) + 200,
					shield_damage = (35*24) + 200,
					stats_shield_damage = (35*24) + 200,
				},

				damage                  = {
					default = 50,
				},

				explosionGenerator      = [[custom:napalm_koda]],
				fireStarter             = 70,
				flightTime              = 3,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				--model                   = [[wep_b_fabby.s3o]], --TODO: replace with SharkGameDev's better model. delete this once it's done.
				range                   = 340,
				reloadtime              = 45,
				smokeTrail              = true,
				soundHit                = [[flamethrowerhit]],
				soundHitVolume          = 0,
				soundStart              = [[weapon/cannon/cannon_fire3]],
				trajectoryHeight        = 1,
				texture2                = [[lightsmoketrail]],
				tolerance               = 8000,
				size = 0.1,
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
					projectile1 = "tankraid_napalm_fragment",
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
		},
		featureDefs         = {

			DEAD = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[logkoda_dead.s3o]],
			},


			HEAP = {
				blocking         = false,
				footprintX       = 2,
				footprintZ       = 2,
				object           = [[debris2x2c.s3o]],
			},

		},
	}
}
