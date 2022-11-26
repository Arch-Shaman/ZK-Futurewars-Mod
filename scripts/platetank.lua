include "constants.lua"
include "plates.lua"

--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------
local base, body, bodyl, bodyr, turret, barrel, pad, nano = piece('base', 'body', 'bodyl', 'bodyr', 'turret', 'barrel', 'pad', 'nano')

local nanoPieces = { nano }
local smokePiece = { body, bodyl, bodyr }
local stuns = {}
local SIG_AIM = 2
local turnrate = 45.5 -- degrees/sec
turnrate = turnrate / 30
local isAiming = false

local function RestoreAfterDelay()
	SetSignalMask (SIG_AIM)

	Sleep (5000)

	Turn (turret, y_axis, 0, turnrate * 0.75)
	Turn (barrel, x_axis, 0, turnrate * 0.75)

	WaitForTurn (turret, y_axis)
	WaitForTurn (barrel, x_axis)
	isAiming = false
end

local function GetDisabled()
	return Spring.GetUnitIsStunned(unitID) or (Spring.GetUnitRulesParam(unitID, "disarmed") == 1)
end

function Stunned(stun_type)
	stuns[stun_type] = true

	disarmed = true
	Signal (SIG_AIM)
	--StopPieceTurn(turret, y_axis)
	--StopPieceTurn(barrel, x_axis)
end

function Unstunned(stun_type)
	stuns[stun_type] = false

	if not stuns[1] and not stuns[2] and not stuns[3] then
		disarmed = false
		StartThread(RestoreAfterDelay)
	end
end

local function Open ()
	Signal (1)
	SetSignalMask (1)
	
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
end

function script.Create()
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
	Spring.SetUnitNanoPieces (unitID, nanoPieces)
end

function script.QueryNanoPiece ()
	GG.LUPS.QueryNanoPiece (unitID, unitDefID, Spring.GetUnitTeam(unitID), nano)
	return nano
end

function script.Activate ()
	StartThread (Open)
end

function script.Deactivate ()
	--StartThread (Close)
end

function script.QueryWeapon(num)
	return barrel
end

local function IsDisabled()
	local nofac = Spring.GetUnitRulesParam(unitID, "nofactory")
	return (nofac and nofac == 1) or false
end

function script.AimWeapon(num, heading, pitch)
	if IsDisabled() then
		return false
	end
	Signal(SIG_AIM)
	SetSignalMask (SIG_AIM)
	local slowMult = (Spring.GetUnitRulesParam (unitID, "baseSpeedMult") or 1)
	Turn (turret, y_axis, heading, turnrate*slowMult)
	Turn (barrel, x_axis,  -pitch, turnrate*slowMult)
	WaitForTurn(turret, y_axis)
	WaitForTurn(barrel, x_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(num)
	Move(barrel, x_axis, -2) -- TODO: Add flare @HigherFlyer!
	Move(barrel, x_axis, 0, 1)
end

function script.BlockShot(num, targetID)
	return IsDisabled() -- disallow firing while cockblocked by lack of factory.
end

function script.QueryBuildInfo ()
	return pad
end

local explodables = {turret, barrel, bodyl, bodyr}
function script.Killed (recentDamage, maxHealth)
	local severity = recentDamage / maxHealth

	for i = 1, #explodables do
		if (severity > math.random()) then Explode(explodables[i], SFX.SMOKE + SFX.FIRE) end
	end

	if (severity <= .5) then
		return 1
	else
		Explode (body, SFX.SHATTER)
		return 2
	end
end
