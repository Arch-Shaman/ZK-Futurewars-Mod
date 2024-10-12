if not gadgetHandler:IsSyncedCode() then return end

function gadget:GetInfo()
	return {
		name     = "Backup allyteam names",
		layer    = math.huge, -- last so that we only cover up holes; actual names are set by startbox handler (MP) or mission handlers (SP)
		enabled  = true,
	}
end

local PUBLIC_VISIBLE = {public = true}

function gadget:Initialize()
	local modOptions = Spring.GetModOptions()
	local allyTeamList = Spring.GetAllyTeamList()
	for i = 1, #allyTeamList do
		local allyTeamID = allyTeamList[i]
		Spring.Echo("allyTeamIDallyTeamID", allyTeamID)
		if not Spring.GetGameRulesParam("allyteam_short_name_" .. allyTeamID) then
			Spring.SetGameRulesParam("allyteam_short_name_" .. allyTeamID, "Team " .. allyTeamID)
			Spring.SetGameRulesParam("allyteam_long_name_"  .. allyTeamID, "Team " .. allyTeamID)
		end
		if string.len(modOptions["allyteam_short_name_" .. (allyTeamID + 1)] or "") > 0 then
			Spring.SetGameRulesParam("allyteam_short_name_" .. allyTeamID, modOptions["allyteam_short_name_" .. (allyTeamID + 1)])
		end
		if string.len(modOptions["allyteam_long_name_" .. (allyTeamID + 1)] or "") > 0 then
			Spring.SetGameRulesParam("allyteam_long_name_" .. allyTeamID, modOptions["allyteam_long_name_" .. (allyTeamID + 1)])
		end
	end
	
	if Spring.GetGameFrame() < 1 then
		local teamList = Spring.GetTeamList()
		for i = 1, #teamList do
			local teamID = teamList[i]
			local _, leaderID, _, isAI = Spring.GetTeamInfo(teamID, false)
			if leaderID >= 0 then
				Spring.SetTeamRulesParam(teamID, "initLeaderID", leaderID, PUBLIC_VISIBLE)
				Spring.SetTeamRulesParam(teamID, "initAI", isAI, PUBLIC_VISIBLE)
				if isAI then
					local _, name, host, shortName, version = Spring.GetAIInfo(teamID)
					Spring.SetTeamRulesParam(teamID, "initAIHost", host, PUBLIC_VISIBLE)
					Spring.SetTeamRulesParam(teamID, "initAIName", name, PUBLIC_VISIBLE)
					Spring.SetTeamRulesParam(teamID, "initAIShort", shortName, PUBLIC_VISIBLE)
					Spring.SetTeamRulesParam(teamID, "initAIVersion", version, PUBLIC_VISIBLE)
				end
			end
		end
	end
end
