--linear constant 65536

include "constants.lua"

local base, pelvis, body, countertilt, aimpoint = piece('base', 'pelvis', 'body', 'countertilt', 'aimpoint')
local rthigh, rshin, rfoot, lthigh, lshin, lfoot = piece('rthigh', 'rshin', 'rfoot', 'lthigh', 'lshin', 'lfoot')
local disks = {
	{piece('f1disk', 'b1disk')},
	{piece('f2disk', 'b2disk')},
	{piece('f3disk', 'b3disk')},
}
local firepoints = {piece('fp1l', 'fp1r', 'fp2l', 'fp2r', 'fp3l', 'fp3r')}

local smokePiece = {body}
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
local PACE = 2

local THIGH_FRONT_ANGLE = -math.rad(50)
local THIGH_FRONT_SPEED = math.rad(60) * PACE
local THIGH_BACK_ANGLE = math.rad(30)
local THIGH_BACK_SPEED = math.rad(60) * PACE
local SHIN_FRONT_ANGLE = math.rad(45)
local SHIN_FRONT_SPEED = math.rad(90) * PACE
local SHIN_BACK_ANGLE = math.rad(10)
local SHIN_BACK_SPEED = math.rad(90) * PACE

local SIG_WALK = 1
local SIG_AIM1 = 2
local SIG_RESTORE = 8

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
local gun_1 = 1
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
local function Walk()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	while true do
		--left leg up, right leg back
		Turn(lthigh, x_axis, THIGH_FRONT_ANGLE, THIGH_FRONT_SPEED)
		Turn(lshin, x_axis, SHIN_FRONT_ANGLE, SHIN_FRONT_SPEED)
		Turn(rthigh, x_axis, THIGH_BACK_ANGLE, THIGH_BACK_SPEED)
		Turn(rshin, x_axis, SHIN_BACK_ANGLE, SHIN_BACK_SPEED)
		WaitForTurn(lthigh, x_axis)
		Sleep(0)
		
		--right leg up, left leg back
		Turn(lthigh, x_axis, THIGH_BACK_ANGLE, THIGH_BACK_SPEED)
		Turn(lshin, x_axis, SHIN_BACK_ANGLE, SHIN_BACK_SPEED)
		Turn(rthigh, x_axis, THIGH_FRONT_ANGLE, THIGH_FRONT_SPEED)
		Turn(rshin, x_axis, SHIN_FRONT_ANGLE, SHIN_FRONT_SPEED)
		WaitForTurn(rthigh, x_axis)
		Sleep(0)
	end
end

local function Stopping()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	
	Turn(rthigh, x_axis, 0, math.rad(80)*PACE)
	Turn(rshin, x_axis, 0, math.rad(120)*PACE)
	Turn(rfoot, x_axis, 0, math.rad(80)*PACE)
	Turn(lthigh, x_axis, 0, math.rad(80)*PACE)
	Turn(lshin, x_axis, 0, math.rad(80)*PACE)
	Turn(lfoot, x_axis, 0, math.rad(80)*PACE)
	Turn(pelvis, z_axis, 0, math.rad(20)*PACE)
	Move(pelvis, y_axis, 0, 12*PACE)
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(Stopping)
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

local function RestoreAfterDelay()
	Signal(SIG_RESTORE)
	SetSignalMask(SIG_RESTORE)
	Sleep(5000)
	Turn(body, y_axis, 0, math.rad(65))
	Turn(pelvis, x_axis, 0, math.rad(47.5))
	Turn(countertilt, x_axis, 0, math.rad(47.5))
end

function script.AimFromWeapon()
	return aimpoint
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM1)
	SetSignalMask(SIG_AIM1)
	Turn(body, y_axis, heading, math.rad(360))
	Turn(pelvis, x_axis, -pitch, math.rad(180))
	Turn(countertilt, x_axis, pitch, math.rad(180))
	WaitForTurn(body, y_axis)
	WaitForTurn(pelvis, x_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.QueryWeapon(num)
	return firepoints[gun_1]
end

function script.FireWeapon(num)
	GG.BatteryManagement.WeaponFired(unitID, num)
	gun_1 = gun_1 %2 + 1
end

function script.BlockShot(num, targetID)
	return (targetID and GG.OverkillPrevention_CheckBlock(unitID, targetID, 85.1, 12, false, false, true)) or  not GG.BatteryManagement.CanFire(unitID, num)
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .50 then
		Explode(lfoot, SFX.FALL)
		Explode(lshin, SFX.FALL)
		Explode(lthigh, SFX.FALL)
		Explode(pelvis, SFX.FALL)
		Explode(rfoot, SFX.FALL)
		Explode(rshin, SFX.FALL)
		Explode(rthigh, SFX.FALL)
		Explode(body, SFX.SHATTER)
		return 1
	else
		Explode(lfoot, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(lshin, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(lthigh, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(pelvis, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(rfoot, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(rshin, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(rthigh, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(body, SFX.SHATTER + SFX.EXPLODE)
		return 2
	end
end
