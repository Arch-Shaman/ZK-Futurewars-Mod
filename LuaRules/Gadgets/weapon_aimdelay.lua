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

local LOS_ACCESS = {inlos = true}

local unitDefsArray = {}
local unitDelayedArray = {}

function GG.AimDelay_AttemptToFire(unitID, weaponNum, heading, pitch, delay)
  
  unitDelayedArray[unitID] = unitDelayedArray[unitID] or {}
  unitDelayedArray[unitID][weaponNum] = unitDelayedArray[unitID][weaponNum] or {
    heading = false,
    pitch = false,
    delayedUntil = 0,
  }
  local weaponDelay = unitDelayedArray[unitID][weaponNum]
  
  if (weaponDelay.heading ~= heading or weaponDelay.pitch ~= pitch) then
    weaponDelay.delayedUntil = Spring.GetGameFrame() + delay
    weaponDelay.heading = heading
    weaponDelay.pitch = pitch
      Spring.SetUnitRulesParam(unitID, "specialReloadFrame", weaponDelay.delayedUntil, LOS_ACCESS)
    return false
  end
  
  return (Spring.GetGameFrame() >= weaponDelay.delayedUntil)
  
end
