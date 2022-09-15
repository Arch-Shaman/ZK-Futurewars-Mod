if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name      = "Handicaps",
		desc      = "Implements Resource handicaps.",
		author    = "Shaman",
		date      = "3/2/2021",
		license   = "CC-0",
		layer     = -999000,
		enabled   = true
	}
end

local handicaps = {}
local allyteammultipliers = {}
local donthandle = {}
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local INLOS = {inlos = true}
local wantedon = false

donthandle[UnitDefNames["staticenergyrtg"].id] = true   -- handled by unit_energy_decay
donthandle[UnitDefNames["staticmex"].id] = true         -- handled by overdrive gadget
donthandle[UnitDefNames["energyfusion"].id] = true      -- handled by unit_energy_decay
donthandle[UnitDefNames["energysingu"].id] = true       -- handled by unit_energy_decay
donthandle[UnitDefNames["energysolar"].id] = true       -- handled by unitscript

Spring.Echo("Setting up team handicaps.")
do
	local modoptions = Spring.GetModOptions()
	local allyteamhandicaps = modoptions["resource_handicap"] or '1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1'
	local allyteams = Spring.GetAllyTeamList()
	local cheatparam = tonumber(modoptions["ai_resourcecheat"]) or 1
	local allyteammults = {}
	local n = 0
	if allyteamhandicaps ~= '' then
		for handicap in allyteamhandicaps:gmatch("%S+") do
			local handicap = tonumber(handicap) or 1
			Spring.Echo("Allyteam " .. n .. ": " .. handicap)
			allyteammults[n] = handicap
			n = n + 1
		end
	end
	for a = 1, #allyteams do
		local allyteam = allyteams[a]
		local mult = allyteammults[allyteam] or 1
		local allai = true
		allyteammultipliers[allyteam] = mult
		local teamlist = Spring.GetTeamList(allyteam)
		for t = 1, #teamlist do
			local team = teamlist[t]
			handicaps[team] = mult
			if select(4, Spring.GetTeamInfo(team)) then
				handicaps[team] = handicaps[team] + (cheatparam - 1)
				if handicaps[team] ~= 1 then
					wantedon = true
				end
			else
				allai = false
			end
		end
		if allai then
			allyteammultipliers[allyteam] = allyteammultipliers[allyteam] + (cheatparam - 1)
		end
	end
end

local function GetTeamHandicap(teamID)
	return handicaps[teamID] or 1
end

local function GetAllyTeamHandicap(allyteamID)
	return allyteammultipliers[allyteamID] or 1
end

GG.GetTeamHandicap = GetTeamHandicap
GG.GetAllyTeamHandicap = GetAllyTeamHandicap

local function HasIncome(unitDefID)
	return (tonumber(UnitDefs[unitDefID].customParams.income_energy) or 0) > 0 or (tonumber(UnitDefs[unitDefID].customParams.income_metal) or 0) > 0
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if handicaps[unitTeam] ~= 1 and not donthandle[unitDefID] then
		local cheatparam = handicaps[unitTeam]
		if UnitDefs[unitDefID].isBuilder then
			local wantedbp = 1
			if spGetUnitRulesParam(unitID, "basebuildpower_mult") then
				wantedbp = spGetUnitRulesParam(unitID, "basebuildpower_mult")
			end
			spSetUnitRulesParam(unitID, "buildpower_mult", wantedbp * cheatparam, INLOS)
			GG.UpdateUnitAttributes(unitID)
		end
		if HasIncome(unitDefID) then
			spSetUnitRulesParam(unitID, "selfIncomeChange", cheatparam, INLOS)
			GG.UpdateUnitAttributes(unitID)
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if handicaps[newTeam] ~= handicaps[oldTeam] and not donthandle[unitDefID] then
		local mult = handicaps[newTeam]
		if UnitDefs[unitDefID].isBuilder then -- undo
			local originalbp = spGetUnitRulesParam(unitID, "basebuildpower_mult") or 1
			spSetUnitRulesParam(unitID, "buildpower_mult", originalbp * mult, INLOS)
			GG.UpdateUnitAttributes(unitID)
		end
		if HasIncome(unitDefID) then
			spSetUnitRulesParam(unitID, "selfIncomeChange", mult, INLOS)
			GG.UpdateUnitAttributes(unitID)
		end
	end
end

if not wantedon then
	Spring.Echo("[Handicaps] Shutdown due to no mult.")
	gadgetHandler:RemoveCallIn("UnitGiven")
	gadgetHandler:RemoveCallIn("UnitFinished")
	gadgetHandler:RemoveCallIn("GameStart")
end
