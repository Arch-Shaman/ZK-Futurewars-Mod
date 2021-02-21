return { 
	jumparty = {
		unitname               = [[jumparty]],
		name                   = [[Firewall]],
		description            = [[Area Denial Artillery (Line)]],
		acceleration           = 0.36,
		brakeRate              = 1.44,
		buildCostMetal         = 1100,
		builder                = false,
		buildPic               = [[jumparty.png]],
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND]],
		selectionVolumeOffsets = [[0 0 0]],
		selectionVolumeScales  = [[55 55 55]],
		selectionVolumeType    = [[ellipsoid]],
		corpse                 = [[DEAD]],
		customParams           = {
			selection_scale   = 0.92,
		},

		explodeAs              = [[BIG_UNITEX]],
		footprintX             = 4,
		footprintZ             = 4,
		iconType               = [[fatbotarty]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 1250,
		maxSlope               = 36,
		maxVelocity            = 1.4,
		maxWaterDepth          = 22,
		movementClass          = [[KBOT4]],
		noAutoFire             = false,
		noChaseCategory        = [[TERRAFORM SATELLITE SUB]],
		objectName             = [[firewalker.s3o]],
		script                 = [[jumparty.lua]],
		selfDestructAs         = [[BIG_UNITEX]],
		sfxtypes               = {

			explosiongenerators = {
				[[custom:shellshockflash]],
				[[custom:SHELLSHOCKSHELLS]],
				[[custom:SHELLSHOCKGOUND]],
			},
		},
		sightDistance          = 660,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 0.6,
		trackType              = [[ComTrack]],
		trackWidth             = 33,
		turnRate               = 720,
		upright                = true,
		workerTime             = 0,
		weapons                = {

			{
				def                = [[NAPALM_SPRAYER]],
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER]],
			},
		},
		weaponDefs             = {
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
					area_damage_radius = 60,
					area_damage_dps = 25,
					area_damage_duration = 14,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
				},
				damage                  = {
					default = 40,
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
				soundHit                = [[weapon/burn_mixed]],
				soundStart              = [[weapon/cannon/wolverine_fire]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},
			NAPALM_SPRAYER = {
				name                    = [[Incendiary Mortar]],
				areaOfEffect            = 128,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[flamer]],
				customParams              = {
					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 460,
					numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "jumparty_napalm_fragment",
					--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					keepmomentum1 = 0,
					spawndist = 700, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = "-2,-4,-2,2,0,2", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					useheight = 1, -- check the distance between ground and projectile? OPTIONAL.
					noairburst = "Friendship is Magic... and Magic throws missiles off course!",
					clustercharges = 18,
					clusterdelay = 7,
					timeddeploy = 40,
					
					setunitsonfire = "1",
					burntime = 200,

					area_damage = 1,
					area_damage_radius = 100,
					area_damage_dps = 50,
					area_damage_duration = 14,
					
				},
				damage                  = {
					default = 300,
				},

				explosionGenerator      = [[custom:napalm_koda_small]],
				flightTime              = 10,
				model					= [[wep_napalm.s3o]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				--myGravity               = 0.1,
				burst					= 2,
				burstRate				= 0.5,
				--projectiles             = 10,
				range                   = 1000,
				reloadtime              = 12,
				rgbColor                = [[1 0.5 0.2]],
				--size                    = 5,
				soundHit                = [[weapon/clusters/cluster_light_napalm]],
				soundStart              = [[weapon/missile/air_launched_missile]],
				soundStartVolume        = 3.2,
				sprayangle              = 500,
				accuracy				= 500,
				trajectoryHeight		= 0.5,
				turret                  = true,
				weaponAcceleration		= 420,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 320,
			},
		},
		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 3,
				footprintZ       = 3,
				object           = [[firewalker_dead.s3o]],
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
