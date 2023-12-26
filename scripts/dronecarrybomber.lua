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

local halfturn =  math.rad(45)

local function Stopping()
	Signal(SIG_move)
	SetSignalMask(SIG_move)
	Move(enginel, x_axis, -2, 2)
	Move(enginer, x_axis,  2, 2)
	Turn(wingl, z_axis,  halfturn, halfturn)
	Turn(wingr, z_axis, -halfturn, halfturn)
end

local function Moving()
	Signal(SIG_move)
	SetSignalMask(SIG_move)
	Move(enginel, x_axis, 0, 2)
	Move(enginer, x_axis, 0, 2)
	Turn(wingl, z_axis, 0, halfturn)
	Turn(wingr, z_axis, 0, halfturn)
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
	Turn(wingl, z_axis,  halfturn)
	Turn(wingr, z_axis, -halfturn)
	--Hide(drop)
end


function script.FireWeapon(num)
	if num == 2 then
		Sleep(33) -- delay before clearing attack order; else bomb loses target and fails to home
		Signal(SIG_NOT_BLOCKED)
		SetUnarmedAI()
		Reload()
	end
end

function script.AimWeapon(num)
	return true
end

function script.QueryWeapon(num)
	return firepoint
end


local function ResetTurnRadius()
	Signal(SIG_NOT_BLOCKED)
	SetSignalMask(SIG_NOT_BLOCKED)
	Sleep(500)
	SetUnarmedAI(300)
end

local function GetAimLocation(targetID)
	if not targetID then
		local targetType, isUser, pos = Spring.GetUnitWeaponTarget(unitID, 2)
		if targetType == 2 and pos then
			return pos[1], pos[2], pos[3]
		end
		return false
	end
	local _,_,_,_,_,_,tx,ty,tz = spGetUnitPosition(targetID, true, true)
	local vx,vy,vz = spGetUnitVelocity(targetID)
	vx, vy, vz = vx*predictMult, vy*predictMult, vz*predictMult
	return tx + vx, ty + vy, tz + vz
end

function script.BlockShot(num, targetID)
	-- This is a copy of raven LIS
	if num == 1 then
		return true
	end
	local ableToFire = not ((GetUnitValue(COB.CRASHING) == 1) or RearmBlockShot())
	if not ableToFire then
		return not ableToFire
	end
	SetUnarmedAI() -- Unarmed before firing because low turn radius fixes the turn aside bug. Try to hit a Flea retreating up a slope without this.
	StartThread(ResetTurnRadius)
	
	local tx, ty, tz = GetAimLocation(targetID)
	--Spring.MarkerAddPoint(tx, ty, tz,"")
	if not tx then
		return false
	end
	local x,y,z = spGetUnitPosition(unitID)
	local dx, dy, dz = tx - x, ty - y, tz - z
	local heading = spGetUnitHeading(unitID)*GG.Script.headingToRad
	local cosHeading = math.cos(heading)
	local sinHeading = math.sin(heading)
	dx, dz = cosHeading*dx - sinHeading*dz, cosHeading*dz + sinHeading*dx
	
	local isMobile = targetID and not GG.IsUnitIdentifiedStructure(true, targetID)
	local damage = targetID and GG.OverkillPrevention_GetHealthThreshold(targetID, 700.1, 670.1)
	
	--Spring.Echo(vx .. ", " .. vy .. ", " .. vz)
	--Spring.Echo(dx .. ", " .. dy .. ", " .. dz)
	--Spring.Echo(heading)
	if targetID and GG.OverkillPrevention_CheckBlockNoFire(unitID, targetID, damage, 40, false, false, false) then
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
	
	local hDist = math.sqrt(dx*dx + dz*dz)
	
	if dy > 0 or hDist*1.15 > -dy then
		return true
	end
	
	local isTooFast = false -- Do not OKP for too fast targets as we don't expect to hit.
	if isMobile then
		local speed = EstimateCurrentMaxSpeed(targetID)
		if speed >= 3 then
			isTooFast = true
		end
		--Spring.Echo(hDist, speed, math.max(3, -dy - speed*90 - 35))
		-- Cap out at speed 2.7 on normal terrain
		local diffFactor = -dy
		if diffFactor > takeoffHeightInElmos then
			-- Reduce apparently height difference for cone in cases where Raven is higher than usual.
			-- This can happen when the Raven crests a cliff, or against underwater targets.
			diffFactor = takeoffHeightInElmos*(diffFactor + takeoffHeightInElmos) / (2*diffFactor)
		end
		--Spring.Echo("diffFactor", diffFactor, -dy, takeoffHeightInElmos)
		if hDist > math.max(3, diffFactor - speed*90 - 35) then
			return true
		end
	end
	
	--if (dz > 30 or dz < -30 or dx > 80 or dx < -80) then
		--return true
	--end
	
	if targetID and (not isTooFast) and GG.Script.OverkillPreventionCheck(unitID, targetID, damage, 270, 35, 0.025) then
		return true
	end
	local xDir, yDir, zDir = spGetUnitPieceDirection(unitID, firepoint)
	Turn(firepoint, x_axis, -atan2(xDir, yDir))
	Turn(firepoint, z_axis, -atan2(sqrt(xDir^2 + yDir^2), zDir))
	return false
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
