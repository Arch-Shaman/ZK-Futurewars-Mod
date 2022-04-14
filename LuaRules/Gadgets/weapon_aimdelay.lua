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

for i = 1, #WeaponDefs do
	if WeaponDefs[i].customParams.allowedpitcherror or WeaponDefs[i].customParams.allowedheadingerror then
		WeaponDefOverrides[i] = {heading = tonumber(WeaponDefs[i].customParams.allowedheadingerror) or allowedHeadingError, pitch = tonumber(WeaponDefs[i].customParams.allowedpitcherror) or allowedPitchError}
	end
end

local LOS_ACCESS = {inlos = true}

--local unitDefsArray = {}
local unitDelayedArray = {}
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local frame = -1


local function isCloseEnough(heading1, heading2, pitch1, pitch2, weaponDefID)
	local headingerror = allowedHeadingError
	local pitcherror = allowedPitchError
	if WeaponDefOverrides[weaponDefID] then
		headingerror = WeaponDefOverrides[weaponDefID].heading
		pitcherror = WeaponDefOverrides[weaponDefID].pitch
	end
	if (heading1 == false or heading2 == false or pitch1 == false or pitch2 == false) then
		return false
	end
	if (abs(heading1 - heading2) > headingerror) then
		--Spring.Echo("Heading error: " .. abs(heading1 - heading2))
		return false
	end
	if (abs(pitch1 - pitch2) > pitcherror) then
		--Spring.Echo("Pitch error: " .. abs(heading1 - heading2))
		return false
	end
	return true
end

function GG.AimDelay_ForceWeaponRestart(unitID, weaponNum, delay)
	if unitDelayedArray[unitID] then
		unitDelayedArray[unitID][weaponNum].forcereset = true
	end
end

function GG.AimDelay_AttemptToFire(unitID, weaponNum, heading, pitch, delay)
	unitDelayedArray[unitID] = unitDelayedArray[unitID] or {}
	unitDelayedArray[unitID][weaponNum] = unitDelayedArray[unitID][weaponNum] or {
		heading = false,
		pitch = false,
		delayedUntil = 0,
		forcereset = false,
	}
	local weaponDelay = unitDelayedArray[unitID][weaponNum]
	local weaponDefID = UnitDefs[Spring.GetUnitDefID(unitID)].weapons[weaponNum].weaponDef or 0
	if (not isCloseEnough(weaponDelay.heading, heading, weaponDelay.pitch, pitch, weaponDefID)) or weaponDelay.forcereset then
		unitDelayedArray[unitID][weaponNum].delayedUntil = frame + delay
		unitDelayedArray[unitID][weaponNum].heading = heading
		unitDelayedArray[unitID][weaponNum].pitch = pitch
		unitDelayedArray[unitID][weaponNum].forcereset = false
		spSetUnitRulesParam(unitID, "aimdelay", weaponDelay.delayedUntil, LOS_ACCESS) -- Tell LUAUI this unit is currently aiming!
		return false
	end
	Spring.Echo("AttemptToFire: " .. unitID .. ": " .. weaponNum .. " (" ..  tostring(frame >= weaponDelay.delayedUntil) .. ")")
	return (frame >= weaponDelay.delayedUntil)
end

function gadget:UnitDestroyed(unitID)
	unitDelayedArray[unitID] = nil
end

function gadget:GameFrame(f)
	frame = f -- this is so we're not calling spGetGameFrame multiple times in a single frame. We now get it more or less for free.
end
