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
local halfAngle = math.rad(180)
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
	--local angleDiffHeading = CalculateAngleDifference(heading1, heading2)
	--local angleDiffPitch = CalculateAngleDifference(pitch1, pitch2)
	--Spring.Echo("Heading: " .. heading1 .. ", " .. heading2 .. "\nPitch: " .. pitch1 .. ", " .. pitch2)
	--Spring.Echo("Heading Diff: " .. angleDiffHeading .. " [Max: " .. headingerror .. "]\n " .. "Pitch Diff: " .. angleDiffPitch .. " [Max: " .. pitcherror .. "]")
	if CalculateAngleDifference(heading1, heading2) > headingerror then
		return false
	elseif CalculateAngleDifference(pitch1, pitch2) > pitcherror then
		return false
	else
		return frame - lastAimFrame <= aimTimeout
	end
end

local function isCommCloseEnough(heading1, heading2, pitch1, pitch2, lastAimFrame, headingerror, pitcherror, aimTimeout)
	if not (heading1 and heading2 and pitch1 and pitch2) then
		return false
	end
	--local angleDiffHeading = CalculateAngleDifference(heading1, heading2)
	--local angleDiffPitch = CalculateAngleDifference(pitch1, pitch2)
	--Spring.Echo("Heading: " .. heading1 .. ", " .. heading2 .. "\nPitch: " .. pitch1 .. ", " .. pitch2)
	--Spring.Echo("Heading Diff: " .. angleDiffHeading .. " [Max: " .. headingerror .. "]\n " .. "Pitch Diff: " .. angleDiffPitch .. " [Max: " .. pitcherror .. "]")
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

local function FixAngle(angle) -- turns a negative angle into a positive one. IE: -5 -> 355
	if angle >= 0 then return angle end
	return fullCircle + angle
end

local function GetAdjustedHeading(heading, unitHeading)
	return (heading + unitHeading) % fullCircle
end

function GG.AimDelay_CommAttemptToFire(unitID, weaponNum, heading, pitch, delay, allowedHeadingError, allowedPitchError, aimTimeout)
	--[[Goal is to get the 'world angle' from the turret's aim point and current unit heading.
	This makes it agnostic to facing (remember: that shifts as the unit rotates)
	This version handles comms and is more "dynamic"
	]]
	local fixedHeading = FixAngle(heading)
	local unitHeading = Spring.GetUnitHeading(unitID, true) or 0
	unitHeading = FixAngle(unitHeading - halfAngle) -- 180 degrees is "north" in spring. 0 is south.
	unitDelayedArray[unitID] = unitDelayedArray[unitID] or {}
	unitDelayedArray[unitID][weaponNum] = unitDelayedArray[unitID][weaponNum] or {
		heading = false,
		pitch = false,
		delayedUntil = 0,
		forcereset = false,
		lastAimFrame = frame,
		originalHeading = 0,
	}
	local adjustedHeading = GetAdjustedHeading(fixedHeading, unitHeading)
	--unitDelayedArray[unitID][weaponNum].previousUnitFacing = unitHeading
	local unitData = unitDelayedArray[unitID][weaponNum]
	--Spring.Echo("UnitHeading is: " .. unitHeading .. "\nCurrent heading: " .. adjustedHeading .. " ( " .. heading .. ", " .. fixedHeading .. ")\nCurrent aim heading: " .. tostring(unitDelayedArray[unitID][weaponNum].heading))
	if not isCommCloseEnough(unitData.heading, adjustedHeading, unitData.pitch, pitch, unitData.lastAimFrame, allowedHeadingError, allowedPitchError, aimTimeout) or unitData.forcereset then
		unitData.delayedUntil = frame + delay
		unitData.heading = adjustedHeading
		unitData.pitch = pitch
		unitData.forcereset = false
		unitData.lastAimFrame = frame
		--Spring.Echo("Aiming error, returning false")
		spSetUnitRulesParam(unitID, "aimdelay", unitData.delayedUntil, LOS_ACCESS) -- Tell LUAUI this unit is currently aiming!
		return false
	end
	unitDelayedArray[unitID][weaponNum].lastAimFrame = frame
	local delayTime = unitDelayedArray[unitID][weaponNum].delayedUntil - frame
	--Spring.Echo("AttemptToFire: " .. unitID .. ": " .. weaponNum .. " (" ..  tostring(frame >= unitData.delayedUntil) .. ")")
	CallInAsUnit(unitID, 1 - (delayTime / delay))
	return delayTime <= 0
end

function GG.AimDelay_AttemptToFire(unitID, weaponNum, heading, pitch, delay)
	--[[Goal is to get the 'world angle' from the turret's aim point and current unit heading.
	This makes it agnostic to facing (remember: that shifts as the unit rotates)
	]]
	local fixedHeading = FixAngle(heading)
	local unitHeading = Spring.GetUnitHeading(unitID, true) or 0
	unitHeading = FixAngle(unitHeading - halfAngle) -- 180 degrees is "north" in spring. 0 is south.
	unitDelayedArray[unitID] = unitDelayedArray[unitID] or {}
	unitDelayedArray[unitID][weaponNum] = unitDelayedArray[unitID][weaponNum] or {
		heading = false,
		pitch = false,
		delayedUntil = 0,
		forcereset = false,
		lastAimFrame = frame,
		originalHeading = 0,
	}
	local weaponDefID = UnitDefs[Spring.GetUnitDefID(unitID)].weapons[weaponNum].weaponDef or 0
	local adjustedHeading = GetAdjustedHeading(fixedHeading, unitHeading)
	--unitDelayedArray[unitID][weaponNum].previousUnitFacing = unitHeading
	local unitData = unitDelayedArray[unitID][weaponNum]
	--Spring.Echo("UnitHeading is: " .. unitHeading .. "\nCurrent heading: " .. adjustedHeading .. " ( " .. heading .. ", " .. fixedHeading .. ")\nCurrent aim heading: " .. tostring(unitDelayedArray[unitID][weaponNum].heading))
	if (not isCloseEnough(unitData.heading, adjustedHeading, unitData.pitch, pitch, weaponDefID, unitData.lastAimFrame)) or unitData.forcereset then
		unitData.delayedUntil = frame + delay
		unitData.heading = adjustedHeading
		unitData.pitch = pitch
		unitData.forcereset = false
		unitData.lastAimFrame = frame
		spSetUnitRulesParam(unitID, "aimdelay", unitData.delayedUntil, LOS_ACCESS) -- Tell LUAUI this unit is currently aiming!
		return false
	end
	unitDelayedArray[unitID][weaponNum].lastAimFrame = frame
	local delayTime = unitDelayedArray[unitID][weaponNum].delayedUntil - frame
	--Spring.Echo("AttemptToFire: " .. unitID .. ": " .. weaponNum .. " (" ..  tostring(frame >= unitData.delayedUntil) .. ")")
	CallInAsUnit(unitID, 1 - (delayTime / delay))
	return delayTime <= 0
end

function gadget:UnitDestroyed(unitID)
	unitDelayedArray[unitID] = nil
end

function gadget:GameFrame(f)
	frame = f -- this is so we're not calling spGetGameFrame multiple times in a single frame. We now get it more or less for free.
end
