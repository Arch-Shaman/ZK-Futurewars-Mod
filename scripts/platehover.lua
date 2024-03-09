include "constants.lua"
include "plates.lua"

local beams = {}
for i = 1, 3 do
	beams[i] = piece ('beam' .. i)
end
local base, house, pad, gate, nano = piece ('base', 'house', 'pad', 'gate', 'nano')
-- there's also the "doormat" piece, not used for anything though

local nanoPieces = beams
local smokePiece = { base }

function script.QueryWeapon()
	return base
end

function script.AimFromWeapon()
	return base
end

function script.AimWeapon()
	return false
end

local function AutoAttack()
	--Signal(SIG_ACTIVATE)
	--SetSignalMask(SIG_ACTIVATE)
	local spGetUnitHealth = Spring.GetUnitHealth
	local spGetUnitWeaponState = Spring.GetUnitWeaponState
	local spGetUnitRulesParam = Spring.GetUnitRulesParam
	local spSetUnitWeaponState = Spring.SetUnitWeaponState
	local spGetGameFrame = Spring.GetGameFrame
	local health, _, _, _, build = spGetUnitHealth(unitID)
	local WAVE_RELOAD = WeaponDefNames["platehover_armorfield"].reload * 30
	local reloaded = true
	local powered = true
	while true do
		Sleep(100)
		powered = (spGetUnitRulesParam(unitID, "nofactory") or 0) == 0
		health, _, _, _, build = spGetUnitHealth(unitID)
		while build < 1 or not powered do
			Sleep(200)
			health, _, _, _, build = spGetUnitHealth(unitID)
			powered = (spGetUnitRulesParam(unitID, "nofactory") or 0) == 0
		end
		reloaded = select(2, spGetUnitWeaponState(unitID, 1))
		if reloaded and health > 0 and build >= 1 then
			local gameFrame = spGetGameFrame()
			local reloadMult = spGetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1.0
			local reloadFrame = gameFrame + WAVE_RELOAD / reloadMult
			spSetUnitWeaponState(unitID, 1, {reloadFrame = reloadFrame})
			EmitSfx(base, 4096)
		end
	end
end

local function Open ()
	Signal (1)
	SetSignalMask (1)

	Turn (gate, x_axis, math.rad(-90), math.rad(135))
	WaitForTurn (gate, z_axis)

	Move (nano, y_axis, 7.625, 17.5)
	WaitForMove (nano, y_axis)

	SetUnitValue(COB.YARD_OPEN, 1)
	SetInBuildDistance(true)
	--SetUnitValue(COB.BUGGER_OFF, 1)
end

local function Close()
	Signal (1)
	SetSignalMask (1)

	SetUnitValue(COB.YARD_OPEN, 0)
	--SetUnitValue(COB.BUGGER_OFF, 0)
	SetInBuildDistance(fals)

	Move (nano, y_axis, 0, 17.5)
	WaitForMove (nano, y_axis)

	Turn (gate, x_axis, 0, math.rad(135))
end

function script.Create()
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
	Spring.SetUnitNanoPieces (unitID, nanoPieces)
	StartThread(AutoAttack)
end

function script.Activate ()
	StartThread(Open)
end

function script.Deactivate ()
	StartThread(Close)
end

function script.QueryBuildInfo ()
	return pad
end

local explodables = beams
function script.Killed (recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	local brutal = (severity > 0.5)
	local sfx = SFX

	local effect = sfx.FALL + (brutal and (sfx.SMOKE + sfx.FIRE) or 0)
	for i = 1, #explodables do
		if math.random() < severity then
			Explode (explodables[i], effect)
		end
	end

	if not brutal then
		return 1
	else
		Explode (nano, sfx.SHATTER)
		Explode (house, sfx.SHATTER)
		return 2
	end
end
