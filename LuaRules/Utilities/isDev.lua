local devs = {
	Shaman = true,
	LeojEspino = true,
	Stuff = true,
	garfild888 = true,
}

local function IsFWDev(name)
	return devs[name]
end

Spring.Utilities.IsFWDev = IsFWDev

function Spring.Utilities.IsPlayerFWDev(playerID)
	local name = Spring.GetPlayerInfo(playerID)
	return devs[name]
end
