local body = piece 'body' 
local head = piece 'head' 
local tail = piece 'tail' 
local lwing = piece 'lwing' 
local rwing = piece 'rwing' 
local lthigh = piece 'lthigh' 
local lknee = piece 'lknee' 
local lshin = piece 'lshin' 
local lfoot = piece 'lfoot' 
local rthigh = piece 'rthigh' 
local rknee = piece 'rknee' 
local rshin = piece 'rshin' 
local rfoot = piece 'rfoot' 
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
local spore1 = piece 'spore1' 
local spore2 = piece 'spore2' 
local spore3 = piece 'spore3' 
--linear constant 65536



local bMoving, feet

-- Signal definitions
local SIG_AIM = 2
local SIG_AIM_2 = 4
local SIG_MOVE = 8

#include "constants.h"

fly()

	while bMoving do
		
			Turn( lwing , z_axis, math.rad(-(-40)), math.rad(120) )
			Turn( rwing , z_axis, math.rad(-(40)), math.rad(120) )
			Turn( tail , x_axis, math.rad(20), math.rad(40) )
			Move( body , y_axis, -60 , 20000 )
			WaitForTurn(lwing, z_axis)
			Turn( lwing , z_axis, math.rad(-(40)), math.rad(240) )
			Turn( rwing , z_axis, math.rad(-(-40)), math.rad(240) )
			Turn( tail , x_axis, math.rad(-20), math.rad(80) )
			Move( body , y_axis, 0 , 40000 )
--			EmitSfx( body,  4096 + 5 ) Queen Crush
			WaitForTurn(lwing, z_axis)
		end
end

stopfly ()
	
	Turn( lwing		, z_axis, math.rad(-(0)), math.rad(200) )
	Turn( rwing		, z_axis, math.rad(-(0)), math.rad(200) )
end

function script.StartMoving()

	Signal( SIG_MOVE)
	SetSignalMask( SIG_MOVE)
	bMoving = true
	StartThread(fly)
	Turn( lfoot , x_axis, math.rad(-20), math.rad(420) )
	Turn( rfoot , x_axis, math.rad(-20), math.rad(420) )
	Turn( lshin , x_axis, math.rad(-40), math.rad(420) )
	Turn( rshin , x_axis, math.rad(-40), math.rad(420) )
end

function script.StopMoving()

	Signal( SIG_MOVE)
	SetSignalMask( SIG_MOVE)
	bMoving = false
	StartThread(stopfly)
end

function script.Create()

	EmitSfx( body,  1026 )
	EmitSfx( head,  1026 )
	EmitSfx( tail,  1026 )
	EmitSfx( firepoint,  1026 )
	EmitSfx( lwing,  1026 )
	EmitSfx( rwing,  1026 )
	EmitSfx( spike1,  1026 )
	EmitSfx( spike2,  1026 )
	EmitSfx( spike3,  1026 )
	feet = true
	Turn( spore1 , x_axis, math.rad(-90 ) )
	Turn( spore2 , x_axis, math.rad(-90 ) )
	Turn( spore3 , x_axis, math.rad(-90 ) )
end

SweetSpot(piecenum)
		piecenum=body	end	
	
function script.AimFromWeapon1(piecenum)
		piecenum=firepoint	end

function script.QueryWeapon1(piecenum)
		piecenum=firepoint end

function script.AimFromWeapon2(piecenum)
		piecenum=spore1	end

function script.QueryWeapon2(piecenum)
		piecenum=spore1 end

function script.AimFromWeapon3(piecenum)
		piecenum=spore2	end

function script.QueryWeapon3(piecenum)
		piecenum=spore2 end

AimFromWeapon4(piecenum)
		piecenum=spore3	end

QueryWeapon4(piecenum)
		piecenum=spore3	end
	
AimFromWeapon5(piecenum)
	
		piecenum=body
	end

QueryWeapon5(piecenum)
	
		if feet then
		
			piecenum=lfoot
		end
		if not feet then
		
			piecenum=rfoot
		end
	end
	
RestoreAfterDelay()
	
	Sleep( 1000)
	end

function script.AimWeapon1(heading,pitch)
	
	Signal( SIG_AIM)
	SetSignalMask( SIG_AIM)
	Turn( head , y_axis, math.rad(heading ), math.rad(250) )
	Turn( head , x_axis, math.rad(0 -pitch ), math.rad(200) )
		
	WaitForTurn(head, y_axis)
	StartThread(RestoreAfterDelay)
	
	return(true)
	end
	
function script.AimWeapon2()
	
	return(true)
	end

function script.AimWeapon3()
	
	return(true)
	end

AimWeapon4()
	
	return(true)
	end

AimWeapon5()
	
	return(true)
	end

function script.Shot1()
	
		Turn( lforearmu , y_axis, math.rad(-140), math.rad(600) )
		Turn( lbladeu , y_axis, math.rad(140), math.rad(600) )
		WaitForTurn(lbladeu, y_axis)
		Turn( lforearmu , y_axis, 0, math.rad(120) )
		Turn( lbladeu , y_axis, 0, math.rad(120) )

		Turn( lforearml , y_axis, math.rad(-140), math.rad(600) )
		Turn( lbladel , y_axis, math.rad(140), math.rad(600) )
		WaitForTurn(lbladel, y_axis)
		Turn( lforearml , y_axis, 0, math.rad(120) )
		Turn( lbladel , y_axis, 0, math.rad(120) )

		Turn( rforearmu , y_axis, math.rad(140), math.rad(600) )
		Turn( rbladeu , y_axis, math.rad(-140), math.rad(600) )
		WaitForTurn(rbladeu, y_axis)
		Turn( rforearmu , y_axis, 0, math.rad(120) )
		Turn( rbladeu , y_axis, 0, math.rad(120) )

		Turn( rforearml , y_axis, math.rad(140), math.rad(600) )
		Turn( rbladel , y_axis, math.rad(-140), math.rad(600) )
		WaitForTurn(rbladel, y_axis)
		Turn( rforearml , y_axis, 0, math.rad(120) )
		Turn( rbladel , y_axis, 0, math.rad(120) )
	end


Shot5()
	
	feet = not feet
	if feet then
		
		Turn( rthigh , x_axis, math.rad(-60), math.rad(100) )
		Turn( rknee , x_axis, math.rad(-70), math.rad(120) )
		Turn( rshin , x_axis, math.rad(60), math.rad(120) )
		WaitForTurn(lknee, x_axis)
		
		Turn( rthigh , x_axis, 0, math.rad(100) )
		Turn( rknee , x_axis, 0, math.rad(120) )
		Turn( rshin , x_axis, 0, math.rad(120) )
		end
	if not feet then
		
		Turn( lthigh , x_axis, math.rad(-60), math.rad(100) )
		Turn( lknee , x_axis, math.rad(-70), math.rad(120) )
		Turn( lshin , x_axis, math.rad(60), math.rad(120) )
		WaitForTurn(lknee, x_axis)
		
		Turn( lthigh , x_axis, 0, math.rad(100) )
		Turn( lknee , x_axis, 0, math.rad(120) )
		Turn( lshin , x_axis, 0, math.rad(120) )
		Turn( tail , x_axis, 0, math.rad(320) )
		end
	end

	
function script.HitByWeaponId()
	
	EmitSfx( body,  1024 )
	return 100
	end

function script.Killed( severity, corpsetype )
	
	corpsetype = 1
	EmitSfx( body,  1025 )
	return( 0 )
	end
