include "constants.lua"

local spGetUnitRulesParam 	= Spring.GetUnitRulesParam

local base, turret, breech, barrel2, flare = piece("base", "turret", "breech", "barrel2", "flare")
-- unused piece: barrel1
local smokePiece = {base, turret}

local turnrate = math.rad(33.2)

local delay = {}
for i=1, #UnitDef.weapons do
	delay[i] = WeaponDefs[UnitDef.weapons[i].weaponDef].customParams.aimdelay
end

local reloading = false

-- Signal definitions
local SIG_AIM = 1

function ReloadWatcher()
	local reloadFrame, frame
	while true do
		Sleep(33)
		frame = Spring.GetGameFrame()
		_, _, reloadFrame = Spring.GetUnitWeaponState(unitID, 1)
		if reloadFrame and reloadFrame > frame then
			reloading = true
			GG.AimDelay_ForceWeaponRestart(unitID, 1)
		else
			reloading = false
		end
	end
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	if (spGetUnitRulesParam(unitID, "lowpower") ~= 0) then --checks for sufficient energy in grid
		return false
	end
	Turn(turret, y_axis, heading, turnrate)
	Turn(breech, x_axis, 0 - pitch, turnrate)
	WaitForTurn(breech, x_axis)
	WaitForTurn(turret, y_axis)
	if num == 2 then return false end
	if reloading then
		return false
	else
		return GG.AimDelay_AttemptToFire(unitID, num, heading, pitch, delay[num])
	end
end

function script.AimFromWeapon(num) return breech end

function script.BlockShot(num, targetID)
	if num == 2 then return true end
	return (targetID and GG.DontFireRadar_CheckBlock(unitID, targetID)) or false
end

function script.QueryWeapon(num)
	return flare
end

local function Recoil()
	EmitSfx(flare, 1024)
	Move(barrel2, z_axis, -6)
	Sleep(300)
	Move(barrel2, z_axis, 0, 1.5)
end

function script.Shot(num)
	StartThread(Recoil)
	GG.AimDelay_ForceWeaponRestart(unitID, 1)
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(base, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(breech, SFX.NONE)
		return 1
	elseif severity <= .50 then
		Explode(base, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(breech, SFX.NONE)
		return 1
	elseif severity <= .99 then
		Explode(base, SFX.SHATTER)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode(breech, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		return 2
	else
		Explode(base, SFX.SHATTER)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(breech, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	end
end
