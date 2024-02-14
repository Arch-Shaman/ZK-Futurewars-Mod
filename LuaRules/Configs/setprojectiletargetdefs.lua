local wantedefs = {}

do
	local nukedef = UnitDefNames["staticnuke"].id
	local nukesubdef = UnitDefNames["subtacmissile"].id
	local nukecp = WeaponDefs[nukedef.weapons[1].id].customParams
	local subcp = WeaponDefs[nukesubdef.weapons[1].id].customParams
	local nukeRange = tonumber(nukecp.mirvrange) or 2500
	local subRange = tonumber(subcp.mirvrange) or 500
	wantedefs[nukedef.id] = {targets = tonumber(nukecp.numprojectiles1) or 5, range = nukeRange, noTargetRange = nukeRange/5, UIaoe = 800}
	wantedefs[UnitDefNames["subtacmissile"].id] = {targets = tonumber(subcp.numprojectiles1) or 5, range = subRange, noTargetRange = subRange/5, UIaoe = 80}
end

for index, data in pairs(wantedefs) do
	data.range2 = data.range^2
end

return wantedefs
