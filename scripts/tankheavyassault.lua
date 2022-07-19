include "constants.lua"
include "rockPiece.lua"
local dynamicRockData
include "trackControl.lua"
include "pieceControl.lua"

local base, body, turret1, sleeve1, barrel1, firepoint1, turret2, sleeve2, barrel2, firepoint2, turret3, sleeve3, barrel3, firepoint3
	= piece("base", "body", "turret1", "sleeve1", "barrel1", "firepoint1", "turret2", "sleeve2", "barrel2", "firepoint2", "turret3", "sleeve3", "barrel3", "firepoint3")

local dgunning = false
local available = true
	
-- Signal definitions
local SIG_AIM1 = 1
local SIG_AIM2 = 2
local SIG_AIM3 = 4
local SIG_MOVE = 8
local SIG_ROCK_X = 16
local SIG_ROCK_Z = 32

local ROCK_FIRE_FORCE = 0.06
local ROCK_SPEED = 9
local ROCK_DECAY = -0.18
local ROCK_PIECE = base
local ROCK_MIN = 0.001 --If around axis rock is not greater than this amount, rocking will stop after returning to center.
local ROCK_MAX = 1.5

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

for i = 1, 3 do
	trackData.tracks[i] = piece ('tracks' .. i)
end
for i = 2, 7 do
	trackData.wheels.small[i - 1] = piece('wheels' .. i)
end

local gunHeading = 0

local smokePiece = {base, turret1}

local RESTORE_DELAY = 3000
local LARGE_MUZZLE_FLASH_FX = 1024
local HUGE_MUZZLE_FLASH_FX = 1025

local ROCK_X_FIRE_1 = -24

local aimPoints = {
	turret1,
	turret2,
	turret3,
}
local firePoints = {
	firepoint1,
	firepoint2,
	firepoint3,
}

function RestoreMainGun()
	Sleep(RESTORE_DELAY)
	Turn(turret1, z_axis, 0, math.rad(45))
	Turn(sleeve1, x_axis, 0, math.rad(15))
end

function RestoreBarrel()
	Sleep(125)
	Move(barrel1, z_axis, 0, 10)
end

function script.Create()
	dynamicRockData = GG.ScriptRock.InitializeRock(rockData)
	InitiailizeTrackControl(trackData)

	while (select(5, Spring.GetUnitHealth(unitID)) < 1) do
		Sleep (250)
	end
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
end

function script.StartMoving()
	StartThread(TrackControlStartMoving)
end

function script.StopMoving()
	TrackControlStopMoving()
end

-- Weapons
function script.AimFromWeapon(num)
	return aimPoints[num]
end

function script.QueryWeapon(num)
	return firePoints[num]
end

function script.AimWeapon(num, heading, pitch)
	if num == 1 then
		Signal(SIG_AIM1)
		SetSignalMask(SIG_AIM1)
		
		Turn(turret1, z_axis, heading, math.rad(60))
		Turn(sleeve1, x_axis, -pitch, math.rad(30))
		WaitForTurn(turret1, z_axis)
		WaitForTurn(sleeve1, x_axis)
		StartThread(RestoreMainGun)
		gunHeading = heading
		return true
	elseif num == 2 then
		return false
	elseif num == 3 then
		return false
	end
end

function script.BlockShot(num, targetID)
	if num ~= 1 then
		return false
	else
		return ((targetID and GG.DontFireRadar_CheckBlock(unitID, targetID)) or false) and GG.Script.OverkillPreventionCheck(unitID, targetID, 3000.2, 280, 1, 1)
	end
end


function script.Shot(num)
	if num ~= 1 then
		return
	end
	StartThread(GG.ScriptRock.Rock, dynamicRockData[z_axis], gunHeading, ROCK_FIRE_FORCE)
	StartThread(GG.ScriptRock.Rock, dynamicRockData[x_axis], gunHeading - hpi, ROCK_FIRE_FORCE)
	
	EmitSfx(firepoint1, LARGE_MUZZLE_FLASH_FX)
	Move(barrel1, z_axis, -20)
	StartThread(RestoreBarrel)
end

local sprayoffset = math.rad(35)
local maxoffset = math.rad(22.5)
local minigunrange = 680 * 0.92

local function TurnMinigunsThread()
	local traveling = 1
	while dgunning do
		Turn(turret2, x_axis, maxoffset * traveling, sprayoffset)
		Turn(turret3, x_axis, maxoffset * traveling, sprayoffset)
		WaitForTurn(turret2, x_axis)
		traveling = -traveling
		Sleep(10)
	end
	Turn(turret2, x_axis, 0, sprayoffset * 3)
	Turn(turret3, x_axis, 0, sprayoffset * 3)
end

local function MinigunThread()
    Turn(turret2, y_axis, math.rad(90), 2)
	Turn(turret3, y_axis, math.rad(-90), 2)
	WaitForTurn(turret2, y_axis)
	WaitForTurn(turret3, y_axis)
	Move(barrel2, z_axis, 13, 9)
	Move(barrel3, z_axis, 13, 9)
	WaitForMove(barrel2, z_axis)
	WaitForMove(barrel3, z_axis)
	Spin(sleeve2, z_axis, 1.875)
	Spin(sleeve3, z_axis, -1.875)
	Sleep(250)
	Spin(sleeve2, z_axis, 3.75)
	Spin(sleeve3, z_axis, -3.75)
	Sleep(250)
	Spin(sleeve2, z_axis, 7.5)
	Spin(sleeve3, z_axis, -7.5)
	Sleep(250)
	Spin(sleeve2, z_axis, 15)
	Spin(sleeve3, z_axis, -15)
	Sleep(250)
	Spin(sleeve2, z_axis, 30)
	Spin(sleeve3, z_axis, -30)
	Sleep(250)
	Spin(sleeve2, z_axis, 60)
	Spin(sleeve3, z_axis, -60)
	local t = 0
	local offset = 0
	local traveling = -1
	local x, y, z, tx, tz, facing
	dgunning = true
	StartThread(TurnMinigunsThread)
	while t <= 10000 do
		t = t + 33
		EmitSfx(firepoint2, GG.Script.FIRE_W2)
		EmitSfx(firepoint3, GG.Script.FIRE_W2)
		Sleep(33)
	end
	dgunning = false
	Turn(turret2, z_axis, 0, sprayoffset * 3)
	Turn(turret3, z_axis, 0, sprayoffset * 3)
	WaitForTurn(turret2, z_axis)
	Spin(sleeve2, z_axis, 30)
	Spin(sleeve3, z_axis, -30)
	Sleep(500)
	Spin(sleeve2, z_axis, 30)
	Spin(sleeve3, z_axis, -30)
	Sleep(500)
	Spin(sleeve2, z_axis, 15)
	Spin(sleeve3, z_axis, -15)
	Sleep(500)
	Spin(sleeve2, z_axis, 7.5)
	Spin(sleeve3, z_axis, -7.5)
	Sleep(500)
	Spin(sleeve2, z_axis, 3.75)
	Spin(sleeve3, z_axis, -3.75)
	Sleep(500)
	Spin(sleeve2, z_axis, 1.875)
	Spin(sleeve3, z_axis, -1.875)
	Sleep(500)
	Spin(sleeve2, z_axis, 0)
	Spin(sleeve3, z_axis, 0)
	Move(barrel2, z_axis, 0, 9)
	Move(barrel3, z_axis, 0, 9)
	WaitForMove(barrel2, z_axis)
	WaitForMove(barrel3, z_axis)
	Turn(turret2, y_axis, math.rad(0), 2)
	Turn(turret3, y_axis, math.rad(0), 2)
end

function Minigun()
	Spring.SetUnitWeaponState(unitID, 3, "reloadFrame", 2250 + Spring.GetGameFrame())
	StartThread(MinigunThread)
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if (severity < 0.25) then
		Explode(turret1, SFX.SMOKE)
		return 1
	elseif (severity < 0.5) then
		Explode(barrel1, SFX.FALL)
		Explode(sleeve1, SFX.FALL)
		Explode(turret1, SFX.SHATTER)
		Explode(body, SFX.SMOKE)
		return 1
	elseif (severity < 1) then
		Explode(barrel1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(sleeve1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(turret1, SFX.SHATTER)
		return 2
	end
	
	Explode(barrel1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(sleeve1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(turret1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(body, SFX.SHATTER)
	return 2
end
