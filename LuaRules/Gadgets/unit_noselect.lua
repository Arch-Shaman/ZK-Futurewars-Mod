if (not gadgetHandler:IsSyncedCode()) then
	return false
end

function gadget:GetInfo()
	return {
		name      = "Enforce Nonselectability",
		desc      = "",
		author    = "Shaman",
		date      = "Nov 21, 2010",
		license   = "CC-0",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

local wantedDefs = {}
local SetUnitNoSelect = Spring.SetUnitNoSelect

for i = 1, #UnitDefs do
	if UnitDefs[i].customParams.notselectable == "1" then
		wantedDefs[i] = true
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if wantedDefs[unitDefID] then
		SetUnitNoSelect(unitID, true)
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if wantedDefs[unitDefID] and cmdID == CMD.MOVE then
		return false
	end
	return true
end

