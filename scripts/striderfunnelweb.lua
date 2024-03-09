include "constants.lua"
include "spider_walking.lua"

local ALLY_ACCESS = {allied = true}

local notum = piece 'notum'
local gaster = piece 'gaster'
local gunL, gunR, aimpoint = piece('gunl', 'gunr', 'aimpoint')
local shieldArm, shield, eye = piece('shield_arm', 'shield', 'eye')
local flareL, flareR = piece('flarel', 'flarer')
-- unused pieces: emit[lr], flare[LR], eyeflare

-- note reversed sides from piece names!
local br = piece 'thigh_bacl'	-- back right
local mr = piece 'thigh_midl' 	-- middle right
local fr = piece 'thigh_frol' 	-- front right
local bl = piece 'thigh_bacr' 	-- back left
local ml = piece 'thigh_midr' 	-- middle left
local fl = piece 'thigh_fror' 	-- front left

local smokePiece = {eye}
local nanoPieces = {eye}

local cannons = {
	[0] = {turret = gunL, flare = flareL},
	[1] = {turret = gunR, flare = flareR},
}

local SIG_WALK = 1
--local SIG_BUILD = 2

local gun_1 = 1

local SIG_AIM = 2

local modelScaling = 0.9
local maxVelocity = 1.8
local PERIOD = 0.495 * modelScaling / maxVelocity

local sleepTime = PERIOD*1000

local legRaiseAngle = math.rad(20)
local legRaiseSpeed = legRaiseAngle/PERIOD
local legLowerSpeed = legRaiseAngle/PERIOD

local legForwardAngle = math.rad(12)
local legForwardTheta = math.rad(25)
local legForwardOffset = 0
local legForwardSpeed = legForwardAngle/PERIOD

local legMiddleAngle = math.rad(12)
local legMiddleTheta = 0
local legMiddleOffset = 0
local legMiddleSpeed = legMiddleAngle/PERIOD

local legBackwardAngle = math.rad(12)
local legBackwardTheta = -math.rad(25)
local legBackwardOffset = 0
local legBackwardSpeed = legBackwardAngle/PERIOD
local restore_delay = 3000

function script.StartBuilding()
	Signal(SIG_BUILD)
	SetSignalMask(SIG_BUILD)
	Spring.SetUnitCOBValue(unitID, COB.INBUILDSTANCE, 1);
end

function script.StopBuilding()
	Signal(SIG_BUILD)
	Spring.SetUnitCOBValue(unitID, COB.INBUILDSTANCE, 0);
end

local function AutoAttack()
	--Signal(SIG_ACTIVATE)
	--SetSignalMask(SIG_ACTIVATE)
	local spGetUnitHealth = Spring.GetUnitHealth
	local spGetUnitWeaponState = Spring.GetUnitWeaponState
	local spGetUnitRulesParam = Spring.GetUnitRulesParam
	local spSetUnitWeaponState = Spring.SetUnitWeaponState
	local spGetGameFrame = Spring.GetGameFrame
	
	local health, _, _, _, build = spGetUnitHealth(unitID)
	local WAVE_RELOAD = WeaponDefNames["factoryhover_armorfield"].reload * 30
	local reloaded
	while true do
		Sleep(100)
		health, _, _, _, build = spGetUnitHealth(unitID)
		while build < 1 do
			Sleep(200)
			health, _, _, _, build = spGetUnitHealth(unitID)
		end
		reloaded = select(2, spGetUnitWeaponState(unitID,3))
		if reloaded and health > 0 and build >= 1 then
			local gameFrame = spGetGameFrame()
			local reloadMult = spGetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1.0
			local reloadFrame = gameFrame + WAVE_RELOAD / reloadMult
			spSetUnitWeaponState(unitID, 3, {reloadFrame = reloadFrame})
			EmitSfx(gaster, GG.Script.DETO_W3)
		end
	end
end


local function Walk()
	Signal (SIG_WALK)
	SetSignalMask (SIG_WALK)
	while true do
		GG.SpiderWalk.walk (br, mr, fr, bl, ml, fl,
			legRaiseAngle, legRaiseSpeed, legLowerSpeed,
			legForwardAngle, legForwardOffset, legForwardSpeed, legForwardTheta,
			legMiddleAngle, legMiddleOffset, legMiddleSpeed, legMiddleTheta,
			legBackwardAngle, legBackwardOffset, legBackwardSpeed, legBackwardTheta,
			sleepTime)
	end
end

local function RestoreLegs()
	Signal (SIG_WALK)
	SetSignalMask (SIG_WALK)
	GG.SpiderWalk.restoreLegs (br, mr, fr, bl, ml, fl,
		legRaiseSpeed, legForwardSpeed, legMiddleSpeed,legBackwardSpeed)
end

local function RestoreAfterDelay()
	Sleep(restore_delay)
	for i=0, 1 do
		Turn( cannons[i].turret, y_axis, 0, math.rad(30) )
		Turn( cannons[i].turret, x_axis, 0, math.rad(15) )
	end
end

function script.Create()
	Spring.SetUnitRulesParam(unitID, "unitActiveOverride", 1) -- shields shouldn't disappear when turned off
	Move (aimpoint, z_axis, 4)
	Move (aimpoint, y_axis, 2)
	Move (aimpoint, x_axis, 0)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(AutoAttack)
	Spring.SetUnitNanoPieces(unitID, nanoPieces)
end

function script.Activate()
	Spring.SetUnitRulesParam(unitID, "shieldChargeDisabled", 0, ALLY_ACCESS)
end

function script.Deactivate()
	Spring.SetUnitRulesParam(unitID, "shieldChargeDisabled", 1, ALLY_ACCESS)
end

function script.StartMoving ()
	StartThread (Walk)
end

function script.StopMoving ()
	StartThread (RestoreLegs)
end

--[[function script.QueryNanoPiece()
	GG.LUPS.QueryNanoPiece(unitID,unitDefID,Spring.GetUnitTeam(unitID),gaster)
	return gaster
end]] -- no longer builds

function script.QueryWeapon(num)
	if num == 1 then
		return cannons[gun_1].flare
	end
	return aimpoint
end

function script.AimFromWeapon(num)
	if num == 1 then
		return cannons[gun_1].flare
	end
	return shield
end

function script.AimWeapon(num, heading, pitch)
	if num == 1 then
		Signal(SIG_AIM)
		SetSignalMask(SIG_AIM)
		for i=0,1 do
			Turn( cannons[i].turret, y_axis, heading, math.rad(60) )
			Turn( cannons[i].turret, x_axis, -pitch, math.rad(30) )
		end
		WaitForTurn(gunL, y_axis)
		WaitForTurn(gunL, x_axis)
		WaitForTurn(gunR, y_axis)
		WaitForTurn(gunR, x_axis)		
		StartThread(RestoreAfterDelay)
		return true
	else
		return true
	end
end

function script.Shot(num)
	if num == 1 then
		EmitSfx(cannons[gun_1].flare, 1024)
		EmitSfx(cannons[gun_1].flare, 1025)
		gun_1 = 1 - gun_1
	end
end

function script.Killed (recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		return 1
	elseif severity <= .50 then
		Explode (shield, SFX.FALL)
		Explode (shieldArm, SFX.FALL)
		Explode (eye, SFX.FALL)
		Explode (br, SFX.FALL)
		Explode (ml, SFX.FALL)
		Explode (fr, SFX.FALL)
		return 1
	elseif severity <= .75 then
		Explode (bl, SFX.FALL)
		Explode (mr, SFX.FALL)
		Explode (fl, SFX.FALL)
		Explode (shield, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (shieldArm, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (eye, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (br, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (ml, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (fr, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (gaster, SFX.SHATTER)
		return 2
	else
		Explode (shield, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (shieldArm, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (eye, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (bl, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (mr, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (fl, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (br, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (ml, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (fr, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode (gaster, SFX.SHATTER)
		Explode (notum, SFX.SHATTER)
		return 2
	end
end
