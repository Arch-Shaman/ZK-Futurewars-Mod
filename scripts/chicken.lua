include "constants.lua"

local body, head, tail, lthigh, lknee, lshin, lfoot = piece('body', 'head', 'tail', 'lthigh', 'lknee', 'lshin', 'lfoot')
local rthigh, rknee, rshin, rfoot, lforearm, lupperarm, lblade = piece('rthigh', 'rknee', 'rshin', 'rfoot', 'lforearm', 'lupperarm', 'lblade')
local rforearm, rupperarm, rblade = piece('rforearm', 'rupperarm', 'rblade')

local bMoving = false
local shooting = false
local lasthit
local mood = 0 -- 0: idle, 1: moving, 2: attack, 3: dying

local SIG_AIM = 2
local SIG_AIM_2 = 4
local SIG_MOVE = 8
local SIG_WAGTAIL = 16

local function WagTailThread(mode)
	local berth
	local speed
	if mode == "threatened" then
		berth = math.rad(12) -- short
		speed = math.rad(80)
		Turn(tail, x_axis, math.rad(49.2), math.rad(40))
	elseif mode == "neutral" then
		berth = math.rad(20)
		speed = math.rad(50)
		Turn(tail, x_axis, math.rad(24.8), math.rad(40))
	elseif mode == "moving" then
		berth = math.rad(30)
		speed = math.rad(34)
	else
		Turn(tail, x_axis, math.rad(-38.2), math.rad(40))
		berth = math.rad(28)
		speed = math.rad(30)
	end
	Signal(SIG_WAGTAIL)
	SetSignalMask(SIG_WAGTAIL)
	while true do
		Turn(tail, y_axis, berth, speed)
		WaitForTurn(tail, y_axis)
		Turn(tail, y_axis, -berth, speed)
		WaitForTurn(tail, y_axis)
		Turn(tail, y_axis, 0, speed)
		WaitForTurn(tail, y_axis)
	end
end

local function Walk()
	bMoving = true
	if mood == 0 then
		StartThread(WagTailThread, "moving")
	end
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while true do
		Turn(lthigh, x_axis, math.rad(70), math.rad(230))
		Turn(lknee, x_axis, math.rad(-40), math.rad(270))
		Turn(lshin, x_axis, math.rad(20), math.rad(270))
		Turn(lfoot, x_axis, math.rad(-50), math.rad(420))
		
		Turn(rthigh, x_axis, math.rad(-20), math.rad(420))
		Turn(rknee, x_axis, math.rad(-60), math.rad(420))
		Turn(rshin, x_axis, math.rad(50), math.rad(420))
		Turn(rfoot, x_axis, math.rad(30), math.rad(420))
		
		Turn(body, z_axis, math.rad(5), math.rad(40))
		Turn(lthigh, z_axis, math.rad(-5), math.rad(40))
		Turn(rthigh, z_axis, math.rad(-5), math.rad(40))
		Move(body, y_axis, 0.7, 8000)			
		Turn(tail, y_axis, math.rad(10), math.rad(80))
		Turn(head, x_axis, math.rad(-10), math.rad(40))
		Turn(tail, x_axis, math.rad(10), math.rad(40))
		WaitForTurn(lthigh, x_axis)
		
		Turn(lthigh, x_axis, math.rad(-10), math.rad(320))
		Turn(lknee, x_axis, math.rad(15), math.rad(270))
		Turn(lshin, x_axis, math.rad(-60), math.rad(500))
		Turn(lfoot, x_axis, math.rad(30), math.rad(270))
		
		Turn(rthigh, x_axis, math.rad(40), math.rad(270))
		Turn(rknee, x_axis, math.rad(-35), math.rad(270))
		Turn(rshin, x_axis, math.rad(-40), math.rad(270))
		Turn(rfoot, x_axis, math.rad(35), math.rad(270))
		
		Move(body, y_axis, 0, 8000)
		Turn(head, x_axis, math.rad(10), math.rad(40))
		Turn(tail, x_axis, math.rad(-10), math.rad(40))
		WaitForTurn(lshin, x_axis)
		
		Turn(rthigh, x_axis, math.rad(70), math.rad(230))
		Turn(rknee, x_axis, math.rad(-40), math.rad(270))
		Turn(rshin, x_axis, math.rad(20), math.rad(270))
		Turn(rfoot, x_axis, math.rad(-50), math.rad(420))
		
		Turn(lthigh, x_axis, math.rad(-20), math.rad(420))
		Turn(lknee, x_axis, math.rad(-60), math.rad(420))
		Turn(lshin, x_axis, math.rad(50), math.rad(420))
		Turn(lfoot, x_axis, math.rad(30), math.rad(420))
		
		Turn(tail, y_axis, math.rad(-10), math.rad(80))
		Turn(body, z_axis, math.rad(-5), math.rad(40))
		Turn(lthigh, z_axis, math.rad(5), math.rad(40))
		Turn(rthigh, z_axis, math.rad(5), math.rad(40))
		Move(body, y_axis, 0.7, 8000)
		Turn(head, x_axis, math.rad(-10), math.rad(40))
		Turn(tail, x_axis, math.rad(10), math.rad(40))
		WaitForTurn(rthigh, x_axis)
		
		Turn(rthigh, x_axis, math.rad(-10), math.rad(320))
		Turn(rknee, x_axis, math.rad(15), math.rad(270))
		Turn(rshin, x_axis, math.rad(-60), math.rad(500))
		Turn(rfoot, x_axis, math.rad(30), math.rad(270))
		
		Turn(lthigh, x_axis, math.rad(40), math.rad(270))
		Turn(lknee, x_axis, math.rad(-35), math.rad(270))
		Turn(lshin, x_axis, math.rad(-40), math.rad(270))
		Turn(lfoot, x_axis, math.rad(35), math.rad(270))
		
		Move(body, y_axis, 0, 8000)
		Turn(head, x_axis, math.rad(10), math.rad(40))
		Turn(tail, x_axis, math.rad(-10), math.rad(40))
		WaitForTurn(rshin, x_axis)
	end
end

local function StopWalking()
	bMoving = false
	Signal(SIG_MOVE)
	Turn(lfoot, x_axis, 0, math.rad(200))
	Turn(rfoot, x_axis, 0, math.rad(200))
	Turn(rthigh, x_axis, 0, math.rad(200))
	Turn(lthigh, x_axis, 0, math.rad(200))
	Turn(lshin, x_axis, 0, math.rad(200))
	Turn(rshin, x_axis, 0, math.rad(200))
	Turn(lknee, x_axis, 0, math.rad(200))
	Turn(rknee, x_axis, 0, math.rad(200))
	if mood == 1 then
		mood = 0
		StartThread(WagTailThread, "neutral")
	end
end

local function Idle()
	SetSignalMask(SIG_AIM_2)
	Sleep(15000)
	if not bMoving then
		StartThread(WagTailThread, "neutral")
	else
		StartThread(WagTailThread, "moving")
	end
end

function script.QueryWeapon()
	return head
end

function script.AimFromWeapon()
	return head
end

function script.AimWeapon(num, heading, pitch)
	if mood < 2 then
		mood = 3
		StartThread(WagTailThread, "threatened")
	end
	Signal(SIG_AIM_2)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(head, y_axis, heading, math.rad(250))
	Turn(head, x_axis, -pitch, math.rad(200))
	WaitForTurn(head, y_axis)
	return true
end

function script.HitByWeapon(x, z, weaponDef, damage)
	EmitSfx(body, 1024)
	return damage
end

function script.Create()
	EmitSfx(body, 1026)
	StartThread(WagTailThread, "neutral")
end

function script.BlockShot(num)
	return shooting
end

local function Recovery()
	shooting = true
	Turn(lforearm, y_axis, math.rad(-140), math.rad(600))
	Turn(rforearm, y_axis, math.rad(140), math.rad(600))
	Turn(lblade, y_axis, math.rad(140), math.rad(600))
	Turn(rblade, y_axis, math.rad(-140), math.rad(600))
	WaitForTurn(rblade, y_axis)
	Turn(lforearm, y_axis, 0, math.rad(200))
	Turn(rforearm, y_axis, 0, math.rad(200))
	Turn(lblade, y_axis, 0, math.rad(200))
	Turn(rblade, y_axis, 0, math.rad(200))
	WaitForTurn(rblade, y_axis)
	shooting = false
end

function script.Shot()
	StartThread(Recovery)
	StartThread(Idle)
end

function script.StopMoving()
	StopWalking()
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StartMoving()
	StartThread(Walk)
	if mood == 0 then
		mood = 1
	end
end

function script.Killed(recentDamage, maxHealth)
	local explodables = {body, head, tail, lforearm, lblade, rforearm, rblade}
	EmitSfx(body, 1025)
	for i = 1, #explodables do
		Explode(explodables[i], SFX.FALL + SFX.EXPLODE)
	end
end
