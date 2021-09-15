local name = "commexplosion_biggaboom_fragment_dummy"
local weaponDef = {
	name                    = [[Cluster Grenade Fragment]],
	accuracy                = 400,
	areaOfEffect            = 160,
	avoidFeature            = false,
	craterBoost             = 1,
	craterMult              = 2,
	cegTag                  = [[flamer]],
	customParams              = {
		--lups_heat_fx = [[firewalker]],
		numprojectiles1 = 1, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile1 = "commexplosion_biggaboom_fragment",
		--spreadradius = 8, -- used in clusters. OPTIONAL. Default: 100.
		clustervec1 = "derpderpderpderpderpderpderpderpderpderp", -- accepted values: randomx, randomy, randomz, randomxy, randomxz, randomyz, random. OPTIONAL. default: random.
		keepmomentum1 = 1,
		timeoutspawn = 0,
		noairburst = "I belive I can fly...", -- if true, this projectile will skip all airburst checks
		spawndist = 69420, -- at what distance should we spawn the projectile(s)? REQUIRED.
		timeddeploy = 20,
		commsubmunition = 1,
		--lups_heat_fx = [[firewalker]],
		light_camera_height = 2500,
		light_color = [[0.25 0.13 0.05]],
		light_radius = 500,
		shield_damage = 120,
	},
	damage                  = {
		default = 0,
	},
	model                   = [[diskball.s3o]],
	explosionGenerator      = [[custom:NONE]],
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
}

return name, weaponDef
-- NOTE: This weapon is a SECONDARY STAGE PROJECTILE. It is not intended for use as an actual weapon!
