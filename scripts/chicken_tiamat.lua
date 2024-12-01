local body = piece 'body' 
local head = piece 'head' 
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
local lforearml = piece 'lforearml' 
local lbladel = piece 'lbladel' 
local rforearml = piece 'rforearml' 
local rbladel = piece 'rbladel' 
local lforearmu = piece 'lforearmu' 
local lbladeu = piece 'lbladeu' 
local rforearmu = piece 'rforearmu' 
local rbladeu = piece 'rbladeu' 
local spike1 = piece 'spike1' 
local spike2 = piece 'spike2' 
local spike3 = piece 'spike3' 
local firepoint = piece 'firepoint' 
--linear constant 163840

local rad = math.rad
local bMoving
local firepoints = {firepoint, spike2, spike3, body}

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
		Turn(lthighf, z_axis, rad(5), rad(20))
		Turn(rthighf, z_axis, rad(5), rad(20))
		Turn(lthighb, z_axis, rad(5), rad(20))
		Turn(rthighb, z_axis, rad(5), rad(20))
		Move(body, y_axis, 0.7, 4000)			
		Turn(tail, y_axis, rad(10), rad(40))
		Turn(head, x_axis, rad(-10), rad(20))
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
		Turn(head, x_axis, rad(10), rad(20))
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
		Turn(head, x_axis, rad(-10), rad(20))
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
		Turn(head, x_axis, rad(10), rad(20))
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
	Turn(lforearmu, y_axis, rad(-140), rad(600))
	Turn(lbladeu, y_axis, rad(140), rad(600))
	Turn(rforearmu, y_axis, rad(140), rad(600))
	Turn(rbladeu, y_axis, rad(-140), rad(600))
	Turn(lforearml, y_axis, rad(-140), rad(600))
	Turn(lbladel, y_axis, rad(140), rad(600))
	Turn(rforearml, y_axis, rad(140), rad(600))
	Turn(rbladel, y_axis, rad(-140), rad(600))
	WaitForTurn(lbladeu, y_axis)
	Turn(lforearmu, y_axis, 0, rad(120))
	Turn(lbladeu, y_axis, 0, rad(120))
	Turn(rforearmu, y_axis, 0, rad(120))
	Turn(rbladeu, y_axis, 0, rad(120))
	Turn(lforearml, y_axis, 0, rad(120))
	Turn(lbladel, y_axis, 0, rad(120))
	Turn(rforearml, y_axis, 0, rad(120))
	Turn(rbladel, y_axis, 0, rad(120))
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
	return firepoints[num]
end

function script.QueryWeapon(num)
	return firepoints[num]
end

local function RestoreAfterDelay()	
	Sleep(1000)
end

function script.AimWeapon(num, heading, pitch)
	if num ~= 1 then
		return true
	end
	
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(head, y_axis, heading, rad(250))
	Turn(head, x_axis, -pitch, rad(200))
		
	WaitForTurn(head, y_axis)
	StartThread(RestoreAfterDelay)
	
	return(true)
end

function script.Shot(num)
	if num ~= 1 then
		return
	end

	StartThread(ShotThread)
end

function script.HitByWeaponId()
	EmitSfx(body, 1024)
	return 100
end

function script.Killed(recentDamage, maxHealth)
	EmitSfx(body, 1025)
	EmitSfx(head, 1025)
	EmitSfx(rbladeu, 1025)
	EmitSfx(lbladel, 1025)
	EmitSfx(tail, 1025)
	EmitSfx(rthighf, 1025)
	EmitSfx(rthighb, 1025)
	EmitSfx(lthighf, 1025)
	EmitSfx(lthighb, 1025)
	EmitSfx(rfootf, 1025)
	EmitSfx(rfootb, 1025)
	EmitSfx(lfootf, 1025)
	EmitSfx(lfootb, 1025)
	Explode(body, SFX.FALL + SFX.EXPLODE)
	Explode(head, SFX.FALL + SFX.EXPLODE)
	Explode(tail, SFX.FALL + SFX.EXPLODE)
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
	Explode(lforearml, SFX.FALL + SFX.EXPLODE)
	Explode(lbladel, SFX.FALL + SFX.EXPLODE)
	Explode(rforearml, SFX.FALL + SFX.EXPLODE)
	Explode(rbladel, SFX.FALL + SFX.EXPLODE)
	Explode(lforearmu, SFX.FALL + SFX.EXPLODE)
	Explode(lbladeu, SFX.FALL + SFX.EXPLODE)
	Explode(rforearmu, SFX.FALL + SFX.EXPLODE)
	Explode(rbladeu, SFX.FALL + SFX.EXPLODE)
	Explode(spike1, SFX.FALL + SFX.EXPLODE)
	Explode(spike2, SFX.FALL + SFX.EXPLODE)
	Explode(spike3, SFX.FALL + SFX.EXPLODE)
	Explode(firepoint, SFX.FALL + SFX.EXPLODE)
	return 0
end
