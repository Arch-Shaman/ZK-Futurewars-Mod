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
	local teams = Spring.GetTeamList()
	for _, teamID in pairs(teams) do
		local _, teamLuaAI, _, isAiTeam = Spring.GetTeamInfo(teamID)
		if isAiTeam and not (teamLuaAI and string.find(string.lower(teamLuaAI), "chicken")) then
			local numUnits = #Spring.GetTeamUnits(teamID)
			if numUnits == 0 then
				Spring.Echo("[AI Cleanup]: " .. teamID)
				GG.ResignTeam(teamID)
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
