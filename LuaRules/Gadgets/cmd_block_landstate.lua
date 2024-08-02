if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name     = "Block Land state Commands",
		desc     = "Blocks Land State changes for certain units",
		author   = "Shaman",
		date     = "August 2, 2024",
		license  = "CC-0",
		layer    = 11,
		enabled  = true
	}
end

local unitsThatCantLand = {}
for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	if ud.customParams.cantland then
		unitsThatCantLand[i] = true
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if unitsThatCantLand[unitDefID] and cmdID == CMD.IDLEMODE and cmdParams[1] ~= 0 then
		return false
	else
		return true
	end
end
