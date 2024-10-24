local name = "commweapon_areashield"
local weaponDef = {
	name                    = [[Area Shield]],

	customParams            = {
		slot = [[2]],
	},

	damage                  = {
		default = 10,
	},

	exteriorShield          = true,
	shieldAlpha             = 0.2,
	shieldBadColor          = [[1 0.1 0.1 1]],
	shieldGoodColor         = [[0.1 0.1 1 1]],
	shieldInterceptType     = 3,
	shieldPower             = 18000,
	shieldPowerRegen        = 180,
	shieldPowerRegenEnergy  = 12,
	shieldRadius            = 450,
	shieldRepulser          = false,
	smartShield             = true,
	visibleShield           = false,
	visibleShieldRepulse    = false,
	weaponType              = [[Shield]],
}

return name, weaponDef
