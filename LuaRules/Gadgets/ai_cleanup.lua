if not gadgetHandler:IsSyncedCode() then -- SYNCED
	return
end

function gadget:GetInfo()
  return {
    name      = "Clean up empty AI Teams",
    desc      = "Cleans up circuit AIs without units.",
    author    = "Shaman",
    date      = "2 Oct 2022",
    license   = "CC-0",
    layer     = 0,
    enabled   = true,
  }
end

local function CleanUpAI()
	local allyTeam = Spring.GetAllyTeamList()
	for i = 1, #allyTeam do
		local ally = allyTeam[i]
		local teamList = Spring.GetTeamList(ally)
		for j = 1, #teamList do
			local teamID = teamList[j]
			local _, _, _, isAiTeam = Spring.GetTeamInfo(teamID)
			if isAiTeam then
				local numUnits = #Spring.GetTeamUnits(teamID)
				if numUnits == 0 then
					GG.ResignTeam(teamID)
				end
			end
		end
	end
end

function gadget:GameFrame(f)
	if f == 25 then
		CleanUpAI()
		gadgetHandler:RemoveGadget()
	end
end
