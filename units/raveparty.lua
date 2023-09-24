local accuracy = 500
local velocity = 2350

return { 
	raveparty = {
		unitname                      = "raveparty",
		name                          = "Disco Rave Party - Globally Revealed at 65%% completion",
		description                   = "Destructive Rainbow Projector",
		buildCostMetal                = 48000,
		builder                       = false,
		buildingGroundDecalDecaySpeed = 30,
		buildingGroundDecalSizeX      = 6,
		buildingGroundDecalSizeY      = 6,
		buildingGroundDecalType       = "staticheavyarty_aoplane.dds",
		buildPic                      = "raveparty.png",
		category                      = "SINK",
		collisionVolumeOffsets        = "0 0 0",
		collisionVolumeScales         = "70 194 70",
		collisionVolumeType           = "cylY",
		corpse                        = "DEAD",
		customParams                  = {
			modelradius    = "35",
			bait_level_default = 0,
			draw_blueprint_facing = 1,
			superweapon = 1,
			neededLink = 750,
			keeptooltip = "any string i want",
			pylonrange  = 330,
			reveal_losunit = "los_superwep",
			reveal_onprogress = 0.65,
		},
		explodeAs                     = "SUPERCOOKED",
		footprintX                    = 7,
		footprintZ                    = 7,
		highTrajectory                = 2,
		iconType                      = "mahlazer",
		idleAutoHeal                  = 5,
		idleTime                      = 1800,
		levelGround                   = false,
		losEmitHeight                 = 100,
		maxDamage                     = 36000,
		maxSlope                      = 18,
		maxWaterDepth                 = 0,
		noChaseCategory               = "FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER",
		objectName                    = "raveparty.s3o",
		--onoffable                        = true,
		script                        = "raveparty.lua",
		selfDestructAs                = "SUPERCOOKED",
		sfxtypes                      = {
			explosiongenerators = {
				"custom:staticheavyarty_SHOCKWAVE",
				"custom:staticheavyarty_SMOKE",
				"custom:staticheavyarty_FLARE",
			},
		},
		sightDistance                 = 660,
		useBuildingGroundDecal        = true,
		yardMap                       = "ooooooo ooooooo ooooooo ooooooo ooooooo ooooooo ooooooo",
		weapons                       = {
			{
				def                = "RED_KILLER",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "ORANGE_ROASTER",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "YELLOW_SLAMMER",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "GREEN_STAMPER",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "BLUE_SHOCKER",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "VIOLET_SLUGGER",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "FAKE_TIMEKEEPER",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "SAPPHIRE",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "RUBY",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
			{
				def                = "RAINBOW",
				onlyTargetCategory = "SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP",
			},
		},
		weaponDefs                    = {
			RED_KILLER = {
				name                    = "Radioactive Red",
				accuracy                = accuracy,
				avoidFeature            = false,
				avoidGround             = false,
				areaOfEffect            = 800,
				craterBoost             = 4,
				craterMult              = 10,
				customParams = {
					script_reload = "6",
					light_color = "1 0.1 0.1",
					light_radius = 40,
					light_camera_height = 1500,
					mass = 69420,
				},
				damage                  = {
					default = 10000.1,
				},
				edgeeffectiveness       = 0.1,
				explosionGenerator      = "custom:nukebigland",
				impulseBoost            = 0,
				impulseFactor           = 2.3,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "1 0.1 0.1",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "weapon/missile/mininuke_hit",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
			SAPPHIRE = {
				name                    = "Singularity Sapphire",
				accuracy                = accuracy,
				avoidFeature            = false,
				avoidGround             = false,
				areaOfEffect            = 1280,
				craterBoost             = 4,
				craterMult              = 10,
				customParams = {
					script_reload = 6,
					singularity = "1",
					singu_radius = 1280,
					singu_lifespan = 600,
					singu_strength = 900,
					singu_height = 300,
					singu_ceg = "black_hole_1280",
					singu_nodamageimmunity = "uwu~",
					detachmentradius = "500",
					restrict_in_widgets = 1,
					stats_hide_dps = 1, -- one use
					stats_hide_reload = 1,
					light_color = "0.059 0.322 0.729",
					light_radius = 550,
					reveal_unit = 12,
					mass = 69420,
				},
				damage                  = {
					default = 10.1,
				},
				edgeeffectiveness       = 0.1,
				explosionGenerator      = "custom:FLASHSMALLUNITEX",
				impulseBoost            = 0,
				impulseFactor           = 2.3,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.059 0.322 0.729",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "weapon/missile/mininuke_hit",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
			RUBY = {
				name                    = "Ruby Roaster",
				accuracy                = accuracy,
				avoidFeature            = false,
				avoidGround             = false,
				areaOfEffect            = 800,
				craterBoost             = 4,
				craterMult              = 10,
				cegTag                  = "flamer_koda",
				customParams = {
					script_reload = "6",
					light_color = "0.8784 0.0667 0.3725",
					light_radius = 40,
					light_camera_height = 1500,
					numprojectiles1 = 6,
					projectile1 = "raveparty_ruby_secondary",
					velspread1 = "6.37, 3, 6.37",
					spawndist = 1200,
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					mass = 69420,
				},
				damage                  = {
					default = 6*3*(8*25),
				},
				edgeeffectiveness       = 0.1,
				explosionGenerator      = "custom:NONE",
				impulseBoost            = 0,
				impulseFactor           = 2.3,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.8784 0.0667 0.3725",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "weapon/cannon/plasma_hit",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
			RUBY_SECONDARY = {
				name                    = "Thermite Blob",
				cegTag                  = "flamer_koda",
				areaOfEffect            = 512,
				craterAreaOfEffect      = 0,
				avoidFriendly           = false,
				collideFriendly         = false,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        	  = {
					numprojectiles1 = 15,
					projectile1 = "raveparty_ruby_tritary",
					spawndist = 900, 
					velspread1 = "6.37, 3, 6.37",
					reaim_time = 60, -- Fast update not required (maybe dangerous)
					setunitsonfire = "1",
					burntime = 90,
					restrict_in_widgets = 1,
					light_color = "1.35 0.5 0.36",
					light_radius = 550,
					mass = 69420,
				},
				damage                  = {
					default = 151,
				},
				edgeeffectiveness       = 0.1,
				explosionGenerator      = "custom:NONE",
				impulseBoost            = 0,
				impulseFactor           = 2.3,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.8784 0.0667 0.3725",
				reloadtime              = 1/30,
				size                    = 7.5,
				sizeDecay               = 0.03,
				soundHit                = "weapon/cannon/plasma_hit",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 2750,
			},
			ruby_tritary = {
				name 			        = "Fireball",
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
					reveals_unit = 3,
					mass = 69420,
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
			ORANGE_ROASTER = {
				name                    = "Orange Obliterator",
				accuracy                = accuracy,
				areaOfEffect            = 640,
				craterAreaOfEffect      = 80,
				avoidFeature            = false,
				avoidGround             = false,
				craterBoost             = 0.25,
				craterMult              = 0.5,
				customParams              = {
					script_reload = "6",
					numprojectiles1 = 30,
					projectile1 = "raveparty_orange_secondary",
					spawndist = 1000,
					useheight = 1,
					velspread1 = "6.37, 3, 6.37",
					light_camera_height = 1500,
					light_color = "0.9 0.3 0",
					light_radius = 240,
					mass = 69420,
				},
				damage                  = {
					default = 300.1*30,
				},
				edgeeffectiveness       = 0.25,
				explosionGenerator      = "custom:MEDMISSILE_EXPLOSION",
				impulseBoost            = 0.2,
				impulseFactor           = 0.1,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.9 0.3 0",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "weapon/cannon/mini_cannon",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
			ORANGE_SECONDARY = {
				name                    = "Orange Obliterator Particle",
				accuracy                = 350,
				alphaDecay              = 0.7,
				areaOfEffect            = 96,
				burnblow                = true,
				craterBoost             = 1,
				craterMult              = 2,
				customParams        = {
					light_camera_height = 1500,
					light_color = "0.9 0.3 0",
					light_radius = 40,
					mass = 69420,
				},
				damage                  = {
					default = 300.1,
				},
				edgeEffectiveness       = 0.5,
				explosionGenerator      = "custom:DOT_Pillager_Explo",
				firestarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				intensity               = 0.7,
				size                    = 5,
				interceptedByShieldType = 1,
				noSelfDamage            = true,
				range                   = 400,
				reloadtime              = 0.5,
				rgbColor                = "0.9 0.3 0",
				separation              = 1.5,
				soundHit                = "weapon/cannon/rhino3",
				soundStart              = "weapon/heavy_emg",
				stages                  = 10,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 550,
			},
			YELLOW_SLAMMER = {
				name                    = "Yellow Yeeter",
				accuracy                = accuracy,
				areaOfEffect            = 360,
				craterAreaOfEffect      = 96,
				avoidFeature            = false,
				avoidGround             = false,
				craterBoost             = 0.5,
				craterMult              = 1,
				customParams = {
					script_reload = "6",
					lups_explodelife = 1.0,
					lups_explodespeed = 0.8,
					light_radius = 360,
					blastwave_size = 30,
					blastwave_impulse = 15,
					blastwave_speed = 20,
					blastwave_life = 15,
					blastwave_lossfactor = 0.99,
					blastwave_damage = 60,
					damage_vs_shield = 200,
					mass = 69420,
				},
				damage                  = {
					default = 401.1,
				},
				edgeeffectiveness       = 0.5,
				explosionGenerator      = "custom:sonic_360",
				explosionSpeed          = 500,
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.7 0.7 0",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "weapon/cannon/earthshaker",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
			GREEN_STAMPER = {
				name                    = "Green Grazer",
				accuracy                = accuracy,
				areaOfEffect            = 384,
				avoidFeature            = false,
				avoidGround             = false,
				craterBoost             = 0,
				craterMult              = 0,
				customParams            = {
					script_reload = "6",
					numprojectiles1 = 40,
					projectile1 = "raveparty_green_secondary",
					spawndist = 1000, 
					useheight = 1,
					velspread1 = "10.19, -3, 10.19, _, 0, _", -- velocity that is randomly added. covers range of +-velspread. OPTIONAL. Default: 4.2
					light_camera_height = 1500,
					light_color = "0.1 1 0.1",
					light_radius = 40,
					mass = 69420,
				},
				damage                  = {
					default = 40*800.1,
				},
				explosionGenerator      = "custom:MEDMISSILE_EXPLOSION",
				impulseBoost            = 0.7,
				impulseFactor           = 0.5,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.1 1 0.1",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "explosion/ex_large4",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
			GREEN_SECONDARY = {
				name                    = "Perkele",
				accuracy                = accuracy,
				areaOfEffect            = 128,
				avoidFeature            = false,
				avoidGround             = false,
				craterBoost             = 80,
				craterMult              = 70,
				customParams            = {
					script_reload = "6",
					light_camera_height = 1500,
					light_color = "0.1 1 0.1",
					light_radius = 40,
					mass = 69420,
				},
				damage                  = {
					default = 800.1,
				},
				explosionGenerator      = "custom:implosion_beam_green",
				impulseBoost            = 0.7,
				impulseFactor           = 0.5,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.1 1 0.1",
				reloadtime              = 1/30,
				size                    = 5,
				sizeDecay               = 0.03,
				soundHit                = "explosion/ex_large4",
				soundHitVolume          = 3,
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 2750,
			},
			BLUE_SHOCKER = {
				name                    = "Blue Bolter",
				accuracy                = accuracy,
				areaOfEffect            = 320,
				avoidFeature            = false,
				avoidGround             = false,
				craterBoost             = 0.25,
				craterMult              = 0.5,
				cegTag                  = "drp_blue_trail",
				customParams = {
					script_reload = "6",
				},
				damage                  = {
					default        = 42000,
					mass = 69420,
				},
				edgeEffectiveness       = 0.75,
				explosionGenerator      = "custom:POWERPLANT_EXPLOSION",
				impulseBoost            = 0,
				impulseFactor           = 0,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				paralyzer               = true,
				paralyzeTime            = 25,
				range                   = 17000,
				rgbColor                = "0.1 0.1 1",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "weapon/more_lightning",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
			VIOLET_SLUGGER = {
				name                    = "Violent Violet",
				accuracy                = accuracy,
				areaOfEffect            = 720,
				craterAreaOfEffect      = 90,
				avoidFeature            = false,
				avoidGround             = false,
				craterBoost             = 0.25,
				craterMult              = 0.5,
				customparams = {
					timeslow_damagefactor = 10,
					nofriendlyfire = "needs hax",
					script_reload = "6",
					timeslow_overslow_frames = 2*30, --2 seconds before slow decays
					numprojectiles1 = 24,
					projectile1 = "raveparty_purple_fragment_fake",
					velspread1 = "3.82, 2, 3.82, _, 4, _",
					noairburst = "EI",
					onexplode = "RUOTSI",
					stats_damage = 450.1 + (200 * 24),
					shield_damage = 1, -- we want it to impact the shield to cause a lot of projectiles to spawn on it and damage it.
					stats_shield_damage = (200 * 24) + 450.1,
					mass = 69420,
				},
				damage                  = {
					default = 450.1,
				},
				edgeeffectiveness       = 0.8,
				explosionGenerator      = "custom:riotballplus2_purple",
				explosionScar           = false,
				explosionSpeed          = 6.5,
				impulseBoost            = 0.2,
				impulseFactor           = 0.1,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.7 0 0.7",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "weapon/aoe_aura2",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
			PURPLE_FRAGMENT = {
				name                    = "Shield Buster Chaff",
				areaOfEffect            = 120,
				avoidFeature            = true,
				cegTag                  = "beamweapon_muzzle_purple",
				commandFire             = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					timeslow_damagefactor = 1.5,
					timeslow_overslow_frames = 5*30, --5 seconds before slow decays
					nofriendlyfire = 1,
					light_camera_height = 3500,
					light_color = "0.5 0.0 0.5",
					light_radius = 220,
					shield_damage = 150,
					mass = 69420,
				},
				damage                  = {
					default = 200,
				},
				fireStarter             = 70,
				impulseBoost            = 0,
				impulseFactor           = 0.4,
				interceptedByShieldType = 2,
				explosionGenerator      = "custom:riotballplus2_purple_small",
				range                   = 2750,
				reloadtime              = 4.4,
				myGravity				= 0.09,
				size					= 4,
				rgbColor				= "0.5 0 0.5",
				soundHit				= "weapon/aoe_aura2",
				soundHitVolume          = 4,
				soundStart              = "weapon/cannon/funnel_fire",
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 450,
			},
			PURPLE_FRAGMENT_FAKE = {
				name                    = "Shield Buster Chaff",
				areaOfEffect            = 120,
				avoidFeature            = true,
				cegTag                  = "beamweapon_muzzle_purple",
				commandFire             = true,
				craterBoost             = 0,
				craterMult              = 0,
				customParams        = {
					light_camera_height = 3500,
					light_color = "0.5 0.0 0.5",
					light_radius = 220,
					numprojectiles1 = 1,
					projectile1 = "raveparty_purple_fragment",
					keepmomentum1 = 1,
					noairburst = "I belive I can fly...",
					timeddeploy = 20,
					shield_damage = 200,
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
				explosionGenerator      = "custom:riotballplus2_purple_small",
				range                   = 700,
				reloadtime              = 3,
				rgbColor				= "0.7 0 0.7",
				size					= 4,
				soundHit                = "nosound",
				soundHitVolume          = 0,
				soundStart              = "weapon/cannon/funnel_fire",
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 350,
			},
			FAKE_TIMEKEEPER = {
				name                    = "Metronome (Fake Weapon)",
				accuracy                = 750,
				avoidFeature            = false,
				avoidGround             = false,
				areaOfEffect            = 800,
				craterBoost             = 4,
				craterMult              = 10,
				customParams = {
					script_reload = "2",
					light_color = "1 0.1 0.1",
					light_radius = 40,
					light_camera_height = 1500,
				},
				damage                  = {
					default = 10000.1,
				},
				edgeeffectiveness       = 0.1,
				explosionGenerator      = "custom:nukebigland",
				impulseBoost            = 0,
				impulseFactor           = 2.3,
				interceptedByShieldType = 1,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "1 0.1 0.1",
				reloadtime              = 1/30,
				size                    = 15,
				sizeDecay               = 0.03,
				soundHit                = "weapon/missile/mininuke_hit",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = 2750,
			},
			RAINBOW = {
				name                    = "Ruinous Rainbow",
				accuracy                = accuracy,
				areaOfEffect            = 720,
				craterAreaOfEffect      = 90,
				avoidFeature            = false,
				avoidGround             = false,
				craterBoost             = 0.25,
				craterMult              = 0.5,
				cegtag					= "rainbowshot",
				customparams = {
					script_reload = "6",
					nofriendlyfire = 1,
					projectile1 = "raveparty_red_killer",
					projectile2 = "raveparty_orange_roaster",
					projectile3 = "raveparty_yellow_slammer",
					projectile4 = "raveparty_green_stamper",
					projectile5 = "raveparty_blue_shocker",
					projectile6 = "raveparty_violet_slugger",
					projectile7 = "raveparty_ruby",
					projectile8 = "raveparty_sapphire",
					keepmomentum1 = true,
					keepmomentum2 = true,
					keepmomentum3 = true,
					keepmomentum4 = true,
					keepmomentum5 = true,
					keepmomentum6 = true,
					keepmomentum7 = true,
					keepmomentum8 = true,
					velspread1 = "6, 6, 6",
					velspread2 = "6, 6, 6",
					velspread3 = "6, 6, 6",
					velspread4 = "6, 6, 6",
					velspread5 = "6, 6, 6",
					velspread6 = "6, 6, 6",
					velspread7 = "6, 6, 6",
					velspread8 = "6, 6, 6",
					spawndist = 2750,
					onexplode = "this is so we can actually damage shields",
					useheight = 1,
					stats_damage = 450.1 + (200 * 24),
					shield_damage = 1, -- we want it to impact the shield to cause a lot of projectiles to spawn on it and damage it.
					stats_shield_damage = (200 * 24) + 450.1,
					mass = 694200,
				},
				damage                  = {
					default = 450.1,
				},
				edgeeffectiveness       = 0.8,
				explosionGenerator      = "custom:NONE",
				explosionScar           = false,
				explosionSpeed          = 6.5,
				impulseBoost            = 0.2,
				impulseFactor           = 0.1,
				interceptedByShieldType = 0,
				myGravity               = 0.36,
				range                   = 17000,
				rgbColor                = "0.7 0 0.7",
				reloadtime              = 1/30,
				size                    = 0.01,
				sizeDecay               = 0.03,
				soundHit                = "weapon/aoe_aura2",
				soundStart              = "weapon/cannon/big_begrtha_gun_fire",
				stages                  = 30,
				turret                  = true,
				weaponType              = "Cannon",
				weaponVelocity          = velocity,
			},
		},
		featureDefs                   = {
			DEAD  = {
				blocking         = true,
				featureDead      = "HEAP",
				footprintX       = 3,
				footprintZ       = 3,
				object           = "raveparty_dead.s3o",
			},
			HEAP  = {
				blocking         = false,
				footprintX       = 3,
				footprintZ       = 3,
				object           = "debris4x4c.s3o",
			},
		},
	} 
}
