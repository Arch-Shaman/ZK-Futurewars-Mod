local base = piece 'base'
local body = piece 'body'
local rfx = piece 'rfx'
local rjet = piece 'rjet'
local lfx = piece 'lfx'
local ljet = piece 'ljet'
local emit = piece 'emit'
local gun = piece 'gun'

local smokePiece = {base}

include "constants.lua"

local SIG_RESTORE = 1

local spGetUnitVelocity = Spring.GetUnitVelocity
local coolingOff = false
local overdriving = false
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local boostSpeed = 1.5

local function TiltWings()
	local lastSpeed = 0
	local maxSpeed = (UnitDefs[unitDefID].speed)/30
	local maxBoosted = maxSpeed * boostSpeed
	maxSpeed = maxSpeed * maxSpeed
	maxBoosted = maxBoosted * maxBoosted
	local speed, mult, vx, vz
	local turnRate = math.rad(90)
	while true do
		vx,_,vz,_ = spGetUnitVelocity(unitID)
		speed = vx*vx + vz*vz
		if lastSpeed ~= speed then
			if overdriving then
				mult = (speed / maxBoosted) * 90
			else
				mult = (speed / maxSpeed) * 90
			end
			Turn (rjet, x_axis, math.rad(mult), turnRate)
			Turn (ljet, x_axis, math.rad(mult), turnRate)
		end
		lastSpeed = speed
		Sleep(100)
	end
end

local function RestoreAfterDelay ()
	Signal (SIG_RESTORE)
	SetSignalMask (SIG_RESTORE)
	Sleep (3000)
	Turn (gun, y_axis, 0, math.rad(20))
	Turn (gun, x_axis, 0, math.rad(20))
end

function script.Create()
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread (TiltWings)
	Hide (lfx)
	Hide (rfx)
	Hide (emit)
	Turn (rfx, x_axis, math.rad(90))
	Turn (lfx, x_axis, math.rad(90))
end

function script.QueryWeapon(num)
	return emit
end

function script.AimFromWeapon(num)
	return gun
end

function script.AimWeapon(num, heading, pitch)
	Turn (gun, y_axis, heading, math.rad(360))
	Turn (gun, x_axis, -pitch, math.rad(360))
	StartThread (RestoreAfterDelay)
	return not coolingOff
end

function script.BlockShot(num)
	if coolingOff then return true end
	if num == 1 and not overdriving then return false end
	if num == 2 and overdriving then return false end
	return true
end

local function OverDriveThread()
	Sleep(7000)
	overdriving = false
	spSetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	spSetUnitRulesParam(unitID, "selfMaxAccelerationChange", 1)
	spSetUnitRulesParam(unitID, "selfTurnSpeedChange", 1)
	GG.Sprint.End(unitID)
	GG.UpdateUnitAttributes(unitID)
	coolingOff = true
	local reloadFrame = Spring.GetGameFrame() + 300
	Spring.SetUnitWeaponState(unitID, 1, "reloadFrame", reloadFrame) -- force the bar to render.
	Spring.SetUnitWeaponState(unitID, 1, "reloadTime",  10)
	local isReloading = true
	while isReloading do
		EmitSfx(gun, 1025)
		Sleep(66)
		isReloading = Spring.GetGameFrame() < Spring.GetUnitWeaponState(unitID, 1, "reloadFrame")
	end
	Spring.SetUnitWeaponState(unitID, 1, "reloadTime",  WeaponDefNames["gunshipraid_laser"].reload) -- return to normal.
	coolingOff = false
end

function Overdrive()
	GG.Sprint.Start(unitID, boostSpeed)
	spSetUnitRulesParam(unitID, "selfMoveSpeedChange", boostSpeed)
	spSetUnitRulesParam(unitID, "selfTurnSpeedChange", boostSpeed * 2)
	spSetUnitRulesParam(unitID, "selfMaxAccelerationChange", boostSpeed)
	GG.UpdateUnitAttributes(unitID)
	overdriving = true
	StartThread(OverDriveThread)
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if (severity <= .50 or ((Spring.GetUnitMoveTypeData(unitID).aircraftState or "") == "crashing")) then
		Explode (body, SFX.SHATTER)
		Explode (rjet, SFX.FALL)
		return 1
	else
		Explode (gun, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode (ljet, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode (rjet, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode (body, SFX.SHATTER)
		return 2
	end
end
