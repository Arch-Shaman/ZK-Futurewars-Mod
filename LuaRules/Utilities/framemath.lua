function Spring.Utilities.RoundToNearestFrame(amount) -- takes a number like 2.253 and rounds it to the nearest frame value.
	return math.max(tonumber(string.format("%.0f", amount * 30)), 1) / 30
end

function Spring.Utilities.Round(amount, places)
	return tonumber(string.format("%." .. places .. "f", amount))
end
