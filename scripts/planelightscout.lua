include 'constants.lua'
include "fixedwingTakeOff.lua"
include 'bombers.lua'

--------------------------------------------------------------------
-- constants/vars
--------------------------------------------------------------------
local fuselage, KRisaravinglunatic, wingl, wingr = piece("fuselage", "KRisaravinglunatic", "wingl", "wingr")
local wingtipl, wingtipr = piece("wingtipl", "wingtipr")
-- unused pieces: canardl, canardr, wingtipl, wingtipr, enginer, enginel, exhaustl, exhaustr
local smokePiece = {KRisaravinglunatic}

local SIG_TAKEOFF = 2
local dgunningg = false
local takeoffHeight = UnitDefNames["planelightscout"].wantedHeight
local weaponDef = UnitDefNames["planelightscout"].weapons[3].weaponDef
--------------------------------------------------------------------
-- functions
--------------------------------------------------------------------
local costToFire = tonumber(WeaponDefs[weaponDef].customParams.batterydrain) or 1

function script.StopMoving()
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
end

function script.Create()
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

function script.QueryWeapon(num)
	return num == 1 and wingtipl or (num == 2 and wingtipr) or KRisaravinglunatic
end

function script.AimWeapon()
	return true
end

local function DgunRotation()
	--local rotation = math.rad(45)
	--local cycle = true
	--local normal = math.rad(90)
	Turn(KRisaravinglunatic, x_axis, math.rad(90))
	Spring.MoveCtrl.SetAirMoveTypeData(unitID, {attackSafetyDistance = 1800})
	while dgunningg do
		--[[if cycle then
			Turn(KRisaravinglunatic, x_axis, normal, math.rad(180))
			Turn(KRisaravinglunatic, z_axis, rotation, math.rad(90))
		else
			Turn(KRisaravinglunatic, x_axis, -normal, -math.rad(180))
			Turn(KRisaravinglunatic, z_axis, -rotation, -math.rad(90))
		end
		WaitForTurn(KRisaravinglunatic, x_axis)
		cycle = not cycle]] -- Removed: Does not work.
		Sleep(33)
	end
	Turn(KRisaravinglunatic, y_axis, 0)
	Spring.MoveCtrl.SetAirMoveTypeData(unitID, {attackSafetyDistance = 150})
	--Turn(KRisaravinglunatic, x_axis, 0)
	--Turn(KRisaravinglunatic, z_axis, 0)
end

local function Dgun()
	dgunningg = true
	local sound_index = 0
	local stunned_or_inbuild = Spring.GetUnitIsStunned(unitID) or (Spring.GetUnitRulesParam(unitID,"disarmed") == 1)
	local hasCharge = true
	--local projectileAttributes = {pos = {0, 0, 0}, speed = {0,-10,0}, gravity = -1, owner = unitID, team = Spring.GetUnitTeam(unitID), maxRange = 1000, ttl = 3}
	local actualAttributes = {pos = {0, 0, 0}, speed = {0, -10, 0}, gravity = -2, owner = unitID, team = Spring.GetUnitTeam(unitID)}
	--projectileAttributes["end"] = {0, 0, 0}  -- Seriously, who the hell thought this was a good idea to make a table entry a reserved keyword?! "endPos" would be better!
	--StartThread(DgunRotation)
	local speed = 2.5 * 15
	local actualDef = WeaponDefNames["planelightscout_laser_actual"].id
	while hasCharge do
		if not stunned_or_inbuild then -- TODO: Figure out how to make this spray better.
			_, _, _, actualAttributes.pos[1], actualAttributes.pos[2], actualAttributes.pos[3] = Spring.GetUnitPosition(unitID, true)
			actualAttributes.pos[2] = actualAttributes.pos[2] - 5 -- spawn below the plane.
			for i = 1, 3 do
				actualAttributes.speed[2] = 0 - math.random(10, 100)
				actualAttributes.speed[1] = math.random(-1, 1) * math.random() * speed
				actualAttributes.speed[3] = math.random(-1, 1) * math.random() * speed
				Spring.SpawnProjectile(actualDef, actualAttributes)
			end
			GG.BatteryManagement.UseCharge(unitID, costToFire)
			if sound_index == 0 then
				Spring.PlaySoundFile("sounds/weapon/LightningBolt.wav", 4.4, actualAttributes.pos[1], actualAttributes.pos[2], actualAttributes.pos[3], 0, 0, 0, "battle")
			end
			sound_index = sound_index + 1
			if sound_index >= 6 then
				sound_index = 0
			end
		end
		stunned_or_inbuild = Spring.GetUnitIsStunned(unitID) or (Spring.GetUnitRulesParam(unitID,"disarmed") == 1)
		Sleep(33)
		hasCharge = GG.BatteryManagement.CanUseCharge(unitID, costToFire)
	end
	dgunningg = false
	Spring.SetUnitRulesParam(unitID, "noammo", 1)
end

function script.Deactivate()
	Spring.SetUnitShieldState(unitID, -1, false)
end

function script.Activate()
	Spring.SetUnitShieldState(unitID, -1, true)
end

function script.BlockShot(num)
	if num == 3 then
		return true
	end
	local canFire = GG.BatteryManagement.CanFire(unitID, num)
	if not canFire then
		Spring.SetUnitRulesParam(unitID, "noammo", 1)
		Reload()
	end
	return dgunningg or not GG.BatteryManagement.CanFire(unitID, num)
end

function UseDgun()
	if GG.BatteryManagement.CanUseCharge(unitID, costToFire) then
		StartThread(Dgun)
	end
end

function script.FireWeapon(num)
	if num == 3 then
		return
	end
	--if num == 1 then
		--EmitSfx(wingtipl, 1024)
	--else
		--EmitSfx(wingtipr, 1024)
	--end
	GG.BatteryManagement.WeaponFired(unitID, num)
	if not GG.BatteryManagement.CanFire(unitID, num) then
		Spring.SetUnitRulesParam(unitID, "noammo", 1)
		Reload()
	end
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity < 0.5 or (Spring.GetUnitMoveTypeData(unitID).aircraftState == "crashing") then
		Explode(wingr, SFX.EXPLODE)
		Explode(wingl, SFX.EXPLODE)
		Explode(fuselage, SFX.FALL)
		return 1
	else
		Explode(wingr, SFX.SHATTER)
		Explode(wingl, SFX.SHATTER)
		Explode(fuselage, SFX.SHATTER + SFX.SMOKE)
		return 2
	end
end
