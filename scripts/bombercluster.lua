local base = piece 'base'
local fuselage = piece 'fuselage'
local wingl1 = piece 'wingl1'
local wingr1 = piece 'wingr1'
local wingl2 = piece 'wingl2'
local wingr2 = piece 'wingr2'
local engines = piece 'engines'
local fins = piece 'fins'
local rflap = piece 'rflap'
local lflap = piece 'lflap'
local predrop = piece 'predrop'
local drop = piece 'drop'
local thrustl = piece 'thrustl'
local thrustr = piece 'thrustr'
local wingtipl = piece 'wingtipl'
local wingtipr = piece 'wingtipr'
local xp,zp = piece("x","z")

local smokePiece = {body, jet}
local currentAmmo = 0

include "constants.lua"
include "bombers.lua"
include "fixedwingTakeOff.lua"

local SIG_TAKEOFF = 1
local takeoffHeight = UnitDefNames["bomberprec"].wantedHeight
local ammoState = 0

local function Lights()
	while select(5, Spring.GetUnitHealth(unitID)) < 1 do
		Sleep(400)
	end
	while true do
		EmitSfx(wingtipr, 1024)
		EmitSfx(wingtipl, 1025)
		Sleep(2000)
	end
end

local function DeathThread()
	local wd
	if currentAmmo == 0 then
		wd = WeaponDefNames["bomberprec_bombsabot"]
	elseif currentAmmo == 1 then
		wd = WeaponDefNames["bomberprec_torpedo"]
	else
		wd = WeaponDefNames["bomberprec_armorpiercing"]
	end
	local count = wd.salvoSize
	local bombsPer = wd.projectiles
	local weaponID = wd.id
	local delay = math.floor(wd.salvoDelay * 1000)
	local x, y, z = Spring.GetUnitPosition(unitID)
	local vx, vy, vz = Spring.GetUnitVelocity(unitID)
	local params = {
			pos = {x, y + 5, z},
			speed = {vx, vy, vz},
			gravity = -1,
			team = Spring.GetGaiaTeamID(),
			owner = unitID,
		}
	local baseX, baseZ
	for i = 1, count do
		baseX, baseZ = params.speed[1], params.speed[3]
		for i = 1, bombsPer do
			Spring.SpawnProjectile(weaponID, params)
			params.speed[1] = baseX + (math.random(-1,1) * math.random()) -- emulate spread
			params.speed[3] = baseZ + (math.random(-1,1) * math.random())
		end
		Sleep(delay)
		if Spring.ValidUnitID(unitID) then
			params.pos[1], params.pos[2], params.pos[3] = Spring.GetUnitPosition(unitID)
			params.pos[2] = params.pos[2] + 5
			params.speed[1], params.speed[2], params.speed[3] = Spring.GetUnitVelocity(unitID)
		else
			break
		end
	end
end

function OnStartingCrash()
	if ammoState == 0 then
		StartThread(DeathThread)
	end
end

function OnAmmoChange(newState)
	ammoState = newState
	if newState == 1 then
		SetUnarmedAI()
	end
	--[[if newState == 0 then
		spSetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
		spSetUnitRulesParam(unitID, "selfMaxAccelerationChange", 1)
		GG.UpdateUnitAttributes(unitID)
		GG.UpdateUnitAttributes(unitID)
	elseif newState == 1 then
		spSetUnitRulesParam(unitID, "selfMoveSpeedChange", 1.15)
		spSetUnitRulesParam(unitID, "selfMaxAccelerationChange", 1.15)
		GG.UpdateUnitAttributes(unitID)
		GG.UpdateUnitAttributes(unitID)
	end]]
end

function script.StopMoving()
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
end

function script.Create()
	SetInitialBomberSettings()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
	StartThread(Lights)
	Move(drop, z_axis, 60)
end

function script.AimWeapon(num)
	return true
end

function script.QueryWeapon(num)
	return drop
end

function script.BlockShot(num)
	return RearmBlockShot() or (num - 1) ~= currentAmmo
end

function script.FireWeapon(num)
	Sleep(400)
	Reload()
	SetUnarmedAI()
	OnAmmoChange(1)
end

function OnAmmoTypeChange(newAmmo)
	if newAmmo ~= currentAmmo then
		OnAmmoChange(1)
		local _, _, inBuild = Spring.GetUnitIsStunned(unitID)
		if not inBuild then
			Reload()
			SetUnarmedAI()
		end
		currentAmmo = newAmmo
	end
end


function script.Killed(recentDamage, maxHealth)
	Signal(SIG_TAKEOFF)
	local severity = recentDamage/maxHealth
	if severity <= 0.25 then
		Explode(fuselage, SFX.NONE)
		Explode(engines, SFX.NONE)
		Explode(wingl1, SFX.NONE)
		Explode(wingr2, SFX.NONE)
		return 1
	elseif severity <= 0.50 or (Spring.GetUnitMoveTypeData(unitID).aircraftState == "crashing") then
		Explode(fuselage, SFX.NONE)
		Explode(engines, SFX.NONE)
		Explode(wingl2, SFX.NONE)
		Explode(wingr1, SFX.NONE)
		return 1
	elseif severity <= 1 then
		Explode(fuselage, SFX.NONE)
		Explode(engines, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode(wingl1, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode(wingr2, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		return 2
	else
		Explode(fuselage, SFX.NONE)
		Explode(engines, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode(wingl1, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode(wingl2, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		return 2
	end
end