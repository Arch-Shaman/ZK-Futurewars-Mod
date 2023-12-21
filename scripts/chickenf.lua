local body = piece 'body' 
local head = piece 'head' 
local tail = piece 'tail' 
local lwing = piece 'lwing' 
local rwing = piece 'rwing' 
local lblade = piece 'lblade' 
local mblade = piece 'mblade' 
local rblade = piece 'rblade' 
local rsack = piece 'rsack' 
local lsack = piece 'lsack' 

local rad = math.rad
local bMoving

-- Signal definitions
local SIG_AIM = 2
local SIG_AIM_2 = 4
local SIG_MOVE = 8
local SIG_SHOT = 16

include "constants.lua"

local function fly()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while bMoving do
		Turn(lwing, z_axis, rad(40), rad(60))
		Turn(rwing, z_axis, rad(-40), rad(60))
		WaitForTurn(lwing, z_axis)
		Turn(lwing, z_axis, rad(-40), rad(120))
		Turn(rwing, z_axis, rad(40), rad(120))
		WaitForTurn(lwing, z_axis)
	end
end

local function stopfly()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	Turn(lwing, z_axis, rad(0), rad(200))
	Turn(rwing, z_axis, rad(0), rad(200))
end

local function ShotThread()
	Signal(SIG_SHOT)
	SetSignalMask(SIG_SHOT)
	Turn(lsack, y_axis, rad(40), rad(1))
	Turn(rsack, y_axis, rad(-40), rad(1))
	Move(rsack, x_axis, 1, 1)
	Move(lsack, x_axis, -1, 1)
	Move(mblade, z_axis, -8, 100)
	WaitForTurn(lsack, y_axis)
	Turn(lsack, y_axis, 0, rad(0.3))
	Turn(rsack, y_axis, 0, rad(0.3))
	Move(rsack, x_axis, -0, 0.3)
	Move(lsack, x_axis, -0, 0.3)
	Move(mblade, z_axis, 0, 3)
end

function script.StartMoving()
	bMoving = true
	StartThread(fly)
end

function script.StopMoving()
	bMoving = false
	StartThread(stopfly)
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
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(head, x_axis, -pitch, rad(200))
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
	EmitSfx(body, 1025)
	return 0
end
