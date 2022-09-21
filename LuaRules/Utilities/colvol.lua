function Spring.Utilities.ResetUnitColVol(unitID)
	local colvol = UnitDefs[Spring.GetUnitDefID(unitID)].collisionVolume
	local vtype = colvol.type or "sphere" -- default is sphere, apparently.
	local axis
	if vtype == "ellipsoid" or vtype == "sphere" then
		axis = 0
	else
		axis = (vtype:find("%ax") and 0) or (vtype:find("%az") and 2) or (vtype:find("%a%ay") and 1) or 0
	end
	Spring.SetUnitCollisionVolumeData(unitID, colvol.scaleX, colvol.scaleY, colvol.scaleZ, colvol.offsetX, colvol.offsetY, colvol.offsetZ, vtype, 1, axis)
end

function Spring.Utilities.SetUnitColVolOffsets(unitID, x, y, z)
	local colvol = UnitDefs[Spring.GetUnitDefID(unitID)].collisionVolume
	local vtype = colvol.type or "sphere" -- default is sphere, apparently.
	local axis
	if vtype == "ellipsoid" or vtype == "sphere" then
		axis = 0
	else
		axis = (vtype:find("%ax") and 0) or (vtype:find("%az") and 2) or (vtype:find("%a%ay") and 1) or 0
	end
	Spring.SetUnitCollisionVolumeData(unitID, colvol.scaleX, colvol.scaleY, colvol.scaleZ, x, y, z, vtype, 1, axis)
end