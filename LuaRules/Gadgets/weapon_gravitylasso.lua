if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name     = "Gravity Lassos",
		desc     = "Yeeeee hawwwww",
		author   = "Shaman",
		date     = "October 13, 2024",
		license  = "GPL v2 or later",
		layer    = 11,
		enabled  = true
	}
end

local wantedDefs = {}

for wid = 1, #WeaponDefs do
	--debugecho(wid .. ": " .. tostring(WeaponDefs[wid].type) .. "\ntracker: " .. tostring(WeaponDefs[wid].customParams.tracker))
	if WeaponDefs[wid].customParams.gravitylasso then
		wantedDefs[#wantedDefs + 1] = wid
	end
end

local function CallAsUnitIfExists(unitID, funcName, ...)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if not env then
		return
	end
	if env and env[funcName] then
		Spring.UnitScript.CallAsUnit(unitID, env[funcName], ...)
	else
		local name = UnitDefs[Spring.GetUnitDefID(unitID)].name
		Spring.Echo("Warning: " .. funcName .. " does not exist for " .. name)
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	if Spring.ValidUnitID(attackerID) then
		CallAsUnitIfExists(attackerID, "GravityLassoUnit", unitID)
	end
	return 1, 1
end

function gadget:UnitPreDamaged_GetWantedWeaponDef() -- only do certain weapons.
	return wantedDefs
end
