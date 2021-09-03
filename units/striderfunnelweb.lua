return { 
	striderfunnelweb = {
		unitname               = [[striderfunnelweb]],
		name                   = [[Funnelweb]],
		description            = [[Shielded Fire Support Strider]],
		acceleration           = 0.166,
		activateWhenBuilt      = true,
		brakeRate              = 0.825,
		buildCostMetal         = 6400,
		buildPic               = [[striderfunnelweb.png]],
		builder                = false,
		canGuard               = true,
		canMove                = true,
		canPatrol              = true,
		category               = [[LAND]],
		collisionVolumeOffsets        = [[0 10 -10]],
		collisionVolumeScales         = [[60 50 80]],
		collisionVolumeType           = [[elipsoid]],
		selectionVolumeOffsets        = [[0 0 0]],
		selectionVolumeScales         = [[80 80 80]],
		selectionVolumeType           = [[Sphere]],
		corpse                 = [[DEAD]],

		customParams           = {
			priority_misc  = 1, -- Medium
			shield_emit_height = 45,
			shield_power_gfx_override = 10000,
			bait_level_default = 1,
		},

		explodeAs              = [[ESTOR_BUILDING]],
		footprintX             = 4,
		footprintZ             = 4,
		iconType               = [[t3spiderbuilder]],
		idleAutoHeal           = 5,
		idleTime               = 1800,
		leaveTracks            = true,
		maxDamage              = 15000,
		maxSlope               = 36,
		maxVelocity            = 1.4,
		maxWaterDepth          = 22,
		minCloakDistance       = 150,
		movementClass          = [[TKBOT4]],
		noAutoFire             = false,
		noChaseCategory        = [[TERRAFORM FIXEDWING GUNSHIP SATELLITE SUB]],
		objectName             = [[funnelweb.dae]],
		radarDistance          = 2200,
		radarEmitHeight        = 32,
		onoffable              = true,
		selfDestructAs         = [[ESTOR_BUILDING]],
		highTrajectory         = 2,

		sfxtypes               = {
			explosiongenerators = {
				[[custom:RAIDMUZZLE]],
				[[custom:RAIDDUST]],
			},
		},
		script                 = [[striderfunnelweb.lua]],
		showNanoSpray          = false,
		sightDistance          = 650,
		trackOffset            = 0,
		trackStrength          = 8,
		trackStretch           = 1,
		trackType              = [[ChickenTrackPointy]],
		trackWidth             = 85,
		turnRate               = 230,

		weapons                = {
			{
				def                = [[CANNON]],
				badTargetCategory  = [[FIXEDWING]],
				mainDir            = [[0 0 1]],
				maxAngleDif		   = 45,
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
			{
				def                = [[SHIELD]],
			},
		},
		
		
		weaponDefs             = {
			SHIELD = {
				name                    = [[Energy Shield]],
				damage                  = {
					default = 10,
				},
				customParams            = {},

				exteriorShield          = true,
				shieldAlpha             = 0.2,
				shieldBadColor          = [[1 0.1 0.1 1]],
				shieldGoodColor         = [[0.1 0.1 1 1]],
				shieldInterceptType     = 3,
				shieldPower             = 32000,
				shieldPowerRegen        = 350,
				shieldPowerRegenEnergy  = 40,
				shieldRadius            = 450,
				shieldRepulser          = false,
				smartShield             = true,
				visibleShield           = false,
				visibleShieldRepulse    = false,
				weaponType              = [[Shield]],
			},
			
			FRAGMENT = {
				name                    = [[Shield Buster Chaff]],
				areaOfEffect            = 120,
				avoidFeature            = true,
				cegTag                  = [[beamweapon_muzzle_purple]],
				commandFire             = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					timeslow_damagefactor = 1.5,
					timeslow_overslow_frames = 5*30, --5 seconds before slow decays
					nofriendlyfire = 1,
					light_camera_height = 3500,
					light_color = [[0.5 0.0 0.5]],
					light_radius = 220,
					shield_damage = 150,
				},

				damage                  = {
					default = 100,
				},
				fireStarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				explosionGenerator      = [[custom:riotballplus2_purple_small]],
				range                   = 1100,
				reloadtime              = 4.4,
				myGravity				= 0.09,
				heightBoostFactor       = 1.1,
				rgbColor				= [[0.5 0 0.5]],
				soundHit				= [[weapon/aoe_aura2]],
				soundHitVolume          = 4,
				soundStart              = [[weapon/cannon/funnel_fire]],
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 450,
			},
			
			FRAGMENT_FAKE = {
				name                    = [[Shield Buster Chaff]],
				areaOfEffect            = 120,
				avoidFeature            = true,
				cegTag                  = [[beamweapon_muzzle_purple]],
				commandFire             = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					light_camera_height = 3500,
					light_color = [[0.5 0.0 0.5]],
					light_radius = 220,
					shield_damage = 150,
					numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "striderfunnelweb_fragment",
					clustervec1 = "derpderpderpderpderpderpderpderpderpderp", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 1,
					timeoutspawn = 0,
					noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					timeddeploy = 20,
					shield_damage = 185,
					bogus = 1
				},

				damage                  = {
					default = 0,
				},
				fireStarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				myGravity               = 0.1,
				noExplode               = true,
				explosionGenerator      = [[custom:riotballplus2_purple_small]],
				range                   = 700,
				reloadtime              = 3,
				rgbColor				= [[0.5 0 0.5]],
				soundHit                = [[nosound]],
				soundHitVolume          = 8,
				soundStart              = [[weapon/cannon/funnel_fire]],
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 350,
			},
			
			CANNON = {
				name                    = [[SX-42 Shield Buster Cannon]],
				areaOfEffect            = 48,
				avoidFeature            = true,
				cegTag                  = [[beamweapon_muzzle_purple]],
				craterBoost             = 0,
				craterMult              = 0,
				burst					= 2,
				burstRate				= 0.9,
				customParams        = {
					timeslow_damagefactor = 1.35,
					light_camera_height = 3500,
					light_color = [[0.5 0.0 0.5]],
					light_radius = 220,
					timeslow_overslow_frames = 5*30, --5 seconds before slow decays
					nofriendlyfire = 1,
					numprojectiles1 = 12, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
					projectile1 = "striderfunnelweb_fragment_fake",
					--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
					clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
					keepmomentum1 = 0,
					timeoutspawn = 0,
					vradius1 = "-3,2,-3,3,4,3",
					noairburst = "EI", -- if true, this projectile will skip all airburst checks
					onexplode = "RUOTSI", -- if true, this projectile will cluster when it explodes
					spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
					useheight = 1, -- check the distance between ground and projectile? OPTIONAL.
					stats_damage = 1200,
					shield_damage = 1, -- we want it to impact the shield to cause a lot of projectiles to spawn on it and damage it.
					stats_shield_damage = (150*24) + 135 * 24,
				},

				damage                  = {
					default = 1200,
				},
				fireStarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				range                   = 800,
				mgravity				= 0.22,
				reloadtime              = 6.5,
				rgbColor				= [[0.5 0 0.5]],
				smokeTrail              = true,
				size 					= 8,
				soundHit                = [[weapon/cannon/heavy_disrupter_hit]],
				soundHitVolume          = 8,
				soundStart              = [[weapon/cannon/funnel_fire]],
				highTrajectory          = 2,
				tolerance               = 8000,
				turret                  = true,
				weaponType              = [[Cannon]],
				weaponVelocity          = 420,
			},
		},


		featureDefs            = {
			DEAD  = {
				blocking         = true,
				featureDead      = [[HEAP]],
				footprintX       = 4,
				footprintZ       = 4,
				object           = [[funnelweb_dead.s3o]],
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 4,
				footprintZ       = 4,
				object           = [[debris4x4a.s3o]],
			},
		},
	} 
}
