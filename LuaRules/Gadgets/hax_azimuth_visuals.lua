if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Azimuth Visuals",
		desc      = "Draws Azimuth lasers and CEGs.",
		author    = "Shaman",
		date      = "16.5.2022",
		license   = "CC-0",
		layer     = 255,  -- As late as it can get
		enabled   = true  --  loaded by default?
	}
end

local watchDefs = {
	[UnitDefNames["turretantiheavy"].weapons[1].weaponDef] = true,
}
local wantedDefs = {}

local spGetUnitTeam = Spring.GetUnitTeam
local spSpawnCEG = Spring.SpawnCEG
local spSpawnProjectile = Spring.SpawnProjectile

for k, _ in pairs(watchDefs) do
	wantedDefs[#wantedDefs + 1] = k
	Script.SetWatchWeapon(k, true)
end

function gadget:Explosion_GetWantedWeaponDef()
	return wantedDefs
end

function gadget:Explosion(weaponID, px, py, pz, ownerID) -- draw CEG and laser
	local firingTime = Spring.GetUnitRulesParam(ownerID, "azi_firing_time") or 0
	local laserStage = math.floor(firingTime / 30)
	if laserStage > 60 then laserStage = 60 end
	local spawnID = WeaponDefNames["turretantiheavy_ata_"..laserStage].id
	if spawnID then
		local ux, uy, uz = Spring.GetUnitPiecePosDir(ownerID, 9) 
		spSpawnProjectile(spawnID, {
			pos = {ux, uy, uz},
			["end"] = {px, py, pz},
			owner = ownerID,
			team = spGetUnitTeam(ownerID),
			ttl = 1,
		})
	end
	local sizeMult = (math.min(math.floor(firingTime / 10 + 0.01), 60) / 10) + 1
	spSpawnCEG("ataalasergrow", px, py, pz, 0, 1, 0, 1, math.sqrt(sizeMult))
end
