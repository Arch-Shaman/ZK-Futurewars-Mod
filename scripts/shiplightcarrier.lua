local base = piece('Base')
local ship = piece('Ship')
local drone1 = piece('Drone1')
local drone2 = piece('Drone2')
local drone3 = piece('Drone3')
local drone4 = piece('Drone4')
local drone5 = piece('Drone5')
local drone6 = piece('Drone6')
local wakeAftL = piece('WakeAftL')
local wakeAftR = piece('WakeAftR')
local wakeForeL = piece('WakeForeL')
local wakeForeR = piece('WakeForeR')
local wakeForeM = piece('WakeForeM')
local wakeForeML = piece('WakeForeML')
local wakeForeMR = piece('WakeForeMR')

-- Signal definitions
local SIG_AIM = 4
local SIG_MOVE = 1
-- local SIG_BANK = 8

local CurrentBank = 0

local function Wake()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while true do
		if not Spring.GetUnitIsCloaked(unitID) then
			EmitSfx(wakeAftL,   2)
			EmitSfx(wakeAftR,   2)
			EmitSfx(wakeForeL,  2)
			EmitSfx(wakeForeR,  2)
			EmitSfx(wakeForeM,  2)
			EmitSfx(wakeForeML, 2)
			EmitSfx(wakeForeMR, 2)
		end
		Sleep(150)
	end
end

-- local function Bank()
-- 	Signal(SIG_BANK)
-- 	SetSignalMask(SIG_BANK)
-- 	while true do
-- 		Turn(ship, z_axis, CurrentBank)
-- 		CurrentBank = CurrentBank * 0.95
-- 		Sleep(33)
-- 	end
-- end

function script.StartMoving()
	StartThread(Wake)
end

function script.StopMoving()
	Signal(SIG_MOVE)
end

-- function script.ChangeHeading(deltaHeading) 
-- 	CurrentBank = CurrentBank + deltaHeading
-- 	Spring.Echo(CurrentBank)
-- end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, { ship })
--	StartThread(Bank)
end

function script.QueryWeapon()
	return ship
end

function script.AimFromWeapon()
	return ship
end

function script.AimWeapon(num, heading, pitch)
	return true
end

function script.Killed()
	local severity = recentDamage/maxHealth
	Explode( body, SFX.SHATTER)
	if  severity <= 0.25  then
		return 1
	elseif  severity <= 0.50  then
		Explode(ship, SFX.FALL + SFX.SHATTER)
		return 1
	else
		Explode(ship, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT + SFX.SHATTER)
		return 2
	end
end
