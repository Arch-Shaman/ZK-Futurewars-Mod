include "constants.lua"

local body,head,tail,lthigh,lknee = piece('body', 'head', 'tail', 'lthigh', 'lknee')
local lshin,lfoot,rthigh,rknee,rshin = piece('lshin', 'lfoot', 'rthigh', 'rknee', 'rshin')
local rfoot,rsack,lsack,rblade,lblade = piece('rfoot', 'rsack', 'lsack', 'rblade', 'lblade')
local mblade,spike1,spike2,spike3 = piece('mblade', 'spike1', 'spike2', 'spike3')

local bMoving   = false
local SIG_AIM   = 2
local SIG_AIM_2 = 4
local SIG_MOVE  = 8

local aimspeed = math.rad(250)
local pitchspeed = math.rad(200)
local scriptReload = include("scriptReload.lua")
local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload
local gameSpeed = Game.gameSpeed
local RELOAD_TIME = 4.5 * gameSpeed
local lastshot = 0

local firePieces = {
	[1] = {
		firepoint = lblade,
		loaded = true,
		unloadedpoint = -13,
		reloadspeed = 13/4.5,
	},
	[2] = {
		firepoint = mblade,
		loaded = true,
		unloadedpoint = -25,
		reloadspeed = 25/4.5,
	},
	[3] = {
		firepoint = rblade,
		loaded = true,
		unloadedpoint = -13,
		reloadspeed = 13/4.5,
	},
}

local bladenum = 1
local special = 0

local function Walk()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while true do
		Turn(lthigh, x_axis, math.rad(70), math.rad(115))
		Turn(lknee, x_axis, math.rad(-40), math.rad(145))
		Turn(lshin, x_axis, math.rad(20), math.rad(145))
		Turn(lfoot, x_axis, math.rad(-50), math.rad(210))

		Turn(rthigh, x_axis, math.rad(-20), math.rad(210))
		Turn(rknee, x_axis, math.rad(-60), math.rad(210))
		Turn(rshin, x_axis, math.rad(50), math.rad(210))
		Turn(rfoot, x_axis, math.rad(30), math.rad(210))

		Turn(body, z_axis, math.rad(5), math.rad(20))
		Turn(lthigh, z_axis, math.rad(-5), math.rad(20))
		Turn(rthigh, z_axis, math.rad(-5), math.rad(20))
		Move(body, y_axis, 0.7, 4000)			
		Turn(tail, y_axis, math.rad(10), math.rad(40))
		Turn(head, x_axis, math.rad(-10), math.rad(20))
		Turn(tail, x_axis, math.rad(10), math.rad(20))
		WaitForTurn(lthigh, x_axis)

		Turn(lthigh, x_axis, math.rad(-10), math.rad(160))
		Turn(lknee, x_axis, math.rad(15), math.rad(145))
		Turn(lshin, x_axis, math.rad(-60), math.rad(250))
		Turn(lfoot, x_axis, math.rad(30), math.rad(145))

		Turn(rthigh, x_axis, math.rad(40), math.rad(145))
		Turn(rknee, x_axis, math.rad(-35), math.rad(145))
		Turn(rshin, x_axis, math.rad(-40), math.rad(145))
		Turn(rfoot, x_axis, math.rad(35), math.rad(145))

		Move(body, y_axis, 0, 4000)
		Turn(head, x_axis, math.rad(10), math.rad(20))
		Turn(tail, x_axis, math.rad(-10), math.rad(20))
		WaitForTurn(lshin, x_axis)

		Turn(rthigh, x_axis, math.rad(70), math.rad(115))
		Turn(rknee, x_axis, math.rad(-40), math.rad(145))
		Turn(rshin, x_axis, math.rad(20), math.rad(145))
		Turn(rfoot, x_axis, math.rad(-50), math.rad(210))

		Turn(lthigh, x_axis, math.rad(-20), math.rad(210))
		Turn(lknee, x_axis, math.rad(-60), math.rad(210))
		Turn(lshin, x_axis, math.rad(50), math.rad(210))
		Turn(lfoot, x_axis, math.rad(30), math.rad(210))

		Turn(tail, y_axis, math.rad(-10), math.rad(40))
		Turn(body, z_axis, math.rad(-5), math.rad(20))
		Turn(lthigh, z_axis, math.rad(5), math.rad(20))
		Turn(rthigh, z_axis, math.rad(5), math.rad(20))
		Move(body, y_axis, 0.7, 4000)
		Turn(head, x_axis, math.rad(-10), math.rad(20))
		Turn(tail, x_axis, math.rad(10), math.rad(20))
		WaitForTurn(rthigh, x_axis)

		Turn(rthigh, x_axis, math.rad(-10), math.rad(160))
		Turn(rknee, x_axis, math.rad(15), math.rad(145))
		Turn(rshin, x_axis, math.rad(-60), math.rad(250))
		Turn(rfoot, x_axis, math.rad(30), math.rad(145))

		Turn(lthigh, x_axis, math.rad(40), math.rad(145))
		Turn(lknee, x_axis, math.rad(-35), math.rad(145))
		Turn(lshin, x_axis, math.rad(-40), math.rad(145))
		Turn(lfoot, x_axis, math.rad(35), math.rad(145))

		Move(body, y_axis, 0, 4000)
		Turn(head, x_axis, math.rad(10), math.rad(20))
		Turn(tail, x_axis, math.rad(-10), math.rad(20))
		WaitForTurn(rshin, x_axis)
	end
end

local function SpecialThread()
	while true do
		Sleep(2000)
		if lastshot > 0 then
			lastshot = lastshot - 2
		end
		if special > 0 and lastshot < 0 then
			special = math.max(special - 1, 0)
		end
	end
end

function script.StopMoving()
	Signal(SIG_MOVE)
	Turn(lfoot, x_axis, 0, math.rad(200))
	Turn(rfoot, x_axis, 0, math.rad(200))
	Turn(rthigh, x_axis, 0, math.rad(200))
	Turn(lthigh, x_axis, 0, math.rad(200))
	Turn(lshin, x_axis, 0, math.rad(200))
	Turn(rshin, x_axis, 0, math.rad(200))
	Turn(lknee, x_axis, 0, math.rad(200))
	Turn(rknee, x_axis, 0, math.rad(200))
end

local function FireSpike(num)
	scriptReload.GunStartReload(num)
	firePieces[num].loaded = false,
	Move(firePieces[num].firepoint, z_axis, firePieces[num].unloadedpoint)
	Move(firePieces[num].firepoint, z_axis, 0, firePieces[num].reloadspeed)
	SleepAndUpdateReload(num, RELOAD_TIME)
	firePieces[num].loaded = true
	if scriptReload.GunLoaded(num) then
		bladenum = 1
	end
	
end

--[[local function RecoilThread()
	Turn(lsack, y_axis, math.rad(40), math.rad(440)) -- this had to be changed because it looked bad
	Turn(rsack, y_axis, math.rad(-40), math.rad(440)) -- ditto. 1 isn't fast enough!
	Move(rsack, x_axis, -1, 1)
	Move(lsack, x_axis, 1, 1)
	Move(mblade, z_axis, -20, 100)
	WaitForTurn(lsack, y_axis)
	Turn(lsack, y_axis, 0, 0.3)
	Turn(rsack, y_axis, 0, 0.3)
	Move(rsack, x_axis, 0, 0.3)
	Move(lsack, x_axis, 0, 0.3)
	Move(mblade, z_axis, 0, 5.5)
end]] -- base game uses this, not future wars!

function script.Shot(num)
	if num == 1 then
		EmitSfx(firePieces[bladenum].firepoint, 1027)
		StartThread(FireSpike, bladenum) -- Needed because of WaitForTurn.
		bladenum = bladenum % 3 + 1
		special = special + 1.5
		lastshot = 7
	else
		EmitSfx(mblade, 1027)
		special = special - 10
	end
end

function script.BlockShot(num)
	if num == 2 then
		return special < 10
	elseif num == 1 then
		return not firePieces[bladenum].loaded or special >= 10
	end
	return false
end

function script.QueryWeapon(num)
	if num == 1 then
		return firePieces[bladenum].firepoint
	else
		return head
	end
end

function script.AimFromWeapon(num)
	return head
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(head, y_axis, heading, aimspeed)
	Turn(head, x_axis, -pitch, pitchspeed)
	WaitForTurn(head, y_axis)
	return true
end

function script.HitByWeapon(x, z, weaponDefID, damage)
	EmitSfx(body, 1024)
	return damage
end

function script.StartMoving()
	StartThread(Walk)
end

function script.Create()
	scriptReload.SetupScriptReload(3, RELOAD_TIME)
	StartThread(SpecialThread)
	EmitSfx(body, 1026)
end

function script.Killed(recentDamage, maxHealth)
	EmitSfx(body, 1025)
end
