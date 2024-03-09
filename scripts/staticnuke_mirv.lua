local base = piece 'Base'
local hatch = piece 'Hatch'
local door1 = piece 'Door1'
local door2 = piece 'Door2'
local door3 = piece 'Door3'
local door4 = piece 'Door4'
local launcher = piece 'Launcher'
local missile = piece 'Missile'
local emit1 = piece 'Emit1'
local mirv1 = piece 'MirvDoor1'
local mirv2 = piece 'MirvDoor2'
local mirv3 = piece 'MirvDoor3'

include "constants.lua"

local openingDoors = false
local doorsAreOpen = false
local closingDoors = false
local missileLoaded = false
local priming = false
local mystock = 0

-- Signal definitions
local SIG_AIM = 1
local SIG_DOORS = 4

local function ShowMissile()
	Show(missile)
	Show(mirv1)
	Show(mirv2)
	Show(mirv3)
end

local function HideMissile()
	Hide(missile)
	Hide(mirv1)
	Hide(mirv2)
	Hide(mirv3)
end

local function CloseHatch()
	Signal(SIG_DOORS)
	SetSignalMask(SIG_DOORS)
	closingDoors = true
	Move(door1, x_axis, -0.082177, 3.0310885)
	Move(door1, y_axis, 0.39754, 3.29252)
	Move(door1, z_axis, 0.095061, 1.2714305)
	Move(door2, x_axis, 0, 2.99)
	Move(door2, y_axis, 0.39754, 3.29252)
	Move(door2, z_axis, 0.082242, 1.265021)
	Move(door3, x_axis, -0.082177, 3.0310885)
	Move(door3, y_axis, 0.397554, 3.292527)
	Move(door3, z_axis, 0.082242, 1.265001)
	Move(door4, x_axis, -0.094997, 3.0462515)
	Move(door4, y_axis, 0.095061, 3.0375305)
	Move(door4, z_axis, 0.39754, 1.42265)
	Sleep(2100)
	closingDoors = false
	doorsAreOpen = false
end

local function ResetNukePosition()
	Move(missile, z_axis, 0, 12.61) --37.83
	Move(launcher, z_axis, 0, 14.97) --44.91
end

local function MoveNukeToPosition()
	Move(missile, z_axis, 37.83, 12.61)
	Move(launcher, z_axis, 44.91, 14.97)
	WaitForMove(launcher, z_axis)
	missileLoaded = true
	priming = false
end

local function OpenHatch()
	Signal(SIG_DOORS)
	SetSignalMask(SIG_DOORS)
	openingDoors = true
	Move(door1, x_axis, 5.98, 3.0310885)
	Move(door1, y_axis, -6.1875, 3.29252)
	Move(door1, z_axis, -2.4478, 1.2714305)
	Move(door2, x_axis, -5.98, 2.99) -- target 2s
	Move(door2, y_axis, 6.1875, 3.29252)
	Move(door2, z_axis, -2.4478, 1.265021)
	Move(door3, x_axis, 5.98, 3.0310885)
	Move(door3, y_axis, 6.1875, 3.292527)
	Move(door3, z_axis, -2.44776, 1.265001)
	Move(door4, x_axis, -6.1875, 3.0462515)
	Move(door4, y_axis, -5.98, 3.0375305)
	Move(door4, z_axis, -2.44776, 1.42265)
	Sleep(2100)
	doorsAreOpen = true
	openingDoors = false
end

local function PrimeNuke()
	priming = true
	ShowMissile()
	StartThread(OpenHatch)
	while not doorsAreOpen do
		Sleep(100)
	end
	StartThread(MoveNukeToPosition)
end

local function FireNukeThread()
	HideMissile()
	Sleep(4000)
	ResetNukePosition()
	Sleep(3000)
	StartThread(CloseHatch)
	while doorsAreOpen do
		Sleep(100)
	end
	missileLoaded = false
	if mystock > 0 then -- we still have ammo
		priming = true
		StartThread(PrimeNuke)
	end
end


function StockpileChanged(newStock)
	mystock = newStock
	if newStock <= 0 then
		return
	end
	if not missileLoaded and not priming then
		priming = true
		StartThread(PrimeNuke)
	end
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, {hatch, base})
	HideMissile()
end

function script.AimWeapon(num, heading, pitch)
	if (not missileLoaded) or mystock == 0 then return false end
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	if not priming and not doorsAreOpen and not missileLoaded and mystock > 0 then
		StartThread(PrimeNuke)
	end
	while not doorsAreOpen do
		Sleep(25)
	end
	return true
end

function script.FireWeapon()
	StartThread(FireNukeThread)
	if GG.GameRules_NukeLaunched then
		GG.GameRules_NukeLaunched(unitID)
	end
	
	-- Intentionally non-positional
	Spring.PlaySoundFile("sounds/weapon/missile/heavymissile_launch.wav", 15, "battle")
end

function script.QueryWeapon()
	return emit1
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
	local explodeOnHit = SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT
	Explode(base, SFX.NONE)
	if severity >= 0.5 then
		Explode(door1, explodeOnHit)
		Explode(door2, explodeOnHit)
		Explode(door3, explodeOnHit)
		Explode(door4, explodeOnHit)
		Explode(launcher, explodeOnHit)
		return 2
	else
		return 1
	end
end
