local body = piece 'body' 
local head = piece 'head' 
local rsack = piece 'rsack' 
local lsack = piece 'lsack' 
local neck = piece 'neck' 
local tail = piece 'tail' 
local lthighf = piece 'lthighf' 
local lkneef = piece 'lkneef' 
local lshinf = piece 'lshinf' 
local lfootf = piece 'lfootf' 
local rthighf = piece 'rthighf' 
local rkneef = piece 'rkneef' 
local rshinf = piece 'rshinf' 
local rfootf = piece 'rfootf' 
local lthighb = piece 'lthighb' 
local lkneeb = piece 'lkneeb' 
local lshinb = piece 'lshinb' 
local lfootb = piece 'lfootb' 
local rthighb = piece 'rthighb' 
local rkneeb = piece 'rkneeb' 
local rshinb = piece 'rshinb' 
local rfootb = piece 'rfootb' 
local firepoint = piece 'firepoint' 
--linear constant 163840

local rad = math.rad
local pi = math.pi
local bMoving, gun_1
local permitSalvo = false

-- Signal definitions
local SIG_AIM = 2
local SIG_AIM_2 = 4
local SIG_MOVE = 8
local SIG_SHOT = 16
local SIG_BUILD = include "constants.lua"

function walk()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while bMoving do
		Turn(lthighf, x_axis, rad(70), rad(115))
		Turn(lkneef, x_axis, rad(-40), rad(145))
		Turn(lshinf, x_axis, rad(20), rad(145))
		Turn(lfootf, x_axis, rad(-50), rad(210))
		
		Turn(rthighf, x_axis, rad(-20), rad(210))
		Turn(rkneef, x_axis, rad(-60), rad(210))
		Turn(rshinf, x_axis, rad(50), rad(210))
		Turn(rfootf, x_axis, rad(30), rad(210))
		
		Turn(rthighb, x_axis, rad(70), rad(115))
		Turn(rkneeb, x_axis, rad(-40), rad(145))
		Turn(rshinb, x_axis, rad(20), rad(145))
		Turn(rfootb, x_axis, rad(-50), rad(210))
		
		Turn(lthighb, x_axis, rad(-20), rad(210))
		Turn(lkneeb, x_axis, rad(-60), rad(210))
		Turn(lshinb, x_axis, rad(50), rad(210))
		Turn(lfootb, x_axis, rad(30), rad(210))
		
		Turn(body, z_axis, rad(-5), rad(20))
		Turn(lthighf, z_axis, rad(-5), rad(20))
		Turn(rthighf, z_axis, rad(-5), rad(20))
		Turn(lthighb, z_axis, rad(-5), rad(20))
		Turn(rthighb, z_axis, rad(-5), rad(20))
		Move(body, y_axis, 0.7, 4000)
		Turn(tail, y_axis, rad(10), rad(40))
		Turn(tail, x_axis, rad(10), rad(20))
		WaitForTurn(lthighf, x_axis)
		
		Turn(lthighf, x_axis, rad(-10), rad(160))
		Turn(lkneef, x_axis, rad(15), rad(145))
		Turn(lshinf, x_axis, rad(-60), rad(250))
		Turn(lfootf, x_axis, rad(30), rad(145))
		
		Turn(rthighf, x_axis, rad(40), rad(145))
		Turn(rkneef, x_axis, rad(-35), rad(145))
		Turn(rshinf, x_axis, rad(-40), rad(145))
		Turn(rfootf, x_axis, rad(35), rad(145))
		
		Turn(rthighb, x_axis, rad(-10), rad(160))
		Turn(rkneeb, x_axis, rad(15), rad(145))
		Turn(rshinb, x_axis, rad(-60), rad(250))
		Turn(rfootb, x_axis, rad(30), rad(145))
		
		Turn(lthighb, x_axis, rad(40), rad(145))
		Turn(lkneeb, x_axis, rad(-35), rad(145))
		Turn(lshinb, x_axis, rad(-40), rad(145))
		Turn(lfootb, x_axis, rad(35), rad(145))
		
		Move(body, y_axis, 0, 4000)
		Turn(tail, x_axis, rad(-10), rad(20))
		WaitForTurn(lshinf, x_axis)
		
		Turn(rthighf, x_axis, rad(70), rad(115))
		Turn(rkneef, x_axis, rad(-40), rad(145))
		Turn(rshinf, x_axis, rad(20), rad(145))
		Turn(rfootf, x_axis, rad(-50), rad(210))
		
		Turn(lthighf, x_axis, rad(-20), rad(210))
		Turn(lkneef, x_axis, rad(-60), rad(210))
		Turn(lshinf, x_axis, rad(50), rad(210))
		Turn(lfootf, x_axis, rad(30), rad(210))
					
		Turn(lthighb, x_axis, rad(70), rad(115))
		Turn(lkneeb, x_axis, rad(-40), rad(145))
		Turn(lshinb, x_axis, rad(20), rad(145))
		Turn(lfootb, x_axis, rad(-50), rad(210))
		
		Turn(rthighb, x_axis, rad(-20), rad(210))
		Turn(rkneeb, x_axis, rad(-60), rad(210))
		Turn(rshinb, x_axis, rad(50), rad(210))
		Turn(rfootb, x_axis, rad(30), rad(210))
		
		Turn(tail, y_axis, rad(-10), rad(40))
		Turn(body, z_axis, rad(5), rad(20))
		Turn(lthighf, z_axis, rad(-5), rad(20))
		Turn(rthighf, z_axis, rad(-5), rad(20))
		Turn(lthighb, z_axis, rad(-5), rad(20))
		Turn(rthighb, z_axis, rad(-5), rad(20))
		Move(body, y_axis, 0.7, 4000)
		Turn(tail, x_axis, rad(10), rad(20))
		WaitForTurn(rthighf, x_axis)
		
		Turn(rthighf, x_axis, rad(-10), rad(160))
		Turn(rkneef, x_axis, rad(15), rad(145))
		Turn(rshinf, x_axis, rad(-60), rad(250))
		Turn(rfootf, x_axis, rad(30), rad(145))
		
		Turn(lthighf, x_axis, rad(40), rad(145))
		Turn(lkneef, x_axis, rad(-35), rad(145))
		Turn(lshinf, x_axis, rad(-40), rad(145))
		Turn(lfootf, x_axis, rad(35), rad(145))
					
		Turn(lthighb, x_axis, rad(-10), rad(160))
		Turn(lkneeb, x_axis, rad(15), rad(145))
		Turn(lshinb, x_axis, rad(-60), rad(250))
		Turn(lfootb, x_axis, rad(30), rad(145))
		
		Turn(rthighb, x_axis, rad(40), rad(145))
		Turn(rkneeb, x_axis, rad(-35), rad(145))
		Turn(rshinb, x_axis, rad(-40), rad(145))
		Turn(rfootb, x_axis, rad(35), rad(145))

		Move(body, y_axis, 0, 4000)
		Turn(tail, x_axis, rad(-10), rad(20))
		WaitForTurn(rshinf, x_axis)
	end
end

local function stopwalk()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	Turn(lfootf, x_axis, 0, rad(200))
	Turn(rfootf, x_axis, 0, rad(200))
	Turn(rthighf, x_axis, 0, rad(200))
	Turn(lthighf, x_axis, 0, rad(200))
	Turn(lshinf, x_axis, 0, rad(200))
	Turn(rshinf, x_axis, 0, rad(200))
	Turn(lkneef, x_axis, 0, rad(200))
	Turn(rkneef, x_axis, 0, rad(200))
	Turn(lfootb, x_axis, 0, rad(200))
	Turn(rfootb, x_axis, 0, rad(200))
	Turn(rthighb, x_axis, 0, rad(200))
	Turn(lthighb, x_axis, 0, rad(200))
	Turn(lshinb, x_axis, 0, rad(200))
	Turn(rshinb, x_axis, 0, rad(200))
	Turn(lkneeb, x_axis, 0, rad(200))
	Turn(rkneeb, x_axis, 0, rad(200))
end

local function ShotThread()
	Signal(SIG_SHOT)
	SetSignalMask(SIG_SHOT)
	permitSalvo = true
	Turn(lsack, y_axis, rad(30), rad(200))
	Turn(rsack, y_axis, rad(-30), rad(200))
	Move(rsack, x_axis, 1, 9)
	Move(lsack, x_axis, -1, 9)
	WaitForTurn(lsack, y_axis)
	Turn(lsack, y_axis, 0, rad(20))
	Turn(rsack, y_axis, 0, rad(20))
	Move(rsack, x_axis, -0, 0.3)
	Move(lsack, x_axis, -0, 0.3)
	Sleep(100)
	permitSalvo = false
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
	EmitSfx(body, 1026)
	EmitSfx(head, 1026)
	EmitSfx(tail, 1026)
end

function script.AimFromWeapon(num)
	return head
end

function script.QueryWeapon(num)
	return firepoint
end

function script.AimWeapon(num, heading, pitch)
	if num ~= 1 then
		return true
	end

	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	if heading > pi then
		heading = heading - 2*pi
	end
	Turn(head, y_axis, heading/2, rad(250))
	Turn(head, x_axis, -pitch/2, rad(200))
	Turn(body, y_axis, heading/2, rad(250))
	Turn(body, x_axis, -pitch/2, rad(200))
	WaitForTurn(head, y_axis)
	
	return true
end
	
function script.FireWeapon(num)
	if num == 1 then
		StartThread(ShotThread)
	end
end

function script.BlockShot(num, targetUnitID, userTarget)
	return (num ~= 1 and (not permitSalvo))
end
	

function script.HitByWeaponId()	
	EmitSfx(body, 1024)
	return 100
end

function script.Killed(recentDamage, maxHealth)
	EmitSfx(body, 1025)
	EmitSfx(head, 1025)
	EmitSfx(tail, 1025)
	EmitSfx(rthighf, 1025)
	EmitSfx(rthighb, 1025)
	EmitSfx(lthighf, 1025)
	EmitSfx(lthighb, 1025)
	EmitSfx(rfootf, 1025)
	EmitSfx(rfootb, 1025)
	EmitSfx(lfootf, 1025)
	EmitSfx(lfootb, 1025)
	Explode(lthighf, SFX.FALL + SFX.EXPLODE)
	Explode(lkneef, SFX.FALL + SFX.EXPLODE)
	Explode(lshinf, SFX.FALL + SFX.EXPLODE)
	Explode(lfootf, SFX.FALL + SFX.EXPLODE)
	Explode(rthighf, SFX.FALL + SFX.EXPLODE)
	Explode(rkneef, SFX.FALL + SFX.EXPLODE)
	Explode(rshinf, SFX.FALL + SFX.EXPLODE)
	Explode(rfootf, SFX.FALL + SFX.EXPLODE)
	Explode(lthighb, SFX.FALL + SFX.EXPLODE)
	Explode(lkneeb, SFX.FALL + SFX.EXPLODE)
	Explode(lshinb, SFX.FALL + SFX.EXPLODE)
	Explode(lfootb, SFX.FALL + SFX.EXPLODE)
	Explode(rthighb, SFX.FALL + SFX.EXPLODE)
	Explode(rkneeb, SFX.FALL + SFX.EXPLODE)
	Explode(rshinb, SFX.FALL + SFX.EXPLODE)
	Explode(rfootb, SFX.FALL + SFX.EXPLODE)
	return 0
end
