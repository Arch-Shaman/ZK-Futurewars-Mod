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
	if ud.customParams.like_structure then
		wantedDefs[i] = true
	end
end

local function GetUnitFixedRotation(facing)
	local degrees = math.deg(facing)
	--Spring.Echo("Fix degrees: " .. degrees)
	if degrees < 0 then degrees = 360 - degrees end
	if degrees >= 0 and degrees < 90 then
		return math.rad(0)
	elseif degrees >= 90 and degrees < 180 then
		return math.rad(90)
	elseif degrees >= 180 and degrees < 270 then
		return math.rad(180)
	else
		return math.rad(270)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if wantedDefs[unitDefID] then
		local rx, ry, rz = Spring.GetUnitRotation(unitID)
		Spring.SetUnitRotation(unitID, rx, GetUnitFixedRotation(ry), rz)
	end
end
