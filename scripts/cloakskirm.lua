include "constants.lua"
local scriptReload = include("scriptReload.lua")

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
local gameSpeed = Game.gameSpeed
local RELOAD_TIME = (tonumber(WeaponDefs[UnitDefs[unitDefID].weapons[1].weaponDef].customParams["script_reload"]) or 3) * gameSpeed
local BIG_ROCKET_RELOAD = WeaponDefs[UnitDefs[unitDefID].weapons[2].weaponDef].reload
local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload

local SIG_Aim = 1
local SIG_Walk = 2
local lastfire = 0
local brocketNum = 1
local brocketFlares = {
	[1] = {query = brocketemit1, loaded = true, visual = brocket1},
	[2] = {query = brocketemit2, loaded = true, visual = brocket2},
	[3] = {query = brocketemit3, loaded = true, visual = brocket3},
}

local aimDelay = 5

-- future-proof running animation against balance tweaks
local runspeed = 20 * (UnitDefs[unitDefID].speed / 69)

local function GetSpeedMod()
	return (Spring.GetUnitRulesParam(unitID, "totalMoveSpeedChange") or 1)
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
	Turn(brocketemit1, x_axis, math.rad(-90))
	Turn(brocketemit2, x_axis, math.rad(-90))
	Turn(brocketemit3, x_axis, math.rad(-90))
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	scriptReload.SetupScriptReload(3, RELOAD_TIME)
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

function script.AimFromWeapon(num)
	if num == 1 then
		return brocketFlares[brocketNum].query
	elseif num == 2 then
		return rocketemit
	else
		return laseremit
	end
end

function script.QueryWeapon(num)
    if num == 1 then
		return brocketFlares[brocketNum].query
	elseif num == 2 then
	    return rocketemit
	else
	    return laseremit
	end
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_Aim)
	SetSignalMask(SIG_Aim)
	if num == 1 then
		return brocketFlares[brocketNum].loaded 
	end
	Turn (hips, x_axis, 0)
	Turn (turner, y_axis, heading, math.rad(420))
	if num == 2 then
	    Turn (lforearm, x_axis, math.rad(90), math.rad(210))
		Turn (lforearm, y_axis, math.rad(15), math.rad(60))
		Turn (gun, x_axis, math.rad(-30), math.rad(75))
		WaitForTurn(lforearm, y_axis)
	else
	    Turn (rforearm, x_axis, math.rad(-90), math.rad(420))
	end
	WaitForTurn (turner, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

local function ReloadBackpackRocketThread(num)
	scriptReload.GunStartReload(num)
	brocketFlares[num].loaded = false
	local piece = brocketFlares[num].visual
	local speed = 2 / (RELOAD_TIME / 60)
	EmitSfx(piece, 1024)
	Hide(piece)
	Move(piece, y_axis, -2, 1000)
	SleepAndUpdateReload(num, RELOAD_TIME / 2)
	Show(piece)
	Move(piece, y_axis, 0, speed)
	SleepAndUpdateReload(num, RELOAD_TIME / 2)
	brocketFlares[num].loaded = true
	if scriptReload.GunLoaded(num) then
		brocketNum = 1
	end
end

local function ReloadBigRocketThread()
	Hide (rocket)
	Move (rocket, y_axis, 12, 100)
	Sleep((BIG_ROCKET_RELOAD - 2) * 1000)
	Show(rocket)
	Move(rocket, y_axis, 0, 6)
end
	

function script.FireWeapon(num)
	if num == 1 then
		StartThread(ReloadBackpackRocketThread, brocketNum)
		brocketNum = brocketNum%3 + 1
	elseif num == 2 then -- BIG rocket
		EmitSfx (exhaust, 1024)
		StartThread(ReloadBigRocketThread)
	else
		lastfire = Spring.GetGameFrame()
	end
end

function script.BlockShot(num, targetID)
	if num == 1 then
		if not brocketFlares[brocketNum].loaded or Spring.GetGameFrame() - aimDelay > lastfire then return true end
		--[[if Spring.ValidUnitID(targetID)  then
			local distMult = (Spring.GetUnitSeparation(unitID, targetID) or 0)/450
			return GG.OverkillPrevention_CheckBlock(unitID, targetID, 280, 75 * distMult, 0.3, 0.1)
		end]]
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
