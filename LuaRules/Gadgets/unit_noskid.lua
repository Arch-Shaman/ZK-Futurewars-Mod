if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Fix Skidding",
		desc      = "No more skating units.",
		author    = "Shaman",
		date      = "",
		license   = "CC-0",
		layer     = 0, -- needs to be later than OD.
		enabled   = true  --  loaded by default?
	}
end


local spMcSetGroundMoveTypeData = Spring.MoveCtrl.SetGroundMoveTypeData


function gadget:UnitCreated(unitID, unitDefID)
	if UnitDefs[unitDefID].isGroundUnit then
		spMcSetGroundMoveTypeData(unitID, "sqSkidSpeedMult", 100)
	end
end
