if (not gadgetHandler:IsSyncedCode()) then
	return 
end

function gadget:GetInfo() 
	return {
		name    = "Reveal Unit Framework",
		desc    = "Reveals units.",
		author  = "Shaman",
		date    = "2 Febuary, 2024",
		license = "CC-0",
		layer   = -2,
		enabled = true,
	} 
end

local IterableMap = Spring.Utilities.IterableMap
local handled = IterableMap.New()

local spSetUnitLosMask = Spring.SetUnitLosMask
local spSetUnitLosState = Spring.SetUnitLosState
local PUBLIC = {public = true}
local ALLIED = {allied = true}

local doOwnersKnowTagState = true
local config = {}
local wantedDefs = {}
local hz = 5
local frameNum = 30 / hz
local reduction = 1 / frameNum

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	if cp.sensortag then
		config[i] = tonumber(cp.sensortag)
		wantedDefs[#wantedDefs + 1] = i
	end
end

local function AddUnit(unitID, allyTeamID, timer)
	if timer == nil then return end
	spSetUnitLosMask(unitID, allyTeamID, 15) -- see: https://github.com/ZeroK-RTS/Zero-K/blob/master/LuaRules/Gadgets/unit_show_shooter.lua
	spSetUnitLosState(unitID, allyTeamID, 15)
	local data = IterableMap.Get(handled, unitID)
	if data then
		local currentTimer = data[allyTeamID]
		if timer > currentTimer then
			data[allyTeamID] = timer
		end
	else
		data = {[allyTeamID] = timer}
		IterableMap.Add(handled, unitID, data)
	end
end

local function IsUnitHandled(unitID, allyTeam)
	local data = IterableMap.Get(handled, unitID)
	if data then
		return data[allyTeam] ~= nil
	else
		return false
	end
end

local function CheckUnit(unitID, data)
	local count = 0
	local max = 0
	for allyTeam, timer in pairs(data) do
		count = count + 1
		timer = timer - reduction
		data[allyTeam] = timer -- force update?
		if timer > max then max = timer end
		if timer <= 0 then
			Spring.SetUnitRulesParam(unitID, "sensortag_" .. allyTeam, nil, PUBLIC)
			Spring.SetUnitRulesParam(unitID, "sensortag", nil, ALLIED)
			if not GG.IsUnitRevealedArtillery(unitID, allyTeam) then
				spSetUnitLosMask(unitID, allyTeam, 0)
				spSetUnitLosState(unitID, allyTeam, 0)
			end
			count = count - 1
			data[allyTeam] = nil
		else
			Spring.SetUnitRulesParam(unitID, "sensortag_" .. allyTeam, timer, PUBLIC) -- unfortunately with widgets you can get this information
			Spring.SetUnitRulesParam(unitID, "sensortag", max, ALLIED)
		end
	end
	if doOwnersKnowTagState then -- so owners should know about it anyways.
		if max == 0 then
			Spring.SetUnitRulesParam(unitID, "sensortag", nil, ALLIED)
		else
			Spring.SetUnitRulesParam(unitID, "sensortag", max, ALLIED)
		end
	end
	if count == 0 then
		IterableMap.Remove(handled, unitID)
	end
end

local function GetAllyTeamFromTeam(teamID)
	if teamID then
		local _, _, _, _, _, allyTeam = Spring.GetTeamInfo(teamID)
		return allyTeam
	else
		return nil
	end
end

function gadget:GameFrame(f)
	if f%frameNum == 0 then
		for unitID, data in IterableMap.Iterator(handled) do
			CheckUnit(unitID, data)
		end
	end
end

function gadget:Initialize()
	GG.IsUnitBeingRevealedBySensorTag = IsUnitHandled
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	local duration = config[weaponDefID] or 0
	local allyTeam = GetAllyTeamFromTeam(attackerTeam)
	if duration == 0 or allyTeam == nil then
		return
	end
	AddUnit(unitID, allyTeam, duration)
	return damage, 1
end

function gadget:UnitPreDamaged_GetWantedWeaponDef() -- only do certain weapons.
	return wantedDefs
end

function gadget:UnitDestroyed(unitID)
	IterableMap.Remove(handled, unitID)
end
