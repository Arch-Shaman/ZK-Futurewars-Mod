local wantedefs = {}
wantedefs[UnitDefNames["staticnuke"].id] = {targets = 3, range = 1000}

for index, data in pairs(wantedefs) do
	data.range2 = data.range^2
end

return wantedefs
