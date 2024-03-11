if (not gadgetHandler:IsSyncedCode()) then
	return false  --  silent removal
end

function gadget:GetInfo()
	return {
		name      = "Cloak-strike",
		desc      = "Now you see me, Now you don't, And now you're dead",
		author    = "Stuff/HTMLPhoton",
		date      = "9/03/2021",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

local spSetUnitWeaponState = Spring.SetUnitWeaponState
local spSetUnitWeaponDamages = Spring.SetUnitWeaponDamages
local spSetUnitRulesParam = Spring.SetUnitRulesParam

local IterableMap = Spring.Utilities.IterableMap
local handledUnits = IterableMap.New()
local cloakstrike_defs = include("LuaRules/Configs/cloakstrike_def.lua")

function gadget:UnitCloaked(unitID, unitDefID, unitTeam)
	if cloakstrike_defs[unitDefID] then
		local strikedefs = cloakstrike_defs[unitDefID]
		for num, data in pairs(strikedefs["WeaponStats"]) do
			spSetUnitWeaponState(unitID, num, data["cloakedWeaponStates"])
			spSetUnitWeaponDamages(unitID, num, data["cloakedWeaponDamages"])
		end
		for paramName, value in pairs(strikedefs["cloakedRulesParam"]) do
			spSetUnitRulesParam(unitID, paramName, value)
		end
		spSetUnitRulesParam(unitID, "cloakstrike_active", cloakstrike_defs[unitDefID].persistance or 1)
		if strikedefs["updateAttributes"] then
			GG.UpdateUnitAttributes(unitID)
		end
	end
end

--decloakedWeaponDamages

local function UndoCloakStrike(unitID, unitDefID)
	for paramName, value in pairs(cloakstrike_defs[unitDefID]["decloakedRulesParam"]) do
		spSetUnitRulesParam(unitID, paramName, value)
	end
	for num, data in pairs(cloakstrike_defs[unitDefID]["WeaponStats"]) do
		spSetUnitWeaponState(unitID, num, data["decloakedWeaponStates"])
		spSetUnitWeaponDamages(unitID, num, data["decloakedWeaponDamages"])
	end
	if cloakstrike_defs[unitDefID]["updateAttributes"] then
		GG.UpdateUnitAttributes(unitID)
	end
	spSetUnitRulesParam(unitID, "cloakstrike_active", nil)
end

function gadget:UnitDecloaked(unitID, unitDefID, unitTeam)
	if cloakstrike_defs[unitDefID] then
		if cloakstrike_defs[unitDefID].persistance and cloakstrike_defs[unitDefID].persistance > 0 then
			IterableMap.Add(handledUnits, unitID, {timer = cloakstrike_defs[unitDefID].persistance, unitDefID = unitDefID})
		else
			UndoCloakStrike(unitID, unitDefID)
		end
	end
end

function gadget:UnitDestroyed(unitID)
	if IterableMap.InMap(handledUnits, unitID) then
		IterableMap.Remove(handledUnits, unitID)
	end
end


function gadget:GameFrame(f)
	for unitID, data in IterableMap.Iterator(handledUnits) do
		data.timer = data.timer - 1
		spSetUnitRulesParam(unitID, "cloakstrike_active", data.timer)
		if data.timer == 0 then
			UndoCloakStrike(unitID, data.unitDefID)
			IterableMap.Remove(handledUnits, unitID)
		end
	end
end
