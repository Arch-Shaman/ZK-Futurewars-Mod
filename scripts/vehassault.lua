include "constants.lua"

local base, body, turret, sleeve, barrel, firepoint = piece('base', 'body', 'turret', 'sleeve', 'barrel', 'firepoint')
local rwheel1, rwheel2, rwheel3, rwheel4 = piece('rwheel1', 'rwheel2', 'rwheel3', 'rwheel4')
local lwheel1, lwheel2, lwheel3, lwheel4 = piece('lwheel1', 'lwheel2', 'lwheel3', 'lwheel4')
local gs1r, gs2r, gs3r, gs4r = piece('gs1r', 'gs2r', 'gs3r', 'gs4r')
local gs1l, gs2l, gs3l, gs4l = piece('gs1l', 'gs2l', 'gs3l', 'gs4l')

local SIG_AIM = 1
local SIG_MOVE = 2
local RESTORE_DELAY = 3000
local TURRET_TURN_SPEED = math.rad(180)
local SLEEVE_TURN_SPEED = math.rad(90)

local angle = math.rad(90)

local recoil = -1.75
local recoilamount = 10
local returnspeed = 1.5
local fired = false
local lastfire = -1
local graceperiod = 4 -- 4 seconds before decay.
local reloads = 0
local maxreloads = 20
local reloadtime = WeaponDefs[UnitDefNames["vehassault"].weapons[1].weaponDef].reload
local reloadframes = {
	[0] = 75,
	[1] = 75,
	[2] = 68,
	[3] = 62,
	[4] = 58,
	[5] = 54,
	[6] = 50,
	[7] = 47,
	[8] = 44,
	[9] = 42,
	[10] = 39,
	[11] = 38,
	[12] = 36,
	[13] = 34,
	[14] = 33,
	[15] = 31,
	[16] = 30,
	[17] = 29,
	[18] = 28,
	[19] = 27,
	[20] = 26,
}

local mainhead = 0

local SUSPENSION_BOUND = 3
local SPEEDUP_FACTOR = tonumber (UnitDef.customParams.boost_speed_mult)
local SPEEDUP_DURATION = tonumber (UnitDef.customParams.boost_duration)
local POSTSPRINT_SPEED = tonumber (UnitDef.customParams.boost_postsprint_speed)
local POSTSPRINT_DURATION = tonumber (UnitDef.customParams.boost_postsprint_duration)

-- speedups --
local cos = math.cos
local sin = math.sin
local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitPiecePosDir = Spring.GetUnitPiecePosDir

local function GetWheelHeight(piece)
	local x, y, z = spGetUnitPiecePosDir(unitID, piece)
	local height = spGetGroundHeight(x, z) - y
	if height < -SUSPENSION_BOUND then
		height = -SUSPENSION_BOUND
	elseif height > SUSPENSION_BOUND then
		height = SUSPENSION_BOUND
	end
	return height
end

local xtiltv, ztiltv = 0, 0
local spGetUnitVelocity = Spring.GetUnitVelocity

function SprintThread()
	for i=1, SPEEDUP_DURATION do
		EmitSfx(rwheel4, 1026)
		EmitSfx(lwheel4, 1026)
		Sleep(33)
	end
	
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", POSTSPRINT_SPEED)
	GG.UpdateUnitAttributes(unitID)
	Sleep(POSTSPRINT_DURATION * 33)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	GG.UpdateUnitAttributes(unitID)
	-- Spring.MoveCtrl.SetAirMoveTypeData(unitID, "maxAcc", 0.5)
	GG.UpdateUnitAttributes(unitID)
end

function Sprint()
	StartThread(SprintThread)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", SPEEDUP_FACTOR)
	-- Spring.MoveCtrl.SetAirMoveTypeData(unitID, "maxAcc", 3)
	GG.UpdateUnitAttributes(unitID)
end

local CMD_ONECLICK_WEAPON = Spring.Utilities.CMD.ONECLICK_WEAPON

local function RetreatThread()
	Sleep(800)
	local specialReloadState = Spring.GetUnitRulesParam(unitID,"specialReloadFrame")
	if (not specialReloadState or (specialReloadState <= Spring.GetGameFrame())) then
		Spring.GiveOrderToUnit(unitID, CMD.INSERT, {0, CMD_ONECLICK_WEAPON, CMD.OPT_INTERNAL,}, CMD.OPT_ALT)
	end
end

local function ReloadSpeedSetterThread()
	local lastreloads = 0
	while true do
		if reloads ~= lastreloads then
			--Spring.Echo("New reloads: " .. reloads)
			lastreloads = reloads
			Spring.SetUnitWeaponState(unitID, 1, "reloadTime", reloadframes[reloads]/30)
		end
		Sleep(66)
	end
end

local function ReloadSpeedControlThread()
	while true do
		Sleep(33)
		if reloads ~= 0 then
			if lastfire == Spring.GetGameFrame() then
				Sleep(graceperiod * (1000 / Game.gameSpeed))
			else
				if lastfire + (graceperiod * 30) <= Spring.GetGameFrame() then
					reloads = reloads - 1
					if reloads < 0 then -- safety.
						reloads = 0
					end
					Sleep(33 * 4)
				end
			end
		end
	end
end

function RetreatFunction()
	StartThread(RetreatThread)
end

local function Suspension() -- Shamelessly stolen and adapted from Ripper. Perhaps this should be an include or something?
	local xtilt, ztilt = 0, 0
	local yv, yp = 0, 0
	local s1r, s2r, s3r, sl1, s2l, s3l, s4l, s4r, xtilta, ztilta, ya, speed, wheelTurnSpeed
	while true do
		s1r = GetWheelHeight(gs1r)
		s2r = GetWheelHeight(gs2r)
		s3r = GetWheelHeight(gs3r)
		s1l = GetWheelHeight(gs1l)
		s2l = GetWheelHeight(gs2l)
		s3l = GetWheelHeight(gs3l)
		s4l = GetWheelHeight(gs4l)
		s4r = GetWheelHeight(gs4r)
		xtilta = (s3r + s3l - s1l - s1r)/6000
		xtiltv = xtiltv*0.99 + xtilta
		xtilt = xtilt*0.98 + xtiltv

		ztilta = (s1r + s2r + s3r - s1l - s2l - s3l)/15000
		ztiltv = ztiltv*0.99 + ztilta
		ztilt = ztilt*0.99 + ztiltv
		
		ya = (s1r + s2r + s3r + s1l + s2l + s3l)/1500
		
		yv = yv*0.99 + ya
		if yv < -0.1 then
			yv = -0.1
		end
		yp = yp*0.98 + yv
		if yp < -3 then
			yp = -3
		end

		Move(base, y_axis, yp)
		Turn(base, x_axis, xtilt)
		Turn(base, z_axis, -ztilt)

		Move(rwheel1, y_axis, s1r, 20)
		Move(rwheel2, y_axis, s2r, 20)
		Move(rwheel3, y_axis, s3r, 20)
		Move(lwheel1, y_axis, s1l, 20)
		Move(lwheel2, y_axis, s2l, 20)
		Move(lwheel3, y_axis, s3l, 20)
		Move(lwheel4, y_axis, s3l, 20)
		Move(rwheel4, y_axis, s3l, 20)

		_, _, _, speed = spGetUnitVelocity(unitID)
		wheelTurnSpeed = speed * 3
		Spin (rwheel1, x_axis, wheelTurnSpeed)
		Spin (rwheel2, x_axis, wheelTurnSpeed)
		Spin (rwheel3, x_axis, wheelTurnSpeed)
		Spin (lwheel1, x_axis, wheelTurnSpeed)
		Spin (lwheel2, x_axis, wheelTurnSpeed)
		Spin (lwheel3, x_axis, wheelTurnSpeed)
		Spin (lwheel4, x_axis, wheelTurnSpeed)
		Spin (rwheel4, x_axis, wheelTurnSpeed)

		Sleep (34)
	end
end

local function BarrelRecoil()
	Move(barrel, z_axis, recoil)
	Sleep(200)
	Move(barrel, z_axis, 0, returnspeed)
end

local function RestoreAfterDelay()
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, TURRET_TURN_SPEED)
	Turn(sleeve, x_axis, 0, SLEEVE_TURN_SPEED)
end

function script.AimFromWeapon(num)
	return turret
end

function script.QueryWeapon(num)
	return firepoint
end

function script.BlockShot(num, targetID)
	return GG.OverkillPrevention_CheckBlock(unitID, targetID, 210, 40, 0.3, 0, true) -- (unitID, targetID, damage, timeout, fastMult, radarMult, staticOnly)
end

function script.AimWeapon(num, heading, pitch)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	Turn(turret, y_axis, heading, TURRET_TURN_SPEED)
	Turn(sleeve, x_axis, -pitch, SLEEVE_TURN_SPEED)
	WaitForTurn(turret, y_axis)
	WaitForTurn(sleeve, x_axis)
	mainhead = heading -- Used for the "barrel recoil" thing.
	StartThread(RestoreAfterDelay)
	return true
end

function script.Shot(num) -- Moved off FireWeapon for modders/tweakunits mostly.
	xtiltv = xtiltv - cos(mainhead) / 69
	ztiltv = ztiltv - sin(mainhead) / 69
	EmitSfx(firepoint, 1024)
	EmitSfx(firepoint, 1025)
	StartThread(BarrelRecoil)
	if reloads < maxreloads then
		reloads = reloads + 1
	end
	lastfire = Spring.GetGameFrame()
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, {body, turret})
	StartThread(Suspension)
	StartThread(ReloadSpeedControlThread)
	StartThread(ReloadSpeedSetterThread)
	Hide(firepoint)
end

local explodables = {barrel, sleeve, turret, rwheel1, rwheel2, rwheel3, rwheel4, lwheel1, lwheel2, lwheel3, lwheel4}
-- Note: Old script did not have exploding wheels. Liberties were taken.

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	local brutal = severity > 0.5
	for i = 1, #explodables do
		if math.random() < severity then
			Explode(explodables[i], SFX.FALL + (brutal and (SFX.SMOKE + SFX.FIRE) or 0))
		end
	end
	
	if not brutal then
		return 1
	else
		Explode(body, SFX.SHATTER)
		return 2
	end
end
