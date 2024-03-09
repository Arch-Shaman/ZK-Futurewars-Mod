include 'constants.lua'
local scriptReload = include("scriptReload.lua")
include "pieceControl.lua"
--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

-- unused pieces: anteny, ozdoba

local cervena = piece 'cervena'
local modra = piece 'modra'
local zelena = piece 'zelena'
local spodni_zebra = piece 'spodni_zebra'
local vrchni_zebra = piece 'vrchni_zebra'
local trubky = piece 'trubky'

local solid_ground = piece 'solid_ground'
local gear = piece 'gear'
local plovak = piece 'plovak'
local gear001 = piece 'gear001'
local gear002 = piece 'gear002'
local rotating_bas = piece 'rotating_bas'
local mc_rocket_ho = piece 'mc_rocket_ho'
local raketa = piece 'raketa'
local raketa_l = piece 'raketa_l'
local raketa002 = piece 'raketa002'
local raketa002_l = piece 'raketa002_l'
local raketa004 = piece 'raketa004'
local raketa004_l = piece 'raketa004_l'
local raketa006 = piece 'raketa006'
local raketa006_l = piece 'raketa006_l'
local raketa007 = piece 'raketa007'
local raketa007_l = piece 'raketa007_l'
local raketa008 = piece 'raketa008'
local raketa008_l = piece 'raketa008_l'
local raketa009 = piece 'raketa009'
local raketa009_l = piece 'raketa009_l'
local raketa010 = piece 'raketa010'
local raketa010_l = piece 'raketa010_l'
local raketa011 = piece 'raketa011'
local raketa011_l = piece 'raketa011_l'
local raketa012 = piece 'raketa012'
local raketa012_l = piece 'raketa012_l'
local raketa013 = piece 'raketa013'
local raketa013_l = piece 'raketa013_l'
local raketa014 = piece 'raketa014'
local raketa014_l = piece 'raketa014_l'
local raketa026 = piece 'raketa026'
local raketa026_l = piece 'raketa026_l'
local raketa027 = piece 'raketa027'
local raketa027_l = piece 'raketa027_l'
local flare = piece 'flare_r'
local flare2 = piece 'flare_l'
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--local flares = { flare_l, flare_r }

local spGetUnitRulesParam = Spring.GetUnitRulesParam
local SleepAndUpdateReload = scriptReload.SleepAndUpdateReload
local gameSpeed = Game.gameSpeed

local shot = 0
local gun = {
	[0] = {firepoint = raketa014, loaded = true},
	[1] = {firepoint = raketa014_l, loaded = true},
	[2] = {firepoint = raketa013, loaded = true},
	[3] = {firepoint = raketa013_l, loaded = true},
	[4] = {firepoint = raketa012, loaded = true},
	[5] = {firepoint = raketa012_l, loaded = true},
	[6] = {firepoint = raketa011, loaded = true},
	[7] = {firepoint = raketa011_l, loaded = true},
	[8] = {firepoint = raketa010, loaded = true},
	[9] = {firepoint = raketa010_l, loaded = true},
	[10] = {firepoint = raketa009, loaded = true},
	[11] = {firepoint = raketa009_l, loaded = true},
	[12] = {firepoint = raketa008, loaded = true},
	[13] = {firepoint = raketa008_l, loaded = true},
	[14] = {firepoint = raketa007, loaded = true},
	[15] = {firepoint = raketa007_l, loaded = true},
	[16] = {firepoint = raketa006, loaded = true},
	[17] = {firepoint = raketa006_l, loaded = true},
	[18] = {firepoint = raketa004, loaded = true},
	[19] = {firepoint = raketa004_l, loaded = true},
	[20] = {firepoint = raketa002, loaded = true},
	[21] = {firepoint = raketa002_l, loaded = true},
	[22] = {firepoint = raketa, loaded = true},
	[23] = {firepoint = raketa_l, loaded = true},
	[24] = {firepoint = raketa026, loaded = true},
	[25] = {firepoint = raketa026_l, loaded = true},
	[26] = {firepoint = raketa027, loaded = true},
	[27] = {firepoint = raketa027_l, loaded = true},
}

--------------------------------------------------------------------------------
-- constants and variables
--------------------------------------------------------------------------------
local smokePiece = {rotating_bas, mc_rocket_ho}

local TURN_SPEED = 145
local TILT_SPEED = 200
local RELOAD_SPEED = 50
local MOV_DEL = 50

local idle = true
local disarmed = false
local doingRotation = false
local loaded = 23
local lastHeading = 0
local rotateWise = 1
local reloadtime = 14
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- signals
--------------------------------------------------------------------------------
local SIG_AIM = 1
local SIG_IDLE = 2
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function reload(num)
	Hide(gun[num].firepoint)
	scriptReload.GunStartReload(num)
	gun[num].loaded = false

	SleepAndUpdateReload(num, reloadtime * gameSpeed)
	if scriptReload.GunLoaded(num) then
		shot = 0
	end
	gun[num].loaded = true
	Show(gun[num].firepoint)
	loaded = loaded + 1
end

--------------------------------------------------------------------------------
-- Methods and functions
--------------------------------------------------------------------------------
local spinspeed = math.rad(60)

local function IdleAnim()
	Signal(SIG_IDLE)
	SetSignalMask(SIG_IDLE)
	local heading = 0
	local r = 0
	while idle do
		while (spGetUnitRulesParam(unitID, "lowpower") == 1) or disarmed do
			Sleep(100)
		end
		EmitSfx(zelena, 1026)
		
		heading = heading + math.rad(math.random(-90, 90))
		r = math.random(0, 100)
		if r > 50 then
			rotateWise = 1
		else
			rotateWise = -1
		end
		lastHeading = heading
		if idle then
			Spin(gear, y_axis, math.rad(TURN_SPEED) * 5 * rotateWise)
			Spin(gear001, y_axis, math.rad(TURN_SPEED) * 5 * rotateWise)
			Spin(gear002, y_axis, math.rad(TURN_SPEED) * 5 * rotateWise)
		
			Turn(rotating_bas, y_axis, heading, spinspeed)
			Turn(mc_rocket_ho, x_axis, math.rad(math.random(-25, 0)), spinspeed)
			
			WaitForTurn(rotating_bas, y_axis)
			EmitSfx(modra, 1027)
			StopSpin(gear, y_axis)
			StopSpin(gear001, y_axis)
			StopSpin(gear002, y_axis)
		end
		Sleep(math.random(400, 6500))
	end
end

local function StunThread()
	Signal (SIG_AIM)
	Signal(SIG_IDLE)
	SetSignalMask(SIG_AIM)
	--SetSignalMask(SIG_IDLE)
	disarmed = true

	GG.PieceControl.StopTurn (gear, y_axis)
	GG.PieceControl.StopTurn (gear001, y_axis)
	GG.PieceControl.StopTurn (gear002, y_axis)
	GG.PieceControl.StopTurn (rotating_bas, y_axis)
	GG.PieceControl.StopTurn (mc_rocket_ho, x_axis)
end

local function RestoreAfterDelay()
	Sleep(6000)
	idle = true
	StartThread(IdleAnim)
end

local function UnstunThread()
	disarmed = false
	SetSignalMask(SIG_AIM)
	RestoreAfterDelay()
end

local stuns = {false, false, true}
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
	--Spring.Echo("Vytvořeno")
	--Hide(flare_l)
	--Hide(flare_r)
	scriptReload.SetupScriptReload(28, 14 * gameSpeed)
	StartThread(IdleAnim)
	if GG.Script.onWater(unitID) then
		Hide(solid_ground)
	else
		Hide(plovak)
	end
	
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

function DoAmmoRotate()
	if doingRotation then
		return
	end
	SetSignalMask(0)
	doingRotation = true
	resetRockets()
	
	Show(raketa014_l)
	Show(raketa014)
	
	--1
	Move(raketa014, y_axis, -3.9, RELOAD_SPEED)
	Move(raketa014, x_axis, -2.5, RELOAD_SPEED)
	Move(raketa014, z_axis, 4, RELOAD_SPEED)
	Move(raketa014_l, y_axis, -3.9, RELOAD_SPEED)
	Move(raketa014_l, x_axis, 2.5, RELOAD_SPEED)
	Move(raketa014_l, z_axis, 4, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--2
	Move(raketa013, y_axis, -3.6, RELOAD_SPEED)
	Move(raketa013, x_axis, -1.5, RELOAD_SPEED)
	Move(raketa013, z_axis, 3.3, RELOAD_SPEED)
	Move(raketa013_l, y_axis, -3.6, RELOAD_SPEED)
	Move(raketa013_l, x_axis, 1.5, RELOAD_SPEED)
	Move(raketa013_l, z_axis, 3.3, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--3
	Move(raketa012, y_axis, -4.1, RELOAD_SPEED)
	Move(raketa012, x_axis, -0.3, RELOAD_SPEED)
	Move(raketa012, z_axis, 2.5, RELOAD_SPEED)
	Move(raketa012_l, y_axis, -4.1, RELOAD_SPEED)
	Move(raketa012_l, x_axis, 0.3, RELOAD_SPEED)
	Move(raketa012_l, z_axis, 2.5, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--4
	Move(raketa011, y_axis, -4.6, RELOAD_SPEED)
	Move(raketa011, x_axis, 1.6, RELOAD_SPEED)
	Move(raketa011, z_axis, 1.9, RELOAD_SPEED)
	Move(raketa011_l, y_axis, -4.6, RELOAD_SPEED)
	Move(raketa011_l, x_axis, -1.6, RELOAD_SPEED)
	Move(raketa011_l, z_axis, 1.9, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--5
	Move(raketa010, y_axis, -4.2, RELOAD_SPEED)
	Move(raketa010, x_axis, 2.2, RELOAD_SPEED)
	Move(raketa010, z_axis, 0.2, RELOAD_SPEED)
	Move(raketa010_l, y_axis, -4.2, RELOAD_SPEED)
	Move(raketa010_l, x_axis, -2.2, RELOAD_SPEED)
	Move(raketa010_l, z_axis, 0.2, RELOAD_SPEED)
	
	
	Sleep(MOV_DEL)
	
	--6
	Move(raketa009, y_axis, -2.8, RELOAD_SPEED)
	Move(raketa009, x_axis, 4.2, RELOAD_SPEED)
	Move(raketa009, z_axis, 0.4, RELOAD_SPEED)
	Move(raketa009_l, y_axis, -2.8, RELOAD_SPEED)
	Move(raketa009_l, x_axis, -4.2, RELOAD_SPEED)
	Move(raketa009_l, z_axis, 0.4, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--7
	Move(raketa008, y_axis, -1, RELOAD_SPEED)
	Move(raketa008, x_axis, 5.2, RELOAD_SPEED)
	Move(raketa008, z_axis, -0.4, RELOAD_SPEED)
	Move(raketa008_l, y_axis, -1, RELOAD_SPEED)
	Move(raketa008_l, x_axis, -5.2, RELOAD_SPEED)
	Move(raketa008_l, z_axis, -0.4, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--8
	Move(raketa007, y_axis, 1.6, RELOAD_SPEED)
	Move(raketa007, x_axis, 4.6, RELOAD_SPEED)
	Move(raketa007, z_axis, -1.8, RELOAD_SPEED)
	Move(raketa007_l, y_axis, 1.6, RELOAD_SPEED)
	Move(raketa007_l, x_axis, -4.6, RELOAD_SPEED)
	Move(raketa007_l, z_axis, -1.8, RELOAD_SPEED)
	
	Sleep(MOV_DEL)

	--9
	Move(raketa006, y_axis, 3, RELOAD_SPEED)
	Move(raketa006, x_axis, 3.6, RELOAD_SPEED)
	Move(raketa006, z_axis, 0, RELOAD_SPEED)
	Move(raketa006_l, y_axis, 3, RELOAD_SPEED)
	Move(raketa006_l, x_axis, -3.6, RELOAD_SPEED)
	Move(raketa006_l, z_axis, 0, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--10
	Move(raketa027, y_axis, 4, RELOAD_SPEED)
	Move(raketa027, x_axis, 1.2, RELOAD_SPEED)
	Move(raketa027, z_axis, 0, RELOAD_SPEED)
	Move(raketa027_l, y_axis, 4.1, RELOAD_SPEED)
	Move(raketa027_l, x_axis, -1.6, RELOAD_SPEED)
	Move(raketa027_l, z_axis, 0, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--11 !!!switched l&r (again, so its right)
	Move(raketa004, y_axis, 5.2, RELOAD_SPEED)
	Move(raketa004, x_axis, 0.2, RELOAD_SPEED)
	Move(raketa004, z_axis, 0, RELOAD_SPEED)
	Move(raketa004_l, y_axis, 4.2, RELOAD_SPEED)
	Move(raketa004_l, x_axis, -0.8, RELOAD_SPEED)
	Move(raketa004_l, z_axis, 0, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--12
	Move(raketa002, y_axis, 5, RELOAD_SPEED)
	Move(raketa002, x_axis, 0.2, RELOAD_SPEED)
	Move(raketa002, z_axis, 0, RELOAD_SPEED)
	Move(raketa002_l, y_axis, 4.9, RELOAD_SPEED)
	Move(raketa002_l, x_axis, -0.2, RELOAD_SPEED)
	Move(raketa002_l, z_axis, 0, RELOAD_SPEED)
	
	Sleep(MOV_DEL)
	
	--14
	Move(raketa, y_axis, 4.8, RELOAD_SPEED)
	Move(raketa, x_axis, 0, RELOAD_SPEED)
	Move(raketa, z_axis, 0, RELOAD_SPEED)
	Move(raketa_l, y_axis, 4.5, RELOAD_SPEED)
	Move(raketa_l, x_axis, 0.2, RELOAD_SPEED)
	Move(raketa_l, z_axis, 0, RELOAD_SPEED)
	
	doingRotation = false
	loaded = true
end

function resetRockets()
	Move(raketa, z_axis, -5)
	Move(raketa_l, z_axis, -3)
	Move(raketa, y_axis, -5)
	Move(raketa_l, y_axis, -3)
	setZero(raketa002)
	setZero(raketa004)
	setZero(raketa006)
	setZero(raketa007)
	setZero(raketa008)
	setZero(raketa009)
	setZero(raketa010)
	setZero(raketa011)
	setZero(raketa012)
	setZero(raketa013)
	--setZero(raketa014)
	setZero(raketa002_l)
	setZero(raketa004_l)
	setZero(raketa006_l)
	setZero(raketa007_l)
	setZero(raketa008_l)
	setZero(raketa009_l)
	setZero(raketa010_l)
	setZero(raketa011_l)
	setZero(raketa012_l)
	setZero(raketa013_l)
	--setZero(raketa014_l)
	--setZero(raketa026)
	setZero(raketa027)
	--setZero(raketa026_l)
	setZero(raketa027_l)
end

function setZero(piece)
	Move(piece, x_axis, 0)
	Move(piece, y_axis, 0)
	Move(piece, z_axis, 0)
end



function script.AimWeapon(num, heading, pitch)
	Signal(SIG_IDLE) -- Tell the IdleAnim we're busy.
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	if (spGetUnitRulesParam(unitID, "lowpower") == 1) then
		return false
	end
	EmitSfx(cervena, 1025)
	if(lastHeading > heading) then
		rotateWise = 1
	else
		rotateWise = -1
	end
	lastHeading = heading
	while disarmed do
		Sleep(33)
	end
	--if(gun and not loaded) then
		--StartThread(DoAmmoRotate)
		--while doingRotation do
			--Sleep(10)
		--end
	--end
	
	Turn(rotating_bas, y_axis, heading, math.rad(TURN_SPEED))
	
	Spin(gear, y_axis, math.rad(TURN_SPEED) * rotateWise * 5)
	Spin(gear001, y_axis, math.rad(TURN_SPEED) * rotateWise * 5)
	Spin(gear002, y_axis, math.rad(TURN_SPEED) * rotateWise * 5)
	
	Turn(mc_rocket_ho, x_axis, -pitch, math.rad(TILT_SPEED))
	WaitForTurn(rotating_bas, y_axis)
	WaitForTurn(mc_rocket_ho, x_axis)
	
	StopSpin(gear, y_axis)
	StopSpin(gear001, y_axis)
	StopSpin(gear002, y_axis)
	
	StartThread(RestoreAfterDelay)
	return (spGetUnitRulesParam(unitID, "lowpower") == 0)
end

function script.Shot(num)
	EmitSfx(gun[shot].firepoint, GG.Script.UNIT_SFX1)
	StartThread(reload, shot)
	shot = (shot + 1) %28
	loaded = loaded - 1
end

function Bum()
	flare, flare2 = flare2, flare

	if(gun) then
		Hide(raketa026)
				
		Hide(raketa014)
		setZero(raketa014)
		gun = false
	else
		Hide(raketa026_l)
		
		gun = true
		loaded = false
		Hide(raketa014_l)
		setZero(raketa014_l)
	end
end

function script.QueryWeapon()
	return gun[shot].firepoint
end

function script.AimFromWeapon()
	return mc_rocket_ho
end

function script.BlockShot(num, targetID)
	if gun[shot].loaded then
		local distMult = (Spring.GetUnitSeparation(unitID, targetID) or 0) * 0.2
		return ((targetID and (GG.DontFireRadar_CheckBlock(unitID, targetID))) or GG.OverkillPrevention_CheckBlock(unitID, targetID, 200.1, distMult)) or false
	end
	return true
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	if severity <= 0.25 then
		return 1
	elseif severity <= 0.50 then
		Explode(trubky, SFX.FALL)
		Explode(raketa027, SFX.FALL)
		Explode(raketa004, SFX.FALL)
		Explode(raketa011_l, SFX.FALL)
		Explode(raketa008_l, SFX.FALL)
		Explode(raketa009, SFX.FALL)
		Explode(cervena, SFX.FALL)
		Explode(modra, SFX.FALL)
		Explode(zelena, SFX.FALL)
		Explode(spodni_zebra, SFX.FALL)
		Explode(vrchni_zebra, SFX.FALL)
		Explode(mc_rocket_ho, SFX.FALL)
		Explode(rotating_bas, SFX.SHATTER)
		return 1
	else
		Explode(trubky, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(raketa027, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(raketa004, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(raketa011_l, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(raketa008_l, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(raketa009, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(cervena, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(modra, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(zelena, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(spodni_zebra, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(vrchni_zebra, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(mc_rocket_ho, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(rotating_bas, SFX.SHATTER)
		return 2
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
