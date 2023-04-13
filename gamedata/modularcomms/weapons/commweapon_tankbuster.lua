local name = "commweapon_tankbuster"
local weaponDef = {
	name                    = "Tankbuster Cannon",
	areaOfEffect            = 32,
	craterBoost             = 0,
	craterMult              = 0,
	cegTag                  = "gauss_tag_l",
	customParams            = {
		gatherradius = "105",
        smoothradius = "70",
        smoothmult   = "0.4",
		is_unit_weapon = 1,
		muzzleEffectFire = "custom:HEAVY_CANNON_MUZZLE",
		miscEffectFire = "custom:RIOT_SHELL_H",
		armorpiercing  = 0.2,
		light_color = "1.4 0.8 0.3",
		reaim_time = 1,
		
		-- okp --
		use_okp = 1,
		okp_speedmult = 0.6,
		okp_radarmult = 1,
		okp_timeout = 40,
		okp_damage = 1400.01,
	},

	damage                  = {
		default = 1400.01,
	},

	edgeEffectiveness       = 0.5,
	explosionGenerator      = "custom:TESS",
	impulseBoost            = 0,
	impulseFactor           = 1.4,
	interceptedByShieldType = 1,
	range                   = 400,
	reloadtime              = 5,
	soundHit                = "weapon/cannon/megaarty_hit",
	soundStart              = "weapon/cannon/plasma_fire",
	soundstartvolume		= 8,
	turret                  = true,
	weaponType              = "Cannon",
	weaponVelocity          = 700,
	waterweapon				= true,
}

return name, weaponDef