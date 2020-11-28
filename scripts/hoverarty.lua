include "constants.lua"

local base = piece 'base' 
local turret = piece 'turret' 
local gun = piece 'barrel1' 
local wheels = {piece 'frdirt', piece 'fldirt', piece 'rrdirt', piece 'rldirt'}
local frpontoon = piece 'frpontoon' 
local flpontoon = piece 'flpontoon' 
local rrpontoon = piece 'rrpontoon' 
local rlpontoon = piece 'rlpontoon' 
local flare = piece 'firepoint1' 

local smokePiece = {base, turret}

local RESTORE_DELAY = 4000

-- Signal definitions
local SIG_AIM = 2
local SIG_MOVE = 4

local curTerrainType = 4
local wobble = false
local firing = false
local tracking = 0
local trackneeded = 15
local reloading = false
local turning = false
local trackingcomplete = false
local reloadtime = WeaponDefs[UnitDef.weapons[1].weaponDef].reload * 1000
local lastfire = 0

local function Tilt()
	while true do
		local angle1 = math.random(-15, 15)
		local angle2 = math.random(-15, 15)
		Turn(base, x_axis, math.rad(angle1*0.1), math.rad(1))
		Turn(base, z_axis, math.rad(angle2*0.1), math.rad(1))
		WaitForTurn(base, x_axis)
		WaitForTurn(base, z_axis)
	end
end

local function WobbleUnit()
	StartThread(Tilt)
	while true do
		if wobble == true then
			Move(base, y_axis, 2, 3)
		end
		if wobble == false then
			Move(base, y_axis, -2, 3)
		end
		wobble = not wobble
		Sleep(1500)
	end
end

local oldtime = 0

local function HoverFX()
	local emitType = 1024
	while true do
		if not Spring.GetUnitIsCloaked(unitID) then
			if (curTerrainType == 1 or curTerrainType == 2) and select(2, Spring.GetUnitPosition(unitID)) == 0 then
				emitType = 5
			else
				emitType = 1024
			end
			for i = 1, 4 do
				EmitSfx(wheels[i], emitType)
			end
		end
		Sleep(150)
	end
end

function script.setSFXoccupy(num)
	curTerrainType = num
end

function script.StopMoving()
	bMoving = 0
end

function TurnThread()
	if turning and not Spring.GetUnitIsCloaked(unitID) then
		local x,y,z = Spring.GetUnitPosition(unitID)
		Spring.PlaySoundFile("turretslow.wav", 0.5,x,y,z,0.1,0.1,0.1,1)
		Sleep(600)
	else
		Sleep(100)
	end
end

function reloadThread()
	while true do
		if reloading then
			Sleep(reloadtime)
			reloading = false
		end
		Sleep(100)
	end
end

function TrackThread()
	while true do
		if lastfire + 6 <= Spring.GetGameFrame() and tracking > 0 then
			tracking = tracking - 4
			if tracking < 0 then
				tracking = 0
			end
		end
		if tracking >= trackneeded and not trackingcomplete then
			local x,y,z = Spring.GetUnitPosition(unitID)
			Spring.PlaySoundFile("weapons/trackercompleted.wav", 1.0, x, y, z, 1, 1, 1, 1)
			Sleep(250)
			trackingcomplete = true
		end
		Sleep(33)
	end
end

function script.Create()
	Hide(flare)
	StartThread(reloadThread)
	StartThread(WobbleUnit)
	StartThread(TurnThread)
	StartThread(TrackThread)
	--for i = 1, 4 do
		--Hide(wheels[i])
	--end
	StartThread(GG.Script.SmokeUnit, smokePiece)
	StartThread(HoverFX)
end

local function RestoreAfterDelay()
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, math.rad(30))
	Turn(gun, x_axis, 0, math.rad(10))
end

function script.AimWeapon(num, heading, pitch)
	if num == 2 and (reloading or tracking > trackneeded + 3) then
		return false
	end
	if num == 1 and not trackingcomplete then
		return false
	end
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)

	while firing do
		Sleep(100)
	end

	GG.DontFireRadar_CheckAim(unitID)
	
	Turn(turret, y_axis, heading, math.rad(30))
	Turn(gun, x_axis, -pitch, math.rad(30))
	turning = true
	WaitForTurn(turret, y_axis)
	WaitForTurn(gun, x_axis)
	turning = false
	StartThread(RestoreAfterDelay)
	return true
end

function script.BlockShot(num, targetID)
	return (targetID and GG.DontFireRadar_CheckBlock(unitID, targetID)) and true or false
end

function script.AimFromWeapon(num)
	return gun
end

function script.QueryWeapon(num)
	return flare
end

local beam_duration = WeaponDefs[UnitDef.weapons[1].weaponDef].beamtime * 1000

function script.FireWeapon(id)
	if id == 2 then -- tracking beam 
		tracking = tracking + 1
		lastfire = Spring.GetGameFrame()
	elseif id == 1 then
		firing = true
		Sleep (beam_duration)
		firing = false
		reloading = true
		trackingcomplete = false
		tracking = 0
	end
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(gun, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(base, SFX.NONE)
		Explode(turret, SFX.NONE)
		return 1
	elseif severity <= .50 then
		Explode(gun, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(base, SFX.NONE)
		Explode(turret, SFX.FALL)
		return 1
	elseif severity <= .99 then
		Explode(gun, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(base, SFX.NONE)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(flpontoon, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(frpontoon, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(rlpontoon, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(rrpontoon, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		return 2
	else
		Explode(gun, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(base, SFX.NONE)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(flpontoon, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(frpontoon, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(rlpontoon, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(rrpontoon, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		return 2
	end
end