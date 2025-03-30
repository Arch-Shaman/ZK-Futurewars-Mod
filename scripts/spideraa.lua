include "spider_walking.lua"
include "constants.lua"

--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------
local base = piece 'base'
local turret = piece 'turret'
local barrel = piece 'barrel'
local flare = piece 'flare'
local leg1 = piece 'leg1'	-- back right
local leg2 = piece 'leg2' 	-- middle right
local leg3 = piece 'leg3' 	-- front right
local leg4 = piece 'leg4' 	-- back left
local leg5 = piece 'leg5' 	-- middle left
local leg6 = piece 'leg6' 	-- front left

local smokePiece = {base, turret}

--------------------------------------------------------------------------------
-- constants
--------------------------------------------------------------------------------
-- Signal definitions
local SIG_WALK = 1
local SIG_AIM = 2
local SIG_AIM2 = 4
local SIG_RESTORE = 8

local PERIOD = 0.17

local sleepTime = PERIOD*1000

local legRaiseAngle = math.rad(30)
local legRaiseSpeed = legRaiseAngle/PERIOD
local legLowerSpeed = legRaiseAngle/PERIOD

local legForwardAngle = math.rad(20)
local legForwardTheta = math.rad(45)
local legForwardOffset = 0
local legForwardSpeed = legForwardAngle/PERIOD

local legMiddleAngle = math.rad(20)
local legMiddleTheta = 0
local legMiddleOffset = 0
local legMiddleSpeed = legMiddleAngle/PERIOD

local legBackwardAngle = math.rad(20)
local legBackwardTheta = -math.rad(45)
local legBackwardOffset = 0
local legBackwardSpeed = legBackwardAngle/PERIOD

local restore_delay = 3000

local reloading = false
local sounded = false
local delay = WeaponDefs[UnitDef.weapons[1].weaponDef].customParams.aimdelay

local turretTurnRate = math.rad(360)

-- four-stroke hexapedal walkscript
local function Walk()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	while true do
		
		GG.SpiderWalk.walk(leg1, leg2, leg3, leg4, leg5, leg6,
			legRaiseAngle, legRaiseSpeed, legLowerSpeed,
			legForwardAngle, legForwardOffset, legForwardSpeed, legForwardTheta,
			legMiddleAngle, legMiddleOffset, legMiddleSpeed, legMiddleTheta,
			legBackwardAngle, legBackwardOffset, legBackwardSpeed, legBackwardTheta,
			sleepTime)
	end
end

function OnTrackProgress(trackProgress)
	if trackProgress < 0.3 and sounded then sounded = false end
	if trackProgress >= 0.65 and not sounded then
		local x, y, z = Spring.GetUnitPosition(unitID)
		GG.PlayFogHiddenSound("Sounds/weapon/laser/trackercompleted_full.wav", 20.0, x, y, z, 1, 1, 1, 1)
		sounded = true
	end
end

function OnWeaponReload(weaponID)
	reloading = false
	sounded = false
	GG.AimDelay_ForceWeaponRestart(unitID, 1)
end

local function RestoreLegs()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	GG.SpiderWalk.restoreLegs(leg1, leg2, leg3, leg4, leg5, leg6,
		legRaiseSpeed, legForwardSpeed, legMiddleSpeed,legBackwardSpeed)
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(RestoreLegs)
end

local function RestoreAfterDelay()
	SetSignalMask(SIG_RESTORE)
	Sleep(restore_delay)
	Turn(turret, y_axis, 0, math.rad(90))
	Turn(barrel, x_axis, 0, math.rad(90))
end

function script.AimWeapon(num, heading, pitch)
	if num == 2 then
		Signal(SIG_AIM2)
		SetSignalMask(SIG_AIM2)
		WaitForTurn(turret, y_axis)
		WaitForTurn(barrel, x_axis)
		return not reloading
	elseif num == 1 then
		Signal(SIG_AIM)
		SetSignalMask(SIG_AIM)
		GG.DontFireRadar_CheckAim(unitID)
		
		Turn(turret, y_axis, heading, turretTurnRate)
		Turn(barrel, x_axis, math.max(-pitch - math.rad(15), -math.rad(90)), turretTurnRate)
		WaitForTurn(turret, y_axis)
		WaitForTurn(barrel, x_axis)
		Signal(SIG_RESTORE)
		StartThread(RestoreAfterDelay)
		return not reloading and GG.AimDelay_AttemptToFire(unitID, 1, heading, pitch, delay)
	end
	return true
end

function script.FireWeapon(num)
	if num == 1 then
		reloading = true
		GG.LusWatchWeaponReload(unitID, 1)
	end
end
function script.AimFromWeapon(num)
	return turret
end

function script.BlockShot(num, targetID)
	local blockRadar = (targetID and GG.DontFireRadar_CheckBlock(unitID, targetID)) and true or false
	return blockRadar and GG.Script.OverkillPreventionCheck(unitID, targetID, 2000.1, 1000, 38, 0.05, true)
end

function script.QueryWeapon(num)
	return flare
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(barrel, SFX.NONE)
		Explode(base, SFX.NONE)
		Explode(leg1, SFX.NONE)
		Explode(leg2, SFX.NONE)
		Explode(leg3, SFX.NONE)
		Explode(leg4, SFX.NONE)
		Explode(leg5, SFX.NONE)
		Explode(leg6, SFX.NONE)
		Explode(turret, SFX.NONE)
		return 1
	elseif severity <= .50 then
		Explode(barrel, SFX.FALL)
		Explode(base, SFX.NONE)
		Explode(leg1, SFX.FALL)
		Explode(leg2, SFX.FALL)
		Explode(leg3, SFX.FALL)
		Explode(leg4, SFX.FALL)
		Explode(leg5, SFX.FALL)
		Explode(leg6, SFX.FALL)
		Explode(turret, SFX.SHATTER)
		return 1
	elseif severity <= .99 then
		Explode(barrel, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(base, SFX.NONE)
		Explode(leg1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg2, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg3, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg4, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg5, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg6, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(turret, SFX.SHATTER)
		return 2
	else
		Explode(barrel, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(base, SFX.NONE)
		Explode(leg1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg2, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg3, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg4, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg5, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(leg6, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(turret, SFX.SHATTER + SFX.EXPLODE)
		return 2
	end
end
