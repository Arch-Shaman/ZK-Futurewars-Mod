include "constants.lua"
include "pieceControl.lua"

local base, wakel, waker, hull, radar = piece ('base', 'wakel', 'waker', 'hull', 'radar')
local turret = {piece('fturret'), piece('bturret')}
local barrels = {piece('fbarrels'), piece('bbarrels')}
local flare = {piece('fflarebl'),piece('fflarebr'),piece('fflaretl'),piece('fflaretr'), piece('bflarebl'), piece('bflarebr'), piece('bflaretl'),piece('bflaretr')}

local SIG_Move = 1
local SIG_Aim = {2, 2, 2, 2, 4, 4, 4, 4}

local stuns = {false, false, false}
local disarmed = false
local moving = false
local sfxNum = 2

function script.setSFXoccupy(num)
	sfxNum = num
end

local function RestoreAfterDelay()
	SetSignalMask(SIG_Aim[1] + SIG_Aim[5])
	Sleep (5000)
	for i = 1, 2 do
		Turn (turret[i], y_axis, 0, math.rad(30))
		Turn (barrels[i], x_axis, 0, math.rad(30))
	end
end

local function MoveScript()
	while true do
		if moving and not Spring.GetUnitIsCloaked(unitID) and (sfxNum == 1 or sfxNum == 2) then
			EmitSfx(wakel, 3)
			EmitSfx(waker, 3)
		end
		Sleep(150)
	end
end

function script.StopMoving()
	moving = false
end

function script.StartMoving()
	moving = true
end

local function StunThread ()
	disarmed = true
	StopSpin (radar, y_axis)
	for i = 1, 2 do
		Signal (SIG_Aim[i])
		GG.PieceControl.StopTurn (turret[i], y_axis)
		GG.PieceControl.StopTurn (barrels[i], x_axis)
	end
end

local function UnstunThread ()
	disarmed = false
	Spin (radar, y_axis, math.rad(60))
	RestoreAfterDelay()
end

function Stunned (stun_type)
	stuns[stun_type] = true
	StartThread (StunThread)
end

function Unstunned (stun_type)
	stuns[stun_type] = false
	if not stuns[1] and not stuns[2] and not stuns[3] then
		StartThread (UnstunThread)
	end
end

function script.Create()
	StartThread(MoveScript)
	StartThread(GG.Script.SmokeUnit, unitID, {hull, turret[1], turret[2]})
end

function script.AimFromWeapon(id)
	if id < 5 then
		return barrels[1]
	else
		return barrels[2]
	end
end

function script.QueryWeapon(id)
	return flare[id]
end

local turretTurnSpeed = math.rad(500)

function script.AimWeapon(id, heading, pitch)
	Signal(SIG_Aim[id])
	SetSignalMask(SIG_Aim[id])
	local slowMult = (Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1) -- TODO: Optimize
	local wantedTurret, wantedBarrel
	if id < 5 then
		wantedTurret = turret[1]
		wantedBarrel = barrels[1]
	else
		wantedTurret = turret[2]
		wantedBarrel = barrels[2]
	end
	while disarmed do
		Sleep(34)
	end
	Turn (wantedTurret, y_axis, heading, turretTurnSpeed * slowMult)
	Turn (wantedBarrel, x_axis, -pitch, turretTurnSpeed * slowMult)
	WaitForTurn (wantedTurret, y_axis)
	WaitForTurn (wantedBarrel, x_axis)
	StartThread (RestoreAfterDelay)
	return true
end

function script.BlockShot(num, targetID)
	local radarCheck = targetID and GG.DontFireRadar_CheckBlock(unitID, targetID)
	return radarCheck or not GG.BatteryManagement.CanFire(unitID, num)
end

function script.FireWeapon(num)
	GG.BatteryManagement.WeaponFired(unitID, num)
end

local explodables = {turret[1], turret[2], barrels[1], barrels[2], radar}
function script.Killed(severity, health)
	severity = severity / health

	for i = 1, #explodables do
		if (math.random() < severity) then
			Explode (explodables[i], SFX.FALL + SFX.FIRE + SFX.SMOKE)
		end
	end

	if severity <= 0.5 then
		return 1
	else
		Explode(hull, SFX.SHATTER)
		Explode(base, SFX.SHATTER)
		return 2
	end
end
