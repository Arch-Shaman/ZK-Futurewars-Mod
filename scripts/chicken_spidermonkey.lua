local body = piece 'body' 
local head = piece 'head' 
local tail1 = piece 'tail1' 
local tail2 = piece 'tail2' 
local firepoint = piece 'firepoint' 
local lthighf = piece 'lthighf' 
local lkneef = piece 'lkneef' 
local lshinf = piece 'lshinf' 
local lfootf = piece 'lfootf' 
local rthighf = piece 'rthighf' 
local rkneef = piece 'rkneef' 
local rshinf = piece 'rshinf' 
local rfootf = piece 'rfootf' 
local rblade = piece 'rblade' 
local lblade = piece 'lblade' 
local lthighb = piece 'lthighb' 
local lkneeb = piece 'lkneeb' 
local lshinb = piece 'lshinb' 
local lfootb = piece 'lfootb' 
local rthighb = piece 'rthighb' 
local rkneeb = piece 'rkneeb' 
local rshinb = piece 'rshinb' 
local rfootb = piece 'rfootb' 
local ospike = piece 'ospike' 
local uspike = piece 'uspike' 
local rspike = piece 'rspike' 
local lspike = piece 'lspike' 
--linear constant 163840

local rad = math.rad
local bMoving

-- Signal definitions
local SIG_AIM = 2
local SIG_AIM_2 = 4
local SIG_MOVE = 8
local SIG_SHOT_1 = 16 
local SIG_SHOT_2 = 32

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
		Turn(rthighb, z_axis, rad(5), rad(20))
		Turn(lthighb, z_axis, rad(5), rad(20))
		Move(body, y_axis, 0.7, 4000)			
		Turn(tail1, y_axis, rad(10), rad(40))
		Turn(tail2, y_axis, rad(10), rad(40))
		Turn(head, x_axis, rad(-10), rad(20))
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
		
		Turn(tail1, y_axis, rad(-10), rad(40))
		Turn(tail2, y_axis, rad(-10), rad(40))
		Turn(body, z_axis, rad(5), rad(20))
		Turn(lthighf, z_axis, rad(-5), rad(20))
		Turn(rthighf, z_axis, rad(-5), rad(20))
		Turn(lthighb, z_axis, rad(-5), rad(20))
		Turn(rthighb, z_axis, rad(-5), rad(20))
		Move(body, y_axis, 0.7, 4000)
		Turn(head, x_axis, rad(-10), rad(20))
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

local function ShotThread(num)
	if num == 1 then
		Signal(SIG_SHOT_1)
		SetSignalMask(SIG_SHOT_1)
		WaitForTurn(lblade, y_axis)
		Turn(lblade, y_axis, rad(40), rad(5))
		Turn(rblade, y_axis, rad(-40), rad(5))
		WaitForTurn(lblade, y_axis)
		Turn(lblade, y_axis, 0, rad(1))
		Turn(rblade, y_axis, 0, rad(1))
	else
		Signal(SIG_SHOT_2)
		SetSignalMask(SIG_SHOT_2)
		Turn(ospike, x_axis, rad(40), rad(1000))
		Turn(uspike, x_axis, rad(-40), rad(1000))
		Turn(lspike, y_axis, rad(40), rad(1000))
		Turn(rspike, y_axis, rad(-40), rad(1000))
		WaitForTurn(ospike, x_axis)
		Turn(ospike, x_axis, 0, rad(100))
		Turn(uspike, x_axis, 0, rad(100))
		Turn(lspike, y_axis, 0, rad(100))
		Turn(rspike, y_axis, 0, rad(100))
	end
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
	Turn(firepoint, y_axis, rad(180))
end

function script.AimFromWeapon(num)
	return head
end

function script.QueryWeapon(num)
	return head
end

local function RestoreAfterDelay()
	Sleep(5000)
	Turn(head, x_axis, rad(0), rad(20))
	Turn(head, y_axis, rad(0), rad(20))
end

function script.AimWeapon(num, heading, pitch)
	if num == 1 then
		Signal(SIG_AIM)
		SetSignalMask(SIG_AIM)
		Turn(head, y_axis, heading, rad(200))
		Turn(head, x_axis, -pitch, rad(200))
		
		WaitForTurn(head, x_axis)
		WaitForTurn(head, y_axis)
		StartThread(RestoreAfterDelay)
		
		return true
	else
		Signal(SIG_AIM_2)
		SetSignalMask(SIG_AIM_2)
		Turn(tail1, x_axis, rad(45), rad(200))
		Turn(tail2, x_axis, rad(45), rad(200))
			
		WaitForTurn(tail1, x_axis)
		StartThread(RestoreAfterDelay)
		
		return true
	end
end
	
function script.Shot(num)
	StartThread(ShotThread, num)
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
