include "constants.lua"
include "trackControl.lua"
include "rockPiece.lua"
include "pieceControl.lua"
local scriptReload = include("scriptReload.lua")
local base, body, turret, sleeve1, sleeve2 = piece('base', 'body', 'turret', 'sleeve1', 'sleeve2')
local smokes = {piece('smoke1', 'smoke2')}
local firepoints = {piece('firepoint1', 'firepoint2')}
local barrels = {piece('barrel1', 'barrel2')}
local shot = 0
local gameSpeed = Game.gameSpeed
local RELOAD_TIME = 4.7 * gameSpeed

local gun = {
	[0] = {firepoint = firepoints[1], loaded = true},
	[1] = {firepoint = firepoints[2], loaded = true},
}

local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload

function script.StartMoving()
	StartThread(TrackControlStartMoving)
end

function StunThread()
	disarmed = true
	Signal (SIG_AIM)
	GG.PieceControl.StopTurn(turret, y_axis)
	GG.PieceControl.StopTurn(sleeve1, x_axis)
	GG.PieceControl.StopTurn(sleeve2, x_axis)
end

local stuns = {false, false, false}
local disarmed = false

function Stunned(stun_type)
	-- since only the turret is animated, treat all types the same since they all disable weaponry
	stuns[stun_type] = true
	StartThread (StunThread)
end

function Unstunned(stun_type)
	stuns[stun_type] = false
	if not stuns[1] and not stuns[2] and not stuns[3] then
		StartThread (UnstunThread)
	end
end

function UnstunThread()
	disarmed = false
	if isAiming then
		StartThread(RestoreAfterDelay)
	end
end

function script.StopMoving()
	TrackControlStopMoving()
end

local rockData

local lastHeading = 0

function script.AimFromWeapon(num)
	return turret
end

function script.QueryWeapon(num)
	return gun[shot].firepoint
end

local function BarrelRecoil(thisGun)
	EmitSfx(smokes[thisGun], 1024)
	Move (barrels[thisGun], z_axis, -10, 75)
	Sleep (130)
	Move (barrels[thisGun], z_axis, 0, 10)
end

local function reload(num)
	scriptReload.GunStartReload(num)
	gun[num].loaded = false
	SleepAndUpdateReload(num, RELOAD_TIME)
	gun[num].loaded = true
	if scriptReload.GunLoaded(num) then
		shot = 0
	end
end

function script.Shot(num)
	StartThread(GG.ScriptRock.Rock, rockData[z_axis], lastHeading, 0.04)
	StartThread(GG.ScriptRock.Rock, rockData[x_axis], lastHeading - (math.pi/2), 0.04)

	StartThread(BarrelRecoil, shot + 1)
	StartThread(reload, shot)
	shot = (shot + 1)%2
end

local function RestoreAfterDelay()
	SetSignalMask(2)
	Sleep (8000)

	Turn(turret, y_axis, 0, 0.3)
	Turn(sleeve1, x_axis, 0, 0.2)
	Turn(sleeve2, x_axis, 0, 0.2)
end

local TURRET_TURN_SPEED = math.rad(70)
local TURRET_PITCH_SPEED = math.rad(50)
function script.AimWeapon(num, heading, pitch)
	Signal(2)
	SetSignalMask(2)
	
	while disarmed do
		Sleep (34)
	end
	local slowMult = (Spring.GetUnitRulesParam (unitID, "baseSpeedMult") or 1)
	Turn(turret, y_axis, heading, TURRET_TURN_SPEED * slowMult)
	Turn(sleeve1, x_axis, -pitch, TURRET_PITCH_SPEED * slowMult)
	Turn(sleeve2, x_axis, -pitch, TURRET_PITCH_SPEED * slowMult)
	WaitForTurn(turret, y_axis)
	WaitForTurn(sleeve1, x_axis)

	StartThread(RestoreAfterDelay)
	lastHeading = heading

	return true
end

local spGetUnitSeparation = Spring.GetUnitSeparation

function script.BlockShot(num, targetID)
	if num == 1 then
		if Spring.ValidUnitID(targetID) then
			-- TTL at max range determined to be 37f empirically
			-- at projectile speed 255 elmo/s and 360 range
			local framesETA = 37 * (spGetUnitSeparation(unitID, targetID) or 0) / 360
			return GG.OverkillPrevention_CheckBlock(unitID, targetID, 640.1, framesETA, false, false, true) or not gun[shot].loaded
		end
		return not gun[shot].loaded
	end
	return false
end

function script.Create()
	scriptReload.SetupScriptReload(2, RELOAD_TIME)
	rockData = GG.ScriptRock.InitializeRock({
		[x_axis] = {
			piece = base,
			speed = 3,
			decay = -0.2,
			minPos = 0.01,
			maxPos = 1,
			signal = 4,
			axis = x_axis,
		},
		[z_axis] = {
			piece = base,
			speed = 6,
			decay = -0.2,
			minPos = 0.01,
			maxPos = 1,
			signal = 8,
			axis = z_axis,
		},
	})

	local tracks = {piece('tracks1', 'tracks2', 'tracks3', 'tracks4')}
	Show(tracks[1])
	Hide(tracks[2])
	Hide(tracks[3])
	Hide(tracks[4])

	InitiailizeTrackControl({
		wheels = {
			large = {piece('wheels2', 'wheels4', 'wheels6')},
			small = {piece('wheels1', 'wheels3', 'wheels5', 'wheels7')},
		},
		tracks = tracks,
		signal = 1,
		smallSpeed = math.rad(480),
		smallAccel = math.rad(15),
		smallDecel = math.rad(120),
		largeSpeed = math.rad(960),
		largeAccel = math.rad(30),
		largeDecel = math.rad(240),
		trackPeriod = 50,
	})
	StartThread(GG.Script.SmokeUnit, unitID, {body, turret}, 2)
end

local explodables = {turret, sleeve1, sleeve2, barrels[1], barrels[2]}
function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	local brutal = (severity > 0.5)

	local sfx = SFX
	local effect = sfx.FALL + (brutal and (sfx.SMOKE + sfx.FIRE) or 0)
	for i = 1, #explodables do
		if math.random() < severity then
			Explode (explodables[i], effect)
		end
	end

	if not brutal then
		return 1
	else
		Explode (body, sfx.SHATTER)
		return 2
	end
end
