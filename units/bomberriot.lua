unitDef = {
	unitname            = [[bomberriot]],
	name                = [[Firebrand]],
	description         = [[Napalm Bomber]],
	brakerate           = 0.4,
	buildCostMetal      = 320,
	builder             = false,
	buildPic            = [[bomberriot.png]],
	canFly              = true,
	canGuard            = true,
	canMove             = true,
	canPatrol           = true,
	canSubmerge         = false,
	category            = [[FIXEDWING]],
	collide             = false,
	collisionVolumeOffsets = [[0 0 -5]],
	collisionVolumeScales  = [[55 15 70]],
	collisionVolumeType    = [[box]],
	selectionVolumeOffsets = [[0 0 0]],
	selectionVolumeScales  = [[80 25 80]],
	selectionVolumeType    = [[cylY]],
	corpse              = [[DEAD]],
	cruiseAlt           = 250,

	customParams        = {
		modelradius    = [[10]],
		refuelturnradius = [[80]],
		requireammo    = [[1]],
	},

	explodeAs           = [[GUNSHIPEX]],
	floater             = true,
	footprintX          = 4,
	footprintZ          = 4,
	iconType            = [[bomberraider]],
	idleAutoHeal        = 5,
	idleTime            = 1800,
	maxAcc              = 0.5,
	maxDamage           = 1650,
	maxAileron          = 0.018,
	maxElevator         = 0.02,
	maxRudder           = 0.008,
	maxFuel             = 1000000,
	maxVelocity         = 9,
	noAutoFire          = false,
	noChaseCategory     = [[TERRAFORM FIXEDWING GUNSHIP SUB]],
	objectName          = [[firestorm.s3o]],
	script			  = [[bomberriot.lua]],
	selfDestructAs      = [[GUNSHIPEX]],

	sfxtypes            = {

		explosiongenerators = {
			[[custom:BEAMWEAPON_MUZZLE_RED]],
			[[custom:light_red]],
			[[custom:light_green]],
		},

	},
	sightDistance       = 660,
	turnRadius          = 200,
	workerTime          = 0,

	weapons             = {

		{
			def                = [[NAPALM]],
			badTargetCategory  = [[SWIM LAND SHIP HOVER GUNSHIP]],
			onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP]],
		},

	},


	weaponDefs          = {

		NAPALM_SECONDARY = {
			name 			= "Napalm Pellet",
			cegTag                  = [[flamer]],
			areaOfEffect            = 216,
			avoidFeature            = false,
			avoidFriendly           = false,
			collideFeature          = false,
			collideFriendly         = false,
			craterBoost             = 0,
			craterMult              = 0,
			--model                   = [[wep_b_fabby.s3o]],
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
				light_color = [[0.25 0.13 0.05]],
				light_radios = 460,
				lups_napalm_fx = 1,
				 
			},
			explosionGenerator      = [[custom:napalm_koda]],
			fireStarter             = 250,
			impulseBoost            = 0,
			impulseFactor           = 0.1,
			interceptedByShieldType = 1,
			soundHit                = [[weapon/burn_mixed]],
			--soundStart              = [[weapon/flak_hit2]],
			myGravity               = 0.2,
			rgbColor                = [[1 0.5 0.2]],
			weaponType              = [[Cannon]],
			weaponVelocity          = 320,
		},

		NAPALM = {
			name                    = [[Napalm Bomb]],
			areaOfEffect            = 216,
			avoidFeature            = false,
			avoidFriendly           = false,
			burst                   = 3,
			burstrate               = 0.4,
			collideFeature          = false,
			collideFriendly         = false,
			craterBoost             = 0,
			craterMult              = 0,
			customParams        	  = {
				numprojectiles1 = 6, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
				projectile1 = "bomberriot_napalm_secondary",
				--spreadradius1 = 4, -- used in clusters. OPTIONAL. Default: 100.
				clustervec1 = "randomxyz", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
				use2ddist = 0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
				spawndist = 170, -- at what distance should we spawn the projectile(s)? REQUIRED.
				timeoutspawn = 0, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
				vradius1 = "-5,0,-5,5,1,5", -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Default: 4.2
				groundimpact = 1, -- check the distance between ground and projectile? OPTIONAL.
				proxy = 0, -- check for nearby units?
				proxydist = 0, -- how far to check for units? Default: spawndist
				reaim_time = 60, -- Fast update not required (maybe dangerous)
				--setunitsonfire = "1", -- the bomb itself is a physical attack.
				--burntime = 300, -- so we commented these lines out. Basically the new cas phoenix drops a couple main bombs that split into the napalm components.
			},
		  
			damage                  = {
				default = 25*6,
			},

			edgeEffectiveness       = 0.7,
			explosionGenerator      = [[custom:STARFIRE]], --custom:napalm_phoenix
			fireStarter             = 250,
			fireTolerance		= 65536/2,
			impulseBoost            = 0,
			impulseFactor           = 0.1,
			interceptedByShieldType = 1,
			model                   = [[wep_b_fabby.s3o]],
			myGravity               = 0.4,
			noSelfDamage            = true,
			firetolerance			= 32000,
			tolerance				= 32000,
			reloadtime              = 1,
			soundHit                = [[weapon/flak_hit2]],
			soundStart              = [[weapon/bomb_drop]],
			--sprayangle              = 64000,
			weaponType              = [[AircraftBomb]],
		},
	},


	featureDefs         = {
		DEAD  = {
			blocking         = true,
			featureDead      = [[HEAP]],
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[firestorm_dead.s3o]],
		},
		HEAP  = {
			blocking         = false,
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[debris3x3c.s3o]],
		},
	},
}

return { bomberriot = unitDef }
