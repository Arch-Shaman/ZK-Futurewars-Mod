if (not gadgetHandler:IsSyncedCode()) then
	return 
end

function gadget:GetInfo() 
	return {
		name    = "LOS Steal",
		desc    = "Steals your sensors! What the hack.",
		author  = "Shaman",
		date    = "2024.3.10",
		license = "CC-0",
		layer   = -2,
		enabled = true,
	} 
end

local IterableMap = Spring.Utilities.IterableMap
local imIterator = IterableMap.Iterator

local config = {}
local wantedDefs = {}
local handled = IterableMap.New() -- unitID = {{[allyTeamID] = {seconds, losUnit = unitID}}, count = 0}

local ALLIED = {allied = true}
local PUBLIC = {public = true}
local spSetUnitSensorRadius = Spring.SetUnitSensorRadius

local function SendError(str)
	Spring.Echo("[weapon_sensor_steal]: " .. str)
end

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	if cp.sensorsteal then
		local duration = tonumber(cp.sensorsteal)
		if duration then
			config[i] = duration
			wantedDefs[#wantedDefs + 1] = i
		end
	end
end

local function UpdateSensorForUnit(losUnitID, newLos, newRadar, airLos)
	spSetUnitSensorRadius(losUnitID, "los", newLos)
	spSetUnitSensorRadius(losUnitID, "radar", newRadar)
	spSetUnitSensorRadius(losUnitID, "sonar", newLos)
	if airLos then
		spSetUnitSensorRadius(losUnitID, "airLos", airLos)
	end
end

local function OnSensorChange(unitID, newLos, newRadar)
	local data = IterableMap.Get(handled, unitID)
	if data then
		for _, unitData in pairs(data) do
			local losUnitID = unitData.losUnit
			UpdateSensorForUnit(losUnitID, newLos, newRadar)
		end
	end
end

local function TryToCreateUnit(unitID, teamID)
	local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
	if (unitDef.radarRadius or 0) == 0 and (unitDef.losRadius or 0) == 0 then
		return
	end
	local x, y, z = Spring.GetUnitPosition(unitID)
	local losUnit = Spring.CreateUnit("los_superwep", x, y, z, 0, teamID)
	if losUnit then
		Spring.UnitAttach(unitID, losUnit, 1)
		Spring.SetUnitNoDraw(losUnit, true)
		Spring.SetUnitNoSelect(losUnit, true)
		Spring.SetUnitNoMinimap(losUnit, true)
		Spring.SetUnitLeaveTracks(losUnit, true)
		Spring.SetUnitRulesParam(losUnit, "untargetable", 1)
		--Spring.SetUnitCloak(losUnit, 4)
		Spring.SetUnitStealth(losUnit, true)
		Spring.SetUnitBlocking(losUnit, false, false, false)
		if unitDef.customParams.commtype or unitDef.customParams.dynamic_comm then
			UpdateSensorForUnit(losUnit, Spring.GetUnitRulesParam(unitID, "sightRangeOverride") or 0, Spring.GetUnitRulesParam(unitID, "radarRangeOverride") or 0, unitDef.airLosRadius or 0)
		else
			UpdateSensorForUnit(losUnit, unitDef.losRadius, unitDef.radarRadius or 0, unitDef.airLosRadius or 0)
		end
		return losUnit
	else
		SendError("Failed to create los unit for " .. teamID .. " on " .. unitID)
	end
end


local function CreateSensorUnit(unitID, teamID, duration)
	local teamsAllyTeam = select(6, Spring.GetTeamInfo(teamID))
	local data = IterableMap.Get(handled, unitID)
	if data then
		if data[teamsAllyTeam] and data[teamsAllyTeam].timer < duration then
			data[teamsAllyTeam].timer = duration
		elseif data[teamsAllyTeam] == nil then 
			local losUnitID = TryToCreateUnit(unitID, teamID)
			if losUnitID then
				data[teamsAllyTeam] = {timer = duration, losUnit = losUnitID}
			end
		end
	else
		local losUnit = TryToCreateUnit(unitID, teamID)
		if losUnit then
			local newTable = {[teamsAllyTeam] = {losUnit = losUnit, timer = duration}}
			IterableMap.Add(handled, unitID, newTable)
		end
	end
end

local function RemoveUnit(unitID)
	local data = IterableMap.Get(handled, unitID)
	if data then
		for allyTeam, unitData in pairs(data) do
			local losUnit = unitData.losUnit
			Spring.DestroyUnit(losUnit, true, true)
		end
		IterableMap.Remove(handled, unitID)
	end
end

local function UnitMorphed(unitID, newUnitID)
	local data = IterableMap.Get(handled, unitID)
	if data then
		for allyTeam, unitData in pairs(data) do
			IterableMap.ReplaceKey(handled, unitID, newUnitID)
			Spring.UnitAttach(newUnitID, unitData.losUnit, 1)
		end
	end
end

local function RemoveAllyTeam(unitID, allyTeamID, data)
	local losUnit = data[allyTeamID] and data[allyTeamID].losUnit
	if losUnit then
		Spring.DestroyUnit(losUnit, true, true)
		Spring.SetUnitRulesParam(unitID, "sensorsteal_" .. allyTeamID, nil)
		data[allyTeamID] = nil
		for k, v in pairs(data) do
			return -- don't remove! something still exists.
		end
		IterableMap.Remove(handled, unitID)
	else
		SendError("Attempt to remove ally team that does not exist from " .. unitID)
	end
end

function gadget:UnitDestroyed(unitID)
	local wasMorphed = Spring.GetUnitRulesParam(unitID, "wasMorphedTo")
	if wasMorphed then
		local data = IterableMap.Get(handled, unitID)
		if data then
			UnitMorphed(unitID, wasMorphed)
		end
	else
		RemoveUnit(unitID)
	end
end

function gadget:UnitPreDamaged_GetWantedWeaponDef()
	return wantedDefs
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	local weaponConfig = config[weaponDefID]
	if unitTeam and weaponConfig and attackerTeam and not Spring.AreTeamsAllied(unitTeam, attackerTeam) then
		CreateSensorUnit(unitID, attackerTeam, config[weaponDefID])
	end
	return 1, 1
end

function gadget:Initialize()
	GG.SensorHackUpdateUnitSensor = OnSensorChange
end

function gadget:GameFrame(f)
	if f%3 == 0 then
		for unitID, data in imIterator(handled) do
			local max = 0
			for allyTeam, unitData in pairs(data) do
				unitData.timer = unitData.timer - 0.1
				if unitData.timer > max then
					max = unitData.timer
				end
				if unitData.timer <= 0 then
					RemoveAllyTeam(unitID, allyTeam, data)
				else
					Spring.SetUnitRulesParam(unitID, "sensorsteal_" .. allyTeam, unitData.timer, PUBLIC)
				end
			end
			Spring.SetUnitRulesParam(unitID, "sensorsteal", max, ALLIED)
		end
	end
end
