if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Fake weapon damage reducer",
		desc      = "Weapons with 0 damage actually deal 0 damage.",
		author    = "_Shaman",
		date      = "June 20, 2019",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

local fakeweapons = {}

for wid = 1, #WeaponDefs do
	--debugecho(wid .. ": " .. tostring(WeaponDefs[wid].type) .. "\ntracker: " .. tostring(WeaponDefs[wid].customParams.tracker))
	if WeaponDefs[wid].customParams.norealdamage or WeaponDefs[wid].customParams.targeter then
		fakeweapons[wid] = true
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	if fakeweapons[weaponDefID] then
		return 0, 0
	end
end
