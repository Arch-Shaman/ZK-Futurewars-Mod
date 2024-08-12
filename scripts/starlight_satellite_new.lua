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
local LaserA = piece('LaserA')
local LaserB = piece('LaserB')
local LaserC = piece('LaserC')
local LaserD = piece('LaserD')
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
local coolingOff = false

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

local function GetAngle(x2, y2, z2, x1, y1, z1)
	local distance = math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)) + ((z2 - z1) * (z2 - z1)))
	return math.asin(math.sqrt(((x2 - x1) * (x2 - x1)) + ((z2 - z1) * (z2 - z1))) / distance) + math.rad(90)
end

local function GetVerticalAngle(x2, y2, z2, x1, y1, z1)
	return math.asin(math.sqrt((z2 - z1) * (z2 - z1)) / math.sqrt((x2 - x1) * (x2 - x1) + ((z2 - z1) * (z2 - z1))))
end

local aimPoints = {
	[1] = LimbA1,
	[2] = LimbB1,
	[3] = LimbC1,
	[4] = LimbD1,
}

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
				--Spring.Echo("Mult: " .. currentSpeedMult)
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
			coolingOff = false
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
		Turn(InnerLimbs[i],y_axis,math.rad(0),1)
		Turn(OuterLimbs[i],y_axis,math.rad(0),1)
	end
	Spring.Echo("STOP")
	Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, {})
	Sleep(1000)
end

function script.Create()
	--Move(Satellite, y_axis, -10)
	--Spin(Satellite, x_axis, math.rad(80))
	for i=1,4 do
		Turn(InnerLimbs[i],y_axis,math.rad(-85))
		Turn(OuterLimbs[i],y_axis,math.rad(-85))
	end
	StartThread(Undock)
	StartThread(SuperWeaponThread)
	StartThread(MonitorThread)
	GG.starlightSatelliteInvulnerable = GG.starlightSatelliteInvulnerable or {}
	GG.starlightSatelliteInvulnerable[unitID] = true
	for i = 5, 9 do
		Spring.SetUnitWeaponState(unitID, i, "range", 999999)
	end
end

local SIG_AIM1 = 32
local SIG_AIM2 = 64
local SIG_AIM3 = 128
local SIG_AIM4 = 256

local rotationRate = math.rad(180)

local states = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false,
}

function script.AimWeapon(num, heading, pitch)
	if num == 1 then
		states[num] = false
		Signal(SIG_AIM1)
		SetSignalMask(SIG_AIM1)
		Turn(LimbA2, x_axis, heading, rotationRate)
		Turn(LimbA2, y_axis, -pitch, rotationRate)
		WaitForTurn(LimbA2, x_axis)
		WaitForTurn(LimbA2, y_axis)
		states[num] = true
		return true
	elseif num == 2 then
		states[2] = false
		Signal(SIG_AIM2)
		SetSignalMask(SIG_AIM2)
		Turn(LimbB2, x_axis, heading, rotationRate)
		Turn(LimbB2, y_axis, -pitch, rotationRate)
		WaitForTurn(LimbB2, x_axis)
		WaitForTurn(LimbB2, y_axis)
		states[2] = true
		return true
	elseif num == 3 then
		states[3] = false
		Signal(SIG_AIM3)
		SetSignalMask(SIG_AIM3)
		Turn(LimbC2, x_axis, heading, rotationRate)
		Turn(LimbC2, y_axis, -pitch, rotationRate)
		WaitForTurn(LimbC2, x_axis)
		WaitForTurn(LimbC2, y_axis)
		states[3] = true
		return true
	elseif num == 4 then
		states[4] = false
		Signal(SIG_AIM4)
		SetSignalMask(SIG_AIM4)
		Turn(LimbD2, x_axis, heading, rotationRate)
		Turn(LimbD2, y_axis, -pitch, rotationRate)
		WaitForTurn(LimbD2, x_axis)
		WaitForTurn(LimbD2, y_axis)
		states[4] = true
		return true
	else
		return false
	end
end

function script.FireWeapon(num)
	lastFrameShot = Spring.GetGameFrame()
	currentFiringTime = currentFiringTime + 1
end

local weapondefsbylevel = {
	[1] = WeaponDefNames["supernova_satellite_tracker"].id,
	[2] = WeaponDefNames["supernova_satellite_laser"].id,
	[3] = WeaponDefNames["supernova_satellite_cutter"].id,
	[4] = WeaponDefNames["supernova_satellite_deathlaser"].id
}

local firepoints = {
	[1] = LaserA,
	[2] = LaserB,
	[3] = LaserC,
	[4] = LaserD,
}

local function FireZeBeam() -- BEAM LASERS *FUCKING* SUCK.
	if coolingOff then
		return
	end
	--[[local unitTargetType, _, target = Spring.GetUnitWeaponTarget(unitID, 1)
	local x, y, z = Spring.GetUnitPosition(unitID)
	local defID = weapondefsbylevel[currentStage + 1]
	local ex, ey, ez
	if unitTargetType == 1 then
		ex, ey, ez = Spring.GetUnitPosition(target)
	elseif unitTargetType == 2 then
		ex = target[1]
		ey = target[2]
		ez = target[3]
	elseif unitTargetType == 3 then
		ex, ey, ez = Spring.GetProjectilePosition(target)
	end
	ey = Spring.GetGroundHeight(ex, ez) - 50]]
	lastFrameShot = Spring.GetGameFrame()
	currentFiringTime = currentFiringTime + 1
	if currentStage == 3 and currentFiringTime > (90 * currentSpeedMult) then
		coolingOff = true
	end
	for i = 1, 4 do
		EmitSfx(firepoints[i], 2052 + currentStage)
	end
end

function script.BlockShot(num)
	if num == 1 then
		if states[1] and states[2] and states[3] and states[4] then
			FireZeBeam()
		end
	end
	return true
end

function script.AimFromWeapon(num)
	if num <= 4 then
		return aimPoints[num]
	else
		return Satellite
	end
end

function script.QueryWeapon(num)
	if num <= 4 then
		return aimPoints[num]
	else
		return Satellite
	end
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
