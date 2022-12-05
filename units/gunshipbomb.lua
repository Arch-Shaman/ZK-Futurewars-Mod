return { 
	gunshipbomb = {
		unitname               = "gunshipbomb",
		name                   = "Seeker",
		description            = "Guidable Canister Missile",
		acceleration           = 0.3,
		airStrafe              = 0,
		brakeRate              = 0.4,
		buildCostMetal         = 50,
		builder                = false,
		buildPic               = "gunshipbomb.png",
		canFly                 = true,
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		canSubmerge            = false,
		category               = "GUNSHIP",
		collide                = false,
		collisionVolumeOffsets = "0 0 0",
		collisionVolumeScales  = "20 20 20",
		collisionVolumeType    = "ellipsoid",
		selectionVolumeOffsets = "0 0 0",
		selectionVolumeScales  = "32 32 32",
		selectionVolumeType    = "ellipsoid",
		corpse                 = "DEAD",
		cruiseAlt              = 100,

		customParams           = {
			landflystate   = "1",
			idle_cloak = 1,
		},
		explodeAs              = "TINY_BUILDINGEX",
		--fireState              = 0,
		floater                = true,
		footprintX             = 2,
		footprintZ             = 2,
		hoverAttack            = true,
		iconType               = "gunshipspecial",
		kamikaze               = false, -- Actually uses the weapon to explode!
		kamikazeDistance       = 60,
		kamikazeUseLOS         = true,
		maneuverleashlength    = "1240",
		maxDamage              = 200,
		maxSlope               = 36,
		maxVelocity            = 10.2,
		noAutoFire             = false,
		noChaseCategory        = "TERRAFORM SATELLITE SUB",
		objectName             = "f-1.s3o",
		script                 = "gunshipbomb.lua",
		selfDestructAs         = "TINY_BUILDINGEX",
		selfDestructCountdown  = 0,
		sightDistance          = 800,
		turnRate               = 950,
		upright                = false,
		workerTime             = 0,
		featureDefs            = {
			DEAD      = {
				blocking         = false,
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
		weapons                = {
			{
				def                = "BOOM",
				badTargetCategory  = "UNARMED",
				onlyTargetCategory = "FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER",
			},
		},
		weaponDefs = {
			secondary = {
				name                    = "Cluster Bomblet",
				accuracy                = 200,
				avoidFeature            = false,
				avoidNeutral            = false,
				areaOfEffect            = 160,
				burst                   = 2,
				burstRate               = 0.033,
				commandFire             = true,
				craterBoost             = 1,
				craterMult              = 2,

				customParams            = {
					is_unit_weapon = 1,
					light_camera_height = 2500,
					light_color = "0.22 0.19 0.05",
					light_radius = 380,
					reaim_time = 1,
				},

				damage                  = {
					default = 65.1,
				},
				
				edgeEffectiveness       = 0.33,
				explosionGenerator      = "custom:MEDMISSILE_EXPLOSION",
				fireStarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.2,
				interceptedByShieldType = 2,
				model                   = "wep_b_canister.s3o",
				projectiles             = 4,
				range                   = 360,
				reloadtime              = 30,
				mygravity               = 0.07,
				smokeTrail              = true,
				soundHit                = "explosion/ex_med6",
				soundStart              = "weapon/cannon/cannonfire_001",
				soundHitVolume          = 8,
				soundTrigger            = true,
				sprayangle              = 2500,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 400,
			},
			BOOM_DUMMY = {
				name                    = "Deployable Bomb",
				accuracy                = 400,
				alwaysVisible           = true,
				areaOfEffect            = 350,
				avoidFeature            = false,
				craterBoost             = 1,
				craterMult              = 2,
				collideFeature          = false,
				collideFriendly         = false,
				cegTag                  = "VINDIBACK",
				customParams              = {
					numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "gunshipbomb_boom",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "derpderpderpderpderpderpderpderpderpderp", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 1,
					timeoutspawn = 0,
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					onexplode = "whoops",
					spawndist = 300, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeddeploy = 8,

					--lups_heat_fx = "firewalker",
					light_camera_height = 1500,
					light_color = "0.8 0.76 0.38",
					light_radius = 40,
					shield_damage = 75*20,
					bogus = 1,
				},
				damage                  = {
					default = 0,
				},

				--explosionGenerator      = "custom:smr_big",
				firestarter             = 180,
				impulseBoost            = 0,
				impulseFactor           = 0.42,
				interceptedByShieldType = 1,
				mygravity               = 0.07,
				model                   = "puppymissile.s3o",
				range                   = 900,
				reloadtime              = 12,
				rgbColor                = "1 0.5 0.2",
				size                    = 24,
				soundHit                = "nosound",
				soundStart              = "nosound",
				soundStartVolume        = 3.2,
				sprayangle              = 2500,
				turret                  = true,
				waterweapon             = true,
				weaponType              = "Cannon",
				weaponVelocity          = 320,
			},
			boom = {
				name                    = "Deployable Bomb",
				areaOfEffect            = 0,
				avoidFeature            = false,
				avoidFriendly           = false,
				burnblow                = false,
				craterBoost             = 1,
				craterMult              = 0.5,
				collideFriendly         = false,
				customParams            = {
					numprojectiles1 = 20, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "gunshipbomb_secondary",
					--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
					spawndist = 180, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeoutspawn = 1, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
					vradius1 = "-3,-1,-3,3,1,3", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
					groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
					proxy = 0, -- check for nearby units?
					proxydist = 80, -- how far to check for units? Default: spawndist
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					light_camera_height = 1500,
					light_color = "0.8 0.76 0.38",
					light_radius = 40,
					stats_hide_dps = 1, -- one use
					stats_hide_reload = 1,
					shield_damage = 20*75.1,
				},
				
				damage                  = {
					default = 20*65.1,
				},
				mygravity               = 0.07,
				cegTag                  = "VINDIBACK",
				model                   = "puppymissile.s3o",
				edgeEffectiveness       = 0.75,
				explosionGenerator      = "custom:FLASH64",
				impulseBoost            = 30,
				impulseFactor           = 0.6,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 280,
				reloadtime              = 1.7 + 2/30,
				soundHit                = "weapon/clusters/cluster_light",
				soundStart              = "weapon/missile/air_launched_missile",
				soundStartVolume        = 3,
				turret                  = false,
				weaponType              = "Cannon",
				weaponVelocity          = 550,
				leadLimit = 1,
			},
		}
	} 
}
