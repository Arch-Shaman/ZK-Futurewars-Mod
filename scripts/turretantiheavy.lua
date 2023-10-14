local base = piece 'base'
local arm = piece 'arm'
local turret = piece 'turret'
local gun = piece 'gun'
local ledgun = piece 'ledgun'
local radar = piece 'radar'
local barrel = piece 'barrel'
local firepiece = piece 'fire'
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
local spSpawnProjectile = Spring.SpawnProjectile
local spGetUnitPiecePosition = Spring.GetUnitPiecePosition
local spGetUnitPosition = Spring.GetUnitPosition
local spAddUnitDamage = Spring.AddUnitDamage
local spSpawnCEG = Spring.SpawnCEG
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
local target = nil
local lastHeading
local lastPitch
local registeredGroundFire = false
local registeredTarget = false
local firingTime = 0
local reloadGrace = 30
local armorValue = UnitDefs[unitDefID].armoredMultiple
local reloadTime = tonumber(WeaponDefNames["turretantiheavy_ata"].customParams.reload_override) * 30

local weaponIDs = {}

local i
for i=0, 60 do
	weaponIDs[i] = WeaponDefNames["turretantiheavy_ata_"..i].id
end

--[[
TO DO:

	 - reduce the amount of times spGetUnitTeam is called (how though?)
]]--

local function Open()
	Signal(SIG_OPEN)
	SetSignalMask(SIG_OPEN)
	GG.SetUnitArmor(unitID, 1)
	Turn(door1, z_axis, 0, math.rad(160))
	Turn(door2, z_axis, 0, math.rad(160))
	WaitForTurn(door1, z_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	Move(arm, y_axis, 0, 24)
	Turn(antenna, x_axis, 0, math.rad(100))
	Sleep(200)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	Move(barrel, z_axis, 0, 14)
	Move(ledgun, z_axis, 0, 14)
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
	
	Turn(turret, y_axis, 0, math.rad(100))
	Turn(gun, x_axis, 0, math.rad(80))
	Move(barrel, z_axis, -24, 14)
	Move(ledgun, z_axis, -15, 14)
	Turn(antenna, x_axis, math.rad(90), math.rad(100))
	WaitForTurn(turret, y_axis)
	WaitForTurn(gun, x_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	Move(arm, y_axis, -50, 24)
	WaitForMove(arm, y_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	
	Turn(door1, z_axis, math.rad(-(90)), math.rad(160))
	Turn(door2, z_axis, math.rad(-(-90)), math.rad(160))
	WaitForTurn(door1, z_axis)
	WaitForTurn(door2, z_axis)
	
	GG.SetUnitArmor(unitID, armorValue)
end

local function handleFire(targetID)
	firing = true
	turnrateMod = 10
	firingTime = firingTime + 1
	local beam = math.min(math.floor(firingTime / 3 + 0.01), 60)
	local d = (beam / 10 + 1)

	local weaponID = weaponIDs[beam]

	local ux, uy, uz = spGetUnitPosition(unitID)
	local px, py, pz = spGetUnitPiecePosition(unitID, firepiece)
	local _, _, _, tx, ty, tz = spGetUnitPosition(targetID, false, true)
	spSpawnProjectile(weaponID, {
		pos = {ux+px, uy+py, uz+pz},
		["end"] = {tx, ty, tz},
		owner = unitID,
		team = spGetUnitTeam(unitID),
		ttl = 1,
	})
	spSpawnCEG("ataalasergrow", tx, ty, tz, 0, 1, 0, 1, math.sqrt(d))
	spAddUnitDamage(targetID, 20 * (1 + beam / 10), 0, unitID, weaponID)
end

local function FiringTimeoutThread()
	Signal(SIG_FIRING)
	SetSignalMask(SIG_FIRING)
	Sleep(100)
	--spEcho("reload due to timeout")
	StartReload()
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
	if weaponNum ~= 1 then
		return false
	end
	
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

function script.FireWeapon()
end

function script.BlockShot(num, targetID)
	if ((targetID and not spIsUnitInLos(targetID, Spring.GetUnitAllyTeam(unitID))) or false) then
		return true
	end

	-- We block weapon 1 from firing and subsitute in our own shot

	if target == nil then
		target = targetID
	elseif target ~= targetID then
		StartReload()
		return true
	end

	handleFire(targetID)

	StartThread(FiringTimeoutThread)

	return true
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
	local reloadmod = firingTime/reloadGrace
	if reloadmod > 1 then reloadmod = 1 elseif reloadmod < 0.15 then reloadmod = 0.15 end
	local slowState = Spring.GetUnitRulesParam(unitID, "slowState") or 0
	if slowState > 0.5 then slowState = 0.5 end
	slowState = 1 - slowState
	local totalReloadTime = math.ceil((reloadTime * reloadmod)/slowState)
	frame = SpGetGameFrame() + math.ceil((reloadTime * reloadmod)/slowState)
	SpetUnitWeaponState(unitID, 1, "reloadState", frame)
	target = nil
	registeredGroundFire = false
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
	return firepiece
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
		Explode(firepiece, SFX.NONE)
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
		Explode(firepiece, SFX.NONE)
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
		Explode(firepiece, SFX.NONE)
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
		Explode(firepiece, SFX.NONE)
		Explode(antenna, SFX.FALL)
		Explode(door1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(door2, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	end
end
