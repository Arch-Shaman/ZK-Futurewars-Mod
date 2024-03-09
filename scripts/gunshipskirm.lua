local scriptReload = include("scriptReload.lua")
local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload

local base = piece 'base'
local lWing = piece 'lWing'
local rWing = piece 'rWing'
local gun1 = piece 'gun1'
local gun2 = piece 'gun2'
local gun3 = piece 'gun3'
local gun4 = piece 'gun4'
local gun5 = piece 'gun5'
local gun6 = piece 'gun6'
local gun7 = piece 'gun7'
local gun8 = piece 'gun8'
local gun9 = piece 'gun9'
local gun10 = piece 'gun10'
local gun11 = piece 'gun11'
local gun12 = piece 'gun12'
local gun13 = piece 'gun13'
local gun14 = piece 'gun14'
local gun15 = piece 'gun15'
local gun16 = piece 'gun16'
local gun17 = piece 'gun17'
local gun18 = piece 'gun18'
local gun19 = piece 'gun19'
local gun20 = piece 'gun20'
-- unused pieces: muzzle[12], thrust[12]

local smokePiece = {base}

include "constants.lua"

local upright = math.rad(90)

local gun = {
	[0] = {firepoint = gun1, loaded = true, bottom = false},
	[1] = {firepoint = gun2, loaded = true, bottom = false},
	[2] = {firepoint = gun3, loaded = true, bottom = true},
	[3] = {firepoint = gun4, loaded = true, bottom = true},
	[4] = {firepoint = gun5, loaded = true, bottom = false},
	[5] = {firepoint = gun6, loaded = true, bottom = false},
	[6] = {firepoint = gun7, loaded = true, bottom = true},
	[7] = {firepoint = gun8, loaded = true, bottom = true},
	[8] = {firepoint = gun9, loaded = true, bottom = false},
	[9] = {firepoint = gun10, loaded = true, bottom = false},
	[10] = {firepoint = gun11, loaded = true, bottom = true},
	[11] = {firepoint = gun12, loaded = true, bottom = true},
	[12] = {firepoint = gun13, loaded = true, bottom = false},
	[13] = {firepoint = gun14, loaded = true, bottom = false},
	[14] = {firepoint = gun15, loaded = true, bottom = true},
	[15] = {firepoint = gun16, loaded = true, bottom = true},
	[16] = {firepoint = gun17, loaded = true, bottom = false},
	[17] = {firepoint = gun18, loaded = true, bottom = false},
	[18] = {firepoint = gun19, loaded = true, bottom = true},
	[19] = {firepoint = gun20, loaded = true, bottom = true},
}

local loaded = 20
local shot = 0

local reloadtime = 12
local gameSpeed = Game.gameSpeed

local function reload(num)
	Turn(gun[num].firepoint, x_axis, 0)
	scriptReload.GunStartReload(num)
	gun[num].loaded = false

	SleepAndUpdateReload(num, reloadtime * gameSpeed)
	if scriptReload.GunLoaded(num) then
		shot = 0
	end
	gun[num].loaded = true
	Show(gun[num].firepoint)
	loaded = loaded + 1
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	scriptReload.SetupScriptReload(20, reloadtime * gameSpeed)
end

function script.Activate()
	Turn(lWing,z_axis, math.rad(-25),0.7)
	Turn(rWing,z_axis, math.rad(25),0.7)
end

function script.Deactivate()
	Turn(lWing,z_axis, math.rad(0),1)
	Turn(rWing,z_axis, math.rad(0),1)
end

function script.QueryWeapon(num)
	return gun[shot].firepoint
end

function script.AimFromWeapon(num)
	return gun[shot].firepoint
end

function script.AimWeapon(num, heading, pitch)
	return true
end

function script.BlockShot(num, targetID)
	if not gun[shot].loaded then
		return true
	else
		--Spring.Echo("Shot: " .. shot, gun[shot].bottom)
		return (num == 2 and gun[shot].bottom) or (num == 1 and not gun[shot].bottom)
	end
end

function script.FireWeapon(num)
	--Spring.Echo("FireWeapon: " .. num, gun[shot].bottom)
	--Turn(gun[shot].firepoint, x_axis, -upright) -- hax
	EmitSfx(gun[shot].firepoint, GG.Script.UNIT_SFX1)
	Hide(gun[shot].firepoint)
	StartThread(reload, shot)
	shot = (shot + 1) %20
	loaded = loaded - 1
end

function script.Shot(num)
end


function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= 0.25 then
		Explode(base, SFX.NONE)
		Explode(lWing, SFX.NONE)
		Explode(rWing, SFX.NONE)
		return 1
	elseif severity <= 0.5 or ((Spring.GetUnitMoveTypeData(unitID).aircraftState or "") == "crashing") then
		Explode(base, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE_ON_HIT)
		Explode(lWing, SFX.FALL)
		Explode(rWing, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE_ON_HIT)
		return 1
	elseif severity <= 0.75 then
		Explode(base, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE_ON_HIT)
		Explode(lWing, SFX.FALL)
		Explode(rWing, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE_ON_HIT)
		return 2
	else
		Explode(base, SFX.SHATTER)
		Explode(lWing, SFX.SHATTER)
		Explode(rWing, SFX.SHATTER)
		return 2
	end
end
