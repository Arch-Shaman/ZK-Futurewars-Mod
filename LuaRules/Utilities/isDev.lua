local function isFWDev(name)
	return name == "Shaman" or
			name == "LeojEspino" or
			name == "Stuff"
end

Spring.Utilities.isFWDev = isFWDev

function Spring.Utilities.isPlayerFWDev(playerID)
	local name = Spring.GetPlayerInfo(playerID)
	return isFWDev(name)
end
