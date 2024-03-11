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

local IterableMap = Spring.Utilities.IterableMap
local units = IterableMap.New()
local recyclers = {}
local forcerecycle = {} -- used for commanders.
local config = {}
local min = math.min
local max = math.max
local ceil = math.ceil
local debugMode = false

local INLOS = {inlos = true}
local spGetGameFrame = Spring.GetGameFrame
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitWeaponState = Spring.SetUnitWeaponState
local spEcho = Spring.Echo
local spSetUnitRulesParam = Spring.SetUnitRulesParam

Spring.Echo("[FireControl] Version 1.2 by Shaman initializing. Scanning for Superweapons.")

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
				if debugMode then Spring.Echo(j .. " recycler!") end
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
	if debugMode then spEcho("[FireControl] WeaponFired: " .. unitID .. "," .. weaponNum) end
	if data ~= nil and data.commWeaponMap then
		weaponNum = data.commWeaponMap[weaponNum]
	end
	if data ~= nil and data.weapons[weaponNum] then
		local firerate = spGetUnitRulesParam(unitID,"superweapon_mult") or 0
		if firerate < data.weapons[weaponNum].origReload and data.weapons[weaponNum].lastfire == nil then
			data.weapons[weaponNum].progress = 0
			if debugMode then spEcho("progress reset") end
		elseif data.weapons[weaponNum].lastfire then -- recycler.
			data.weapons[weaponNum].lastfire = spGetGameFrame() + (data.weapons[weaponNum].origReload / (1 + data.weapons[weaponNum].currentbonus))
			if firerate < data.weapons[weaponNum].origReload and data.weapons[weaponNum].currentbonus < data.weapons[weaponNum].maxbonus then
				data.weapons[weaponNum].currentbonus = min(data.weapons[weaponNum].currentbonus + data.weapons[weaponNum].bonus, data.weapons[weaponNum].maxbonus)
			end
			firerate = 1 + data.weapons[weaponNum].currentbonus
			if firerate < data.weapons[weaponNum].origReload then
				data.weapons[weaponNum].progress = 0
			end
			if debugMode then spEcho("new bonus: " .. data.weapons[weaponNum].currentbonus) end
		end
		IterableMap.Set(units, unitID, data)
	end
end

local function CanFireWeapon(unitID, weaponNum)
	local data = IterableMap.Get(units, unitID)
	if data == nil then
		if debugMode then spEcho("CanFireWeapon nil") end
		return false
	end
	if data.commWeaponMap then
		weaponNum = data.commWeaponMap[weaponNum]
	end
	if debugMode then spEcho("CanFireWeapon: " .. tostring(data.weapons[weaponNum].progress >= data.weapons[weaponNum].origReload and (spGetUnitRulesParam(unitID, "lowpower") or 0) == 0)) end
	return data.weapons[weaponNum].progress >= data.weapons[weaponNum].origReload and (spGetUnitRulesParam(unitID, "lowpower") or 0) == 0
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if config[unitDefID] then
		if debugMode then spEcho("[FireControl] Added " .. unitID) end
		local data = {unitDef = unitDefID}
		data.weapons = deepcopy(config[unitDefID])
		IterableMap.Add(units, unitID, data)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID)
	if IterableMap.InMap(units, unitID) then
		IterableMap.Remove(units, unitID)
		forcerecycle[unitID] = nil
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

local function ClearBonusFirerate(unitID)
	local data = IterableMap.Get(units, unitID)
	if not data then
		return
	end
	for _, weapon in pairs(data.weapons) do
		weapon.currentbonus = 0
	end
end

local function ForceAddUnit(unitID, weaponNum, origReload, bonus, reductionframes, reduction, framesuntilreduction, maxbonus, currentbonus)
	if debugMode then
		spEcho("ForceAddUnit: " .. unitID .. ", " .. weaponNum)
	end
	local data = IterableMap.Get(units, unitID) or {}
	if data.weapons then
		data.commWeaponMap[weaponNum] = 2
		data.weapons[2] = {progress = origReload, recycler = true}
		data.weapons[2].currentbonus = currentbonus or 0
		data.weapons[2].framesuntilreduction = framesuntilreduction
		data.weapons[2].reductionpenalty = -reduction
		data.weapons[2].bonus = bonus
		data.weapons[2].reductionframes = reductionframes
		data.weapons[2].maxbonus = maxbonus
		data.weapons[2].lastfire = spGetGameFrame()
		data.weapons[2].origReload = origReload
		IterableMap.Set(units, unitID, data)
	else
		data = {weapons = {[1] = {progress = origReload, recycler = true}}, commWeaponMap = {[weaponNum] = 1}}
		data.weapons[1].currentbonus = currentbonus or 0
		data.weapons[1].framesuntilreduction = framesuntilreduction
		data.weapons[1].reductionpenalty = -reduction
		data.weapons[1].bonus = bonus
		data.weapons[1].reductionframes = reductionframes
		data.weapons[1].maxbonus = maxbonus
		data.weapons[1].lastfire = spGetGameFrame()
		data.weapons[1].origReload = origReload
		IterableMap.Add(units, unitID, data)
	end
	forcerecycle[unitID] = true
end

GG.FireControl = {WeaponFired = WeaponFired, CanFireWeapon = CanFireWeapon, GetBonusFirerate = GetBonusFirerate, ClearBonusFirerate = ClearBonusFirerate, ForceAddUnit = ForceAddUnit}

function gadget:GameFrame(f)
	for unitID, data in IterableMap.Iterator(units) do
		local slowMult = (spGetUnitRulesParam(unitID,"baseSpeedMult") or 1)
		local unpowered = (spGetUnitRulesParam(unitID, "lowpower") or 0)
		local effectiveSpeed
		local firespeed
		if recyclers[data.unitDef] or forcerecycle[unitID] then
			firespeed = 1
			if debugMode then spEcho("Firespeed set to 1 due to recycler") end
		else
			firespeed = Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0
		end
		--if debugMode then spEcho("firespeed: " .. firespeed .. "\nslowMult : " .. slowMult) end
		effectiveSpeed = firespeed * slowMult * (1 - unpowered)
		if debugMode then spEcho("effectiveSpeed: " .. effectiveSpeed) end
		for i = 1, #data.weapons do
			if data.weapons[i].progress < data.weapons[i].origReload then
				local progressToAdd = effectiveSpeed
				if data.weapons[i].currentbonus then
					progressToAdd = progressToAdd * (1 + data.weapons[i].currentbonus)
					if debugMode then spEcho("Progress: " .. progressToAdd) end
				end
				data.weapons[i].progress = data.weapons[i].progress + progressToAdd
				local estimatedTimeToReload
				if data.weapons[i].progress < data.weapons[i].origReload then
					estimatedTimeToReload = f + ceil((data.weapons[i].origReload - data.weapons[i].progress))
				else
					estimatedTimeToReload = f
				end
				if debugMode then spEcho("[FireControl] WeaponUpdated: " .. unitID .. "," .. i .. ": " .. data.weapons[i].progress .. "/" .. data.weapons[i].origReload) end
				spSetUnitWeaponState(unitID, i, "reloadFrame", estimatedTimeToReload)
				spSetUnitRulesParam(unitID, i .. "_reload", min(data.weapons[i].progress / data.weapons[i].origReload, 1), INLOS)
			elseif data.weapons[i].currentbonus and data.weapons[i].currentbonus > 0 then
				local f2 = data.weapons[i].lastfire + data.weapons[i].framesuntilreduction
				if debugMode then spEcho("Reduction in " .. f2 - f) end
				if f2 - f < 0 then
					data.weapons[i].lastfire = data.weapons[i].reductionframes + f
					data.weapons[i].currentbonus = max((data.weapons[i].currentbonus * (1 + data.weapons[i].reductionpenalty)) + data.weapons[i].reductionpenalty, 0)
					if debugMode then spEcho("New firerate: " .. data.weapons[i].currentbonus) end
				end
			end
			spSetUnitRulesParam(unitID, "firecontrol_mult_" .. i, data.weapons[i].currentbonus, INLOS)
		end
		--IterableMap.Set(units, unitID, data)
	end
end
