local ploppables = {
  "factoryhover",
  "factoryveh",
  "factorytank",
  "factoryshield",
  "factorycloak",
  "factoryamph",
  "factoryjump",
  "factoryspider",
  "factoryship",
  "factoryplane",
  "factorygunship",
}

ploppableDefs = {}
for i = 1, #ploppables do
	local ud = UnitDefNames[ploppables[i]]
	if ud and ud.id then
		ploppableDefs[ud.id] = true
	end
end
