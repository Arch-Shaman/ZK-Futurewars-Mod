local base, fan, cradle, float = piece('base', 'fan', 'cradle', 'flaot')
include "constants.lua"

local baseDirection

local smokePiece = {base}

local hpi = math.pi*0.5

local UPDATE_PERIOD = 1000
local BUILD_PERIOD = 500

local turnSpeed = math.rad(20)
local waterFanSpin = math.rad(30)

local isWind, baseWind, rangeWind
local SIG_SPIN = 2
local forceStop = false

local rand = math.random

function InitializeWind()
	isWind, baseWind, rangeWind = GG.SetupWindmill(unitID)
	if isWind then
		Show(base)
		Show(float)
		Move(cradle, y_axis, 0)
		Turn(fan, x_axis, 0)
		Move(fan, z_axis, 0)
		Move(fan, y_axis, 0)
	else
		Hide(base)
		Hide(float)
		Move(cradle, y_axis, -51)
		Turn(fan, x_axis, hpi)
		Move(fan, z_axis, 9)
		Move(fan, y_axis, -5)
	end
end

local function BobTidal()
	-- Body movement models being somewhat free-floating upon the waves
	local bodySpinSpeed	= 0
	Signal(SIG_SPIN)
	SetSignalMask(SIG_SPIN)
	while true do
		bodySpinSpeed = 0.99*bodySpinSpeed + (rand() - 0.5) * 0.016
		Spin(cradle, y_axis, bodySpinSpeed)
		Spin(fan, z_axis, waterFanSpin + bodySpinSpeed)

		Move(cradle, x_axis, rand(-2,2), 0.3)
		Move(cradle, y_axis, rand(-2,2) * 0.5 - 51, 0.2)
		Move(cradle, z_axis, rand(-2,2), 0.3)
		Sleep(1000)

		if GG.Wind_SpinDisabled then
			StopSpin(fan, z_axis)
			StopSpin(cradle, y_axis)
			return
		end
	end
end

local oldWindStrength, oldWindHeading
function SpinWind()
	local buildProgress
	local bodySpinSpeed	= 0
	local spinning = false
	while true do
		_, _, _, _, buildProgress = Spring.GetUnitHealth(unitID)
		if forceStop then
			Sleep(200)
		elseif buildProgress < 1 then
			oldWindStrength = nil
			if spinning then
				StopSpin(fan, z_axis)
				StopSpin(cradle, y_axis)
				spinning = false
			end
			Sleep(BUILD_PERIOD)
		else
			if isWind then
				if GG.WindStrength and ((oldWindStrength ~= GG.WindStrength) or (oldWindHeading ~= GG.WindHeading)) then
					oldWindStrength, oldWindHeading = GG.WindStrength, GG.WindHeading
					local st = baseWind + (GG.WindStrength or 0)*rangeWind
					Spin(fan, z_axis, -st*(0.94 + 0.08*rand()))
					Turn(cradle, y_axis, GG.WindHeading - baseDirection + math.pi, turnSpeed)
					if not spinning then spinning = true end
				end
				Sleep(UPDATE_PERIOD + 200*rand())
			else
				if not spinning then spinning = true end
				bodySpinSpeed = 0.99*bodySpinSpeed + (rand() - 0.5) * 0.016
				Spin(cradle, y_axis, bodySpinSpeed)
				Spin(fan, z_axis, waterFanSpin + bodySpinSpeed)
				Move(cradle, x_axis, rand(-2,2), 0.3)
				Move(cradle, y_axis, rand(-2,2) * 0.5 - 51, 0.2)
				Move(cradle, z_axis, rand(-2,2), 0.3)
				Sleep(1000)
			end
		end
		if GG.Wind_SpinDisabled then
			StopSpin(fan, z_axis)
			return
		end
	end
end

function OnTransportChanged(isBeingTransporting)
	if isBeingTransporting then
		StopSpin(fan, z_axis)
		StopSpin(cradle, y_axis)
		Show(base)
		Show(float)
		Move(cradle, y_axis, 0)
		Turn(fan, x_axis, 0)
		Move(fan, z_axis, 0)
		Move(fan, y_axis, 0)
		forceStop = true
	else
		InitializeWind()
		forceStop = false
	end
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	
	baseDirection = math.random() * math.tau
	Turn(base, y_axis, baseDirection)
	baseDirection = baseDirection + hpi * Spring.GetUnitBuildFacing(unitID)
	StartThread(SpinWind)
	InitializeWind()
end

local function CreateTidalWreck()
	local x,y,z = Spring.GetUnitPosition(unitID)
	local heading = Spring.GetUnitHeading(unitID)
	local team = Spring.GetUnitTeam(unitID)
	local featureID = Spring.CreateFeature("energywind_deadwater", x, y, z, heading + baseDirection*65536/math.tau, team)
	Spring.SetFeatureResurrect(featureID, "energywind")
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if isWind then
		if severity <= 0.25 then
			Explode(base, SFX.SHATTER)
			Explode(fan, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
			Explode(base, SFX.SHATTER)
			return 1
		elseif severity <= 0.5 then
			Explode(base, SFX.SHATTER)
			Explode(fan, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
			Explode(cradle, SFX.SHATTER)
			return 1
		else
			Explode(base, SFX.SHATTER)
			Explode(fan, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
			Explode(cradle, SFX.SMOKE)
			return 2
		end
	else
		if severity <= 0.25 then
			--Explode(fan, SFX.SMOKE)
			--Explode(cradle, SFX.FIRE)
			CreateTidalWreck()
			return 3
		elseif severity <= 0.5 then
			--Explode(fan, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
			--Explode(cradle, SFX.SMOKE)
			CreateTidalWreck()
			return 3
		else
			Explode(fan, SFX.SHATTER)
			Explode(cradle, SFX.SHATTER)
			return 2
		end
	end
end
