return {
	energyheavygeo = {
		unitname                      = [[energyheavygeo]],
		name                          = [[Advanced Geothermal]],
		description                   = [[Large Powerplant (+150) - Increases slowly over time, EXTREAMLY HAZARDOUS]],
		activateWhenBuilt             = true,
		buildCostMetal                = 1500,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 9,
		buildingGroundDecalSizeY      = 9,
		buildingGroundDecalType       = [[energyheavygeo_aoplane.dds]],
		buildPic                      = [[energyheavygeo.png]],
		category                      = [[SINK UNARMED]],
		corpse                        = [[DEAD]],
    
		customParams                  = {
			pylonrange     = 150,
			removewait     = 1,
			removestop     = 1,
			decay_time     = 2,
			decay_maxoutput= 1.4,
			decay_initialrate = 0.6,
			decay_rate     = -0.002,
			stats_show_death_explosion = true,
		},
    
		energyMake                    = 250, --ik the AI doesn't build geos, but when they do, hopefully they builds lots!
		energyUse                     = 0,
		explodeAs                     = [[energyheavygeo_DEATH]],
		footprintX                    = 5,
		footprintZ                    = 5,
		iconType                      = [[energyheavygeo]],
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		maxDamage                     = 3750,
		maxSlope                      = 255,
		objectName                    = [[energyheavygeo.s3o]],
		script                        = [[energyheavygeo.lua]],
		selfDestructAs                = [[energyheavygeo_DEATH]],
		sightDistance                 = 273,
		useBuildingGroundDecal        = true,
		yardMap                       = [[ooooo ogggo ogggo ogggo ooooo]],
		weaponDefs            = {
			YELLOWSTONE = {
				name                    = [[Supervolcanic Eruption (Death Explosion)]],
				--cegTag                  = [[missiletrailred]],
				areaOfEffect            = 1280,
				canAttackGround         = false,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					setunitsonfire = "1",
					burntime = 1980,

					numprojectiles1 = 60, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "energyheavygeo_napalm_fragment_dummy",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-2,5,-2,2,12,2",
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeddeploy = 1,
					--clustercharges = 60,
					--clusterdelay = 2,

					stats_damage = 9500,
					stats_hide_dps = true,
					stats_hide_reload = true,
					stats_hide_range = true,
				},

				damage                  = {
					default = 0,
				},

				fireStarter             = 70,
				interceptedByShieldType = 0,
				model                   = [[wep_b_fabby.s3o]],
				range                   = 5,
				reloadtime              = 45,
				soundHit                = [[nosound]],
				soundStart              = [[nosound]],
				texture2                = [[lightsmoketrail]],
				tolerance               = 8000,
				turret                  = true,
				waterweapon             = true,
				weaponType              = [[LaserCannon]],
				weaponVelocity          = 1,
			},
			NAPALM_FRAGMENT_DUMMY = {
				name                    = [[Volcanic Superbomb]], --https://en.wikipedia.org/wiki/Volcanic_bomb but on steroids
				accuracy                = 400,
				alwaysVisible           = true,
				areaOfEffect            = 350,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[meteor_trail]],
				customParams              = {
					numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "energyheavygeo_napalm_fragment",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "derpderpderpderpderpderpderpderpderpderp", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 1,
					timeoutspawn = 0,
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					onexplode = "whoops",
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeddeploy = 120,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
					shield_damage = 40,
					bogus = 1,
				},
				damage                  = {
					default = 0,
				},

				explosionGenerator      = [[custom:smr_big]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.42,
				interceptedByShieldType = 1,
				myGravity               = 0.04,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 24,
				soundHit                = [[nosound]],
				soundStart              = [[nosound]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				waterweapon             = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},
			NAPALM_FRAGMENT = {
				name                    = [[Volcanic Superbomb]], --https://en.wikipedia.org/wiki/Volcanic_bomb but on steroids
				accuracy                = 400,
				alwaysVisible           = true,
				areaOfEffect            = 350,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[meteor_trail]],
				customParams              = {
					setunitsonfire = "1",
					burntime = 900,

					numprojectiles1 = 8, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "energyheavygeo_napalm_fragment_fragment",
					spreadradius1 = "10,10",
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					clusterpos1 = "randomy",
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-1.75,2,-1.5,1.75,5,1.75",
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					onexplode = "by the power of god, disco and hentai...", -- if true, this projectile will cluster when it explodes
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.

					area_damage = 1,
					area_damage_radius = 160,
					area_damage_dps = 250,
					area_damage_duration = 24,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
				},
				damage                  = {
					default = 2200,
				},
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.42,
				interceptedByShieldType = 1,
				myGravity               = 0.04,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 24,
				soundHit                = [[weapon/cannon/supergun_bass_boost]], --it's effectively an asteroid, so why not use the asteroid sounds?
				soundStart              = [[nosound]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},
			NAPALM_FRAGMENT_FRAGMENT = {
				name                    = [[Magma Fireball]],
				accuracy                = 400,
				alwaysVisible           = true,
				areaOfEffect            = 162,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				cegTag                  = [[flamer]],
				customParams            = {
					setunitsonfire = "1",
					burntime = 450,

					area_damage = 1,
					area_damage_radius = 60,
					area_damage_dps = 100,
					area_damage_duration = 16,

					--lups_heat_fx = [[firewalker]],
					light_camera_height = 2500,
					light_color = [[0.25 0.13 0.05]],
					light_radius = 500,
				},
				damage                  = {
					default = 560,
				},

				explosionGenerator      = [[custom:smr]],
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 1,
				myGravity               = 0.05,
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = [[1 0.5 0.2]],
				size                    = 10,
				soundHit                = [[explosion/ex_med17]],
				soundStart              = [[nosound]],
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 320,
			},
			energyheavygeo_DEATH = {
				name                    = [[Supervolcanic Eruption]],
				areaOfEffect            = 1280,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					setunitsonfire = "1",
					burntime = 2700,

					numprojectiles1 = 60, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "energyheavygeo_napalm_fragment_dummy",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-2,2,-2,2,12,2",
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeddeploy = 1,
				},
				damage                  = {
					default = 9500,
				},

				explosionGenerator      = [[custom:NUKE_600]],
				firestarter             = 400,
				impulseBoost            = 0.5,
				impulseFactor           = 0.2,
				soundHit                = [[explosion/mohoexplode]],
				soundHitVolume          = 10000,
			}
		},
		
		featureDefs                   = {
    
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 5,
				footprintZ       = 5,
				object           = [[energyheavygeo_dead.s3o]],
			},
    
			HEAP  = {
				blocking         = false,
				footprintX       = 5,
				footprintZ       = 5,
				object           = [[debris4x4a.s3o]],
			},
    
		},
	}
}
