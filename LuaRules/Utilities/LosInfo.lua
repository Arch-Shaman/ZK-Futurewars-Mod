local function TranslateLosInfo(bit)
	local inLOS = bit%2 == 1
	local inRadar = bit%4 >= 2
	local prevLOS = bit%8 >= 4
	local contRadar = bit > 7
	return inLOS, inRadar, prevLOS, contRadar
end

local function LOSInfoToBit(inLOS, inRadar, prevLOS, contRadar)
	local ret = 0
	if inLOS then
		ret = ret + 1
	end
	if inRadar then
		ret = ret + 2
	end
	if prevLOS then
		ret = ret + 4
	end
	if contRadar then
		ret = ret + 8
	end
	return ret
end

local LosInfo = {TranslateLosInfo = TranslateLosInfo, LOSInfoToBit = LOSInfoToBit}
Spring.Utilities.LosInfo = LosInfo
