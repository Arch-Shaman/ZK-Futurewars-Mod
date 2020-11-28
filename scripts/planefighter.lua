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



local fast = 4
local slow = 0.55
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitMoveTypeData = Spring.GetUnitMoveTypeData
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local SetAirMoveTypeData = Spring.MoveCtrl.SetAirMoveTypeData
local movectrlGetTag = Spring.MoveCtrl.GetTag
local block = false

----------------------------------------------------------

VFS.Include("LuaRules/Configs/customcmds.h.lua")

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

function SpeedThread()
	spSetUnitRulesParam(unitID, "selfMoveSpeedChange", fast)
	SetAirMoveTypeData(unitID, "maxAcc", 1)
	GG.UpdateUnitAttributes(unitID)
	local ammo = 0
	local reloading = false
	while spGetUnitMoveTypeData(unitID).aircraftState ~= "crashing" do
		ammo = spGetUnitRulesParam(unitID,"noammo") or 0
		if ammo == 0 and reloading then -- being reloaded.
			while movectrlGetTag(unitID) ~= nil do
				Sleep(33)
			end
			spSetUnitRulesParam(unitID, "selfMoveSpeedChange", fast)
			SetAirMoveTypeData(unitID, "maxAcc", 1)
			Sleep(330)
			reloading = false
			block = false
		elseif ammo == 1 and not reloading then
			spSetUnitRulesParam(unitID, "selfMoveSpeedChange", slow)
			SetAirMoveTypeData(unitID, "maxAcc", slow/2)
			GG.UpdateUnitAttributes(unitID)
			reloading = true
		else
			Sleep(66)
		end
	end
end
		

function OnLoadGame()
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
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
	StartThread(SpeedThread)
end

function script.StartMoving()
	activate()
end

function script.StopMoving()
	deactivate()
end

function script.QueryWeapon(num) 
	return flare[shotCycle]
end

function script.AimFromWeapon(num) 
	return base
end

function script.AimWeapon(num, heading, pitch)
	if (GetUnitValue(COB.CRASHING) == 1)  or spGetUnitRulesParam(unitID, "noammo") == 1 then
		return false
	else
		return true
	end
end

function script.FireWeapon(num)
	EmitSfx(missile, UNIT_SFX2)
	shotCycle = 1 - shotCycle
	if num ~= 3 then
		spSetUnitRulesParam(unitID,"noammo",1)
	end
end

function script.BlockShot(num, targetID)
	if (GetUnitValue(COB.CRASHING) == 1) or spGetUnitRulesParam(unitID, "noammo") == 1 or movectrlGetTag(unitID) ~= nil or block then
		return true
	end
	if num == 1 then -- ATA overkill prevention
		return GG.OverkillPrevention_CheckBlock(unitID, targetID, 133, 35)
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