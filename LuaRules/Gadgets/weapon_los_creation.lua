if not gadgetHandler:IsSyncedCode() then -- SYNCED
	return
end

function gadget:GetInfo()
  return {
    name      = "Weapon Los Creation",
    desc      = "Creates fake LOS units for attacks.",
    author    = "Shaman",
    date      = "14 March, 2024",
    license   = "CC-0",
    layer     = 0,
    enabled   = true,
  }
end

local config = {}
local onImpactConfig = {}
local handled = {count = 0, data = {}, byID = {}}
local wantedDefs = {}
local losOnImpact = {count = 0, data = {}}

-- speedups --
local spSetUnitPosition = Spring.SetUnitPosition
local spGetProjectilePosition = Spring.GetProjectilePosition
local spSetUnitSensorRadius = Spring.SetUnitSensorRadius

local function SendError(str)
	Spring.Echo("[weapon_los_creation]: " .. str)
end

for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	local wantsImpact = false
	if cp.generates_los or cp.generates_radar then
		local los = tonumber(cp.generates_los) or 0
		local radar = tonumber(cp.generates_radar) or 0
		if los > 0 or radar > 0 then
			config[i] = {radar = radar, los = los}
			Script.SetWatchExplosion(i, true) -- probably not necessary.
			Script.SetWatchWeapon(i, true)
			wantsImpact = true
		end
	end
	if cp.onimpact_los or cp.onimpact_radar then
		local los = tonumber(cp.onimpact_los) or 0
		local radar = tonumber(cp.onimpact_radar) or 0
		local timer = tonumber(cp.onimpact_duration) or 0
		if los > 0 or radar > 0 and timer > 0 then
			wantsImpact = true
			onImpactConfig[i] = {radar = radar, los = los, timer = timer}
			Script.SetWatchExplosion(i, true)
		end
	end
	if wantsImpact then
		wantedDefs[#wantedDefs + 1] = i
	end
end

local function UpdateSensorForUnit(losUnitID, newLos, newRadar)
	spSetUnitSensorRadius(losUnitID, "los", newLos)
	spSetUnitSensorRadius(losUnitID, "radar", newRadar)
	spSetUnitSensorRadius(losUnitID, "sonar", newLos)
	spSetUnitSensorRadius(losUnitID, "airLos", newLos)
end

local function TryToCreateUnit(teamID, x, y, z, isScan)
	local losUnit
	if isScan then 
		losUnit = Spring.CreateUnit("los_scan", -10000, -10000, -10000, 0, teamID) 
	else
		losUnit = Spring.CreateUnit("los_superwep", -10000, -10000, -10000, 0, teamID) 
	end
	if losUnit then
		Spring.SetUnitNoDraw(losUnit, true)
		Spring.SetUnitNoSelect(losUnit, true)
		Spring.SetUnitNoMinimap(losUnit, true)
		Spring.SetUnitLeaveTracks(losUnit, true)
		Spring.SetUnitRulesParam(losUnit, "untargetable", 1)
		--Spring.SetUnitCloak(losUnit, 4)
		Spring.SetUnitStealth(losUnit, true)
		Spring.SetUnitBlocking(losUnit, false, false, false)
		spSetUnitPosition(losUnit, x, y, z)
		return losUnit
	else
		SendError("Failed to create los unit for " .. teamID)
	end
end

local function RemoveIndex(index, tab)
	if tab.data[index] == nil or index > tab.count then
		SendError("Attempt to remove a nonexistent value!\n Index: " .. index .. "\ncount: " .. tab.count .. "\nactual count in memory: " .. #tab.data)
		Spring.Echo("game_message: /!\ A serious error has occurred in weapon_los_creation.\nThe game may still be playable but you may have unintentional LOS.")
		return
	end
	local losID = tab.data[index].los
	if index == handled.count then -- last index just 
		tab.count = tab.count - 1
	else
		local d = tab.data[tab.count]
		tab.data[tab.count] = tab.data[index]
		tab.data[index] = d
		tab.byID[d.id] = index
		tab.count = tab.count - 1
	end
	Spring.DestroyUnit(losID, true, true)
end

local function AddIndex(projectileID, weaponDefID)
	local x, y, z = spGetProjectilePosition(projectileID)
	local projectileTeam = Spring.GetProjectileTeamID(projectileID)
	local losUnit = TryToCreateUnit(projectileTeam, x, y, z)
	local con = config[weaponDefID]
	if losUnit == nil then return end -- abort!
	local c = handled.count + 1
	local los = con.los or 0
	local radar = con.radar or 0
	SendError("AddIndex: " .. los .. ", " .. radar)
	UpdateSensorForUnit(losUnit, los, radar)
	if handled.data[c] then
		handled.data[c].id = projectileID
		handled.data[c].los = losUnit
	else
		handled.data[c] = {id = projectileID, los = losUnit}
	end
	handled.count = c
	handled.byID[projectileID] = c
end

local function AddTimedIndex(teamID, x, y, z, con)
	local losUnit = TryToCreateUnit(teamID, x, y, z)
	if losUnit == nil then return end -- abort!
	local c = losOnImpact.count + 1
	UpdateSensorForUnit(losUnit, con.los or 0, con.radar or 0)
	if losOnImpact.data[c] then
		losOnImpact.data[c].timer = con.timer
		losOnImpact.data[c].los = losUnit
	else
		losOnImpact.data[c] = {timer = con.timer, los = losUnit}
	end
	losOnImpact.count = c
end

function gadget:Explosion(weaponDefID, px, py, pz, attackerID, projectileID)
	local index = handled.byID[projectileID]
	if index then -- it'll get cleaned up also under ProjectileUpdate, apparently.
		RemoveIndex(index, handled)
		handled.byID[projectileID] = nil
	end
	local con = onImpactConfig[weaponDefID]
	if con and attackerID and Spring.ValidUnitID(attackerID) then
		local attackerTeam = Spring.GetUnitTeam(attackerID)
		if attackerTeam then
			AddTimedIndex(attackerTeam, px, py, pz, onImpactConfig[weaponDefID])
		end
	end
end

function gadget:Explosion_GetWantedWeaponDef()
	return wantedDefs
end

function gadget:ProjectileCreated(proID, unitFiringID, weaponDefID) -- it would be nice if this had an equivalent to Explosion_GetWantedWeaponDef
	if config[weaponDefID] then
		AddIndex(proID, weaponDefID)
	end
end

--[[function gadget:ProjectileDestroyed(proID) -- not needed?
	if handled.byID[proID] then
		RemoveIndex(index, handled.byID[proID])
	end
end]]

local function ProjectileUpdate()
	local toRemove = {}
	for i = 1, handled.count do
		local projectileID = handled.data[i].id
		local losID = handled.data[i].los
		local x, y, z = spGetProjectilePosition(projectileID)
		if x == nil then -- something has fucked up
			toRemove[#toRemove + 1] = i
		else
			spSetUnitPosition(losID, x, y, z)
		end
	end
	local maxIndex = #toRemove
	if maxIndex > 0 then
		for i = 1, maxIndex do
			RemoveIndex(toRemove[i], handled)
		end
	end
end

local function ImpactUpdate()
	local toRemove = {}
	for i = 1, losOnImpact.count do
		local losID = losOnImpact.data[i].los
		losOnImpact.data[i].timer = losOnImpact.data[i].timer - 0.1
		if losOnImpact.data[i].timer <= 0 then
			toRemove[#toRemove + 1] = i
		end
	end
	local maxIndex = #toRemove
	if maxIndex > 0 then
		for i = 1, maxIndex do
			RemoveIndex(toRemove[i], losOnImpact)
		end
	end
end

function gadget:GameFrame(f)
	if handled.count > 0 then
		ProjectileUpdate()
	end
	if losOnImpact.count > 0 and f%3 == 0 then
		ImpactUpdate()
	end
end
