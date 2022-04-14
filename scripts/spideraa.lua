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
local trackerlastframe = 0
local aimedrecently = false
local forcefire = false
local lastcheck = -1
local delay = WeaponDefs[UnitDef.weapons[1].weaponDef].customParams.aimdelay
local beam_duration = WeaponDefs[UnitDef.weapons[1].weaponDef].beamtime * 1000


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

function TrackThread()
	local currentframe, trackingcompletedframe, diff, reloadFrame = 0, 999999999, 0, 0
	local sounded = false
	while true do
		trackingcompletedframe = Spring.GetUnitRulesParam(unitID, "aimdelay") or -9999
		currentframe = Spring.GetGameFrame()
		diff = trackingcompletedframe - currentframe
		if aimedrecently and currentframe - trackerlastframe > 7 then
			aimedrecently = false
			GG.AimDelay_ForceWeaponRestart(unitID, 1)
		end
		if diff <= 30 and diff > 0 and currentframe - lastcheck < 3 and not reloading and aimedrecently and not sounded then
			Spring.PlaySoundFile("Sounds/weapon/laser/trackercompleted_full.wav", 20.0, x, y, z, 1, 1, 1, 1)
			sounded = true
		end
		if diff <= 0 and aimedrecently then
			forcefire = true
			sounded = false
		end
		_, _, reloadFrame = Spring.GetUnitWeaponState(unitID, 1)
		if reloadFrame then
			reloading = reloadFrame >= currentframe
			--Spring.Echo("TrackThread: Updated Reloading state: " .. tostring(reloading) .. "\nReloadFrame: " .. tostring(reloadFrame))
		end
		Sleep(33)
	end
end

local function RestoreLegs()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	GG.SpiderWalk.restoreLegs(leg1, leg2, leg3, leg4, leg5, leg6,
		legRaiseSpeed, legForwardSpeed, legMiddleSpeed,legBackwardSpeed)
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(TrackThread)
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(RestoreLegs)
end

local function RestoreAfterDelay()
	Sleep(restore_delay)
	Turn(turret, y_axis, 0, math.rad(90))
	Turn(barrel, x_axis, 0, math.rad(90))
end

function script.AimWeapon(num, heading, pitch)
	if num == 1 and not reloading then
		if forcefire then
			return true
		else
			GG.AimDelay_AttemptToFire(unitID, 1, heading, pitch, delay)
			aimedrecently = true
			sounded = false
			lastcheck = Spring.GetGameFrame()
		end
	end
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	GG.DontFireRadar_CheckAim(unitID)
	
	Turn(turret, y_axis, heading, math.rad(450))
	Turn(barrel, x_axis, math.max(-pitch - math.rad(15), -math.rad(90)), math.rad(180))
	
	WaitForTurn(turret, y_axis)
	WaitForTurn(barrel, x_axis)
	if num == 2 and reloading then
		return false
	end
	
	if num == 1 and not reloading then
		lastcheck = Spring.GetGameFrame()
		aimedrecently = true
		return GG.AimDelay_AttemptToFire(unitID, 1, heading, pitch, delay)
	elseif num == 1 and reloading then
		return false
	end
	
	StartThread(RestoreAfterDelay)
	return true
end

function script.AimFromWeapon(num)
	return turret
end

function script.FireWeapon(id)
	if id == 1 then
		forcefire = false
		GG.AimDelay_ForceWeaponRestart(unitID, 1) -- restart progress.
		aimedrecently = false
	elseif id == 2 then
		trackerlastframe = Spring.GetGameFrame()
	end
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
