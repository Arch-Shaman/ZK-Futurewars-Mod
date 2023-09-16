local version = "v1.003"
function widget:GetInfo()
  return {
    name      = "Showeco and Grid Drawer",
    desc      = "Register an action called Showeco & draw overdrive overlay.", --"acts like F4",
    author    = "xponen, ashdnazg, Shaman",
    date      = "July 19 2013",
    license   = "GNU GPL, v2 or later",
    layer     = 0, --only layer > -4 works because it seems to be blocked by something.
    enabled   = true,  --  loaded by default?
    handler   = true,
  }
end

local pylon = {}

local spGetMapDrawMode = Spring.GetMapDrawMode
local spSendCommands   = Spring.SendCommands

local function ToggleShoweco()
	WG.showeco = not WG.showeco

	if (not WG.metalSpots and (spGetMapDrawMode() == "metal") ~= WG.showeco) then
		spSendCommands("showmetalmap")
	end
end

WG.ToggleShoweco = ToggleShoweco

--------------------------------------------------------------------------------------
--Grid drawing. Copied and trimmed from unit_mex_overdrive.lua gadget (by licho & googlefrog)
VFS.Include("LuaRules/Configs/constants.lua", nil, VFS.ZIP_FIRST)
VFS.Include("LuaRules/Utilities/glVolumes.lua") --have to import this incase it fail to load before this widget

local spGetUnitDefID       = Spring.GetUnitDefID
local spGetUnitPosition    = Spring.GetUnitPosition
local spGetActiveCommand   = Spring.GetActiveCommand
local spTraceScreenRay     = Spring.TraceScreenRay
local spGetMouseState      = Spring.GetMouseState
local spAreTeamsAllied     = Spring.AreTeamsAllied
local spGetMyTeamID        = Spring.GetMyTeamID
local spGetUnitPosition    = Spring.GetUnitPosition
local spValidUnitID        = Spring.ValidUnitID
local spGetUnitRulesParam  = Spring.GetUnitRulesParam
local spGetSpectatingState = Spring.GetSpectatingState
local spGetBuildFacing     = Spring.GetBuildFacing
local spPos2BuildPos       = Spring.Pos2BuildPos

local glVertex        = gl.Vertex
local glCallList      = gl.CallList
local glColor         = gl.Color
local glCreateList    = gl.CreateList
local tableInsert     = table.insert

--// gl const

local pylons = {count = 0, data = {}} -- Isn't this just an iterable map?
local pylonByID = {}
local currentSelection = false
local playerIsPlacingPylon = false
local playerAllyTeam

local pylonDefs = {}
local isBuilder = {}
local floatOnWater = {}

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local queuedPylons = IterableMap.New() -- {unitID = {[1] = {x, z, def} . . .}

for i=1,#UnitDefs do
	local udef = UnitDefs[i]
	local range = tonumber(udef.customParams.pylonrange)
	if (range and range > 0) then
		pylonDefs[i] = range
	end
	if udef.isBuilder then
		isBuilder[i] = true
	end
	if udef.floatOnWater then
		floatOnWater[i] = true
	end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Utilities

local drawList = 0
local disabledDrawList = 0
local drawQueueList = 0
local drawAllQueuedList = 0
local lastDrawnFrame = 0
local lastFrame = 2
local highlightQueue = false
local alwaysHighlight = false
local playerHasBuilderSelected = false
local currentCommand = 0
local playerTeamID = 0

local function ForceRedraw()
	lastDrawnFrame = 0
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Menu Options

local drawAlpha = 0.2
WG.showeco_always_mexes = true -- No OnChange when not changed from the default.

local drawGroundCircle
local showAllies = false

options_path = 'Settings/Interface/Economy Overlay'
options_order = {'start_with_showeco', 'always_show_mexes', 'mergeCircles', 'drawQueued', 'show_allies'}


local queuedColor = { 0.9,0.8,0.75, drawAlpha}
local disabledColor = { 0.9,0.8,0.75, drawAlpha}
local placementColor = { 0.6, 0.7, 0.5, drawAlpha} -- drawAlpha on purpose!

local GetGridColor = VFS.Include("LuaUI/Headers/overdrive.lua")

local function QueueList()
	if currentSelection then
		glColor(disabledColor)
		for i = 1, #currentSelection do
			local unitID = currentSelection[i]
			local data = IterableMap.Get(queuedPylons, unitID)
			if data then
				for i = 1, #data do
					local radius = data[i].range
					drawGroundCircle(data[i].x, data[i].z, radius)
				end
			end
		end
	end
	glColor(1,1,1,1)
	gl.Clear(GL.STENCIL_BUFFER_BIT, 0)
end

local function UpdateQueueList()
	gl.DeleteList(drawQueueList or 0)
	drawQueueList = gl.CreateList(QueueList)
end

local function AllQueue()
	glColor(queuedColor)
	for unitID, data in IterableMap.Iterator(queuedPylons) do
		if showAllies or Spring.GetUnitTeam(unitID) == playerTeamID then
			--Spring.Echo("Make list volume: " .. unitID .. "data: " .. tostring(data))
			for i = 1, #data do
				--Spring.Echo(i .. ":" .. tostring(data[i].x) .. ", " .. tostring(data[i].z) .. ", " .. tostring(data[i].range) .. ", " .. tostring(data[i].team))
				drawGroundCircle(data[i].x, data[i].z, data[i].range)
			end
		end
	end
	glColor(1, 1, 1, 1)
	gl.Clear(GL.STENCIL_BUFFER_BIT, 0)
end

local function UpdateAllQueuesList()
	gl.DeleteList(drawAllQueuedList or 0)
	drawAllQueuedList = gl.CreateList(AllQueue)
	UpdateQueueList()
end

options = {
	start_with_showeco = {
		name = "Start with economy overlay",
		desc = "Game starts with Economy Overlay enabled",
		type = 'bool',
		value = true,
		noHotkey = true,
		OnChange = function(self)
			if (self.value) then
				WG.showeco = self.value
			end
		end,
	},
	always_show_mexes = {
		name = "Always show Mexes",
		desc = "Show metal extractors even when the full economy overlay is not enabled.",
		type = 'bool',
		value = true,
		OnChange = function(self)
			WG.showeco_always_mexes = self.value
		end,
	},
	mergeCircles = {
		name = "Draw merged grid circles",
		desc = "Merge overlapping grid circle visualisation. Does not work on older hardware and should automatically disable.",
		type = 'bool',
		value = true,
		OnChange = function(self)
			drawGroundCircle = self.value and gl.Utilities.DrawMergedGroundCircle or gl.Utilities.DrawGroundCircle
			lastDrawnFrame = 0
		end,
	},
	drawQueued = {
		name = "Always Draw Queued Grid",
		desc = "When enabled, always draw grid in queue, otherwise, only draw it when placing new grid units down.",
		type = 'bool',
		value = false,
		OnChange = function(self) 
			alwaysHighlight = self.value 
		end,
	},
	show_allies = {
		name = "Draw allied queued grid",
		desc = "Shows the queued grid of allied queued units.",
		type = 'bool',
		value = true,
		OnChange = function(self)
			showAllies = self.value
			UpdateAllQueuesList()
		end,
	},
}

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Unit Handling

local function RemoveFromOrderedTable(tab, num)
	local table_length = #tab
	if num == table_length then
		tab[num] = nil
	else
		local entry = tab[#tab]
		tab[num] = entry
		tab[table_length] = nil
	end
end

local function ShiftFromTable(tab, num)
	local table_length = #tab
	if table_length == num then
		tab[num] = nil
	else
		for i = num + 1, table_length do
			tab[i - 1] = tab[i]
		end
		tab[table_length] = nil
	end
end


local function addUnit(unitID, unitDefID, unitTeam)
	if pylonDefs[unitDefID] and not pylonByID[unitID] then
		local spec, fullview = spGetSpectatingState()
		spec = spec or fullview
		if spec or spAreTeamsAllied(unitTeam, spGetMyTeamID()) then
			local x,y,z = spGetUnitPosition(unitID)
			pylons.count = pylons.count + 1
			pylons.data[pylons.count] = {unitID = unitID, x = x, y = y, z = z, range = pylonDefs[unitDefID]}
			pylonByID[unitID] = pylons.count
		end
	end
end

local function removeUnit(unitID, unitDefID, unitTeam)
	pylons.data[pylonByID[unitID]] = pylons.data[pylons.count]
	pylonByID[pylons.data[pylons.count].unitID] = pylonByID[unitID]
	pylons.data[pylons.count] = nil
	pylons.count = pylons.count - 1
	pylonByID[unitID] = nil
end

function widget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	addUnit(unitID, unitDefID, unitTeam)
	local data = IterableMap.Get(queuedPylons, builderID)
	if data and data[1] and data[1].def == unitDefID then -- we're starting construction on the current cmd.
		ShiftFromTable(data, 1)
		UpdateAllQueuesList()
	end
	if isBuilder[unitDefID] then
		IterableMap.Add(queuedPylons, unitID, {})
	end
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if pylonByID[unitID] then
		removeUnit(unitID, unitDefID, unitTeam)
	end
	if isBuilder[unitDefID] then
		IterableMap.Remove(queuedPylons, unitID)
	end
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
	if isBuilder[unitDefID] then
		IterableMap.Add(queuedPylons, unitID, {})
	end
end

function widget:UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	addUnit(unitID, unitDefID, unitTeam)
	if IterableMap.InMap(queuedPylons, unitID) then
		UpdateAllQueuesList()
	end
end

function widget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if pylonByID[unitID] then
		removeUnit(unitID, unitDefID, unitTeam)
	end
end

function widget:UnitUnloaded(unitID, unitDefID, unitTeam)
	addUnit(unitID, unitDefID, unitTeam)
end

function widget:UnitCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOpts, cmdTag)
	if isBuilder[unitDefID] then
		local data = IterableMap.Get(queuedPylons, unitID)
		if data == nil then -- for some reason we don't have this builder on record!
			data = {}
			IterableMap.Set(queuedPylons, unitID, data) -- should be fine?
		end
		if cmdID ~= 1 then
			if (not (cmdOpts.shift or cmdOpts.meta) or cmdID == CMD.STOP) and #data > 0 then
				data = {}
				--Spring.Echo("[Ecoview] Queue cleared.")
				IterableMap.Set(queuedPylons, unitID, data)
				UpdateAllQueuesList()
			end
			if cmdID < 0 then
				local buildDef = -cmdID -- turn it positive. build orders are negative.
				if pylonDefs[buildDef] then
					data[#data + 1] = {x = cmdParams[1], y = cmdParams[2], z = cmdParams[3], range = pylonDefs[buildDef], def = buildDef, facing = cmdParams[4]}
					--Spring.Echo("[Ecoview] Added new " .. buildDef .. " for " .. unitID)
					--Spring.MarkerAddPoint(cmdParams[1], cmdParams[2], cmdParams[3], buildDef, true)
					UpdateAllQueuesList()
				end
			end
		elseif cmdParams[2] and cmdParams[2] < 0 then
			buildDef = -cmdParams[2]
			tableInsert(data, 1, {x = cmdParams[4], y = cmdParams[5], z = cmdParams[6], range = pylonDefs[buildDef], def = buildDef, facing = cmdParams[7]})
			--Spring.Echo("[Ecoview] Added new " .. buildDef .. " for " .. unitID .. ", Team: " .. tostring(unitTeam))
			--Spring.MarkerAddPoint(cmdParams[4], cmdParams[5], cmdParams[6], buildDef, true)
			UpdateAllQueuesList()
		end
	end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Drawing

local function AllyTeamChanged()
	pylons = {count = 0, data = {}}
	pylonByID = {}
	for unitID, _ in IterableMap.Iterator(queuedPylons) do
		IterableMap.Remove(queuedPylons, unitID)
	end
	local teamList = Spring.GetTeamList(playerAllyTeam)
	for i = 1, #teamList do
		local units = Spring.GetTeamUnits(teamList[i])
		for j = 1, #units do
			local unitID = units[j]
			local unitDefID = spGetUnitDefID(unitID)
			local unitTeam = Spring.GetUnitTeam(unitID)
			widget:UnitCreated(unitID, unitDefID, unitTeam)
			local commandQueue = Spring.GetUnitCommands(unitID, -1)
			if commandQueue and #commandQueue > 0 then
				local ux, _, uz = Spring.GetUnitPosition(unitID)
				for j = 1, #commandQueue do
					local cmd = commandQueue[j]
					if j == 1 and cmd.id < -1 then
						local currentBuilding = Spring.GetUnitIsBuilding(unitID)
						if currentBuilding and Spring.GetUnitDefID(currentBuilding) ~= -cmd.id then
							--Spring.Echo("Adding ID")
							widget:UnitCommand(unitID, unitDefID, unitTeam, commandQueue[j].id, commandQueue[j].params, commandQueue[j].options)
						end
					end
					if cmd.id < 0 then
						--Spring.Echo("Processing command for " .. unitID)
						widget:UnitCommand(unitID, unitDefID, unitTeam, commandQueue[j].id, commandQueue[j].params, commandQueue[j].options)
					end
				end
			end
		end
	end
	UpdateAllQueuesList()
end

function widget:Initialize()
	drawGroundCircle = options.mergeCircles.value and gl.Utilities.DrawMergedGroundCircle or gl.Utilities.DrawGroundCircle
	playerAllyTeam = Spring.GetMyAllyTeamID()
	playerTeamID = Spring.GetMyTeamID()
	showAllies = options.show_allies.value -- must be before AllyTeamChanged otherwise will need to be invalidated!
	WG.showeco = options.start_with_showeco.value
	AllyTeamChanged()
	highlightQueue = false
	alwaysHighlight = options.drawQueued.value
	widget:SelectionChanged(Spring.GetSelectedUnits())
	--highlightQueue = options.drawQueued.value
end

function widget:Shutdown()
	gl.DeleteList(drawList or 0)
	gl.DeleteList(disabledDrawList or 0)
	gl.DeleteList(drawQueueList or 0)
	gl.DeleteList(drawAllQueuedList or 0)
end

function widget:GameFrame(f)
	if f%32 == 2 then
		lastFrame = f
	end
end

local function makePylonListVolume(onlyActive, onlyDisabled)
	local i = 1
	while i <= pylons.count do
		local data = pylons.data[i]
		local unitID = data.unitID
		if spValidUnitID(unitID) then
			local efficiency = spGetUnitRulesParam(unitID, "gridefficiency") or -1
			if efficiency == -1 and not onlyActive then
				glColor(disabledColor)
				drawGroundCircle(data.x, data.z, data.range)
			elseif efficiency ~= -1 and not onlyDisabled then
				local color = GetGridColor(efficiency, drawAlpha)
				glColor(color)
				drawGroundCircle(data.x, data.z, data.range)
			end
			i = i + 1
		else
			pylons.data[i] = pylons.data[pylons.count]
			pylonByID[pylons.data[i].unitID] = i
			pylons.data[pylons.count] = nil
			pylons.count = pylons.count - 1
		end
	end
	-- Keep clean for everyone after us
	gl.Clear(GL.STENCIL_BUFFER_BIT, 0)
end


local function HighlightPylons()
	if lastDrawnFrame < lastFrame then
		lastDrawnFrame = lastFrame
		if options.mergeCircles.value then
			gl.DeleteList(disabledDrawList or 0)
			disabledDrawList = gl.CreateList(makePylonListVolume, false, true)
			gl.DeleteList(drawList or 0)
			drawList = gl.CreateList(makePylonListVolume, true, false)
		else
			gl.DeleteList(drawList or 0)
			drawList = gl.CreateList(makePylonListVolume)
		end
	end
	gl.CallList(drawList)
	if options.mergeCircles.value then
		gl.CallList(disabledDrawList)
	end
end

local function HighlightPlacement(unitDefID)
	if not unitDefID then
		return
	end
	local mx, my = spGetMouseState()
	local _, coords = spTraceScreenRay(mx, my, true, true, false, not floatOnWater[unitDefID])
	if coords then
		local radius = pylonDefs[unitDefID]
		if (radius ~= 0) then
			local x, _, z = spPos2BuildPos( unitDefID, coords[1], 0, coords[3], spGetBuildFacing())
			glColor(placementColor)
			gl.Utilities.DrawGroundCircle(x,z, radius)
		end
	end
end

function widget:SelectionChanged(selectedUnits)
	-- force regenerating the lists if we've selected a different unit
	currentSelection = selectedUnits
	playerHasBuilderSelected = false
	if #currentSelection > 0 then
		for i = 1, #currentSelection do
			if isBuilder[Spring.GetUnitDefID(currentSelection[i])] then
				playerHasBuilderSelected = true
				break
			end
		end
	end
	UpdateQueueList()
end



function widget:DrawWorld()
	if Spring.IsGUIHidden() or not (playerIsPlacingPylon or alwaysHighlight) then return end
	gl.DepthMask(true)
	gl.DepthTest(GL.LEQUAL)
	glColor(1.0, 1.0, 1.0, 0.20)
	for unitID, data in IterableMap.Iterator(queuedPylons) do
		local team = Spring.GetUnitTeam(unitID)
		if showAllies or team == playerTeamID then
			for i = 1, #data do
				local facing = data[i].facing or 1
				gl.PushMatrix()
					gl.LoadIdentity()
					gl.Translate(data[i].x, data[i].y, data[i].z)
					gl.Rotate(90 * facing, 0, 1, 0)
					gl.Texture("%"..data[i].def..":0") 
					gl.UnitShape(data[i].def, team, false, false, false) -- gl.UnitShape(bDefID, teamID, false, false, false)
					gl.Texture(false) 
				gl.PopMatrix()
			end
		end
	end
	glColor(1,1,1,1)
	gl.DepthTest(false)
	gl.DepthMask(false)
end

function widget:Update()
	if playerHasBuilderSelected or alwaysHighlight then
		local _, newCommand = spGetActiveCommand()  -- show pylons if pylon is about to be placed
		if newCommand ~= currentCommand then
			currentCommand = newCommand
			if newCommand and pylonDefs[-newCommand] then
				ForceRedraw()
			end
		end
		if currentCommand and pylonDefs[-currentCommand] then
			playerIsPlacingPylon = true
		else
			playerIsPlacingPylon = false
		end
	end
end

function widget:PlayerChangedTeam(playerID, oldTeam, newTeam)
	if playerID == Spring.GetMyPlayerID() then -- we're switching teams.
		local newAllyTeam = select(6, Spring.GetTeamInfo(newTeam))
		if newAllyTeam ~= playerAllyTeam then
			AllyTeamChanged()
		end
	end
end


function widget:KeyPress(key, mods)
	--Spring.Echo("KeyPress: " .. tostring(mods.shift))
	if mods.shift and playerHasBuilderSelected then
		highlightQueue = true
	end
end

function widget:KeyRelease(key)
	highlightQueue = false
end

function widget:DrawWorldPreUnit()
	if Spring.IsGUIHidden() then return end
	if highlightQueue and not (playerIsPlacingPylon or alwaysHighlight) then
		gl.CallList(drawQueueList)
	elseif playerIsPlacingPylon or alwaysHighlight then
		gl.CallList(drawAllQueuedList)
		if currentCommand and pylonDefs[-currentCommand] then
			HighlightPlacement(-currentCommand)
		end
	end
	local showecoMode = WG.showeco
	if showecoMode or playerHasBuilderSelected then
		HighlightPylons()
		glColor(1,1,1,1)
		return
	end
end
