if (not gadgetHandler:IsSyncedCode()) then return end

function gadget:GetInfo() return {
	name      = "Transport Callin",
	desc      = "Calls OnTransport and OnUnload for transported units.",
	author    = "Shaman",
	date      = "20 April 2023",
	license   = "CC-0",
	layer     = 1,
	enabled   = true,
} end

local function CallUnitScriptFunction(unitID, transported)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if env and env.OnTransportChanged then
		Spring.UnitScript.CallAsUnit(unitID, env.OnTransportChanged, transported)
	end
end

function gadget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	CallUnitScriptFunction(unitID, true)
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	CallUnitScriptFunction(unitID, false)
end
