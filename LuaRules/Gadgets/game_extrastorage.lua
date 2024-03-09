if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Extra Storage",
		desc      = "Tracks and controls extra comm storage",
		author    = "Shaman",
		date      = "3.12.2021",
		license   = "CC-0",
		layer     = -5,
		enabled   = true  --  loaded by default?
	}
end

local handledunits = {}
local debugMode = false

local spGetUnitDefID = Spring.GetUnitDefID
local spGetTeamResources = Spring.GetTeamResources
local spGetUnitTeam = Spring.GetUnitTeam
local spSetTeamResource = Spring.SetTeamResource
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local INLOS = {inlos = true}

local function AddTeamStorage(teamID, amount)
	if debugMode then
		Spring.Echo("[game_extrastorage.lua] AddTeamStorage", teamID, amount)
	end
	local _, es = spGetTeamResources(teamID, "energy")
	local _, ms = spGetTeamResources(teamID, "metal")
	es = es + amount
	ms = ms + amount
	spSetTeamResource(teamID, "es", es)
	spSetTeamResource(teamID, "ms", ms)
end

local function AddUnitStorage(unitID, amount)
	if debugMode then
		Spring.Echo("[game_extrastorage.lua] AddUnitStorage", unitID, amount)
	end
	local originalstorage = UnitDefs[spGetUnitDefID(unitID)].energyStorage or 0
	local extrastorage = spGetUnitRulesParam(unitID, "extra_storage") or 0
	local newamount = extrastorage + amount
	local unitteam = spGetUnitTeam(unitID)
	if newamount == 0 then
		if debugMode then
			Spring.Echo("[game_extrastorage.lua] AddTeamStorage: newamount was zero. removing")
		end
		spSetUnitRulesParam(unitID, "extra_storage", nil)
		AddTeamStorage(unitteam, amount)
		handledunits[unitID] = nil
		return
	end
	handledunits[unitID] = newamount
	spSetUnitRulesParam(unitID, "extra_storage", newamount, INLOS)
	AddTeamStorage(unitteam, amount)
end

local function SetUnitStorage(unitID, amount)
	local originalstorage = spGetUnitRulesParam(unitID, "commander_storage_override") or UnitDefs[spGetUnitDefID(unitID)].energyStorage or 0
	local extrastorage = spGetUnitRulesParam(unitID, "extra_storage") or 0
	if amount - (originalstorage + extrastorage) ~= 0 then
		AddUnitStorage(unitID, amount - (originalstorage + extrastorage))
	end
end

local function SetupCommanderStorage(unitID)
	local storageamount = spGetUnitRulesParam(unitID, "commander_storage_override") or UnitDefs[spGetUnitDefID(unitID)].energyStorage
	local oldstorage = UnitDefs[spGetUnitDefID(unitID)].energyStorage
	local mult = GG.GetTeamHandicap(spGetUnitTeam(unitID))
	storageamount = storageamount * mult
	local extrastorage = storageamount - oldstorage
	if debugMode then
		Spring.Echo("[game_extrastorage.lua] Setup Commander Storage", extrastorage, oldstorage)
	end
	--Spring.Echo("Setting up commander storage for " .. unitID .. " (" .. storageamount .. ")")
	if extrastorage >= 0 then
		AddUnitStorage(unitID, extrastorage)
	end
end

local function ResetUnitStorage(unitID)
	local extrastorage = spGetUnitRulesParam(unitID, "extra_storage") or 0
	if extrastorage > 0 then
		local unitteam = spGetUnitTeam(unitID)
		AddTeamStorage(unitteam, -extrastorage)
		spSetUnitRulesParam(unitID, "extra_storage", nil)
		handledunits[unitID] = nil
	end
end

local function SetupUnitStorage(unitID)
	local teamID = spGetUnitTeam(unitID)
	local storage = UnitDefs[spGetUnitDefID(unitID)].energyStorage or 0
	local mult = GG.GetTeamHandicap(teamID)
	if mult ~= 1 and storage > 0 then
		local wantedstorage = storage * mult
		SetUnitStorage(unitID, wantedstorage)
	end
end

GG.ResetUnitStorage = ResetUnitStorage
GG.AddUnitStorage = AddUnitStorage
GG.SetUnitStorage = SetUnitStorage
GG.SetupCommanderStorage = SetupCommanderStorage
GG.SetupUnitStorage = SetupUnitStorage

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if handledunits[unitID] then
		local storageamount = spGetUnitRulesParam(unitID, "extra_storage") or 0
		if debugMode then
			Spring.Echo("[game_extrastorage.lua] Unit Given: " .. tostring(storageamount))
		end
		if storageamount ~= 0 then
			if debugMode then
				Spring.Echo("[game_extrastorage.lua] Removing storage from old team")
			end
			AddTeamStorage(oldTeam, -storageamount)
		end
		spSetUnitRulesParam(unitID, "extra_storage", nil)
		if spGetUnitRulesParam(unitID, "commander_storage_override") then
			if debugMode then
				Spring.Echo("[game_extrastorage.lua] UnitGiven: Setup commander storage.")
			end
			SetupCommanderStorage(unitID)
		else
			SetupUnitStorage(unitID)
		end
	end
end

function gadget:UnitReverseBuilt(unitID, unitDefID, unitTeam)
	if handledunits[unitID] then
		ResetUnitStorage(unitID)
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	local storage = UnitDefs[unitDefID].energyStorage or 0
	if storage > 0 then
		if not (spGetUnitRulesParam(unitID, "comm_staticLevel") or spGetUnitRulesParam(unitID, "comm_level")) then
			SetupUnitStorage(unitID)
		end
	end
end
		

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	if handledunits[unitID] then
		AddTeamStorage(unitTeam, - handledunits[unitID])
	end
end
