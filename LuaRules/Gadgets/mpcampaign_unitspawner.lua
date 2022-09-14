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
		enabled   = false,
	}
end

function gadget:Initialize()
	local allyteamlist = Spring.GetAllyTeamList()
	local holderTeams = {}
	local configPath = "LuaRules\\Configs\\Scenarios\\"
	local unitconfig, envconfig
	if VFS.FileExists(configPath .. Game.mapName .. "_units.lua") then
		unitconfig = include(configPath .. Game.mapName .. "_units.lua") -- load config.
	end
	for i = 1, #allyteamlist do
		local teamlist = Spring.GetTeamList(allyteamlist[i])
		holderTeams[allyteamlist[i]] = teamlist[1]
	end
	if unitconfig then
		GG.Scenario = {Units = {}}
		local done = {} -- store for buildees
		for i = 1, #unitconfig do
			Spring.Echo("Loading unit " .. i)
			local unit = unitconfig[i]
			--for k, v in pairs(unitconfig[i]) do
				--Spring.Echo(k .. " : " .. tostring(v))
			--end
			local position = unitconfig[i]["position"]
			local healthstate = unitconfig[i]["health"]
			local unitID
			if unit.unitdef == "dyntrainer_strike_base" then
				if GG.Scenario.StartPos then
					GG.Scenario.StartPos[unit.allyid] = GG.Scenario.StartPos[unit.allyid] or {}
					GG.Scenario.StartPos[unit.allyid][unit.role] = {position.position[1], position.position[2], position.position[3]}
				else
					GG.Scenario.StartPos = {}
					GG.Scenario.StartPos[unit.allyid] = GG.Scenario.StartPos[unit.allyid] or {}
					GG.Scenario.StartPos[unit.allyid][unit.role] = {position.position[1], position.position[2], position.position[3]}
				end
			else
				if healthstate.buildprogress == 1 then
					unitID = Spring.CreateUnit(unit.unitdef, position.position[1], position.position[2], position.position[3], position.facing, holderTeams[unit.allyid], false, false)
				else
					unitID = Spring.CreateUnit(unit.unitdef, position.position[1], position.position[2], position.position[3], position.facing, holderTeams[unit.allyid], true, false, done[unit.builder])
				end
				Spring.SetUnitRotation(unitID, position.rotation[1], position.rotation[2], position.rotation[3])
				Spring.SetUnitHealth(unitID, healthstate.hp, healthstate.captureprogress, healthstate.paralysis, healthstate.buildprogress)
				Spring.SetUnitMaxHealth(unitID, healthstate.maxhp)
				local cmdArray = {}
				-- Set up states --
				cmdArray[1] = {CMD.ONOFF, {unit.states.active and 1 or 0}, {}} -- Active State
				cmdArray[2] = {CMD.REPEAT, {unit.states.repeats and 1 or 0}, {}} -- repeat state
				cmdArray[3] = {CMD.CLOAK, {unit.states.cloak and 1 or 0}, {}} -- cloak state
				cmdArray[4] = {CMD.FIRE_STATE, {unit.states.firestate}, {}} -- fire state
				cmdArray[5] = {CMD.MOVE_STATE, {unit.states.movestate}, {}} -- move state
				cmdArray[6] = {CMD.TRAJECTORY, {unit.states.trajectory and 1 or 0}, {}} -- trajectory
				-- setup queue --
				if #unit.queue > 0 then
					for c = 1, #unit.queue do
						local cmd = unit.queue[c]
						local cmdid = cmd.id
						local params = {}
						if cmdid == 16 or cmdid == 15 or cmdid == 10 then -- needs fixes.
							params[1] = cmd.params[1]
							params[2] = Spring.GetGroundHeight(cmd.params[1], cmd.params[3]) -- clamp to ground
							params[3] = cmd.params[3]
							if params[4] and params[4] > 0 then
								params[4] = cmd.params[4]
							end
						end
						cmdArray[#cmdArray + 1] = {cmdid, params, cmd.options}
					end
				end
				done[i] = unitID
				-- Give order --
				Spring.GiveOrderArrayToUnitArray({unitID}, cmdArray)
				GG.Scenario.Units[unit.allyid] = GG.Scenario.Units[unit.allyid] or {} -- this is probably a bit inefficient, but whatever.
				GG.Scenario.Units[unit.allyid][unit.role] = GG.Scenario.Units[unit.allyid][unit.role] or {}
				GG.Scenario.Units[unit.allyid][unit.role][#GG.Scenario.Units[unit.allyid][unit.role] + 1] = unitID
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