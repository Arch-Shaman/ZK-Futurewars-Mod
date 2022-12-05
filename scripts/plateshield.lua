include "constants.lua"
include "plates.lua"

local base, turret, arm_1, arm_2, arm_3, nanobase, rightpiece, leftpiece, nanoemit, pad, nozzle, cylinder, back = piece ('base', 'turret', 'arm_1', 'arm_2', 'arm_3', 'nanobase', 'rightpiece', 'leftpiece', 'nanoemit', 'pad', 'nozzle', 'cylinder', 'back')

local nanoPieces = { nanoemit }
local smokePiece = { base }
local enabled = true -- is the shield enabled?

local function Open ()
	Signal (1)
	SetSignalMask (1)

	Turn (arm_1, x_axis, math.rad(-85), math.rad(85))
	Turn (arm_2, x_axis, math.rad(170), math.rad(170))
	Turn (arm_3, x_axis, math.rad(-60), math.rad(60))
	Turn (nanobase, x_axis, math.rad(10), math.rad(10))
	WaitForTurn (nanobase, x_axis)

	SetUnitValue (COB.YARD_OPEN, 1)
	SetInBuildDistance(true)
	--SetUnitValue (COB.BUGGER_OFF, 1)
end

local function Close()
	Signal (1)
	SetSignalMask (1)

	SetUnitValue (COB.YARD_OPEN, 0)
	--SetUnitValue (COB.BUGGER_OFF, 0)
	SetInBuildDistance(false)

	Turn (arm_1, x_axis, 0, math.rad(34))
	Turn (arm_2, x_axis, 0, math.rad(68))
	Turn (arm_3, x_axis, 0, math.rad(24))
	Turn (nanobase, x_axis, 0, math.rad(4))
end

local function IsDisabled()
	local nofac = Spring.GetUnitRulesParam(unitID, "nofactory")
	return (nofac and nofac == 1) or false
end

local function ShieldEnableThread()
	local isDisabled = false
	local power = 0
	while true do
		isDisabled = IsDisabled()
		if isDisabled then -- we're on, but we want to be turned off.
			if enabled then
				_, power = Spring.GetUnitShieldState(unitID, 1)
			end
			enabled = false
			Spring.SetUnitShieldState(unitID, 1, false, 0)
		elseif not isDisabled and not enabled then -- we're off, but we want to be turned on.
			enabled = true
			Spring.SetUnitShieldState(unitID, 1, true, power)
		end
		Sleep(200)
	end
end

function script.Create()
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
	Spring.SetUnitNanoPieces (unitID, nanoPieces)
	StartThread(ShieldEnableThread)
end

function script.QueryNanoPiece ()
	GG.LUPS.QueryNanoPiece (unitID, unitDefID, Spring.GetUnitTeam(unitID), nanoemit)
	return nanoemit
end

function script.Activate ()
	StartThread (Open)
end

function script.Deactivate ()
	StartThread (Close)
end

function script.QueryBuildInfo ()
	return pad
end

function script.QueryWeapon()
	return pad
end

local explodables = {nozzle, cylinder, arm_1, arm_2, arm_3}
function script.Killed (recentDamage, maxHealth)
	local severity = recentDamage / maxHealth

	for i = 1, #explodables do
		if (severity > math.random()) then Explode(explodables[i], SFX.SMOKE + SFX.FIRE) end
	end

	if (severity <= .5) then
		return 1
	else
		Explode (back, SFX.SHATTER)
		Explode (leftpiece, SFX.SHATTER)
		Explode (rightpiece, SFX.SHATTER)
		return 2
	end
end
