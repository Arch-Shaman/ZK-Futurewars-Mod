-- reloadTime is in seconds

local StrikeWepDefs = {}

local StrikeWepDefNames = {

}
--[[	cloakheavyraid = {
		persistance = 30, cloakRecharge = 2, maxRecharge = 60, attackDecharge = -1, WeaponStats = {[1] = {cloakedWeaponStates = {}, decloakedWeaponStates = {}, cloakedWeaponDamages = {[0] = 10000, [1] = 10000, [2] = 10000, [3] = 10000, [4] = 10000, [5] = 10000}, decloakedWeaponDamages = {[0] = 10000, [1] = 10000, [2] = 10000, [3] = 10000, [4] = 10000, [5] = 10000},}},
	},]]--
local defaultStates = {
		persistance = 30, cloakRecharge = 2, maxRecharge = 60, attackDecharge = -1, WeaponStats = {},
}
local defaultWeapon = {cloakedWeaponStates = {}, decloakedWeaponStates = {}, cloakedWeaponDamages = {[0] = 10000, [1] = 10000, [2] = 10000, [3] = 10000, [4] = 10000, [5] = 10000}, decloakedWeaponDamages = {[0] = 10000, [1] = 10000, [2] = 10000, [3] = 10000, [4] = 10000, [5] = 10000},}

local cpDefsCache = {}
local function printFullTable(printValue, filler)
	local spEcho = Spring.Echo
	if not filler then
		spEcho("TABLE:")
		filler = "\t"
	end
	for key, value in pairs(printValue) do
		if type(value) == "table" then
			spEcho(filler .. "[ " .. key .. " ] = {")
			printFullTable(value, (filler .. "\t"))
			spEcho(filler .. "}")
		else
		spEcho(filler .. "[ " .. key .. " ] = " .. (value or "nil"))
		end
	end
end

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
