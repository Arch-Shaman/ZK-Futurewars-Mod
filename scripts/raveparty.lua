include "pieceControl.lua"

local base, turret, spindle, fakespindle = piece('base', 'turret', 'spindle', 'fakespindle')

local guns = {}
for i=1,6 do
	guns[i] = {
		center = piece('center'..i),
		sleeve = piece('sleeve'..i),
		barrel = piece('barrel'..i),
		flare = piece('flare'..i),
		y = 0,
		z = 0,
	}
end

local hpi = math.pi*0.5

local headingSpeed = math.rad(4)
local pitchSpeed = math.rad(30)
local maxPitchSpeed = math.rad(1800)

local spindleOffset = 0
local spindlePitch = 0

guns[5].y = 11
guns[5].z = 7

local dis = math.sqrt(guns[5].y^2 + guns[5].z)
local ratio = math.tan(math.rad(60))

guns[6].y = guns[5].y + ratio*guns[5].z
guns[6].z = guns[5].z - ratio*guns[5].y
local dis6 = math.sqrt(guns[6].y^2 + guns[6].z^2)
guns[6].y = guns[6].y*dis/dis6
guns[6].z = guns[6].z*dis/dis6

guns[4].y = guns[5].y - ratio*guns[5].z
guns[4].z = guns[5].z + ratio*guns[5].y
local dis4 = math.sqrt(guns[4].y^2 + guns[4].z^2)
guns[4].y = guns[4].y*dis/dis4
guns[4].z = guns[4].z*dis/dis4

guns[1].y = -guns[4].y
guns[1].z = -guns[4].z

guns[2].y = -guns[5].y
guns[2].z = -guns[5].z

guns[3].y = -guns[6].y
guns[3].z = -guns[6].z

for i=1,6 do
	guns[i].ys = math.abs(guns[i].y)
	guns[i].zs = math.abs(guns[i].z)
end

local smokePiece = {spindle, turret}

include "constants.lua"

-- Signal definitions
local SIG_AIM = 2

local gunNum = 1
local weaponNum = 1
local randomize = true

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	Turn(spindle, x_axis, spindleOffset + spindlePitch)
	for i = 1, 6 do
		Turn(guns[i].flare, x_axis, (math.rad(-60)* i + 1))
	end
end

function script.HitByWeapon()
	if Spring.GetUnitRulesParam(unitID,"disarmed") == 1 then
		GG.PieceControl.StopTurn (turret, y_axis)
		GG.PieceControl.StopTurn (spindle, x_axis)
	end
end

local sleeper = {}
for i = 1, 6 do
	sleeper[i] = false
end

function script.AimWeapon(num, heading, pitch)
	if num == 7 then -- metrenome cannot fire.
		return false
	end
	if (sleeper[num]) then
		return false
	end

	sleeper[num] = true
	while weaponNum ~= num or (Spring.GetUnitRulesParam(unitID, "lowpower") or 0) == 1 do
		Sleep(10)
	end
	sleeper[num] = false

	Signal (SIG_AIM)
	SetSignalMask (SIG_AIM)

	while Spring.GetUnitRulesParam(unitID,"disarmed") == 1 do
		Sleep(10)
	end
	local curHead = select (2, Spring.UnitScript.GetPieceRotation(turret))
	local headDiff = heading-curHead
	if math.abs(headDiff) > math.pi then
		headDiff = headDiff - math.abs(headDiff)/headDiff*2*math.pi
	end
	--Spring.Echo(headDiff*180/math.pi)

	if math.abs(headDiff) > hpi then
		heading = (heading+math.pi)%math.tau
		pitch = -pitch+math.pi
	end
	spindlePitch = -pitch
	local slowMult = (Spring.GetUnitRulesParam(unitID,"baseSpeedMult") or 1)
	local speedMult = (Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0) * slowMult
	local effectivePitchSpeed = pitchSpeed * speedMult, maxPitchSpeed
	Turn(turret, y_axis, heading, headingSpeed*slowMult*speedMult)
	Turn(spindle, x_axis, spindlePitch+spindleOffset, effectivePitchSpeed)
	WaitForTurn(turret, y_axis)
	WaitForTurn(spindle, x_axis)
	return (Spring.GetUnitRulesParam(unitID,"disarmed") ~= 1) and (Spring.GetUnitRulesParam(unitID, "lowpower") or 0) ~= 1
end

function script.AimFromWeapon(num)
	return spindle
end

function script.QueryWeapon(num)
	return guns[gunNum].flare
end

local function gunFire(num)
	local speedMult = (Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0) + 1
	Move(guns[num].barrel, z_axis, guns[num].z*1.2, 8*guns[num].zs)
	Move(guns[num].barrel, y_axis, guns[num].y*1.2, 8*guns[num].ys)
	WaitForMove(guns[num].barrel, y_axis)
	Move(guns[num].barrel, z_axis, 0, 0.2*guns[num].zs)
	Move(guns[num].barrel, y_axis, 0, 0.2*guns[num].ys)
end

local function PickNewWeapon()
	local r = math.random(0, 1000)
	if r < 150 then -- 15%
		return 1 -- red
	elseif r < 300 then -- 15%
		return 2 -- orange
	elseif r < 450 then -- 15%
		return 3 -- yellow
	elseif r < 600 then -- 15%
		return 4 -- green
	elseif r < 750 then -- 15%
		return 5 -- blue
	elseif r < 900 then -- 15%
		return 6 -- violet
	elseif r < 950 then -- 5%
		return 9 -- ruby
	elseif r < 990 then -- 4%
		return 10 -- rainbow
	else -- 1%
		return 8 -- sapphire (singularity should be fairly rare)
	end
end

function script.Shot(num)
	--EmitSfx(base, 1024) BASE IS NOT CENTRAL
	EmitSfx(guns[gunNum].flare, 1025)
	EmitSfx(guns[gunNum].flare, 1026)
	StartThread(gunFire, gunNum)
end

function script.FireWeapon(num)
	GG.FireControl.WeaponFired(unitID, 7) -- Update Metrenome.
	local reloadspeed = Spring.GetUnitRulesParam(unitID,"superweapon_mult") or 0
	if reloadspeed <= 1 then
		reloadspeed = 1
	end
	if randomize then
		weaponNum = PickNewWeapon()
	else
		weaponNum = weaponNum + 1
		if weaponNum > 6 then
			weaponNum = 1
		end
	end
	gunNum = gunNum + 1
	if gunNum > 6 then
		gunNum = 1
	end
	spindleOffset = math.rad(60)*(gunNum)
end

function script.BlockShot(num, targetID)
	--Spring.Echo("Metrenome ready: " .. tostring(GG.FireControl.CanFireWeapon(unitID, 7)))
	return not GG.FireControl.CanFireWeapon(unitID, 7)
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(base, SFX.NONE)
		Explode(spindle, SFX.NONE)
		Explode(turret, SFX.NONE)
		return 1
	elseif severity <= .50 then
		Explode(base, SFX.NONE)
		Explode(spindle, SFX.NONE)
		Explode(turret, SFX.NONE)
		return 1
	elseif severity <= .99 then
		Explode(base, SFX.SHATTER)
		Explode(spindle, SFX.SHATTER)
		Explode(turret, SFX.SHATTER)
		return 2
	else
		Explode(base, SFX.SHATTER)
		Explode(spindle, SFX.SHATTER)
		Explode(turret, SFX.SHATTER)
		return 2
	end
end
