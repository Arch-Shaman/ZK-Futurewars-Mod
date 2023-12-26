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

local carriers = {}
local carrierDefIDs = {
	[UnitDefNames["shipcarrier"].id] = true,
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function GetDrones(unitID)
	local drones = {}
	local count = 0

	local count = spGetUnitRulesParam(unitID, "dronesControlled")
	
	for i=1,count do
		drones[i] = spGetUnitRulesParam(unitID, "droneList_"..i)
	end
	
	return drones
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:CommandNotify(cmdID, params, options)
	if cmdID ~= CMD_SELECT_DRONES then
		return false
	end
	
	local selectedUnits = Spring.GetSelectedUnits()
	
	local toSelect = toSelect or {}
	for _, unitID in pairs(selectedUnits) do
		if carrierDefIDs[Spring.GetUnitDefID(unitID)] then
			local drones = GetDrones(unitID)
			for i=1,#drones do
				toSelect[#toSelect + 1] = drones[i]
			end
		end
	end
	
	if #toSelect > 0 then
		local alt, ctrl, meta, shift = Spring.GetModKeyState()
		Spring.SelectUnitArray(toSelect, shift)
	end
	
	return true
end

-- add missile selection command
function widget:CommandsChanged()
	local selectedUnits = Spring.GetSelectedUnits()
	local selectedCarrier = false
	for _, unitID in pairs(selectedUnits) do
		Spring.Echo("[CSD]: Checking...")
		if carrierDefIDs[Spring.GetUnitDefID(unitID)] then
			selectedCarrier = true
			break
		end
	end
	if selectedCarrier then
		local customCommands = widgetHandler.customCommands
		table.insert(customCommands, selectDronesCmdDesc)
		Spring.Echo("[CSD]: Adding Command!")
	end
end

function widget:UnitCreated(unitID, unitDefID, unitTeam)
	if unitTeam == Spring.GetMyTeamID() and (carrierDefIDs[unitDefID]) then
		carriers[unitID] = true	--0
	end
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
	carriers[unitID] = nil
end

function widget:Initialize()
	for i,unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		local unitTeam = Spring.GetUnitTeam(unitID)
		widget:UnitCreated(unitID, unitDefID, unitTeam)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
