include "constants.lua"
include "bombers.lua"

--pieces
local base, flare1, flare2, nozzle1, nozzle2, missile, rgun, lgun, rwing, lwing, rjet, ljet, body 
	= piece("base", "flare1", "flare2", "nozzle1", "nozzle2", "missile", "rgun", "lgun", "rwing", "lwing", "rjet", "ljet", "body")

local smokePiece = {base, rwing, lwing}

--variables
local shotCycle = 0
local flare = {
	[0] = flare1,
	[1] = flare2,
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
local currentLoadout = -1
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
	if num == 2 then
		return base
	end
	return flare[shotCycle]
end

function script.AimFromWeapon(num) 
	return base
end

function script.AimWeapon(num, heading, pitch)
	if (GetUnitValue(COB.CRASHING) == 1) or ammoState ~= 0 then
		return false
	else
		return true
	end
end

local function reloadThread(num)
	if num == 1 then
		Sleep(600)
	elseif num == 3 then
		Sleep(1100)
	end
	spSetUnitRulesParam(unitID, "noammo", 1)
	OnAmmoChange(1)
	Reload()
end

function script.Shot(num)
	EmitSfx(missile, UNIT_SFX2)
	if num ~= 2 then
		shotCycle = 1 - shotCycle
	end
	StartThread(reloadThread, num)
end

function script.BlockShot(num, targetID)
	if (GetUnitValue(COB.CRASHING) == 1) or ammoState ~= 0 then
		return true
	end
	if num ~= currentLoadout then
		if currentLoadout == 1 and num == 3 then
			return false
		else
			return true
		end
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