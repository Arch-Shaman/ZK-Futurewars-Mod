if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Engineer Overdrive",
		desc      = "Controls buildpower overdriving",
		author    = "Shaman / Hellaratsastaja212",
		date      = "11 Feb, 2023",
		license   = "CC-0",
		layer     = 10, -- preferably higher?
		enabled   = true  --  loaded by default?
	}
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local handled = IterableMap.New()
local config = {}
local unitRulesUnits = {}

local frequency = 2

-- speedups --
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitDefID = Spring.GetUnitDefID
local INLOS = {inlos = true}
local GetTeamHandicap = GG.GetTeamHandicap or function () return 1 end
local spGetUnitTeam = Spring.GetUnitTeam
local spGetFeatureResurrect = Spring.GetFeatureResurrect

local debugMode = false

for i = 1, #UnitDefs do
	local unitDef = UnitDefs[i]
	if unitDef.customParams.bp_overdrive then
		config[i] = {
			initialcharge = tonumber(unitDef.customParams.bp_overdrive_initialcharge),
			chargetime = tonumber(unitDef.customParams.bp_overdrive_chargedelay) or 30, -- in frames.
			overdrivebonus = tonumber(unitDef.customParams.bp_overdrive_bonus),
			chargetotal = tonumber(unitDef.customParams.bp_overdrive_totalcharge),
			basespeed = unitDef.buildSpeed,
			chargerate = tonumber(unitDef.customParams.bp_overdrive_chargerate) / (30 / frequency), -- per second -> per update
			allowcooloff = unitDef.customParams.bp_overdrive_allowcooloff ~= nil,
		}
		config[i].initialcharge = config[i].initialcharge or config[i].chargetotal
		config[i].spools = config[i].overdrivebonus < 0
		Spring.Echo("[EngieOverdrive]: Added unitDef " .. unitDef.name)
		for k, v in pairs(config[i]) do
			Spring.Echo(k .. ": " .. tostring(v))
		end
	end
end

local function UpdateUnitRules(unitID, data)
	if data == nil then
		return
	end
	local unitConfig = unitRulesUnits[unitRulesUnits] or config[data.unitDef]
	local chargeMax = unitConfig.chargetotal
	local currentCharge = data.charge / chargeMax
	local currentBonus = unitConfig.overdrivebonus
	currentBonus = currentBonus * currentCharge
	currentBonus = currentBonus + 1
	spSetUnitRulesParam(unitID, "bp_overdrive", currentCharge, INLOS)
	local handicap = GetTeamHandicap(spGetUnitTeam(unitID))
	--if spGetUnitRulesParam(unitID, "comm_level") then
		--currentBonus = currentBonus * unitRulesUnits[unitID].bpmult
	--end
	if debugMode then
		Spring.Echo("[EngieOverdrive] Update Unit: " .. unitID .. "\nCharge: " .. tostring(data.charge) .. " / " .. chargeMax .. "\nCurrent Bonus: " .. currentBonus .. "\nHandicap: " .. handicap)
	end
	currentBonus = currentBonus * handicap
	if debugMode then
		Spring.Echo("[EngieOverdrive] Setting unit bonus to " .. currentBonus)
	end
	spSetUnitRulesParam(unitID, "buildpower_mult", currentBonus, INLOS)
	GG.UpdateUnitAttributes(unitID)
end

local function UpdateWorker(unitID, workRate, unitConfig)
	local data = IterableMap.Get(handled, unitID)
	if data == nil then
		return
	end
	local baseSpeed = data.baseSpeed
	local newCharge = data.charge
	if debugMode then
		Spring.Echo("[EngieOverdrive] UpdateWorker: Speed Check: " .. workRate .. " / " .. baseSpeed)
	end
	if unitConfig.spools then
		if debugMode then
			Spring.Echo("[EngieOverdrive] UpdateWorker: Unit spools")
		end
		if data.charge < unitConfig.chargetotal then
			local theoreticalSpeed = 1 + ((1 - (data.charge / unitConfig.chargetotal)) * unitConfig.overdrivebonus) * baseSpeed
			if debugMode then 
				Spring.Echo("[EngieOverdrive] UpdateWorker: theoretical Speed: " .. theoreticalSpeed) 
			end
			newCharge = newCharge + ((workRate / theoreticalSpeed) * part)
			if newCharge > unitConfig.chargetotal then newCharge = unitConfig.chargetotal end
		else
			newCharge = data.charge -- stay at max.
		end
		data.replinishtimer = unitConfig.chargetime
	else
		local allowcooloff = unitConfig.allowcooloff
		if workRate > baseSpeed and data.charge > 0 then
			local chargeUse = (workRate - baseSpeed) / 30 -- convert from per second -> per frame
			newCharge = newCharge - chargeUse
			if debugMode then
				Spring.Echo("[EngieOverdrive] UpdateWorker: chargeUse this frame: " .. chargeUse)
			end
			if newCharge < 0 then newCharge = 0 end
			data.replinishtimer = unitConfig.chargetime
		elseif not allowcooloff and data.charge ~= 0 then
			data.replinishtimer = unitConfig.chargetime
		end
	end
	if debugMode then
		Spring.Echo("[EngieOverdrive] UpdateWorker: New charge: " .. tostring(newCharge))
	end
	if newCharge ~= data.charge then
		data.charge = newCharge
		UpdateUnitRules(unitID, data)
	end
end

function gadget:AllowUnitBuildStep(builderID, builderTeam, unitID, unitDefID, part)
	local unitConfig = unitRulesUnits[builderID] or config[spGetUnitDefID(builderID)]
	if unitConfig then
		local currentSpeed = (UnitDefs[unitDefID].metalCost * part) * 30 -- build speed in bp/second. Metal cost is the same in FW as buildtime.
		UpdateWorker(builderID, currentSpeed, unitConfig)
	end
	return true
end

function gadget:AllowFeatureBuildStep(builderID, builderTeam, featureID, featureDefID, part)
	local unitConfig = unitRulesUnits[builderID] or config[spGetUnitDefID(builderID)]
	if unitConfig then
		local currentSpeed
		if part < 0 then
			local _, _, _, _, _, reclaimTime = Spring.GetFeatureResources(featureID)
			currentSpeed = reclaimTime * (-1 * part) * 30 -- reclaim is negative, so we need to make it a positive to get the current build rate.
		else
			currentSpeed = UnitDefNames[spGetFeatureResurrect(featureID)].buildTime * part * 30
		end
		UpdateWorker(builderID, currentSpeed, unitConfig)
	end
	return true
end

function gadget:UnitCreated(unitID, unitDefID)
	if config[unitDefID] then
		local data = {unitDef = unitDefID, charge = config[unitDefID].initialcharge, replinishtimer = config[unitDefID].chargetime, reversebuilt = true, baseSpeed = config[unitDefID].basespeed}
		UpdateUnitRules(unitID, data)
		IterableMap.Add(handled, unitID, data)
	end
end

function GG.AddEngineeringOverdrive(unitID)
	local chargeMax = spGetUnitRulesParam(unitID, "comm_bpoverdrive_chargemax")
	local chargeRate = spGetUnitRulesParam(unitID, "comm_bpoverdrive_chargerate") / (30 / frequency)
	local baseSpeed = spGetUnitRulesParam(unitID, "basebuildpower_mult") * UnitDefs[unitDefID].buildSpeed
	local allowcooloff = spGetUnitRulesParam(unitID, "comm_bpoverdrive_allowcooloff") ~= nil
	local bonus = spGetUnitRulesParam(unitID, "comm_bpoverdrive_bonus")
	local chargeTime = spGetUnitRulesParam(unitID, "comm_bpoverdrive_chargetime")
	local spools = bonus < 0
	local initialcharge = (spools and 0) or chargeMax
	unitRulesUnits[unitID] = {chargetotal = chargeMax, overdrivebonus = bonus, spools = spools, chargetime = chargeTime, allowcooloff = allowcooloff, chargerate = chargeRate}
	local data = {unitDef = spGetUnitDefID(unitID), charge = initialcharge, replinishtimer = chargeTime, reversebuilt = false, baseSpeed = basespeed}
	IterableMap.Add(handled, unitID, data)
	UpdateUnitRules(unitID, data)
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if (config[unitDefID] or unitRulesUnits[unitID]) and GG.GetTeamHandicap(newTeam) ~= GG.GetTeamHandicap(oldTeam) then
		UpdateUnitRules(unitID, IterableMap.Get(handled, unitID))
	end
end

function gadget:UnitFinished(unitID, unitDefID)
	if config[unitDefID] or unitRulesUnits[unitID] then
		local data = IterableMap.Get(handled, unitID)
		data.reversebuilt = false
		UpdateUnitRules(unitID, data)
		IterableMap.Set(handled, unitID, data)
	end
end

function gadget:UnitReverseBuilt(unitID, unitDefID)
	if config[unitDefID] or unitRulesUnits[unitID] then
		local data = IterableMap.Get(handled, unitID)
		data.reversebuilt = true
		IterableMap.Set(handled, unitID, data)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID)
	if config[unitDefID] or unitRulesUnits[unitID] then
		IterableMap.Remove(handled, unitID)
	end
end

function gadget:GameFrame(f)
	if f%frequency == 0 then
		for unitID, data in IterableMap.Iterator(handled) do
			local unitConfig = unitRulesUnits[unitID] or config[data.unitDef]
			local totalCharge = unitConfig.chargetotal
			if data.charge ~= totalCharge and data.replinishtimer <= 0 then
				local newCharge
				local replinishrate = unitConfig.chargerate
				local slowState = spGetUnitRulesParam(unitID, "slowState") or 0
				if slowState > 0.5 then slowState = 0.5 end
				local totalChange = (1 - slowState) * frequency -- respect slow
				if config[data.unitDef].spools then
					newCharge = data.charge - (replinishrate * totalChange)
				else
					if not data.reversebuilt then
						newCharge = data.charge + (replinishrate * totalChange)
					else
						newCharge = data.charge
					end
				end
				if newCharge < 0 then newCharge = 0 end -- bound the charge amount between 0 and totalCharge.
				if newCharge > totalCharge then newCharge = totalCharge end
				if data.charge ~= newCharge then
					data.charge = newCharge
					UpdateUnitRules(unitID, data)
				end
			elseif data.replinishtimer > 0 then
				data.replinishtimer = data.replinishtimer - frequency
			end
		end
	end
end
