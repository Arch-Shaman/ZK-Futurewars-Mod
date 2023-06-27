include "constants.lua"

local hips = piece 'hips'
local chest = piece 'chest'
local rshoulder = piece 'rshoulder'
local lshoulder = piece 'lshoulder'
local rforearm = piece 'rforearm'
local lforearm = piece 'lforearm'
local gun = piece 'gun'
local rocket = piece 'rocket'
local rocketemit = piece 'rocketemit'
local exhaust = piece 'exhaust'
local turner = piece 'turner'
local laseremit = piece 'laseremit'
local brocket1 = piece 'brocket1'
local brocket2 = piece 'brocket2'
local brocket3 = piece 'brocket3'
local brocketemit1 = piece 'brocketemit1'
local brocketemit2 = piece 'brocketemit2'
local brocketemit3 = piece 'brocketemit3'

local thigh = {piece 'lthigh', piece 'rthigh'}
local shin = {piece 'lshin', piece 'rshin'}
local foot = {piece 'lfoot', piece 'rfoot'}
local knee = {piece 'lknee', piece 'rknee'}

local smokePiece = {chest, exhaust, rocketemit}
local RELOAD_PENALTY = tonumber(UnitDefs[unitDefID].customParams.reload_move_penalty)

local SIG_Aim = 1
local SIG_Walk = 2
local lastfire = 0
local shot0 = true
local shot1 = false
local shot2 = false

-- future-proof running animation against balance tweaks
local runspeed = 20 * (UnitDefs[unitDefID].speed / 69)

local aimBlocked = false

local function GetSpeedMod()
	return (Spring.GetUnitRulesParam(unitID, "totalMoveSpeedChange") or 1)
end

local function SetSelfSpeedMod(speedmod)
	if RELOAD_PENALTY == 1 then
		return
	end
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", speedmod)
	GG.UpdateUnitAttributes(unitID)
end

local function Walk()
	Signal(SIG_Walk)
	SetSignalMask(SIG_Walk)

	for i = 1, 2 do
		Turn (thigh[i], y_axis, 0, runspeed*0.15)
		Turn (thigh[i], z_axis, 0, runspeed*0.15)
	end

	local side = 1
	while true do
		local speedmod = GetSpeedMod()
		local truespeed = runspeed * speedmod

		Turn (shin[side], x_axis, math.rad(85), truespeed*0.28)
		Turn (foot[side], x_axis, math.rad(0), truespeed*0.25)
		Turn (thigh[side], x_axis, math.rad(-36), truespeed*0.16)
		Turn (thigh[3-side], x_axis, math.rad(36), truespeed*0.16)

		Move (hips, y_axis, 0, truespeed*0.8)
		WaitForMove (hips, y_axis)

		Turn (shin[side], x_axis, math.rad(10), truespeed*0.32)
		Turn (foot[side], x_axis, math.rad(-20), truespeed*0.25)
		Move (hips, y_axis, -1, truespeed*0.35)
		WaitForMove (hips, y_axis)

		Move (hips, y_axis, -2, truespeed*0.8)

		WaitForTurn (thigh[side], x_axis)

		side = 3 - side
	end
end

local function StopWalk()
	Signal(SIG_Walk)

	Move (hips, y_axis, 0, runspeed*0.5)

    for i = 1, 2 do
	    Turn (thigh[i], x_axis, 0, runspeed*0.2)
	    Turn (shin[i],  x_axis, 0, runspeed*0.2)
	    Turn (foot[i], x_axis, 0, runspeed*0.2)

	    Turn (thigh[i], y_axis, math.rad(0), runspeed*0.1)
	    Turn (thigh[i], z_axis, math.rad(0), runspeed*0.1)
	end
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(StopWalk)
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

local function RestoreAfterDelay()
	SetSignalMask(SIG_Aim)
	Sleep (2000)
	Turn (turner, y_axis, math.rad(0), math.rad(40))
	Turn (rforearm, x_axis, math.rad(0),  math.rad(45))
	Turn (lforearm, x_axis, math.rad(0), math.rad(45))
	Turn (lforearm, y_axis, math.rad(0), math.rad(30))
	Turn (gun, x_axis, math.rad(0), math.rad(30))
end

local function ReloadPenaltyAndAnimation()
	aimBlocked = true
	SetSelfSpeedMod(RELOAD_PENALTY)

	Sleep(200)
	Turn (turner, y_axis, 0, math.rad(200))

	Sleep(2300) -- 3.5 second reload so no point checking earlier.
	while true do
		local state = Spring.GetUnitWeaponState(unitID, 1, "reloadState")
		local gameFrame = Spring.GetGameFrame()
		if state - 32 < gameFrame then
			aimBlocked = false

			Sleep(500)
			SetSelfSpeedMod(1)
			RestoreAfterDelay()
			return
		end
		Sleep(340)
	end
end

function OnLoadGame()
	SetSelfSpeedMod(1)
end

function script.AimFromWeapon(num)
	return laseremit
end

function script.QueryWeapon(num)
    if num == 1 then
	    return rocketemit
	elseif num == 2 then
	    return laseremit
	elseif num == 3 and shot0 then
	    return brocketemit1
	elseif num == 3 and shot1 then
	    return brocketemit2
	elseif num == 3 and shot2 then
	    return brocketemit2
	end
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_Aim)
	SetSignalMask(SIG_Aim)

	if aimBlocked then
		return false
	end
    
	if num == 1 then
	    Turn (lforearm, x_axis, math.rad(90), math.rad(210))
		Turn (lforearm, y_axis, math.rad(15), math.rad(60))
		Turn (gun, x_axis, math.rad(-30), math.rad(75))
	end
	
    if num == 2 then
	    Turn (rforearm, x_axis, math.rad(-90), math.rad(420))
	end
	
	Turn (hips, x_axis, 0)
	Turn (turner, y_axis, heading, math.rad(420))

	WaitForTurn (turner, y_axis)

	StartThread(RestoreAfterDelay)

	return true
end

function script.FireWeapon(num)
	if num == 1 then
		EmitSfx (exhaust, 1024)
		Hide (rocket)
		Move (rocket, y_axis, 12, 100)
		Sleep(4000)
		Show (rocket)
		Move (rocket, y_axis, 0, 6)
	end
	if num == 2 then
		lastfire = Spring.GetGameFrame()
	end
	if num == 3 and shot0 then
	    Sleep(1)
		shot0 = false
		shot1 = true
		Move (brocket1, y_axis, -2, 1000)
		Sleep(3000)
		Move (brocket1, y_axis, 0, 2)
	elseif num == 3 and shot1 then
	    Sleep(1)
		shot1 = false
		shot2 = true
		Move (brocket2, y_axis, -2, 1000)
		Sleep(3000)
		Move (brocket2, y_axis, 0, 2)
	elseif num == 3 and shot2 then
	    Sleep(1)
		shot2 = false
		shot0 = true
		Move (brocket3, y_axis, -2, 1000)
		Sleep(3000)
		Move (brocket3, y_axis, 0, 2)
	end
	--StartThread(ReloadPenaltyAndAnimation)
end

function script.BlockShot(num, targetID)
	if Spring.ValidUnitID(targetID) and num == 1 then
		if Spring.GetGameFrame() - 10 > lastfire then -- should have fired targeting laser before.
			return true
		end 
		local distMult = (Spring.GetUnitSeparation(unitID, targetID) or 0)/450
		return GG.OverkillPrevention_CheckBlock(unitID, targetID, 280, 75 * distMult, 0.3, 0.1)
	end
	return false
end

local explodables = {hips, thigh[2], foot[1], shin[2], knee[1]}
function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth

	for i = 1, #explodables do
		if math.random() < severity then
			Explode (explodables[i], SFX.FALL + SFX.SMOKE + SFX.FIRE)
		end
	end

	if (severity < 0.5) then
		return 1
	else
		Explode (chest, SFX.SHATTER)
		return 2
	end
end
