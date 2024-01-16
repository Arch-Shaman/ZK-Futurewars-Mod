local base = piece('Base')
local ship = piece('Ship')
local wakeAftL = piece('WakeAftL')
local wakeAftR = piece('WakeAftR')
local wakeForeL = piece('WakeForeL')
local wakeForeR = piece('WakeForeR')
local wakeForeM = piece('WakeForeM')
local wakeForeML = piece('WakeForeML')
local wakeForeMR = piece('WakeForeMR')
local beamCannonBase = piece('BeamCannonBase')
local beamCannonTurret = piece('BeamCannonTurret')
local azimuthHack = piece('AzimuthHack')
local beamCannonGun = piece('BeamCannonGun')
local firepoint = piece('Firepoint')

-- Signal definitions
local SIG_AIM = 4
local SIG_MOVE = 1
-- local SIG_BANK = 8
local SIG_EXTEND = 16

local erect = false
local moving = false
local CurrentBank = 0

local elevationSpeed = math.rad(6)
local azimuthSpeed = math.rad(25)

local gun_yaw = 0

--rockz
include "rockPiece.lua"
local dynamicRockData

local ROCK_FORCE_X = -0.125
local ROCK_FORCE_Y = -0.25

local rockData = {
	[x_axis] = {
		piece = base,
		speed = 5,
		decay = -1/2,
		minPos = math.rad(2.5),
		maxPos = math.rad(10),
		signal = 32,
		axis = x_axis,
	},
	[y_axis] = {
		piece = base,
		speed = 5,
		decay = -1/2,
		minPos = math.rad(5),
		maxPos = math.rad(20),
		signal = 64,
		axis = y_axis,
	},
}

local function Wake()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while true do
		if not Spring.GetUnitIsCloaked(unitID) and not erect then
			EmitSfx(wakeAftL,   2)
			EmitSfx(wakeAftR,   2)
			EmitSfx(wakeForeL,  2)
			EmitSfx(wakeForeR,  2)
			EmitSfx(wakeForeM,  2)
			EmitSfx(wakeForeML, 2)
			EmitSfx(wakeForeMR, 2)
		end
		Sleep(150)
	end
end

local ableToMove = true
local function SetAbleToMove(newMove)
	if ableToMove == newMove then
		return
	end
	ableToMove = newMove
	
	Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", (ableToMove and 1) or 0.05)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", (ableToMove and 1) or 0.05)
	GG.UpdateUnitAttributes(unitID)
	if newMove then
		GG.WaitWaitMoveUnit(unitID)
	end
end

local function Erect()
	-- Don't set signals because this is called from aimweapon and spring complains if we set signals
	--Signal(SIG_AIM)
	--SetSignalMask(SIG_AIM)
	SetAbleToMove(false)
	Move(beamCannonTurret, z_axis, 0, 5)
	Move(beamCannonGun,    y_axis, 0, 11)
	WaitForMove(beamCannonTurret, z_axis)
	WaitForMove(beamCannonGun, y_axis)
	erect = true
end

local function Unerect()
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	if not erect then return end
	Turn(azimuthHack, z_axis, 0, azimuthSpeed)
	Turn(beamCannonTurret, x_axis, 0, elevationSpeed)
	WaitForTurn(azimuthHack, z_axis)
	WaitForTurn(beamCannonTurret, x_axis)
	Move(beamCannonGun, y_axis, 20, 11)
	WaitForMove(beamCannonGun, y_axis)
	Move(beamCannonGun, y_axis, 43.151, 11)
	Move(beamCannonTurret, z_axis, -10, 5)
	WaitForMove(beamCannonGun, y_axis)
	WaitForMove(beamCannonTurret, z_axis)
	SetAbleToMove(true)
	erect = false
end

-- local function Bank()
-- 	Signal(SIG_BANK)
-- 	SetSignalMask(SIG_BANK)
-- 	while true do
-- 		Turn(ship, z_axis, CurrentBank)
-- 		CurrentBank = CurrentBank * 0.95
-- 		Sleep(33)
-- 	end
-- end

function script.StartMoving()
	moving = true
	StartThread(Unerect)
	StartThread(Wake)
end

function script.StopMoving()
	moving = false
	Signal(SIG_MOVE)
end

-- function script.ChangeHeading(deltaHeading) 
-- 	CurrentBank = CurrentBank + deltaHeading
-- 	Spring.Echo(CurrentBank)
-- end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, { ship, beamCannonBase, beamCannonGun, beamCannonTurret })
--	StartThread(Bank)
	Move(beamCannonGun, y_axis, 43.151)
	Move(beamCannonTurret, z_axis, -10)
	dynamicRockData = GG.ScriptRock.InitializeRock(rockData)
end

function script.QueryWeapon()
	return firepoint
end

function script.AimFromWeapon()
	return beamCannonTurret
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)

	if moving then
		return false
	end

	if not erect then
		Erect()
	end
	
	Turn(azimuthHack, z_axis, heading, azimuthSpeed)
	Turn(beamCannonTurret, x_axis, -pitch, elevationSpeed)
	WaitForTurn(azimuthHack, z_axis)
	WaitForTurn(beamCannonTurret, x_axis)
	gun_yaw = heading
	return true
end

function script.FireWeapon(num)
	if num == 1 then
		StartThread(GG.ScriptRock.Rock, dynamicRockData[x_axis], math.pi/2-gun_yaw, ROCK_FORCE_X)
		StartThread(GG.ScriptRock.Rock, dynamicRockData[y_axis], gun_yaw, ROCK_FORCE_Y)
	end
end

function script.Shot(num)
	if num == 1 then
		Move(beamCannonGun, y_axis, 15)
		Move(beamCannonGun, y_axis, 0, 15)
	end
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	Explode( body, SFX.SHATTER)
	if  severity <= 0.25  then
		return 1
	elseif  severity <= 0.50  then
		Explode(ship, SFX.FALL + SFX.SHATTER)
		return 1
	else
		Explode(ship, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT + SFX.SHATTER)
		return 2
	end
end
