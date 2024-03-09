if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Missile Laser Targeter",
		desc      = "Missiles follow their targeter.",
		author    = "Shaman",
		date      = "June 20, 2019",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

local spEcho = Spring.Echo
local spGetGameFrame = Spring.GetGameFrame
local spGetProjectilePosition = Spring.GetProjectilePosition
local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitPosition = Spring.GetUnitPosition
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetProjectileTarget = Spring.GetProjectileTarget
local spSetProjectileTarget = Spring.SetProjectileTarget
local SetWatchWeapon = Script.SetWatchWeapon
local spGetValidUnitID = Spring.ValidUnitID
local debugMode = false

local g_CHAR = string.byte('g')
local u_CHAR = string.byte('u')
local f_CHAR = string.byte('f')

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

local missiles = IterableMap.New() -- {weaponDef = ID, targeterID = unitID, state}
local targeters = {} -- holds the targeting information.
local config = {} -- targeter or tracker
local wantedList = {}

for wid = 1, #WeaponDefs do
	--debugecho(wid .. ": " .. tostring(WeaponDefs[wid].type) .. "\ntracker: " .. tostring(WeaponDefs[wid].customParams.tracker))
	local cp = WeaponDefs[wid].customParams
	if (WeaponDefs[wid].type == "MissileLauncher" or WeaponDefs[wid].type == "StarburstLauncher") and cp.tracker then
		config[wid] = {type = 'tracker', fallsWhenLost = cp.laserguidancefalls ~= nil, lostTime = tonumber(cp.laserguidance_failtime) or 15}
		SetWatchWeapon(wid, true)
		wantedList[#wantedList + 1] = wid
	elseif WeaponDefs[wid].customParams.targeter then
		config[wid] = {type = 'targeter'}
		SetWatchWeapon(wid, true)
		wantedList[#wantedList + 1] = wid
	end
end

local function PrintConfig()
	spEcho("Laser targeting config: ")
	for wid,data in pairs(config) do
		spEcho(wid .. ': ' .. data.type)
	end
end

local function GetMissileTracking(pid)
	local data = IterableMap.Get(pid)
	if not data then
		return false
	else
		return data.state == "normal"
	end
end

GG.GetLaserTrackingEnabled = GetMissileTracking

if debugMode then PrintConfig() end

local function RemoveMissile(proID)
	local data = IterableMap.Get(missiles, proID)
	if data then
		targeters[data.owner].numMissiles = targeters[data.owner].numMissiles - 1
		if targeters[data.owner].numMissiles == 0 and targeters[data.owner].isDead then
			targeters[data.owner] = nil
		end
		IterableMap.Remove(missiles, proID)
	end
end

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, projectileID)
	--debugecho("Explosion: " .. tostring(weaponDefID, px, py, pz, AttackerID, projectileID))
	if config[weaponDefID].type == 'targeter' then
		if targeters[AttackerID] == nil then
			targeters[AttackerID] = {target = {[1] = px, [2] = py, [3] = pz}, lastFrame = spGetGameFrame(), isDead = spGetValidUnitID(AttackerID), numMissiles = 0}
		else
			targeters[AttackerID].target[1] = px
			targeters[AttackerID].target[2] = py
			targeters[AttackerID].target[3] = pz
			targeters[AttackerID].lastFrame = spGetGameFrame()
		end
		if debugMode then
			local x = missiles[AttackerID].target[1]
			local y = missiles[AttackerID].target[2]
			local z = missiles[AttackerID].target[3]
			spEcho("position is: " .. tostring(x) .. ", " .. tostring(y) .. "," .. tostring(z))
			spEcho("Set " .. AttackerID .. " target: " .. tostring(px) .. "," .. tostring(py) .. "," .. tostring(pz))
			local ux,uy,uz = spGetUnitPosition(AttackerID)
			spEcho("UnitPosition: " .. ux .. "," .. uy .. "," .. uz)
		end
	else
		RemoveMissile(projectileID)
	end
end

function gadget:Explosion_GetWantedWeaponDef()
	return wantedList
end

function gadget:ProjectileCreated(projectileID, proOwnerID, weaponDefID) -- proOwnerID is the unitID that fired the projectile
	if config[weaponDefID] and config[weaponDefID].type == 'tracker' then
		local owner = proOwnerID or Spring.GetProjectileOwnerID(projectileID)
		local data = {state = "normal", owner = owner, def = weaponDefID}
		if debugMode then
			spEcho("Added " .. projectileID .. " to " .. proOwnerID)
		end
		if targeters[proOwnerID] then
			local targetInfo = targeters[proOwnerID].target
			spSetProjectileTarget(projectileID, targetInfo[1], targetInfo[2], targetInfo[3])
			targeters[proOwnerID].numMissiles = targeters[proOwnerID].numMissiles + 1
		else
			local target = {}
			local t, tpos = spGetProjectileTarget(projectileID)
			if t == g_CHAR then
				target = tpos
			elseif t == u_CHAR then
				target[1], target[2], target[3] = spGetUnitPosition(tpos)
			elseif t == f_CHAR then
				target[1], target[2], target[3] = spGetFeaturePosition(tpos)
			else -- If we really don't know what's going on, then safest to just scuttle the missile by aiming it at -1mil
				local tx, _, ty = spGetProjectilePosition(projectileID)
				target = {tx or 0, -1000000, tz or 0}
			end
			targeters[proOwnerID] = {target = target, lastFrame = spGetGameFrame(), isDead = spGetValidUnitID(proOwnerID), numMissiles = 1}
		end
		IterableMap.Add(missiles, projectileID, data)
		--debugecho(tostring(success))
	end
end

function gadget:ProjectileDestroyed(proID)
	--debugecho("destroyed " .. proID)
	RemoveMissile(proID)
end

function GG.GetLaserTarget(proID)
	local data = IterableMap.Get(missiles, proID)
	if data then
		local target = targeters[data.owner].target
		if data.state == "normal" then
			return target[1], target[2], target[3]
		else
			local x, _, z = spGetProjectilePosition(proID)
			return x, spGetGroundHeight(x,z), z
		end
	else
		return nil
	end
end

function gadget:UnitDestroyed(unitID)
	if targeters[unitID] and targeters[unitID].numMissiles > 0 then
		targeters[unitID].isDead = true
	elseif targeters[unitID] and targeters[unitID].numMissiles == 0 then
		targeters[unitID] = nil
	end
end

local function SetMissileTarget(missileID, x, y, z)
	if not GG.GetMissileCruising(missileID) then
		spSetProjectileTarget(missileID, x, y, z)
	else
		GG.ForceCruiseUpdate(missileID, x, y, z)
	end
end

local function SetMissileLost(missileID, data, targeterInfo, configuration)
	local tx, ty, tz
	if configuration.fallsWhenLost then
		tx, _, tz = spGetProjectilePosition(missileID)
		ty = spGetGroundHeight(tx, tz)
	else
		local targetInfo = targeterInfo.target
		tx, ty, tz = targetInfo[1], targetInfo[2], targetInfo[3]
	end
	SetMissileTarget(missileID, tx, ty, tz)
end

local function UpdateMissileTarget(missileID, targeterInfo)
	local tx, ty, tz = targeterInfo.target[1], targeterInfo.target[2], targeterInfo.target[3]
	SetMissileTarget(missileID, tx, ty, tz)
end

function gadget:GameFrame(f)
	if f%3 == 0 then
		for missileID, data in IterableMap.Iterator(missiles) do
			local configuration = config[data.def]
			local targeter = targeters[data.owner]
			local timeSinceLastTargeterExplosion = f - targeter.lastFrame
			if timeSinceLastTargeterExplosion >= configuration.lostTime then
				SetMissileLost(missileID, data, targeter, configuration)
				data.state = "lost"
			elseif data.state == "lost" and timeSinceLastTargeterExplosion < configuration.lostTime then -- restore
				data.state = "normal"
				UpdateMissileTarget(missileID, targeter)
			else
				UpdateMissileTarget(missileID, targeter)
			end
		end
	end
end
