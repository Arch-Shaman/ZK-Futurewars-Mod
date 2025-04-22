function widget:GetInfo()
  return {
    name      = "Localized Labels and Messages",
    desc      = "Provides label macros in your language.",
    author    = "Shaman",
    date      = "April 5th, 2025",
    license   = "CC-0",
    layer     = -100,
    enabled   = true,
  }
end

local function GetRoundedString(str, place)
	return string.format("%." .. place .. "f", str)
end

local airFactoryDef = UnitDefNames["factoryplane"].id
local airPlateDef = UnitDefNames["plateplane"].id

local function DoIEvenHaveAir()
	return #Spring.GetTeamUnitsByDefs(Spring.GetMyTeamID(), {airFactoryDef, airPlateDef}) > 0
end

local function GetNameOfTeam(teamID)
	local _, teamLeader, _, isAI = Spring.GetTeamInfo(teamID)
	if not isAI then
		local teamSize = #Spring.GetPlayerList(teamID, true)
		if teamSize > 1 then
			return Spring.GetPlayerInfo(teamLeader) .. "'s squad" -- TODO: Localize
		else
			return Spring.GetPlayerInfo(teamLeader)
		end
	else
		local _, name = Spring.GetAIInfo(teamID)
		return name
	end
end

local function GetTeamNameFromUnitID(unitID)
	local teamID = Spring.GetUnitTeam(unitID)
	return GetNameOfTeam(teamID)
end

local function AddFakeLabel(playerID, text, x, z) -- ProConsoleAddFakeMsg(playerID, txt)
	local y = Spring.GetGroundHeight(x, z)
	Spring.MarkerAddPoint(x, y, z, text, true, playerID)
end

--             AddLocalizedLabel(playerID, context, x, z, unitDef, unitID, unitTeamID, extrainfo)
local function AddLocalizedLabel(playerID, num, x, z, unitDef, unitID, teamID, extrainfo)
	local teamName
	if teamID then
		teamName = GetNameOfTeam(teamID)
	end
	local str
	local unitName = unitDef and (WG.Translate("units", UnitDefs[unitDef].name .. ".name") or UnitDefs[unitDef].humanName)
	if not unitName then
		unitName = WG.Translate("interface", "radardot")
	end
	Spring.Echo("unitName: " .. tostring(unitName) .. ", " .. tostring(extrainfo) .. ", " .. num)
	if num == 36 then -- special support neeeded 
		str = WG.Translate("interface", "localizedlabel_36", {power = extrainfo})
	elseif num == 8 then
		str = WG.Translate("interface", "localizedlabel_8", {teamname = teamName, health = extrainfo})
	elseif num == 10 or num == 11 or num == 5 then
		str = WG.Translate("interface", "localizedlabel_"..num, {teamname = teamName, unitname = unitName, progress = extrainfo})
	else
		str = WG.Translate("interface", "localizedlabel_"..num, {teamname = teamName, unitname = unitName, health=extrainfo})
	end
	if num == 27 or num == 26 then
		if Spring.GetMyPlayerID() == playerID or DoIEvenHaveAir() then
			AddFakeLabel(playerID, str, x, z)
		end
	else
		AddFakeLabel(playerID, str, x, z)
	end
end

local function AddLocalizedMessage(playerID, num, teamID, health)
	WG.ProConsoleAddFakeMsg(playerID, WG.Translate("interface", "localizedlabel_" .. num))
end

local function CheckForGrid(unitID, unitDefID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp and cp.pylonrange then -- this is a griddable
		if cp.neededlink then -- griddable weapon
			local needed = tonumber(cp.neededlink) or 0
			local hasPower = (Spring.GetUnitRulesParam(unitID, "lowpower") or 0) == 0
			if hasPower then return end -- unit has power, no complaints.
			local currentGrid = Spring.GetUnitRulesParam(unitID, "OD_gridMaximum") or 0
			local powerNeeded = needed - currentGrid
			if powerNeeded == needed then return 35 end
			return 36, powerNeeded
		else -- grid provider or mex
			local eff = Spring.GetUnitRulesParam(unitID, "gridefficiency") or -1
			--Spring.Echo("Efficiency is " .. eff)
			if eff <= 0 then return 35 end -- context 35: connect this to grid.
			return nil -- no complaints.
		end
	else
		return nil
	end
end

local function SendOutLabel(labelNumber, unitID, unitDefID, teamID, extrainfo, x, z)
	Spring.SendLuaUIMsg("locallabel:" .. labelNumber .. "," .. x .. "," .. z .. "," .. tostring(unitDefID) .. "," .. tostring(unitID) .. "," .. tostring(teamID) .. "," .. tostring(extrainfo), "a")
end

local function GetContextFromMousePos(contextNum)
	local mouseX, mouseZ = Spring.GetMouseState()
	local returntype, args = Spring.TraceScreenRay(mouseX, mouseZ, false, false, false, false)
	local _, pos = Spring.TraceScreenRay(mouseX, mouseZ, true, false, false, false)
	local x, y, z
	local _, activeCommand = Spring.GetActiveCommand()
	if pos then
		x = pos[1]
		y = pos[2]
		z = pos[3]
	end
	local buildDef = activeCommand and activeCommand < 0 and activeCommand * -1
	if not x or not z then return end
	if x < 0 or z < 0 or x > Game.mapSizeX or z > Game.mapSizeZ then return end -- Don't do things for out of bounds!
	local playerID = Spring.GetMyPlayerID()
	if returntype == "feature" then
		SendOutLabel(39, nil, nil, nil, nil, x, z)
		return
	end
	if contextNum == 1 then -- General spotting
		if returntype == "ground" then
			local aboveGeo = WG.mouseAboveGeo
			local pregame = Spring.GetGameFrame() < 1
			if pregame then -- pregame, we probably want someone to spawn somewhere.
				SendOutLabel(21, nil, nil, nil, nil, x, z)
				return
			end
			if buildDef then
				SendOutLabel(20, nil, buildDef, nil, nil, x, z)
				return
			end
			if aboveGeo then
				SendOutLabel(13, nil, UnitDefNames["energygeo"].id, nil, nil, x, z)
				return
			end
			local isInLos = Spring.IsPosInLos(x, y, z)
			if not isInLos then
				SendOutLabel(29, nil, nil, nil, nil, x, z)
				return
			end
			SendOutLabel(12, nil, nil, nil, nil, x, z) -- labelNumber, unitID, unitDefID, unitTeam, extrainfo, x, z
		elseif returntype == "unit" then
			local unitID = args
			local unitDefID = Spring.GetUnitDefID(unitID)
			local unitAllyTeam = Spring.GetUnitAllyTeam(unitID)
			local isEnemy = unitAllyTeam ~= Spring.GetMyAllyTeamID()
			local unitName = unitDefID and UnitDefs[unitDefID].humanName or "radar dot"
			local teamName = GetTeamNameFromUnitID(unitID)
			local unitTeam = Spring.GetUnitTeam(unitID)
			local unitHealth, maxHealth, _, _, conProgress = Spring.GetUnitHealth(unitID)
			local healthPerc = unitHealth and (unitHealth / maxHealth) or 1.0
			local isMyUnit = unitTeam == Spring.GetMyTeamID()
			local isStructure = unitDefID and (UnitDefs[unitDefID].isBuilding or UnitDefs[unitDefID].speed < 3)
			local _, isStunned = Spring.GetUnitIsStunned(unitID) 
			if not unitDefID then
				local groundHeight = Spring.GetGroundHeight(x, z)
				local _, y, _ = Spring.GetUnitPosition(unitID)
				if groundHeight < 0 then groundHeight = 0 end -- water exists!
				if y - groundHeight > 25 then -- probably flying
					SendOutLabel(1, unitID, unitDefID, unitTeam, nil, x, z)
				else
					SendOutLabel(2, unitID, unitDefID, unitTeam, nil, x, z)
				end
			elseif isEnemy then
				if not conProgress then -- on radar
					--Spring.Echo("OnRadar -- context: 2")
					SendOutLabel(3, unitID, unitDefID, unitTeam, nil, x, z)
					return
				end
				if conProgress >= 1 and isStunned then
					SendOutLabel(37, unitID, unitDefID, unitTeam, nil, x, z)
					return
				end
				if conProgress >= 1 and healthPerc < 0.3 then -- probably want someone to pick it off.
					SendOutLabel(4, unitID, unitDefID, unitTeam, GetRoundedString(unitHealth, 0), x, z)
				elseif conProgress < 1 then -- we  probably want to point out something's under construction
					SendOutLabel(5, unitID, unitDefID, unitTeam, GetRoundedString(conProgress * 100, 2), x, z)
				else
					SendOutLabel(2, unitID, unitDefID, unitTeam, nil, x, z)
				end
			else
				-- check for grid --
				local gridContext, powerNeeded = CheckForGrid(unitID, unitDefID)
				if gridContext then
					-- temporary code --
					--Spring.Echo("Grid context: " .. gridContext)
					if gridContext == 35 then
						SendOutLabel(35, unitID, unitDefID, unitTeam, nil, x, z)
					else
						SendOutLabel(36, unitID, unitDefID, unitTeam, powerNeeded, x, z)
					end
					return
				end
				local nearestEnemy = Spring.GetUnitNearestEnemy(unitID, 600, true)
				if conProgress >= 1 and healthPerc < 0.5 then
					if isMyUnit then
						SendOutLabel(7, unitID, unitDefID, unitTeam, nil, x, z)
					elseif not isStructure and nearestEnemy then
						SendOutLabel(8, unitID, unitDefID, unitTeam, GetRoundedString(unitHealth, 0), x, z)
					else
						SendOutLabel(9, unitID, unitDefID, unitTeam, nil, x, z)
					end
				elseif conProgress < 1 then
					if isMyUnit then
						SendOutLabel(10, unitID, unitDefID, unitTeam, GetRoundedString(conProgress * 100, 2), x, z)
						--AddFakeLabel(playerID, "Help me construct this " .. unitName .. "! (Progress: " .. GetRoundedString(conProgress * 100, 2) .. "%)", x, z)
					else
						SendOutLabel(11, unitID, unitDefID, unitTeam, GetRoundedString(conProgress * 100, 2), x, z)
					end
				else
					--SendOutLabel(6, unitID, unitDefID, extrainfo, teamID, x, z)
					SendOutLabel(6, unitID, unitDefID, unitTeam, nil, x, z)
				end
			end
		end
	elseif contextNum == 2 then -- assist with something. (More granular)
		if buildDef then
			SendOutLabel(13, nil, buildDef, nil, nil, x, z)
			--AddFakeLabel(playerID, "Build a " .. UnitDefs[buildDef].humanName .. " here!", x, z)
			return
		end
		if returntype == "ground" then
			SendOutLabel(14, nil, nil, nil, nil, x, z)
			--AddFakeLabel(playerID, "Need reinforcements here!", x, z)
		else -- needs help with building or repairing something.
			local unitID = args
			local unitDefID = Spring.GetUnitDefID(unitID)
			local unitAllyTeam = Spring.GetUnitAllyTeam(unitID)
			local isEnemy = unitAllyTeam ~= Spring.GetMyAllyTeamID()
			local unitTeam = Spring.GetUnitTeam(unitID)
			local unitHealth, maxHealth, _, _, conProgress = Spring.GetUnitHealth(unitID)
			local healthPerc = unitHealth and (unitHealth / maxHealth) or 1.0
			local isMyUnit = unitTeam == Spring.GetMyTeamID()
			local isStructure = unitDefID and (UnitDefs[unitDefID].isBuilding or UnitDefs[unitDefID].speed < 3)
			if isEnemy and unitName ~= "radar dot" then
				SendOutLabel(15, unitID, unitDefID, nil, nil, x, z)
				--AddFakeLabel(playerID, "Need help fighting this " .. unitName, x, z)
			elseif not isEnemy then
				if conProgress < 1 then -- request assistance with building something.
					SendOutLabel(16, unitID, unitDefID, nil, nil, x, z)
					--AddFakeLabel(playerID, "We need to finish this " .. unitName .. "!", x, z)
				elseif healthPerc < 0.8 then
					SendOutLabel(17, unitID, unitDefID, nil, nil, x, z)
					--AddFakeLabel(playerID, "Help repair this " .. unitName .. "!", x, z)
				else
					if isStructure then
						SendOutLabel(18, unitID, unitDefID, nil, nil, x, z)
						--AddFakeLabel(playerID, "Help defend this " .. unitName .. "!", x, z)
					else
						SendOutLabel(19, unitID, unitDefID, nil, nil, x, z)
						--AddFakeLabel(playerID, "This " .. unitName .. " needs an escort!", x, z)
					end
				end
			end
		end
	elseif contextNum == 3 then -- retreat
		if returntype == "ground" then
			SendOutLabel(38, nil, nil, nil, nil, x, z)
		elseif returntype == "unit" then
			local unitID = args
			local unitDefID = Spring.GetUnitDefID(unitID)
			local unitAllyTeam = Spring.GetUnitAllyTeam(unitID)
			local isEnemy = unitAllyTeam ~= Spring.GetMyAllyTeamID()
			local teamName = GetTeamNameFromUnitID(unitID)
			local unitTeam = Spring.GetUnitTeam(unitID)
			local unitHealth, maxHealth, _, _, conProgress = Spring.GetUnitHealth(unitID)
			local healthPerc = unitHealth and (unitHealth / maxHealth) or 1.0
			local isMyUnit = unitTeam == Spring.GetMyTeamID()
			local isStructure = unitDefID and (UnitDefs[unitDefID].isBuilding or UnitDefs[unitDefID].speed < 3)
			if not isEnemy and unitTeam ~= Spring.GetMyTeamID() then
				SendOutLabel(22, unitID, unitDefID, unitTeam, nil, x, z)
			else
				SendOutLabel(38, nil, nil, nil, nil, x, z)
			end
		end
	elseif contextNum == 4 then
		if returntype == "ground" then
			SendOutLabel(24, nil, nil, nil, nil, x, z)
		else
			local unitID = args
			local unitDefID = Spring.GetUnitDefID(unitID)
			local unitAllyTeam = Spring.GetUnitAllyTeam(unitID)
			local isEnemy = unitAllyTeam ~= Spring.GetMyAllyTeamID()
			local unitName = unitDefID and UnitDefs[unitDefID].humanName or "radar dot"
			local teamName = GetTeamNameFromUnitID(unitID)
			local unitTeam = Spring.GetUnitTeam(unitID)
			local unitHealth, maxHealth, _, _, conProgress = Spring.GetUnitHealth(unitID)
			local healthPerc = unitHealth and (unitHealth / maxHealth) or 1.0
			local isMyUnit = unitTeam == Spring.GetMyTeamID()
			local isStructure = unitDefID and (UnitDefs[unitDefID].isBuilding or UnitDefs[unitDefID].speed < 3)
			if not isEnemy then -- TODO: add "let's attack with this unit"
				return
			else
				SendOutLabel(25, unitID, unitDefID, unitTeam, nil, x, z)
			end
		end
	elseif contextNum == 5 then
		if returntype == "ground" then
			SendOutLabel(26, nil, nil, nil, nil, x, z)
		else
			local unitID = args
			local unitDefID = Spring.GetUnitDefID(unitID)
			local unitAllyTeam = Spring.GetUnitAllyTeam(unitID)
			local isEnemy = unitAllyTeam ~= Spring.GetMyAllyTeamID()
			local unitTeam = Spring.GetUnitTeam(unitID)
			if isEnemy then
				if unitDefID and UnitDefs[unitDefID].isAirUnit then
					SendOutLabel(28, unitID, unitDefID, unitTeam, nil, x, z)
				elseif unitDefID then
					SendOutLabel(27, unitID, unitDefID, unitTeam, nil, x, z)
				else
					SendOutLabel(26, nil, nil, nil, nil, x, z)
				end
			end
		end
	elseif contextNum == 6 then -- EMP this
		if returntype == "ground" then
			SendOutLabel(33, nil, nil, nil, nil, x, z)
		else
			local unitID = args
			local unitDefID = Spring.GetUnitDefID(unitID)
			local unitAllyTeam = Spring.GetUnitAllyTeam(unitID)
			local isEnemy = unitAllyTeam ~= Spring.GetMyAllyTeamID()
			local unitTeam = Spring.GetUnitTeam(unitID)
			if isEnemy then
				SendOutLabel(32, unitID, unitDefID, unitTeam, nil, x, z)
			else
				return
			end
		end
	elseif contextNum == 7 then -- Artillery Support
		SendOutLabel(30, nil, nil, nil, nil, x, z)
	elseif contextNum == 8 then -- nuke
		SendOutLabel(34, nil, nil, nil, nil, x, z)
	elseif contextNum == 9 then -- ??
		
	else -- ??
		
	end
end

function widget:RecvLuaMsg(msg, playerID)
	if string.sub(msg, 1, 11) == "locallabel:" then
		local proccessed = string.sub(msg, 12)
		local args = {}
		for w in string.gmatch(proccessed, "([^,]+)") do
			args[#args + 1] = w
		end
		--[[Spring.SendLuaUIMsg("locallabel:" .. 
			labelNumber .. ","
			x .. "," .. 
			z .. "," .. 
			tostring(unitDefID) .. "," .. 
			tostring(unitID) .. "," .. 
			tostring(teamID) .. "," .. 
			tostring(extrainfo), "a")]]
		local context = tonumber(args[1])
		if context == nil then return end
		local x = tonumber(args[2])
		local z = tonumber(args[3])
		if not x or not z then return end
		local unitDef = args[4] and tonumber(args[4])
		local unitID = args[5] and tonumber(args[5])
		local unitTeamID = args[6] and tonumber(args[6])
		local extrainfo = args[7]
		--[[for i = 1, #args do
			Spring.Echo(i .. ": " .. args[i])
		end]]
		AddLocalizedLabel(playerID, context, x, z, unitDef, unitID, unitTeamID, extrainfo)
	elseif string.sub(msg, 1, 9) == "localmsg:" then
		local proccessed = string.sub(msg, 10)
		AddLocalizedMessage(playerID, proccessed)
	end
end

function widget:KeyPress(num, isRepeat)
	if num > 57 or num < 47 or not WG.drawtoolKeyPressed then return false end -- keys: 49 - 57 + 48 
	--Spring.Echo("Keypress: " .. num .. " -- context: " .. num - 48)
	GetContextFromMousePos(num - 48)
	return true
end
