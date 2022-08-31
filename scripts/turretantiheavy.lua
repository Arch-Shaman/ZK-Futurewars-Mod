local base = piece 'base'
local arm = piece 'arm'
local turret = piece 'turret'
local gun = piece 'gun'
local ledgun = piece 'ledgun'
local radar = piece 'radar'
local barrel = piece 'barrel'
local fire = piece 'fire'
local antenna = piece 'antenna'
local door1 = piece 'door1'
local door2 = piece 'door2'

local smokePiece = {base, turret}

include "constants.lua"

local spGetUnitRulesParam 	= Spring.GetUnitRulesParam
local SpGetGameSeconds = Spring.GetGameSeconds
local SpGetGameFrame = Spring.GetGameFrame
local spEcho = Spring.Echo
local SpUnitWeaponFire = Spring.UnitWeaponFire
local SpSetUnitRulesParam = Spring.SetUnitRulesParam
local SpetUnitWeaponState = Spring.SetUnitWeaponState
local spGetUnitTeam = Spring.GetUnitTeam
local spIsUnitInLos = Spring.IsUnitInLos
local abs = math.abs
local huge = math.huge

-- Signal definitions
local SIG_AIM = 2
local SIG_OPEN = 1
local SIG_FIRING = 4

local inlosTrueTable = {inlos = true}

local open = true
local firing = false
local reloading = false
local turnrateMod = 0.5
local target = 1 --anything but nil is fine
local lastHeading
local lastPitch
local registeredGroundFire = false
local registeredTarget = false
local firingTime = 0

--[[
TO DO:

	 - reduce the amount of times spGetUnitTeam is called (how though?)
]]--

local function Open()
	Signal(SIG_OPEN)
	SetSignalMask(SIG_OPEN)
	Spring.SetUnitArmored(unitID,false)	--broken
	Spring.SetUnitCOBValue(unitID, COB.ARMORED, 0)
	Turn(door1, z_axis, 0, math.rad(80))
	Turn(door2, z_axis, 0, math.rad(80))
	WaitForTurn(door1, z_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	Move(arm, y_axis, 0, 12)
	Turn(antenna, x_axis, 0, math.rad(50))
	Sleep(200)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	Move(barrel, z_axis, 0, 7)
	Move(ledgun, z_axis, 0, 7)
	WaitForMove(barrel, z_axis)
	WaitForMove(ledgun, z_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	open = true
end

local function Close()
	open = false
	Signal(SIG_OPEN)
	SetSignalMask(SIG_OPEN)
	
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	Turn(turret, y_axis, 0, math.rad(50))
	Turn(gun, x_axis, 0, math.rad(40))
	Move(barrel, z_axis, -24, 7)
	Move(ledgun, z_axis, -15, 7)
	Turn(antenna, x_axis, math.rad(90), math.rad(50))
	WaitForTurn(turret, y_axis)
	WaitForTurn(gun, x_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	Move(arm, y_axis, -50, 12)
	WaitForMove(arm, y_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	Turn(door1, z_axis, math.rad(-(90)), math.rad(80))
	Turn(door2, z_axis, math.rad(-(-90)), math.rad(80))
	WaitForTurn(door1, z_axis)
	WaitForTurn(door2, z_axis)
	
	Spring.SetUnitArmored(unitID,true)
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	Spin(radar, y_axis, math.rad(1000))
end

local on = true

function OnArmorStateChanged(state)
	local armored = state == 1
	if armored and on then
		StopSpin(radar, y_axis)
		Signal(SIG_AIM)
		Turn(radar, y_axis, 0, math.rad(1000))
		StartThread(Close)
		on = false
	elseif not armored and not on then
		Spin(radar, y_axis, math.rad(1000))
		StartThread(Open)
		on = true
	end
end

function script.AimWeapon(weaponNum, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)

	while (not open) or (spGetUnitRulesParam(unitID, "lowpower") == 1) do
		Sleep (100)
	end

	GG.DontFireRadar_CheckAim(unitID)
	
	if (target == nil) and firing then 
		if registeredGroundFire then
			if abs(lastHeading - heading) + abs(lastPitch - pitch) > 0.01 then
				--spEcho("reload due to turn")
				StartReload()
			end
		else
			registeredGroundFire = true
			lastHeading = heading
			lastPitch = pitch
		end
	end
	
	local slowMult = (Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1)
	Turn(turret, y_axis, heading, math.rad(50)*slowMult*turnrateMod)
	Turn(gun, x_axis, 0 - pitch, math.rad(40)*slowMult*turnrateMod)
	WaitForTurn(turret, y_axis)
	WaitForTurn(gun, x_axis)
	return (spGetUnitRulesParam(unitID, "lowpower") == 0)	--checks for sufficient energy in grid
end

local beam_duration = WeaponDefs[UnitDef.weapons[1].weaponDef].beamtime * 1000
function script.FireWeapon()
	Signal(SIG_FIRING)
	SetSignalMask(SIG_FIRING)
	--EmitSfx(fire, 1024)
	firing = true
	turnrateMod = 2
	firingTime = firingTime + 1
	local d = (firingTime / 30 + 1) ^ 0.67
	if d > 3 then
		d = 3
	end
	SpSetUnitRulesParam(unitID, "CEGdOverride2", d, inlosTrueTable)
	local timeout = SpGetGameFrame()
	timeout = timeout + beam_duration * 3
	SpSetUnitRulesParam(unitID, "CEGdTimeout2", timeout, inlosTrueTable)
	Sleep(beam_duration * 3)
	--spEcho("reload due to timeout")
	StartReload()
end

function script.BlockShot(num, targetID)
	if firing then
		if registeredTarget then
			if target ~= targetID and registeredTarget then
				--spEcho("target: " .. (target or "nil") .. " targetID : " .. (targetID or "nil"))
				StartReload()
			end
		else
			registeredTarget = true
		end
	end
	--spEcho("Is unit is Los: " .. ((spIsUnitInLos(targetID, spGetUnitTeam(unitID)) and "true") or "false"))
	--spEcho("Is ground fire: " .. ((targetID and "true") or "false"))
	--spEcho("Final Verdict: " .. (((targetID and not spIsUnitInLos(targetID, spGetUnitTeam(unitID))) and "true") or "false"))
	return targetID and not spIsUnitInLos(targetID, Spring.GetUnitAllyTeam(unitID))
end

function script.TargetWeight(num, targetUnitID)
	if spIsUnitInLos(targetUnitID, Spring.GetUnitAllyTeam(unitID)) then
		return 1
	else
		return huge
	end
end

function StartReload()
	firing = false
	turnrateMod = 0.5
	frame = SpGetGameFrame() + 420
	SpetUnitWeaponState(unitID, 1, "reloadState", frame)
	SpetUnitWeaponState(unitID, 2, "reloadState", frame)
	registeredGroundFire = false
	registeredTarget = false
	firingTime = 0
end




--[[
-- multi-emit workaround
function script.BlockShot(num)
	local px, py, pz = Spring.GetUnitPosition(unitID)
	Spring.PlaySoundFile("sounds/weapon/laser/heavy_laser6.wav", 10, px, py, pz)
	return false
end

function script.Shot(weaponNum)
	EmitSfx(fire, GG.Script.FIRE_W1)
	EmitSfx(fire, GG.Script.FIRE_W1)
	EmitSfx(fire, GG.Script.FIRE_W1)
	EmitSfx(fire, GG.Script.FIRE_W1)
end
--]]

function script.AimFromWeapon(weaponNum)
	return barrel
end

function script.QueryWeapon(weaponNum)
	return fire
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(base, SFX.NONE)
		Explode(arm, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(gun, SFX.NONE)
		Explode(ledgun, SFX.NONE)
		Explode(radar, SFX.NONE)
		Explode(barrel, SFX.NONE)
		Explode(fire, SFX.NONE)
		Explode(antenna, SFX.NONE)
		Explode(door1, SFX.NONE)
		Explode(door2, SFX.NONE)
		return 1
	elseif severity <= .50 then
		Explode(base, SFX.NONE)
		Explode(arm, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(gun, SFX.SHATTER)
		Explode(ledgun, SFX.NONE)
		Explode(radar, SFX.NONE)
		Explode(barrel, SFX.FALL)
		Explode(fire, SFX.NONE)
		Explode(antenna, SFX.FALL)
		Explode(door1, SFX.FALL)
		Explode(door2, SFX.FALL)
		return 1
	elseif severity <= .99 then
		Explode(base, SFX.NONE)
		Explode(arm, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(gun, SFX.SHATTER)
		Explode(ledgun, SFX.NONE)
		Explode(radar, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(barrel, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(fire, SFX.NONE)
		Explode(antenna, SFX.FALL)
		Explode(door1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(door2, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	else
		Explode(base, SFX.NONE)
		Explode(arm, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(gun, SFX.SHATTER)
		Explode(ledgun, SFX.NONE)
		Explode(radar, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(barrel, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(fire, SFX.NONE)
		Explode(antenna, SFX.FALL)
		Explode(door1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(door2, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	end
end
