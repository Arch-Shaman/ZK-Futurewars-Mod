function Spring.Utilities.RoundToNearestFrame(amount) -- takes a number like 2.253 and rounds it to the nearest frame value.
	local val = tonumber(string.format("%.0f", amount * 30))
	if val < 1 then val = 1 end
	return val / 30
end

function Spring.Utilities.Round(amount, places)
	return tonumber(string.format("%." .. places .. "f", amount))
end
