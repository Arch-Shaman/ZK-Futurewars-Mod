if (not gadgetHandler:IsSyncedCode()) then return end

function gadget:GetInfo() return {
	name      = "Structure-like Fixer",
	desc      = "Fixes caretakers on unload",
	author    = "Shaman",
	date      = "14 April 2023",
	license   = "CC-0",
	layer     = 0,
	enabled   = true,
} end

local wantedDefs = {}
for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	if ud.isImmobile then
		wantedDefs[i] = true
	end
end

local oldAngles = {}

local function StoreRotation(unitID)
	local x, y, z = Spring.GetUnitDirection(unitID)
	local rx, ry, rz = Spring.GetUnitRotation(unitID)
	oldAngles[unitID] = {x, y, z, rx, ry, rz}
end

function gadget:UnitCreated(unitID, unitDefID)
	if wantedDefs[unitDefID] and UnitDefs[unitDefID].metalCost < 1500 then
		StoreRotation(unitID)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if wantedDefs[unitDefID] and oldAngles[unitID] then
		local rx, ry, rz = Spring.GetUnitRotation(unitID)
		Spring.SetUnitRotation(unitID, oldAngles[unitID][4], oldAngles[unitID][5], oldAngles[unitID][6])
		Spring.SetUnitDirection(unitID, oldAngles[unitID][1], oldAngles[unitID][2], oldAngles[unitID][3]) 
	end
end

function gadget:UnitDestroyed(unitID)
	oldAngles[unitID] = nil
end
