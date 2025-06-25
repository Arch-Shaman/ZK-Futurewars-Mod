local body = piece "body"
local tail = piece "tail"
local enginel = piece "enginel"
local enginer = piece "enginer"
local wingl = piece "wingl"
local wingr = piece "wingr"
local firepoint = piece "firepoint"

include "constants.lua"
include "bombers.lua"
include "fixedwingTakeOff.lua"

local spGetUnitPieceDirection = Spring.GetUnitPieceDirection
local sqrt = math.sqrt
local atan2 = math.atan2

local smokePiece = {body}

--Signal
local SIG_move = 1
local SIG_TAKEOFF = 2
local takeoffHeight = UnitDefNames["dronecarrybomber"].cruiseAltitude

local OKP_DAMAGE = tonumber(UnitDefs[unitDefID].customParams.okp_damage)

local eighthTurn =  math.rad(45)
local currentAngle = math.rad(90)

local function Stopping()
	Signal(SIG_move)
	SetSignalMask(SIG_move)
	Move(enginel, x_axis, -2, 2)
	Move(enginer, x_axis,  2, 2)
	Turn(wingl, z_axis,  eighthTurn, eighthTurn)
	Turn(wingr, z_axis, -eighthTurn, eighthTurn)
end

local function Moving()
	Signal(SIG_move)
	SetSignalMask(SIG_move)
	Move(enginel, x_axis, 0, 2)
	Move(enginer, x_axis, 0, 2)
	Turn(wingl, z_axis, 0, eighthTurn)
	Turn(wingr, z_axis, 0, eighthTurn)
end

function script.StartMoving()
	StartThread(Moving)
end

function script.StopMoving()
	StartThread(Stopping)
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
end

function script.Create()
	SetInitialBomberSettings()
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	Move(enginel, x_axis, -2)
	Move(enginer, x_axis,  2)
	Turn(wingl, z_axis,  eighthTurn)
	Turn(wingr, z_axis, -eighthTurn)
	Turn(firepoint, y_axis, -currentAngle)
	--Hide(drop)
end


function script.FireWeapon(num)
	Sleep(33) -- delay before clearing attack order; else bomb loses target and fails to home
	SetUnarmedAI()
	Reload()
end

function script.AimWeapon(num, heading, pitch)
	return (Spring.GetUnitRulesParam(unitID, "noammo") ~= 1)
end

function script.QueryWeapon(num)
	return firepoint
end

function script.Shot(num)
	Turn(firepoint, y_axis, currentAngle)
	currentAngle = -currentAngle
end


local function ResetTurnRadius()
	Signal(SIG_NOT_BLOCKED)
	SetSignalMask(SIG_NOT_BLOCKED)
	Sleep(500)
	SetUnarmedAI(300)
end

function script.BlockShot(num, targetID)
	if GG.OverkillPrevention_CheckBlockNoFire(unitID, targetID, OKP_DAMAGE, 550, false, false, false) then
		-- Remove attack command on blocked target, if it is followed by another attack command. This is commands queued in an area.
		local cmdID, _, cmdTag, cp_1, cp_2 = Spring.GetUnitCurrentCommand(unitID)
		if cmdID == CMD.ATTACK and (not cp_2) and cp_1 == targetID then
			local cmdID_2, _, _, cp_1_2, cp_2_2 = Spring.GetUnitCurrentCommand(unitID, 2)
			if cmdID_2 == CMD.ATTACK and (not cp_2_2) then
				local cQueue = Spring.GetCommandQueue(unitID, 1)
				Spring.GiveOrderToUnit(unitID, CMD.REMOVE, cmdTag, 0)
			end
		end
		return true
	end
	return GG.Script.OverkillPreventionCheck(unitID, targetID, OKP_DAMAGE, 550, 550, 0, true, false, 0.8)
end

local explodables = {tail, enginel, enginer, wingl, wingr}
function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	local effect = SFX.FALL + SFX.SMOKE + (severity > 0.5 and SFX.FIRE or 0) + (severity > 0.75 and SFX.EXPLODE or 0)
	
	for i = 1, #explodables do
		if math.random() < severity then
			Explode (explodables[i], effect)
		end
	end
end
