if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Resurrection Protection",
		desc      = "NO BULLY.",
		author    = "Shaman",
		date      = "11 Elokuu 2021",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

local IterableMap = Spring.Utilities.IterableMap
local protectedFeatures = {}
local features = IterableMap.New()
--local newtable = {timer = 10, cancer = true}

local spGetTeamInfo = Spring.GetTeamInfo

function gadget:AllowFeatureBuildStep(builderID, builderTeam, featureID, featureDefID, part) -- part seems to be some sort of reclaim speed.
	if part >= 0 then
		if protectedFeatures[featureID] == nil then
			IterableMap.Add(features, featureID, {timer = 10, cancer = true})
			protectedFeatures[featureID] = true
		else
			local data = IterableMap.Get(features, featureID)
			data.timer = 31
			IterableMap.Set(features, featureID, data)
		end
		return true
	else
		return protectedFeatures[featureID] == nil
	end
end

function gadget:FeatureDestroyed(featureID)
	if protectedFeatures[featureID] then
		protectedFeatures[featureID] = nil
		IterableMap.Remove(features, featureID)
	end
end

function gadget:GameFrame(f)
	if f%5 == 2 then
		for id, data in IterableMap.Iterator(features) do
			data.timer = data.timer - 5
			if data.timer <= 0 then
				protectedFeatures[id] = nil
				IterableMap.Remove(features, id)
			end
		end
	end
end
