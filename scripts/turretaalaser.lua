include "constants.lua"
include "pieceControl.lua"

-- unused piece: 'base'
local body, aim = piece('body', 'aim')
local door1, door2, hinge1, hinge2 = piece('door1', 'door2', 'hinge1', 'hinge2')
local turret, launcher, firep1, firep2 = piece('turret', 'launcher', 'firep1', 'firep2')

local explodables1 = {turret, hinge1, hinge2} -- not visible on wreck so we can throw these
local explodables2 = {door2, door1, launcher}
local smokePiece = { body, turret }
local armorValue = UnitDefs[unitDefID].armoredMultiple
local gun = false
local closed = true
local stuns = {false, false, false}
local disarmed = false
local currentTask = 0
local openrate = math.rad(275*6)

local SigAim = 1

local spGetUnitHealth = Spring.GetUnitHealth
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitIsStunned = Spring.GetUnitIsStunned
local spSetUnitHealth = Spring.SetUnitHealth
local BUNKERED_AUTOHEAL = tonumber (UnitDef.customParams.armored_regen or 20) / 2 -- applied every 0.5s

local function ArmoredThread()
	local stunned_or_inbuild = false
	while closed do
		stunned_or_inbuild = spGetUnitIsStunned(unitID) or (spGetUnitRulesParam(unitID, "disarmed") == 1)
		if not stunned_or_inbuild then
			local hp = spGetUnitHealth(unitID)
			local slowMult = (spGetUnitRulesParam(unitID,"baseSpeedMult") or 1)
			if hp then
				local newHp = hp + slowMult*BUNKERED_AUTOHEAL
				spSetUnitHealth(unitID, newHp)
			end
		end
		Sleep(500)
	end
end

local function Close ()
	currentTask = 1
	if disarmed then return end
	closed = true

	Turn (launcher, x_axis, 0, math.rad(90))
	Move (turret, y_axis, -13.5, 15)
	WaitForMove (turret, y_axis)
	if disarmed then return	end

	Turn (door1, z_axis, math.rad(150),math.rad(125))
	Turn (door2, z_axis, -math.rad(150),math.rad(125))
	WaitForTurn (door1, z_axis)
	if disarmed then return	end

	currentTask = 0
	GG.SetUnitArmor(unitID, armorValue)
	StartThread(ArmoredThread)
end

local function RestoreAfterDelay()
	Sleep (1500)
	Close()
end

local function Open ()
	StartThread (RestoreAfterDelay)
	if not closed then return end
	currentTask = 2
	GG.SetUnitArmor(unitID, 1.0)

	Turn (door1, z_axis, 0, openrate)
	Turn (door2, z_axis, 0, openrate)
	WaitForTurn (door1, z_axis)

	if disarmed then return	end
	Move (turret, y_axis, 0, 200)
	WaitForMove (turret, y_axis)

	if disarmed then return	end
	currentTask = 0
	closed = false
end

local function StunThread ()
	disarmed = true
	Signal (SigAim)

	-- GG.PieceControl.StopMove (turret, y_axis) -- seems gebork
	GG.PieceControl.StopTurn (turret, y_axis)
	GG.PieceControl.StopTurn (launcher, x_axis)
	GG.PieceControl.StopTurn (door1, z_axis)
	GG.PieceControl.StopTurn (door2, z_axis)
end

local function UnstunThread ()
	SetSignalMask (SigAim)
	disarmed = false
	if currentTask == 1 then
		Close()
	elseif currentTask == 2 then
		Open()
	else
		RestoreAfterDelay()
	end
end

function Stunned (stun_type)
	stuns[stun_type] = true
	StartThread (StunThread)
end
function Unstunned (stun_type)
	stuns[stun_type] = false
	if not stuns[1] and not stuns[2] and not stuns[3] then
		StartThread (UnstunThread)
	end
end

function script.Create()
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
	while (select(5, Spring.GetUnitHealth(unitID)) < 1) do
		Sleep (1000)
	end
	SetSignalMask (SigAim)
	RestoreAfterDelay()
end

function script.QueryWeapon() return gun and firep1 or firep2 end
function script.AimFromWeapon() return aim end

local aimspeed = math.rad(720)

function script.AimWeapon (num, heading, pitch)

	if disarmed and closed then return false end -- prevents slowpoke.jpg (when it opens up after stun wears off even if target is long gone)

	Signal (SigAim)
	SetSignalMask (SigAim)

	while disarmed do
		Sleep (34)
	end

	StartThread (Open)
	while closed do
		Sleep (34)
	end

	local slowMult = (Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1)
	Turn (turret, y_axis, heading, aimspeed*slowMult)
	Turn (launcher, x_axis, -pitch, (aimspeed/2)*slowMult)

	WaitForTurn (turret, y_axis)
	WaitForTurn (launcher, x_axis)

	return true
end

function script.FireWeapon ()
	EmitSfx (gun and firep1 or firep2, 1024)
end

function script.EndBurst()
	gun = not gun
end

function script.Killed (recentDamage, maxHealth)
	local severity = recentDamage / maxHealth

	for i = 1, #explodables1 do
		if (math.random() < severity) then
			Explode (explodables1[i], SFX.SMOKE + SFX.FIRE)
		end
	end

	if (severity <= .5) then
		return 1
	else
		Explode (body, SFX.SHATTER)
		for i = 1, #explodables2 do
			if (math.random() < severity) then
				Explode (explodables2[i], SFX.SMOKE + SFX.FIRE)
			end
		end
		return 2
	end
end
