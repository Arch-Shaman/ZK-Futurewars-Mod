local ground = piece 'ground'
local base = piece 'base'
local flare = piece 'flare'
local muzzle = piece 'muzzle'
local turret = piece 'turret'
local barrel = piece 'barrel'
local barrel_back = piece 'barrel_back'
local sleeve = piece 'sleeve'
local query = piece 'query'

include "constants.lua"
include "pieceControl.lua"
include "QueryWeaponFixHax.lua"

local spGetUnitIsStunned = Spring.GetUnitIsStunned
local spGetUnitRulesParam = Spring.GetUnitRulesParam

-- Signal definitions
local SIG_AIM = 2

local ammoState = 0
local gunLoaded = true

local smokePiece = {base, turret, ground}
local turretSpeed = math.rad(10)
local sleeveSpeed = math.rad(5)

local function DisableCheck()
	while true do
		if select(1, spGetUnitIsStunned(unitID)) then
			if GG.PieceControl.StopTurn(sleeve, x_axis) then
				Signal(SIG_AIM)
			end
			if GG.PieceControl.StopTurn(turret, y_axis) then
				Signal(SIG_AIM)
			end
		end
		Sleep(500)
	end
end

function script.Create()
	Hide(flare)
	Hide(muzzle)
	--Hide(barrel_back)
	Turn(sleeve, x_axis, -math.rad(60))
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(DisableCheck)

	SetupQueryWeaponFixHax(query, flare)
end

function script.AimWeapon(num, heading, pitch)
	if (((num - 1) ~= ammoState) or (spGetUnitRulesParam(unitID, "lowpower") == 1)) then
		return
	end
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	
	local speedMult = (Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0)
	Turn(turret, y_axis, heading, turretSpeed * speedMult)
	Turn(sleeve, x_axis, -pitch, sleeveSpeed * speedMult)
	WaitForTurn(turret, y_axis)
	WaitForTurn(sleeve, x_axis)
	StartThread(AimingDone) -- what?
	return (spGetUnitRulesParam(unitID, "lowpower") == 0) and GG.FireControl.CanFireWeapon(unitID, num)
end

function script.FireWeapon(num)
	local speedMult = (Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0)
	GG.FireControl.WeaponFired(unitID, num)
	EmitSfx(ground, GG.Script.UNIT_SFX1)
	Move(barrel, z_axis, -24, 500)
	EmitSfx(barrel_back, GG.Script.UNIT_SFX2)
	EmitSfx(muzzle, GG.Script.UNIT_SFX3)
	WaitForMove(barrel, z_axis)
	Move(barrel, z_axis, 0, 6 * speedMult)
end

function script.BlockShot(num, targetID)
	local cantFire = not GG.FireControl.CanFireWeapon(unitID, num)
	return (not gunLoaded) or ((num - 1) ~= ammoState) or cantFire
end

function script.QueryWeapon(num)
	return GetQueryPiece()
end

function script.AimFromWeapon(num)
	return query
end

function OnAmmoTypeChange(newAmmo)
	GG.FireControl.WeaponFired(unitID, 1)
	GG.FireControl.WeaponFired(unitID, 2)
	GG.FireControl.WeaponFired(unitID, 3)
	ammoState = newAmmo
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if severity <= 0.25 then
		return 1
	elseif severity <= 0.50 then
		Explode(sleeve, SFX.SHATTER)
		Explode(turret, SFX.SHATTER)
		return 1
	else
		Explode(base, SFX.SHATTER + SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(sleeve, SFX.SHATTER + SFX.EXPLODE_ON_HIT)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		return 2
	end
end
