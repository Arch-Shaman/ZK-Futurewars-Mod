include 'constants.lua'
include "pieceControl.lua"

local base = piece "base"
local wheel = piece "wheel"
local pumpcylinders = piece "pumpcylinders"
local turret = piece "turret"
local pump1 = piece "pump1"
local pump2 = piece "pump2"
local pump3 = piece "pump3"

local ALLY_ACCESS = {allied = true}
local active = false
local powered = false
local stunned = false
local wantedState = false

local spGetUnitRulesParam 	= Spring.GetUnitRulesParam
local spSetUnitRulesParam 	= Spring.SetUnitRulesParam

local function UpdateShieldThread()
	local regenstate = true
	local stunned = false
	local shieldammount = 9999
	local maxshield = WeaponDefNames["staticheavyshield_big_shield"].shieldPower
	local last = 0
	while true do
		Sleep(300) -- every 10th frame (3hz)
		powered = spGetUnitRulesParam(unitID, "lowpower") == 1
		stunned = Spring.GetUnitIsStunned(unitID)
		local overdrive = spGetUnitRulesParam(unitID,"superweapon_mult") or 0
		spSetUnitRulesParam(unitID, "selfReloadSpeedChange", overdrive)
		GG.UpdateUnitAttributes(unitID)
		wantedState = (not powered) and active and (not stunned)
		if last ~= shieldammount then
			local spinrate = shieldammount / maxshield
			Spin(wheel, y_axis, 9 * overdrive * spinrate , 0.1)
			Spin(turret, y_axis, -3 * overdrive * spinrate, 0.01)
		end
		last = shieldammount
		_, shieldammount = Spring.GetUnitShieldState(unitID, 1)
		--Spring.Echo("Wanted state: " .. tostring(wantedState) .. "{ " .. tostring(active) .. ", " .. tostring(stunned) .. ", " .. tostring(powered) .. "}")
		if wantedState and not regenstate then
			spSetUnitRulesParam(unitID, "shieldChargeDisabled", 0, ALLY_ACCESS)
			regenstate = true
		elseif not wantedState and regenstate then
			spSetUnitRulesParam(unitID, "shieldChargeDisabled", 1, ALLY_ACCESS)
			GG.PieceControl.StopTurn(wheel, y_axis)
			GG.PieceControl.StopTurn(turret, y_axis)
			regenstate = false
		end
		if not regenstate and shieldammount > 0 then
			shieldammount = shieldammount - 1000
			Spring.SetUnitShieldState(unitID, 1, math.max(shieldammount, 0))
		end
	end
end

local function Initialize()
	Signal(1)
	SetSignalMask(2)
	while (true) do
		while powered do
			Sleep(100)
		end
		Move(pumpcylinders, z_axis, -11, 15)
		Turn(pump1, x_axis, -1.4, 2)
		Turn(pump2, z_axis, -1.4, 2)
		Turn(pump3, z_axis, 1.4, 2)

		WaitForMove(pumpcylinders, z_axis)
		WaitForTurn(pump1, x_axis)
		WaitForTurn(pump2, z_axis)
		WaitForTurn(pump3, z_axis)

		Move(pumpcylinders, z_axis, 0, 15)
		Turn(pump1, x_axis, 0, 2)
		Turn(pump2, z_axis, 0, 2)
		Turn(pump3, z_axis, 0, 2)

		WaitForMove(pumpcylinders, z_axis)
		WaitForTurn(pump1, x_axis)
		WaitForTurn(pump2, z_axis)
		WaitForTurn(pump3, z_axis)
	end
end

function script.AimFromWeapon(num)
	return turret
end

function script.AimWeapon(num, heading, pitch)
	return true
end

function script.QueryWeapon(num)
	return turret
end

local function Deinitialize()
	Signal(2)
	SetSignalMask(1)

	StopSpin(wheel, y_axis, 0.1)
	StopSpin(turret, y_axis, 0.1)
end

function script.Create()
	Spring.SetUnitRulesParam(unitID, "lowpower", 1, ALLY_ACCESS)
	StartThread(UpdateShieldThread)
	Turn(pump2, y_axis, -0.523598776)
	Turn(pump3, y_axis, 0.523598776)
	Spring.SetUnitRulesParam(unitID, "unitActiveOverride", 1)
	active = true
end

function script.Activate()
	active = true
	StartThread(Initialize)
end

function script.Deactivate()
	--Spring.SetUnitShieldState(unitID, -1, true) -- don't allow it to hide the shield.
	active = false
	StartThread(Deinitialize)
end

-- Invulnerability
--function script.HitByWeapon()
--	return 0
--end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity < 0.5 then
		Explode(base, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(pumpcylinders, SFX.NONE)
		Explode(wheel, SFX.FALL)
		return 1
	else
		Explode(base, SFX.SHATTER)
		Explode(turret, SFX.SHATTER)
		Explode(pumpcylinders, SFX.SHATTER)
		Explode(wheel, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		return 2
	end
end
