
-- by Chris Mackey
include "constants.lua"

--pieces
local base = piece "base"
local missile = piece "missile"
local l_wing = piece "l_wing"
local l_fan = piece "l_fan"
local r_wing = piece "r_wing"
local r_fan = piece "r_fan"

local side = 1
local forward = 3
local up = 2

local RIGHT_ANGLE = math.rad(90)
local range = 0
local random = math.random
local projectileDef = WeaponDefNames["gunshipbomb_boom"].id
local myGravity = WeaponDefs[projectileDef].myGravity
local terminated = false

local tolerance = math.rad(30) -- 15 degrees tolerance

local smokePiece = { base, l_wing, r_wing }

local SIG_BURROW = 1

local function Burrow()
	Signal(SIG_BURROW)
	SetSignalMask(SIG_BURROW)
	
	local x,y,z = Spring.GetUnitPosition(unitID)
	local height = Spring.GetGroundHeight(x,z)
	
	while height + 35 < y do
		Sleep(500)
		x,y,z = Spring.GetUnitPosition(unitID)
		height = Spring.GetGroundHeight(x,z)
	end
	
	--Spring.UnitScript.SetUnitValue(firestate, 0)
	Turn(base, side, -RIGHT_ANGLE, 5)
	Turn(l_wing, side, RIGHT_ANGLE, 5)
	Turn(r_wing, side, RIGHT_ANGLE, 5)
	Move(base, up, 8, 8)
	--Move(base, forward, -4, 5)
end

local function UnBurrow()
	Signal(SIG_BURROW)
	Spring.SetUnitCloak(unitID, 0)
	Spring.SetUnitStealth(unitID, false)
	--Spring.UnitScript.SetUnitValue(firestate, 2)
	Turn(base, side, 0, 5)
	Turn(l_wing, side,0, 5)
	Turn(r_wing, side, 0, 5)
	Move(base, up, 0, 10)
	--Move(base, forward, 0, 5)
end

local function RangeUpdateThread() -- shamelessly stolen from xponen's ballistic calculator widget.
	local vx, vy, vz = 0
	local ux, uy, uz, v2, discrim, denom,t1,t2,d1,d2
	local velocity
	local heightDifference = 0
	while true do
		ux, uy, uz = Spring.GetUnitPosition(unitID)
		vx, vy, vz = Spring.GetUnitVelocity(unitID)
		heightDifference = uy - math.max(Spring.GetGroundHeight(ux, uz), 0) -- can't enter sea, don't bother.
		velocity = math.sqrt((vx*vx) + (vz*vz))
		discrim = math.sqrt(0 - 4*((-myGravity/2)*heightDifference))
		denom = 2*(-myGravity/2)
		t1 = discrim/denom
		t2 = -discrim/denom
		d1 = velocity*t1
		d2 = velocity*t2
		range = math.max(d1 , d2)
		if range < 10 then
			range = 10
		end
		if range ~= range then -- prevent NaN from 2025.03.9
			range = 10
		end
		Spring.SetUnitMaxRange(unitID, range/15)
		Spring.SetUnitWeaponState(unitID, 1, {range = range, autoTargetRangeBoost = 100,})
		--Spring.Echo("RANGEUPDATE\nVel: " .. velocity .. "\nRange: " .. range)
		Sleep(33)
	end
end

local function Death(target)
	Explode(l_wing, SFX.EXPLODE)
	Explode(r_wing, SFX.EXPLODE)
	Explode(l_fan, SFX.EXPLODE)
	Explode(r_fan, SFX.EXPLODE)
	local vx, vy, vz = Spring.GetUnitVelocity(unitID)
	local x, y, z = Spring.GetUnitPosition(unitID)
	--Spring.Echo("Death: " .. vx .. ", " .. vy .. ", " .. vz .. "\nGravity: " .. myGravity .. "\nEstimated range: " .. range)
	local pro
	if vx + vz == 0 then
		pro = Spring.SpawnProjectile(projectileDef, {pos = {x, y, z}, speed = {0, random(1,8), 0}, owner = unitID, gravity = -myGravity, team = Spring.GetUnitTeam(unitID)})
	else
		pro = Spring.SpawnProjectile(projectileDef, {pos = {x, y, z}, speed = {vx, 0, vz}, owner = unitID, gravity = -myGravity, team = Spring.GetUnitTeam(unitID)})
	end
	if pro and target then
		Spring.SetProjectileTarget(pro, target[1], target[2], target[3])
	else
		Spring.SetProjectileTarget(pro, x, y, z)
	end
	GG.PlayFogHiddenSound("sounds/weapon/missile/sabot_hit.wav", 1600, x, y, z)
end

local function CleanupThread()
	Spring.SetUnitNoSelect(unitID, true)
	Spring.SetUnitNoDraw(unitID, true)
	Spring.SetUnitNoMinimap(unitID, true)
	local _, maxHealth = Spring.GetUnitHealth(unitID)
	Spring.SetUnitHealth(unitID, {paralyze = 99999999, health = maxHealth}) -- also heal to drop (now off-map) repair orders
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, -10000, 0, -10000)
	--Spring.SetUnitRulesParam(unitID, "untargetable", 1, {public = true}) -- does not work!
	Spring.SetUnitCloak(unitID, 4)
	Spring.SetUnitStealth(unitID, true)
	Spring.SetUnitBlocking(unitID,false,false,false)
	Spring.GiveOrderToUnit(unitID, CMD.STOP, 0, 0)
	
	Sleep(10000)
	Spring.MoveCtrl.Disable(unitID)
	Spring.DestroyUnit(unitID, false, true)
end

local function Terminate(ex, ey, ez)
	Death({ex, ey, ez})
	--Spring.DestroyUnit(unitID, false, true)
	terminated = true
	StartThread(CleanupThread)
end

local function GetHeading()
	local vx, _, vy = Spring.GetUnitVelocity(unitID)
	--Spring.Echo("GetHeading: " .. vx .. " , " .. vy)
	if vx == 0 and vy == 0 then return 0 end -- div by zero!
	if vx == 0 then return 0 end
	return math.atan(vy/vx)
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(RangeUpdateThread)
	if not Spring.GetUnitIsStunned(unitID) then
		Spring.SetUnitCloak(unitID, 2)
		Spring.SetUnitStealth(unitID, true)
		Burrow()
	end
end

function script.AimWeapon(num, heading, pitch)
	return true
end

function script.BlockShot() -- after verifying aim and before firing so we're suiciding.
	if terminated then
		return true
	end
	local typ, _, target = Spring.GetUnitWeaponTarget(unitID, 1)
	local x, _, z = Spring.GetUnitPosition(unitID)
	local ex, _, ez
	local rangeto
	local heading = GetHeading()
	if typ == 1 then -- expects unit or position
		ex, _, ez = Spring.GetUnitPosition(target)
		if ex == nil then
			rangeto = 200 -- safe fail.
		else
			rangeto = math.sqrt(((ex - x)*(ex - x)) + ((ez - z) * (ez - z)))
		end
	else
		ex = target[1]
		ez = target[3]
		rangeto = math.sqrt(((target[1] - x)*(target[1] - x)) + ((target[3] - z)*(target[3]-z)))
	end
	local angle = -99
	if ex then
		local az = ez - z
		local ax = ex - x
		angle = math.atan(az/ax)
	end
	local diff = range - rangeto
	--Spring.Echo("Angle: " .. angle .. ", Heading: " .. heading)
	local headingDiff = 0
	if angle > heading and (heading > 0 or angle < 0) then -- + - or - -
		headingDiff = angle - heading
	elseif angle > heading then -- + -
		headingDiff = angle + heading
	elseif heading > angle and (angle > 0 or heading < 0) then -- + - or - -
		headingDiff = heading - angle
	elseif heading > angle then
		headingDiff = heading + angle
	end
	headingDiff = math.abs(headingDiff)
	--Spring.Echo("Target Range: " .. rangeto .. "\nDif: " .. diff .. "\nAngle Dif: " .. headingDiff .. " / " .. tolerance)
	if diff < 20 and diff > -40 and headingDiff <= tolerance then
		Terminate(ex, Spring.GetGroundHeight(ex, ez), ez)
	end
	return true
end

function script.QueryWeapon()
	return missile
end

function script.Activate()
	StartThread(UnBurrow)
end

function script.Deactivate()
	Spring.SetUnitCloak(unitID, 2)
	Spring.SetUnitStealth(unitID, true)
end

function script.StopMoving()
	StartThread(Burrow)
end

function Detonate() -- Giving an order causes recursion.
	local h = GetHeading()
	local ux, _, uy = Spring.GetUnitPosition(unitID)
	if range ~= range then -- prevent NaN from 2025.03.9
		range = 10
	end
	local x = ux + (range * math.sin(h))
	local y = uy + (range * math.cos(h))
	Terminate(x, Spring.GetGroundHeight(x,y), y)
end

function script.Killed(recentDamage, maxHealth)
	if not terminated then
		Death()
	end
	Explode(base, SFX.EXPLODE + SFX.FIRE + SFX.SMOKE)
	--Explode(l_wing, SFX.EXPLODE)
	--Explode(r_wing, SFX.EXPLODE)
	
	Explode(missile, SFX.SHATTER)
	
	--Explode(l_fan, SFX.EXPLODE)
	--Explode(r_fan, SFX.EXPLODE)
	
	local severity = recentDamage / maxHealth
	if (severity <= 0.5) or ((Spring.GetUnitMoveTypeData(unitID).aircraftState or "") == "crashing") then
		return 1 -- corpsetype
	else
		return 2 -- corpsetype
	end
end
