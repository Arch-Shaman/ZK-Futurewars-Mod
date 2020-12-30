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

local unitDefsArray = {}
local unitDelayedArray = {}

--function gadget:GameFrame(f)
--  for i=1, #unitDelayedArray do
--    for j=1, #unitDelayedArray[i] do
      
--      if (not unitDelayedArray[i][j].canFire) then -- we skip the delays that are already over
--        local weaponDelayed = unitDelayedArray[i][j]
--        if (weaponDelayed.untilFrame == false) then
--          weaponDelayed.untilFrame = f + weaponDelayed.delay
--          Spring.Log("Sunlance", "warning", "blocking shot for " .. weaponDelayed.delay .. " frames") -- TODO remove once over
--        elseif (weaponDelayed.untilFrame <= f) then
--          Spring.Log("Sunlance", "warning", "can now fire") -- TODO remove once over
--          weaponDelayed.canFire = true
--        end
--      end
      
--    end
--  end
--end

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
---- External Functions

--local externalFunctions = {}

--function externalFunctions.StartDelayIfNewAimingPoint(unitID, weaponNum, heading, pitch, delay)
--  local unitDelayed = unitDelayedArray[unitID] or {}
    
--  local oldDelay = unitDelayed[weaponNum]
--  if (not oldDelay or oldDelay.pitch ~= pitch or oldDelay.heading ~= heading) then
--    unitDelayed[weaponNum] = {
--      canFire = false,
--      pitch = pitch,
--      heading = heading,
--      delay = delay,
--      untilFrame = false,
--    }
--    unitDelayedArray[unitID] = unitDelayed
--  end
--end

--function externalFunctions.CheckIfDelayIsOver(unitID, weaponNum)
--  local unitDelayed = unitDelayedArray[unitID] or {}
--  if (unitDelayed[weaponNum]) then
--    return unitDelayed[weaponNum].canFire
--  end
--  return true
--end

--function gadget:Initialize()
--	GG.AimDelay = externalFunctions
--end





function GG.AimDelay_AttemptToFire(unitID, weaponNum, heading, pitch, delay)
  
  unitDelayedArray[unitID] = unitDelayedArray[unitID] or {}
  unitDelayedArray[unitID][weaponNum] = unitDelayedArray[unitID][weaponNum] or {
    heading = false,
    pitch = false,
    delayedUntil = 0,
  }
  weaponDelay = unitDelayedArray[unitID][weaponNum]
  
  if (weaponDelay.heading ~= heading or weaponDelay.pitch ~= pitch) then
    weaponDelay.delayedUntil = Spring.GetGameFrame() + delay
    weaponDelay.heading = heading
    weaponDelay.pitch = pitch
--    Spring.Log("Sunlance", "warning", "waiting for " .. delay .. " frames, until " .. weaponDelay.delayedUntil) -- TODO remove once over
--    Spring.Log("Sunlance", "warning", "pitch " .. weaponDelay.pitch .. " vs " .. unitDelayedArray[unitID][weaponNum].pitch) -- TODO remove once over
    return false
  end
  
--  if (Spring.GetGameFrame() >= weaponDelay.delayedUntil) then
--    Spring.Log("Sunlance", "warning", "firing weapon at " .. heading .. ", " .. pitch) -- TODO remove once over
--  end
  return (Spring.GetGameFrame() >= weaponDelay.delayedUntil)
  
end
