
include "constants.lua"

local chest = piece 'chest'
local flare = piece 'flare'
local hips = piece 'hips'
local lthigh = piece 'lthigh'
local rthigh = piece 'rthigh'
local head = piece 'head'
local lforearm = piece 'lforearm'
local rforearm = piece 'rforearm'
local rshoulder = piece 'rshoulder'
local lshoulder = piece 'lshoulder'
local rshin = piece 'rshin'
local rfoot = piece 'rfoot'
local lshin = piece 'lshin'
local lfoot = piece 'lfoot'
local gun = piece 'gun'
local barrel = piece 'barrel'
local ejector = piece 'ejector'
local lbelt = piece 'lbelt'
local rbelt = piece 'rbelt'

local gunBelts = {
	{
		main = rbelt,
		other = lbelt,
	},
	{
		main = lbelt,
		other = rbelt,
	},
}

local gunFlares = {flare}
local ejectors = {ejector}
local gun = 1
local aiming = false

-- Signal definitions
local SIG_WALK = 1
local SIG_RESTORE = 2
local SIG_AIM = 4

local RESTORE_DELAY = 3000

-- future-proof running animation against balance tweaks
local runspeed = 1.8 * (UnitDefs[unitDefID].speed / 51)

local hangtime = 32
local steptime = 10
local stride_top = -0.5
local stride_bottom = -2.75

local function GetSpeedMod()
	return (GG.att_MoveChange[unitID] or 1)
end

local function BarrelAnim()
	local speedMod = 0
	local last = 0
	local acceleration = math.rad(20)
	while true do
		speedMod = GG.FireControl.GetBonusFirerate(unitID, 1) - 1 -- Barrel linked to MG weapon
		if speedMod ~= last then
			if speedMod < last then
				Spin(barrel, y_axis, speedMod, -acceleration)
			else
				Spin(barrel, y_axis, speedMod, acceleration)
			end
		end
		last = speedMod
		Sleep(66) -- happens every 3rd frame.
	end
end

local function Walk()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)

	while true do
		local truespeed = runspeed * GetSpeedMod()

		Turn(hips, z_axis, 0.08, truespeed*0.15)

		Turn(rthigh, x_axis, -0.65, truespeed*1.25)
		Turn(rshin, x_axis, 0.8, truespeed*1.25)
		Turn(rfoot, x_axis, 0, truespeed*0.5)

		Turn(lshin, x_axis, 0.4, truespeed*0.5)
		Turn(lthigh, x_axis, 0.5, truespeed*1.25)
		Turn(lfoot, x_axis, -0.3, truespeed*1)

		Move(hips, y_axis, stride_top, truespeed*4)

		if not aiming then
			Move(chest, y_axis, -0.15, truespeed*1)
			Turn(chest, x_axis, -0.08, truespeed*0.25)
			Turn(chest, y_axis, -0.065, truespeed*0.25)
		end

		WaitForMove(hips, y_axis)

		Move(hips, y_axis, stride_bottom, truespeed*1)

		Sleep(hangtime)

		Move(hips, y_axis, stride_bottom, truespeed*4)
		Turn(rshin, x_axis, 0.0, truespeed*0.75)
		Turn(rfoot, x_axis, -0.2, truespeed*0.5)
		Turn(lshin, x_axis, 0.6, truespeed*0.75)
		Turn(lfoot, x_axis, -0.0, truespeed*1.25)

		if not aiming then
			Move(chest, y_axis, 0, truespeed*1)
			Turn(chest, x_axis, 0, truespeed*0.25)
			Turn(chest, y_axis, 0, truespeed*0.25)
		end

		WaitForTurn(rthigh, x_axis)

		Sleep(steptime)

		truespeed = runspeed * GetSpeedMod() -- again because it might've changed during sleep
		Turn(hips, z_axis, -0.08, truespeed*0.15)

		Turn(lthigh, x_axis, -0.65, truespeed*1.25)
		Turn(lshin, x_axis, 0.8, truespeed*1.25)
		Turn(lfoot, x_axis, 0, truespeed*0.5)

		Turn(rshin, x_axis, 0.4, truespeed*0.5)
		Turn(rthigh, x_axis, 0.5, truespeed*1.25)
		Turn(rfoot, x_axis, -0.3, truespeed*1)

		Move(hips, y_axis, stride_top, truespeed*4)

		if not aiming then
			Move(chest, y_axis, -0.15, truespeed*1)
			Turn(chest, x_axis, -0.08, truespeed*0.25)
			Turn(chest, y_axis, 0.065, truespeed*0.25)
		end

		WaitForMove(hips, y_axis)

		Move(hips, y_axis, stride_bottom, truespeed*1)

		Sleep(hangtime)

		Move(hips, y_axis, stride_bottom, truespeed*4)
		Turn(lshin, x_axis, 0.0, truespeed*0.75)
		Turn(lfoot, x_axis, -0.2, truespeed*0.5)
		Turn(rshin, x_axis, 0.6, truespeed*0.75)
		Turn(rfoot, x_axis, -0.0, truespeed*1.25)

		if not aiming then
			Move(chest, y_axis, 0, truespeed*1)
			Turn(chest, x_axis, 0, truespeed*0.25)
			Turn(chest, y_axis, 0, truespeed*0.25)
		end

		WaitForTurn(lthigh, x_axis)

		Sleep(steptime)
	end
end

local function StopWalk()
	Signal(SIG_WALK)

	Move(hips, x_axis, 0, 10.0)
	Move(hips, y_axis, 0, 10.0)
	Turn(rthigh, x_axis, 0, math.rad(400))
	Turn(rshin, x_axis, 0, math.rad(400))
	Turn(rfoot, x_axis, 0, math.rad(400))
	Turn(lthigh, x_axis, 0, math.rad(400))
	Turn(lshin, x_axis, 0, math.rad(400))
	Turn(lfoot, x_axis, 0, math.rad(400))
	if not aiming then
		Turn(chest, y_axis, 0, math.rad(180))
		Turn(rshoulder, x_axis, 0, math.rad(400))
		Turn(rforearm, x_axis, 0, math.rad(400))
		Turn(lshoulder, x_axis, 0, math.rad(400))
		Turn(lforearm, x_axis, 0, math.rad(400))
	end
end

function script.Create()
	Hide(ejector)
	Hide(flare)

	-- workaround for ejectors pointing forwards in model
	Turn(ejector, y_axis, math.rad(90), 100.0)
	StartThread(BarrelAnim)
	StartThread(GG.Script.SmokeUnit, unitID, {chest})
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StopWalk()
end

function script.AimFromWeapon(num)
	return chest
end

function script.QueryWeapon(num)
	return gunFlares[gun]
end

function script.BlockShot(num)
	return not GG.FireControl.CanFireWeapon(unitID, num)
end

function script.FireWeapon(num)
	EmitSfx(gunFlares[gun], 1024)
	EmitSfx(ejectors[gun], 1025)
	--Spin(barrel, y_axis, 20)
	GG.FireControl.WeaponFired(unitID, num)
end

local function RestoreAim()
	Sleep(RESTORE_DELAY)
	Signal(SIG_RESTORE)
	SetSignalMask(SIG_RESTORE)
	
	Turn(chest, y_axis, 0, math.rad(90))
	Turn(rforearm, x_axis, 0, math.rad(45))
	Turn(rshoulder, y_axis, 0, math.rad(45))
	Turn(lforearm, x_axis, 0, math.rad(45))
	WaitForTurn(chest, y_axis)
	WaitForTurn(rforearm, x_axis)
	WaitForTurn(rshoulder, y_axis)
	WaitForTurn(lforearm, x_axis)
	--Spin(barrel, y_axis, 0)
	
	aiming = false
end

function script.AimWeapon(num, heading, pitch)

	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	aiming = true

	Turn(chest, y_axis, heading, math.rad(800))
	Turn(rforearm, x_axis, -pitch, math.rad(600))
	Turn(lforearm, x_axis, -pitch, math.rad(600))
	--Spin(barrel, y_axis, 10)
	WaitForTurn(chest, y_axis)
	WaitForTurn(lforearm, x_axis)
	WaitForTurn(rforearm, x_axis)
	StartThread(RestoreAim)
	return true
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if (severity <= 0.25) then

		Explode(gun, SFX.NONE)
		Explode(lfoot, SFX.NONE)
		Explode(lshin, SFX.NONE)
		Explode(lshoulder, SFX.NONE)
		Explode(lthigh, SFX.NONE)
		Explode(lforearm, SFX.NONE)
		Explode(rfoot, SFX.NONE)
		Explode(rshin, SFX.NONE)
		Explode(rshoulder, SFX.NONE)
		Explode(rthigh, SFX.NONE)
		Explode(rforearm, SFX.NONE)
		Explode(chest, SFX.NONE)
		return 1
	elseif severity <= 0.50 then
		Explode(gun, SFX.FALL)
		Explode(lfoot, SFX.FALL)
		Explode(lshin, SFX.FALL)
		Explode(lshoulder, SFX.FALL)
		Explode(lthigh, SFX.FALL)
		Explode(lforearm, SFX.FALL)
		Explode(rfoot, SFX.FALL)
		Explode(rshin, SFX.FALL)
		Explode(rshoulder, SFX.FALL)
		Explode(rthigh, SFX.FALL)
		Explode(rforearm, SFX.FALL)
		Explode(chest, SFX.SHATTER)
		return 1
	end

	Explode(gun, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lfoot, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lshin, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lshoulder, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lthigh, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(lforearm, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rfoot, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rshin, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rshoulder, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rthigh, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(rforearm, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
	Explode(chest, SFX.SHATTER + SFX.EXPLODE_ON_HIT)
	return 2
end
