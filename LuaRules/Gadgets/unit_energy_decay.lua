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

if not gadgetHandler:IsSyncedCode() then
	return
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
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
		}
		config[i].appreciates = config[i].rate < 0
	end
end

local cheatparam
local aiteams = {}

do
	local modoptions = Spring.GetModOptions()
	cheatparam = modoptions and modoptions["ai_resourcecheat"] or 1
	local allyteams = Spring.GetAllyTeamList()
	for a = 1, #allyteams do
		local allyteam = allyteams[a]
		local teamlist = Spring.GetTeamList(allyteam)
		for t = 1, #teamlist do
			local team = teamlist[t]
			if select(4, Spring.GetTeamInfo(team)) then
				aiteams[team] = true
			end
		end
	end
end

local INLOS = {inlos = true}
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetGameFrame = Spring.GetGameFrame
local spSetUnitResourcing = Spring.SetUnitResourcing
local spEcho = Spring.Echo
local debug = false
local max = math.max
local min = math.min

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if config[unitDefID] then
		if debug then spEcho("Added decayer " .. unitID) end
		local mult = 1
		if aiteams[unitTeam] then
			mult = cheatparam
		end
		local config = config[unitDefID]
		IterableMap.Add(decayers, unitID, {currentrate = config.initialrate, nextupdate = spGetGameFrame() + config.time, def = unitDefID, mult = mult})
		spSetUnitRulesParam(unitID, "selfIncomeChange", config.initialrate * mult)
		GG.UpdateUnitAttributes(unitID)
		GG.UpdateUnitAttributes(unitID)
	end
end

function gadget:UnitDestroyed(unitID)
	if IterableMap.InMap(decayers, unitID) then
		IterableMap.Remove(decayers, unitID)
	end
end

function gadget:UnitReverseBuilt(unitID, unitDefID, unitTeam)
	if IterableMap.InMap(decayers, unitID) then
		if debug then spEcho("reverse built removed " .. unitID) end
		IterableMap.Remove(decayers, unitID)
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if IterableMap.InMap(decayers, unitID) then
		local data = IterableMap.Get(decayers, unitID)
		if aiteams[newTeam] then
			data.mult = cheatparam
		else
			data.mult = 1
		end
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
				newrate = max(data.currentrate * (1 - config.rate), 1)
			end
			if debug then spEcho(id .. ": Decayed from " .. data.currentrate * 10 .. "% -> " .. newrate * 10 .. "%") end
			data.currentrate = newrate
			spSetUnitRulesParam(id, "selfIncomeChange", data.currentrate * data.mult)
			GG.UpdateUnitAttributes(id)
			GG.UpdateUnitAttributes(id)
			--if debug then spEcho("Updated " .. id) end
			if (not config.appreciates and data.currentrate == 1) or (config.appreciates and data.currentrate == config.maxoutput) then
				IterableMap.Remove(decayers, id)
			else
				data.nextupdate = f + config.time
			end
		end
	end
end
