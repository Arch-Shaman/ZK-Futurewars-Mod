include "constants.lua"

--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------
local base, pelvis, torso = piece("base", "pelvis", "torso")
local rthigh, rleg, rfoot, lthigh, lleg, lfoot = piece("rthigh", "rleg", "rfoot", "lthigh", "lleg", "lfoot")
local lbturret, lbbarrel1, lbbarrel2, rbturret, rbbarrel1, rbbarrel2 = piece("lbturret", "lbbarrel1", "lbbarrel2", "rbturret", "rbbarrel1", "rbbarrel2")
local lbflare1, lbflare2, rbflare1, rbflare2 = piece("lbflare1", "lbflare2", "rbflare1", "rbflare2")
local luparm, llarm, lfbarrel1, lfbarrel2, lfflare1, lfflare2 = piece("luparm", "llarm", "lfbarrel1", "lfbarrel2", "lfflare1", "lfflare2")
local ruparm, rlarm, rfbarrel1, rfbarrel2, rfflare1, rfflare2 = piece("ruparm", "rlarm", "rfbarrel1", "rfbarrel2", "rfflare1", "rfflare2")

local gunIndex = {1,1,1}
local flares = {
    {lfflare1, lfflare2, rfflare1, rfflare2},
    {lbflare1, rbflare1, lbflare2, rbflare2},
    {base}
}

smokePiece = {torso}

--------------------------------------------------------------------------------
-- constants
--------------------------------------------------------------------------------
-- Signal definitions
local SIG_WALK = 1
local SIG_RESTORE = 8
local SIG_AIM = 2

local TORSO_SPEED_YAW = math.rad(240)
local ARM_SPEED_PITCH = math.rad(120)

local PACE = 2

local THIGH_FRONT_ANGLE = -math.rad(50)
local THIGH_FRONT_SPEED = math.rad(60) * PACE
local THIGH_BACK_ANGLE = math.rad(30)
local THIGH_BACK_SPEED = math.rad(60) * PACE
local SHIN_FRONT_ANGLE = math.rad(45)
local SHIN_FRONT_SPEED = math.rad(90) * PACE
local SHIN_BACK_ANGLE = math.rad(10)
local SHIN_BACK_SPEED = math.rad(90) * PACE

local ARM_FRONT_ANGLE = -math.rad(20)
local ARM_FRONT_SPEED = math.rad(22.5) * PACE
local ARM_BACK_ANGLE = math.rad(10)
local ARM_BACK_SPEED = math.rad(22.5) * PACE
--[[
local FOREARM_FRONT_ANGLE = -math.rad(15)
local FOREARM_FRONT_SPEED = math.rad(40) * PACE
local FOREARM_BACK_ANGLE = -math.rad(10)
local FOREARM_BACK_SPEED = math.rad(40) * PACE
]]--

local TORSO_ANGLE_MOTION = math.rad(10)
local TORSO_SPEED_MOTION = math.rad(15)*PACE

local LEG_JUMP_COIL_ANGLE = math.rad(15)
local LEG_JUMP_COIL_SPEED = math.rad(90)
local LEG_JUMP_RELEASE_ANGLE = math.rad(18)
local LEG_JUMP_RELEASE_SPEED = math.rad(420)

local UPARM_JUMP_COIL_ANGLE = math.rad(15)
local UPARM_JUMP_COIL_SPEED = math.rad(60)
local LARM_JUMP_COIL_ANGLE = math.rad(30)
local LARM_JUMP_COIL_SPEED = math.rad(90)
local UPARM_JUMP_RELEASE_ANGLE = math.rad(80)
local UPARM_JUMP_RELEASE_SPEED = math.rad(240)
local LARM_JUMP_RELEASE_ANGLE = math.rad(90)
local LARM_JUMP_RELEASE_SPEED = math.rad(360)

local RESTORE_DELAY = 6000


--------------------------------------------------------------------------------
-- vars
--------------------------------------------------------------------------------
local armsFree = true
local jumpDir = 1
local bJumping = false
local bSomersault = false

--------------------------------------------------------------------------------
-- funcs
--------------------------------------------------------------------------------
local function RestorePose()
	Turn(base, x_axis, 0, math.rad(60))
	Move(pelvis , y_axis, 0 , 1 )
	Turn(rthigh , x_axis, 0, math.rad(200) )
	Turn(rleg , x_axis, 0, math.rad(200) )
	Turn(lthigh , x_axis, 0, math.rad(200) )
	Turn(lleg , x_axis, 0, math.rad(200) )
	Turn(luparm, x_axis, 0, math.rad(120))
	Turn(ruparm, x_axis, 0, math.rad(120))   
	Turn(llarm, x_axis, 0, math.rad(180))
	Turn(rlarm, x_axis, 0, math.rad(180))
	Turn(luparm, z_axis, math.rad(45))
	Turn(ruparm, z_axis, math.rad(-45))
	bJumping = false
end

-- jump stuff
function preJump(turn,distance)
	Signal(SIG_WALK)
	Signal(SIG_RESTORE)
	bJumping = true
	local radians = turn*2*math.pi/2^16
	if radians > 0 then
		if radians > math.rad(120) then
			jumpDir = 3
		elseif radians > math.rad(60) then
			jumpDir = 2
		else
			jumpDir = 1
		end
	else
		if radians < math.rad(-120) then
			jumpDir = 3
		elseif radians < math.rad(-60) then
			jumpDir = 4
		else
			jumpDir = 1
		end    
	end

	Move(pelvis, y_axis, -5, 10)
	Turn(torso, y_axis, 0, math.rad(180))

	Turn(lthigh, y_axis, math.rad(30), math.rad(60))
	Turn(rthigh, y_axis, math.rad(-30), math.rad(60))
	Turn(lthigh, x_axis, -LEG_JUMP_COIL_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(rthigh, x_axis, -LEG_JUMP_COIL_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(lleg, x_axis, LEG_JUMP_COIL_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(rleg, x_axis, LEG_JUMP_COIL_ANGLE, LEG_JUMP_COIL_SPEED)

	Turn(luparm, z_axis, UPARM_JUMP_COIL_ANGLE, UPARM_JUMP_COIL_SPEED)
	Turn(ruparm, z_axis, -UPARM_JUMP_COIL_ANGLE, UPARM_JUMP_COIL_SPEED)
	Turn(llarm, x_axis, LARM_JUMP_COIL_ANGLE, LARM_JUMP_COIL_SPEED)
	Turn(rlarm, x_axis, LARM_JUMP_COIL_ANGLE, LARM_JUMP_COIL_SPEED)       
end

local function Somersault()
	Sleep(100)
	if jumpDir == 1 then
			Turn(pelvis, x_axis, math.rad(22), math.rad(40))
	elseif jumpDir == 2 then
	elseif jumpDir == 3 then
			Turn(pelvis, x_axis, math.rad(-22), math.rad(40))
	else
	end
	Sleep(200)

	Turn(lthigh, x_axis, LEG_JUMP_COIL_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(rthigh, x_axis, LEG_JUMP_COIL_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(lleg, x_axis, LEG_JUMP_COIL_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(rleg, x_axis, LEG_JUMP_COIL_ANGLE, LEG_JUMP_COIL_SPEED)        
	if jumpDir == 1 then
		Turn(pelvis, x_axis, math.rad(200), math.rad(240))
	elseif jumpDir == 3 then
		Turn(pelvis, x_axis, math.rad(-200), math.rad(240))
	end
	WaitForTurn(pelvis, x_axis)
	Turn(pelvis, x_axis, 0, math.rad(240))
	Turn(lthigh, x_axis, LEG_JUMP_RELEASE_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(rthigh, x_axis, LEG_JUMP_RELEASE_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(lleg, x_axis, -2*LEG_JUMP_RELEASE_ANGLE, LEG_JUMP_COIL_SPEED)
	Turn(rleg, x_axis, -2*LEG_JUMP_RELEASE_ANGLE, LEG_JUMP_COIL_SPEED)
	bSomersault = false
end

function beginJump()
        Move(pelvis, y_axis, 0, 24)
        Turn(lthigh, y_axis, 0, math.rad(180))
        Turn(rthigh, y_axis, 0, math.rad(180))
        Turn(lthigh, x_axis, LEG_JUMP_RELEASE_ANGLE, LEG_JUMP_RELEASE_SPEED)
        Turn(rthigh, x_axis, LEG_JUMP_RELEASE_ANGLE, LEG_JUMP_RELEASE_SPEED)
        Turn(lleg, x_axis, -2*LEG_JUMP_RELEASE_ANGLE, LEG_JUMP_RELEASE_SPEED)
        Turn(rleg, x_axis, -2*LEG_JUMP_RELEASE_ANGLE, LEG_JUMP_RELEASE_SPEED)
        
        Turn(luparm, z_axis, UPARM_JUMP_RELEASE_ANGLE, UPARM_JUMP_RELEASE_SPEED)
        Turn(ruparm, z_axis, -UPARM_JUMP_RELEASE_ANGLE, UPARM_JUMP_RELEASE_SPEED)
        Turn(llarm, x_axis, LARM_JUMP_RELEASE_ANGLE, LARM_JUMP_RELEASE_SPEED)
        Turn(rlarm, x_axis, LARM_JUMP_RELEASE_ANGLE, LARM_JUMP_RELEASE_SPEED)
		bJumping = true
        bSomersault = true
		StartThread(Somersault)
end

function jumping()
end

local function CollisionDamageRestoreThread()
	Sleep(2000)
	GG.SetCollisionDamageMult(unitID, 1)
end


function halfJump()
	GG.SetCollisionDamageMult(unitID, 0)
end

function jumping(jumpPercent)
	if jumpPercent < 40 then
		GG.PokeDecloakUnit(unitID, unitDefID)
		EmitSfx(lfoot, 1028)
		EmitSfx(rfoot, 1028)
	end
	if jumpPercent > 70 and bJumping then
		RestorePose()
		bJumping = false
	end
end

function endJump()
	EmitSfx(base, 4096 + 2)
	bJumping = false
	StartThread(CollisionDamageRestoreThread)
end

-- not jump stuff

local function Walk()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	Turn(base, x_axis, math.rad(10), math.rad(30))
	while true do
		--left leg up, right leg back
		Turn(lthigh, x_axis, THIGH_FRONT_ANGLE, THIGH_FRONT_SPEED)
		Turn(lleg, x_axis, SHIN_FRONT_ANGLE, SHIN_FRONT_SPEED)
		Turn(rthigh, x_axis, THIGH_BACK_ANGLE, THIGH_BACK_SPEED)
		Turn(rleg, x_axis, SHIN_BACK_ANGLE, SHIN_BACK_SPEED)
		if (armsFree) then
			--left arm back, right arm front
			Turn(torso, y_axis, TORSO_ANGLE_MOTION, TORSO_SPEED_MOTION)
			Turn(luparm, x_axis, ARM_BACK_ANGLE, ARM_BACK_SPEED)
			Turn(ruparm, x_axis, ARM_FRONT_ANGLE, ARM_FRONT_SPEED)
		end
		WaitForTurn(lthigh, x_axis)
		Sleep(0)
		
		--right leg up, left leg back
		Turn(lthigh, x_axis,  THIGH_BACK_ANGLE, THIGH_BACK_SPEED)
		Turn(lleg, x_axis, SHIN_BACK_ANGLE, SHIN_BACK_SPEED)
		Turn(rthigh, x_axis, THIGH_FRONT_ANGLE, THIGH_FRONT_SPEED)
		Turn(rleg, x_axis, SHIN_FRONT_ANGLE, SHIN_FRONT_SPEED)
		if (armsFree) then
			--left arm front, right arm back
			Turn(torso, y_axis, -TORSO_ANGLE_MOTION, TORSO_SPEED_MOTION)
			Turn(luparm, x_axis, ARM_FRONT_ANGLE, ARM_FRONT_SPEED)
			Turn(ruparm, x_axis, ARM_BACK_ANGLE, ARM_BACK_SPEED)
		end
		WaitForTurn(rthigh, x_axis)		
		Sleep(0)
	end
end

function script.Create()
	Turn(luparm, z_axis, math.rad(45))
	Turn(ruparm, z_axis, math.rad(-45))
	Turn(lbflare1, x_axis, math.rad(-105))
	Turn(lbflare2, x_axis, math.rad(-105))
	Turn(rbflare1, x_axis, math.rad(-105))
	Turn(rbflare2, x_axis, math.rad(-105))
	Turn(lbflare1, z_axis, math.rad(-30))
	Turn(lbflare2, z_axis, math.rad(-30))
	Turn(rbflare1, z_axis, math.rad(30))
	Turn(rbflare2, z_axis, math.rad(30))
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

function script.StartMoving() 
	StartThread(Walk)
end

function script.StopMoving() 
	Signal(SIG_WALK)
	StartThread(RestorePose)
end

local function RestoreAfterDelay()
	Signal(SIG_RESTORE)
	SetSignalMask(SIG_RESTORE)
	Sleep(RESTORE_DELAY)
	armsFree = true
	Turn(torso, y_axis, 0,  TORSO_SPEED_YAW)
	Turn(luparm, x_axis, 0, ARM_SPEED_PITCH)
	Turn(ruparm, x_axis, 0, ARM_SPEED_PITCH)
end


function script.AimWeapon(num, heading, pitch)
	if num == 1 or num == 4 then
		if bJumping then return false end
		Signal(SIG_AIM)
		SetSignalMask(SIG_AIM)
		armsFree = false
		Turn(torso, y_axis, heading,  TORSO_SPEED_YAW)
		Turn(luparm, x_axis, -pitch, ARM_SPEED_PITCH)
		Turn(ruparm, x_axis, -pitch, ARM_SPEED_PITCH)
		WaitForTurn(torso, y_axis)
		WaitForTurn(luparm, x_axis)
		WaitForTurn(ruparm, x_axis)
	end
	return true
end

function script.FireWeapon(num)
end

local function RecoilThread(barrel)
	Move(barrel, z_axis, -3.72, -20)
	Sleep(99)
	Move(barrel, z_axis, -3.72, -10.5)
	Sleep(99)
	Move(barrel, z_axis, -3.72, -5)
	WaitForMove(barrel, z_axis)
	Move(barrel, z_axis, 0, 9)
end

local barrels = {[1] = lfbarrel1, [2] = lfbarrel2, [3] = rfbarrel1, [4] = rfbarrel2}

function script.Shot(num)
	if num == 4 then num = 1 end
	gunIndex[num] = gunIndex[num] + 1
	if gunIndex[num] > 4 then gunIndex[num] = 1 end
	if num == 1 then
		StartThread(RecoilThread, barrels[gunIndex[1]])
		EmitSfx(flares[num][gunIndex[num]], 1024)
		EmitSfx(flares[num][gunIndex[num]], 1026)
	else
		EmitSfx(flares[num][gunIndex[num]], 1027)
	end
end

function script.QueryWeapon(num)
	if num == 4 then
		return flares[1][gunIndex[1]]
	else
		return(flares[num][gunIndex[num]])
	end
end

function script.AimFromWeapon(num)
	return torso
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	local effect = SFX.NONE
	if severity < 0.5 then
		Explode(torso, effect)
		Explode(luparm, effect)
		Explode(ruparm, effect)
		Explode(pelvis, effect)
		Explode(lthigh, effect)
		Explode(rthigh, effect)
		Explode(rleg, effect)
		Explode(lleg, effect)
		return 1
	else
		effect = SFX.SMOKE + SFX.FIRE + SFX.EXPLODE + SFX.FALL
		Explode(torso, SFX.SHATTER)
		Explode(luparm, effect)
		Explode(ruparm, effect)
		Explode(pelvis, SFX.SHATTER)
		Explode(lthigh, effect)
		Explode(rthigh, effect)
		Explode(rleg, effect)
		Explode(lleg, effect)
		return 2
	end
end
