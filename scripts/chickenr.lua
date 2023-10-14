local base = piece 'base' 
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
local rsack = piece 'rsack' 
local lsack = piece 'lsack' 

local rad = math.rad
local pi = math.pi
local bMoving

-- Signal definitions
local SIG_AIM = 2
local SIG_AIM_2 = 4
local SIG_MOVE = 8
local SIG_SHOT = 16

include "constants.lua"

local function walk()		
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while bMoving do
		Turn(lthigh, x_axis, rad(70), rad(115))
		Turn(lknee, x_axis, rad(-40), rad(145))
		Turn(lshin, x_axis, rad(20), rad(145))
		Turn(lfoot, x_axis, rad(-50), rad(210))
		
		Turn(rthigh, x_axis, rad(-20), rad(210))
		Turn(rknee, x_axis, rad(-60), rad(210))
		Turn(rshin, x_axis, rad(50), rad(210))
		Turn(rfoot, x_axis, rad(30), rad(210))
		
		Turn(base, z_axis, rad(-5), rad(20))
		Turn(lthigh, z_axis, rad(5), rad(20))
		Turn(rthigh, z_axis, rad(5), rad(20))
		Move(base, y_axis, 0.7, 4000)			
		Turn(tail, y_axis, rad(10), rad(40))
		Turn(head, x_axis, rad(-10), rad(20))
		Turn(tail, x_axis, rad(10), rad(20))
		WaitForTurn(lthigh, x_axis)
		
		Turn(lthigh, x_axis, rad(-10), rad(160))
		Turn(lknee, x_axis, rad(15), rad(145))
		Turn(lshin, x_axis, rad(-60), rad(250))
		Turn(lfoot, x_axis, rad(30), rad(145))
		
		Turn(rthigh, x_axis, rad(40), rad(145))
		Turn(rknee, x_axis, rad(-35), rad(145))
		Turn(rshin, x_axis, rad(-40), rad(145))
		Turn(rfoot, x_axis, rad(35), rad(145))
		
		Move(base, y_axis, 0, 4000)
		Turn(head, x_axis, rad(10), rad(20))
		Turn(tail, x_axis, rad(-10), rad(20))
		WaitForTurn(lshin, x_axis)
		
		Turn(rthigh, x_axis, rad(70), rad(115))
		Turn(rknee, x_axis, rad(-40), rad(145))
		Turn(rshin, x_axis, rad(20), rad(145))
		Turn(rfoot, x_axis, rad(-50), rad(210))
		
		Turn(lthigh, x_axis, rad(-20), rad(210))
		Turn(lknee, x_axis, rad(-60), rad(210))
		Turn(lshin, x_axis, rad(50), rad(210))
		Turn(lfoot, x_axis, rad(30), rad(210))
		
		Turn(tail, y_axis, rad(-10), rad(40))
		Turn(base, z_axis, rad(5), rad(20))
		Turn(lthigh, z_axis, rad(-5), rad(20))
		Turn(rthigh, z_axis, rad(-5), rad(20))
		Move(base, y_axis, 0.7, 4000)
		Turn(head, x_axis, rad(-10), rad(20))
		Turn(tail, x_axis, rad(10), rad(20))
		WaitForTurn(rthigh, x_axis)
		
		Turn(rthigh, x_axis, rad(-10), rad(160))
		Turn(rknee, x_axis, rad(15), rad(145))
		Turn(rshin, x_axis, rad(-60), rad(250))
		Turn(rfoot, x_axis, rad(30), rad(145))
		
		Turn(lthigh, x_axis, rad(40), rad(145))
		Turn(lknee, x_axis, rad(-35), rad(145))
		Turn(lshin, x_axis, rad(-40), rad(145))
		Turn(lfoot, x_axis, rad(35), rad(145))
		
		
		Move(base, y_axis, 0, 4000)
		Turn(head, x_axis, rad(10), rad(20))
		Turn(tail, x_axis, rad(-10), rad(20))
		WaitForTurn(rshin, x_axis)
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
	Turn(lsack, y_axis, rad(30), rad(200))
	Turn(rsack, y_axis, rad(-30), rad(200))
	Move(rsack, x_axis, 1, 9)
	Move(lsack, x_axis, -1, 9)
	WaitForTurn(lsack, y_axis)
	Turn(lsack, y_axis, 0, rad(20))
	Turn(rsack, y_axis, 0, rad(20))
	Move(rsack, x_axis, -0, 0.3)
	Move(lsack, x_axis, -0, 0.3)
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

local function RestoreAfterDelay()
	Sleep(1200)
	Turn(head, y_axis, rad(0), rad(25))
	Turn(head, x_axis, rad(0), rad(20))
	Turn(body, y_axis, rad(0), rad(25))
	Turn(body, x_axis, rad(0), rad(20))
end
	
function script.AimFromWeapon(num)
	return head
end

function script.QueryWeapon(num)
	return head
end

function script.AimWeapon(num, heading, pitch)	
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(head, y_axis, pi+((heading-pi)/2), rad(250))
	Turn(head, x_axis, -pitch/2, rad(200))
	Turn(body, y_axis, pi+((heading-pi)/2), rad(250))
	Turn(body, x_axis, -pitch/2, rad(200))
	WaitForTurn(head, y_axis)
	StartThread(RestoreAfterDelay)
	
	return true
end
	
function script.Shot(num)
	StartThread(ShotThread)
end
	

function script.HitByWeaponId()	
	EmitSfx(body, 1024)
	return 100
end

function script.Killed(recentDamage, maxHealth)
	corpsetype = 1
	EmitSfx(body, 1025)
	return 0
end
