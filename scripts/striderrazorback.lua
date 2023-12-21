-- Converted by hand by Shaman.
-- Feel free to steal, but PR any improvements!

include "constants.lua"
-- unused pieces: b1, b2, arm1, arm2, ar?, al

local ground = piece 'ground' -- guessing this is base.
local hips = piece 'hips' 
local luparm = piece 'luparm'
local lloarm = piece 'lloarm'
local lhand = piece 'lhand'
local fingerla = piece 'fingerla'
local fingerlb = piece 'fingerlb'
local thumbl = piece 'thumbl'
local ruparm = piece 'ruparm'
local rloarm = piece 'rloarm'
local rhand = piece 'rhand'
local fingerra = piece 'fingerra'
local fingerrb = piece 'fingerrb'
local thumbr = piece 'thumbr'
local body = piece 'body'
local arml = piece 'arml'
local cannonl = piece 'cannonl'
local flareb = piece 'flareb'
local canonbarrel1 = piece 'canonbarrel1'
local armr = piece 'armr'
local cannonr = piece 'cannonr'
local flarea = piece 'flarea'
local canonbarrel2 = piece 'canonbarrel2'
local calcarm = piece 'calcarm'
local calcflare = piece 'calcflare'
local calcpoint = piece 'calcpoint'
local emit = piece 'emit'
local axis = piece 'axis'
local flare = piece 'flare'
local exploder = piece 'exploder'
local hpoint = piece 'hpoint'
local smokepoint = piece 'smokepoint'
local smokeemit = piece 'smokeemit'
local muzzlea = piece 'muzzlea'
local muzzleb = piece 'muzzleb'
local ejectora = piece 'ejectora'
local ejectorb = piece 'ejectorb'

-- Signals --

local SIG_MOVE = 2
local SIG_AIM = 4
local SIG_AIM2 = 8

-- Other --
local restoredelay = 4500
local secondaryturnrate = math.rad(250)
local primaryturnrate = math.rad(100)
local zero = math.rad(0)
local moving = false
local armsfree = true

local smokePiece = {smokeemit}

local function BarrelAnim()
	local speedMod = 0
	local last = 0
	local acceleration = math.rad(20)
	while true do
		speedMod = GG.FireControl.GetBonusFirerate(unitID, 1) - 1 -- Barrel linked to MG weapon
		if speedMod ~= last then
			if speedMod < last then
				Spin(canonbarrel1, z_axis, speedMod, -acceleration)
				Spin(canonbarrel2, z_axis, speedMod, -acceleration)
			else
				Spin(canonbarrel1, z_axis, speedMod, acceleration)
				Spin(canonbarrel2, z_axis, speedMod, acceleration)
			end
		end
		last = speedMod
		Sleep(66) -- happens every 3rd frame.
	end
end

function script.Create()
	--Move(ground, z_axis, 10)
	Turn(muzzlea, z_axis, -math.rad(90))
	Turn(muzzleb, z_axis, -math.rad(90))
	Turn(muzzlea, x_axis, math.rad(90))
	Turn(muzzleb, x_axis, math.rad(90))
	Hide(flare)
	Hide(flarea)
	Hide(flareb)
	Hide(exploder)
	Hide(muzzlea)
	Hide(muzzleb)
	Hide(ejectora)
	Hide(ejectorb)
	Turn(calcarm, x_axis, 0)
	Spin(smokepoint, y_axis, 300) -- not sure what this does
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(BarrelAnim)
end

local function RestoreLaserThread()
	Sleep(restoredelay)
	Turn(hpoint, y_axis, math.rad(0), secondaryturnrate / 2)
	Turn(hpoint, x_axis, math.rad(0), secondaryturnrate / 2)
end

local function RestoreBody()
	Sleep(restoredelay)
	Turn(cannonr, y_axis, zero, primaryturnrate / 2)
	Turn(cannonl, y_axis, zero, primaryturnrate / 2)
	if not moving then
		Turn(arml, x_axis, zero, primaryturnrate)
		Turn(armr, x_axis, zero, primaryturnrate)
	else
		Turn(body, y_axis, zero, primaryturnrate)
		Turn(axis, y_axis, zero, primaryturnrate)
	end
	armsfree = true
end

local function StartWalkingThread()
	if not armsfree then
		Turn(body, y_axis, zero, math.rad(60))
		Turn(axis, y_axis, zero, math.rad(60))
	else
		Turn(arml, x_axis, math.rad(18), math.rad(9))
		Turn(armr, x_axis, -math.rad(18), math.rad(18))
	end
	Turn(luparm, x_axis,  math.rad(38.005495), math.rad(50))
	Turn(ruparm, x_axis, -math.rad(38.005495), math.rad(50))
	Turn(lhand, x_axis, -math.rad(28.005495), math.rad(70))
	Turn(rhand, x_axis, math.rad(8), math.rad(50))
	Turn(rloarm, x_axis, -math.rad(30), math.rad(80))
	Turn(body, x_axis, math.rad(4), math.rad(5))
	Sleep(505)
	Turn(lhand, x_axis, math.rad(38.005495), math.rad(100))
	Turn(rhand, x_axis, math.rad(18), math.rad(50))
	Turn(rloarm, x_axis, math.rad(38.005495), math.rad(100))
	Turn(fingerla, x_axis, math.rad(45.005495), math.rad(100))
	Turn(fingerlb, x_axis, math.rad(45.005495), math.rad(100))
	Turn(thumbl, x_axis, -math.rad(45.005495), math.rad(100))
	Turn(fingerra, x_axis, zero, math.rad(100))
	Turn(fingerrb, x_axis, zero, math.rad(100))
	Sleep(450)
	Turn(thumbr, x_axis, zero, math.rad(100))
	Move(hips, y_axis, 11, 1)
	Turn(hips, z_axis, math.rad(3), math.rad(3))
	if armsfree then
		Turn(arml, x_axis, -math.rad(18), math.rad(20))
		Turn(armr, x_axis, math.rad(18), math.rad(20))
	end
	Turn(luparm, x_axis, -math.rad(38.005495), math.rad(50))
	Turn(ruparm, x_axis, math.rad(38.005495), math.rad(50))
	Turn(rhand, x_axis, -math.rad(38.005495), math.rad(130))
	Turn(lloarm, x_axis, -math.rad(30), math.rad(80))
	Sleep(1050)
	Turn(rhand, x_axis, math.rad(38.005495), math.rad(100))
	Turn(lloarm, x_axis, math.rad(30.005495), math.rad(80))
	Move(hips, y_axis, 5, 2)
	Turn(fingerla, x_axis, zero, math.rad(100))
	Turn(fingerlb, x_axis, zero, math.rad(100))
	Turn(fingerra, x_axis, math.rad(45.005495), math.rad(100))
	Turn(fingerrb, x_axis, math.rad(45.005495), math.rad(100))
	Turn(thumbr, x_axis, -math.rad(45.005495), math.rad(100))
	Sleep(450)
	Turn(thumbl, x_axis, 0, math.rad(100))
	Move(hips, y_axis, 12, 2)
	Move(hips, z_axis, 5, 2)
	Turn(hips, z_axis, -math.rad(5), math.rad(8))
	Turn(arml, x_axis, 0, math.rad(14))
	Turn(armr, x_axis, 0, math.rad(14))
end

local function StopMovingThread()
	SetSignalMask(SIG_MOVE)
	Turn(luparm, x_axis, zero, math.rad(50))
	Turn(ruparm, x_axis, zero, math.rad(50))
	Turn(lloarm, x_axis, zero, math.rad(100))
	Turn(rloarm, x_axis, zero, math.rad(100))
	Turn(body, x_axis, zero, math.rad(20))
	Move(hips, y_axis, 5, 20)
	Turn(fingerra, x_axis, zero, math.rad(100))
	Turn(fingerrb, x_axis, zero, math.rad(100))
	Turn(thumbr, x_axis, zero, math.rad(100))
	Turn(fingerla, x_axis, zero, math.rad(100))
	Turn(fingerlb, x_axis, zero, math.rad(100))
	Turn(thumbl, x_axis, zero, math.rad(100))
	Turn(rhand, x_axis, zero, math.rad(100))
	Turn(lhand, x_axis, zero, math.rad(100))
	Turn(body, x_axis, math.rad(8), math.rad(48))
	if armsfree then
		Turn(arml, x_axis, -math.rad(8), math.rad(48))
		Turn(armr, x_axis, -math.rad(8), math.rad(48))
	end
	WaitForTurn(body, x_axis)
	Turn(body, x_axis, -math.rad(1), math.rad(48))
	if armsfree then
		Turn(arml, x_axis, zero, math.rad(48))
		Turn(armr, x_axis, zero, math.rad(48))
	end
end

function script.StopMoving()
	moving = false
	Signal(SIG_MOVE)
	StartThread(StopMovingThread)
end

local function WalkThread()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while true do
		if armsfree then
			Turn(arml, x_axis, math.rad(18), math.rad(18))
			Turn(armr, x_axis, -math.rad(18), math.rad(18))
			Turn(body, y_axis, -math.rad(8), math.rad(12))
			Turn(axis, y_axis, math.rad(8), math.rad(12))
			-- if we're not aiming hpoint, turn it y_axis -8, at speed 12
		end
		Turn(body, x_axis, -math.rad(3), math.rad(6))
		Turn(luparm, x_axis, math.rad(38.005495), math.rad(50))
		Turn(ruparm, x_axis, -math.rad(38.005495), math.rad(50))
		Turn(lhand, x_axis, -math.rad(38.005495), math.rad(50))
		Turn(rloarm, x_axis, -math.rad(30), math.rad(80))
		Sleep(1050)
		Turn(lhand, x_axis, math.rad(38.005495), math.rad(100))
		Turn(rhand, x_axis, math.rad(38.005495), math.rad(70))
		Turn(rloarm, x_axis, math.rad(30.005495), math.rad(100))
		Move(hips, y_axis, 0, 2)
		Turn(fingerla, x_axis, math.rad(45.005495), math.rad(100))
		Turn(fingerlb, x_axis, math.rad(45.005495), math.rad(100))
		Turn(thumbl, x_axis, -math.rad(45.005495), math.rad(100))
		Turn(fingerra, x_axis, zero, math.rad(100))
		Turn(fingerrb, x_axis, zero, math.rad(100))
		Sleep(450)
		Turn(thumbr, x_axis, 0, math.rad(100))
		Move(hips, y_axis, 11, 2)
		Turn(hips, z_axis, math.rad(3), math.rad(7))
		if armsfree then
			Turn(arml, x_axis, -math.rad(18), math.rad(20))
			Turn(armr, x_axis, math.rad(18), math.rad(20))
			Turn(body, y_axis, math.rad(8), math.rad(12))
			Turn(axis, y_axis, -math.rad(8), math.rad(12))
		end
		Turn(body, x_axis, math.rad(4), math.rad(6))
		Turn(luparm, x_axis, -math.rad(38.005495), math.rad(50))
		Turn(ruparm, x_axis, math.rad(38.005495), math.rad(50))
		Turn(rhand, x_axis, -math.rad(38.005495), math.rad(130))
		Turn(lloarm, x_axis, -math.rad(30), math.rad(100))
		Sleep(1050)
		Turn(rhand, x_axis, math.rad(38.005495), math.rad(100))
		Turn(lloarm, x_axis, math.rad(30.005495), math.rad(80))
		Move(hips, y_axis, 5, 2)
		Turn(fingerla, x_axis, 0, math.rad(100))
		Turn(fingerlb, x_axis, 0, math.rad(100))
		Turn(fingerra, x_axis, math.rad(45.005495), math.rad(100))
		Turn(fingerrb, x_axis, math.rad(45.005495), math.rad(100))
		Turn(thumbr, x_axis, -math.rad(45.005495), math.rad(100))
		Sleep(450)
		Turn(thumbl, x_axis, 0, math.rad(100))
		Move(hips, y_axis, 11, 2)
		Turn(hips, z_axis, -math.rad(3), math.rad(7))
	end
end

function script.StartMoving()
	moving = true
	StartThread(StartWalkingThread)
	StartThread(WalkThread)
end

function script.AimFromWeapon(num)
	if num ~= 3 then
		return body
	else
		return hpoint
	end
end

function script.QueryWeapon(num)
	if num == 1 then
		return flarea
	elseif num == 2 then
		return flareb
	elseif num == 3 then
		return emit
	else -- shield or microrift
		return body
	end
end

function script.AimWeapon(num, heading, pitch)
	if num == 4 or num == 5 then -- shield or microrift
		return true
	elseif num == 3 then -- secondary laser thingy
		Signal(SIG_AIM2)
		SetSignalMask(SIG_AIM2)
		Turn(hpoint, y_axis, heading, secondaryturnrate)
		Turn(hpoint, x_axis, -pitch, secondaryturnrate)
		WaitForTurn(hpoint, y_axis)
		WaitForTurn(hpoint, x_axis)
		StartThread(RestoreLaserThread)
		return true
	else
		armsfree = false
		Signal(SIG_AIM)
		SetSignalMask(SIG_AIM)
		local calcy, flarey
		_, calcy = Spring.UnitScript.GetPieceRotation(calcpoint)
		_, flarey = Spring.UnitScript.GetPieceRotation(calcflare)
		if calcy >= flarey then
			local angle = math.rad(calcy - flarey / 300 + 360)
			Turn(cannonr, y_axis, angle, primaryturnrate)
			Turn(cannonl, y_axis, -angle, primaryturnrate)
		else
			Turn(cannonr, y_axis, zero, primaryturnrate)
			Turn(cannonl, y_axis, zero, primaryturnrate)
		end
		Turn(body, y_axis, heading, primaryturnrate)
		Turn(axis, y_axis, 0.005495 - heading, primaryturnrate)
		Turn(arml, x_axis, -pitch, primaryturnrate)
		Turn(armr, x_axis, -pitch, primaryturnrate)
		WaitForTurn(body, y_axis)
		WaitForTurn(cannonl, y_axis)
		WaitForTurn(arml, x_axis)
		StartThread(RestoreBody)
		return true
	end
end

function script.FireWeapon(num)
	if num == 1 or num == 2 then
		GG.FireControl.WeaponFired(unitID, num)
	end
end

function script.BlockShot(num)
	if num == 1 or num == 2 then
		return not GG.FireControl.CanFireWeapon(unitID, num)
	else
		return false
	end
end

function script.Shot(num)
	if num == 1 then
		EmitSfx(muzzlea, 1024)
		EmitSfx(ejectora, 1025)
	elseif num == 2 then
		EmitSfx(muzzleb, 1024)
		EmitSfx(ejectorb, 1025)
	end
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	local corpse = 1
	local explodables = {hips, luparm, lloarm, lhand, fingerla, fingerlb, thumbl, ruparm, rloarm, rhand, fingerra, fingerrb, thumbr, body, arml, cannonl, canonbarrel1, canonbarrel2, cannonr}
	if severity <= 0.5 then
		for i = 1, #explodables do
			Explode(explodables[i], SFX.FALL + SFX.FIRE)
		end
	else
		corpse = 2
		for i = 1, #explodables do
			Explode(explodables[i], SFX.SHATTER)
		end
	end
	return corpse
end
