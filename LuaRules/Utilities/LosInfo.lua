local function TranslateLosBitToBools(bit) -- turns Spring.GetUnitLosState into booleans. This makes it easier to read code.
	local inLOS = bit%2 == 1
	local inRadar = bit%4 >= 2
	local prevLOS = bit%8 >= 4
	local contRadar = bit > 7
	return inLOS, inRadar, prevLOS, contRadar
end

local function TranslateLosBitToTable(bit) -- turns Spring.GetUnitLosState into a nice human readable table.
	local inLOS, inRadar, prevLOS, contRadar = TranslateLosBitToBools(bit)
	return {inLOS = inLOS, inRadar = inRadar, prevLOS = prevLOS, contRadar = contRadar}
end

local function LosInfoToBit(inLOS, inRadar, prevLOS, contRadar) -- turns bools into a number for SetUnitLosState.
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

local LosInfo = {TranslateLosBitToBools = TranslateLosBitToBools, LosInfoToBit = LosInfoToBit, TranslateLosBitToTable = TranslateLosBitToTable}
Spring.Utilities.LosInfo = LosInfo
