return { 
	staticnuke = {
		unitname                      = [[staticnuke]],
		name                          = [[Oblivion]],
		description                   = [[MIRV Launcher, Drains 25 m/s, 4 minute stockpile]],
		acceleration                  = 0,
		brakeRate                     = 0,
		buildCostMetal                = 8000,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 10,
		buildingGroundDecalSizeY      = 10,
		buildingGroundDecalType       = [[staticnuke_aoplane.dds]],
		buildPic                      = [[staticnuke.png]],
		category                      = [[SINK UNARMED]],
		collisionVolumeOffsets        = [[0 0 0]],
		collisionVolumeScales         = [[90 55 115]],
		collisionVolumeType           = [[box]],
		corpse                        = [[DEAD]],

		customParams                  = {
			stockpiletime  = [[240]],
			stockpilecost  = [[6000]],
			priority_misc  = 1, -- Medium
		},

		explodeAs                     = [[ATOMIC_BLAST]],
		footprintX                    = 6,
		footprintZ                    = 8,
		iconType                      = [[nuke]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		maxDamage                     = 5000,
		maxSlope                      = 18,
		maxVelocity                   = 0,
		maxWaterDepth                 = 0,
		minCloakDistance              = 150,
		noAutoFire                    = false,
		objectName                    = [[Silencer.s3o]],
		script                        = [[staticnuke.lua]],
		selfDestructAs                = [[ATOMIC_BLAST]],
		sightDistance                 = 660,
		turnRate                      = 0,
		useBuildingGroundDecal        = true,
		workerTime                    = 0,
		yardmap                       = [[oooooooooooooooooooooooooooooooooooooooooooooooo]],

		weapons                       = {

			{
				def                = [[crblmssl]],
				badTargetCategory  = [[SWIM LAND SHIP HOVER]],
				onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER]],
			},

		},


		weaponDefs                    = {
			warhead = {
				name                    = [[Nuclear Warhead]],
				areaOfEffect            = 1920,
				cegTag                  = [[NUCKLEARMINI]],
				collideFriendly         = false,
				collideFeature          = false,
				commandfire             = true,
				craterBoost             = 6,
				craterMult              = 6,
				customParams              = {
					restrict_in_widgets = 1,
					alwaysvisible = 1,
					light_color = [[2.92 2.64 1.76]],
					light_radius = 3000,
					cruisealt = 6000,
					airlaunched = 1,
					cruisedist = [[300]],
				},
				damage                  = {
					default = 12000.1,
				},
				edgeEffectiveness       = 0.3,
				explosionGenerator      = [[custom:LONDON_FLAT]],      -- note, spawning of the explosion is handled by exp_nuke_effect_chooser.lua
				fireStarter             = 0,
				flightTime              = 180,
				impulseBoost            = 0.5,
				impulseFactor           = 0.2,
				interceptedByShieldType = 65,
				model                   = [[crblmsslr.s3o]],
				noSelfDamage            = false,
				range                   = 72000,
				reloadtime              = 10,
				smokeTrail              = false,
				soundHit                = [[explosion/ex_ultra8]],
				startVelocity           = 800,
				stockpile               = true,
				tracks					= true,
				turnrate                = 18000,
				stockpileTime           = 10^5,
				targetable              = 1,
				texture1                = [[null]], --flare
				tolerance               = 4000,
				weaponAcceleration      = 0,
				weaponTimer             = 10,
				weaponType              = [[MissileLauncher]],
				weaponVelocity          = 800,
			},
			crblmssl = {
				name                    = [[Nuclear MIRV]],
				areaOfEffect            = 0, --1920,
				cegTag                  = [[NUCKLEARMINI]],
				collideFriendly         = false,
				collideFeature          = false,
				commandfire             = true,
				craterBoost             = 6,
				craterMult              = 6,
				customParams              = {
					restrict_in_widgets = 1,
					cruisealt = 6000,
					cruisedist = 400,
					numprojectiles1 = 3, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "staticnuke_warhead",
					spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					spawndist = 5000, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 0, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = 0, -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					useheight = 1,
					usertargetable = 1,
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					light_color = [[2.92 2.64 1.76]],
					light_radius = 3000,
					
					
					stats_custom_tooltip_1 = " - Carries MIRV Warheads",
					stats_custom_tooltip_entry_1 = "",
					stats_custom_tooltip_2 = "    - Warhead Count:",
					stats_custom_tooltip_entry_2 = "3",
					stats_custom_tooltip_3 = "    - Warhead Range:",
					stats_custom_tooltip_entry_3 = "1750 elmos",
				},
				damage                  = {
					default = 36000.1,
				},
				edgeEffectiveness       = 0.3,
				explosionGenerator      = [[custom:MEDMISSILE_EXPLOSION]],      -- note, spawning of the explosion is handled by exp_nuke_effect_chooser.lua
				fireStarter             = 0,
				flightTime              = 900,
				impulseBoost            = 0.5,
				impulseFactor           = 0.2,
				interceptedByShieldType = 65,
				model                   = [[crblmsslr.s3o]],
				noSelfDamage            = false,
				range                   = 140000,
				reloadtime              = 30,
				smokeTrail              = false,
				soundHit                = [[weapon\missile\nuclear_reentry]],
				startVelocity           = 100,
				stockpile               = true,
				stockpileTime           = 10^5,
				targetable              = 1,
				texture1                = [[null]], --flare
				tolerance               = 4000,
				weaponAcceleration      = 100,
				turnrate                = 18000,
				tracks                  = true,
				weaponType              = [[StarburstLauncher]],
				weaponVelocity          = 1100,
			},
			
		},

		featureDefs                   = {
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 6,
				footprintZ       = 8,
				object           = [[silencer_dead.s3o]],
			},

			HEAP  = {
				blocking         = false,
				footprintX       = 6,
				footprintZ       = 8,
				object           = [[debris4x4a.s3o]],
			},
		},
	} 
}
