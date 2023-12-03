include "constants.lua"
include "fakeUpright.lua"
include "bombers.lua"
include "fixedwingTakeOff.lua"

local base, Lwing, LwingTip, Rwing, RwingTip, jet1, jet2,xp,zp,preDrop, drop, LBSpike, LFSpike,RBSpike, RFSpike = piece("Base", "LWing", "LWingTip", "RWing", "RWingTip", "Jet1", "Jet2","x","z","PreDrop", "Drop", "LBSpike", "LFSpike","RBSpike", "RFSpike")
local smokePiece = {base, jet1, jet2}

local doingRun = false
local preDropMoved = false
local sound_index = 0
local ammoState = 1
local currentAmmo = 0

local SIG_TAKEOFF = 1
local takeoffHeight = UnitDefNames["bomberdisarm"].wantedHeight
local isCrashing = false

local function DeathThread()
	if ammoState > 0 then
		return
	end
	local wd
	if currentAmmo == 0 then
		wd = WeaponDefNames["bomberdisarm_slow_bomb"]
	elseif currentAmmo == 1 then
		wd = WeaponDefNames["bomberdisarm_mine"]
	else
		wd = WeaponDefNames["bomberdisarm_armbomblightning"]
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

function OnStartingCrash()
	if ammoState == 0 then
		StartThread(DeathThread)
	end
end


function script.Create()
	SetInitialBomberSettings()
	Hide(preDrop)
	Hide(drop)
	
	GG.FakeUpright.FakeUprightInit(xp, zp, drop)
	Turn(Lwing, z_axis, math.rad(90))
	Turn(Rwing, z_axis, math.rad(-90))
	Turn(LwingTip, z_axis, math.rad(-165))
	Turn(RwingTip, z_axis, math.rad(165))
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

function script.Activate()
	Turn(Lwing, z_axis, math.rad(90), 2)
	Turn(Rwing, z_axis, math.rad(-90), 2)
	Turn(LwingTip, z_axis, math.rad(-165), 2) --160
	Turn(RwingTip, z_axis, math.rad(165), 2) -- -160
end

function script.Deactivate()
	Turn(Lwing, z_axis, math.rad(10), 2)
	Turn(Rwing, z_axis, math.rad(-10), 2)
	Turn(LwingTip, z_axis, math.rad(-30), 2) -- -30
	Turn(RwingTip, z_axis, math.rad(30), 2) --30
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
end

function script.FireWeapon(num)
	OnAmmoChange(1)
	if num == 1 then
		Sleep(1600)
	elseif num == 2 then
		Sleep(300)
	end
	Reload()
	SetUnarmedAI()
end

function StartRun()
	script.FireWeapon(true)
end

function script.QueryWeapon()
	return drop
end

function script.AimFromWeapon()
	return drop
end

function script.AimWeapon(num, heading, pitch)
	return true
end

function script.BlockShot(num)
	return isCrashing or (num - 1) ~= currentAmmo
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity < 0.5 or (Spring.GetUnitMoveTypeData(unitID).aircraftState == "crashing") then
		Explode(base, SFX.NONE)
		Explode(jet1, SFX.SMOKE)
		Explode(jet2, SFX.SMOKE)
		Explode(Lwing, SFX.NONE)
		Explode(Rwing, SFX.NONE)
		return 1
	elseif severity < 0.75 then
		Explode(base, SFX.SHATTER)
		Explode(jet1, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(jet2, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(Lwing, SFX.FALL + SFX.SMOKE)
		Explode(Rwing, SFX.FALL + SFX.SMOKE)
		return 2
	else
		Explode(base, SFX.SHATTER)
		Explode(jet1, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(jet2, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(Lwing, SFX.SMOKE + SFX.EXPLODE)
		Explode(Rwing, SFX.SMOKE + SFX.EXPLODE)
		Explode(LwingTip, SFX.SMOKE + SFX.EXPLODE)
		Explode(RwingTip, SFX.SMOKE + SFX.EXPLODE)
		return 2
	end
end
