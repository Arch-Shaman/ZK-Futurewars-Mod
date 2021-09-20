include "constants.lua"

local base, nano, guns, doors, turret, shovel = piece ('base', 'nano', 'guns', 'doors', 'turret', 'shovel')
local reloads = {[1] = 0, [2] = 0}
local graceperiod = 3
local reloadframes = {
	[0] = 30,
	[1] = 30,
	[2] = 26,
	[3] = 23,
	[4] = 20,
	[5] = 19,
	[6] = 17,
	[7] = 16,
	[8] = 15,
	[9] = 14,
	[10] = 13,
	[11] = 12,
	[12] = 11,
	[13] = 11,
	[14] = 10,
	[15] = 10,
	[16] = 9,
	[17] = 9,
	[18] = 8,
	[19] = 8,
	[20] = 7,
	[21] = 7,
	[22] = 6,
	[23] = 6,
	[24] = 5,
	[25] = 5,
	[26] = 4,
	[27] = 4,
	[28] = 3,
	[29] = 3,
	[30] = 2,
	[31] = 2,
	[32] = 1,
}
local maxreloads = 32
local lastfire = {[1] = 0, [2] = 0}

-- Construction

local nanos = { piece 'nano1', piece 'nano2' }
local SIG_BUILD = 1

function script.StartBuilding(heading)
	Signal (SIG_BUILD)
	Turn (doors, x_axis, math.rad(-100), math.rad(200))
	Move (nano, z_axis, 3, 12)
	Spring.SetUnitCOBValue(unitID, COB.INBUILDSTANCE, 1)
end

function script.StopBuilding()
	Spring.SetUnitCOBValue(unitID, COB.INBUILDSTANCE, 0)
	SetSignalMask (SIG_BUILD)
	Sleep (5000)
	Turn (doors, x_axis, 0, math.rad(200))
	Move (nano, z_axis, 0, 12)
end

local current_nano = 1
function script.QueryNanoPiece()
	current_nano = 3 - current_nano
	GG.LUPS.QueryNanoPiece(unitID,unitDefID,Spring.GetUnitTeam(unitID), nanos[current_nano])
	return nanos[current_nano]
end

-- Weaponry

local function ReloadSetterThread()
	local lastreload = {[1] = 0, [2] = 0}
	while true do
		if lastreload[1] ~= reloads[1] then
			Spring.SetUnitWeaponState(unitID, 1, "reloadTime", reloadframes[reloads[1]]/30)
		end
		if lastreload[2] ~= reloads[2] then
			Spring.SetUnitWeaponState(unitID, 2, "reloadTime", reloadframes[reloads[2]]/30)
		end
		Sleep(66)
	end
end

local function ReloadSpeedControlThread(num)
	local currentframe
	while true do
		Sleep(33)
		currentframe = Spring.GetGameFrame()
		if reloads ~= 0 then
			if lastfire[num] == currentframe then
				Sleep(graceperiod * (1000 / Game.gameSpeed))
			else
				if lastfire[num] + (graceperiod * 30) <= currentframe then
					reloads[num] = reloads[num] - 1
					if reloads[num] < 0 then -- safety.
						reloads[num] = 0
					end
					Sleep(33 * 4)
				end
			end
		end
	end
end
	

local flares = { piece 'flare1', piece 'flare2' }
local current_flare = 1
local SIG_AIM = 2

local function RestoreAfterDelay()
	SetSignalMask(SIG_AIM)

	Sleep(5000)

	Turn(turret, y_axis, 0, math.rad(15))
	Turn(guns,   x_axis, 0, math.rad(15))
end

function script.QueryWeapon(num)
	return flares[num]
end

function script.AimFromWeapon(num)
	return turret
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)

	Turn(turret, y_axis, heading, math.rad(450))
	Turn(guns,   x_axis,  -pitch, math.rad(150))

	WaitForTurn(turret, y_axis)
	WaitForTurn(guns, x_axis)
	StartThread(RestoreAfterDelay)

	return true
end

function script.FireWeapon(num)
	EmitSfx(flares[num], 1024)
	if reloads[num] < maxreloads then
		reloads[num] = reloads[num] + 1
		lastfire[num] = Spring.GetGameFrame()
	end
end

function script.BlockShot(num)
	if reloads[num] > 30 then
		return false
	end
	return Spring.GetGameFrame() == lastfire[3 - num]
end

-- EndBurst doesn't seem to fix friendlyfire on units with high-RoF

-- Misc

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, {base})
	Spring.SetUnitNanoPieces(unitID, nanos)
	StartThread(ReloadSetterThread)
	StartThread(ReloadSpeedControlThread, 1)
	StartThread(ReloadSpeedControlThread, 2)
end

local explodables = { turret, guns, shovel }
function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	local brutal = (severity > 0.5)

	for i = 1, #explodables do
		if math.random() < severity then
			Explode (explodables[i], SFX.FALL + (brutal and (SFX.SMOKE + SFX.FIRE) or 0))
		end
	end

	if not brutal then
		return 1
	else
		Explode (base, SFX.SHATTER)
		return 2
	end
end
