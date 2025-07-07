include "constants.lua"
local base = piece 'base'
local arm1 = piece 'arm1'
local arm2 = piece 'arm2'
local turret = piece 'turret'
local firepoint = piece 'firepoint'
local spGetUnitBasePosition = Spring.GetUnitBasePosition
local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitPosition = Spring.GetUnitPosition
local spPlaySoundFile = Spring.PlaySoundFile
local waterFire = false
local smokePiece = {base}
local torpsRemaining = 5
local torpsMax = 5
local aimSpeed = math.rad(120)
local init = false

-- Signal definitions
local SIG_AIM = 2

local gameSpeed = Game.gameSpeed
local scriptReload = include("scriptReload.lua")
local RELOAD_TIME = tonumber(WeaponDefs[UnitDefs[unitDefID].weapons[1].weaponDef].customParams.script_reload) * gameSpeed
local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload

local function Bob(rot)
	while true do
		Turn(base, x_axis, rot + math.rad(10)*math.random() - math.rad(5), math.rad(1) + math.rad(1)*math.random())
		Turn(base, z_axis, math.rad(10)*math.random() - math.rad(5), math.rad(1) + math.rad(1)*math.random())
		Move(base, y_axis, 48 + math.rad(math.random(0,2)), math.rad(math.random(1,2)))
		Sleep(2000)
		Turn(base, x_axis, rot + math.rad(10)*math.random() - math.rad(5), math.rad(1) + math.rad(1)*math.random())
		Turn(base, z_axis, math.rad(10)*math.random() - math.rad(5), math.rad(1) + math.rad(1)*math.random())
		Move(base, y_axis, 48 + math.rad(math.random(-2,0)), math.rad(math.random(1,2)))
		Sleep(1000)
	end
end

local function FireAndReload()
	scriptReload.GunStartReload(5 - torpsRemaining)
	torpsRemaining = torpsRemaining - 1
	SleepAndUpdateReload(num, 6.5 * gameSpeed)
	torpsRemaining = torpsRemaining + 1
end

function script.Create()
	scriptReload.SetupScriptReload(3, RELOAD_TIME)
	local x, _, z = spGetUnitBasePosition(unitID)
	local y = spGetGroundHeight(x, z)
	Turn(arm1, z_axis, math.rad(-70), math.rad(80))
	Turn(arm2, z_axis, math.rad(70), math.rad(80))
	Move(base, y_axis, 20, 25)
	if y > 0 then
		Turn(arm1, z_axis, math.rad(-70), math.rad(80))
		Turn(arm2, z_axis, math.rad(70), math.rad(80))
		Move(base, y_axis, 20, 25)
	else
		waterFire = true
		--StartThread(Bob, math.rad(180))
		--Turn(base, x_axis, math.rad(180))
		--Move(base, y_axis, 48)
		--Turn(arm1, x_axis, math.rad(180))
		--Turn(arm2, x_axis, math.rad(180))
		--Turn(turret, x_axis, 0)
	end
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	init = true
end

function script.AimWeapon(num, heading, pitch)
	if num == 2 and waterFire then return false end -- above water "torpedo mortar"
	if num == 1 and not waterFire then return false end -- underwater "torpedo launcher"
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	if num == 1 then
		Turn(turret, x_axis, -pitch, aimSpeed)
	end
	Turn(turret, y_axis, heading, aimSpeed)
	WaitForTurn(turret, y_axis)
	WaitForTurn(turret, x_axis)
	return true
end

function script.FireWeapon(num)
	StartThread(FireAndReload)
end

function script.BlockShot(num, targetID)
	if not init then return true end
	if num == 2 and waterFire then return true end
	if num == 1 and not waterFire then return true end
	if torpsRemaining == 0 then return true end
	return GG.Script.OverkillPreventionCheck(unitID, targetID, 125, 550, 90, 1.3, 100, 1.5)
end

function script.AimFromWeapon(num)
	if waterFire then
		return base
	else
		return turret
	end
end

function script.QueryWeapon(num)
	return firepoint
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(base, SFX.NONE)
		Explode(firepoint, SFX.NONE)
		Explode(arm1, SFX.NONE)
		Explode(turret, SFX.NONE)
		return 1
	elseif severity <= .50 then
		Explode(base, SFX.NONE)
		Explode(firepoint, SFX.FALL)
		Explode(arm2, SFX.SHATTER)
		Explode(turret, SFX.FALL)
		return 1
	elseif severity <= .99 then
		Explode(base, SFX.NONE)
		Explode(firepoint, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(arm1, SFX.SHATTER)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	else
		Explode(base, SFX.NONE)
		Explode(firepoint, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(arm2, SFX.SHATTER + SFX.EXPLODE)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	end
end
