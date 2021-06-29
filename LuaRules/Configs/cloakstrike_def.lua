-- reloadTime is in seconds

local StrikeWepDefs = {}

local StrikeWepDefNames = {
	cloakheavyraid = {
		persistance = 30,
		cloakRecharge = 2,    -- NYI
		maxRecharge = 60,     -- NYI
		attackDecharge = -1,  -- NYI apparently (None of this matters anyways because Persistence is a thing.)
		WeaponStats = {
			[1] = {
				cloakedWeaponStates = {}, 
				decloakedWeaponStates = {}, 
				cloakedWeaponDamages = {
					[0] = 855, 
					[1] = 855, 
					[2] = 855, 
					[3] = 855, 
					[4] = 855, 
					[5] = 855,
				}, 
				decloakedWeaponDamages = {
					[0] = 285, 
					[1] = 285, 
					[2] = 285, 
					[3] = 285, 
					[4] = 285, 
					[5] = 285,
				},
			}
		}, 
		cloakedRulesParam = {
			selfMoveSpeedChange = 1.25,
		}, 
		decloakedRulesParam = {
			selfMoveSpeedChange = 0.75,
		}, 
		updateAttributes = true,
	}
}

local defaultStates = {
	persistance = 30, 
	cloakRecharge = 2, 
	maxRecharge = 60, 
	attackDecharge = -1, 
	WeaponStats = {},
}
local defaultWeapon = {
	cloakedWeaponStates = {}, 
	decloakedWeaponStates = {}, 
	cloakedWeaponDamages = {
		[0] = 10000, 
		[1] = 10000, 
		[2] = 10000, 
		[3] = 10000, 
		[4] = 10000, 
		[5] = 10000,
	}, 
	decloakedWeaponDamages = {
		[0] = 10000, 
		[1] = 10000, 
		[2] = 10000, 
		[3] = 10000, 
		[4] = 10000, 
		[5] = 10000,
	},
}

local cpDefsCache = {}

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local cp = wd.customParams
	if cp.cloakstrike_amp then
		cpDefsCache[i] = {wd.damages[0], cp.cloakstrike_amp}
	end
end

for i=1, #UnitDefs do
	local ud = UnitDefs[i]
	local myStates = defaultStates
	local hasCSWep = false
	for n=1, #ud.weapons do
		local wdefid = ud.weapons[n].weaponDef
		if cpDefsCache[wdefid] then
			local defaultdmg = cpDefsCache[wdefid][1]
			local cloakeddmg = cpDefsCache[wdefid][2] * defaultdmg
			for m=0,5 do --changing defaultWeapon since there is no reason to create a new table
				defaultWeapon["cloakedWeaponDamages"][m] = cloakeddmg
				defaultWeapon["decloakedWeaponDamages"][m] = defaultdmg
			end
			myStates["WeaponStats"][n] = defaultWeapon
			hasCSWep = true
		end
	end
	if hasCSWep then
		StrikeWepDefNames[ud.name] = myStates
	end
end
for name, data in pairs(StrikeWepDefNames) do
	if UnitDefNames[name] then
		StrikeWepDefs[UnitDefNames[name].id] = data
	end
end

return StrikeWepDefs
