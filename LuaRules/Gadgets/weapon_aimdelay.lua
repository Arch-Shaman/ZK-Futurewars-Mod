function gadget:GetInfo()
	return {
		name      = "Weapon Aim Delay",
		desc      = "After aiming at a new target, the weapon muwt wait before firing again",
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

local LOS_ACCESS = {inlos = true}

--local unitDefsArray = {}
local unitDelayedArray = {}


local function isCloseEnough(heading1, heading2, pitch1, pitch2)
  if (heading1 == false or heading2 == false or pitch1 == false or pitch2 == false) then
    return false
  end
  if (abs(heading1 - heading2) > allowedHeadingError) then
    return false
  end
  if (abs(pitch1 - pitch2) > allowedPitchError) then
    return false
  end
  return true
end


function GG.AimDelay_AttemptToFire(unitID, weaponNum, heading, pitch, delay)
  
  unitDelayedArray[unitID] = unitDelayedArray[unitID] or {}
  unitDelayedArray[unitID][weaponNum] = unitDelayedArray[unitID][weaponNum] or {
    heading = false,
    pitch = false,
    delayedUntil = 0,
  }
  local weaponDelay = unitDelayedArray[unitID][weaponNum]
  
  if (not isCloseEnough(weaponDelay.heading, heading, weaponDelay.pitch, pitch)) then
    weaponDelay.delayedUntil = Spring.GetGameFrame() + delay
    weaponDelay.heading = heading
    weaponDelay.pitch = pitch
      Spring.SetUnitRulesParam(unitID, "specialReloadFrame", weaponDelay.delayedUntil, LOS_ACCESS)
    return false
  end
  
  return (Spring.GetGameFrame() >= weaponDelay.delayedUntil)
  
end
