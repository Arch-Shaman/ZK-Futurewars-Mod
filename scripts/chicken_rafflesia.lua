local base = piece 'base' 
local body = piece 'body' 
local tentacles = piece 'tentacles' 
local rotator01 = piece 'rotator01' 
local glow01 = piece 'glow01' 
local center = piece 'center' 
local explode_point01 = piece 'explode_point01' 
local explode_point02 = piece 'explode_point02' 
local explode_point03 = piece 'explode_point03' 
local explode_point04 = piece 'explode_point04' 
local explode_point05 = piece 'explode_point05' 
local explode_point06 = piece 'explode_point06' 
local explode_point07 = piece 'explode_point07' 
local explode_point08 = piece 'explode_point08' 
--Chicken K'Vart Script

-- This script is hereby released under GPL v. 2 or later by Wolfe Games, 2008
-- All contents were created by Wolfe Games.

local random = math.random
local rad = math.rad

local dirt3 = 1024+9

local RandomPitch, amAttacking


local function twitch()
	while true do
		Turn(body, x_axis, rad(10), rad(10))
		WaitForTurn(body, x_axis)
		Turn(body, x_axis, rad(-10), rad(10))
		WaitForTurn(body, x_axis)	
	end
end

local function spinMe()
	local randomVal
	while true do
		Move(glow01, x_axis, random(-90, -60), 5)
		Turn(rotator01, z_axis, rad(-1), rad(5))
		
		randomVal = random(-35, 35)
		if randomVal < 0 and randomVal > -15 then
			randomVal = -15
		end
		if randomVal > 0 and randomVal < 15 then
			randomVal = 15
		end		
		Spin(rotator01, y_axis, rad(randomVal))

		Sleep(random(2000, 6000))				
	end
end

function script.Create()
	amAttacking = 0

	Turn(base, y_axis, random(0, math.pi*2))
	
	Turn(tentacles, y_axis, random(0, math.pi*2))

	Turn(body, x_axis, random(0, math.pi*2))
	
	Move(glow01, x_axis, random(45, 85))

	-- lua_function script.CreateLightMe(glow01, 0, 128, 255, 160)
			
	StartThread(twitch)
	StartThread(spinMe)
	--StartThread(glow)
	--StartThread(RandomTarget)
end

function script.AimFromWeapon(num)
	return body
end

function script.QueryWeapon(num)
	return body
end

function script.AimWeapon(num, heading, pitch)
	return true
end
	
function script.HitByWeaponId()
	EmitSfx(body, 1024)
	return 100
end

function script.Killed(recentDamage, maxHealth)
	EmitSfx(base, 1026)
	EmitSfx(body, 1025)
	return 0
end
