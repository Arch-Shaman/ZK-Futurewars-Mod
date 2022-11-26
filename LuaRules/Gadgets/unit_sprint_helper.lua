if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Sprint Control",
		desc      = "Controls sprinting",
		author    = "Shaman",
		date      = "26 Nov 2022",
		license   = "CC-0",
		layer     = 1,
		enabled   = true  --  loaded by default?
	}
end

local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitIsStunned  = Spring.GetUnitIsStunned

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local handled = IterableMap.New()
GG.Sprint = {}

local function IsUnitDisarmed(unitID)
	local disarmed = (spGetUnitRulesParam(unitID, "disarmed") or 0) == 1
	return spGetUnitIsStunned(unitID) or disarmed
end

function GG.Sprint.Start(unitID, speed)
	spSetUnitRulesParam(unitID, "selfMoveSpeedChange", speed)
	GG.UpdateUnitAttributes(unitID)
	IterableMap.Add(handled, unitID, speed)
end

function GG.Sprint.End(unitID)
	spSetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	GG.UpdateUnitAttributes(unitID)
	IterableMap.Remove(handled, unitID)
end

function gadget:UnitDestroyed(unitID)
	IterableMap.Remove(handled, unitID)
end

function gadget:GameFrame(f)
	for unitID, originalSpeed in IterableMap.Iterator(handled) do
		local currentSpeed = spGetUnitRulesParam(unitID, "selfMoveSpeedChange") or 1
		if IsUnitDisarmed(unitID) and currentSpeed ~= 1 then
			spSetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
			GG.UpdateUnitAttributes(unitID)
		elseif not IsUnitDisarmed(unitID) and currentSpeed ~= originalSpeed then
			spSetUnitRulesParam(unitID, "selfMoveSpeedChange", originalSpeed)
			GG.UpdateUnitAttributes(unitID)
		end
	end
end
