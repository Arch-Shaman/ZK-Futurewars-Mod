local name = "commweapon_buster_disrupt"
local weaponDef = {
	name                    = "Disruptor Buster Cannon",
	areaOfEffect            = 32,
	craterBoost             = 0,
	craterMult              = 0,
	cegTag                  = "hmg_trail_disrupt",
	customParams            = {
		gatherradius = "105",
        smoothradius = "70",
        smoothmult   = "0.4",
		light_color = "1.3 0.5 1.6",
		is_unit_weapon = 1,
		muzzleEffectFire = "custom:disruptor_cannon_muzzle",
		miscEffectFire = "custom:RIOT_SHELL_H",
		timeslow_damageFactor = 2,
		reaim_time = 1,
		use_okp = 1,
		okp_speedmult = 0.6,
		okp_radarmult = 1,
		okp_timeout = 40,
		okp_damage = 1120.1,
	},

	damage                  = {
		default = 1120.1,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = "custom:cyclops_hit",
	impulseBoost            = 0,
	impulseFactor           = 0.4,
	interceptedByShieldType = 1,
	range                   = 400,
	reloadtime              = 5,
	rgbColor				= "0.9 0.1 0.9",
	soundHit                = "weapon/cannon/heavy_disrupter_hit",
	soundStart              = "weapon/cannon/heavy_disrupter",
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 700,
	waterweapon				= true,
}

return name, weaponDef
