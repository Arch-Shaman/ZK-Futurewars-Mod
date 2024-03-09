include "constants.lua"
include "pieceControl.lua"

local scriptReload = include("scriptReload.lua")
----------------------------------------------------------------------------------------------
-- Model Pieces

local basebottom, basemid, basetop, holder, housing, spindle, aim = piece('basebottom', 'basemid', 'basetop', 'holder', 'housing', 'spindle', 'aim')
local flares = {piece('flare1', 'flare2', 'flare3')}

local smokePiece = {basebottom, basemid, basetop}

local gameSpeed = Game.gameSpeed
local RELOAD_TIME = tonumber(WeaponDefs[UnitDefs[unitDefID].weapons[1].weaponDef].customParams.script_reload) * gameSpeed
local ammoMax = tonumber(WeaponDefs[UnitDefs[unitDefID].weapons[1].weaponDef].customParams.script_burst)
local shot = 0
local gun = {}

for i = 0, ammoMax - 1 do
	gun[i] = {firepoint = flares[(i + 1)%3 + 1 ], loaded = true}
end

----------------------------------------------------------------------------------------------
-- Local Constants

local BASETOP_TURN_SPEED = math.rad(200)
local BASEMID_TURN_SPEED = math.rad(230)
local HOUSING_TURN_SPEED = math.rad(200)
local SPINDLE_TURN_SPEED = math.rad(600)

local firing = false
local index = 2

local stuns = {false, false, false}
local disarmed = false

----------------------------------------------------------------------------------------------
-- Signal Definitions

local SIG_AIM = 2

----------------------------------------------------------------------------------------------
-- Localising Functions

local spGetUnitRulesParam = Spring.GetUnitRulesParam
local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload


----------------------------------------------------------------------------------------------
-- Local Animation Functions

local function RestoreAfterDelay()
	Sleep(5000)
	Turn(housing, x_axis, 0, math.rad(10))
	Turn(basetop, y_axis, 0, math.rad(10))
end

----------------------------------------------------------------------------------------------
-- Script Functions

function script.Create()
	local ud = UnitDefs[unitDefID]
	scriptReload.SetupScriptReload(ammoMax, RELOAD_TIME)
	local midTable = ud.model
	
	local midpos = {midTable.midx, midTable.midy,      midTable.midz}
	local aimpos = {midTable.midx, midTable.midy + 15, midTable.midz}

	GG.Script_SetupAimPosTerraform(unitID, ud.floatOnWater, midpos, aimpos, midTable.midy + 15, midTable.midy + 60, 15, 48)
	
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

----------------------------------------------------------------------------------------------
-- Weapon Animations

function script.QueryWeapon(num) return gun[shot].firepoint end
function script.AimFromWeapon(num) return holder end

local function StunThread ()
	Signal (SIG_AIM)
	SetSignalMask(SIG_AIM)
	disarmed = true

	GG.PieceControl.StopTurn (basetop, y_axis)
	GG.PieceControl.StopTurn (housing, x_axis)
end

local function UnstunThread()
	disarmed = false
	SetSignalMask(SIG_AIM)
	RestoreAfterDelay()
end

function Stunned (stun_type)
	stuns[stun_type] = true
	StartThread (StunThread)
end
function Unstunned (stun_type)
	stuns[stun_type] = false
	if not stuns[1] and not stuns[2] and not stuns[3] then
		StartThread (UnstunThread)
	end
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)

	while firing or disarmed do
		Sleep (34)
	end

	local slowMult = (Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1)
	Turn(basetop, z_axis, heading, BASETOP_TURN_SPEED*slowMult)
	Turn(housing, x_axis, -pitch, HOUSING_TURN_SPEED*slowMult)
	WaitForTurn(basetop, z_axis)
	WaitForTurn(housing, x_axis)
	StartThread (RestoreAfterDelay)
	return (spGetUnitRulesParam(unitID, "lowpower") == 0)
end

local function reload(num)
	scriptReload.GunStartReload(num)
	gun[num].loaded = false
	SleepAndUpdateReload(num, RELOAD_TIME)
	gun[num].loaded = true
	if scriptReload.GunLoaded(num) then
		shot = 0
	end
end

function script.Shot(num)
	StartThread(reload, shot)
	EmitSfx(gun[shot].firepoint, GG.Script.UNIT_SFX2)
	shot = (shot + 1)%ammoMax
	local rz = select(3, Spring.UnitScript.GetPieceRotation(spindle))
	Turn(spindle, z_axis, rz + math.rad(120), SPINDLE_TURN_SPEED)
end

function script.BlockShot(num, targetID)
	-- Block for less than full damage and time because the target may dodge.
	local ammoReady = not gun[shot].loaded
	return ammoReady or (targetID and (GG.DontFireRadar_CheckBlock(unitID, targetID) or GG.OverkillPrevention_CheckBlock(unitID, targetID, 825.1, 18))) or false
end


----------------------------------------------------------------------------------------------
-- Death Animation

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .50 then
		Explode(basebottom, SFX.NONE)
		Explode(housing, SFX.NONE)
		Explode(holder, SFX.NONE)
		Explode(spindle, SFX.NONE)
		Explode(basetop, SFX.NONE)
		Explode(basemid, SFX.NONE)
		return 1
	elseif severity <= .99 then
		Explode(basebottom, SFX.NONE)
		Explode(housing, SFX.FALL+ SFX.SMOKE+ SFX.FIRE + SFX.EXPLODE)
		Explode(holder, SFX.FALL+ SFX.SMOKE+ SFX.FIRE + SFX.EXPLODE)
		Explode(spindle, SFX.FALL+ SFX.SMOKE+ SFX.FIRE + SFX.EXPLODE)
		Explode(basetop, SFX.FALL+ SFX.SMOKE+ SFX.FIRE + SFX.EXPLODE)
		Explode(basemid, SFX.SHATTER)
		return 2
	else
		Explode(basebottom, SFX.NONE)
		Explode(housing, SFX.SHATTER)
		Explode(holder, SFX.FALL+ SFX.SMOKE+ SFX.FIRE + SFX.EXPLODE)
		Explode(spindle, SFX.FALL+ SFX.SMOKE+ SFX.FIRE + SFX.EXPLODE)
		Explode(basetop, SFX.SHATTER)
		Explode(basemid, SFX.SHATTER)
		return 2
	end
end
