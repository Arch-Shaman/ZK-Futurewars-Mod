local centre = piece 'centre'
local turner = piece 'turner'
local chest = piece 'chest'
local head = piece 'head'
local emitter = piece 'emitter'
local hips = piece 'hips'
local lthigh = piece 'lthigh'
local rthigh = piece 'rthigh'
local lforearm = piece 'lforearm'
local rforearm = piece 'rforearm'
local rshoulder = piece 'rshoulder'
local lshoulder = piece 'lshoulder'
local rshin = piece 'rshin'
local rfoot = piece 'rfoot'
local lshin = piece 'lshin'
local lfoot = piece 'lfoot'
local spear = piece 'spear'
local shield = piece 'shield'
local lshield1 = piece 'lshield1'
local lshield2 = piece 'lshield2'
local ushield1 = piece 'ushield1'
local ushield2 = piece 'ushield2'
--linear constant=65536

include "constants.lua"

local smokePiece = {chest}
local armorValue = UnitDefs[unitDefID].armoredMultiple

--how do you get random() to work???--
--local hitshield = {
    --[1] = {firepoint = shield},
	--[2] = {firepoint = ushield1},
	--[3] = {firepoint = lshield1},
	--[4] = {firepoint = ushield2},
	--[5] = {firepoint = lshield2},
--}

local aiming = false
local shooting = false
local walking = false
local shielding = false

-- Signal definitions
local SIG_MOVE = 1
local SIG_RESTORE = 2
local SIG_AIM = 4
local SIG_STOPMOVE = 8
local SIG_SHIELD = 16

local RESTORE_DELAY = 3000

-- future-proof running animation against balance tweaks
local runspeed = 1.8 * (UnitDefs[unitDefID].speed / 51)

local hangtime = 32
local steptime = 10
local stride_top = 0
local stride_bottom = -2

local spGetUnitRulesParam = Spring.GetUnitRulesParam
local function GetSpeedMod()
	return (spGetUnitRulesParam(unitID, "totalMoveSpeedChange") or 1)
end

local function walk()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
    
	if not shielding then
	    Turn(rforearm, x_axis, math.rad(-15), 0.5)
	end
	
	while true do
		local truespeed = runspeed * GetSpeedMod()
		Turn(rthigh, x_axis, -0.65, truespeed*1)
		Turn(rshin, x_axis, 0.8, truespeed*1)
		Turn(rfoot, x_axis, 0, truespeed*0.5)

		Turn(lshin, x_axis, 0.4, truespeed*0.5)
		Turn(lthigh, x_axis, 0.5, truespeed*1)
		Turn(lfoot, x_axis, -0.3, truespeed*1)

	    Move(hips, y_axis, stride_top, truespeed*3)
		
		if not shielding then
		    Turn(rshoulder, x_axis, math.rad(15), truespeed*0.5)
		    if not aiming then
			    Move(chest, y_axis, -0.15, truespeed*1)
			    Turn(chest, y_axis, math.rad(-15), truespeed*0.5)
			    Turn(head, z_axis, math.rad(15), truespeed*0.5)
		    end
        end
		WaitForMove(hips, y_axis)

		Move(hips, y_axis, stride_bottom, truespeed*1)

		Sleep(hangtime)

		Move(hips, y_axis, stride_bottom, truespeed*3)
		Turn(rshin, x_axis, 0.0, truespeed*0.75)
		Turn(rfoot, x_axis, -0.2, truespeed*0.5)
		Turn(lshin, x_axis, 0.6, truespeed*0.75)
		Turn(lfoot, x_axis, -0.0, truespeed*1)
		
		if not shielding then
		    Turn(rshoulder, x_axis, math.rad(0), truespeed*0.5)
			if not aiming then
			    Move(chest, y_axis, 0, truespeed*1)
			    Turn(chest, y_axis, math.rad(0), truespeed*0.5)
			    Turn(head, z_axis, math.rad(0), truespeed*0.5)
		    end
        end

		WaitForTurn(rthigh, x_axis)

		Sleep(steptime)

		truespeed = runspeed * GetSpeedMod() -- again because it might've changed during sleep

		Turn(lthigh, x_axis, -0.65, truespeed*1)
		Turn(lshin, x_axis, 0.8, truespeed*1)
		Turn(lfoot, x_axis, 0, truespeed*0.5)

		Turn(rshin, x_axis, 0.4, truespeed*0.5)
		Turn(rthigh, x_axis, 0.5, truespeed*1)
		Turn(rfoot, x_axis, -0.3, truespeed*1)

		Move(hips, y_axis, stride_top, truespeed*3)
		
		if not shielding then
		    Turn(rshoulder, x_axis, math.rad(-15), truespeed*0.5)
			if not aiming then
			    Move(chest, y_axis, -0.15, truespeed*1)
			    Turn(chest, y_axis, math.rad(15), truespeed*0.5)
			    Turn(head, z_axis, math.rad(-15), truespeed*0.5)
		    end
        end

		WaitForMove(hips, y_axis)

		Move(hips, y_axis, stride_bottom, truespeed*1)

		Sleep(hangtime)

		Move(hips, y_axis, stride_bottom, truespeed*3)
		Turn(lshin, x_axis, 0.0, truespeed*0.75)
		Turn(lfoot, x_axis, -0.2, truespeed*0.5)
		Turn(rshin, x_axis, 0.6, truespeed*0.75)
		Turn(rfoot, x_axis, -0.0, truespeed*1)
		
		if not shielding then
		    Turn(rshoulder, x_axis, math.rad(0), truespeed*0.5)
		    if not aiming then
			    Move(chest, y_axis, 0, truespeed*1)
			    Turn(chest, y_axis, math.rad(0), truespeed*0.5)
			    Turn(head, z_axis, math.rad(0), truespeed*0.5)
		    end
        end

		WaitForTurn(lthigh, x_axis)

		Sleep(steptime)
	end
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	Turn(lshoulder, x_axis, math.rad(-15), 15)
	Turn(lshoulder, z_axis, math.rad(30), 30)
	Turn(lforearm, x_axis, math.rad(-15), 15)
end

function script.BlockShot(num, targetID)
	return GG.OverkillPrevention_CheckBlock(unitID, targetID, 450.1, 70, 0.1, 0.2) -- unitID, targetID, gameFrame, damage, timeout, fastmult, radarmult, staticonly
end

function script.StartMoving()
	Signal(SIG_STOPMOVE)
	if walking == false then

		walking = true
		StartThread(walk)
	end
end

local function StopMovingThread()
	
	Signal(SIG_STOPMOVE)
	SetSignalMask(SIG_STOPMOVE)
	Sleep(33)
	
	walking = false
	Signal(SIG_MOVE)

	Turn(hips, z_axis, 0, math.rad(60.0))
	Move(hips, y_axis, 0, 8.0)
	Turn(rthigh, x_axis, 0, math.rad(120.000000))
	Turn(rshin, x_axis, 0, math.rad(240.000000))
	Turn(rfoot, x_axis, 0, math.rad(120.000000))
	Turn(lthigh, x_axis, 0, math.rad(120.000000))
	Turn(lshin, x_axis, 0, math.rad(240.000000))
	Turn(lfoot, x_axis, 0, math.rad(120.000000))
	
	if not aiming and not shielding then
		Move(chest, y_axis, 0, 8.0)
		Turn(chest, y_axis, 0, math.rad(120.000000))
		Turn(head, z_axis, 0, math.rad(120.000000))
		Turn(rshoulder, x_axis, 0, math.rad(120.000000))
		Turn(rforearm, x_axis, 0, math.rad(120.000000))
		Turn(lshoulder, x_axis, math.rad(-15), 15)
	    Turn(lshoulder, z_axis, math.rad(30), 30)
		Turn(lforearm, x_axis, math.rad(-15), 15)
	end
end

function script.StopMoving()
	StartThread(StopMovingThread)
end

local function RestoreAfterDelay()
	Signal(SIG_RESTORE)
	SetSignalMask(SIG_RESTORE)
	
	Sleep(RESTORE_DELAY)
	if not shielding then
	    Turn(turner, y_axis, 0, math.rad(90))
	    Turn(chest, y_axis, 0, math.rad(90))
	    Turn(chest, x_axis, 0, math.rad(45))
	    Turn(head, z_axis, 0, math.rad(90))
	    Turn(lshoulder, x_axis, math.rad(-15), 3)
	    Turn(lshoulder, z_axis, math.rad(30), 3)
	    Turn(lforearm, x_axis, math.rad(-15), 3)
	    Turn(lforearm, z_axis, math.rad(0), 3)
	    WaitForTurn(chest, y_axis)
	    WaitForTurn(chest, x_axis)
	    aiming = false
	elseif shielding then
	    Turn(turner, y_axis, math.rad(0), math.rad(150))
	    Turn(chest, y_axis, math.rad(45), math.rad(150))
		Turn(chest, x_axis, math.rad(0), math.rad(150))
	    Turn(head, z_axis, math.rad(-45), math.rad(150))
	    Turn(lshoulder, x_axis, math.rad(0), math.rad(150))
	    Turn(lshoulder, z_axis, math.rad(0), math.rad(150))
	    Turn(lforearm, x_axis, math.rad(-90), math.rad(150))
	    Turn(lforearm, z_axis, math.rad(-45), math.rad(150))
		WaitForTurn(chest, y_axis)
	    WaitForTurn(chest, x_axis)
		aiming = false
	end
end

function script.AimFromWeapon()
	return hips
end

function script.QueryWeapon()
	return emitter
end

local function ShieldActivate()
    Signal(SIG_SHIELD)
	SetSignalMask(SIG_SHIELD)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 0.5)
	GG.UpdateUnitAttributes(unitID)
	GG.SetUnitArmor(unitID, armorValue)
	shielding = true
	Turn(rshoulder, x_axis, math.rad(0), 6)
	Turn(rforearm, x_axis, math.rad(-90), 9)
	Turn(rforearm, z_axis, math.rad(45), 6)
	if not aiming then
	    Turn(turner, y_axis, math.rad(0), math.rad(150))
	    Turn(chest, y_axis, math.rad(45), math.rad(150))
	    Turn(head, z_axis, math.rad(-45), math.rad(150))
	    Turn(lshoulder, x_axis, math.rad(0), math.rad(150))
	    Turn(lshoulder, z_axis, math.rad(0), math.rad(150))
	    Turn(lforearm, x_axis, math.rad(-90), math.rad(150))
	    Turn(lforearm, z_axis, math.rad(-45), math.rad(150))
	end
	WaitForTurn(rforearm, x_axis)
	WaitForTurn(rforearm, z_axis)
	Move(lshield1, z_axis, -10, 50)
	Move(ushield1, z_axis, 10, 50)
	WaitForMove(lshield1, z_axis)
	WaitForMove(ushield1, z_axis)
	Move(lshield2, z_axis, -10, 50)
	Move(ushield2, z_axis, 10, 50)
end

local function ShieldDeactivate()
    Signal(SIG_SHIELD)
	SetSignalMask(SIG_SHIELD)
	Move(lshield2, z_axis, 0, 25)
	Move(ushield2, z_axis, 0, 25)
	WaitForMove(lshield2, z_axis)
	WaitForMove(ushield2, z_axis)
	Move(lshield1, z_axis, 0, 25)
	Move(ushield1, z_axis, 0, 25)
	WaitForMove(lshield1, z_axis)
	WaitForMove(ushield1, z_axis)
    Turn(rshoulder, x_axis, math.rad(0), 3)
	Turn(rforearm, x_axis, math.rad(0), 6)
	Turn(rforearm, z_axis, math.rad(0), 3)
	if not aiming then
	    Turn(turner, y_axis, 0, math.rad(90))
	    Turn(chest, y_axis, 0, math.rad(90))
	    Turn(chest, x_axis, 0, math.rad(45))
	    Turn(head, z_axis, 0, math.rad(90))
	    Turn(lshoulder, x_axis, math.rad(-15), 3)
	    Turn(lshoulder, z_axis, math.rad(30), 3)
	    Turn(lforearm, x_axis, math.rad(-15), 3)
	    Turn(lforearm, z_axis, math.rad(0), 3)
    end
	WaitForTurn(rforearm, x_axis)
	WaitForTurn(rforearm, z_axis)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	GG.UpdateUnitAttributes(unitID)
	GG.SetUnitArmor(unitID, 1)
    shielding = false
end

function script.Activate()
	StartThread(ShieldActivate)
end

function script.Deactivate()
	StartThread(ShieldDeactivate)
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	StartThread(RestoreAfterDelay)
	aiming = true
	
	if not shooting then
	    Turn(turner, y_axis, math.rad(0), math.rad(300))
	    Turn(chest, y_axis, heading+math.rad(45), math.rad(300))
	    Turn(chest, x_axis, -pitch, math.rad(120))
	    Turn(head, z_axis, math.rad(-45), math.rad(300))
	    Turn(lshoulder, x_axis, math.rad(0), math.rad(300))
	    Turn(lshoulder, z_axis, math.rad(0), math.rad(300))
	    Turn(lforearm, x_axis, math.rad(-90), math.rad(300))
	    Turn(lforearm, z_axis, math.rad(-45), math.rad(300))
	    WaitForTurn(chest, y_axis)
	    WaitForTurn(chest, x_axis)
	    WaitForTurn(lforearm, x_axis)
	    WaitForTurn(lforearm, z_axis)
	    return true
	else
	    return false
	end
end

function script.FireWeapon()
    shooting = true
	EmitSfx(emitter, GG.Script.UNIT_SFX1)
	EmitSfx(emitter, GG.Script.UNIT_SFX1)
	Turn(turner, y_axis, math.rad(-90), math.rad(600))
	Turn(head, z_axis, math.rad(45), math.rad(600))
	Turn(lforearm, z_axis, math.rad(45), math.rad(600))
	Sleep(1000)
	shooting = false
end

function script.HitByWeapon()
    if shielding then
        --EmitSfx(hitshield[random(1,5)].firepoint, GG.Script.UNIT_SFX1)
	    EmitSfx(shield, GG.Script.UNIT_SFX1)
	end
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if (severity <= .25) then
		Explode(lfoot, SFX.NONE)
		Explode(lshin, SFX.NONE)
		Explode(lshoulder, SFX.NONE)
		Explode(lthigh, SFX.NONE)
		Explode(lforearm, SFX.NONE)
		Explode(rfoot, SFX.NONE)
		Explode(rshin, SFX.NONE)
		Explode(rshoulder, SFX.NONE)
		Explode(rthigh, SFX.NONE)
		Explode(rforearm, SFX.NONE)
		Explode(chest, SFX.NONE)
		return 1 -- corpsetype
	elseif (severity <= .5) then
		Explode(lfoot, SFX.FALL)
		Explode(lshin, SFX.FALL)
		Explode(lshoulder, SFX.FALL)
		Explode(lthigh, SFX.FALL)
		Explode(lforearm, SFX.FALL)
		Explode(rfoot, SFX.FALL)
		Explode(rshin, SFX.FALL)
		Explode(rshoulder, SFX.FALL)
		Explode(rthigh, SFX.FALL)
		Explode(rforearm, SFX.FALL)
		Explode(chest, SFX.SHATTER)
		return 1 -- corpsetype
	elseif (severity <= 1) then
		Explode(lfoot, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(lshin, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(lshoulder, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(lthigh, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(lforearm, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(rfoot, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(rshin, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(rshoulder, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(rthigh, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(rforearm, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
		Explode(chest, SFX.SHATTER)
		return 2
	end
	Explode(lfoot, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(lshin, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(lshoulder, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(lthigh, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(lforearm, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(rfoot, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(rshin, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(rshoulder, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(rthigh, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(rforearm, SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT)
	Explode(chest, SFX.SHATTER, SFX.EXPLODE_ON_HIT)
	return 2
end