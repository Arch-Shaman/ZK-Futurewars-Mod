include "constants.lua"

local dyncomm = include('dynamicCommander.lua')
_G.dyncomm = dyncomm

local spSetUnitShieldState = Spring.SetUnitShieldState

local scriptMagazine = include("scriptMagazine.lua")

--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------
local pieceMap = Spring.GetUnitPieceMap(unitID)
local HAS_GATTLING = pieceMap.rgattlingflare and true or false
local HAS_BONUS_CANNON = pieceMap.bonuscannonflare and true or false

local torso = piece 'torso'

local rcannon_flare= HAS_GATTLING and piece('rgattlingflare') or piece('rcannon_flare')
local barrels = HAS_GATTLING and piece 'barrels' or nil
local lcannon_flare = HAS_BONUS_CANNON and piece('bonuscannonflare') or piece('lnanoflare')
local lnanoflare = piece 'lnanoflare'
local lnanohand = piece 'lnanohand'
local larm = piece 'larm'
local rarm = piece 'rarm'
local pelvis = piece 'pelvis'
local rupleg = piece 'rupleg'
local lupleg = piece 'lupleg'
local rhand = piece 'rhand'
local lleg = piece 'lleg'
local lfoot = piece 'lfoot'
local rleg = piece 'rleg'
local rfoot = piece 'rfoot'

local smokePiece = {torso}
local nanoPieces = {lnanoflare}
--------------------------------------------------------------------------------
-- constants
--------------------------------------------------------------------------------
local SIG_WALK = 1
local SIG_LASER = 2
local SIG_DGUN = 4
local SIG_RESTORE_LASER = 8
local SIG_RESTORE_DGUN = 16
local SIG_RESTORE_TORSO = 32

local TORSO_SPEED_YAW = math.rad(300)
local ARM_SPEED_PITCH = math.rad(180)
local needsBattery = false
local magazine = nil

local PACE = 1.8
local BASE_VELOCITY = UnitDefNames.benzcom1.speed or 1.25*30
local VELOCITY = UnitDefs[unitDefID].speed or BASE_VELOCITY
PACE = PACE * VELOCITY/BASE_VELOCITY

local THIGH_FRONT_ANGLE = -math.rad(45)
local THIGH_FRONT_SPEED = math.rad(42) * PACE
local THIGH_BACK_ANGLE = math.rad(30)
local THIGH_BACK_SPEED = math.rad(40) * PACE
local SHIN_FRONT_ANGLE = math.rad(40)
local SHIN_FRONT_SPEED = math.rad(60) * PACE
local SHIN_BACK_ANGLE = math.rad(15)
local SHIN_BACK_SPEED = math.rad(60) * PACE

local ARM_FRONT_ANGLE = -math.rad(15)
local ARM_FRONT_SPEED = math.rad(14.5) * PACE
local ARM_BACK_ANGLE = math.rad(5)
local ARM_BACK_SPEED = math.rad(14.5) * PACE
local ARM_PERPENDICULAR = math.rad(90)
--[[
local FOREARM_FRONT_ANGLE = -math.rad(15)
local FOREARM_FRONT_SPEED = math.rad(40) * PACE
local FOREARM_BACK_ANGLE = -math.rad(10)
local FOREARM_BACK_SPEED = math.rad(40) * PACE
]]--

local TORSO_ANGLE_MOTION = math.rad(8)
local TORSO_SPEED_MOTION = math.rad(7)*PACE

local RESTORE_DELAY = 2500
local okpconfig
local priorityAim = false
local priorityAimNum = 0

--------------------------------------------------------------------------------
-- vars
--------------------------------------------------------------------------------
local isLasering, isDgunning, gunLockOut = false, false, false
local restoreHeading, restorePitch = 0, 0

local starBLaunchers = {}
local wepTable = UnitDefs[unitDefID].weapons
wepTable.n = nil
for index, weapon in pairs(wepTable) do
	local weaponDef = WeaponDefs[weapon.weaponDef]
	if weaponDef.type == "StarburstLauncher" then
		starBLaunchers[index] = true
		--Spring.Echo("sbl found")
	end
end

local function GetOKP()
	while Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1") == nil do
		Sleep(33)
	end
	okpconfig = dyncomm.GetOKPConfig()
	--Spring.Echo("Use OKP: " .. tostring(okpconfig[1].useokp or okpconfig[2].useokp))
	if okpconfig[1].useokp or okpconfig[2].useokp then
		GG.OverkillPrevention_ForceAdd(unitID)
	end
end

local function StartPriorityAim(num)
	priorityAim = true
	priorityAimNum = num
	Sleep(5000)
	priorityAim = false
end


--------------------------------------------------------------------------------
-- Walking
--------------------------------------------------------------------------------
local PACE_MULT = 0.7
local PACE = 2*PACE_MULT
local BASE_VELOCITY = UnitDefNames.benzcom1.speed or 1.25*30
local VELOCITY = UnitDefs[unitDefID].speed or BASE_VELOCITY
local PACE = PACE * VELOCITY/BASE_VELOCITY

local SLEEP_TIME = 360/PACE_MULT

local walkCycle = 1 -- Alternate between 1 and 2

local walkAngle = {
	{ -- Moving forwards
		{
			hip = {math.rad(-12), math.rad(35) * PACE},
			leg = {math.rad(80), math.rad(100) * PACE},
			foot = {math.rad(5), math.rad(40) * PACE},
			arm = {math.rad(-10), math.rad(10) * PACE},
		},
		{
			hip = {math.rad(-40), math.rad(50) * PACE},
			leg = {math.rad(10), math.rad(100) * PACE},
			foot = {math.rad(-5), math.rad(140) * PACE},
		},
	},
	{ -- Moving backwards
		{
			hip = {math.rad(2), math.rad(50) * PACE},
			leg = {math.rad(2), math.rad(40) * PACE},
			foot = {math.rad(8), math.rad(20) * PACE},
			arm = {math.rad(10), math.rad(15) * PACE},
		},
		{
			hip = {math.rad(20), math.rad(25) * PACE},
			leg = {math.rad(35), math.rad(35) * PACE},
			foot = {math.rad(-10), math.rad(80) * PACE},
		}
		
	},
}

local function Walk()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	
	while true do
		walkCycle = 3 - walkCycle
		local speedMult = (Spring.GetUnitRulesParam(unitID,"totalMoveSpeedChange") or 1)*dyncomm.GetPace()
		
		local left = walkAngle[walkCycle]
		local right = walkAngle[3 - walkCycle]
		-----------------------------------------------------------------------------------
		
		Turn(lupleg, x_axis,  left[1].hip[1],  left[1].hip[2] * speedMult)
		Turn(lleg, x_axis, left[1].leg[1],  left[1].leg[2] * speedMult)
		Turn(lfoot, x_axis, left[1].foot[1], left[1].foot[2] * speedMult)
		
		Turn(rupleg, x_axis,  right[1].hip[1],  right[1].hip[2] * speedMult)
		Turn(rleg, x_axis, right[1].leg[1],  right[1].leg[2] * speedMult)
		Turn(rfoot, x_axis,  right[1].foot[1], right[1].foot[2] * speedMult)
		
		if not (isLasering or isDgunning) then
			Turn(larm, x_axis, left[1].arm[1],  left[1].arm[2] * speedMult)
			Turn(rarm, x_axis, right[1].arm[1],  right[1].arm[2] * speedMult)
		end
		
		Sleep(SLEEP_TIME / speedMult)
		-----------------------------------------------------------------------------------
		
		Turn(lupleg, x_axis,  left[2].hip[1],  left[2].hip[2] * speedMult)
		Turn(lleg, x_axis, left[2].leg[1],  left[2].leg[2] * speedMult)
		Turn(lfoot, x_axis, left[2].foot[1], left[2].foot[2] * speedMult)
		
		Turn(rupleg, x_axis,  right[2].hip[1],  right[2].hip[2] * speedMult)
		Turn(rleg, x_axis, right[2].leg[1],  right[2].leg[2] * speedMult)
		Turn(rfoot, x_axis,  right[2].foot[1], right[2].foot[2] * speedMult)
		
		if not (isLasering or isDgunning) then
			Turn(torso, z_axis, -0.1*(walkCycle - 1.5), 0.12 * speedMult)
		end
		
		Sleep(SLEEP_TIME / speedMult)
	end
end

local function RestoreLegs()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	
	Move(pelvis, y_axis, 0, 1)
	Turn(lupleg, x_axis, 0, math.rad(200))
	Turn(lleg, x_axis, 0, math.rad(200))
	Turn(lfoot, x_axis, 0, math.rad(200))
	Turn(rupleg, x_axis, 0, math.rad(200))
	Turn(rleg, x_axis, 0, math.rad(200))
	Turn(rfoot, x_axis, 0, math.rad(200))
	Turn(torso, y_axis, 0, math.rad(200))
	if not (isLasering or isDgunning) then
		Turn(larm, x_axis, 0, math.rad(200))
		Turn(rarm, x_axis, 0, math.rad(200))
		Turn(torso, z_axis, 0, math.rad(200))
	end
end


function script.Create()
	dyncomm.Create()
	Hide(rcannon_flare)
	Hide(lnanoflare)
	needsBattery = dyncomm.SetUpBattery()
	magazine = dyncomm.SetUpMagazine()
--	Turn(larm, x_axis, math.rad(30))
--	Turn(rarm, x_axis, math.rad(-10))
--	Turn(rhand, x_axis, math.rad(41))
--	Turn(lnanohand, x_axis, math.rad(36))
	
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	Spring.SetUnitNanoPieces(unitID, nanoPieces)
	StartThread(GetOKP)
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(RestoreLegs)
end

--------------------------------------------------------------------------------
-- Aiming
--------------------------------------------------------------------------------

local function RestoreTorsoAim()
	Signal(SIG_RESTORE_TORSO)
	SetSignalMask(SIG_RESTORE_TORSO)
	Sleep(RESTORE_DELAY)
	Turn(torso, y_axis, restoreHeading, TORSO_SPEED_YAW)
end

local function RestoreLaser()
	StartThread(RestoreTorsoAim)
	Signal(SIG_RESTORE_LASER)
	SetSignalMask(SIG_RESTORE_LASER)
	Sleep(RESTORE_DELAY)
	isLasering = false
	Turn(rarm, x_axis, restorePitch, ARM_SPEED_PITCH)
	Turn(rhand, x_axis, 0, ARM_SPEED_PITCH)
	
	if HAS_GATTLING then
		Spin(barrels, z_axis, 100)
		Sleep(200)
		Turn(barrels, z_axis, 0, ARM_SPEED_PITCH)
	end
end

local function RestoreDGun()
	StartThread(RestoreTorsoAim)
	Signal(SIG_RESTORE_DGUN)
	SetSignalMask(SIG_RESTORE_DGUN)
	Sleep(RESTORE_DELAY)
	isDgunning = false
	Turn(larm, x_axis, 0, ARM_SPEED_PITCH)
	Turn(lnanohand, x_axis, 0, ARM_SPEED_PITCH)
end

function script.AimWeapon(num, heading, pitch)
	local weaponNum = dyncomm.GetWeapon(num)
	if weaponNum == 3 then
		return true
	end
	GG.DontFireRadar_CheckAim(unitID)
	if priorityAim and weaponNum ~= priorityAimNum then
		return false
	end
	if weaponNum and dyncomm.IsManualFire(num) and not priorityAim and dyncomm.PriorityAimCheck(num) then
		StartThread(StartPriorityAim, weaponNum)
		if weaponNum == 1 then
			Signal(SIG_DGUN)
		else
			Signal(SIG_LASER)
		end
	end
	if weaponNum == 1 then
		Signal(SIG_LASER)
		SetSignalMask(SIG_LASER)
		isLasering = true
		if pitch > math.rad(-45) then
			Turn(rarm, x_axis, -pitch, ARM_SPEED_PITCH)
			Turn(rhand, x_axis, math.rad(0), ARM_SPEED_PITCH)
		else
			Turn(rarm, x_axis, -math.rad(18), ARM_SPEED_PITCH)
			Turn(rhand, x_axis, math.rad(18) -pitch, ARM_SPEED_PITCH)
		end
		Turn(torso, y_axis, heading, TORSO_SPEED_YAW)
		WaitForTurn(torso, y_axis)
		WaitForTurn(rarm, x_axis)
		StartThread(RestoreLaser)
		return true
	elseif weaponNum == 2 then
		if starBLaunchers[num] then
			pitch = ARM_PERPENDICULAR
		end
		Signal(SIG_DGUN)
		SetSignalMask(SIG_DGUN)
		isDgunning = true
		if pitch > math.rad(-45) then
			Turn(larm, x_axis, -pitch, ARM_SPEED_PITCH)
			Turn(lnanohand, x_axis, math.rad(0), ARM_SPEED_PITCH)
		else
			Turn(larm, x_axis, -math.rad(18), ARM_SPEED_PITCH)
			Turn(lnanohand, x_axis, math.rad(18) -pitch, ARM_SPEED_PITCH)
		end
		--Turn(larm, x_axis, math.min(math.rad(-18), -pitch), ARM_SPEED_PITCH)
		--Turn(lnanohand, x_axis, math.max(0, math.rad(18) -pitch), ARM_SPEED_PITCH)
		Turn(torso, y_axis, heading, TORSO_SPEED_YAW)
		WaitForTurn(torso, y_axis)
		WaitForTurn(lnanohand, x_axis)
		StartThread(RestoreDGun)
		return true
	end
	return false
end

function script.FireWeapon(num)
	local weaponNum = dyncomm.GetWeapon(num)
	if weaponNum == 1 then
		dyncomm.EmitWeaponFireSfx(rcannon_flare, num)
	elseif weaponNum == 2 then
		dyncomm.EmitWeaponFireSfx(lcannon_flare, num)
	end
	if dyncomm.IsManualFire(num) then
		priorityAim = false
	end
end

function script.BlockShot(num, targetID)
	local weaponNum = dyncomm.GetWeapon(num)
	--Spring.Echo(unitID .. ": BlockShot: " .. weaponNum)
	local radarcheck = (targetID and GG.DontFireRadar_CheckBlock(unitID, targetID)) and true or false
	local okp = false
	if okpconfig and okpconfig[weaponNum] and okpconfig[weaponNum].useokp and targetID then
		okp = GG.OverkillPrevention_CheckBlock(unitID, targetID, okpconfig[weaponNum].damage, okpconfig[weaponNum].timeout, okpconfig[weaponNum].speedmult, okpconfig[weaponNum].structureonly) or false -- (unitID, targetID, damage, timeout, fastMult, radarMult, staticOnly)
		--Spring.Echo("OKP: " .. tostring(okp))
	end
	local battery = false
	if needsBattery then
		battery = GG.BatteryManagement.CanFire(unitID, weaponNum)
	end
	local mag = false
	if magazine and magazine[weaponNum] then
		mag = not scriptMagazine.CanFire(weaponNum)
	end
	return okp or radarcheck or battery or mag
end

function script.Shot(num)
	local weaponNum = dyncomm.GetWeapon(num)
	if magazine and magazine[weaponNum] then
		scriptMagazine.Reload(weaponNum)
	end
	if weaponNum == 1 then
		dyncomm.EmitWeaponShotSfx(rcannon_flare, num)
	elseif weaponNum == 2 then
		dyncomm.EmitWeaponShotSfx(lcannon_flare, num)
	end
end

function script.AimFromWeapon(num)
	if dyncomm.IsManualFire(num) then
		if dyncomm.GetWeapon(num) == 1 then
			return rcannon_flare
		elseif dyncomm.GetWeapon(num) == 2 then
			return lcannon_flare
		end
	end
	return pelvis
end

function script.QueryWeapon(num)
	if dyncomm.GetWeapon(num) == 1 then
		return rcannon_flare
	elseif dyncomm.GetWeapon(num) == 2 then
		return lcannon_flare
	end
	return pelvis
end

function script.StopBuilding()
	SetUnitValue(COB.INBUILDSTANCE, 0)
	Turn(larm, x_axis, 0, ARM_SPEED_PITCH)
	restoreHeading, restorePitch = 0, 0
	StartThread(RestoreDGun)
end

function script.StartBuilding(heading, pitch)
	restoreHeading, restorePitch = heading, pitch
	Turn(larm, x_axis, math.rad(-30) - pitch, ARM_SPEED_PITCH)
	if not (isDgunning) then Turn(torso, y_axis, heading, TORSO_SPEED_YAW) end
	SetUnitValue(COB.INBUILDSTANCE, 1)
end

function script.QueryNanoPiece()
	GG.LUPS.QueryNanoPiece(unitID,unitDefID,Spring.GetUnitTeam(unitID),lnanoflare)
	return lnanoflare
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	local x, y, z = Spring.GetUnitPosition(unitID)
	local assetDenialSystemActivated = dyncomm.Explode(x, y, z)
	local explodables = {[1] = torso, [2] = larm, [3] = rarm, [4] = pelvis, [5] = lupleg, [6] = rupleg, [7] = lnanoflare, [8] = rhand, [9] = lleg, [10] = rleg}
	local flags = SFX.SMOKE + SFX.FIRE + SFX.EXPLODE
	if assetDenialSystemActivated then
		for i = 1, #explodables do
			Explode(explodables[i], flags)
		end
	elseif severity < 0.5 then
		dyncomm.SpawnWreck(1)
	else
		Explode(torso, SFX.SHATTER)
		for i = 2, #explodables do
			Explode(explodables[i], flags)
		end
		dyncomm.SpawnWreck(2)
	end
end
