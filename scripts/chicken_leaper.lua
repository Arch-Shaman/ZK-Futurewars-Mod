local body = piece 'body' 
local head = piece 'head' 
local tail = piece 'tail' 
local lthigh = piece 'lthigh' 
local lknee = piece 'lknee' 
local lshin = piece 'lshin' 
local lfoot = piece 'lfoot' 
local rthigh = piece 'rthigh' 
local rknee = piece 'rknee' 
local rshin = piece 'rshin' 
local rfoot = piece 'rfoot' 
local lblade = piece 'lblade' 
local rblade = piece 'rblade' 
local legturner = piece 'legturner' 

local rad = math.rad()
local bMoving, lasthit

-- Signal definitions
local SIG_AIM = 2
local SIG_AIM_2 = 4
local SIG_MOVE = 8
local SIG_SHOT = 16

include "constants.lua"

function beginJump()
	bMoving = 0
	EmitSfx(lfoot, 1026)
	EmitSfx(rfoot, 1026)
	Turn(lthigh, x_axis, rad(50), rad(420))
	Turn(lknee, x_axis, rad(-40), rad(420))
	Turn(lshin, x_axis, rad(20), rad(420))
	Turn(lfoot, x_axis, rad(30), rad(420))

	Turn(rthigh, x_axis, rad(50), rad(420))
	Turn(rknee, x_axis, rad(-40), rad(420))
	Turn(rshin, x_axis, rad(20), rad(420))
	Turn(rfoot, x_axis, rad(30), rad(420))
		
	Turn(tail, x_axis, rad(20), rad(400))
	Turn(head, x_axis, rad(-30), rad(400))
end

function endJump()
	EmitSfx(lfoot, 1026)
	EmitSfx(rfoot, 1026)
	Turn(lthigh, x_axis, 0, rad(420))
	Turn(lknee, x_axis, 0, rad(420))
	Turn(lshin, x_axis, 0, rad(420))
	Turn(lfoot, x_axis, 0, rad(420))

	Turn(rthigh, x_axis, 0, rad(420))
	Turn(rknee, x_axis, 0, rad(420))
	Turn(rshin, x_axis, 0, rad(420))
	Turn(rfoot, x_axis, 0, rad(420))
		
	Turn(tail, x_axis, 0, rad(400))
	Turn(head, x_axis, 0, rad(400))
end

local function walk()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while bMoving do
		Turn(lthigh, x_axis, rad(70), rad(420))
		Turn(lknee, x_axis, rad(-40), rad(420))
		Turn(lshin, x_axis, rad(20), rad(420))
		Turn(lfoot, x_axis, rad(30), rad(420))
		
		Turn(rthigh, x_axis, rad(70), rad(420))
		Turn(rknee, x_axis, rad(-40), rad(420))
		Turn(rshin, x_axis, rad(20), rad(420))
		Turn(rfoot, x_axis, rad(30), rad(420))
		
		Move(body, y_axis, 3, 140000)			
		Turn(tail, x_axis, rad(20), rad(400))
		Turn(head, x_axis, rad(-30), rad(400))
		WaitForMove(body, y_axis)
		Move(body, y_axis, 6, 100000)
		WaitForMove(body, y_axis)
		Move(body, y_axis, 9, 60000)
		WaitForMove(body, y_axis)
		Sleep(Rand(0, 50))
		Move(body, y_axis, 6, 60000)
		WaitForMove(body, y_axis)
		Move(body, y_axis, 3, 100000)			
		Turn(lthigh, x_axis, 0, rad(300))
		Turn(lknee, x_axis, 0, rad(300))
		Turn(lshin, x_axis, 0, rad(300))
		Turn(lfoot, x_axis, 0, rad(300))
		
		Turn(rthigh, x_axis, 0, rad(300))
		Turn(rknee, x_axis, 0, rad(300))
		Turn(rshin, x_axis, 0, rad(300))
		Turn(rfoot, x_axis, 0, rad(300))
		
		Turn(head, x_axis, rad(10), rad(320))
		Turn(tail, x_axis, rad(-10), rad(320))
		WaitForMove(body, y_axis)
		Move(body, y_axis, 0, 140000)
		WaitForMove(body, y_axis)
	end
end

local function stopwalk()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	Turn(lfoot, x_axis, 0, rad(200))
	Turn(rfoot, x_axis, 0, rad(200))
	Turn(rthigh, x_axis, 0, rad(200))
	Turn(lthigh, x_axis, 0, rad(200))
	Turn(lshin, x_axis, 0, rad(200))
	Turn(rshin, x_axis, 0, rad(200))
	Turn(lknee, x_axis, 0, rad(200))
	Turn(rknee, x_axis, 0, rad(200))
end

local function ShotThread()
	Signal(SIG_SHOT)
	SetSignalMask(SIG_SHOT)
	bMoving = 0
	Turn(body, x_axis, rad(-30), rad(400))
	Turn(legturner, x_axis, rad(-30), rad(400))
	Turn(lthigh, x_axis, rad(-30), rad(400))
	Turn(lknee, x_axis, rad(-70), rad(420))
	Turn(lshin, x_axis, rad(60), rad(420))
	Turn(rthigh, x_axis, rad(-30), rad(420))
	Turn(rknee, x_axis, rad(-70), rad(420))
	Turn(rshin, x_axis, rad(60), rad(420))
	Move(body, z_axis, 12, 60000)
	Turn(tail, x_axis, rad(-10), rad(320))
	WaitForTurn(lknee, x_axis)
	Turn(body, x_axis, 0, rad(400))
	Turn(legturner, x_axis, 0, rad(400))
	Turn(lthigh, x_axis, 0, rad(400))
	Turn(lknee, x_axis, 0, rad(420))
	Turn(lshin, x_axis, 0, rad(420))
	Turn(rthigh, x_axis, 0, rad(420))
	Turn(rknee, x_axis, 0, rad(420))
	Turn(rshin, x_axis, 0, rad(420))
	Move(body, z_axis, 0, 40000)
	Turn(tail, x_axis, 0, rad(320))
	bMoving = 1
end

function script.StartMoving()
	bMoving = true
	StartThread(walk)
end

function script.StopMoving()
	bMoving = false
	StartThread(stopwalk)
end

function script.Create()
	EmitSfx(body, 1024+2)
end
	
function script.AimFromWeapon(num)
	return head
end

function script.QueryWeapon(num)
	return head
end

local function RestoreAfterDelay()	
	Sleep(1000)
end

function script.AimWeapon(num, heading, pitch)
	return true
end
	
function script.Shot()
	StartThread(ShotThread)
end
	

function script.HitByWeaponId()	
	EmitSfx(body, 1024)
	return 100
end

function script.Killed(recentDamage, maxHealth)	
	EmitSfx(body, 1025)
	return 0
end
