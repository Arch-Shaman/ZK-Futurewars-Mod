include "constants.lua"

local base, body, turret, barrel, flare, lrepflare, rrepflare = piece('base', 'body', 'turret', 'barrel', 'flare', 'lrepflare', 'rrepflare')

local deployed = false

local nanoPieces = {[0] = rrepflare, [1] = lrepflare}
local smokePiece = {turret}
local turnrate = math.rad(120)

local SIG_AIM = 1
local SIG_RESTORE = 2

local function DeployThread()
	Turn(barrel, x_axis, math.rad(45), math.rad(90))
	Turn(barrel, y_axis, math.rad(45), math.rad(90))
	Turn(barrel, z_axis, math.rad(45), math.rad(90))
	WaitForTurn(barrel, y_axis)
	Turn(barrel, x_axis, math.rad(0), math.rad(90))
	Turn(barrel, y_axis, math.rad(0), math.rad(90))
	Turn(barrel, z_axis, math.rad(0), math.rad(90))
	WaitForTurn(barrel, y_axis)
	deployed = true
	SetUnitValue(COB.INBUILDSTANCE, 1)
end

local function RestoreAfterDelay()
	Signal(SIG_RESTORE)
	SetSignalMask(SIG_RESTORE)
	Sleep(5000)
	Turn(barrel, y_axis, 0, turnrate/2)
	Turn(barrel, z_axis, 0, turnrate/2)
end

function script.QueryWeapon(num)
	return flare
end

function script.AimFromWeapon(num)
	return barrel
end

function script.AimWeapon(num, heading, pitch)
	if not deployed then return false end
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(turret, y_axis, -heading, turnrate)
	Turn(barrel, z_axis, -pitch, turnrate)
	WaitForTurn(barrel, z_axis)
	WaitForTurn(barrel, y_axis)
	return true
end

function script.Create()
	Turn(turret, y_axis, 0)
	SetUnitValue(COB.INBUILDSTANCE, 0)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	Turn(barrel, x_axis, math.rad(90))
	Turn(barrel, z_axis, math.rad(90))
	Spring.SetUnitNanoPieces(unitID, nanoPieces)
	StartThread(DeployThread)
end

function script.Killed(recentDamage, maxHealth)
	local explodables = {body, turret, barrel}
	for i = 1, 3 do
		Explode(explodables[i], SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
	end
end
