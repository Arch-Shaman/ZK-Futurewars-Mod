include "constants.lua"

local base = piece('base')
local turret = piece('turret')
local spinner = piece('spinner')

local CMD_STOP = CMD.STOP
local x, y, z
local active = true
local spinning = false
local waveWeaponDef = WeaponDefNames["turretdecloak_decloak"]
local WAVE_RELOAD = math.floor(waveWeaponDef.reload * Game.gameSpeed)
local WAVE_TIMEOUT = math.ceil(waveWeaponDef.damageAreaOfEffect / waveWeaponDef.explosionSpeed)* (1000 / Game.gameSpeed) + 200
local spGetUnitWeaponState = Spring.GetUnitWeaponState
local spSetUnitWeaponState = Spring.SetUnitWeaponState
local spGetGameFrame = Spring.GetGameFrame
local spGetUnitRulesParam = Spring.GetUnitRulesParam

--[[local function ScannerLoop()
	local index = 0
	while true do
		while (not active) or Spring.GetUnitIsStunned(unitID) do
			Sleep(300)
		end
		index = index + 1
		if index == 5 then
			index = 0
			EmitSfx(spinner, 1024)
		end
		Sleep(1000)
	end
end]]

local function StopSpinning()
	StopSpin(turret, y_axis, 0.5)
	GG.StopMiscPriorityResourcing(unitID, 1)
	--StopSpin(spinner, x_axis, 0.5)
	spinning = false
end

local function Stop()
	StopSpinning()
	active = false -- stop go thread
end

local function StartSpinning()
	--Spin(spinner, x_axis, 1.0, 0.5)
	spinning = true
	Spin(turret, y_axis, 6.0, 0.5)
	GG.StartMiscPriorityResourcing(unitID, 16, true, 1)
end

local function Go()
	while active do
		Sleep(100)
		local reloaded = select(2, spGetUnitWeaponState(unitID,1))
		local powered = not (spGetUnitRulesParam(unitID, "lowpower") == 1)
		if not powered and spinning then
			StopSpinning()
		elseif powered and not spinning then
			StartSpinning()
		end
		if reloaded then
			local gameFrame = spGetGameFrame()
			local reloadMult = spGetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1.0
			local reloadFrame = gameFrame + WAVE_RELOAD / reloadMult
			for i = 1, 3 do
				Sleep((1000/Game.gameSpeed) * 10)
				while (not active) or not spinning do
					Sleep(100)
				end
				EmitSfx(spinner, 4096)
			end
			spSetUnitWeaponState(unitID, 1, {reloadFrame = reloadFrame})
		end
	end
end

function script.Create()
	GG.StopMiscPriorityResourcing(unitID, 1)
	StartThread(GG.Script.SmokeUnit, unitID, {turret})
	--StartThread(ScannerLoop)
end

function script.Activate()
	active = true
	StartThread(Go)
end

function script.Deactivate()
	Stop()
end

function script.QueryWeapon(num)
	return spinner
end

function script.AimWeapon(num)
	return active -- always allow it to fire its decloaker
end

function Killed(recentDamage, maxHealth)
	active = false
	local severity = recentDamage / maxHealth
	if  severity <= .5 then
		corpsetype = 1
		Explode(base, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(spinner, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		return 1
	else
		Explode(base, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(turret, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(spinner, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		return 2
	end
end

function script.Killed(recentDamage, maxHealth)
	active = false
	GG.Script.DelayTrueDeath(unitID, unitDefID, recentDamage, maxHealth, Killed, WAVE_TIMEOUT)
end
