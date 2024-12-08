if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Battery Management",
		desc      = "Controls artemis battery.",
		author    = "Shaman",
		date      = "26.5.2022",
		license   = "CC-0",
		layer     = 10,  -- After OD, because battery needs it.
		enabled   = true  --  loaded by default?
	}
end

local debugMode = false

local IterableMap = Spring.Utilities.IterableMap

local handled = IterableMap.New()

local checkTime = 3
local wantedUnits = {}

local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitRulesParam = Spring.SetUnitRulesParam
--local spGetUnitHealth = Spring.GetUnitHealth
local spEcho = Spring.Echo
local min = math.min
local max = math.max
local INLOS = {inlos = true}
local forceUpdateUnits = {}

for i = 1, #UnitDefs do
	local cp = UnitDefs[i].customParams
	if cp.battery then
		local maxbat = tonumber(cp.battery)
		local gain = (tonumber(cp.batterygain) or 1)
		local startBattery = tonumber(cp.initialbattery) or 0
		gain = gain / (30 / checkTime)
		local costs = {}
		local checks = {}
		local scales = cp.superweapon ~= nil
		local wep = UnitDefs[i].weapons
		if wep and #wep > 0 then
			for i = 1, #wep do
				local wd = WeaponDefs[wep[i].weaponDef]
				if wd.customParams.batterydrain then
					costs[i] = tonumber(wd.customParams.batterydrain)
					checks[i] = tonumber(wd.customParams.batterychecklevel)
					if debugMode then spEcho("[BatteryManagement]: Cost of weapon " .. i .. ": " .. tostring(costs[i])) end
				end
			end
		end
		if maxbat then
			wantedUnits[i] = {maximum = maxbat, initialCharge = startBattery, gain = gain, batterycost = costs, scales = scales, checks = checks}
		end
	end
end

local function CanFire(unitID, weaponID)
	local data = IterableMap.Get(handled, unitID)
	if data then
		if debugMode then spEcho("CanFire", weaponID, data.costs[weaponID]) end
		if data.costs[weaponID] then
			local checkval = data.checks[weaponID] or data.costs[weaponID]
			return data.battery > checkval
		else
			return true -- doesn't cost.
		end
	else
		return true
	end
end

local function WeaponFired(unitID, weaponID)
	local data = IterableMap.Get(handled, unitID)
	if data == nil or data.costs[weaponID] == nil then
		return
	end
	data.battery = data.battery - data.costs[weaponID]
	if debugMode then
		spEcho("[BatteryManagement] " .. unitID .. " fired weapon " .. weaponID .. ": " .. tostring(data.battery) .. " / " .. tostring(data.maxbattery) .. " left.")
	end
	spSetUnitRulesParam(unitID, "battery", data.battery, INLOS)
end

local function IsBatteryRecharged(unitID)
	local data = IterableMap.Get(handled, unitID)
	return data == nil or data.battery / data.maxbattery >= 1
end

local function CanUseCharge(unitID, chargeamt)
	local data = IterableMap.Get(handled, unitID)
	if data == nil then
		return true
	end
	return data.battery >= chargeamt
end

local function RechargeBattery(unitID, amount)
	local data = IterableMap.Get(handled, unitID)
	if data == nil then
		return
	end
	data.battery = min(data.battery + amount, data.maxbattery)
	spSetUnitRulesParam(unitID, "battery", data.battery, INLOS)
	IterableMap.Set(handled, unitID, data)
end

local function HasBattery(unitID)
	return IterableMap.InMap(handled, unitID)
end

local function UseCharge(unitID, amount)
	local data = IterableMap.Get(handled, unitID)
	if data == nil then
		return 1
	end
	local newCharge = data.battery - amount
	local ret = 1
	if newCharge < 0 then
		local newAmount = data.battery
		data.battery = 0
		ret = data.battery / amount
	else
		data.battery = data.battery - amount
	end
	spSetUnitRulesParam(unitID, "battery", data.battery, INLOS)
	return ret
end

local function GetChargePercent(unitID)
	local data = IterableMap.Get(handled, unitID)
	return data and data.battery / data.maxbattery or 1
end

local function GetChargeLevel(unitID)
	local data = IterableMap.Get(handled, unitID)
	return data and data.battery
end

local function SetBatteryCosts(unitID, costs)
	local data = IterableMap.Get(handled, unitID)
	if data then
		if costs then data.costs = costs end
	end
end

local function SetBatteryChecks(unitID, checks)
	local data = IterableMap.Get(handled, unitID)
	if data then
		if checks then data.checks = checks end
	end
end

local function SetBatteryStats(unitID, charge, maxbattery, rechargerate, costs, checks)
	local data = IterableMap.Get(handled, unitID)
	if data then
		if charge then data.battery = charge end
		if rechargerate then data.gain = rechargerate end
		if maxbattery then data.maxbattery = maxbattery end
		if costs then data.costs = costs end
		if checks then data.checks = checks end
	else
		local data = {battery = charge, gain = rechargerate, maxbattery = maxbattery, costs = costs, scales = config.scales, checks = checks, reverseBuilt = false}
		IterableMap.Add(handled, unitID, data)
		forceUpdateUnits[unitID] = true
	end
end

function gadget:Initialize()
	GG.BatteryManagement = {SetBatteryCosts = SetBatteryCosts, SetBatteryChecks = SetBatteryChecks, SetBatteryStats = SetBatteryStats, CanFire = CanFire, GetChargeLevel = GetChargeLevel, GetChargePercent = GetChargePercent, CanUseCharge = CanUseCharge, WeaponFired = WeaponFired, IsBatteryRecharged = IsBatteryRecharged, UseCharge = UseCharge, RechargeBattery = RechargeBattery, HasBattery = HasBattery}
end

function gadget:UnitCreated(unitID, unitDefID)
	if wantedUnits[unitDefID] then
		local config = wantedUnits[unitDefID]
		IterableMap.Add(handled, unitID, {battery = config.initialCharge, gain = config.gain, maxbattery = config.maximum, costs = config.batterycost, scales = config.scales, checks = config.checks, reverseBuilt = false})
		spSetUnitRulesParam(unitID, "battery", config.initialCharge, INLOS)
	end
end

function gadget:UnitReverseBuilt(unitID, unitDefID, unitTeam)
	if wantedUnits[unitDefID] or forceUpdateUnits[unitID] then
		local data = IterableMap.Get(handled, unitID)
		data.reverseBuilt = true
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if wantedUnits[unitDefID] or forceUpdateUnits[unitID] then
		local data = IterableMap.Get(handled, unitID)
		data.reverseBuilt = false
	end
end

function gadget:UnitDestroyed(unitID, unitDefID)
	if wantedUnits[unitDefID] or forceUpdateUnits[unitID] then
		IterableMap.Remove(handled, unitID)
		forceUpdateUnits[unitID] = nil
	end
end

function gadget:GameFrame(f)
	if f%checkTime == 0 then
		for id, data in IterableMap.Iterator(handled) do
			local powered = (spGetUnitRulesParam(id, "lowpower") or 0) == 0
			--local _, _, _, _, bp = spGetUnitHealth(id)
			local lastbattery = data.battery
			local gain = data.gain
			if (not powered) or data.reverseBuilt then
				if data.battery > 0 then
					data.battery = max(data.battery - (gain * 2), 0)
				end
			elseif data.battery < data.maxbattery and gain > 0 then
				if data.scales then
					local power = spGetUnitRulesParam(id, "superweapon_mult") or 0
					gain = gain * power
				end
				data.battery = min(data.battery + gain, data.maxbattery)
			end
			if lastbattery ~= data.battery then
				spSetUnitRulesParam(id, "battery", data.battery, INLOS)
			end
		end
	end
end
