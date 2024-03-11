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
		enabled = false,
	} 
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

local config = {}
local wantedDefs = {}
local handled = IterableMap.New() -- unitID = {{[allyTeamID] = {seconds, losUnit = unitID}}, count = 0}

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

local function SendError(str)
	Spring.Echo("[weapon_sensor_steal] " .. str)
end

local function OnSensorChange(unitID)
	local data = IterableMap.Get
end

local function AddUnit(unitID)
	
end

local function RemoveUnit(unitID)
	local data = IterableMap.Get(handled, unitID)
	if data then
		for allyTeam, unitData in pairs(data) do
			local losUnit = unitData.losID
			Spring.DestroyUnit(losUnit, true, true)
		end
		IterableMap.Remove(handled, unitID)
	end
end

local function UnitMorphed(unitID)
	local data = IterableMap.Get(handled, unitID)
	if data then
		local newTable = {}
		for allyTeam, unitData in pairs(data) do
			newTable[allyTeam] = {timer = unitData.timer, losID = unitData.losID}
			Spring.UnitAttach(unitID, unitData.losID, 1)
		end
	end
end

local function RemoveAllyTeam(unitID, allyTeamID, data)
	local losUnit = data[allyTeamID] and data[allyTeamID].losID
	if losUnit then
		Spring.DestroyUnit(losUnit, true, true)
		data[allyTeamID] = nil
		for k, v in pairs(data) do
			return -- don't remove! something still exists.
		end
		if data.count == 0 then
			IterableMap.Remove(handled, unitID)
		end
	else
		SendError("Attempt to remove ally team that does not exist from " .. unitID)
	end
end

function gadget:UnitDestroyed(unitID)
	local wasMorphed = Spring.GetUnitRulesParam(unitID, "wasMorphedTo")
	if wasMorphed then
		local data = IterableMap.Get(handled, unitID)
		if data then
			IterableMap.Add(handled, unitID, data)
			IterableMap.Remove(handled, unitID)
		end
	else
		RemoveUnit(unitID)
	end
end

function gadget:UnitPreDamage_GetWantedDefs()
	return wantedDefs
end

function gadget:UnitPreDamage(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	
end
