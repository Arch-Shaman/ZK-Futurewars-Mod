include "constants.lua"
local scriptReload = include("scriptReload.lua")

--pieces
local base = piece "base"
local wingR, wingL, wingtipR, wingtipL = piece("wingr", "wingl", "wingtip1", "wingtip2")
local engineR, engineL, thrust1, thrust2, thrust3 = piece("jetr", "jetl", "thrust1", "thrust2", "thrust3")
local missR, missL = piece("m1", "m2")

local smokePiece = {base, engineL, engineR}
local gameSpeed = Game.gameSpeed

--constants
local gundefs = {
	[0] = {firepoint = missR, loaded = true},
	[1] = {firepoint = missL, loaded = true},
	[2] = {firepoint = missR, loaded = true},
	[3] = {firepoint = missL, loaded = true},
}

--variables
local hasfired = false
local landed = false
local lastfire = 0
local shot = 0
local RESTORE_DELAY = 150
local FIRE_SLOWDOWN = tonumber(UnitDef.customParams.combat_slowdown)

--signals
local SIG_Aim = 1
local SIG_RESTORE = 2

----------------------------------------------------------

local function getState()
	local state = Spring.GetUnitStates(unitID)
	return state and state.active
end

local function reload(num)
	scriptReload.GunStartReload(num)
	gundefs[num].loaded = false
	scriptReload.SleepAndUpdateReload(num, 5 * gameSpeed)
	if scriptReload.GunLoaded(num) then
		shot = 0
	end
	gundefs[num].loaded = true
end


function WeaponEnder()
	local x, y, z
	while true do
		if Spring.GetGameFrame() - 3 > lastfire and hasfired then
			x, y, z = Spring.GetUnitPosition(unitID)
			GG.PlayFogHiddenSound("sounds/weapon/brrt_final.wav", 10.5, x, y, z, 1, 1, 1, 1)
			hasfired = false
		end
		Sleep(100)
	end
end

function script.Create()
	Turn(thrust1, x_axis, -math.rad(90), 1)
	Turn(thrust2, x_axis, -math.rad(90), 1)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(WeaponEnder)
	scriptReload.SetupScriptReload(4, 5 * gameSpeed)
	landed = false
end

function script.StartMoving()
	landed = false
	Turn(engineL, z_axis, -1.57, 1)
	Turn(engineR, z_axis, 1.57, 1)
	Turn(engineL, y_axis, -1.57, 1)
	Turn(engineR, y_axis, 1.57, 1)
	Turn(engineL, x_axis, 0, 1)
	Turn(engineR, x_axis, 0, 1)
end

function script.StopMoving()
	landed = true
	Turn(engineL, z_axis, 0, 1)
	Turn(engineR, z_axis, 0, 1)
	Turn(engineL, y_axis, 0, 1)
	Turn(engineR, y_axis, 0, 1)
	Turn(engineL, x_axis, 0, 1)
	Turn(engineR, x_axis, 0, 1)
end

function script.QueryWeapon(num)
	if num == 1 then
		return missR
	elseif num == 2 then
		return missL
	else
		return gundefs[shot].firepoint
	end
end

function script.AimFromWeapon(num)
	return base
end

function script.AimWeapon(num, heading, pitch)
	return not (GetUnitValue(COB.CRASHING) == 1)
end

function script.FireWeapon(num)
	if num == 1 or num == 2 then
		lastfire = Spring.GetGameFrame()
		hasfired = true
	end
end

function script.Shot(num)
	if num == 3 then
		StartThread(reload, shot)
		shot = (shot + 1)%4
	end
end

local function RestoreAfterDelay()
	Signal(SIG_RESTORE)
	SetSignalMask(SIG_RESTORE)
	
	if getState() then
		Turn(engineL, z_axis, -1.2, 1)
		Turn(engineR, z_axis, 1.2, 1)
		Turn(engineL, y_axis, -1.2, 1)
		Turn(engineR, y_axis, 1.2, 1)
		Turn(engineL, x_axis, 0.6, 1)
		Turn(engineR, x_axis, 0.6, 1)
	end
	
	Sleep(RESTORE_DELAY)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", 1)

	-- Don't ask me why this must be called twice for planes, Spring is crazy
	GG.UpdateUnitAttributes(unitID)
	GG.UpdateUnitAttributes(unitID)
	if getState() then
		script.StartMoving()
	else
		script.StopMoving()
	end
end

function script.BlockShot(num, targetID)
	if GetUnitValue(GG.Script.CRASHING) == 1 or landed then
		return true
	else
		if Spring.GetUnitRulesParam(unitID, "selfMoveSpeedChange") ~= FIRE_SLOWDOWN then
			Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", FIRE_SLOWDOWN)
			--Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", 1/FIRE_SLOWDOWN)
			GG.UpdateUnitAttributes(unitID)
		end
		StartThread(RestoreAfterDelay)
	end
	if num == 3 and targetID then
		return not gundefs[shot].loaded or GG.Script.OverkillPreventionCheck(unitID, targetID, 260.1, 220, 32, 0.2)
	end
	return false -- anything unhandled gets passed through.
end

function OnLoadGame()
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", 1)
	GG.UpdateUnitAttributes(unitID)
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity < 0.25 then
		Explode(base, SFX.NONE)
		Explode(wingL, SFX.NONE)
		Explode(wingR, SFX.NONE)
		return 1
	elseif severity < 0.5 or (Spring.GetUnitMoveTypeData(unitID).aircraftState == "crashing") then
		Explode(base, SFX.NONE)
		Explode(engineL, SFX.SMOKE)
		Explode(engineR, SFX.SMOKE)
		Explode(wingL, SFX.NONE)
		Explode(wingR, SFX.NONE)
		return 1
	elseif severity < 0.75 then
		Explode(engineL, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(engineR, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(wingL, SFX.FALL + SFX.SMOKE)
		Explode(wingR, SFX.FALL + SFX.SMOKE)
		return 2
	else
		Explode(base, SFX.SHATTER)
		Explode(engineL, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(engineR, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(wingL, SFX.SMOKE + SFX.EXPLODE)
		Explode(wingR, SFX.SMOKE + SFX.EXPLODE)
		return 2
	end
end
