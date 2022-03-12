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
local recyclers = {}
local forcerecycle = {} -- used for commanders.
local config = {}
local min = math.min
local max = math.max
local ceil = math.ceil
local debug = false

local INLOS = {inlos = true}
local spGetGameFrame = Spring.GetGameFrame
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitWeaponState = Spring.SetUnitWeaponState
local spEcho = Spring.Echo
local spSetUnitRulesParam = Spring.SetUnitRulesParam

Spring.Echo("[FireControl] Version 1.0 by Shaman initializing. Scanning for Superweapons.")

for i = 1, #UnitDefs do
	local UnitDef = UnitDefs[i]
	if UnitDef.customParams.superweapon or UnitDef.customParams.needsfirecontrol then
		local weapons = UnitDef.weapons
		local data = {}
		local recycler = false
		spEcho("Found " .. i .. "(" .. UnitDef.name .. ")\n Weapons: " .. #weapons)
		for j = 1, #weapons do
			local weaponDef = WeaponDefs[weapons[j].weaponDef]
			local reload = (tonumber(weaponDef.customParams.script_reload) or 10) * 30
			data[j] = {origReload = reload, progress = reload, recycler = weaponDef.customParams.recycler ~= nil}
			if data[j].recycler then
				if debug then Spring.Echo(j .. " recycler!") end
				recycler = true
				data[j].currentbonus = 0
				data[j].framesuntilreduction = (tonumber(weaponDef.customParams.recycle_reductiontime) or 3.0) * 30
				data[j].reductionpenalty = -(tonumber(weaponDef.customParams.recycle_reduction) or 0.1)
				data[j].bonus = (tonumber(weaponDef.customParams.recycle_bonus) or 0.1)
				data[j].reductionframes = (tonumber(weaponDef.customParams.recycle_reductionframes) or 1) * 30
				data[j].maxbonus = (tonumber(weaponDef.customParams.recycle_maxbonus) or 900)
				data[j].lastfire = 0
			end
		end
		config[i] = data
		if recycler then
			recyclers[i] = true
		end
	end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local function WeaponFired(unitID, weaponNum)
	local data = IterableMap.Get(units, unitID)
	if debug then spEcho("[FireControl] WeaponFired: " .. unitID .. "," .. weaponNum) end
	if data ~= nil and data.weapons[weaponNum] then
		local firerate = spGetUnitRulesParam(unitID,"superweapon_mult") or 0
		if firerate < data.weapons[weaponNum].origReload and data.weapons[weaponNum].lastfire == nil then
			data.weapons[weaponNum].progress = 0
			if debug then spEcho("progress reset") end
		elseif data.weapons[weaponNum].lastfire then -- recycler.
			data.weapons[weaponNum].lastfire = spGetGameFrame() + (data.weapons[weaponNum].origReload / (1 + data.weapons[weaponNum].currentbonus))
			if firerate < data.weapons[weaponNum].origReload and data.weapons[weaponNum].currentbonus < data.weapons[weaponNum].maxbonus then
				data.weapons[weaponNum].currentbonus = min(data.weapons[weaponNum].currentbonus + data.weapons[weaponNum].bonus, data.weapons[weaponNum].maxbonus)
			end
			firerate = 1 + data.weapons[weaponNum].currentbonus
			if firerate < data.weapons[weaponNum].origReload then
				data.weapons[weaponNum].progress = 0
			end
			if debug then spEcho("new bonus: " .. data.weapons[weaponNum].currentbonus) end
		end
		IterableMap.Set(units, unitID, data)
	end
end

local function CanFireWeapon(unitID, weaponNum)
	local data = IterableMap.Get(units, unitID)
	if data == nil then
		if debug then spEcho("CanFireWeapon nil") end
		return false
	end
	if debug then spEcho("CanFireWeapon: " .. tostring(data.weapons[weaponNum].progress >= data.weapons[weaponNum].origReload and (spGetUnitRulesParam(unitID, "lowpower") or 0) == 0)) end
	return data.weapons[weaponNum].progress >= data.weapons[weaponNum].origReload and (spGetUnitRulesParam(unitID, "lowpower") or 0) == 0
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if config[unitDefID] then
		if debug then spEcho("[FireControl] Added " .. unitID) end
		local data = {unitDef = unitDefID}
		data.weapons = deepcopy(config[unitDefID])
		IterableMap.Add(units, unitID, data)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID)
	if IterableMap.InMap(units, unitID) then
		IterableMap.Remove(units, unitID)
	end
end

local function GetBonusFirerate(unitID, weaponNum)
	local data = IterableMap.Get(units, unitID)
	if data then
		return 1 + data.weapons[weaponNum].currentbonus
	else
		return 1
	end
end

GG.FireControl = {WeaponFired = WeaponFired, CanFireWeapon = CanFireWeapon, GetBonusFirerate = GetBonusFirerate}

function gadget:GameFrame(f)
	for unitID, data in IterableMap.Iterator(units) do
		local slowMult = (spGetUnitRulesParam(unitID,"baseSpeedMult") or 1)
		local unpowered = (spGetUnitRulesParam(unitID, "lowpower") or 0)
		local effectiveSpeed
		local firespeed
		if recyclers[data.unitDef] or forcerecycle[unitID] then
			firespeed = 1
			if debug then spEcho("Firespeed set to 1 due to recycler") end
		else
			firespeed = Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0
		end
		--if debug then spEcho("firespeed: " .. firespeed .. "\nslowMult : " .. slowMult) end
		effectiveSpeed = firespeed * slowMult * (1 - unpowered)
		if debug then spEcho("effectiveSpeed: " .. effectiveSpeed) end
		for i = 1, #data.weapons do
			if data.weapons[i].progress < data.weapons[i].origReload then
				local progressToAdd = effectiveSpeed
				if data.weapons[i].currentbonus then
					progressToAdd = progressToAdd * (1 + data.weapons[i].currentbonus)
					if debug then spEcho("Progress: " .. progressToAdd) end
				end
				data.weapons[i].progress = data.weapons[i].progress + progressToAdd
				local estimatedTimeToReload
				if data.weapons[i].progress < data.weapons[i].origReload then
					estimatedTimeToReload = f + ceil((data.weapons[i].origReload - data.weapons[i].progress)/effectiveSpeed)
				else
					estimatedTimeToReload = f
				end
				if debug then spEcho("[FireControl] WeaponUpdated: " .. unitID .. "," .. i .. ": " .. data.weapons[i].progress .. "/" .. data.weapons[i].origReload) end
				spSetUnitWeaponState(unitID, i, "reloadFrame", estimatedTimeToReload)
				spSetUnitRulesParam(unitID, i .. "_reload", min(data.weapons[i].progress / data.weapons[i].origReload, 1), INLOS)
			elseif data.weapons[i].currentbonus and data.weapons[i].currentbonus > 0 then
				local f2 = data.weapons[i].lastfire + data.weapons[i].framesuntilreduction
				if debug then spEcho("Reduction in " .. f2 - f) end
				if f2 - f < 0 then
					data.weapons[i].lastfire = data.weapons[i].reductionframes + f
					data.weapons[i].currentbonus = max((data.weapons[i].currentbonus * (1 + data.weapons[i].reductionpenalty)) + data.weapons[i].reductionpenalty, 0)
					if debug then spEcho("New firerate: " .. data.weapons[i].currentbonus) end
				end
			end
		end
		--IterableMap.Set(units, unitID, data)
	end
end
