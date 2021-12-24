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
local config = {}
local debug = false
local lolmode = false

local spGetGameFrame = Spring.GetGameFrame
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitWeaponState = Spring.SetUnitWeaponState

Spring.Echo("[FireControl] Version 1.0 by Shaman initializing. Scanning for Superweapons.")

for i = 1, #UnitDefs do
	local UnitDef = UnitDefs[i]
	if UnitDef.customParams.superweapon or UnitDef.customParams.needsfirecontrol then
		local weapons = UnitDef.weapons
		local data = {}
		local recylcer = false
		for j = 1, #weapons do
			local weaponDef = WeaponDefs[weapons[j].weaponDef]
			local reload = (tonumber(weaponDef.customParams.script_reload) or 10) * 30
			data[j] = {origReload = reload, progress = reload, recycler = weaponDef.customParams.recycler ~= nil}
			if data[j].recycler then
				recycler = true
				data[j].currentbonus = 0
				data[j].framesuntilreduction = (tonumber(weaponDef.customParams.recycle_reductiontime) or 3.0) * 30
				data[j].reductionpenalty = -(tonumber(weaponDef.customParams.recycle_reduction) or 0.1)
				data[j].reduction = (tonumber(weaponDef.customParams.recycle_bonus) or 0.1)
				data[j].reductionframes = (tonumber(weaponDef.customParams.recycle_reductionframes) or 1) * 30
				data[j].maxbonus = (tonumber(weaponDef.customParams.recycle_maxbonus) or 900)
				data[j].lastfire = 0
			end
		end
		Spring.Echo("Found " .. i .. "(" .. UnitDef.name .. ")\n Weapons: " .. #weapons)
		config[i] = data
		if recycler then
			recyclers[i] = true
		end
	end
end



local function WeaponFired(unitID, weaponNum)
	local data = IterableMap.Get(units, unitID)
	if debug then Spring.Echo("[FireControl] WeaponFired: " .. unitID .. "," .. weaponNum) end
	if data ~= nil and data[weaponNum] then
		local firerate = spGetUnitRulesParam(unitID,"superweapon_mult") or 0
		if firerate < config[data.unitDef][weaponNum].origReload then
			data.weapons[weaponNum].progress = 0
		end
		if data[weaponNum].lastfire then -- recycler.
			data.weapons[weaponNum].progress = 0
			data[weaponNum].lastfire = spGetGameFrame()
			if firerate < config[data.unitDef][weaponNum].origReload and firerate < config[data.unitDef][weaponNum].maxbonus then
				data[weaponNum].currentbonus = data[weaponNum].currentbonus + data[weaponNum].reduction
			end
		end
		IterableMap.Set(units, unitID, data)
	end
end

local function CanFireWeapon(unitID, weaponNum)
	local data = IterableMap.Get(units, unitID)
	if data == nil then
		return true
	end
	return lolmode or data.weapons[weaponNum].progress >= data.weapons[weaponNum].origReload
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
		local slowMult = (spGetUnitRulesParam(unitID,"baseSpeedMult") or 1)
		local unpowered = (spGetUnitRulesParam(unitID, "lowpower") or 0)
		local effectiveSpeed
		local firespeed
		if recyclers[data.unitDefID] then
			firespeed = 1
		else
			firespeed = Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0
		end
		effectiveSpeed = firespeed * slowMult * (1 - unpowered)
		for i = 1, #data.weapons do
			if data.weapons[i].progress < data.weapons[i].origReload then
				local progressToAdd = effectiveSpeed
				if data.weapons[i].currentbonus then
					progressToAdd = progressToAdd * (1 + data.weapons[i].currentbonus)
				end
				data.weapons[i].progress = data.weapons[i].progress + effectiveSpeed
				local estimatedTimeToReload
				if data.weapons[i].progress < data.weapons[i].origReload then
					estimatedTimeToReload = f + math.ceil((data.weapons[i].origReload - data.weapons[i].progress)/effectiveSpeed)
				else
					estimatedTimeToReload = f
				end
				if debug then Spring.Echo("[FireControl] WeaponUpdated: " .. unitID .. "," .. i .. ": " .. data.weapons[i].progress .. "/" .. data.weapons[i].origReload) end
				spSetUnitWeaponState(unitID, i, "reloadFrame", estimatedTimeToReload)
			elseif data.weapons[i].currentbonus and data.weapons[i].currentbonus > 0 and f > data.weapons[i].lastfire + data.weapons[i].framesuntilreduction then
				data.weapons[i].lastfire = data.weapons[i].reductionframes + f
				data.weapons[i].currentbonus = math.max(data.weapons[i].currentbonus + data.weapons[i].reductionpenalty, 0)
			end
		end
	end
end
