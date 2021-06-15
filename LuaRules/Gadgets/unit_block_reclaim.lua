if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
  return {
    name      = "Block useless orders",
    desc      = "Blocks reclaim from units that cannot reclaim",
    author    = "Shaman",
    date      = "2021-05-15",
    license   = "GNU GPL, v2 or later",
    layer     = -1500,
    enabled   = true,
  }
end

local wantedunits = {[UnitDefNames["staticrepair"].id] = true}

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if wantedunits[unitDefID] and cmdID == CMD.RECLAIM then
		return false
	else
		return true
	end
end
