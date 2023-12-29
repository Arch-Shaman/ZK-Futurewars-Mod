--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if not gadgetHandler:IsSyncedCode() then
	return
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Carrier Drones",
		desc      = "Spawns drones for aircraft carriers",
		author    = "TheFatConroller, modified by KingRaptor",
		date      = "12.01.2008",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end
--Version 1.003
--Changelog:
--24/6/2014 added carrier building drone on emit point.

--around 1/1/2017: added hold fire functionality, recall drones button, circular drone leash, drones pay attention to set target
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include("LuaRules/Configs/customcmds.h.lua")

local AddUnitDamage       = Spring.AddUnitDamage
local CreateUnit          = Spring.CreateUnit
local GetCommandQueue     = Spring.GetCommandQueue
local spGetUnitDirection  = Spring.GetUnitDirection
local GetUnitIsStunned    = Spring.GetUnitIsStunned
local GetUnitPieceMap     = Spring.GetUnitPieceMap
local spGetUnitPiecePosDir = Spring.GetUnitPiecePosDir
local spGetUnitPosition   = Spring.GetUnitPosition
local GiveOrderToUnit     = Spring.GiveOrderToUnit
local SetUnitPosition     = Spring.SetUnitPosition
local SetUnitNoSelect     = Spring.SetUnitNoSelect
local spGetUnitHealth     = Spring.GetUnitHealth
local spSetUnitHealth     = Spring.SetUnitHealth
local TransferUnit        = Spring.TransferUnit
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetGameFrame      = Spring.GetGameFrame
local spGetUnitVelocity   = Spring.GetUnitVelocity
local spGetUnitSeparation = Spring.GetUnitSeparation
local spGetUnitTeam       = Spring.GetUnitTeam
local spIsUnitInLos       = Spring.IsUnitInLos
local spIsUnitInRadar     = Spring.IsUnitInRadar
local spGetUnitAllyTeam   = Spring.GetUnitAllyTeam
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spValidUnitID       = Spring.ValidUnitID
local spDestroyUnit       = Spring.DestroyUnit
local spEcho              = Spring.Echo
local random              = math.random
local CMD_ATTACK          = CMD.ATTACK

local emptyTable = {}
local ALLIED_ACCESS = {allied = true}
local INLOS_ACCESS = {inlos = true}

-- thingsWhichAreDrones is an optimisation for AllowCommand, no longer used but it'll stay here for now
local carrierDefs, thingsWhichAreDrones, unitRulesCarrierDefs, droneLaunchDefs = include "LuaRules/Configs/drone_defs.lua"

local DEFAULT_UPDATE_ORDER_FREQUENCY = 40 -- gameframes
local IDLE_DISTANCE = 120
local ACTIVE_DISTANCE = 180
local DRONE_HEIGHT = 120
local RECALL_TIMEOUT = 300

local TARGET_GROUND     = string.byte('g')
local TARGET_UNIT       = string.byte('u')
local TARGET_FEATURE    = string.byte('f')
local TARGET_PROJECTILE = string.byte('p')

local generateDrones = {}
local carrierList = {}
local droneList = {}
local drones_to_move = {}
local killList = {}
local recall_frame_start = {}
local droneLaunchesQueued = {}

local GiveClampedOrderToUnit = Spring.Utilities.GiveClampedOrderToUnit

local supportCommanderDroneSpawnTable = {
	[1] = {'drone6'},
	[2] = {'drone6', 'drone1'},
	[3] = {'drone6', 'drone1', 'drone2'},
	[4] = {'drone6', 'drone1', 'drone2', 'drone5'},
	[5] = {'drone6', 'drone1', 'drone2', 'drone5', 'drone4'},
	[6] = {'drone6', 'drone1', 'drone2', 'drone5', 'drone4', 'drone3'},
}

local recallDronesCmdDesc = {
	id      = CMD_RECALL_DRONES,
	type    = CMDTYPE.ICON,
	name    = 'Recall Drones',
	cursor  = 'Load units',
	action  = 'recalldrones',
	tooltip = 'Recall Drones: Return controlled drones to the host unit.',
}

local toggleDronesCmdDesc = {
	id      = CMD_TOGGLE_DRONES,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Drone Generation',
	cursor  = 'Load units',
	action  = 'toggledrones',
	tooltip = 'Toggle drone creation.',
	params  = {1, 'Disabled','Enabled'}
}

local droneSetTargetCmdDesc = {
	id      = CMD_DRONE_SET_TARGET,
	type    = CMDTYPE.ICON_UNIT_OR_MAP,
	name    = 'Set Drone Target',
	action  = 'dronesettarget',
	cursor  = 'DroneSetTarget',
	tooltip = 'Set Drone Target: Set a priority target for drones that is independent of the units command queue.',
	texture = "LuaUI/Images/Commands/Bold/missile.png",
}
local toggleParams = {params = {1, 'Disabled','Enabled'}}

for weaponID, _ in pairs(droneLaunchDefs) do
	Script.SetWatchWeapon(weaponID, true)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function RandomPointInUnitCircle()
	local angle = random(0, 2*math.pi)
	local distance = math.pow(random(0, 1), 0.5)
	return math.cos(angle)*distance, math.sin(angle)*distance
end

-- Don't call this, call the following 2 functions instead
local function ChangeDroneRulesParam(unitID, diff)
	local count = spGetUnitRulesParam(unitID, "dronesControlled") or 0
	count = count + diff
	spSetUnitRulesParam(unitID, "dronesControlled", count, INLOS_ACCESS)
end

local function UpdatePrioTargetRulesParam(unitID)
	local priorityTarget = carrierList[unitID].priorityTarget
	if not priorityTarget then
		spSetUnitRulesParam(unitID, "drone_target_type", 0, ALLIED_ACCESS)
	elseif priorityTarget.x then
		spSetUnitRulesParam(unitID, "drone_target_type", 1, ALLIED_ACCESS)
		spSetUnitRulesParam(unitID, "drone_target_x", priorityTarget.x, ALLIED_ACCESS)
		spSetUnitRulesParam(unitID, "drone_target_y", priorityTarget.y, ALLIED_ACCESS)
		spSetUnitRulesParam(unitID, "drone_target_z", priorityTarget.z, ALLIED_ACCESS)
	elseif priorityTarget.unitID then
		spSetUnitRulesParam(unitID, "drone_target_type", 2, ALLIED_ACCESS)
		spSetUnitRulesParam(unitID, "drone_target_id", priorityTarget.unitID, ALLIED_ACCESS)
	end
end

local function InitCarrier(unitID, carrierData, teamID, maxDronesOverride)
	local toReturn  = {teamID = teamID, droneSets = {}, occupiedPieces={}, droneInQueue= {}, droneListRulesParam = {}}
	local unitPieces = GetUnitPieceMap(unitID)
	local usedPieces = carrierData.spawnPieces
	if usedPieces then
		toReturn.spawnPieces = {}
		for i = 1, #usedPieces do
			toReturn.spawnPieces[i] = unitPieces[usedPieces[i]]
		end
		toReturn.pieceIndex = 1
	end
	local maxDronesTotal = 0
	for i = 1, #carrierData do
		-- toReturn.droneSets[i] = Spring.Utilities.CopyTable(carrierData[i])
		toReturn.droneSets[i] = {nil}
		--same as above, but we assign reference to "carrierDefs[i]" table in memory to avoid duplicates, DO NOT CHANGE ITS CONTENT (its constant & config value only).
		toReturn.droneSets[i].config = carrierData[i]
		toReturn.droneSets[i].maxDrones = (maxDronesOverride and maxDronesOverride[i]) or carrierData[i].maxDrones
		maxDronesTotal = maxDronesTotal + toReturn.droneSets[i].maxDrones
		toReturn.droneSets[i].reload = carrierData[i].reloadTime
		toReturn.droneSets[i].droneCount = 0
		toReturn.droneSets[i].drones = {}
		toReturn.droneSets[i].buildCount = 0
		toReturn.droneSets[i].queueCount = 0
	end
	if maxDronesTotal > 0 then
		spSetUnitRulesParam(unitID, "dronesControlled", 0, INLOS_ACCESS)
		spSetUnitRulesParam(unitID, "dronesControlledMax", maxDronesTotal, INLOS_ACCESS)
	end
	return toReturn
end

local function CreateCarrier(unitID, carrierData)
	Spring.InsertUnitCmdDesc(unitID, recallDronesCmdDesc)
	Spring.InsertUnitCmdDesc(unitID, toggleDronesCmdDesc)
	Spring.InsertUnitCmdDesc(unitID, droneSetTargetCmdDesc)
	generateDrones[unitID] = true
end

local function Drones_InitializeDynamicCarrier(unitID)
	if carrierList[unitID] then
		return
	end
	
	local carrierData = {}
	local maxDronesOverride = {}
	local hasDrones = false
	for name, data in pairs(unitRulesCarrierDefs) do
		local drones = Spring.GetUnitRulesParam(unitID, "carrier_count_" .. name)
		if drones then
			carrierData[#carrierData + 1] = data
			maxDronesOverride[#maxDronesOverride + 1] = drones
			hasDrones = true
		end
	end
	local droneSlots = Spring.GetUnitRulesParam(unitID, "comm_extra_drones") or 1
	local isSupportComm = tonumber(UnitDefs[Spring.GetUnitDefID(unitID)].customParams.commtype) or 0 == 4
	if isSupportComm then
		carrierData.spawnPieces = supportCommanderDroneSpawnTable[droneSlots]
	end
	if hasDrones then
		CreateCarrier(unitID, carrierData)
	end
	carrierList[unitID] = InitCarrier(unitID, carrierData, spGetUnitTeam(unitID), maxDronesOverride)
end

-- communicates to unitscript, copied from unit_float_toggle; should be extracted to utility
-- preferably that before i PR this
local function callScript(unitID, funcName, args)
	local func = Spring.UnitScript.GetScriptEnv(unitID)[funcName]
	if func then
		Spring.UnitScript.CallAsUnit(unitID, func, args)
	end
end

local function NewDrone(unitID, droneName, setNum, droneBuiltExternally, controllable)
	local carrierEntry = carrierList[unitID]
	local _, _, _, x, y, z = spGetUnitPosition(unitID, true)
	local xS, yS, zS = x, y, z
	local rot = 0
	local piece = nil
	if carrierEntry.spawnPieces and not droneBuiltExternally then
		local index = carrierEntry.pieceIndex
		piece = carrierEntry.spawnPieces[index];
		local px, py, pz, pdx, pdy, pdz = spGetUnitPiecePosDir(unitID, piece)
		xS, yS, zS = px, py, pz
		rot = Spring.GetHeadingFromVector(pdx, pdz)/65536*2*math.pi + math.pi
		
		index = index + 1
		if index > #carrierEntry.spawnPieces then
			index = 1
		end
		carrierEntry.pieceIndex = index
	else
		local angle = math.rad(random(1, 360))
		xS = (x + (math.sin(angle) * 20))
		zS = (z + (math.cos(angle) * 20))
		rot = angle
	end
	
	--Note: create unit argument: (unitDefID|unitDefName, x, y, z, facing, teamID, build, flattenGround, targetID, builderID)
	local droneID = CreateUnit(droneName, xS, yS, zS, 1, carrierList[unitID].teamID, droneBuiltExternally and true, false, nil, unitID)
	if droneID then
		spSetUnitRulesParam(droneID, "parent_unit_id", unitID)
		spSetUnitRulesParam(droneID, "drone_set_index", setNum)
		local droneSet = carrierEntry.droneSets[setNum]
		droneSet.droneCount = droneSet.droneCount + 1
		ChangeDroneRulesParam(unitID, 1)
		droneSet.drones[droneID] = true
		
		--SetUnitPosition(droneID, xS, zS, true)
		Spring.MoveCtrl.Enable(droneID)
		Spring.MoveCtrl.SetPosition(droneID, xS, yS, zS)
		Spring.MoveCtrl.Disable(droneID)
		Spring.SetUnitCOBValue(droneID, 82, (rot - math.pi)*65536/2/math.pi)

		local firestate = Spring.Utilities.GetUnitFireState(unitID)
		GiveOrderToUnit(droneID, CMD.MOVE_STATE, { 2 }, 0)
		GiveOrderToUnit(droneID, CMD.FIRE_STATE, { firestate }, 0)
		GiveOrderToUnit(droneID, CMD.IDLEMODE, { 0 }, 0)
		
		if not controllable then
			SetUnitNoSelect(droneID, true)
		end
		
		local rx, rz = RandomPointInUnitCircle()
		-- Drones intentionall use CMD.MOVE instead of CMD_RAW_MOVE as they do not require any of the features
		GiveClampedOrderToUnit(droneID, CMD.MOVE, {x + rx*IDLE_DISTANCE, y+DRONE_HEIGHT, z + rz*IDLE_DISTANCE}, 0, false, true)
		GiveOrderToUnit(droneID, CMD.GUARD, {unitID} , CMD.OPT_SHIFT)

		droneList[droneID] = {carrier = unitID, set = setNum, controllable = controllable}
	end
	return droneID, rot
end

--START OF----------------------------
--drone nanoframe attachment code:----

function AddUnitToEmptyPad(carrierID, droneType)
	local carrierData = carrierList[carrierID]
	local unitIDAdded
	local CheckCreateStart = function(pieceNum)
		if not carrierData.occupiedPieces[pieceNum] then -- Note: We could do a strict checking of empty space here (Spring.GetUnitInBox()) before spawning drone, but that require a loop to check if & when its empty.
			local droneDefID = carrierData.droneSets[droneType].config.drone
			local controllable = carrierData.droneSets[droneType].config.controllable or false
			unitIDAdded = NewDrone(carrierID, droneDefID, droneType, true, controllable)
			if unitIDAdded then
				local config = carrierData.droneSets[droneType].config
				local offsets = config.offsets
				SitOnPad(unitIDAdded, carrierID, pieceNum, config)
				carrierData.occupiedPieces[pieceNum] = true
				if config.colvolTweaked then --can be used to move collision volume away from carrier to avoid collision
					Spring.SetUnitMidAndAimPos(unitIDAdded, offsets.colvolMidX, offsets.colvolMidY, offsets.colvolMidZ, offsets.aimX, offsets.aimY, offsets.aimZ, true)
					--offset whole colvol & aim point (red dot) above the carrier (use /debugcolvol to check)
				end
				if config.untargetableOnPad then
					spSetUnitRulesParam(unitIDAdded, 'untargetable', 1)
				end
				return true
			end
		end
		return false
	end
	if carrierList[carrierID].spawnPieces then --have airpad or emit point
		for i=1, #carrierList[carrierID].spawnPieces do
			local pieceNum = carrierList[carrierID].spawnPieces[i]
			if CheckCreateStart(pieceNum) then
				--- notify carrier that it should start a drone building animation
				callScript(carrierID, "Carrier_droneStarted", pieceNum)
				break
			end
		end
	else
		CheckCreateStart(0) --use unit's body as emit point
	end
	return unitIDAdded
end

function GetCarrierFreePadsCount(carrierID)
	local carrierData = carrierList[carrierID]
	local currentIndex = carrierData.pieceIndex
	local length = #carrierData.spawnPieces
	local count = 0
	for i = 1, length do
		if not carrierData.occupiedPieces[carrierData.spawnPieces[i]] then
			count = count + 1
		end
	end
	return count
end

local coroutines = {}
local coroutineCount = 0
local coroutine = coroutine
local Sleep     = coroutine.yield
local assert    = assert
local function StartScript(fn)
	local co = coroutine.create(fn)
	coroutineCount = coroutineCount + 1 --in case new co-routine is added in same frame
	coroutines[coroutineCount] = co
end

function UpdateCoroutines()
	coroutineCount = #coroutines
	local i = 1
	while (i <= coroutineCount) do
		local co = coroutines[i]
		if (coroutine.status(co) ~= "dead") then
			assert(coroutine.resume(co))
			i = i + 1
		else
			coroutines[i] = coroutines[coroutineCount]
			coroutines[coroutineCount] = nil
			coroutineCount = coroutineCount - 1
		end
	end
end

local function GetPitchYawRoll(front, top) --This allow compatibility with Spring 91
	--NOTE:
	--angle measurement and direction setting is based on right-hand coordinate system, but Spring might rely on left-hand coordinate system.
	--So, input for math.sin and math.cos, or positive/negative sign, or math.atan2 might be swapped with respect to the usual whenever convenient.

	--1) Processing FRONT's vector to get Pitch and Yaw
	local x, y, z = front[1], front[2], front[3]
	local xz = math.sqrt(x*x + z*z) --hypothenus
	local yaw = math.atan2 (x/xz, z/xz) --So facing south is 0-radian, and west is negative radian, and east is positive radian
	local pitch = math.atan2 (y, xz) --So facing upward is positive radian, and downward is negative radian
	
	--2) Processing TOP's vector to get Roll
	x, y, z = top[1], top[2], top[3]
	--rotate coordinate around Y-axis until Yaw value is 0 (a reset)
	local newX = x* math.cos (-yaw) + z*  math.sin (-yaw)
	local newY = y
	local newZ = z* math.cos (-yaw) - x* math.sin (-yaw)
	x, y, z = newX, newY, newZ
	--rotate coordinate around X-axis until Pitch value is 0 (a reset)
	newX = x
	newY = y* math.cos (-pitch) + z* math.sin (-pitch)
	newZ = z* math.cos (-pitch) - y* math.sin (-pitch)
	x, y, z = newX, newY, newZ
	local roll =  math.atan2 (x, y) --So lifting right wing is positive radian, and lowering right wing is negative radian
	
	return pitch, yaw, roll
end

local function GetOffsetRotated(rx, ry, rz, front, top, right)
	local offX = front[1]*rz + top[1]*ry - right[1]*rx
	local offY = front[2]*rz + top[2]*ry - right[2]*rx
	local offZ = front[3]*rz + top[3]*ry - right[3]*rx
	return offX, offY, offZ
end

local HEADING_TO_RAD = (math.pi*2/2^16)
local RAD_TO_HEADING = 1/HEADING_TO_RAD
local PI = math.pi
local cos = math.cos
local sin = math.sin
local acos = math.acos
local floor = math.floor
local sqrt = math.sqrt
local exp = math.exp
local min = math.min

local mcSetVelocity         = Spring.MoveCtrl.SetVelocity
local mcSetPosition         = Spring.MoveCtrl.SetPosition
local mcSetRotation         = Spring.MoveCtrl.SetRotation
local mcDisable             = Spring.MoveCtrl.Disable
local mcEnable              = Spring.MoveCtrl.Enable

local function GetBuildRate(unitID)
	if not generateDrones[unitID] then
		return 0
	end
	local stunned_or_inbuild = GetUnitIsStunned(unitID) or (spGetUnitRulesParam(unitID, "disarmed") == 1)
	if stunned_or_inbuild then
		return 0
	end
	return spGetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1
end

function SitOnPad(unitID, carrierID, padPieceID, config)
	-- From unit_refuel_pad_handler.lua (author: GoogleFrog)
	-- South is 0 radians and increases counter-clockwise
	local offsets = config.offsets
	
	spSetUnitHealth(unitID, {build = 0})
	
	local GetPlacementPosition = function(inputID, pieceNum)
		if (pieceNum == 0) then
			local _, _, _, mx, my, mz = spGetUnitPosition(inputID, true)
			local dx, dy, dz = spGetUnitDirection(inputID)
			return mx, my, mz, dx, dy, dz
		else
			return spGetUnitPiecePosDir(inputID, pieceNum)
		end
	end
	
	local AddNextDroneFromQueue = function(inputID)
		local carrier = carrierList[inputID]
		local droneQueue = carrier.droneInQueue
		if #droneQueue > 0 then
			local droneSetID = droneQueue[1]
			if AddUnitToEmptyPad(inputID, droneSetID) then --pad cleared, immediately add any unit from queue
				local set = carrier.droneSets[droneSetID]
				set.buildCount = set.buildCount + 1
				set.queueCount = set.queueCount - 1
				table.remove(carrierList[inputID].droneInQueue, 1)
			end
		end
	end
	
	mcEnable(unitID)
	Spring.SetUnitLeaveTracks(unitID, false)
	Spring.SetUnitBlocking(unitID, false, false, true, true, false, true, false)
	mcSetVelocity(unitID, 0, 0, 0)
	mcSetPosition(unitID, GetPlacementPosition(carrierID, padPieceID))
	
	-- deactivate unit to cause the lups jets away
	Spring.SetUnitCOBValue(unitID, COB.ACTIVATION, 0)
	
	local function SitLoop()
		local previousDir, currentDir
		local pitch, yaw, roll
		local px, py, pz, dx, dy, dz, vx, vy, vz, offx, offy, offz
		-- local magnitude, newPadHeading
		
		if not droneList[unitID] then
			--droneList[unitID] became NIL when drone or carrier is destroyed (in UnitDestroyed()). Is NIL at beginning of frame and this piece of code run at end of frame
			if carrierList[carrierID] then
				droneInfo.buildCount = droneInfo.buildCount - 1
				carrierList[carrierID].occupiedPieces[padPieceID] = false
				AddNextDroneFromQueue(carrierID) --add next drone in this vacant position
				GG.StopMiscPriorityResourcing(carrierID, miscPriorityKey)
			end
			return --nothing else to do
		end
		
		local miscPriorityKey = "drone_" .. unitID
		local oldBuildRate = false
		local buildProgress, health
		local droneType = droneList[unitID].set
		local droneInfo = carrierList[carrierID].droneSets[droneType] --may persist even after "carrierList[carrierID]" is emptied
		local build_step = droneInfo.config.buildStep
		local build_step_health = droneInfo.config.buildStepHealth
		
		local buildStepCost = droneInfo.config.buildStepCost
		local perSecondCost = droneInfo.config.perSecondCost
		
		local resTable
		if buildStepCost then
			resTable = {
				m = buildStepCost,
				e = buildStepCost,
			}
		end

		local function Sit()
			if (droneList[unitID] and (not carrierList[carrierID])) then --carrierList[carrierID] is NIL because it was MORPHED.
				carrierID = droneList[unitID].carrier
				padPieceID = (carrierList[carrierID].spawnPieces and carrierList[carrierID].spawnPieces[1]) or 0
				carrierList[carrierID].occupiedPieces[padPieceID] = true --block pad
				oldBuildRate = false -- Update MiscPriority for morphed unit.
			end
			
			vx, vy, vz = spGetUnitVelocity(carrierID)
			px, py, pz, dx, dy, dz = GetPlacementPosition(carrierID, padPieceID)
			currentDir = dx + dy*100 + dz* 10000
			if previousDir ~= currentDir then --refresh pitch/yaw/roll calculation when unit had slight turning
				previousDir = currentDir
				front, top, right = Spring.GetUnitVectors(carrierID)
				pitch, yaw, roll = GetPitchYawRoll(front, top)
				offx, offy, offz = GetOffsetRotated(offsets[1], offsets[2], offsets[3], front, top, right)
			end
			mcSetVelocity(unitID, vx, vy, vz)
			mcSetPosition(unitID, px + vx + offx, py + vy + offy, pz + vz + offz)
			mcSetRotation(unitID, pitch, -yaw, roll) --Spring conveniently rotate Y-axis first, X-axis 2nd, and Z-axis 3rd which allow Yaw, Pitch & Roll control.
		end
		
		while true do
			if (not droneList[unitID]) then
				--droneList[unitID] became NIL when drone or carrier is destroyed (in UnitDestroyed()). Is NIL at beginning of frame and this piece of code run at end of frame
				if carrierList[carrierID] then
					droneInfo.buildCount = droneInfo.buildCount - 1
					carrierList[carrierID].occupiedPieces[padPieceID] = false
					AddNextDroneFromQueue(carrierID) --add next drone in this vacant position
					GG.StopMiscPriorityResourcing(carrierID, miscPriorityKey)
				end
				return true
			end
			
			Sit()
			if DroneGone then return end
			
			local buildRate = GetBuildRate(carrierID)
			local buildratemod = spGetUnitRulesParam(carrierID, "comm_drone_buildrate") or 1
			buildRate = buildRate * buildratemod
			if perSecondCost and oldBuildRate ~= buildRate then
				oldBuildRate = buildRate
				GG.StartMiscPriorityResourcing(carrierID, perSecondCost*buildRate, false, miscPriorityKey)
				resTable.m = buildStepCost*buildRate
				resTable.e = buildStepCost*buildRate
			end
			
			-- Check if the change can be carried out
			if (buildRate > 0) and ((not perSecondCost) or (GG.AllowMiscPriorityBuildStep(carrierID, spGetUnitTeam(carrierID), false, resTable) and Spring.UseUnitResource(carrierID, resTable))) then
				health, _, _, _, buildProgress = spGetUnitHealth(unitID)
				buildProgress = buildProgress + (build_step*buildRate) --progress
				spSetUnitHealth(unitID, {health = health + (build_step_health*buildRate), build = buildProgress})
				if buildProgress >= 1 then
					callScript(carrierID, "Carrier_droneCompleted", padPieceID)
					break
				end
			end
			
			Sleep()
		end
		
		GG.StopMiscPriorityResourcing(carrierID, miscPriorityKey)
		
		droneInfo.buildCount = droneInfo.buildCount - 1

		if config.sitsOnPad then
			while true do
				if (not droneList[unitID]) then
					--droneList[unitID] became NIL when drone or carrier is destroyed (in UnitDestroyed()). Is NIL at beginning of frame and t his piece of code run at end of frame
					if spValidUnitID(unitID) then -- drone was launched
						-- spEcho("Drone has been launched!!!")
						callScript(carrierID, "Carrier_droneLaunched", padPieceID)
						break
					elseif carrierList[carrierID] then
						-- spEcho("Drone died on pad :(")
						carrierList[carrierID].occupiedPieces[padPieceID] = false
						AddNextDroneFromQueue(carrierID) --add next drone in this vacant position
						GG.StopMiscPriorityResourcing(carrierID, miscPriorityKey)
					end
					return true
				end
				
				Sit()
			
				Sleep()
			end
		end
		-- spEcho("Drone finished building")

		-- note that droneList[unitID] is not garenteed to exsit at this point!
		carrierList[carrierID].occupiedPieces[padPieceID] = false
		Spring.SetUnitLeaveTracks(unitID, true)
		local launchVel = config.launchVel
		Spring.SetUnitVelocity(unitID, launchVel[1], launchVel[2], launchVel[3])
		Spring.SetUnitBlocking(unitID, false, true, true, true, false, true, false)
		mcDisable(unitID)
		if config.untargetableOnPad then
			spSetUnitRulesParam(unitID, 'untargetable', nil)
		end
		GG.UpdateUnitAttributes(unitID) --update pending attribute changes in unit_attributes.lua if available
		
		if droneInfo.config.colvolTweaked then
			Spring.SetUnitMidAndAimPos(unitID, 0, 0, 0, 0, 0, 0, true)
		end
		
		-- activate unit and its jets
		Spring.SetUnitCOBValue(unitID, COB.ACTIVATION, 1)
		AddNextDroneFromQueue(carrierID) --this create next drone in this position (in this same GameFrame!), so it might look overlapped but that's just minor details
	end
	
	StartScript(SitLoop)
end
--drone nanoframe attachment code------
--END----------------------------------

-- morph uses this
--[[
local function transferCarrierData(unitID, unitDefID, unitTeam, newUnitID)
	-- UnitFinished (above) should already be called for this new unit.
	if carrierList[newUnitID] then
		carrierList[newUnitID] = Spring.Utilities.CopyTable(carrierList[unitID], true) -- deep copy?
		  -- old carrier data removal (transfering drones to new carrier, old will "die" (on morph) silently without taking drones together to the grave)...
		local carrier = carrierList[unitID]
		for i=1, #carrier.droneSets do
			local set = carrier.droneSets[i]
			for droneID in pairs(set.drones) do
				droneList[droneID].carrier = newUnitID
				GiveOrderToUnit(droneID, CMD.GUARD, {newUnitID} , CMD.OPT_SHIFT)
			end
		end
		carrierList[unitID] = nil
	end
end
--]]

local function isCarrier(unitID)
	if (carrierList[unitID]) then
		return true
	end
	return false
end

-- morph uses this
GG.isCarrier = isCarrier
--GG.transferCarrierData = transferCarrierData

local function GetDistance(x1, x2, y1, y2)
	return ((x1-x2)^2 + (y1-y2)^2)^0.5
end

local function UpdateCarrierTarget(carrierID, frame)
	local cmdID, _, _, cmdParam_1, cmdParam_2, cmdParam_3 = Spring.GetUnitCurrentCommand(carrierID)
	local droneSendDistance = nil
	local px, py, pz
	local target
	local recallDrones = false
	local gotTarget = false
	local affectControllables = false
	local carrierData = carrierList[carrierID]
	local ox, oy, oz = spGetUnitPosition(carrierID)
	
	--checks if there is an active recall order
	local recallFrame = recall_frame_start[carrierID]
	if recallFrame then
		if frame > recallFrame.frame + RECALL_TIMEOUT then
			--recall has expired
			recall_frame_start[carrierID] = nil
		else
			recallDrones = true
			affectControllables = recallFrame.recallControllable
			gotTarget = true
		end
	end
	
	--Handles a droneSetTarget order given to the carrier.
	if not gotTarget then
		local priorityTarget = carrierData.priorityTarget
		if priorityTarget then
			if priorityTarget.x then --targeting ground
				px, py, pz = priorityTarget.x, priorityTarget.y, priorityTarget.z
				affectControllables = true -- I hate the fact that I am writing this
				gotTarget = true
			end
			if priorityTarget.unitID then --targeting units
				local allyID = spGetUnitAllyTeam(carrierID)
				local visible = spIsUnitInLos(priorityTarget.unitID, allyID) or spIsUnitInRadar(priorityTarget.unitID, allyID)
				if visible then
					priorityTarget.losTimeout = 0
					target = {priorityTarget.unitID}
					px, py, pz = spGetUnitPosition(priorityTarget.unitID)
					affectControllables = true -- I hate the fact that I am writing this
					gotTarget = true
				else
					priorityTarget.losTimeout = priorityTarget.losTimeout + 1
					if priorityTarget.losTimeout > 2 then
						carrierData.priorityTarget = nil
						UpdatePrioTargetRulesParam(carrierID)
					end
				end
			end
		end
	end
	
	--Handles an attack order given to the carrier.
	if not gotTarget and cmdID == CMD_ATTACK then
		if cmdParam_1 and not cmdParam_2 then
			target = {cmdParam_1}
			px, py, pz = spGetUnitPosition(cmdParam_1)
		else
			px, py, pz = cmdParam_1, cmdParam_2, cmdParam_3
		end
		gotTarget = true
	end
	
	--Handles a setTarget order given to the carrier.
	if not gotTarget then
		local targetType = spGetUnitRulesParam(carrierID,"target_type")
		if targetType and targetType > 0 then
			if targetType == 1 then --targeting ground
				px, py, pz = spGetUnitRulesParam(carrierID,"target_x"), spGetUnitRulesParam(carrierID,"target_y"), spGetUnitRulesParam(carrierID,"target_z")
			end
			if targetType == 2 then --targeting units
				local target_id = spGetUnitRulesParam(carrierID,"target_id")
				target = {target_id}
				px, py, pz = spGetUnitPosition(target_id)
			end
			gotTarget = true
		end
	end
	
	
	if px then
		droneSendDistance = GetDistance(ox, px, oz, pz)
	end
	local firestate = Spring.Utilities.GetUnitFireState(carrierID)
	local holdfire = (firestate == 0)
	local rx, rz
	
	local rangeBonus = spGetUnitRulesParam(carrierID, "comm_drone_range") or 1
	
	for i = 1, #carrierData.droneSets do
		local set = carrierData.droneSets[i]
		
		for droneID in pairs(set.drones) do
			if affectControllables or not droneList[droneID].controllable then
				local controllable = droneList[droneID].controllable
				droneList[droneID].controllable = true -- to keep AllowCommand from blocking the order
				
				if gotTarget then
					-- drones fire at will if carrier has an attack/target order
					-- a drone bomber probably should not do this
					GiveOrderToUnit(droneID, CMD.FIRE_STATE, { 2 }, 0)
				else
					-- update firestate based on that of carrier
					GiveOrderToUnit(droneID, CMD.FIRE_STATE, { firestate }, 0)
				end
				
				local separation = spGetUnitSeparation(droneID, carrierID, true)
				local maxRange = set.config.maxChaseRange * rangeBonus
				local sendRange = set.config.range * rangeBonus
				if recallDrones or (separation and separation > maxRange) then
					-- move drones to carrier
					rx, rz = RandomPointInUnitCircle()
					GiveClampedOrderToUnit(droneID, CMD.MOVE, {ox + rx*IDLE_DISTANCE, oy+DRONE_HEIGHT, oz + rz*IDLE_DISTANCE}, 0, false, true)
					GiveOrderToUnit(droneID, CMD.GUARD, {carrierID} , CMD.OPT_SHIFT)
				elseif droneSendDistance and droneSendDistance < sendRange then
					-- attacking
					if target then
						GiveOrderToUnit(droneID, CMD.ATTACK, target, 0)
					else
						rx, rz = RandomPointInUnitCircle()
						GiveClampedOrderToUnit(droneID, CMD.FIGHT, {px + rx*ACTIVE_DISTANCE, py+DRONE_HEIGHT, pz + rz*ACTIVE_DISTANCE}, 0, false, true)
					end
				else
					-- return to carrier unless in combat
					local cQueue = GetCommandQueue(droneID, -1)
					local engaged = false
					for j = 1, (cQueue and #cQueue or 0) do
						if cQueue[j].id == CMD.ATTACK and firestate > 0 then
							-- if currently fighting AND not on hold fire
							engaged = true
							break
						end
					end
					if not engaged then
						rx, rz = RandomPointInUnitCircle()
						GiveClampedOrderToUnit(droneID, holdfire and CMD.MOVE or CMD.FIGHT, {ox + rx*IDLE_DISTANCE, oy+DRONE_HEIGHT, oz + rz*IDLE_DISTANCE}, 0, false, true)
						GiveOrderToUnit(droneID, CMD.GUARD, {carrierID} , CMD.OPT_SHIFT)
					end
				end
				
				droneList[droneID].controllable = controllable
			end
		end
		
	end
end

local function launchDrone(unitID, px, py, pz)
	-- spEcho("UCD: beginning drone launch!", unitID, px, py, pz)
	if not droneList[unitID] then -- Drone has died since launch order was queued
		return false
	end
	local carrierID = droneList[unitID].carrier
	local setID = droneList[unitID].set
	local droneSet = carrierList[carrierID].droneSets[setID]
	droneSet.droneCount = (droneSet.droneCount - 1)
	ChangeDroneRulesParam(carrierID, -1)
	droneSet.drones[unitID] = nil
	droneList[unitID] = nil
	-- spEcho("UCD: launch flag 1!")
	
	GiveOrderToUnit(unitID, CMD.FIRE_STATE, { 2 }, 0)
	rx, rz = RandomPointInUnitCircle()
	GiveClampedOrderToUnit(unitID, CMD.FIGHT, {px + rx*ACTIVE_DISTANCE, py+DRONE_HEIGHT, pz + rz*ACTIVE_DISTANCE}, 0, false, true)
	-- spEcho("UCD: launch flag 2!")

	SetUnitNoSelect(unitID, false)

	local lifetime = droneSet.config.launchedLife
	if lifetime then
		spSetUnitRulesParam(unitID, "lifetime_total", lifetime, ALLIED_ACCESS)
		spSetUnitRulesParam(unitID, "lifetime_expiry", spGetGameFrame() + lifetime, ALLIED_ACCESS)
		GG.UnitCallLater(unitID, droneSet.config.launchedLife, spDestroyUnit, true)
	end
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function ToggleDronesCommand(unitID, newState)
	local cmdDescID = Spring.FindUnitCmdDesc(unitID, CMD_TOGGLE_DRONES)
	if (cmdDescID) then
		toggleParams.params[1] = newState
		Spring.EditUnitCmdDesc(unitID, cmdDescID, toggleParams)
		generateDrones[unitID] = (newState == 1)
	end
end

function gadget:AllowCommand_GetWantedCommand()
	return true
end

function gadget:AllowCommand_GetWantedUnitDefID()
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if droneList[unitID] then
		return droneList[unitID].controllable
	end
	if not carrierList[unitID] then
		return true
	end

	if (cmdID == CMD.STOP) then
		carrierList[unitID].priorityTarget = nil
		UpdatePrioTargetRulesParam(unitID)
	end
	
	if cmdID == CMD_TOGGLE_DRONES then
		ToggleDronesCommand(unitID, cmdParams[1])
		return false
	end
	
	if (cmdID == CMD.ATTACK or cmdID == CMD.FIGHT or cmdID == CMD.PATROL or cmdID == CMD_UNIT_SET_TARGET or cmdID == CMD_UNIT_SET_TARGET_CIRCLE) then
		recall_frame_start[unitID] = nil
		return true
	end
	
	if (cmdID == CMD_RECALL_DRONES) then
		
		-- Gives drones a command to recall to the carrier
		for i = 1, #carrierList[unitID].droneSets do
			local set = carrierList[unitID].droneSets[i]
			px, py, pz = spGetUnitPosition(unitID)
			
			for droneID in pairs(set.drones) do
				if not droneList[droneID].controllable then
					droneList[droneID].controllable = true -- to keep AllowCommand from blocking the order
					local rx, rz = RandomPointInUnitCircle()
					GiveClampedOrderToUnit(droneID, CMD.MOVE, {px + rx*IDLE_DISTANCE, py+DRONE_HEIGHT, pz + rz*IDLE_DISTANCE}, 0, false, true)
					GiveOrderToUnit(droneID, CMD.GUARD, {unitID} , CMD.OPT_SHIFT)
					droneList[droneID].controllable = false
				end
			end
		end
		
		frame = spGetGameFrame()
		local recallControllable = carrierList[unitID].priorityTarget and true or false
		recall_frame_start[unitID] = {frame = frame, recallControllable = recallControllable}

		carrierList[unitID].priorityTarget = nil
		UpdatePrioTargetRulesParam(unitID)
		
		return false
	end
	
	if (cmdID == CMD_DRONE_SET_TARGET) then
		local priorityTarget = {}
		if #cmdParams == 1 then
			priorityTarget.unitID = cmdParams[1]
			priorityTarget.losTimeout = 0
		elseif #cmdParams == 3 then
			priorityTarget.x = cmdParams[1]
			priorityTarget.y = cmdParams[2]
			priorityTarget.z = cmdParams[3]
		end
		carrierList[unitID].priorityTarget = priorityTarget
		UpdatePrioTargetRulesParam(unitID)
		
		return false
	end
	
	return true
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if (carrierList[unitID]) then
		local newUnitID = GG.wasMorphedTo and GG.wasMorphedTo[unitID]
		local carrier = carrierList[unitID]
		if newUnitID and carrierList[newUnitID] then --MORPHED, and MORPHED to another carrier. Note: unit_morph.lua create unit first before destroying it, so "carrierList[]" is already initialized.
			local newCarrier = carrierList[newUnitID]
			ToggleDronesCommand(newUnitID, ((generateDrones[unitID] ~= false) and 1) or 0)
			for i = 1, #carrier.droneSets do
				local set = carrier.droneSets[i]
				local newSetID = -1
				local droneCount = 0
				for j = 1, #newCarrier.droneSets do
					if newCarrier.droneSets[j].config.drone == set.config.drone then --same droneType? copy old drone data
						newCarrier.droneSets[j].droneCount = set.droneCount
						droneCount = droneCount + set.droneCount
						newCarrier.droneSets[j].reload = set.reload
						newCarrier.droneSets[j].drones = set.drones
						newSetID = j
					end
				end
				
				ChangeDroneRulesParam(newUnitID, droneCount)

				for droneID in pairs(set.drones) do
					droneList[droneID].carrier = newUnitID
					droneList[droneID].set = newSetID
					GiveOrderToUnit(droneID, CMD.GUARD, {newUnitID} , CMD.OPT_SHIFT)
				end
			end
		else --Carried died
			for i = 1, #carrier.droneSets do
				local set = carrier.droneSets[i]
				for droneID in pairs(set.drones) do
					droneList[droneID] = nil
					killList[droneID] = true
				end
			end
		end
		generateDrones[unitID] = nil
		carrierList[unitID] = nil
		recall_frame_start[unitID] = nil
	elseif (droneList[unitID]) then
		local carrierID = droneList[unitID].carrier
		local setID = droneList[unitID].set
		if setID > -1 then --is -1 when carrier morphed and drone is incompatible with the carrier
			local droneSet = carrierList[carrierID].droneSets[setID]
			droneSet.droneCount = (droneSet.droneCount - 1)
			ChangeDroneRulesParam(carrierID, -1)
			droneSet.drones[unitID] = nil
		end
		droneList[unitID] = nil
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if (carrierDefs[unitDefID]) then
		CreateCarrier(unitID, carrierDefs[unitDefID])
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if Spring.GetUnitRulesParam(unitID, "comm_level") then
		Drones_InitializeDynamicCarrier(unitID)
	end
	if (carrierDefs[unitDefID]) and not carrierList[unitID] then
		carrierList[unitID] = InitCarrier(unitID, carrierDefs[unitDefID], unitTeam)
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam)
	if carrierList[unitID] then
		carrierList[unitID].teamID = newTeam
		for i = 1, #carrierList[unitID].droneSets do
			local set = carrierList[unitID].droneSets[i]
			for droneID, _ in pairs(set.drones) do
				-- Only transfer drones which are allied with the carrier. This is to
				-- make carriers and capture interact in a robust, simple way. A captured
				-- drone will take up a slot on the carrier and attack the carriers allies.
				-- A captured carrier will need to have its drones killed or captured to
				-- free up slots.
				--local droneTeam = spGetUnitTeam(droneID)
				--if droneTeam and Spring.AreTeamsAllied(droneTeam, newTeam) then
					drones_to_move[droneID] = newTeam
				--end
			end
		end
	end
end


function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if droneLaunchDefs[weaponDefID] then
		local targetType, targetParam = Spring.GetProjectileTarget(proID)
		local targetX, targetY, targetZ
		local config = droneLaunchDefs[weaponDefID]
		local carrier = carrierList[proOwnerID]
		Spring.DeleteProjectile(proID)

		if not carrier then return end

		if targetType == TARGET_UNIT then
			targetX, targetY, targetZ = spGetUnitPosition(targetParam)
		elseif targetType == TARGET_FEATURE then
			targetX, targetY, targetZ = Spring.GetFeaturePosition(targetParam)
		elseif targetType == TARGET_GROUND then
			targetX = targetParam[1]
			targetY = targetParam[2]
			targetZ = targetParam[3]
		else
			Spring.Echo("[unit_carrier_drones.lua]: Bad target type. Got: " .. tostring(targetType))
		end
		if not targetX then return end

		local launchData = {
			config = config,
			cooldown = spGetGameFrame(),
			x = targetX,
			y = targetY,
			z = targetZ,
			drones = {},
		}
		local toLaunch = launchData.drones
		-- spEcho("UCD: Launching drones!")
		for i = 1, #carrier.droneSets do
			local set = carrier.droneSets[i]
			if set.config.canLaunch then
			-- spEcho("UCD: found Set!")
				for droneID in pairs(set.drones) do
					-- spEcho("UCD: found drone!")
					health, _, _, _, buildProgress = spGetUnitHealth(droneID)
					if buildProgress >= 1 then
						-- spEcho("UCD: queueing for launch!")
						toLaunch[#toLaunch+1] = droneID
					end
				end
			end
		end

		if #toLaunch > 1 then
			-- spEcho("UCD: all good!")
			droneLaunchesQueued[proOwnerID] = launchData
		end
	end
end


function gadget:GameFrame(f)
	if (((f+1) % 30) == 0) then
		for carrierID, carrier in pairs(carrierList) do
			if (not GetUnitIsStunned(carrierID)) then
				local freePads = GetCarrierFreePadsCount(carrierID)
				for i = 1, #carrier.droneSets do
					local set = carrier.droneSets[i]
					if (set.reload > 0) then
						local reloadMult = spGetUnitRulesParam(carrierID, "totalReloadSpeedChange") or 1
						local droneReloadMod = spGetUnitRulesParam(carrierID, "comm_drone_rebuildrate") or 1
						set.reload = set.reload - (reloadMult * droneReloadMod)
						
					elseif (set.droneCount + set.queueCount < set.maxDrones) and set.buildCount < set.config.maxBuild then
						if generateDrones[carrierID] then
							local spawnSize = set.config.spawnSize
							if freePads > 1 then -- extra spawns for empty pads.
								spawnSize = math.min(freePads, set.maxDrones - set.queueCount - set.buildCount) -- shove as many as possible out the door.
							end
							for n = 1, spawnSize do
								if set.droneCount + set.queueCount >= set.maxDrones
								or set.buildCount >= set.config.maxBuild then
									break
								end

								if AddUnitToEmptyPad(carrierID, i ) then
									set.buildCount = set.buildCount + 1
								else
									set.queueCount = set.queueCount + 1
									carrierList[carrierID].droneInQueue[ #carrierList[carrierID].droneInQueue + 1 ] = i
								end
							end
							set.reload = set.config.reloadTime -- apply reloadtime when queuing construction (not when it actually happens) - helps keep a constant creation rate over time
						end
					end
				end
			end
		end
		for droneID, team in pairs(drones_to_move) do
			TransferUnit(droneID, team, false)
			drones_to_move[droneID] = nil
		end
		for unitID in pairs(killList) do
			spDestroyUnit(unitID, true)
			killList[unitID] = nil
		end
	end
	if ((f % DEFAULT_UPDATE_ORDER_FREQUENCY) == 0) then
		for i, _ in pairs(carrierList) do
			UpdateCarrierTarget(i, f)
		end
	end
	for carrierID, launch in pairs(droneLaunchesQueued) do
		local drones = launch.drones
		-- spEcho("UCD: checking set!")
		while f > launch.cooldown do
			local sucess = launchDrone(drones[#drones], launch.x, launch.y, launch.z)
			drones[#drones] = nil
			if sucess then
				launch.cooldown = launch.cooldown + launch.config.launch_rate + 1
			end
			if #drones <= 0 then
				droneLaunchesQueued[carrierID] = nil
				break
			end
		end
	end
	UpdateCoroutines() --maintain nanoframe position relative to carrier
end

function gadget:Initialize()
	gadgetHandler:RegisterCMDID(CMD_RECALL_DRONES)
	gadgetHandler:RegisterCMDID(CMD_TOGGLE_DRONES)
	GG.Drones_InitializeDynamicCarrier = Drones_InitializeDynamicCarrier
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		local team = spGetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, team)
		local build  = select(5, spGetUnitHealth(unitID))
		if build == 1 then
			gadget:UnitFinished(unitID, unitDefID, team)
		end
	end
end

function gadget:Shutdown()
	--for unitID in pairs(droneList) do
	--	Spring.DestroyUnit(unitID, true)
	--end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Save/Load

local function LoadDrone(unitID, parentID)
	Spring.DestroyUnit(unitID, false, true)
end

function gadget:Load(zip)
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local parentID = Spring.GetUnitRulesParam(unitID, "parent_unit_id")
		if parentID then
			LoadDrone(unitID, parentID)
		end
	end
end

