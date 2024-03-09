local function GetCollisionVolumeType(vtype)
	vtype = vtype:lower()
	if vtype == "ellipsoid" then
		vtype = 0
	elseif vtype == "box" then
		vtype = 2
	elseif vtype == "sphere" then
		vtype = 3
	else
		vtype = 1
	end
	return vtype
end

function Spring.Utilities.ResetUnitColVol(unitID)
	local axis = UnitDefs[Spring.GetUnitDefID(unitID)].customParams.colvolaxis or 0
	local colvol = UnitDefs[Spring.GetUnitDefID(unitID)].collisionVolume
	local vtype = colvol.type or "sphere" -- default is sphere, apparently.
	vtype = GetCollisionVolumeType(vtype)
	--Spring.Echo("Reset colvol: " .. axis)
	Spring.SetUnitCollisionVolumeData(unitID, colvol.scaleX, colvol.scaleY, colvol.scaleZ, colvol.offsetX, colvol.offsetY, colvol.offsetZ, vtype, 1, axis)
end

function Spring.Utilities.SetUnitColVolOffsets(unitID, x, y, z)
	local colvol = UnitDefs[Spring.GetUnitDefID(unitID)].collisionVolume
	local axis = UnitDefs[Spring.GetUnitDefID(unitID)].customParams.colvolaxis or 0
	local vtype = colvol.type or "sphere" -- default is sphere, apparently.
	vtype = GetCollisionVolumeType(vtype)
	--Spring.Echo("Setting colvol: " .. axis)
	Spring.SetUnitCollisionVolumeData(unitID, colvol.scaleX, colvol.scaleY, colvol.scaleZ, x, y, z, vtype, 1, axis)
end
