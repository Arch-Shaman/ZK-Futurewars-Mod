local ExtraCMDs = {}
local AMMO_SELECT_GENERIC = 20500

local num = 1
for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	if ud.customParams.ammocount then
		local name = "AMMO_SELECT_" .. string.upper(ud.name)
		ExtraCMDs[name] = AMMO_SELECT_GENERIC + num
		num = num + 1
	end
end

return ExtraCMDs
