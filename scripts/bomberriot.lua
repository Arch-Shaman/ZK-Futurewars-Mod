local base = piece 'base'
local body = piece 'body'
local jet = piece 'jet'
local drop = piece 'drop'
local wingtipl = piece 'wingtipl'
local wingtipr = piece 'wingtipr'

local smokePiece = {body, jet}

include "constants.lua"
include "bombers.lua"
include "fixedwingTakeOff.lua"

local SIG_TAKEOFF = 1
local takeoffHeight = UnitDefNames["bomberriot"].wantedHeight
local ammoState = 0
local currentAmmo = 0
local isCrashing = false


local function Lights()
	while select(5, Spring.GetUnitHealth(unitID)) < 1 do
		Sleep(400)
	end
	while true do
		EmitSfx(wingtipl, 1025)
		EmitSfx(wingtipr, 1026)
		Sleep(2000)
	end
end

local function DeathThread()
	isCrashing = true
	local wd
	if currentAmmo == 0 then
		wd = WeaponDefNames["bomberriot_napalm"]
	elseif currentAmmo == 1 then
		wd = WeaponDefNames["bomberriot_black_hole"]
	else
		wd = WeaponDefNames["bomberriot_seismic"]
	end
	local count = wd.salvoSize
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
	for i = 1, count do
		Spring.SpawnProjectile(weaponID, params)
		Sleep(delay)
		if Spring.ValidUnitID(unitID) then
			params.pos[1], params.pos[2], params.pos[3] = Spring.GetUnitPosition(unitID)
			params.pos[2] = params.pos[2] + 5
			params.speed[1], params.speed[2], params.speed[3] = Spring.GetUnitVelocity(unitID)
		else
			break
		end
	end
	ammoState = 1
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
end

function OnAmmoTypeChange(newAmmo)
	if newAmmo ~= currentAmmo then
		local _, _, inBuild = Spring.GetUnitIsStunned(unitID)
		if not inBuild then
			OnAmmoChange(1)
			Reload()
		end
		currentAmmo = newAmmo
	end
end

function script.StopMoving()
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
end

function script.Create()
	SetInitialBomberSettings()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
	--StartThread(Lights)
end

function script.AimWeapon(num)
	return true
end

function script.QueryWeapon(num)
	return drop
end

function script.Shot(num)
	Move(drop, x_axis, math.random()*50 - 25)
end

function script.BlockShot(num)
	return isCrashing or (num - 1) ~= currentAmmo
end

function script.FireWeapon(num)
	Move(drop, x_axis, math.random()*50 - 25)
	SetUnarmedAI()
	OnAmmoChange(1)
	Sleep(400)
	Move(drop, x_axis, 0)
	Reload()
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(body, SFX.NONE)
		Explode(jet, SFX.NONE)
		return 1
	elseif severity <= .50 or (Spring.GetUnitMoveTypeData(unitID).aircraftState == "crashing") then
		Explode(body, SFX.NONE)
		Explode(jet, SFX.SHATTER)
		return 1
	elseif severity <= .75 then
		Explode(body, SFX.SHATTER)
		Explode(jet, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	else
		Explode(body, SFX.SHATTER)
		Explode(jet, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	end
end
