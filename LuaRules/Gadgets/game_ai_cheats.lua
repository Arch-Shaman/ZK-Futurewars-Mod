function gadget:GetInfo()
	return {
		name      = "AI Cheats",
		desc      = "Implements AI cheats",
		author    = "Shaman",
		date      = "3/2/2021",
		license   = "CC-0",
		layer     = 200,
		enabled   = true
	}
end

if not gadgetHandler:IsSyncedCode() then
	return
end

local cheatparam
local cheatlevel
local aiteams = {}
local donthandle = {}
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local INLOS = {inlos = true}
local handledunits = {}

donthandle[UnitDefNames["staticenergyrtg"].id] = true -- let the gadget handle it.
donthandle[UnitDefNames["staticmex"].id] = true -- let the gadget handle it.
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

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if aiteams[unitTeam] and not donthandle[unitDefID] then
		if UnitDefs[unitDefID].isBuilder then
			local bpmult = spGetUnitRulesParam(unitID, "buildpower_mult") or 1
			spSetUnitRulesParam(unitID, "buildpower_mult", bpmult * cheatparam, INLOS)
			GG.UpdateUnitAttributes(unitID)
			handledunits[unitID] = true
		end
		if UnitDefs[unitDefID].energyMake > 0 or UnitDefs[unitDefID].metalMake then
			spSetUnitRulesParam(unitID, "selfIncomeChange", cheatparam, INLOS)
			GG.UpdateUnitAttributes(unitID)
			handledunits[unitID] = true
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if aiteams[oldTeam] and not donthandle[unitDefID] and not aiteams[newTeam] then
		if UnitDefs[unitDefID].isBuilder then -- undo
			local bpmult = spGetUnitRulesParam(unitID, "buildpower_mult")
			bpmult = bpmult / cheatparam
			spSetUnitRulesParam(unitID, "buildpower_mult", bpmult, INLOS)
		end
		if (UnitDefs[unitDefID].energyMake or 0) > 0 or (UnitDefs[unitDefID].metalMake or 0) > 0 then
			spSetUnitRulesParam(unitID, "selfIncomeChange", cheatparam, INLOS)
		end
	elseif aiteams[newTeam] and not donthandle[unitDefID] then
		if UnitDefs[unitDefID].isBuilder then
			local bpmult = spGetUnitRulesParam(unitID, "buildpower_mult") or 1
			spSetUnitRulesParam(unitID, "buildpower_mult", bpmult * cheatparam, INLOS)
			GG.UpdateUnitAttributes(unitID)
		end
		if UnitDefs[unitDefID].energyMake > 0 or UnitDefs[unitDefID].metalMake then
			spSetUnitRulesParam(unitID, "selfIncomeChange", cheatparam, INLOS)
			GG.UpdateUnitAttributes(unitID)
		end
	end
end

function gadget:GameStart()
	if cheatparam > 1.0 then
		local bonus = (cheatparam - 1)/.1
		for team, _ in pairs(aiteams) do
			local allyteam = select(6, Spring.GetTeamInfo(team))
			GG.Overdrive.AddInnateIncome(allyteam, bonus, bonus)
		end
	end
end
