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

if (not gadgetHandler:IsSyncedCode()) then
	return false  --  silent removal
end

local spSetUnitWeaponState = Spring.SetUnitWeaponState
local spSetUnitWeaponDamages = Spring.SetUnitWeaponDamages
local spSetUnitRulesParam = Spring.SetUnitRulesParam

local cloakstrike_defs = include("LuaRules/Configs/cloakstrike_def.lua")
local persisting_strikes = {}
local persisting_strikes_cache = {unitDefID = 0, timer = 0,}
local frame = 0

function gadget:UnitCloaked(unitID, unitDefID, unitTeam)
	if cloakstrike_defs[unitDefID] then
		local strikedefs = cloakstrike_defs[unitDefID]
		persisting_strikes[unitID] = nil
		for num, data in pairs(strikedefs["WeaponStats"]) do
			spSetUnitWeaponState(unitID, num, data["cloakedWeaponStates"])
			spSetUnitWeaponDamages(unitID, num, data["cloakedWeaponDamages"])
		end
		for paramName, value in pairs(strikedefs["cloakedRulesParam"]) do
			spSetUnitRulesParam(unitID, paramName, value)
		end
		spSetUnitRulesParam(unitID, "cloakstrike_active", "Stuff is an idiot")
		if strikedefs["updateAttributes"] then
			GG.UpdateUnitAttributes(unitID)
		end
	end
end

function gadget:UnitDecloaked(unitID, unitDefID, unitTeam)
	if cloakstrike_defs[unitDefID] then
		persisting_strikes_cache["unitDefID"] = unitDefID
		persisting_strikes_cache["timer"] = frame + cloakstrike_defs[unitDefID]["persistance"]
		persisting_strikes[unitID] = persisting_strikes_cache
		for paramName, value in pairs(cloakstrike_defs["decloakedRulesParam"]) do
			spSetUnitRulesParam(unitID, paramName, value)
		end
		if cloakstrike_defs["updateAttributes"] then
			GG.UpdateUnitAttributes(unitID)
		end
	end
end

function gadget:GameFrame(f)
	frame = f
	if f%5 == 0 then
		for unitID, data in pairs(persisting_strikes) do
			if data["timer"] <= f then
				for num, stats in pairs(cloakstrike_defs[data["unitDefID"]]["WeaponStats"]) do
					spSetUnitWeaponState(unitID, num, data["decloakedWeaponStates"])
					spSetUnitWeaponDamages(unitID, num, data["decloakedWeaponDamages"])
				end
				spSetUnitRulesParam(unitID, "cloakstrike_active", nil)
			end
		end
	end
end
