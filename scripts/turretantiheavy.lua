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

local weaponDefID = UnitDefs[unitDefID].weapons[1].weaponDef
--Spring.Echo("Firing Piece is " .. firepiece)

local smokePiece = {base, turret}

include "constants.lua"

local spGetUnitRulesParam 	= Spring.GetUnitRulesParam
local spGetUnitHealth = Spring.GetUnitHealth
local spGetGameFrame = Spring.GetGameFrame
local SpUnitWeaponFire = Spring.UnitWeaponFire
local SpSetUnitRulesParam = Spring.SetUnitRulesParam
local SpSetUnitWeaponState = Spring.SetUnitWeaponState
--local spGetUnitTeam = Spring.GetUnitTeam
local spIsUnitInLos = Spring.IsUnitInLos
--local spSpawnProjectile = Spring.SpawnProjectile
--local spGetUnitPiecePosDir  = Spring.GetUnitPiecePosDir
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitWeaponState = Spring.GetUnitWeaponState
--local spAddUnitDamage = Spring.AddUnitDamage
local spSpawnCEG = Spring.SpawnCEG
local spGetUnitWeaponTarget = Spring.GetUnitWeaponTarget
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local abs = math.abs
local huge = math.huge
local max = math.max
local rand = math.random

-- Signal definitions
local SIG_AIM = 2
local SIG_OPEN = 1

local inlosTrueTable = {inlos = true}

local myAllyteam
local open = true
local firing = false
local turnrateMod = 1
local target = nil
local reloading = false
local okpTarget = nil
--local registeredGroundFire = false
--local registeredTarget = false
local firingTime = 0
local reloadGrace = 20
--local lastOKPFrame = 0
local hasFiredRecently = -1
local armorValue = UnitDefs[unitDefID].armoredMultiple
local reloadTime = tonumber(WeaponDefNames["turretantiheavy_ata"].customParams.reload_override) * 30

--[[local weaponIDs = {}

local i
for i=0, 60 do
	weaponIDs[i] = WeaponDefNames["turretantiheavy_ata_"..i].id
end]]

if not GG.AzimuthAvoidance then
	GG.AzimuthAvoidance = {}
end

--[[
TO DO:

	 - reduce the amount of times spGetUnitTeam is called (how though?)
]]--

--[[local function AllyteamThread()
	while true do
		myAllyteam = spGetUnitAllyTeam(unitID)
		Sleep(1000)
	end
end]]

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

local function setOKPTarget(targetID)
	if targetID == okpTarget then
		return
	end
	if okpTarget then
		GG.AzimuthAvoidance[okpTarget] = GG.AzimuthAvoidance[okpTarget] - 1
		if GG.AzimuthAvoidance[okpTarget] <= 0 then
			GG.AzimuthAvoidance[okpTarget] = nil
		end
	end
	if targetID then
		GG.AzimuthAvoidance[targetID] = (GG.AzimuthAvoidance[targetID] or 0) + 1
	end
	okpTarget = targetID
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

local function CheckStillFiring()
	if (not open) or (spGetUnitRulesParam(unitID, "lowpower") == 1) then
		return false
	else
		local targetType, _, targetID = spGetUnitWeaponTarget(unitID, 1)
		if targetType ~= 1 then
			--Spring.Echo("Target type is not valid")
			return false
		else
			local firedRecently = hasFiredRecently - (Spring.GetGameFrame() - 1) >= 0 -- blockshot updates every frame
			--Spring.Echo("Has fired recently: " .. tostring(firedRecently) .. "(" .. hasFiredRecently - (Spring.GetGameFrame() - 3) .. ")")
			return targetID == target and firedRecently
		end
	end
end


local function StartReload()
	--Spring.Echo("StartReload")
	firing = false
	turnrateMod = 1
	setOKPTarget(nil)
	
	local reloadmod = firingTime / reloadGrace
	--Spring.Echo("Firing time: " .. firingTime .. ", Reload mult: " .. reloadmod)
	if reloadmod > 1 then reloadmod = 1 elseif reloadmod < 0.15 then reloadmod = 0.15 end
	local slowState = Spring.GetUnitRulesParam(unitID, "slowState") or 0
	if slowState > 0.5 then slowState = 0.5 end
	slowState = 1 - slowState
	local duration = math.ceil((reloadTime * reloadmod)/slowState)
	--Spring.Echo("Setting reload time to " .. duration)
	frame = spGetGameFrame() + duration
	--Spring.Echo("Setting reload frame to " .. frame)
	SpSetUnitWeaponState(unitID, 1, "reloadTime", duration) -- force render.
	SpSetUnitWeaponState(unitID, 1, "reloadState", frame)
	local damages = WeaponDefs[weaponDefID].damages
	for k, v in pairs(damages) do
		if type(k) == "number" then
			Spring.SetUnitWeaponDamages(unitID, 1, k, v) -- restart damage to 100%
		end
	end
	target = nil
	firingTime = 0
end

local function DamageUpdateThread()
	local damages = WeaponDefs[weaponDefID].damages
	while true do
		if firing and CheckStillFiring() then
			local beam = math.min(math.floor(firingTime / 10 + 0.01), 60)
			local damageMult = (beam / 10 + 1)
			for k, v in pairs(damages) do
				--Spring.Echo(k)
				if type(k) == "number" then
					Spring.SetUnitWeaponDamages(unitID, 1, k, v * damageMult)
					--Spring.Echo("DamageUpdate: " .. k .. ": " .. v * damageMult)
				end
			end
			Sleep(66)
		else
			Sleep(33)
		end
	end
end

local function WatchForFinishThread()
	--Spring.Echo("Start WatchThread " .. Spring.GetGameFrame() .. "." .. math.random(1, 999))
	while CheckStillFiring() do
		Sleep(33)
	end
	reloading = true
	StartReload()
	while spGetUnitWeaponState(unitID, 1, "reloadFrame") < Spring.GetGameFrame() do
		Sleep(33)
	end
	reloading = false
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(DamageUpdateThread)
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

	local targetType, _, targetID = spGetUnitWeaponTarget(unitID, 1)
	if targetType ~= 1 then
		return
	end
	setOKPTarget(targetID)
	GG.DontFireRadar_CheckAim(unitID)
	
	local slowMult = (Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1)
	Turn(turret, y_axis, heading, math.rad(50)*slowMult*turnrateMod)
	Turn(gun, x_axis, 0 - pitch, math.rad(40)*slowMult*turnrateMod)
	WaitForTurn(turret, y_axis)
	WaitForTurn(gun, x_axis)

	return (spGetUnitRulesParam(unitID, "lowpower") == 0)
end

function script.BlockShot(num, targetID)
	if not firing and not reloading then -- prevent firingTime from clearing or gaining turret turn rate while reloading.
		SpSetUnitWeaponState(unitID, 1, "reloadTime", 1/30)
		target = targetID
		firing = true
		hasFiredRecently = Spring.GetGameFrame()
		turnrateMod = 10
		setOKPTarget(target)
		StartThread(WatchForFinishThread)
		return false
	end
	if firing and not CheckStillFiring() then
		return true
	elseif firing then
		firingTime = firingTime + 1
		SpSetUnitRulesParam(unitID, "azi_firing_time", firingTime, 1)
		hasFiredRecently = Spring.GetGameFrame()
		return false
	end
	return true -- something has gone wrong. Unhandled!
end

function script.TargetWeight(num, targetUnitID)
	if firing then
		-- Give lucifer adderall
		if targetUnitID == target then
			return 0.1
		else
			return huge
		end
	elseif spIsUnitInLos(targetUnitID, myAllyteam) then
		local hp = spGetUnitHealth(targetUnitID)
		hp = max(hp - (GG.AzimuthAvoidance[targetUnitID] or 0) * 20000 + rand() * 500, 50)
		return (25000 / hp) ^ 4
	else
		return huge
	end
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
	setOKPTarget(nil)
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
