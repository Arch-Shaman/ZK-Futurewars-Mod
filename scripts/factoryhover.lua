include "constants.lua"

local beams = {}
for i = 1, 6 do
	beams[i] = piece ('beam' .. i)
end
local base, gate_l, gate_r, nano = piece ('base', 'gate_l', 'gate_r', 'nano')
-- there's also the "doormat" piece, not used for anything though

local nanoPieces = beams
local smokePiece = { base }

local function Open ()
	Signal (1)
	SetSignalMask (1)

	Turn (gate_l, z_axis, math.rad(-90), math.rad(135))
	Turn (gate_r, z_axis, math.rad( 90), math.rad(135))
	WaitForTurn (gate_l, z_axis)

	Move (nano, y_axis, 7.625, 17.5)
	WaitForMove (nano, y_axis)

	SetUnitValue(COB.YARD_OPEN, 1)
	SetUnitValue(COB.INBUILDSTANCE, 1)
	--SetUnitValue(COB.BUGGER_OFF, 1)
	GG.Script.UnstickFactory(unitID)
end

local function Close()
	Signal (1)
	SetSignalMask (1)

	SetUnitValue(COB.YARD_OPEN, 0)
	--SetUnitValue(COB.BUGGER_OFF, 0)
	SetUnitValue(COB.INBUILDSTANCE, 0)

	Move (nano, y_axis, 0, 17.5)
	WaitForMove (nano, y_axis)

	Turn (gate_l, z_axis, 0, math.rad(135))
	Turn (gate_r, z_axis, 0, math.rad(135))
	-- WaitForTurn (gate_l, z_axis)
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
	local WAVE_RELOAD = WeaponDefNames["factoryhover_armorfield"].reload * 30
	local reloaded
	while true do
		Sleep(100)
		health, _, _, _, build = spGetUnitHealth(unitID)
		while build < 1 do
			Sleep(200)
			health, _, _, _, build = spGetUnitHealth(unitID)
		end
		reloaded = select(2, spGetUnitWeaponState(unitID,1))
		if reloaded and health > 0 and build >= 1 then
			local gameFrame = spGetGameFrame()
			local reloadMult = spGetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1.0
			local reloadFrame = gameFrame + WAVE_RELOAD / reloadMult
			spSetUnitWeaponState(unitID, 1, {reloadFrame = reloadFrame})
			EmitSfx(base, 4096)
		end
	end
end

function script.QueryWeapon()
	return base
end

function script.AimFromWeapon()
	return base
end

function script.AimWeapon()
	return false
end

function script.Create()
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
	Spring.SetUnitNanoPieces (unitID, nanoPieces)
	StartThread(AutoAttack)
end

function script.Activate ()
	StartThread (Open)
end

function script.Deactivate ()
	StartThread (Close)
end

function script.QueryBuildInfo ()
	return base
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
		Explode (base, sfx.SHATTER)
		return 2
	end
end
