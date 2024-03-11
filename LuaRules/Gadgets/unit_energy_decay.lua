if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name      = "Energy Decay",
		desc      = "Handles Energy Decay for RTGs",
		author    = "Shaman",
		date      = "1/22/2021",
		license   = "CC-0",
		layer     = 0,
		enabled   = true
	}
end

local IterableMap = Spring.Utilities.IterableMap
local config = {}
local decayers = IterableMap.New()

for i=1, #UnitDefs do
	local cp = UnitDefs[i].customParams
	if tonumber(cp["decay_time"]) and tonumber(cp["decay_rate"]) then
		config[i] = {
			rate = tonumber(cp["decay_rate"]),
			time = tonumber(cp["decay_time"]) * 30,
			minoutput = tonumber(cp["decay_minoutput"]) or 0,
			baseoutput = UnitDefs[i].energyMake,
			maxoutput = tonumber(cp["decay_maxoutput"]) or 10,
			initialrate = tonumber(cp["decay_initialrate"]) or 10,
			progressnotsaved = cp["decay_noprogressonmorph"] ~= nil
		}
		config[i].appreciates = config[i].rate < 0
	end
end

local INLOS = {inlos = true}
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetGameFrame = Spring.GetGameFrame
local spSetUnitResourcing = Spring.SetUnitResourcing
local spEcho = Spring.Echo
local debugMode = false
local max = math.max
local min = math.min

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if config[unitDefID] and not IterableMap.InMap(decayers, unitID) then
		if debugMode then spEcho("Added decayer " .. unitID) end
		local mult = GG.GetTeamHandicap(unitTeam) or 1
		local config = config[unitDefID]
		IterableMap.Add(decayers, unitID, {currentrate = config.initialrate, nextupdate = spGetGameFrame() + config.time, def = unitDefID, mult = mult})
		spSetUnitRulesParam(unitID, "selfIncomeChange", config.initialrate * mult)
		GG.UpdateUnitAttributes(unitID)
		GG.UpdateUnitAttributes(unitID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID)
	local inMap = IterableMap.InMap(decayers, unitID)
	if inMap or (config[unitDefID]) then
		local newUnit = Spring.GetUnitRulesParam(unitID, "wasMorphedTo")
		if newUnit then
			local data = IterableMap.Get(decayers, unitID)
			local unitconfig = config[unitDefID]
			if not unitconfig.progressnotsaved then
				local currentrate
				if data then
					currentrate = data.currentrate
					local totalchange
					if unitconfig.appreciates then
						totalchange = unitconfig.maxoutput - unitconfig.initialrate
						currentrate = currentrate - unitconfig.initialrate
						currentrate = currentrate / totalchange
					else
						currentrate = unitconfig.initialrate - currentrate -- 1 ->0.1 current is 0.9. we've progressed 0.1 through it.
						totalchange = unitconfig.initialrate - unitconfig.minoutput -- 0.9 is total change.
						currentrate = currentrate / totalchange
					end
				else
					currentrate = 1 -- we've completed the cycle totally.
				end
				local newconfig = config[Spring.GetUnitDefID(newUnit)]
				if newconfig then
					--check if it appreciates
					if unitconfig.appreciates == newconfig.appreciates then
						local newCurrentRate = newconfig.initialrate
						local newTotalChange
						if newconfig.appreciates then
							newTotalChange = newconfig.maxoutput - newCurrentRate
							newCurrentRate = newCurrentRate + (newTotalChange * currentrate)
						else
							newTotalChange = newCurrentRate - newconfig.minoutput
							newCurrentRate = newCurrentRate - (newTotalChange * currentrate)
						end
						local newData = {currentrate = newCurrentRate, nextupdate = spGetGameFrame() + newconfig.time, def = Spring.GetUnitDefID(newUnit), mult = GG.GetTeamHandicap(unitTeam) or 1}
						if IterableMap.InMap(decayers, newUnit) then
							IterableMap.Set(decayers, newUnit, newData)
						else
							IterableMap.Add(decayers, newUnit, newData)
						end
						spSetUnitRulesParam(newUnit, "selfIncomeChange", newCurrentRate)
						GG.UpdateUnitAttributes(newUnit)
						GG.UpdateUnitAttributes(newUnit)
					end
				end
			end
		end
		if inMap then -- cleanup.
			IterableMap.Remove(decayers, unitID)
		end
	end
end

function gadget:UnitReverseBuilt(unitID, unitDefID, unitTeam)
	if IterableMap.InMap(decayers, unitID) then
		if debugMode then spEcho("reverse built removed " .. unitID) end
		IterableMap.Remove(decayers, unitID)
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if IterableMap.InMap(decayers, unitID) then
		local data = IterableMap.Get(decayers, unitID)
		data.mult = GG.GetTeamHandicap(newTeam)
	end
end


function gadget:GameFrame(f)
	for id, data in IterableMap.Iterator(decayers) do
		--spEcho(id .. " next update: " .. data.nextupdate)
		if data.nextupdate == f then
			local config = config[data.def]
			local newrate
			if config.appreciates then
				newrate = min(data.currentrate * (1 - config.rate), config.maxoutput)
			else -- depreciates
				newrate = max(data.currentrate * (1 - config.rate), config.minoutput)
			end
			if debugMode then spEcho(id .. ": Decayed from " .. data.currentrate * 10 .. "% -> " .. newrate * 10 .. "%") end
			data.currentrate = newrate
			spSetUnitRulesParam(id, "selfIncomeChange", data.currentrate * data.mult)
			GG.UpdateUnitAttributes(id)
			GG.UpdateUnitAttributes(id)
			--if debugMode then spEcho("Updated " .. id) end
			if (not config.appreciates and data.currentrate == config.minoutput) or (config.appreciates and data.currentrate == config.maxoutput) then
				IterableMap.Remove(decayers, id)
			else
				data.nextupdate = f + config.time
			end
		end
	end
end

if cheatparam == 1 then
	gadgetHandler:RemoveCallIn("UnitGiven")
end
