function gadget:GetInfo()
	return {
		name      = "Overreclaim prevention",
		desc      = "Prevents excess from reclaim.",
		author    = "Shaman",
		date      = "9 Elokuu 2021",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

local SAVE_FILE = "Gadgets/unit_overreclaimprevention.lua"

if (not gadgetHandler:IsSyncedCode()) then
	function gadget:Save(zip)
		if not GG.SaveLoad then
			Spring.Log(gadget:GetInfo().name, LOG.ERROR, "Failed to access save/load API")
			return
		end
		
		-- basically everything here is regenerated either on unit recreation or when retreat check is done
		local data = {
			exceptionUnits = Spring.Utilities.MakeRealTable(SYNCED.exceptionUnits, "ORP")
		}
		GG.SaveLoad.WriteSaveData(zip, SAVE_FILE, data)
	end
	
	return
end

include("LuaRules/Configs/customcmds.h.lua")

local spGetTeamResources = Spring.GetTeamResources
local spEcho = Spring.Echo
local spGetUnitDefID = Spring.GetUnitDefID
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spGetFeatureResurrect = Spring.GetFeatureResurrect
local spFindUnitCmdDesc = Spring.FindUnitCmdDesc
local exceptionUnits = {} -- units that bypass ORP
local wantedUnits = {}


for i = 1, #UnitDefs do
	if UnitDefs[i].canReclaim and UnitDefs[i].buildSpeed > 0 then
		wantedUnits[i] = true
	end
end

local DefaultState = 1
local Tooltips = {
	'On',
	'On',
	'Off',
}

local CommandOrder = 123456
local CommandDesc = {
	id          = CMD_OVERRECLAIM,
	type        = CMDTYPE.ICON_MODE,
	name        = 'Overreclaim Prevention',
	action      = 'ORP',
	tooltip     = Tooltips[DefaultState + 1],
	params      = {0, 'Off', 'On'},
}

local function CheckStorage(teamID)
	local currentMetal, metalStorage = spGetTeamResources(teamID, "metal")
	metalStorage = (metalStorage - 10000)
	return currentMetal / metalStorage <= 0.98
end

function gadget:AllowFeatureBuildStep(builderID, builderTeam, featureID, featureDefID, part) -- part seems to be some sort of reclaim speed.
	local metalvalue = FeatureDefs[featureDefID].metal or 0
	--spEcho(builderID .. ", " .. builderTeam .. ", " .. featureID .. ", " .. featureDefID .. ", " .. tostring(part))
	--local reclaimspeed = part * metalvalue * -1
	--Spring.Echo("Reclaim seems to be " .. reclaimspeed)
	--spEcho("Current Storage: " .. currentMetal .. " / " .. metalStorage .. " -> " .. currentMetal + reclaimspeed .. " / " .. metalStorage)
	return part > 0 or metalvalue <= 0.1 or CheckStorage(builderTeam) or exceptionUnits[builderID] or spGetFeatureResurrect(featureID) == "staticmex"
end

local function Command(unitID, cmdParams)
	local cmdDescID = spFindUnitCmdDesc(unitID, CMD_OVERRECLAIM)
	if cmdDescID then
		local state = cmdParams[1]
		CommandDesc.params[1] = state
		exceptionUnits[unitID] = state == 1
		Spring.EditUnitCmdDesc(unitID, cmdDescID, {params = CommandDesc.params})
	end
end

function gadget:UnitDestroyed(unitID, unitDefID)
	local morphedFrom = Spring.GetUnitRulesParam(unitID, "wasMorphedTo")
	if morphedFrom and wantedUnits[unitDefID] then
		local state = exceptionUnits[unitID]
		exceptionUnits[morphedFrom] = state
		Command(unitID, {state and 1 or 0})
	end
	exceptionUnits[unitID] = nil
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if wantedUnits[unitDefID] then
		if Spring.GetAIInfo(unitTeam) then
			CommandDesc.params[1] = 1
			exceptionUnits[unitID] = true
		else
			local wanted = exceptionUnits[unitID] and 1 or 0
			CommandDesc.params[1] = wanted
		end
		spInsertUnitCmdDesc(unitID, CommandOrder, CommandDesc)
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if cmdID == CMD_OVERRECLAIM then
		Command(unitID, cmdParams)
		return false
	end
	return true
end

local function UpdateSaveReferences()
	_G.ORP = exceptionUnits
end

UpdateSaveReferences()

function GG.GetORPState(unitID)
	return exceptionUnits[unitID]
end

function GG.CheckORPForTeam(teamID)
	return CheckStorage(teamID)
end

function GG.SetORPState(unitID, state)
	if wantedUnits[spGetUnitDefID(unitID)] then
		exceptionUnits[unitID] = state
		Command(unitID, {state and 1 or 0})
	end
end

function gadget:Load(zip)
	if not (GG.SaveLoad and GG.SaveLoad.ReadFile) then
		Spring.Log(gadget:GetInfo().name, LOG.ERROR, "Failed to access save/load API")
		return
	end
	local loadData = GG.SaveLoad.ReadFile(zip, "ORP", SAVE_FILE)
	if not loadData then
		return
	end
	exceptionUnits = GG.SaveLoad.GetNewUnitIDKeys(loadData.exceptionUnits or {})
	UpdateSaveReferences()
end
