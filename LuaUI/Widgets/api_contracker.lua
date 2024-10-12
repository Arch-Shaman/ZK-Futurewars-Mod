function widget:GetInfo()
	return {
		name      = "Callin for Lost All Cons",
		desc      = "Tells other widgets when a player is out of cons.",
		author    = "Shaman",
		date      = "09/24/18",
		license   = "PD",
		layer     = -99999,
		enabled   = true,
		alwaysStart = true,
		handler = true,
	}
end

local listeners = {}

local teamCons = {}
local teamState = {}
local myAllyTeam
local amISpectator = false

local myConstructors = {}
local myIdleCons = {}

local function addListener(l, widgetName)
	if l and type(l) == "function" then
		local okay, err = pcall(l, -1)
		if okay then
			listeners[widgetName] = l
		else
			Spring.Echo("OnPlayerLostAllCons: subscribe failed: " .. widgetName .. "\nCause: " .. err)
		end
	else
		Spring.Echo("OnPlayerLostAllCons: subscribe failed: " .. widgetName .. "\nCause: Not a function.")
	end
end

local function FireUpdate(teamID)
	Spring.Echo("api_contracker: " .. teamID .. ", " .. tostring(teamState[teamID]))
	for w,f in pairs(listeners) do
		local okay, err = pcall(f, teamID, teamState[teamID])
		if not okay then
			Spring.Echo("OnPlayerLostAllCons update failed: " .. w .. "\nCause: " .. err)
			listeners[w] = nil
		end
	end
end

local function CheckTeam(teamID)
	Spring.Echo("api_contracker: " .. teamID .. ": " .. tostring(teamCons[teamID]))
	if teamCons[teamID] == 0 then
		teamState[teamID] = false
		FireUpdate(teamID)
	elseif not teamState[teamID] and teamCons[teamID] > 0 then
		teamState[teamID] = true
		FireUpdate(teamID)
	end
end

local function Unsubscribe(widget_name)
	listeners[widget_name] = nil
end

local function IsUnitACon(unitDefID)
	local ud = UnitDefs[unitDefID]
	return (ud.isBuilder or ud.isFactory) and ud.canAssist -- prevent detection of rejuvs
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerUnitID, attackerDefID, attackerTeam)
	if IsUnitACon(unitDefID) then
		Spring.Echo("UnitDestroyed: " .. tostring(unitTeam))
		teamCons[unitTeam] = teamCons[unitTeam] - 1
		CheckTeam(unitTeam)
		if unitTeam == Spring.GetMyTeamID() then
			myConstructors[unitID] = nil
		end
	end
end

function widget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if IsUnitACon(unitDefID) then
		teamCons[oldTeam] = teamCons[oldTeam] - 1
		teamCons[newTeam] = teamCons[newTeam] + 1
		CheckTeam(unitTeam)
		local myTeam = Spring.GetMyTeamID()
		if oldTeam == myTeam then
			myConstructors[unitID] = nil
		elseif newTeam == myTeam then
			myConstructors[unitID] = true
		end
	end
end

function widget:UnitReverseBuilt(unitID, unitDefID, unitTeam)
	if IsUnitACon(unitDefID) then
		teamCons[unitTeam] = teamCons[unitTeam] - 1
		CheckTeam(unitTeam)
		if unitTeam == Spring.GetMyTeamID() then
			myConstructors[unitID] = nil
		end
	end
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
	if IsUnitACon(unitDefID) then
		teamCons[unitTeam] = teamCons[unitTeam] + 1
		CheckTeam(unitTeam)
		if unitTeam == Spring.GetMyTeamID() then
			myConstructors[unitID] = true
		end
	end
end

local function SetUpTeam(teamID, force)
	if teamCons[teamID] and not force then return end
	teamCons[teamID] = 0
	local units = Spring.GetTeamUnits(teamID)
	for u = 1, #units do
		widget:UnitFinished(units[u], Spring.GetUnitDefID(units[u]), teamID)
	end
	CheckTeam(teamID)
end

function widget:Initialize()
	myAllyTeam = Spring.GetMyAllyTeamID()
	amISpectator = Spring.GetSpectatingState()
	if amISpectator then
		local allyteams = Spring.GetAllyTeamList()
		for a = 1, #allyteams do
			local teamList = Spring.GetTeamList(allyteams[a])
			for t = 1, #teamList do
				SetUpTeam(teamList[t])
			end
		end
	else
		local teamList = Spring.GetTeamList(myAllyTeam)
		for t = 1, #teamList do
			SetUpTeam(teamList[t])
		end
	end
end

function widget:PlayerChanged(playerID)
	if not amISpectator then
		if Spring.GetSpectatingState() then -- player resigned
			amISpectator = true
			for a = 1, #allyteams do
				local teamList = Spring.GetTeamList(allyteams[a])
				for t = 1, #teamList do
					SetUpTeam(teamList[t])
				end
			end
		end
	end
end

local function GetMyCons()
	local ret = {}
	local myTeamID = Spring.GetMyTeamID()
	for id, _ in pairs(myConstructors) do
		if Spring.GetUnitTeamID() == myTeamID then
			ret[#ret + 1] = id
		end
	end
	return ret
end

function widget:UnitIdle(unitID, unitDefID, unitTeam)
	if unitTeam == Spring.GetMyTeamID() and myConstructors[unitID] then
		myIdleCons[unitID] = true
	end
end

function widget:UnitCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
	if myIdleCons[unitID] then
		myIdleCons[unitID] = nil
	end
end

local function GetIdleCons()
	local ret = {}
	local myTeamID = Spring.GetMyTeamID()
	for id, _ in pairs(myIdleCons) do
		if Spring.GetUnitTeamID() == myTeamID then
			ret[#ret + 1] = id
		end
	end
	return ret
end

local function GetTeamConStatus(teamID)
	return teamCons[teamID] and teamCons[teamID] > 0
end

WG.ConTracker = {
	Subscribe = addListener,
	Unsubscribe = Unsubscribe,
	GetMyCons = GetMyCons,
	GetIdleCons = GetIdleCons,
	GetTeamConStatus = GetTeamConStatus
}
