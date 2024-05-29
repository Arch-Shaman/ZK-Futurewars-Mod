include "constants.lua"
include "bombers.lua"

--pieces
local base, flare1, flare2, nozzle1, nozzle2, missileleft, missileright, rgun, lgun, rwing, lwing, rjet, ljet, body 
	= piece("base", "flare1", "flare2", "nozzle1", "nozzle2", "missileleft", "missileright", "rgun", "lgun", "rwing", "lwing", "rjet", "ljet", "body")

local smokePiece = {base, rwing, lwing}

--variables
local shotCycle = 0
local flare = {
	[0] = flare1,
	[1] = flare2,
}

local missileflare = {
	[0] = missileleft,
	[1] = missileright,
}


local fast = 3.75
local slow = 0.9
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitMoveTypeData = Spring.GetUnitMoveTypeData
local spSetUnitRulesParam = Spring.SetUnitRulesParam
--local SetAirMoveTypeData = Spring.MoveCtrl.SetAirMoveTypeData
local movectrlGetTag = Spring.MoveCtrl.GetTag
local block = false
local ammoState = 0
local currentLoadout = 0
local distanceSet = false

----------------------------------------------------------

--[[function SprintThread()
	for i=1, SPEEDUP_DURATION do
		EmitSfx(ljet, 1027)
		EmitSfx(rjet, 1027)
		Sleep(33)
	end
	while (Spring.MoveCtrl.GetTag(unitID) ~= nil) do --is true when unit_refuel_pad_handler.lua is MoveCtrl-ing unit, wait until MoveCtrl disabled before restore speed.
		Sleep(33)
	end
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	-- Spring.MoveCtrl.SetAirMoveTypeData(unitID, "maxAcc", 0.5)
	GG.UpdateUnitAttributes(unitID)
	
	Turn(rwing, y_axis, 0, math.rad(100))
	Turn(lwing, y_axis, 0, math.rad(100))
end]]

--function Sprint()
	--Turn(rwing, y_axis, math.rad(65), math.rad(300))
	--Turn(lwing, y_axis, math.rad(-65), math.rad(300))

	--StartThread(SprintThread)
	-- Spring.MoveCtrl.SetAirMoveTypeData(unitID, "maxAcc", 3)
	--GG.UpdateUnitAttributes(unitID)
--end

local function SetDistance()
	if currentLoadout == 1 then
		Spring.SetUnitMaxRange(unitID, 700)
		Spring.MoveCtrl.SetAirMoveTypeData(unitID, {attackSafetyDistance = 100})
	else
		Spring.SetUnitMaxRange(unitID, 180)
		Spring.MoveCtrl.SetAirMoveTypeData(unitID, {attackSafetyDistance = 3500})
	end
	distanceSet = true
end

function OnAmmoChange(newState)
	ammoState = newState
	if newState == 0 then
		spSetUnitRulesParam(unitID, "selfMoveSpeedChange", fast)
		spSetUnitRulesParam(unitID, "selfMaxAccelerationChange", fast)
		GG.UpdateUnitAttributes(unitID)
		GG.UpdateUnitAttributes(unitID)
		if not distanceSet then
			SetDistance()
		end
	elseif newState == 1 then
		spSetUnitRulesParam(unitID, "selfMoveSpeedChange", slow)
		spSetUnitRulesParam(unitID, "selfMaxAccelerationChange", slow)
		GG.UpdateUnitAttributes(unitID)
		GG.UpdateUnitAttributes(unitID)
		SetUnarmedAI()
	end
end

function OnAmmoTypeChange(newAmmo, bypassReload)
	local _, _, inBuild = Spring.GetUnitIsStunned(unitID)
	if bypassReload == nil or not inBuild then
		Reload()
	end
	currentLoadout = newAmmo + 1
	if newAmmo == 0 then
		fast = 3.75
		slow = 1.875
	else
		fast = 2.0
		slow = 1.0
	end
	if Spring.MoveCtrl.GetTag(unitID) == nil then
		SetDistance()
	else
		distanceSet = false
	end
	if ammoState == 0 and bypassReload == nil and not inBuild then
		OnAmmoChange(1)
	end
end

function OnLoadGame()
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	ammoState = Spring.GetUnitRulesParam(unitID, "noammo") or 0
	OnAmmoChange(ammoState)
	GG.UpdateUnitAttributes(unitID)
end


local scriptReload = include("scriptReload.lua")
local SIG_RELOAD = 4
local ammoAmount = 12
local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload

local function RearmingThread()
	SetSignalMask(SIG_RELOAD)
	while ammoAmount <= 11 do
		scriptReload.GunStartReload(ammoAmount)
		SleepAndUpdateReload(ammoAmount, 15)
		ammoAmount = ammoAmount + 1
	end
end

function OnStartReloading()
	StartThread(RearmingThread)
end

function OnAmmoInterrupted()
	Signal(SIG_RELOAD)
end

----------------------------------------------------------

local WING_DISTANCE = 8

local function activate()
	Move(rwing, x_axis, 0, 10)
	Move(lwing, x_axis, 0, 10)
end

local function deactivate()
	Move(rwing, x_axis, WING_DISTANCE, 10)
	Move(lwing, x_axis, -WING_DISTANCE, 10)
	Turn(rwing, y_axis, 0, math.rad(30))
	Turn(lwing, y_axis, 0, math.rad(30))
end

function script.Create()
	scriptReload.SetupScriptReload(12, 0.5)
	Move(rwing, x_axis, WING_DISTANCE)
	Move(lwing, x_axis, -WING_DISTANCE)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	OnAmmoTypeChange(0, true)
	OnAmmoChange(0)
end

function script.StartMoving()
	activate()
end

function script.StopMoving()
	deactivate()
end

function script.QueryWeapon(num) 
	if num == 1 then -- ATA
		return flare[shotCycle]
	elseif num == 2 then -- bomb
		return base
	elseif num == 3 then -- rockets
		return missileflare[0]
	else
		return missileflare[1]
	end
end

function script.AimFromWeapon(num)
	if num == 3 then
		return missileflare[shotCycle]
	end
	return base
end

local SIG_AIM = 2
local SIG_AIM2 = 4
local aimSpeed = math.rad(40000)

function script.AimWeapon(num, heading, pitch)
	if (GetUnitValue(COB.CRASHING) == 1) or ammoState ~= 0 then
		return false
	elseif num == 2 or num == 1 then
		return true
	elseif num == 3 then
		Signal(SIG_AIM)
		SetSignalMask(SIG_AIM)
		Turn(missileflare[0], y_axis, heading, aimSpeed)
		Turn(missileflare[0], x_axis, -pitch, aimSpeed)
		WaitForTurn(missileflare[0], y_axis)
		WaitForTurn(missileflare[0], x_axis)
		return true
	else
		Signal(SIG_AIM2)
		SetSignalMask(SIG_AIM2)
		Turn(missileflare[1], y_axis, heading, aimSpeed)
		Turn(missileflare[1], x_axis, -pitch, aimSpeed)
		WaitForTurn(missileflare[1], y_axis)
		WaitForTurn(missileflare[1], x_axis)
		return true
	end
end

local function reloadThread(num)
	spSetUnitRulesParam(unitID, "noammo", 1)
	OnAmmoChange(1)
	Reload()
end

function script.Shot(num)
	if num ~= 2 then
		EmitSfx(missileflare[shotCycle], UNIT_SFX2)
		shotCycle = 1 - shotCycle
		ammoAmount = ammoAmount - 1
		if ammoAmount > 0 then
			return
		end
	end
	StartThread(reloadThread, num)
end

function script.BlockShot(num, targetID)
	if (GetUnitValue(COB.CRASHING) == 1) or ammoState ~= 0 then
		return true
	end
	if currentLoadout == 1 and num == 2 then
		return true
	elseif currentLoadout == 2 and num ~= 2 then
		return true
	end
	if targetID == nil then
		return false
	end
	if num == 1 then -- ATA overkill prevention
		return GG.OverkillPrevention_CheckBlock(unitID, targetID, 900, 50)
	elseif num == 2 then -- ATG okp
		return GG.OverkillPrevention_CheckBlock(unitID, targetID, 905, 60, 0.25, 0.4) -- (unitID, targetID, damage, timeout, fastMult, radarMult, staticOnly)
	end
	return false
end

function script.Killed(recentDamage, maxHealth)
	local severity = (recentDamage/maxHealth)
	if severity < 0.5 or (Spring.GetUnitMoveTypeData(unitID).aircraftState == "crashing") then
		Explode(base, SFX.NONE)
		Explode(rwing, SFX.NONE)
		Explode(lwing, SFX.NONE)
		Explode(rjet, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE + SFX.SHATTER + SFX.EXPLODE_ON_HIT)
		Explode(ljet, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE + SFX.SHATTER + SFX.EXPLODE_ON_HIT)
		return 1
	else
		Explode(base, SFX.NONE)
		Explode(rwing, SFX.NONE)
		Explode(lwing, SFX.NONE)
		Explode(rjet, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE + SFX.SHATTER + SFX.EXPLODE_ON_HIT)
		Explode(ljet, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE + SFX.SHATTER + SFX.EXPLODE_ON_HIT)
		return 2
	end
end