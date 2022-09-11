if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Unit Must Survive",
		desc      = "Campaign gadget that allows for units that must survive.",
		author    = "Shaman",
		date      = "10 Sept 2022",
		license   = "CC-0",
		layer     = -15,
		enabled   = true,
	}
end

local mustSurvive = {}
local oneOfMustSurvive = {} -- groupnum = count
local oneOfReverse = {} -- unitID = groupID

local function DefeatMessage(unitDefID, allyTeamID, allyName, wasLast)
	local defeatMsg
	if wasLast then
		defeatMsg = "The last <defname> owned by <allyname> was destroyed! <allyname> has been defeated!"
	else
		defeatMsg = "<allyname>'s <defname> was killed. <allyname> is forced to retreat!"
	end
	defeatMsg = defeatMsg:gsub("<allyname>", allyName):gsub("<defname>", UnitDefs[unitDefID].humanName)
	Spring.Echo("game_message: " .. defeatMsg)
	GG.DestroyAlliance(allyTeamID)
end

-- adding stuff

local function AddUnit(unitID)
	mustSurvive[unitID] = true
end

local function AddUnitToGroup(unitID, groupnum)
	oneOfReverse[unitID] = groupnum
	oneOfMustSurvive[groupnum] = (oneOfMustSurvive[groupnum] or 0) + 1
end

local function AddUnitToSameGroup(unitID, unitID2)
	local groupnum = oneOfReverse[unitID2]
	AddUnitToGroup(unitID, groupnum)
end

-- Stuff Dies --

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	if oneOfReverse[unitID] then
		local groupnum = oneOfReverse[unitID]
		
		local count = oneOfMustSurvive[groupnum] - 1
		local morphed = Spring.GetUnitRulesParam(unitID, "wasMorphedTo")
		if morphed then
			AddUnitToSameGroup(morphed, unitID)
			count = count + 1
		end
		oneOfMustSurvive[groupnum] = count
		oneOfReverse[unitID] = nil
		if count == 0 then
			local allyTeamID = Spring.GetUnitAllyTeam(unitID)
			local allyName = Spring.GetGameRulesParam("allyteam_short_name_" .. allyTeamID)
			DefeatMessage(unitDefID, allyTeamID, allyName, false)
			return
		end
	end
	if mustSurvive[unitID] then
		local morphed = Spring.GetUnitRulesParam(unitID, "wasMorphedTo")
		if morphed == nil then -- unit was killed
			local allyTeamID = Spring.GetUnitAllyTeam(unitID)
			local allyName = Spring.GetGameRulesParam("allyteam_short_name_" .. allyTeamID)
			DefeatMessage(unitDefID, allyTeamID, allyName, false)
			return
		else
			AddUnit(morphed)
		end
		mustSurvive[unitID] = nil
	end
end

-- Expose to other gadgets.

local function CheckForSpecialStatus(unitID)
	return mustSurvive[unitID] or oneOfReverse[unitID] ~= nil
end

GG.UMS = {IsUnitSpecial = CheckForSpecialStatus, AddUnit = AddUnit, AddUnitToGroup = AddUnitToGroup, AddUnitToSameGroup = AddUnitToSameGroup}

-- Safety --

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, params)
	if CheckForSpecialStatus(unitID) and (cmdID == CMD.SELFD) then -- don't allow special units to self-d
		return false
	elseif cmdID == CMD.RECLAIM and CheckForSpecialStatus(params[1]) then -- don't allow units to reclaim our special units.
		return false
	else
		return true
	end
end

function gadget:AllowUnitTransfer(unitID) -- do not allow units to be transfered.
	if CheckForSpecialStatus(unitID) then
		return false
	end
	return true
end

--[[function gadget:AllowUnitBuildStep(builderID, builderTeam, unitID, unitDefID, part)
	if part < 0 and IsUnitSpecial(unitID) then
		return false
	end
	return true
end]] -- Additional safety may not be necessary.
