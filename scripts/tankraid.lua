-- linear constant 65536

include "constants.lua"

-- WARNING: change your constant for the -brackets to 65536 before compilingnot
local base, body, turret, sleeve, barrel, firepoint, tracks1, tracks2, tracks3, tracks4,
wheels1, wheels2, wheels3, wheels4, wheels5, wheels6, wheels7, wheels8, flamepoint =
piece('base', 'body', 'turret', 'sleeve', 'barrel', 'firepoint', 'tracks1', 'tracks2',
'tracks3', 'tracks4', 'wheels1', 'wheels2', 'wheels3', 'wheels4', 'wheels5', 'wheels6', 'wheels7', 'wheels8')

local moving, once, animCount = false,true,0

local deathanimtab = {
	[1] = piece('base'),
	[2] = piece('turret'),
	[3] = piece('tracks1'),
	[4] = piece('tracks3'),
	[5] = piece('tracks2'),
	[6] = piece('tracks4'),
	[7] = piece('wheels8'),
}

-- Signal definitions
local SIG_Walk = 2
local SIG_Restore = 1 --NOTE: must be an odd number
local SIG_AIM1 = 1

local ANIM_SPEED = 50
local RESTORE_DELAY = 200

local TURRET_TURN_SPEED = math.rad(360)
local GUN_TURN_SPEED = math.rad(260)

local WHEEL_TURN_SPEED1 = 480
local WHEEL_TURN_SPEED1_ACCELERATION = 75
local WHEEL_TURN_SPEED1_DECELERATION = 200

local smokePiece = {body, turret}

local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetGameFrame = Spring.GetGameFrame
local sin = math.sin
local spGetUnitWeaponTarget = Spring.GetUnitWeaponTarget
local spSpawnSFX = Spring.SpawnSFX
local spGetUnitPiecePosition = Spring.GetUnitPiecePosition
local spGetUnitPosition = Spring.GetUnitPosition
local spSetUnitHealth = Spring.SetUnitHealth
local spGetUnitHealth = Spring.GetUnitHealth
local spAddUnitDamage = Spring.AddUnitDamage

local flaming = false
local isFiring = false

local boostHealthCost = tonumber(UnitDef.customParams.boost_health_cost) or 15
local boostSpeed = tonumber(UnitDef.customParams.boost_speed_mult) or 2
local boostTime = (tonumber(UnitDef.customParams.boost_duration) or 1.4) * 10
local boostMinHealth = tonumber(UnitDef.customParams.boost_min_health) or 100
local normalSpeed = 1
local firingSpeed = 0.8

local sweepAngle = 0
local sweepMax = math.rad(30)
local sweepStep = math.rad(10)

local function IsStunnedOrDisarmed()
	local disarmed = (Spring.GetUnitRulesParam(unitID, "disarmed") or 0) == 1
	return Spring.GetUnitIsStunned(unitID) or disarmed
end

local function RestoreAfterDelay()
	Signal(SIG_Restore)
	SetSignalMask(SIG_Restore)
	
	Sleep(RESTORE_DELAY)
	
	--Turn(turret, y_axis, math.rad(0), math.rad(TURRET_TURN_SPEED/2))
	--Turn(sleeve, x_axis, math.rad(0), math.rad(GUN_TURN_SPEED/2))
	while disableAfterburner do
		sleep(200)
	end
	
	Turn(turret, y_axis, math.pi, TURRET_TURN_SPEED)
	Turn(sleeve, x_axis, 0.6, GUN_TURN_SPEED)
	
	WaitForTurn(turret, y_axis)
	WaitForTurn(sleeve, x_axis)
	
	isFiring = false
	spSetUnitRulesParam(unitID, "selfMoveSpeedChange", normalSpeed)
	spSetUnitRulesParam(unitID, "maxAcc", normalSpeed)
	GG.UpdateUnitAttributes(unitID)
	
	while true do
		EmitSfx(firepoint, GG.Script.UNIT_SFX1)
		Sleep(100)
	end
end

----------------------------------------------------------
----------------------------------------------------------


function FlameTrailThread()
	Signal(SIG_Restore)
	Signal(SIG_AIM1)
	
	flaming = true
	disableAfterburner = true
	Turn(turret, y_axis, math.pi, TURRET_TURN_SPEED)
	Turn(sleeve, x_axis, 0.6, GUN_TURN_SPEED)
	WaitForTurn(turret, y_axis)
	WaitForTurn(sleeve, x_axis)
	
	spSetUnitRulesParam(unitID, "selfMoveSpeedChange", boostSpeed)
	spSetUnitRulesParam(unitID, "maxAcc", boostSpeed)
	GG.UpdateUnitAttributes(unitID)
	
	--spAddUnitDamage(unitID, 30) --this is to reset regen times. there seems to be a minium enforced by either a gadget or the engine of 20 damage.
	local n = 0
	local disarmed, needsRestore = false, false
	GG.Sprint.Start(unitID, boostSpeed)
	while (n < boostTime) do
		local health = spGetUnitHealth(unitID)
		disarmed = IsStunnedOrDisarmed()
		while disarmed do
			Sleep(33)
			disarmed = IsStunnedOrDisarmed()
		end
		if moving then
			EmitSfx(firepoint, GG.Script.FIRE_W2)
			spSetUnitHealth(unitID, health - boostHealthCost)
		end
		if health < boostMinHealth then
			n = 10000
		end
		Sleep(100)
		n = n + 1
	end
	GG.Sprint.End(unitID)
	spSetUnitRulesParam(unitID, "selfMoveSpeedChange", normalSpeed)
	spSetUnitRulesParam(unitID, "maxAcc", normalSpeed)
	GG.UpdateUnitAttributes(unitID)
	flaming = false
	disableAfterburner = false
	
	StartThread(RestoreAfterDelay)
end


function FlameTrail()
	StartThread(FlameTrailThread)
end

----------------------------------------------------------
----------------------------------------------------------

local function AnimationControl()

	local current_tracks = 0
	
	while true do
	
		if moving or once then
		
			if current_tracks == 0 then
			
				Show(tracks1)
				Hide(tracks4)
				current_tracks = current_tracks + 1
			elseif current_tracks == 1 then
				
				Show(tracks2)
				Hide(tracks1)
				current_tracks = current_tracks + 1
			elseif current_tracks == 2 then
			
				Show(tracks3)
				Hide(tracks2)
				current_tracks = current_tracks + 1
			elseif current_tracks == 3 then
			
				Show(tracks4)
				Hide(tracks3)
				current_tracks = 0
			end
			
			once = false
			
		end
		animCount = animCount + 1
		Sleep(ANIM_SPEED)
	end
end

local function Moving()
	Signal(SIG_Walk)
	SetSignalMask(SIG_Walk)
	
	Spin(wheels1, x_axis, WHEEL_TURN_SPEED1, WHEEL_TURN_SPEED1_ACCELERATION)
	Spin(wheels2, x_axis, WHEEL_TURN_SPEED1, WHEEL_TURN_SPEED1_ACCELERATION)
	Spin(wheels3, x_axis, WHEEL_TURN_SPEED1, WHEEL_TURN_SPEED1_ACCELERATION)
	Spin(wheels4, x_axis, WHEEL_TURN_SPEED1, WHEEL_TURN_SPEED1_ACCELERATION)
	Spin(wheels5, x_axis, WHEEL_TURN_SPEED1, WHEEL_TURN_SPEED1_ACCELERATION)
	Spin(wheels6, x_axis, WHEEL_TURN_SPEED1, WHEEL_TURN_SPEED1_ACCELERATION)
	Spin(wheels7, x_axis, WHEEL_TURN_SPEED1, WHEEL_TURN_SPEED1_ACCELERATION)
	Spin(wheels8, x_axis, WHEEL_TURN_SPEED1, WHEEL_TURN_SPEED1_ACCELERATION)
end

local function Stopping()
	Signal(SIG_Walk)
	SetSignalMask(SIG_Walk)
	
	-- I don\'t like insta braking. It\'s not perfect but works for most cases.
	-- Probably looks goofy when the unit is turtling,, i.e. does not become faster as time increases..
	once = animCount*ANIM_SPEED/1000

	StopSpin(wheels1, x_axis, WHEEL_TURN_SPEED1_DECELERATION)
	StopSpin(wheels2, x_axis, WHEEL_TURN_SPEED1_DECELERATION)
	StopSpin(wheels3, x_axis, WHEEL_TURN_SPEED1_DECELERATION)
	StopSpin(wheels4, x_axis, WHEEL_TURN_SPEED1_DECELERATION)
	StopSpin(wheels5, x_axis, WHEEL_TURN_SPEED1_DECELERATION)
	StopSpin(wheels6, x_axis, WHEEL_TURN_SPEED1_DECELERATION)
	StopSpin(wheels7, x_axis, WHEEL_TURN_SPEED1_DECELERATION)
	StopSpin(wheels8, x_axis, WHEEL_TURN_SPEED1_DECELERATION)
end


function script.StartMoving()
	moving = true
	animCount = 0
	StartThread(Moving)
end

function script.StopMoving()

	moving = false
	StartThread(Stopping)
end

-- Weapons
function script.AimFromWeapon()
	return turret
end

function script.QueryWeapon()
	return firepoint
end

function script.AimWeapon(num, heading, pitch)
	if flaming then
		return false
	end
	
	Signal(SIG_AIM1)
	SetSignalMask(SIG_AIM1)
	if not isFiring then
		spSetUnitRulesParam(unitID, "selfMoveSpeedChange", firingSpeed)
		spSetUnitRulesParam(unitID, "maxAcc", firingSpeed)
		GG.UpdateUnitAttributes(unitID)
		isFiring = true
	end
	
	Turn(turret, y_axis, heading, TURRET_TURN_SPEED)
	Turn(sleeve, x_axis, -pitch, GUN_TURN_SPEED)
	
	WaitForTurn(turret, y_axis)
	WaitForTurn(sleeve, x_axis)
	
	StartThread(RestoreAfterDelay)
	
	return true
	--[[
	local fx, _, fz = Spring.GetUnitPiecePosition(unitID, firepoint)
	local tx, _, tz = Spring.GetUnitPiecePosition(unitID, turret)
	local pieceHeading = math.pi * Spring.GetHeadingFromVector(fx-tx,fz-tz) * 2^-15
	
	local headingDiff = math.abs((heading+pieceHeading)%(math.pi*2) - math.pi)
	
	if headingDiff > 2.6 then
		Turn(turret, y_axis, heading)
		Turn(sleeve, x_axis, -pitch)
		StartThread(RestoreAfterDelay)
		-- EmitSfx works if the turret takes no time to turn and there is no waitForTurn
		return true
	else
		Turn(turret, y_axis, heading, math.rad(TURRET_TURN_SPEED))
		Turn(sleeve, x_axis, -pitch, math.rad(GUN_TURN_SPEED))
		StartThread(RestoreAfterDelay)
		return false
	end
	--]]
end

local function Recoil()
	Move(barrel, z_axis, -3.5)
	Sleep(150)
	Move(barrel, z_axis, 0, 10)
end

function script.Shot(num)
	--[[
	Turn(firepoint, y_axis, math.rad(25))
	EmitSfx(firepoint, GG.Script.FIRE_W2)
	Turn(firepoint, y_axis, - math.rad(25))
	EmitSfx(firepoint, GG.Script.FIRE_W2)
	Turn(firepoint, y_axis, 0)
	--]]
	--StartThread(Recoil)
end

function script.BlockShot(num, targetID)
	if num == 2 or flaming then
		return true
	else
		--[[if Spring.ValidUnitID(targetID) then
			local hitTime = (Spring.GetUnitSeparation(unitID, targetID) or 0)*0.1
			return GG.OverkillPrevention_CheckBlock(unitID, targetID, 58, hitTime)
		end]]--
		return false
	end
end

local function DeathAnim(num)
	local _, inBuild = Spring.GetUnitIsStunned(unitID)
	if inBuild then
		return
	end
	--EmitSfx(turret, 1024)
	--Sleep(33)
	local px, py, pz = Spring.GetUnitPosition(unitID)
	Spring.PlaySoundFile("Sounds/explosion/tankraid_deathexplo.wav", 80.0, px, py, pz, 0, 0, 0, "battle")
	--EmitSfx(base, 1024)
	--EmitSfx(deathanimtab[math.random(5,7)], GG.Script.UNIT_SFX1)
	--EmitSfx(deathanimtab[math.random(1,4)], GG.Script.UNIT_SFX1)
	Spring.SpawnProjectile(WeaponDefNames["tankraid_deathexplo"].id, {
		pos = {px, py + 5, pz},
		["end"] = {px, py, pz},
		speed = {0, 0, 0},
		ttl = 10,
		gravity = 1,
		team = Spring.GetGaiaTeamID(),
		owner = unitID,
	})
	for i = 1, num do
		--EmitSfx(deathanimtab[math.random(5,7)], GG.Script.UNIT_SFX2)
		--EmitSfx(deathanimtab[math.random(1,4)], GG.Script.UNIT_SFX2)
		px, py, pz = Spring.GetUnitPosition(unitID)
		Spring.SpawnProjectile(WeaponDefNames["tankraid_deathexplo_spawner"].id, {
			pos = {px, py + 5, pz},
			speed = {0, 0, 0},
			ttl = 10,
			gravity = 1,
			team = Spring.GetGaiaTeamID(),
			owner = unitID,
		})
		if num < 3 then
			Sleep(math.random() * 300)
		else
			Sleep(33)
		end
	end
end

function script.Killed(recentDamage, maxHealth)
	local severity = 100 * recentDamage / maxHealth
	if severity <= 25 then
		Explode(body, SFX.NONE)
		Explode(turret, SFX.NONE)
		DeathAnim(2)
		return 1
	end
	if severity <= 50 then
		Explode(body, SFX.NONE)
		Explode(turret,SFX.NONE)
		Explode(barrel, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		DeathAnim(4)
		return 1
	else
		Explode(body, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(barrel, SFX.FALL + SFX.SMOKE + SFX.FIRE)
		Explode(tracks1, SFX.SHATTER + SFX.SMOKE + SFX.FIRE)
		Hide(tracks2)
		Hide(tracks3)
		Hide(tracks4)
		DeathAnim(6)
		return 2
	end
end

function script.Create()
	Spring.SetUnitRulesParam(unitID,'cannot_damage_unit',unitID) --SAVE ME, SENPAI LAZOR!
	
	moving = false
	
	Turn(firepoint, x_axis, math.rad(7))
	
	--Hide(tracks1)
	--Hide(tracks2)
	--Hide(tracks3)
	
	while select(5, Spring.GetUnitHealth(unitID)) < 1 do
		Sleep(250)
	end
	
	StartThread(AnimationControl)
	StartThread(RestoreAfterDelay)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end
