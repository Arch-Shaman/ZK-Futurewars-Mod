local wantedefs = {}
wantedefs[UnitDefNames["staticnuke"].id] = {targets = 5, range = 2500, noTargetRange = 1000, UIaoe = 800}
wantedefs[UnitDefNames["subtacmissile"].id] = {targets = 6, range = 500, noTargetRange = 100, UIaoe = 80}

for index, data in pairs(wantedefs) do
	data.range2 = data.range^2
end

return wantedefs
