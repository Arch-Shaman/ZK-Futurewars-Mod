function gadget:GetInfo()
	return {
		name      = "Weapon Aim Delay",
		desc      = "After aiming at a new target, the weapon must wait before firing again",
		author    = "ThornEel",
		date      = "12/28/2020",
		license   = "CC-0",
		layer     = 0,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--local SAVE_FILE = "Gadgets/weapon_aimdelay.lua" -- TODO manage saves

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local abs = math.abs
local allowedHeadingError = 0.000001 -- to allow for micro-variations in heading even when firing at fixed positions
local allowedPitchError = 0.01 -- to allow for cratering
local WeaponDefOverrides = {}

local abs = math.abs

for i = 1, #WeaponDefs do
	if WeaponDefs[i].customParams.allowedpitcherror or WeaponDefs[i].customParams.allowedheadingerror then
		local headingError = tonumber(WeaponDefs[i].customParams.allowedheadingerror) or allowedHeadingError
		local pitchError = tonumber(WeaponDefs[i].customParams.allowedpitcherror) or allowedPitchError
		WeaponDefOverrides[i] = {
			heading = math.rad(headingError), 
			pitch = math.rad(pitchError), 
			aimReset = tonumber(WeaponDefs[i].customParams.aimdelayresettime) or 60,
		}
	end
end

local LOS_ACCESS = {inlos = true}
local fullCircle = math.rad(360)

--local unitDefsArray = {}
local unitDelayedArray = {}
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local frame = -1

local function CallAsUnitIfExists(unitID, funcName, ...)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if not env then
		return
	end
	if env and env[funcName] then
		Spring.UnitScript.CallAsUnit(unitID, env[funcName], ...)
	end
end

local function CallInAsUnit(unitID, trackProgress)
	CallAsUnitIfExists(unitID, "OnTrackProgress", trackProgress)
end

local function CalculateAngleDifference(angle1, angle2)
	local clockWise = abs(angle1 - angle2)
	local counterClockwise
	if clockWise < 0 then
		counterClockwise = fullCircle + clockWise
	else
		counterClockwise = fullCircle - clockWise
	end
	if clockWise < counterClockwise then
		return clockWise
	else
		return counterClockwise
	end
end

local function isCloseEnough(heading1, heading2, pitch1, pitch2, weaponDefID, lastAimFrame)
	local headingerror = allowedHeadingError
	local pitcherror = allowedPitchError
	local aimTimeout = 60
	if WeaponDefOverrides[weaponDefID] then
		headingerror = WeaponDefOverrides[weaponDefID].heading
		pitcherror = WeaponDefOverrides[weaponDefID].pitch
		aimTimeout = WeaponDefOverrides[weaponDefID].aimReset
	end
	if not (heading1 and heading2 and pitch1 and pitch2) then
		return false
	end
	if CalculateAngleDifference(heading1, heading2) > headingerror then
		return false
	elseif CalculateAngleDifference(pitch1, pitch2) > pitcherror then
		return false
	else
		return frame - lastAimFrame <= aimTimeout
	end
end

function GG.AimDelay_ForceWeaponRestart(unitID, weaponNum, delay)
	if unitDelayedArray[unitID] then
		unitDelayedArray[unitID][weaponNum].forcereset = true
		if delay then
			unitDelayedArray[unitID][weaponNum].delayedUntil = frame + delay
			spSetUnitRulesParam(unitID, "aimdelay", frame + delay, LOS_ACCESS) -- Tell LUAUI this unit is currently aiming!
		end
	end
end

function GG.AimDelay_AttemptToFire(unitID, weaponNum, heading, pitch, delay)
	unitDelayedArray[unitID] = unitDelayedArray[unitID] or {}
	unitDelayedArray[unitID][weaponNum] = unitDelayedArray[unitID][weaponNum] or {
		heading = false,
		pitch = false,
		delayedUntil = 0,
		forcereset = false,
		lastAimFrame = frame,
	}
	local weaponDefID = UnitDefs[Spring.GetUnitDefID(unitID)].weapons[weaponNum].weaponDef or 0
	local weaponDelay = unitDelayedArray[unitID][weaponNum]
	if (not isCloseEnough(weaponDelay.heading, heading, weaponDelay.pitch, pitch, weaponDefID, weaponDelay.lastAimFrame)) or weaponDelay.forcereset then
		unitDelayedArray[unitID][weaponNum].delayedUntil = frame + delay
		unitDelayedArray[unitID][weaponNum].heading = heading
		unitDelayedArray[unitID][weaponNum].pitch = pitch
		unitDelayedArray[unitID][weaponNum].forcereset = false
		unitDelayedArray[unitID][weaponNum].lastAimFrame = frame
		spSetUnitRulesParam(unitID, "aimdelay", weaponDelay.delayedUntil, LOS_ACCESS) -- Tell LUAUI this unit is currently aiming!
		return false
	end
	unitDelayedArray[unitID][weaponNum].lastAimFrame = frame
	local delayTime = unitDelayedArray[unitID][weaponNum].delayedUntil - frame
	--Spring.Echo("AttemptToFire: " .. unitID .. ": " .. weaponNum .. " (" ..  tostring(frame >= weaponDelay.delayedUntil) .. ")")
	CallInAsUnit(unitID, 1 - (delayTime / delay))
	return delayTime <= 0
end

function gadget:UnitDestroyed(unitID)
	unitDelayedArray[unitID] = nil
end

function gadget:GameFrame(f)
	frame = f -- this is so we're not calling spGetGameFrame multiple times in a single frame. We now get it more or less for free.
end
