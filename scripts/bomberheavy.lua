include "constants.lua"
include "bombers.lua"
include "fixedwingTakeOff.lua"


local base       = piece 'base'
local wing_L     = piece 'wing_L'
local wing_R     = piece 'wing_R'
local drop       = piece 'drop'
local extra_L    = piece 'extra_L'
local extra_R    = piece 'extra_R'
local radiator_L = piece 'radiator_L'
local radiator_R = piece 'radiator_R'
local rad_L      = piece 'rad_L' -- empty piece for fx
local rad_R      = piece 'rad_R'
local hatch_L    = piece 'hatch_L'
local hatch_R    = piece 'hatch_R'
local ball       = piece 'ball'
local thrust_L, thrust_R = piece('thrust_L', 'thrust_R')

local smokePiece = {base, radiator_L, radiator_R}

--Signal
local SIG_move = 1
local SIG_TAKEOFF = 2
local takeoffHeight = UnitDefNames["bomberheavy"].wantedHeight

local armedspeed = 1.0
local unarmedspeed = 1 + 1/3

local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitMoveTypeData = Spring.GetUnitMoveTypeData
local spSetUnitRulesParam = Spring.SetUnitRulesParam
--local SetAirMoveTypeData = Spring.MoveCtrl.SetAirMoveTypeData
local movectrlGetTag = Spring.MoveCtrl.GetTag
local deathexplosiontriggered = false
local ammoState = 0

local armed = true
local cooling = false

local function DeathExplosion()
	if ammoState == 0 then
		local px, py, pz = Spring.GetUnitPosition(unitID)
		local vx, vy, vz = Spring.GetUnitVelocity(unitID)
		Spring.SpawnProjectile(WeaponDefNames["bomberheavy_deathexplo"].id, {
			pos = {px, py + 5, pz},
			speed = {vx, vy, vz},
			gravity = -1,
			team = Spring.GetGaiaTeamID(),
			owner = unitID,
		})
		deathexplosiontriggered = true
	end
end

local function UpdateCooling()
	if not armed and not cooling then
		Show(radiator_L)
		Show(radiator_R)
		Turn(hatch_L, y_axis, math.rad(-90), 2)
		Turn(hatch_R, y_axis, math.rad( 90), 2)
		Move(radiator_L, z_axis, 3, 1)
		Move(radiator_R, z_axis, 3, 1)
		Move(rad_L, z_axis, 3, 1)
		Move(rad_R, z_axis, 3, 1)
		--Spin(ball, y_axis, 0)
		cooling = true
	end

	if armed and cooling then
		Move(radiator_L, z_axis, 0, 2)
		Move(radiator_R, z_axis, 0, 2)
		Move(rad_L, z_axis, -2, 2)
		Move(rad_R, z_axis, -2, 2)
		Turn(hatch_L, y_axis, math.rad(0), 1)
		Turn(hatch_R, y_axis, math.rad(0), 1)
		--Spin(ball, y_axis, math.rad(30))
		WaitForTurn (hatch_L, y_axis)
		WaitForTurn (hatch_R, y_axis)
		Hide(radiator_L)
		Hide(radiator_R)
		cooling = false
	end
end



function OnAmmoChange(newState)
	ammoState = newState
	if newState == 0 then
		spSetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
		spSetUnitRulesParam(unitID, "selfMaxAccelerationChange", 1)
		armed = true
		GG.UpdateUnitAttributes(unitID)
	elseif newState == 1 then
		spSetUnitRulesParam(unitID, "selfMoveSpeedChange", unarmedspeed)
		spSetUnitRulesParam(unitID, "selfMaxAccelerationChange", unarmedspeed)
		armed = false
		GG.UpdateUnitAttributes(unitID)
	end
	--UpdateCooling()
end

local function Fly()
	Move(wing_L, x_axis, 0, 6)
	Move(wing_R, x_axis, 0, 6)
	Move(wing_L, y_axis, 0, 8)
	Move(wing_R, y_axis, 0, 8)

	Move(extra_L, x_axis, 0, 3)
	Move(extra_R, x_axis, 0, 3)
	Turn(extra_L, z_axis, math.rad(-30), 2)
	Turn(extra_R, z_axis, math.rad( 30), 2)
	WaitForTurn (extra_L, z_axis)
	WaitForTurn (extra_R, z_axis)

	Turn(extra_L, z_axis, math.rad(0), 1)
	Turn(extra_R, z_axis, math.rad(0), 1)
end

local function WingStart()
	Move(wing_L, x_axis, -7, 0)
	Move(wing_R, x_axis,  7, 0)
	Move(wing_L, y_axis, -9, 0)
	Move(wing_R, y_axis, -9, 0)

	Turn(extra_L, z_axis, math.rad(-30), 0)
	Turn(extra_R, z_axis, math.rad( 30), 0)
	WaitForTurn (extra_L, z_axis)
	WaitForTurn (extra_R, z_axis)

	Turn(extra_L, z_axis, math.rad(-146.3), 0)
	Turn(extra_R, z_axis, math.rad( 146.3), 0)
	WaitForTurn (extra_L, z_axis)
	WaitForTurn (extra_R, z_axis)

	Move(extra_L, x_axis, -1, 0)
	Move(extra_R, x_axis,  1, 0)
end

local function Land()
	Turn(extra_L, z_axis, math.rad(-30), 3)
	Turn(extra_R, z_axis, math.rad( 30), 3)

	WaitForTurn (extra_L, z_axis)
	WaitForTurn (extra_R, z_axis)

	Turn(extra_L, z_axis, math.rad(-146.3), 2)
	Turn(extra_R, z_axis, math.rad( 146.3), 2)

	Move(wing_L, x_axis, -7, 6)
	Move(wing_R, x_axis,  7, 6)

	Move(wing_L, y_axis, -9, 8)
	Move(wing_R, y_axis, -9, 8)

	WaitForTurn (extra_L, z_axis)
	WaitForTurn (extra_R, z_axis)

	Move(extra_L, x_axis, -1, 3)
	Move(extra_R, x_axis,  1, 3)
end

function OnStartingCrash()
	DeathExplosion()
end

local function Stopping()
	Signal(SIG_move)
	SetSignalMask(SIG_move)
	Land()
end

local function Moving()
	Signal(SIG_move)
	SetSignalMask(SIG_move)
	Fly()
end

function script.StartMoving()
	StartThread(Moving)
end

function script.StopMoving()
	StartThread(Stopping)
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
end

function script.MoveRate(rate)
	if rate == 1 then
		Turn(base, z_axis, math.rad(-240), math.rad(120))
		WaitForTurn(base, z_axis)
		Turn(base, z_axis, math.rad(-(120)), math.rad(180))
		WaitForTurn(base, z_axis)
		Turn(base, z_axis, 0, math.rad(120))
	end
end

function script.Create()
	Move(thrust_L, y_axis, -5)
	Move(thrust_R, y_axis, -5)

	Turn(thrust_L, x_axis, math.rad(90))
	Turn(thrust_R, x_axis, math.rad(90))

	Turn(rad_L, x_axis, math.rad(180))
	Turn(rad_R, x_axis, math.rad(180))
	Move(rad_L, z_axis, -2)
	Move(rad_R, z_axis, -2)

	WingStart()
	Hide(ball)
	Hide(radiator_L)
	Hide(radiator_R)
	SetInitialBomberSettings()
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)

end

function script.FireWeapon(num)
	SetUnarmedAI()
	OnAmmoChange(1)
	Sleep(50)	-- delay before clearing attack order; else bomb loses target and fails to home
	Reload()
end

function script.AimWeapon(num)
	return true
end

function script.QueryWeapon(num)
	return drop
end

function script.BlockShot(num)
	return (GetUnitValue(COB.CRASHING) == 1) or RearmBlockShot()
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if not deathexplosiontriggered then
		DeathExplosion()
	end
	local effect = SFX.FALL + SFX.SMOKE + SFX.FIRE
	if severity > .50 then effect = effect + SFX.EXPLODE end
	if severity <= .25 then
		Explode(base, SFX.NONE)
		Explode(wing_L, SFX.NONE)
		Explode(wing_R, SFX.NONE)
		return 1
	elseif severity <= .50 or ((Spring.GetUnitMoveTypeData(unitID).aircraftState or "") == "crashing") then
		Explode(wing_L, effect)
		Explode(wing_R, effect)
		return 1
	elseif severity <= .75 then
		Explode(wing1, effect)
		Explode(wing2, effect)
		return 2
	else
		Explode(wing1, effect)
		Explode(wing2, effect)
		return 2
	end
end
