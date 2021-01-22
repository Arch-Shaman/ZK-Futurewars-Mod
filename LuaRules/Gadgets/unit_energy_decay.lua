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
		}
	end
end

local INLOS = {inlos = true}
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetGameFrame = Spring.GetGameFrame
local spSetUnitResourcing = Spring.SetUnitResourcing
local BASETABLE = {currentrate = 1, nextupdate = 0, def = 0}
local spEcho = Spring.Echo
local debug = false
local max = math.max

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if config[unitDefID] then
		if debug then spEcho("Added decayer " .. unitID) end
		local config = config[unitDefID]
		local data = BASETABLE
		data.def = unitDefID
		data.nextupdate = spGetGameFrame() + config.time
		IterableMap.Add(decayers, unitID, data)
	end
end

function gadget:UnitDestroyed(unitID)
	local data = IterableMap.Get(decayers, unitID)
	if data then
		IterableMap.Remove(decayers, unitID)
	end
end

function gadget:UnitReverseBuilt(unitID, unitDefID, unitTeam)
	local data = IterableMap.Get(decayers, unitID)
	if data then
		IterableMap.Remove(decayers, unitID)
	end
end

function gadget:GameFrame(f)
	for id, data in IterableMap.Iterator(decayers) do
		if data.nextupdate == f then
			local config = config[data.def]
			local newrate = max(data.currentrate * (1 - config.rate), config.minoutput)
			--spEcho(newrate)
			if debug then spEcho(id .. ": Decayed from " .. data.currentrate * 100 .. "% -> " .. newrate * 100 .. "%") end
			data.currentrate = newrate
			spSetUnitRulesParam(id, "selfIncomeChange", data.currentrate)
			GG.UpdateUnitAttributes(id)
			if data.currentrate == config.minoutput then
				IterableMap.Remove(decayers, id)
			else
				data.nextupdate = f + config.time
			end
		end
	end
end
