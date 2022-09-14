if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Scenario Loader",
		desc      = "Loads scenarios from files for MP campaigns.",
		author    = "Shaman",
		date      = "10 Sept 2022",
		license   = "CC-0",
		layer     = 1005,
		enabled   = true,
	}
end

function gadget:Initialize()
	local allyteamlist = Spring.GetAllyTeamList()
	local holderTeams = {}
	local configPath = "LuaRules\\Configs\\Scenarios\\"
	local unitconfig, envconfig
	if VFS.FileExists(configPath .. Game.mapName .. "_units.lua") then
		unitconfig = VFS.Include(configPath .. Game.mapName .. "_units.lua") -- load config.
	end
	for i = 1, #allyteamlist do
		local teamlist = Spring.GetTeamList(allyteamlist[i])
		holderTeams[i] = teamlist[1]
	end
	if unitconfig then
		GG.Scenario = {Units = {}}
		local done = {} -- store for buildees
		for i = 1, #unitconfig do
			local unit = unitconfig[i]
			local position = unit.positionState
			local unitID
			if unit.unitDef == "dyntrainer_strike_base" then
				StartPos[unit.allyID] = StartPos[unit.allyID] or {}
				StartPos[unit.allyID][unit.role] = {position.position[1], position.position[2], position.position[3]}
			else
				if unit.healthState.buildprogress == 1 then
					unitID = Spring.CreateUnit(unit.unitDef, position.position[1], position.position[2], position.position[3], position.facing, holderTeams[unit.allyID], false, false)
				else
					unitID = Spring.CreateUnit(unit.unitDef, position.position[1], position.position[2], position.position[3], position.facing, holderTeams[unit.allyID], true, false, done[unit.builder])
				end
				Spring.SetUnitRotation(unitID, position.rotation[1], position.rotation[2], position.rotation[3])
				Spring.SetUnitHealth(unitID, unit.healthState.hp, unit.healthState.captureprogress, unit.healthState.paralysis, unit.healthState.buildprogress)
				Spring.SetUnitMaxHealth(unitID, unit.healthState.maxhp)
				local cmdArray = {}
				-- Set up states --
				cmdArray[1] = {CMD.ONOFF, {unit.states.active and 1 or 0}, {}} -- Active State
				cmdArray[2] = {CMD.REPEAT, {unit.states.repeat and 1 or 0}, {}} -- repeat state
				cmdArray[3] = {CMD.CLOAK, {unit.states.cloak and 1 or 0}, {}} -- cloak state
				cmdArray[4] = {CMD.FIRE_STATE, {unit.states.firestate}, {}} -- fire state
				cmdArray[5] = {CMD.MOVE_STATE, {unit.states.movestate}, {}} -- move state
				cmdArray[6] = {CMD.TRAJECTORY, {unit.states.trajectory and 1 or 0}, {}} -- trajectory
				-- setup queue --
				if #unit.queue > 0 then
					for c = 1, #unit.queue do
						local cmd = unit.queue[c]
						cmdArray[#cmdArray + 1] = {cmd.id, cmd.params, cmd.options}
					end
				end
				done[i] = unitID
				-- Give order --
				Spring.GiveOrderArrayToUnitArray({unitID}, cmdArray)
				GG.Scenario.Units[unit.allyID] = GG.Scenario.Units[unit.allyID] or {} -- this is probably a bit inefficient, but whatever.
				GG.Scenario.Units[unit.allyID][unit.role] = GG.Scenario.Units[unit.allyID][unit.role] or {}
				GG.Scenario.Units[unit.allyID][unit.role][#GG.Scenario.Units[unit.allyID][unit.role] + 1] = unitID
				if unit.mustSurvive then -- set up UMS status.
					GG.UMS.AddUnit(unitID)
				end
				if unit.mustSurviveGroup then
					GG.UMS.AddUnitToGroup(unitID, unit.mustSurviveGroup)
				end
			end
		end
	end
end