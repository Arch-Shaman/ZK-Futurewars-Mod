include "constants.lua"
include "pieceControl.lua"

-- these are satellite pieces
local LimbA1 = piece('LimbA1')
local LimbA2 = piece('LimbA2')
local LimbB1 = piece('LimbB1')
local LimbB2 = piece('LimbB2')
local LimbC1 = piece('LimbC1')
local LimbC2 = piece('LimbC2')
local LimbD1 = piece('LimbD1')
local LimbD2 = piece('LimbD2')
local Satellite = piece('Satellite')
local SatelliteMuzzle = piece('SatelliteMuzzle')

local InnerLimbs = {LimbA1,LimbB1,LimbC1,LimbD1}
local OuterLimbs = {LimbA2,LimbB2,LimbC2,LimbD2}

local SIG_DOCK  = 2
local SIG_SHOOT = 4
local SIG_WATCH = 8
local SIG_SUPERWEAPON = 16

local on = false
local shooting = 0

local parentUnitID
local lastFrameShot = -1
local currentStage = 0
local setup = false

local currentSpeedMult = 0.01
local noPower = false
local currentFiringTime = 0

local restartTime = 2.2 * 30
local beamLevelTime = {}
beamLevelTime[0] = 2 * 30 -- Tracker -> laser
beamLevelTime[1] = 10 * 30 -- laser -> cutter
beamLevelTime[2] = 20 * 30 -- cutter -> deathlaser

local spGetUnitIsStunned = Spring.GetUnitIsStunned
local spGetUnitRulesParam = Spring.GetUnitRulesParam

local function RoundToNearestFrame(num) -- take whole number, put out whole number
	local prenumber = num * 10
	return math.ceil(prenumber/ 10)
end

local function GetFrameTimeToNextLevel(level)
	if beamLevelTime[level] and not noPower then
		return RoundToNearestFrame(beamLevelTime[level] / currentSpeedMult)
	else
		return 10000000
	end
end

local function CheckLevel()
	if currentFiringTime >= GetFrameTimeToNextLevel(currentStage) then
		currentFiringTime = 0
		currentStage = currentStage + 1
	end
end

local function SuperWeaponThread()
	SetSignalMask(SIG_SUPERWEAPON)
	local INLOS = {inlos = true}
	while true do
		if parentUnitID and Spring.ValidUnitID(parentUnitID) and setup then
			local disabled = spGetUnitIsStunned(parentUnitID)
			noPower = not ((Spring.GetUnitRulesParam(parentUnitID,"disarmed") ~= 1) and (Spring.GetUnitRulesParam(parentUnitID, "lowpower") or 0) ~= 1)
			if noPower then
				currentSpeedMult = 0.000000001
			else
				currentSpeedMult = Spring.GetUnitRulesParam(parentUnitID, "superweapon_mult") or 0.000000001
				Spring.Echo("Mult: " .. currentSpeedMult)
				Spring.SetUnitRulesParam(unitID, "superweapon_mult", currentSpeedMult, INLOS)
			end
			Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", math.max(currentSpeedMult, 0.01))
			GG.UpdateUnitAttributes(unitID)
		else
			currentSpeedMult = 0
		end
		Sleep(198) -- 5hz
	end
end

local function MonitorThread()
	SetSignalMask(SIG_WATCH)
	local timeSinceFire = 0
	local currentGameFrame = -1
	noPower = true
	while true do
		currentGameFrame = Spring.GetGameFrame()
		if currentStage > 0 and currentGameFrame - lastFrameShot > restartTime then
			currentStage = 0
			currentFiringTime = 0
		end
		if setup then
			CheckLevel()
		end
		if (not Spring.ValidUnitID(parentUnitID)) and setup then
			Spring.Echo("Crashing")
			Spring.SetUnitCrashing(unitID, true)
			Spring.SetUnitHealth(unitID, 0)
		elseif not parentUnitID then
			parentUnitID = Spring.GetUnitRulesParam(unitID,'parent_unit_id') -- set up
			if parentUnitID then
				setup = true
				Spring.Echo("Parent ID is " .. parentUnitID .. " Valid: " .. tostring(Spring.ValidUnitID(parentUnitID)))
			end
		end
		Sleep(33)
	end
end

local function Undock()
	Spring.Echo("UNDOCK")
	Sleep(100)
	Spring.Echo("Issue flight command")
	Spring.GiveOrderToUnit(unitID, CMD.IDLEMODE, {0}, CMD.OPT_SHIFT)
	local x, y, z = Spring.GetUnitPosition(unitID)
	Spring.GiveOrderToUnit(unitID, CMD.MOVE, {x + 1800, y, z + 1800}, CMD.OPT_SHIFT)
	Sleep(200)
	for i=1,4 do
		Turn(InnerLimbs[i],y_axis,math.rad(-85),1)
		Turn(OuterLimbs[i],y_axis,math.rad(-85),1)
	end
	Spring.Echo("STOP")
	Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, {})
end

function script.Create()
	--Move(Satellite, y_axis, -10)
	--Spin(Satellite, x_axis, math.rad(80))
	StartThread(Undock)
	StartThread(SuperWeaponThread)
	StartThread(MonitorThread)
	GG.starlightSatelliteInvulnerable = GG.starlightSatelliteInvulnerable or {}
	GG.starlightSatelliteInvulnerable[unitID] = true
end

function script.AimWeapon(num, heading, pitch)
	return num == currentStage + 1 
end

function script.FireWeapon(num)
	lastFrameShot = Spring.GetGameFrame()
	currentFiringTime = currentFiringTime + 1
end

function script.AimFromWeapon(num)
	return Satellite
end

function script.QueryWeapon(num)
	return SatelliteMuzzle
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if (severity <= 0.25) then
		Explode(Satellite, SFX.SHATTER)
		return 0 -- corpsetype
	elseif (severity <= 0.5) then
		Explode(Satellite, SFX.SHATTER)
		return 1 -- corpsetype
	else
		Explode(Satellite, SFX.SHATTER)
		return 2 -- corpsetype
	end
end
