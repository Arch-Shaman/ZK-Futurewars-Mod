include "constants.lua"

--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------
local base = piece 'base'
local pelvis = piece 'pelvis'
local torso = piece 'torso'
local rgun = piece 'rgun'
local lgun = piece 'lgun'
local rbarrel = piece 'rbarrel'
local lbarrel = piece 'lbarrel'
local fp1 = piece 'fp1'
local fp2 = piece 'fp2'
local rflap1 = piece 'rflap1'
local rflap2 = piece 'rflap2'
local rflap3 = piece 'rflap3'
local rflap4 = piece 'rflap4'
local lflap1 = piece 'lflap1'
local lflap2 = piece 'lflap2'
local lflap3 = piece 'lflap3'
local lflap4 = piece 'lflap4'
local rupleg = piece 'rupleg'
local rloleg = piece 'rloleg'
local rfoot = piece 'rfoot'
local lupleg = piece 'lupleg'
local lloleg = piece 'lloleg'
local lfoot = piece 'lfoot'
local rftoe = piece 'rftoe'
local rrtoe = piece 'rrtoe'
local lftoe = piece 'lftoe'
local lrtoe = piece 'lrtoe'

local jumpProg = 0
local flares = {[0] = fp2, [1] = fp1}
local barrels = {[0] = lbarrel, [1] = rbarrel}

--------------------------------------------------------------------------------
-- constants
--------------------------------------------------------------------------------
local SIG_AIM = 2
local SIG_MOVE = 16

local RESTORE_DELAY = 6000

local WALK_RATE = math.rad(38)

--------------------------------------------------------------------------------
-- variables
--------------------------------------------------------------------------------
local bAiming = false
local gun_1 = 0
local isJumping = false
local jumpflaming = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function Walk()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while true do
		local pace = WALK_RATE*(Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1)

		Turn(rupleg, y_axis, 0, pace)
		Turn(lupleg, y_axis, 0, pace)

		Turn(rupleg, z_axis, 0, pace)
		Turn(lupleg, z_axis, 0, pace)
		Turn(lfoot, z_axis, 0, pace)
		Turn(rfoot, z_axis, 0, pace)

		Turn(rupleg, x_axis, math.rad(-70), pace*4) --Forward
		Turn(rloleg, x_axis, math.rad(70), pace*9)
		Turn(rfoot, x_axis, 0, pace*4)

		Turn(rftoe, x_axis, 0, pace*6)
		Turn(rrtoe, x_axis, 0, pace*6)

		Turn(lupleg, x_axis, math.rad(10), pace*4) --Back
		Turn(lloleg, x_axis, 0, pace*2)
		Turn(lfoot, x_axis, math.rad(-10), pace*2)

		Turn(lftoe, x_axis, math.rad(-20), pace*6)

		Turn(torso, z_axis, math.rad(-5), pace*0.4)
		Turn(torso, x_axis, math.rad(3), pace)

		WaitForTurn(rloleg, x_axis)
		Sleep(0)

		Turn(rupleg, x_axis, math.rad(10), pace*4) --Mid
		Turn(rloleg, x_axis, math.rad(20), pace*5)
		Turn(rfoot, x_axis, math.rad(10), pace)

		Turn(lupleg, x_axis, math.rad(-70), pace*4) --Up
		Turn(lloleg, x_axis, math.rad(-20), pace*2)
		Turn(lfoot, x_axis, math.rad(40), pace*4)

		Turn(lftoe, x_axis, math.rad(30), pace*3)
		Turn(lrtoe, x_axis, math.rad(-30), pace*3)

		Turn(torso, x_axis, math.rad(-3), pace)

		WaitForTurn(rloleg, x_axis)
		Sleep(0)

		Turn(rupleg, x_axis, math.rad(10), pace*4) --Back
		Turn(rloleg, x_axis, 0, pace*2)
		Turn(rfoot, x_axis, math.rad(-10), pace*2)

		Turn(rftoe, x_axis, math.rad(-20), pace*6)

		Turn(lupleg, x_axis, math.rad(-70), pace*4) --Forward
		Turn(lloleg, x_axis, math.rad(70), pace*9)
		Turn(lfoot, x_axis, 0, pace*4)

		Turn(lftoe, x_axis, 0, pace*6)
		Turn(lrtoe, x_axis, 0, pace*6)

		Turn(torso, z_axis, math.rad(5), pace*0.4)
		Turn(torso, x_axis, math.rad(3), pace)

		WaitForTurn(rloleg, x_axis)
		Sleep(0)

		Turn(rupleg, x_axis, math.rad(-70), pace*4) --Up
		Turn(rloleg, x_axis, math.rad(-20), pace*2)
		Turn(rfoot, x_axis, math.rad(40), pace*4)

		Turn(rftoe, x_axis, math.rad(30), pace*3)
		Turn(rrtoe, x_axis, math.rad(-30), pace*3)

		Turn(lupleg, x_axis, math.rad(10), pace*4) --Mid
		Turn(lloleg, x_axis, math.rad(20), pace*5)
		Turn(lfoot, x_axis, math.rad(10), pace)

		Turn(torso, x_axis, math.rad(-3), pace)

		WaitForTurn(rloleg, x_axis)
		Sleep(0)
	end
end

local function Stop()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	Turn(lupleg, x_axis, 0, math.rad(50))
	Turn(rupleg, x_axis, 0, math.rad(50))
	Turn(lloleg, x_axis, 0, math.rad(100))
	Turn(rloleg, x_axis, 0, math.rad(100))
	if not bAiming then
		Turn(torso, z_axis, 0, math.rad(100))
		Turn(torso, x_axis, 0, math.rad(20))
	end
	Turn(rftoe, x_axis, 0, math.rad(100))
	Turn(rrtoe, x_axis, 0, math.rad(100))
	Turn(lftoe, x_axis, 0, math.rad(100))
	Turn(lrtoe, x_axis, 0, math.rad(100))
	Turn(rfoot, x_axis, 0, math.rad(100))
	Turn(lfoot, x_axis, 0, math.rad(100))
	WaitForTurn(torso, x_axis)
	if not bAiming then
	
		Turn(torso, x_axis, math.rad(10), math.rad(48))
	end
	WaitForTurn(torso, x_axis)
	if not bAiming then
	
		Turn(torso, x_axis, math.rad(-3), math.rad(48))
	end
	WaitForTurn(torso, x_axis)
	if not bAiming then
	
		Turn(torso, x_axis, 0, math.rad(48))
	end
	WaitForTurn(torso, x_axis)
	Sleep(20)
	return (0)
end

local function JetTrailThread()
	local waitTime = 100
	local waitMod = 1
	local minWait = 1/3
	while not jumpflaming do
		EmitSfx(fp2, GG.Script.UNIT_SFX4)
		EmitSfx(fp1, GG.Script.UNIT_SFX4)
		Sleep(33)
	end
	while jumpflaming do
		EmitSfx(fp2, GG.Script.FIRE_W2)
		EmitSfx(fp1, GG.Script.FIRE_W2)
		waitMod = math.max(minWait, jumpProg / 10)
		Sleep(waitTime * waitMod)
	end
	Turn (lgun, x_axis, 0, math.rad(70))
	Turn (rgun, x_axis, 0, math.rad(70))
end

local function PreJumpThread(goalX, goalZ, goalHeading, startHeading)
	jumpProg = 0
	StartThread(JetTrailThread)
	local x, _, z = Spring.GetUnitPosition(unitID)
	local heading = startHeading * GG.Script.headingToRad
	local wanted = goalHeading * GG.Script.headingToRad
	wanted = wanted + math.rad(180) % math.rad(360)
	wanted = wanted - heading
	isJumping = true
	jumpflaming = false
	Turn(lgun, x_axis, math.rad(38), math.rad(25.4)) -- 1500ms?
	Turn(rgun, x_axis, math.rad(38), math.rad(25.4))
	Turn(torso, y_axis, wanted, math.rad(200))
	Move(pelvis, y_axis, -7.522, 7.522)
	Turn(rupleg, x_axis, math.rad(42.7), math.rad(42.7))
	Turn(lupleg, x_axis, math.rad(42.7), math.rad(42.7))
	Turn(lfoot, x_axis, math.rad(-45), math.rad(45))
	Turn(rfoot, x_axis, math.rad(-45), math.rad(45))
	WaitForTurn(torso, y_axis)
	WaitForTurn(lgun, x_axis)
	jumpflaming = true
	Move (pelvis, y_axis, 0, 8)
	Turn (rupleg, x_axis, 0, math.rad(140))
	Turn (lupleg, x_axis, 0, math.rad(140))
	Turn (lfoot, x_axis, 0, math.rad(140))
	Turn (rfoot, x_axis, 0, math.rad(140))
end

function preJump(turn, lineDist, flightDist, duration, goalX, goalZ, goalHeading, startHeading)
	Signal(SIG_AIM)
	Signal(SIG_MOVE)
	StartThread(PreJumpThread, goalZ, goalX, goalHeading, startHeading)
end

function halfJump()
	--Turn (torso, y_axis, 0, math.rad(70))
end

function endJump()
	isJumping = false
	Turn(torso, x_axis, 0, math.rad(90))
	Turn(lupleg, x_axis, 0, math.rad(90))
	Turn(rupleg, x_axis, 0, math.rad(90))
	Turn(lloleg, x_axis, 0, math.rad(90))
	Turn(rloleg, x_axis, 0, math.rad(90))
	Turn(rfoot, x_axis, 0, math.rad(90))
	Turn(lfoot, x_axis, 0, math.rad(90))
end

local function PrepareJumpLand()
	Turn(torso, x_axis, math.rad(9.7), math.rad(30))
	Turn(lupleg, x_axis, math.rad(20.1), math.rad(45))
	Turn(rupleg, x_axis, math.rad(20.1), math.rad(45))
	Turn(lloleg, x_axis, math.rad(-45), math.rad(45))
	Turn(rloleg, x_axis, math.rad(-45), math.rad(45))
	Turn(rfoot, x_axis, math.rad(18.9), math.rad(30))
	Turn(lfoot, x_axis, math.rad(18.9), math.rad(30))
end

function jumping(jumpPercent)
	jumpProg = jumpPercent
	if jumpPercent > 95 and isJumping then
		StartThread(PrepareJumpLand)
		jumpflaming = false
		isJumping = false
	end
end


function script.Create()
	bAiming = false
	StartThread(GG.Script.SmokeUnit, unitID, {torso})
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(Stop)
end


local function RestoreAfterDelay()
	Sleep(RESTORE_DELAY)
	local speed = math.rad(50)
	Turn(rflap1, x_axis, 0, speed)
	Turn(rflap2, x_axis, 0, speed)
	Turn(rflap3, y_axis, 0, speed)
	Turn(rflap4, y_axis, 0, speed)
	Turn(lflap1, x_axis, 0, speed)
	Turn(lflap2, x_axis, 0, speed)
	Turn(lflap3, y_axis, 0, speed)
	Turn(lflap4, y_axis, 0, speed)
	Turn(torso, y_axis, 0, speed)
	Turn(torso, x_axis, 0, speed)
	Turn(lgun, x_axis, 0, speed)
	Turn(rgun, x_axis, 0, speed)
	WaitForTurn(torso, y_axis)
	WaitForTurn(torso, x_axis)
	WaitForTurn(lgun, x_axis)
	WaitForTurn(rgun, x_axis)
	bAiming = false
end

function script.AimWeapon(num, heading, pitch)
	if num == 2 or isJumping then return false end
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	
	local aimMult = (Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1)
	
	bAiming = true
	Turn(rflap1, x_axis, 0, math.rad(168)*aimMult)
	Turn(rflap2, x_axis, 0, math.rad(168)*aimMult)
	Turn(rflap3, y_axis, 0, math.rad(168)*aimMult)
	Turn(rflap4, y_axis, 0, math.rad(168)*aimMult)
	Turn(lflap1, x_axis, 0, math.rad(168)*aimMult)
	Turn(lflap2, x_axis, 0, math.rad(168)*aimMult)
	Turn(lflap3, y_axis, 0, math.rad(168)*aimMult)
	Turn(lflap4, y_axis, 0, math.rad(168)*aimMult)
	Turn(rgun, x_axis, - pitch + 0.15, math.rad(168)*aimMult)
	Turn(lgun, x_axis, - pitch + 0.15, math.rad(168)*aimMult)
	Turn(torso, y_axis, heading, math.rad(65)*aimMult)
	WaitForTurn(torso, y_axis)
	WaitForTurn(lgun, x_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.AimFromWeapon(num)
	return torso
end


local function Recoil()
	local barrel = barrels[gun_1]
	EmitSfx(flares[gun_1], 1024)
	Move(barrel, z_axis, -8)
	Sleep(150)
	Move(barrel, z_axis, 0, 10)
end

function script.Shot(num)
	StartThread(Recoil)
	gun_1 = 1 - gun_1
end

function script.QueryWeapon(num)
	return flares[gun_1]
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .50 then
		Explode(base, SFX.NONE)
		Explode(pelvis, SFX.NONE)
		Explode(torso, SFX.NONE)
		Explode(lgun, SFX.FALL)
		Explode(rgun, SFX.FALL)
		Explode(rupleg, SFX.NONE)
		Explode(rloleg, SFX.NONE)
		Explode(rfoot, SFX.NONE)
		Explode(lupleg, SFX.NONE)
		Explode(lloleg, SFX.NONE)
		Explode(lfoot, SFX.NONE)
		return 1
	end
	Explode(base, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(pelvis, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(torso, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lgun, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rgun, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rupleg, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rloleg, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rfoot, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lupleg, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lloleg, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lfoot, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	return 2
end
