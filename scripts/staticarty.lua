include "constants.lua"
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local scriptReload = include("scriptReload.lua")

local base = piece 'base'
local turret = piece 'turret'
local sleeve = piece 'sleeve'
local barrel1 = piece 'barrel1'
local flare1 = piece 'flare1'
local barrel2 = piece 'barrel2'
local flare2 = piece 'flare2'
local barrel3 = piece 'barrel3'
local flare3 = piece 'flare3'
local gun = {
	[1] = {firepoint = barrel1, loaded = true, flare = flare1},
	[2] = {firepoint = barrel2, loaded = true, flare = flare2},
	[3] = {firepoint = barrel3, loaded = true, flare = flare3},
}

local gun_1 = 1
local gameSpeed = Game.gameSpeed
local RELOAD_TIME = 10 * gameSpeed
local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload

-- Signal definitions
local SIG_AIM = 2

local RECOIL_DISTANCE = -5
local RECOIL_RESTORE_SPEED = -(RECOIL_DISTANCE)/7.3 -- should be setup just before it fires
local aimspeed = math.rad(20)

local smokePiece = {base, turret}

local function reload(num)
	scriptReload.GunStartReload(num)
	gun[num].loaded = false
	SleepAndUpdateReload(num, RELOAD_TIME)
	gun[num].loaded = true
	if scriptReload.GunLoaded(num) then
		shot = 0
	end
end

local function RangeThread()
	local baseRange = WeaponDefs[UnitDefs[Spring.GetUnitDefID(unitID)].weapons[1].weaponDef].range
	local baseSpeedLow = WeaponDefs[UnitDefs[Spring.GetUnitDefID(unitID)].weapons[2].weaponDef].projectilespeed
	local baseSpeedHigh = WeaponDefs[UnitDefs[Spring.GetUnitDefID(unitID)].weapons[1].weaponDef].projectilespeed
	local overdrive, range, speed
	while true do
		overdrive = spGetUnitRulesParam(unitID,"superweapon_mult") or 0
		range = math.max(baseRange * overdrive, 1000)
		Spring.SetUnitWeaponState(unitID, 1, "range", range)
		Spring.SetUnitWeaponState(unitID, 2, "range", range)
		Spring.SetUnitMaxRange(unitID, range)
		Sleep(33)
		speed = range / baseRange
		Spring.SetUnitWeaponState(unitID, 1, "projectileSpeed", speed * baseSpeedHigh) -- THIS DOES WEIRD THINGS!
		--Spring.Echo("Speed: " .. math.ceil(speed * baseSpeedLow))
		Spring.SetUnitWeaponState(unitID, 2, "projectileSpeed", speed * baseSpeedLow)
		Sleep(297)
	end
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	scriptReload.SetupScriptReload(3, RELOAD_TIME)
	StartThread(RangeThread)
end

local function IsRightWeapon(num)
	local traj = Spring.GetUnitStates(unitID)["trajectory"] or false
	if traj and num == 2 then -- 2 = low traj weapon
		return false
	elseif not traj and num == 1 then -- 1 = high traj weapon
		return false
	end
	return true
end

function script.AimWeapon(num, heading, pitch)
	if not IsRightWeapon(num) or (spGetUnitRulesParam(unitID, "lowpower") == 1) then
		return
	end
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(turret, y_axis, heading, aimspeed)
	Turn(sleeve, x_axis, -pitch, aimspeed * 0.8)
	WaitForTurn(turret, y_axis)
	WaitForTurn(sleeve, x_axis)
	return (spGetUnitRulesParam(unitID, "lowpower") == 0)	--checks for sufficient energy in grid
end

function script.BlockShot(num, targetID)
	return not gun[gun_1].loaded or not IsRightWeapon(num)
end

function script.QueryWeapon(num)
	return gun[gun_1].flare
end

local function RecoilThread(num)
	Move(gun[num].firepoint, z_axis, RECOIL_DISTANCE, 30)
	Sleep(166)
	Move(gun[num].firepoint, z_axis, 0, RECOIL_RESTORE_SPEED)
end


function script.Shot(num)
	StartThread(reload, gun_1)
	EmitSfx(gun[gun_1].flare, 1024)
	StartThread(RecoilThread, gun_1)
	gun_1 = gun_1%3 + 1
end

function script.AimFromWeapon(num)
	return sleeve
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(base, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(barrel1, SFX.NONE)
		Explode(barrel2, SFX.NONE)
		Explode(barrel3, SFX.NONE)
		return 1
	elseif severity <= .50 then
		Explode(base, SFX.SHATTER)
		Explode(turret, SFX.FALL + SFX.SMOKE)
		Explode(barrel1, SFX.NONE)
		Explode(barrel2, SFX.NONE)
		Explode(barrel3, SFX.NONE)
		return 1
	elseif severity <= .99 then
		Explode(base, SFX.SHATTER)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(barrel1, SFX.FALL + SFX.SMOKE)
		Explode(barrel2, SFX.FALL + SFX.SMOKE)
		Explode(barrel3, SFX.FALL + SFX.SMOKE)
		return 2
	else
		Explode(base, SFX.SHATTER)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(barrel1, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode(barrel2, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode(barrel3, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		return 2
	end
end
