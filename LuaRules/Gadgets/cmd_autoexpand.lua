if not gadgetHandler:IsSyncedCode() then -- SYNCED
	return
end

function gadget:GetInfo() 
	return {
		name    = "Autoexpand",
		desc    = "Expansion should be easy.",
		author  = "Shaman",
		date    = "2025 July 12",
		license = "",
		layer   = 50,
		enabled = true,
	} 
end

local IterableMap = Spring.Utilities.IterableMap
local spLosInfo = Spring.Utilities.LosInfo
local handled = IterableMap.New()
local forceupdatecons = IterableMap.New()
local wantedUnitDefs = {}
local metalSpots = {}
local mexDefs = {}
local CMD_AUTOEXPAND = Spring.Utilities.CMD.AUTOEXPAND
local averageRTGOutput = 0.32
local energyDefs = {
	[1] = {energy = tonumber(UnitDefNames["staticenergyrtg"].customParams.income_energy) * averageRTGOutput, defID = UnitDefNames["staticenergyrtg"].id, cost = UnitDefNames["staticenergyrtg"].metalCost, isWind = false, gridSize = tonumber(UnitDefNames["staticenergyrtg"].customParams.pylonrange) or 10},
	[2] = {energy = tonumber(UnitDefNames["energysolar"].customParams.income_energy), defID = UnitDefNames["energysolar"].id, cost = UnitDefNames["energysolar"].metalCost, isWind = false, gridSize = tonumber(UnitDefNames["energysolar"].customParams.pylonrange) or 10},
	[3] = {energy = tonumber(UnitDefNames["energywind"].customParams.income_energy), defID = UnitDefNames["energywind"].id, cost = UnitDefNames["energywind"].metalCost, isWind = true, gridSize = tonumber(UnitDefNames["energywind"].customParams.pylonrange) or 10},
}

local watchedEnergyDefs = {
	[UnitDefNames["staticenergyrtg"].id] = true,
	[UnitDefNames["energysolar"].id] = true,
	[UnitDefNames["energywind"].id] = true,
}

local incomeMultMetal = 1
local incomeMultEnergy = 1
local energyBuffer = energyDefs[2].energy * 3 -- 3 solars worth.
local mexToSpotID = {}
local mexDefIDs = {}
local averageIncome = 1

local stateCommands = { -- list of cmdIDs that shouldn't interrupt what we're doing.
	[CMD.INSERT] = true,
	[CMD.WAIT] = true,
	[CMD.SQUADWAIT] = true,
	[CMD.GATHERWAIT] = true,
	[CMD.GROUPADD] = true,
	[CMD.GROUPCLEAR] = true,
	[CMD.FIRE_STATE] = true,
	[CMD.MOVE_STATE] = true,
	[CMD.SELFD] = true,
	[CMD.ONOFF] = true,
	[CMD.STOCKPILE] = true,
	[CMD.TRAJECTORY] = true,
	[CMD.AUTOREPAIRLEVEL] = true,
	[CMD.LOOPBACKATTACK] = true,
}

for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	local cp = ud.customParams
	local canBuild = ud.buildSpeed and ud.buildSpeed > 0
	local isMobile = ud.speed > 0.2
	if canBuild then
		Spring.Echo("[Autoexpand]: UnitDef " .. ud.name .. ": " .. tostring(isMobile) .. ", " .. tostring(ud.canAssist))
	end
	if isMobile and canBuild and ud.canAssist then
		local commander = cp and (cp.level ~= nil or cp.is_commander ~= nil or cp.commtype ~= nil)
		if not commander then -- commanders do not get autoexpand state because these should be player controlled units.
			Spring.Echo("[Autoexpand]: Adding " .. ud.name .. " to wanted list")
			wantedUnitDefs[i] = true
		end
	end
	if cp and cp.ismex then
		mexDefs[i] = true
		mexDefIDs[#mexDefIDs + 1] = i
	end
end

local autoExpandCMD = {
	id      = CMD_AUTOEXPAND,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Autoexpansion',
	action  = 'autoexpand',
	tooltip    = 'Toggles Autoexpand',
	params     = {0, 'Off','On'}
}

-- wind --
local windMin, windMax, windGroundMin, windGroundSlope, windMinBound, tidalHeight
local windInitialized = false

-- Includes --
VFS.Include("LuaRules/Configs/cai/accessory/targetReachableTester.lua")
include("LuaRules/Configs/constants.lua") -- mainly for HIDDEN_STORAGE
-- speedups --
local spGetGameRulesParam = Spring.GetGameRulesParam

local function GetMexSpotsFromGameRules()
	local mexCount = spGetGameRulesParam("mex_count")
	if (not mexCount) or mexCount == -1 then
		return {}
	end
	local incomeCount = 0
	local metalSpots = {}
	for i = 1, mexCount do
		metalSpots[i] = {
			x = spGetGameRulesParam("mex_x" .. i),
			y = spGetGameRulesParam("mex_y" .. i),
			z = spGetGameRulesParam("mex_z" .. i),
			metal = spGetGameRulesParam("mex_metal" .. i),
			claimedByAllyTeam = -1,
			mexID = -1, -- track mex
			claimants = {}, -- track unitIDs expanding to this.
		}
		incomeCount = incomeCount + spGetGameRulesParam("mex_metal" .. i)
	end
	averageIncome = incomeCount / mexCount
	return metalSpots
end

local function InitializeWindParameters()
	windMin = spGetGameRulesParam("WindMin")
	windMax = spGetGameRulesParam("WindMax")
	windGroundMin = spGetGameRulesParam("WindGroundMin")
	windGroundSlope = spGetGameRulesParam("WindSlope")
	windMinBound = spGetGameRulesParam("WindMinBound")
	tidalHeight = Spring.GetGameRulesParam("tidalHeight")
end

local function Distance(x1, y1, x2, y2)
	return math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))
end

local function GetGridPreplacementPoint(radius, x, z, targetx, targetz)
	local dx = targetx - x
	local dz = targetz - z
	local mag = 1 / math.sqrt((dx * dx) + (dz * dz))
	local tx = x + (radius * dx * mag)
	local tz = z + (radius * dz * mag)
	return tx, tz
end

local function CanUnitBePlacedHere(unitDefID, x, y, z, facing, checkForFeature)
	local blocking, feature = Spring.TestBuildOrder(unitDefID, x, y, z, facing)
	if checkForFeature then
		return blocking == 3 -- Recoil engine now has 3 for "free", 2 for "blocked by feature"
	else
		return blocking > 1
	end
end

local function GetClosestValidConstructionSpot(x, z, unitDefID, facing, magMax, radius)
	magMax = magMax or 8
	radius = radius or 16 -- 1x1 grid size
	local canBePlacedHere = false
	local mag = 1
	local spiralChangeNumber = 1
	local movesLeft = 1
	local dir = 1 -- 1: right, 2: up, 3: left, 4 down
	local nx, ny, nz
	local offsetX, offsetZ = 0, 0
	local aborted = false
	repeat -- 1 right, 1 up, 2 left, 2 down, 3 right, 3 up
		nx = x + offsetX
		nz = z + offsetZ
		ny = Spring.GetGroundHeight(nx, nz)
		canBePlacedHere = CanUnitBePlacedHere(unitDefID, nx, ny, nz, facing, false)
		if canBePlacedHere then
			return nx, ny, nz
		end
		if movesLeft == 0 and not (mag == magMax and movesLeft == 0 and dir == 4) then 
			spiralChangeNumber = spiralChangeNumber + 1
			if spiralChangeNumber%3 == 0 then 
				mag = mag + 1
			end
			movesLeft = mag
			dir = dir%4 + 1
		elseif mag == magMax and movesLeft == 0 and dir == 4 then -- abort
			aborted = true 
		else -- move to the next offset
			if dir == 1 then
				offsetX = offsetX + radius
			elseif dir == 2 then
				offsetZ = offsetZ + radius
			elseif dir == 3 then
				offsetX = offsetX - radius
			elseif dir == 4 then
				offsetZ = offsetZ - radius
			end
			movesLeft = movesLeft - 1
		end
	until canBePlacedHere or aborted
	return x, Spring.GetGroundHeight(x, z), z -- aborted, return original position.
end

local function CalculateWindIncome(x, z)
	if not windInitialized then
		InitializeWindParameters()
		windInitialized = true
	end
	local y = Spring.GetGroundHeight(x, z)
	if y then
		if y <= tidalHeight then
			return energyDefs[3].energy
		elseif windInitialized and windMin then
			local windBound = windGroundSlope*(y - windGroundMin)
			if windBound > windMinBound then -- optimize by removing math.min and math.max, this speeds things up significantly.
				windBound = windMinBound
			end
			if windBound < 0 then windBound = 0 end
			local minWindIncome = windMin + (windMax - windMin) * windBound
			return (minWindIncome + windMax)/2
		elseif windInitialized and not windMin then -- no wind
			return 0
		end
	end
end

local function CalculateWindAverage(x, z, magMax)
	local radius = 32
	local validPlacements = {}
	local canBePlacedHere = false
	local mag = 1
	local spiralChangeNumber = 1
	local movesLeft = 1
	local dir = 1 -- 1: right, 2: up, 3: left, 4 down
	local nx, ny, nz
	local offsetX, offsetZ = 0, 0
	local aborted = false
	local facing = 2 -- does not matter.
	local windDef = UnitDefNames["energywind"].id
	local total = 0
	local numberOfPlacements = 0
	local validLocations = {}
	Spring.Echo("WindDef is " .. windDef)
	repeat -- 1 right, 1 up, 2 left, 2 down, 3 right, 3 up
		nx = x + offsetX
		nz = z + offsetZ
		ny = Spring.GetGroundHeight(nx, nz)
		canBePlacedHere = CanUnitBePlacedHere(windDef, nx, ny, nz, facing, false)
		if canBePlacedHere then
			local income = CalculateWindIncome(nx, nz)
			--Spring.MarkerAddPoint(nx, ny, nz, income, true)
			validLocations[#validLocations + 1] = {nx, ny, nz}
			numberOfPlacements = numberOfPlacements + 1
			total = total + CalculateWindIncome(nx, nz)
			--Spring.Echo("Wind valid! " .. numberOfPlacements .. ", " .. total)
		else
			--Spring.MarkerAddPoint(nx, ny, nz, "InvalidWindPosition", true)
		end
		if movesLeft == 0 and not (mag == magMax and movesLeft == 0 and dir == 4) then 
			spiralChangeNumber = spiralChangeNumber + 1
			if spiralChangeNumber%3 == 0 then 
				mag = mag + 1
			end
			movesLeft = mag
			dir = dir%4 + 1
		elseif mag == magMax and movesLeft == 0 and dir == 4 then -- abort
			aborted = true 
		else -- move to the next offset
			if dir == 1 then
				offsetX = offsetX + radius
			elseif dir == 2 then
				offsetZ = offsetZ + radius
			elseif dir == 3 then
				offsetX = offsetX - radius
			elseif dir == 4 then
				offsetZ = offsetZ - radius
			end
			movesLeft = movesLeft - 1
		end
	until aborted
	Spring.Echo("Wind average: " .. total / numberOfPlacements .. ", " .. total .. ", " .. numberOfPlacements)
	return validLocations, total / numberOfPlacements
end

local function GetStorageRatio(currentLevel, storage)
	storage = storage - HIDDEN_STORAGE
	Spring.Echo("TeamStorage: " .. storage)
	return currentLevel / storage
end

local minStorage = 500
local minStorageRatio = 0.85

local function QuickEnergyCheck(teamID) -- done between energy builds
	local _, _, _, metalIncome = Spring.GetTeamResources(teamID, "metal")
	local currentLevel, storage, _, energyIncome = Spring.GetTeamResources(teamID, "energy")
	local energyStorageLevel = GetStorageRatio(currentLevel, storage)
	metalIncome = metalIncome + energyBuffer
	local netIncome = energyIncome - metalIncome
	Spring.Echo("[AutoExpand] QEC: Energy income: " .. netIncome)
	return netIncome < 0 and energyStorageLevel <= minStorageRatio and currentLevel < minStorage
end
	
local function CheckIfEnergyIsNeeded(x, z, metalProduction, teamID, data)
	local _, _, _, metalIncome = Spring.GetTeamResources(teamID, "metal")
	local currentLevel, storage, _, energyIncome = Spring.GetTeamResources(teamID, "energy")
	local energyStorageLevel = GetStorageRatio(currentLevel, storage)
	metalIncome = metalIncome + metalProduction + energyBuffer
	local netIncome = energyIncome - metalIncome
	Spring.Echo("[AutoExpand] CheckEnergy: Energy income: " .. netIncome .. "(" .. metalIncome .. ", " .. energyIncome .. ")")
	local validPlacements
	if netIncome < 0 and energyStorageLevel <= minStorageRatio and currentLevel < minStorage then -- needs energy
		local neededEnergy = metalIncome - energyIncome
		local selected = -1
		local lowestCost = 999999
		local needed = 9999
		Spring.Echo("[Autoexpand] Energy is too low! Amount: " .. neededEnergy .. "Checking for cheapest def...")
		for i = 1, #energyDefs do
			local def = energyDefs[i]
			local energy = energyDefs[i].energy
			if def.isWind then
				validPlacements, energy = CalculateWindAverage(x, z, 3)
				Spring.Echo("Wind average: " .. energy)
			end
			local numberNeeded = math.ceil(neededEnergy / energy)
			local approximatedCost = numberNeeded * def.cost
			Spring.Echo(UnitDefs[def.defID].name .. ": " .. approximatedCost)
			if approximatedCost < lowestCost then
				lowestCost = approximatedCost
				needed = numberNeeded
				selected = i
			end
		end
		if selected == -1 then return end
		data.wantedEnergy = {def = energyDefs[selected].defID, numberNeeded = needed}
		data.state = "energy"
		if selected == 3 then -- wind
			data.wantedEnergy.validPlacements = validPlacements -- cache the valid placements around the mex.
		else
			data.wantedEnergy.validPlacements = nil -- ensure that previous ones are killed off.
		end
	else
		return
	end
end

local function CheckUnitIsIdle(unitID) -- checks if a unit is idle.
	local cmdQueueCount = Spring.GetUnitCommandCount(unitID)
	if cmdQueueCount > 0 then return false end
	local transported = Spring.GetUnitTransporter(unitID)
	return transported == nil
end

local function IsKnownClaim(losMask)
	return spLosInfo.InLOS(losMask) or spLosInfo.InRadar(losMask) or spLosInfo.WasInLOS(losMask)
end

local function CalculateMexIncomeMult(income)
	local difference = averageIncome - income
	if difference < 0 then difference = -difference end -- turn it positive
	if difference < 0.2 then return 1 end
	local mult = averageIncome / income
	if mult < 0.1 then mult = 0.1 end
	return mult
end

local function EvaluateMex(unitID, unitSpeed, unitX, unitY, unitZ, spot)
	if spot then
		local x = spot.x
		local z = spot.z
		local result = IsTargetReallyReachable(unitID, x, spot.y, z, unitX, unitY, unitZ)
		if result then
			local income = spot.metal
			if income == 0 then
				Spring.Echo("No income")
				return 9999999 
			end
			local incomeMult = CalculateMexIncomeMult(income)
			local distance = Distance(x, z, unitX, unitZ)
			local estimatedTimeToArrival = distance / unitSpeed -- in seconds
			local arrivalTimeMult = estimatedTimeToArrival * 10 -- in terms of how many mexes could be built in this time. Calculated by average bp (7.5) divided by mex cost (75). This makes distant supermexes less worthwhile compared to nearby mexes.
			if arrivalTimeMult < 0.1 then arrivalTimeMult = 0.1 end
			--Spring.Echo("EvaluateMex: " .. distance .. ", ArrivalTime: " .. arrivalTimeMult .. ", IncomeMult: " .. incomeMult)
			return distance * incomeMult * arrivalTimeMult
		else
			if Distance(unitX, unitZ, x, z) <= 120 then -- unreachable because of "low distance".	
				return 0
			else -- actually might be unreachable
				Spring.Echo("Target Unreachable")
				return 9999999
			end
		end
	end
	return 9999999
end

local debugPathing = true

local function AreTheseMexesTheSame(x1, z1, x2, z2)
	local xDiff = x1 - x2
	local zDiff = z1 - z2
	if xDiff < 0 then xDiff = -xDiff end
	if zDiff < 0 then zDiff = -zDiff end
	if xDiff < 16 and zDiff < 16 then -- this is the correct spot or at least probably the right one.
		return true
	end
	return false
end

local function DivertCon(unitID, mexID)
	local orderCount = Spring.GetUnitCommandCount(unitID)
	if orderCount == 1 then
		Spring.Echo("[AutoExpand]::DivertCon: One order only. Stopping.")
		Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, 0)
		Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, 0)
		IterableMap.Add(forceupdatecons, unitID, true)
	else
		local mexDefID = mexDefIDs[1]
		local spot = metalSpots[mexID]
		local wantedX = spot.x
		local wantedY = spot.y
		local wantedZ = spot.z
		local commandQueue = Spring.GetUnitCommands(unitID, 10)
		local removed = false
		local newQueue = {}
		for i = 1, #commandQueue do
			local cmd = commandQueue[i]
			Spring.Echo(cmd.id)
			local params = cmd.params
			if cmd.id == mexDefID then
				local params = cmd.params
				if params and params[1] and params[3] and not AreTheseMexesTheSame(params[1], params[3], wantedX, wantedZ) then
					newQueue[#newQueue + 1] = {cmd.id, cmd.params, 0}
				end
			else
				newQueue[#newQueue + 1] = {cmd.id, cmd.params, 0}
			end
			if i == #commandQueue and #newQueue == #commandQueue then -- this is so far down the queue that it doesn't matter.
				Spring.Echo("[AutoExpand]::DivertCon: Unable to find mex order. Not removed!")
				return
			end
			Spring.GiveOrderArrayToUnitArray({unitID}, newQueue)
		end
	end
	IterableMap.Add(forceupdatecons, unitID, true)
end

local function GetNearestUnclaimedMexToUnit(unitID, data)
	local lastMexID = data.lastMexID or -1
	local lowestDist = 9999999
	local selectedID = -1
	local allyTeam = Spring.GetUnitAllyTeam(unitID)
	local x, y, z = Spring.GetUnitPosition(unitID)
	local speed = UnitDefs[Spring.GetUnitDefID(unitID)].speed
	for i = 1, #metalSpots do
		local spot = metalSpots[i]
		local claimed = false
		local potentiallyClaimed = false
		if spot.claimedByAllyTeam ~= -1 then -- this is a potentially claimed mex
			if allyTeam == spot.claimedByAllyTeam then 
				claimed = true
			elseif IsKnownClaim(Spring.GetUnitLosState(spot.mexID, allyTeam, true)) then
				claimed = true
			else
				claimed = false
			end
		elseif spot.claimants[allyTeam] and spot.claimants[allyTeam] ~= -1 then
			potentiallyClaimed = true
		end
		local dist = EvaluateMex(unitID, speed, x, y, z, spot)
		if not claimed and potentiallyClaimed then
			local con2 = spot.claimants[allyTeam]
			local x2, y2, z2 = Spring.GetUnitPosition(con2)
			local con2Dist = EvaluateMex(con2, UnitDefs[Spring.GetUnitDefID(con2)].speed, x2, y2, z2, spot)
			local data2 = IterableMap.Get(handled, con2)
			Spring.Echo("[DivertCon]: " .. con2Dist .. ", " .. dist .. ", building: " .. tostring(data2.currentlyBuilding == i))
			local currentlyBuilding = data2.currentlyBuilding or -1
			if con2Dist <= dist or currentlyBuilding == i then
				Spring.Echo("No diversion.")
				claimed = true
			end
		end	
		if not claimed then
			local dist = EvaluateMex(unitID, speed, x, y, z, spot)
			--[[if debugPathing then
				Spring.MarkerAddPoint(spot.x, 1, spot.z, "val: " .. dist .. "[Raw: " .. Distance(x, z, spot.x, spot.z) .. "]", true)
			end]]
			if dist < lowestDist then
				selectedID = i
				lowestDist = dist
			end
			if dist < 150 then -- this mex is very close, there's no point in searching more mexes.
				selectedID = i
				lowestDist = dist
				break
			end
		end
	end
	if selectedID ~= -1 then
		data.state = "expanding"
		data.target = selectedID
		local selectedSpot = metalSpots[selectedID]
		if selectedSpot.claimants[allyTeam] and selectedSpot.claimants[allyTeam] ~= -1 then
			Spring.Echo("Diverting con " .. selectedSpot.claimants[allyTeam])
			DivertCon(selectedSpot.claimants[allyTeam], selectedID)
		end
		selectedSpot.claimants[allyTeam] = unitID
		if debugPathing then
			Spring.MarkerAddLine(x, y, z, selectedSpot.x, selectedSpot.y, selectedSpot.z)
		end
		return selectedSpot.x, selectedSpot.z
	end
end

function gadget:Initialize()
	metalSpots = GetMexSpotsFromGameRules()
	if #metalSpots == 0 then
		wantedUnitDefs = {} -- throw out, we're not adding autoexpand to any unit.
		mexDefs = {} -- clear these too.
		Spring.Echo("[Autoexpansion] Removed gadget due to metal map! No metal spots detected!")
		gadgetHandler:RemoveGadget()
	end
end

local function FindMexSpot(x, z)
	for i = 1, #metalSpots do
		local spot = metalSpots[i]
		if spot.mexID == -1 then -- if it isn't -1, it's already claimed and we're wasting cycles on checking because 1 mex 1 spot.
			if AreTheseMexesTheSame(x, z, spot.x, spot.z) then
				return i
			end
		end
	end
end

local function QueueEnergyForUnit(unitID, data, wantedX, wantedZ)
	local wantedEnergy = data.wantedEnergy
	if wantedEnergy then
		if wantedEnergy.numberNeeded > 0 then
			local validPlacements = wantedEnergy.validPlacements
			if validPlacements then
				local placement = validPlacements[#validPlacements]
				Spring.GiveOrderToUnit(unitID, -wantedEnergy.def, {placement[1], placement[2], placement[3]}, 0)
				validPlacements[#validPlacements] = nil
			else
				local x, y, z = GetClosestValidConstructionSpot(wantedX, wantedZ, wantedEnergy.def, 1, 4)
				if x then
					Spring.GiveOrderToUnit(unitID, -wantedEnergy.def, {x, y, z}, CMD.OPT_SHIFT)
				end
			end
		end
	end
end

local function StartNewExpansion(unitID, data, forceRemoval)
	local x, z = GetNearestUnclaimedMexToUnit(unitID, data)
	data.state = "expanding"
	if x then
		if forceRemoval then
			local commandQueue = Spring.GetUnitCommandCount(unitID)
			if commandQueue == 1 then
				Spring.GiveOrderToUnit(unitID, -mexDefIDs[1], {x, Spring.GetGroundHeight(x, z), z}, 0)
			else
				Spring.GiveOrderToUnit(unitID, -mexDefIDs[1], {x, Spring.GetGroundHeight(x, z), z}, CMD.OPT_SHIFT)
			end
		else
			Spring.GiveOrderToUnit(unitID, -mexDefIDs[1], {x, Spring.GetGroundHeight(x, z), z}, CMD.OPT_SHIFT)
		end
	end
end

local function UpdateConsTryingToExpand(mexSpotID, claimedAllyTeam)
	local spot = metalSpots[mexSpotID]
	local claimant = spot.claimants[claimedAllyTeam] or -1
	for allyTeamID, unitID in pairs(spot.claimants) do
		if allyTeamID ~= claimedAllyTeam then
			local losState = Spring.GetUnitLosState(spot.mexID, allyTeamID)
			if IsKnownClaim(losState) then
				local x, _, z = Spring.GetUnitPosition(unitID)
				--[[if spLosInfo.IsInLOS(losState) and Distance(x, z, spot.x, spot.z) < 300 and spot.mexID then
					Spring.GiveOrderToUnit(unitID, CMD.RECLAIM, {spot.mexID}, 0) -- go fuck with the enemy constructor.
				else
					Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, 0) -- order this unit to stop. This will force an update next check cycle.
				end]]
				Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, 0)
				local data = IterableMap.Get(handled, unitID)
				if data then
					StartNewExpansion(unitID, data)
				end
			end
		end
		spot.claimants[allyTeamID] = -1
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if wantedUnitDefs[unitDefID] then
		-- add command
		Spring.Echo("Adding command to unitID " .. unitID)
		Spring.InsertUnitCmdDesc(unitID, 123456, autoExpandCMD)
	elseif mexDefs[unitDefID] then
		local allyTeam = Spring.GetUnitAllyTeam(unitID)
		local mexID
		local data
		if builderID then
			data = IterableMap.Get(handled, builderID)
		end
		if data then -- this is probably a mex we're autoexpanding to.
			mexID = data.target
			data.state = "building"
			data.currentlyBuilding = mexID
		else -- not a mex we're expanding to
			local x, _, z = Spring.GetUnitPosition(unitID)
			mexID = FindMexSpot(x, z)
		end
		local spot = metalSpots[mexID]
		mexToSpotID[unitID] = mexID
		spot.mexID = unitID
		spot.claimedByAllyTeam = allyTeam
		UpdateConsTryingToExpand(mexID, Spring.GetUnitAllyTeam(unitID))
		if builderID then
			if data and QuickEnergyCheck(unitTeam) then
				CheckIfEnergyIsNeeded(spot.x, spot.z, spot.metal, Spring.GetUnitTeam(builderID), data)
				QueueEnergyForUnit(builderID, data, spot.x, spot.z)
			elseif data then
				StartNewExpansion(builderID, data)
			end
		end
	elseif watchedEnergyDefs[unitDefID] and IterableMap.InMap(handled, builderID) then
		local data = IterableMap.Get(handled, builderID)
		local wantedEnergy = data.wantedEnergy
		wantedEnergy.numberNeeded = wantedEnergy.numberNeeded - 1
		if QuickEnergyCheck(unitTeam) then
			local targetX, targetZ
			if data.target then
				targetX = metalSpots[data.target].x
				targetZ = metalSpots[data.target].z
			else
				targetX, _, targetZ = Spring.GetUnitPosition(builderID)
			end
			QueueEnergyForUnit(builderID, data, targetX, targetZ)
		else -- energy conditions have changed, update plan accordingly.
			data.wantedEnergy.numberNeeded = 0
			data.wantedEnergy.validPlacements = nil
		end
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if mexDefs[unitDefID] then
		local allyTeam = Spring.GetUnitAllyTeam(unitID)
		local spot, mexID
		if mexToSpotID[unitID] then
			spot = metalSpots[mexToSpotID[unitID]]
			mexID = mexToSpotID[unitID]
		else
			local allyTeam = Spring.GetUnitAllyTeam(unitID)
			local x, _, z = Spring.GetUnitPosition(unitID)
			mexID = FindMexSpot(x, z)
			spot = metalSpots[mexID]
			mexToSpotID[unitID] = mexID
			spot.mexID = unitID
		end
		spot.claimedByAllyTeam = allyTeam
		local builderID = spot.claimants[allyTeam] or -1
		if builderID ~= -1 then
			local data = IterableMap.Get(handled, builderID)
			data.currentlyBuilding = nil
			data.state = "expanding"
			if data then
				QueueEnergyForUnit(builderID, data, spot.x, spot.z)
			end
		end
		UpdateConsTryingToExpand(mexID, Spring.GetUnitAllyTeam(unitID))
	end
end

local function RemoveExpander(allyTeamID, data)
	local spotID = data.target
	local spot = metalSpots[spotID]
	if not spot.mexID or spot.mexID == -1 then
		spot.claimants[allyTeamID] = -1
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	if mexToSpotID[unitID] then
		local spotID = mexToSpotID[unitID]
		mexToSpotID[unitID] = nil
		local spot = metalSpots[spotID]
		spot.claimedByAllyTeam = -1
		spot.mexID = -1
		spot.claimants = {} -- clear claimants.
	end
	if IterableMap.InMap(handled, unitID) then
		local data = IterableMap.Get(handled, unitID)
		RemoveExpander(Spring.GetUnitAllyTeam(unitID), data)
		IterableMap.Remove(handled, unitID)
	end
end

local function AddUnitToAutoexpand(unitID)
	local data = {
		state = "idle",
	}
	IterableMap.Add(handled, unitID, data)
	if CheckUnitIsIdle(unitID) then
		local teamID = Spring.GetUnitTeam(unitID)
		if QuickEnergyCheck(teamID) then
			local x, _, z = Spring.GetUnitPosition(unitID)
			CheckIfEnergyIsNeeded(x, z, 0, teamID, data)
		else
			StartNewExpansion(unitID, data)
		end
	end
end

local function RemoveUnitFromAutoexpansion(unitID)
	local data = IterableMap.Get(handled, unitID)
	local allyTeam = Spring.GetUnitAllyTeam(unitID)
	RemoveExpander(allyTeam, data)
	IterableMap.Remove(handled, unitID)
end

local function ToggleCommand(unitID, cmdParams)
	Spring.Echo("ToggleCommand")
	local def = Spring.GetUnitDefID(unitID)
	if wantedUnitDefs[def] then
		local state = cmdParams[1]
		Spring.Echo("New State: " .. state)
		local cmdDescID = Spring.FindUnitCmdDesc(unitID, CMD_AUTOEXPAND)
		if (cmdDescID) then
			autoExpandCMD.params[1] = state
			Spring.EditUnitCmdDesc(unitID, cmdDescID, { params = autoExpandCMD.params})
			if state == 1 and not IterableMap.InMap(handled, unitID) then -- on
				AddUnitToAutoexpand(unitID)
			elseif state == 0 then -- off
				RemoveUnitFromAutoexpansion(unitID)
			end
			autoExpandCMD.params[1] = 0
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	ToggleCommand(unitID, cmdParams)
	return false
end

function gadget:AllowCommand_GetWantedCommand()
	return {[CMD_AUTOEXPAND] = true}
end

function gadget:UnitCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOpts, cmdTag)
	if stateCommands[cmdID] or not wantedUnitDefs[unitDefID] then return end
	if IterableMap.InMap(handled, unitID) and not cmdOpts.shift then
		local data = IterableMap.Get(handled, unitID)
		if data.target then
			local spot = metalSpots[data.target]
			local allyTeam = Spring.GetUnitAllyTeam(unitID)
			if (not spot.mexID) or spot.mexID == -1 then
				spot.claimants[allyTeam] = nil
			end
		end
	end
end

function gadget:GameFrame(f)
	for unitID, _ in IterableMap.Iterator(forceupdatecons) do
		IterableMap.Remove(forceupdatecons, unitID)
		local data = IterableMap.Get(handled, unitID)
		StartNewExpansion(unitID, data, true)
	end
	if f%45 == 35 then -- Check for idle cons every so often to ensure they're doing their part for MANAGED DEMOCRACY.
		Spring.Echo("[autoexpand]: Checking cons " .. f)
		for unitID, data in IterableMap.Iterator(handled) do
			if CheckUnitIsIdle(unitID) then
				local teamID = Spring.GetUnitTeam(unitID)
				if QuickEnergyCheck(teamID) then
					local x, _, z = Spring.GetUnitPosition(unitID)
					CheckIfEnergyIsNeeded(x, z, 0, teamID, data)
					QueueEnergyForUnit(unitID, data, x, z)
				else
					StartNewExpansion(unitID, data)
				end
			end
		end
	end
end

