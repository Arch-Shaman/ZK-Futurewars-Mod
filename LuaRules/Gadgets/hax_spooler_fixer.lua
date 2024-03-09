if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name      = "Spooling Unit Idle Fixer",
		desc      = "Fixes idle units with spooling weapons",
		author    = "Shaman",
		date      = "15 August, 2022",
		license   = "CC-0",
		layer     = 0, -- low enough to catch any geo creation.
		enabled   = true,
	}
end

local wantedDefs = {
	[UnitDefNames["cloakriot"].id] = true,
	[UnitDefNames["vehassault"].id] = true,
}

local aiTeams = {}

local opts = {
	internal = true,
	shift = true,
}

local spGetUnitPosition = Spring.GetUnitPosition

function gadget:UnitIdle(unitID, unitDefID, unitTeam)
	if not aiTeams[unitTeam] and wantedDefs[unitDefID] then -- Do not control units from ai team! They may want rely on unitidle.
		local x, y, z = spGetUnitPosition(unitID)
		GG.DelegateOrder(unitID, CMD.FIGHT, {x, y, z}, opts)
	end
end

function gadget:Initialize()
	local teamList = Spring.GetTeamList()
	for i = 1, #teamList do
		local teamID = teamList[i]
		if select(4, Spring.GetTeamInfo(teamID)) then
			aiTeams[teamID] = true
		end
	end
end
