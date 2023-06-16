if (not gadgetHandler:IsSyncedCode()) then
	return false
end

function gadget:GetInfo()
	return {
		name      = "LUS Extended Callins",
		desc      = "Adds ReverseBuild and UnitFinished callins to LUS. Removes the need for silly threads.",
		author    = "Shaman",
		date      = "2023 June 15",
		license   = "GPL v2",
		layer     = 0,
		enabled   = false, --  loaded by default?
	}
end

local function CallAsUnitIfExists(unitID, funcName)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if not env then
		return
	end
	if env and env[funcName] then
		Spring.UnitScript.CallAsUnit(unitID, env[funcName])
	end
end

function gadget:UnitReverseBuilt(unitID)
	CallAsUnitIfExists(unitID, "OnReverseBuild")
end

function gadget:UnitFinished(unitID)
	CallAsUnitIfExists(unitID, "OnUnitCompleted")
end
