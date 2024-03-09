include "constants.lua"
include "rockPiece.lua"
local dynamicRockData
include "trackControl.lua"
include "pieceControl.lua"

local base, body, turret, sleeve, barrel1, barrel2, barrel3, firepoint
	= piece("base", "body", "turret", "sleeve", "barrel1", "barrel2", "barrel3", "firepoint")

local moving = false

-- Signal definitions
local SIG_AIM = 1
local SIG_MOVE = 2
local SIG_ROCK_X = 4
local SIG_ROCK_Z = 8
local SIG_STOW = 16

local ROCK_FIRE_FORCE = 0.33
local ROCK_SPEED = 3.0
local ROCK_DECAY = -0.15
local ROCK_PIECE = base
local ROCK_MIN = 0.001 --If around axis rock is not greater than this amount, rocking will stop after returning to center.
local ROCK_MAX = 1.75

local hpi = math.pi*0.5

rockData = {
	[x_axis] = {
		piece = ROCK_PIECE,
		speed = ROCK_SPEED,
		decay = ROCK_DECAY,
		minPos = ROCK_MIN,
		maxPos = ROCK_MAX,
		signal = SIG_ROCK_X,
		axis = x_axis,
	},
	[z_axis] = {
		piece = ROCK_PIECE,
		speed = ROCK_SPEED,
		decay = ROCK_DECAY,
		minPos = ROCK_MIN,
		maxPos = ROCK_MAX,
		signal = SIG_ROCK_Z,
		axis = z_axis,
	},
}

local trackData = {
	wheels = {
		large = {piece('wheels1'), piece('wheels8')},
		small = {},
	},
	tracks = {},
	signal = SIG_MOVE,
	smallSpeed = math.rad(480),
	smallAccel = math.rad(80),
	smallDecel = math.rad(100),
	largeSpeed = math.rad(360),
	largeAccel = math.rad(40),
	largeDecel = math.rad(50),
	trackPeriod = 50,
}

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

for i = 1, 3 do
	trackData.tracks[i] = piece ('tracks' .. i)
end
for i = 2, 7 do
	trackData.wheels.small[i - 1] = piece('wheels' .. i)
end

local function StowGun()
	Signal(SIG_STOW)
	SetSignalMask(SIG_STOW)
	
	Turn(turret, z_axis, 0, math.rad(30))
	Turn(sleeve, z_axis, 0, math.rad(15))
	WaitForTurn(turret, z_axis)
	WaitForTurn(sleeve, z_axis)
	Move(barrel1, y_axis, 5, 5)
	Move(barrel2, z_axis, -10, 10)
	Move(barrel3, z_axis, -15, 15)
	WaitForMove(barrel1, y_axis)
	WaitForMove(barrel2, y_axis)
	WaitForMove(barrel3, y_axis)
	SetAbleToMove(true)
end

function script.StartMoving()
	moving = true
	StartThread(TrackControlStartMoving)
	StartThread(StowGun)
end

local function DelayStopMove()
	SetSignalMask(SIG_MOVE)
	Sleep(500)
	moving = false
end

function script.StopMoving()
	Signal(SIG_STOW)
	StartThread(DelayStopMove)
	TrackControlStopMoving()
end

local gunHeading = 0

local smokePiece = {base, turret}

local RESTORE_DELAY = 3000
local LARGE_MUZZLE_FLASH_FX = 1024
local HUGE_MUZZLE_FLASH_FX = 1025

local ROCK_X_FIRE_1 = -24

local aimPoints = {
	turret,
}
local firePoints = {
	firepoint,
}

function RestoreMainGun()
	Sleep(RESTORE_DELAY)
	Turn(turret, z_axis, 0, math.rad(45))
	Turn(sleeve, z_axis, 0, math.rad(15))
end

function RestoreBarrel()
	Sleep(125)
	Move(barrel1, y_axis, 0, 5)
	Move(barrel2, z_axis, 0, 10)
	Move(barrel3, z_axis, 0, 15)
end

function script.Create()
	dynamicRockData = GG.ScriptRock.InitializeRock(rockData)
	InitiailizeTrackControl(trackData)

	while (select(5, Spring.GetUnitHealth(unitID)) < 1) do
		Sleep (250)
	end
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
end

-- Weapons
function script.AimFromWeapon(num)
	return aimPoints[num]
end

function script.QueryWeapon(num)
	return firePoints[num]
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	
	if moving then
		return false
	end
	SetAbleToMove(false)
	
	Move(barrel1, y_axis, 0, 5)
	Move(barrel2, z_axis, 0, 10)
	Move(barrel3, z_axis, 0, 15)
	WaitForMove(barrel1, y_axis)
	WaitForMove(barrel2, y_axis)
	WaitForMove(barrel3, y_axis)
	Turn(turret, z_axis, heading, math.rad(30))
	Turn(sleeve, z_axis, -pitch, math.rad(15))
	WaitForTurn(turret, z_axis)
	WaitForTurn(sleeve, z_axis)
	StartThread(RestoreMainGun)
	gunHeading = heading
    return true
end

function script.BlockShot(num, targetID)
	if num ~= 1 then
		return false
	else
		return ((targetID and GG.DontFireRadar_CheckBlock(unitID, targetID)) or false) and GG.Script.OverkillPreventionCheck(unitID, targetID, 3000.2, 280, 1, 1)
	end
end

function script.Shot(num)
	StartThread(GG.ScriptRock.Rock, dynamicRockData[z_axis], gunHeading, ROCK_FIRE_FORCE)
	StartThread(GG.ScriptRock.Rock, dynamicRockData[x_axis], gunHeading - hpi, ROCK_FIRE_FORCE)
	
	EmitSfx(firepoint, LARGE_MUZZLE_FLASH_FX)
	Move(barrel1, y_axis, 10)
	Move(barrel2, z_axis, -20)
	Move(barrel3, z_axis, -30)
	StartThread(RestoreBarrel)
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if (severity < 0.25) then
		Explode(turret, SFX.SMOKE)
		return 1
	elseif (severity < 0.5) then
		Explode(barrel1, SFX.FALL)
		Explode(sleeve, SFX.FALL)
		Explode(turret, SFX.SHATTER)
		Explode(body, SFX.SMOKE)
		return 1
	elseif (severity < 1) then
		Explode(barrel1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(sleeve, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(turret, SFX.SHATTER)
		return 2
	end
	
	Explode(barrel1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(sleeve, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(body, SFX.SHATTER)
	return 2
end
