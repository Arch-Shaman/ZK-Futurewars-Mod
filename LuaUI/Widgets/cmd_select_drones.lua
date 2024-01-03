function widget:GetInfo()
	return {
		name      = "Select Drones",
		desc      = "Isn't it fun to be coding while your parents are yelling outside?",
		author    = "Stuffphoton",
		date      = "2023-12-26",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
		handler   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local CMD_SELECT_DRONES = Spring.Utilities.CMD.SELECT_DRONES

local selectDronesCmdDesc = {
	id      = CMD_SELECT_DRONES,
	type    = CMDTYPE.ICON,
	name    = 'Select Drones',
	action  = 'selectdrones',
	tooltip = "Select this carrier's controllable drones",
	texture = "LuaUI/Images/Commands/Bold/selectdrones.png",
	params  = {}
}

local CMD_OPT_SHIFT = CMD.OPT_SHIFT
local CMD_OPT_CTRL = CMD.OPT_CTRL

local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetTeamUnitsByDefs = Spring.GetTeamUnitsByDefs
local spGetMyTeamID = Spring.GetMyTeamID

local carriers = {}
local carrierDefNames = {
	shipcarrier = {"dronecarrybomber"},
	shiplightcarrier = {"dronecarry"},
}
local carrierDefs = {}
for name, def in pairs(carrierDefNames) do
	local newDef = {}
	for _, drone in pairs(def) do
		local id = UnitDefNames[drone].id
		newDef[#newDef+1] = id
	end
	local id = UnitDefNames[name].id
	carrierDefs[id] = newDef
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:CommandNotify(cmdID, params, options)
	if cmdID ~= CMD_SELECT_DRONES then
		return false
	end
	
	local selectedUnits = Spring.GetSelectedUnits()
	local wantedDefIDs = {}
	local wantedCarriers = {}
	local toSelect = {}
	
	local toSelect = toSelect or {}
	for _, unitID in pairs(selectedUnits) do
		local defID = Spring.GetUnitDefID(unitID)
		if carrierDefs[defID] then
			wantedCarriers[unitID] = true
			for i=1,#carrierDefs[defID] do
				wantedDefIDs[carrierDefs[defID][i]] = true
			end
		end
	end

	for defID in pairs(wantedDefIDs) do
		local units = spGetTeamUnitsByDefs(spGetMyTeamID(), defID)
		for i=1, #units do
			if wantedCarriers[spGetUnitRulesParam(unitID, "parent_unit_id")] then
				toSelect[#toSelect+1] = unitID
			end
		end
	end
		
	
	if #toSelect > 0 then
		local alt, ctrl, meta, shift = Spring.GetModKeyState()
		Spring.SelectUnitArray(toSelect, shift)
	end
	
	return true
end

function widget:CommandsChanged()
	local selectedUnits = Spring.GetSelectedUnits()
	local selectedCarrier = false
	for _, unitID in pairs(selectedUnits) do
		if carrierDefs[Spring.GetUnitDefID(unitID)] then
			selectedCarrier = true
			break
		end
	end
	if selectedCarrier then
		local customCommands = widgetHandler.customCommands
		table.insert(customCommands, selectDronesCmdDesc)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
