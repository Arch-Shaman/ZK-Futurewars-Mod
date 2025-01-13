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
overrideMinTime = overrideMinTime or 30
overrideTime = overrideTime or 180

Spring.Echo("ResignState: MinTime: " .. overrideMinTime .. ", Starting time: " .. overrideTime)
