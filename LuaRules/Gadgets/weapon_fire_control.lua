if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Fire Control Assistance",
		desc      = "Controls overdrivable weapons",
		author    = "Shaman",
		date      = "",
		license   = "CC-0",
		layer     = 0, -- needs to be later than OD.
		enabled   = true  --  loaded by default?
	}
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local units = IterableMap.New()
local config = {}
local debug = false

Spring.Echo("[FireControl] Version 1.0 by Shaman initializing. Scanning for Superweapons.")

for i = 1, #UnitDefs do
	local UnitDef = UnitDefs[i]
	if UnitDef.customParams.superweapon then
		local weapons = UnitDef.weapons
		local data = {}
		for i = 1, #weapons do
			local weaponDef = WeaponDefs[weapons[i].weaponDef]
			local reload = (tonumber(weaponDef.customParams.script_reload) or 10) * 30
			data[i] = {origReload = reload, progress = reload}
		end
		Spring.Echo("Found " .. i .. "(" .. UnitDef.name .. ")\n Weapons: " .. #weapons)
		config[i] = data
	end
end

local function WeaponFired(unitID, weaponNum)
	local data = IterableMap.Get(units, unitID)
	if debug then Spring.Echo("[FireControl] WeaponFired: " .. unitID .. "," .. weaponNum) end
	if data ~= nil then
		local firerate = Spring.GetUnitRulesParam(unitID,"superweapon_mult")
		if firerate < config[data.unitDef][weaponNum].origReload then
			data.weapons[weaponNum].progress = 0
			IterableMap.Set(units, unitID, data)
		end
	end
end

local function CanFireWeapon(unitID, weaponNum)
	local data = IterableMap.Get(units, unitID)
	if data == nil then
		return true
	end
	return data.weapons[weaponNum].progress >= data.weapons[weaponNum].origReload
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if config[unitDefID] then
		if debug then Spring.Echo("[FireControl] Added " .. unitID) end
		local data = {unitDef = unitDefID, weapons = config[unitDefID]}
		IterableMap.Add(units, unitID, data)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID)
	if config[unitDefID] then
		if IterableMap.InMap(units, unitID) then
			IterableMap.Remove(units, unitID)
		end
	end
end

GG.FireControl = {WeaponFired = WeaponFired, CanFireWeapon = CanFireWeapon}

function gadget:GameFrame(f)
	for unitID, data in IterableMap.Iterator(units) do
		local firespeed = Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0
		local slowMult = (Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1)
		local unpowered = Spring.GetUnitRulesParam(unitID, "lowpower") or 0
		local effectiveSpeed = firespeed * slowMult * (1 - unpowered)
		for i = 1, #data.weapons do
			if data.weapons[i].progress < data.weapons[i].origReload then
				data.weapons[i].progress = data.weapons[i].progress + effectiveSpeed
				local estimatedTimeToReload
				if data.weapons[i].progress < data.weapons[i].origReload then
					estimatedTimeToReload = f + math.ceil((data.weapons[i].origReload - data.weapons[i].progress)/effectiveSpeed)
				else
					estimatedTimeToReload = f
				end
				if debug then Spring.Echo("[FireControl] WeaponUpdated: " .. unitID .. "," .. i .. ": " .. data.weapons[i].progress .. "/" .. data.weapons[i].origReload) end
				Spring.SetUnitWeaponState(unitID, i, "reloadFrame", estimatedTimeToReload)
			end
		end
	end
end
