local overrideTime, overrideMinTime
do
	local mapTable = {
		["duck"] = {time = 60, mintime = 20},
		["trololo_v2"] = {time = 60, mintime = 20},
		["polish flag"] = {time = 60, mintime = 20},
		["winniedapoohv3"] = {time = 60, mintime = 20},
	}
	local mapName = string.lower(game.mapName)
	if mapTable[mapName] then
		overrideTime = mapTable[mapName].time
		overrideMinTime = mapTable[mapName].mintime
	end
end

if overrideMinTime and overrideTime then
	return overrideTime, overrideMinTime
else
	return 180, 60
end
