local base = piece 'base'
--local tube = piece 'hatch'
local door1 = piece 'door.b'
local door2 = piece 'door.f'
local door3 = piece 'door.l'
local door4 = piece 'door.r'
local launcher = piece 'launcher'
local missile = piece 'mirv'
local emit1 = piece 'emit1'
local emit2 = piece 'emit2'
local flare = piece 'flare'

-- unused pieces: mirvdoor1, mirvdoor2, mirvdoor3

include "constants.lua"

local RESTORE_DELAY = 3000
local openingDoors = false
local doorsAreOpen = false
local closingDoors = false
local missileLoaded = true
local primingQueued = false
local mystock = 0

-- Signal definitions
local SIG_AIM = 1
local SIG_RESTORE = 2

local function OpenDoors()
	SetSignalMask(0)
	
	if openingDoors or closingDoors then
		return
	end
	openingDoors = true

	Move(doorl, x_axis, 0)
	Move(doorl, x_axis, -22, 14)
	Move(doorr, x_axis, 0)
	Move(doorr, x_axis, 22, 14)
	Move(tube, y_axis, 0)
	Move(nuke, x_axis, 0)
	Move(tower, y_axis, 0)
	
	Show(tube)
	Show(tower)
	Show(nuke)
	
	Sleep(1000)

	Move(tube, y_axis, 15, 10)
	
	Move(tower, y_axis, 62, 22)
	Sleep(3000)
	doorsAreOpen = true
	openingDoors = false
end

local function CloseDoors()
	SetSignalMask(0)
	
	if openingDoors or closingDoors then
		return
	end
	doorsAreOpen = false
	closingDoors = true
	
	Sleep(500)
	
	Move(tower, y_axis, 0, 30)
	Sleep(1000)
	Move(tube, y_axis, 0, 15)
	Sleep(1000)

	Move(doorl, x_axis, 0, 14)
	Move(doorr, x_axis, 0, 14)
	Sleep(500)
	
	WaitForMove(doorr, x_axis)
	Hide(tube)
	
	Sleep(500)	-- keep door from instantly opening after closing
	closingDoors = false
	missileLoaded = true
	
	if primingQueued or Spring.GetUnitStockpile(unitID) > 0 then
		primingQueued = false
		StartThread(OpenDoors)
	end
end

function StockpileChanged(newStock)
	mystock = newStock
	if newStock <= 0 then
		return
	end
	if not missileLoaded then
		primingQueued = true
	elseif not doorsAreOpen and not openingDoors and not closingDoors then
		StartThread(OpenDoors)
	end
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, {piece("smoke1", "smoke2", "smoke3")})
	Hide(tube)
	Hide(tower)
	Hide(nuke)
end

local function RestoreAfterDelay()
	Signal(SIG_RESTORE)
	SetSignalMask(SIG_RESTORE)
	Sleep(RESTORE_DELAY)
	
	StartThread(CloseDoors)
end

function script.AimWeapon(num, heading, pitch)
	StartThread(RestoreAfterDelay)
	
	if not (missileLoaded or closingDoors) then
		StartThread(CloseDoors)
	elseif not (doorsAreOpen or openingDoors) then
		StartThread(OpenDoors)
	end
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	while not doorsAreOpen do
		Sleep(25)
	end
	return true
end

function script.FireWeapon()
	Hide(nuke)
	missileLoaded = false
	doorsAreOpen = false
	if GG.GameRules_NukeLaunched then
		GG.GameRules_NukeLaunched(unitID)
	end
	
	-- Intentionally non-positional
	Spring.PlaySoundFile("sounds/weapon/missile/heavymissile_launch.wav", 15, "battle")
end

function script.QueryWeapon()
	return point
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if mystock > 0 then
		local x, y, z = Spring.GetUnitPosition(unitID)
		local deathproj = WeaponDefNames["staticnuke_death"].id
		local params = {pos = {x, y + 5, z}, team = Spring.GetGaiaTeamID(), ttl = 50*30, gravity = -0.1}
		local pid
		for i = 1, mystock * 3 do
			pid = Spring.SpawnProjectile(deathproj, params) -- first always hits the silo.
			if i ~= 1 then
				params.pos[2] = y + 300 + (math.random() * 100)
				Spring.SetProjectileVelocity(pid, 4 - math.random() * 8, math.random() * 15, 4 - math.random() * 8)
			end
		end
	end
	if (severity <= .25) then
		Explode(base, SFX.NONE)
		Explode(tube, SFX.NONE)
		Explode(doorl, SFX.NONE)
		Explode(doorr, SFX.NONE)
		Explode(tower, SFX.NONE)
		Explode(nuke, SFX.NONE)
		return 1
	elseif (severity <= .5) then
		Explode(base, SFX.NONE)
		Explode(tube, SFX.SHATTER)
		Explode(doorl, SFX.FALL)
		Explode(doorr, SFX.FALL)
		Explode(tower, SFX.NONE)
		Explode(nuke, SFX.NONE)
		return 1
	else
		Explode(base, SFX.NONE)
		Explode(tube, SFX.SHATTER)
		Explode(doorl, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(doorr, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(tower, SFX.NONE)
		Explode(nuke, SFX.NONE)
		return 2
	end
end
