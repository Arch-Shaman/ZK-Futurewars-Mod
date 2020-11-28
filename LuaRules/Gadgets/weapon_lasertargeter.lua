function gadget:GetInfo()
	return {
		name      = "Missile Laser Targeter",
		desc      = "Missiles follow their targeter.",
		author    = "_Shaman",
		date      = "June 20, 2019",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local movectrlOn = Spring.MoveCtrl.Enable
local movectrlOff = Spring.MoveCtrl.Disable
local spEcho = Spring.Echo
local spGetGameFrame = Spring.GetGameFrame
local spGetProjectilePosition = Spring.GetProjectilePosition
local spGetProjectileTarget = Spring.GetProjectileTarget
local spGetProjectileTimeToLive = Spring.GetProjectileTimeToLive
local spGetGroundHeight = Spring.GetGroundHeight
local spDeleteProjectile = Spring.DeleteProjectile
local spGetProjectileOwnerID = Spring.GetProjectileOwnerID
local spGetProjectileVelocity = Spring.GetProjectileVelocity
local spGetUnitTeam = Spring.GetUnitTeam
local spPlaySoundFile = Spring.PlaySoundFile
local spSpawnExplosion = Spring.SpawnExplosion
local spSpawnProjectile = Spring.SpawnProjectile
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder
local spGetUnitsInSphere = Spring.GetUnitsInSphere
local spSetProjectileTarget = Spring.SetProjectileTarget
local spSetProjectileIgnoreTrackingError = Spring.SetProjectileIgnoreTrackingError
local spGetProjectileDefID = Spring.GetProjectileDefID
local spAreTeamsAllied = Spring.AreTeamsAllied
local spGetUnitIsCloaked = Spring.GetUnitIsCloaked
local SetWatchWeapon = Script.SetWatchWeapon
local spSetProjectileAlwaysVisible = Spring.SetProjectileAlwaysVisible
local spSetUnitPosition = Spring.SetUnitPosition
local spCreateUnit = Spring.CreateUnit
local spDestroyUnit = Spring.DestroyUnit
local spGetValidUnitID = Spring.ValidUnitID
local random = math.random
local sqrt = math.sqrt
local byte = string.byte
local abs = math.abs
local pi = math.pi
local strfind = string.find
local debug = false
local gaiaID = Spring.GetGaiaTeamID()

local missiles = {} -- id = {missiles = {projIDs},target = {x,y,z}, numMissiles = 0, fake = uid}
local config = {} -- targeter or tracker
local prolist = {} -- reverse lookup: proID = ownerID

local function debugecho(str)
	if debug then spEcho(str) end
end

for wid = 1, #WeaponDefs do
	debugecho(wid .. ": " .. tostring(WeaponDefs[wid].type) .. "\ntracker: " .. tostring(WeaponDefs[wid].customParams.tracker))
	if (WeaponDefs[wid].type == "MissileLauncher" or WeaponDefs[wid].type == "StarburstLauncher") and WeaponDefs[wid].customParams.tracker then
		config[wid] = 'tracker'
		SetWatchWeapon(wid, true)
	elseif WeaponDefs[wid].customParams.targeter then
		config[wid] = 'targeter'
		SetWatchWeapon(wid, true)
	end
end

local function PrintConfig()
	spEcho("Laser targeting config: ")
	for wid,type in pairs(config) do
		spEcho(wid .. ': ' .. type)
	end
end

local function GetMissileTracking(unitID, pid)
	if missiles[unitID] == nil then
		return true
	else
		return missile[unitID].state == "normal"
	end
end

GG.GetLaserTrackingEnabled = GetMissileTracking

if debug then PrintConfig() end

--[[function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if config[weaponDefID] and config[weaponDefID] == 'tracker' then
		local x,y,z = spGetUnitPosition(unitID)
		missiles[attackerID].target = {x,y,z}
		x,y,z = nil
		return damage,1
	end
end]] -- May not be needed?

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, projectileID)
	debugecho("Explosion: " .. tostring(weaponDefID, px, py, pz, AttackerID, projectileID))
	if config[weaponDefID] == 'targeter' then
		--spSetUnitPosition(missiles[AttackerID].target,px,py,pz)
		missiles[AttackerID].target[1] = px
		missiles[AttackerID].target[2] = py
		missiles[AttackerID].target[3] = pz
		if debug then
			local x = missiles[AttackerID].target[1]
			local y = missiles[AttackerID].target[2]
			local z = missiles[AttackerID].target[3]
			debugecho("position is: " .. tostring(x) .. ", " .. tostring(y) .. "," .. tostring(z))
		end
		debugecho("Set " .. AttackerID .. " target: " .. tostring(px) .. "," .. tostring(py) .. "," .. tostring(pz))
		local ux,uy,uz = spGetUnitPosition(AttackerID)
		debugecho("UnitPosition: " .. ux .. "," .. uy .. "," .. uz)
		missiles[AttackerID].lastframe = spGetGameFrame()
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID) -- proOwnerID is the unitID that fired the projectile
	debugecho("ProjectileCreated: " .. tostring(proID, proOwnerID, weaponDefID))
	if config[weaponDefID] and not missiles[proOwnerID] then
		debugecho("added UnitID#" .. proOwnerID)
		--local fakeid = spCreateUnit("missiletarget",0,0,0,0,gaiaID,false,false)
		--movectrlOn(fakeid)
		missiles[proOwnerID] = {missiles = {}, target = {[1] = 0, [2] = 0, [3] = 0}, numMissiles = 0, lastframe = spGetGameFrame(), state = "normal"}
	end
	--[[if config[weaponDefID] and config[weaponDefID] == 'targeter' then
		local x,y,z = spGetProjectilePosition(proID)
		debugecho("projectileID: " .. proID .. "\nPosition: " .. "\nX: " .. tostring(x) .. "\nY: " .. tostring(y) .. "\nZ: " .. tostring(z))
		spSetUnitPosition(missiles[proOwnerID].target, x,y,z)
		if debug then
			x,y,z = spGetUnitPosition(missiles[proOwnerID].target)
			debugecho("Fake unit position: " .. "x: " .. x .. ", y: " .. y .. " z: " ..z)
		end
		missiles[proOwnerID].lastframe = spGetGameFrame()]]
	if config[weaponDefID] and config[weaponDefID] == 'tracker' then
		debugecho("Added " .. proID .. " to " .. proOwnerID)
		--local x,y,z = spGetProjectilePosition(proID)
		--local vx,vy,vz = spGetProjectileVelocity(proID)
		--debugecho("velocity: " .. vx .. "," .. vy .. "," .. vz)
		--vy = vy + 10
		--spDeleteProjectile(proID)
		--local nproID = spSpawnProjectile(weaponDefID, {pos = {x,y,z}, speed = {vx,vy,vz}, team = spGetUnitTeam(proOwnerID), owner = proOwnerID, tracking = missiles[proOwnerID].target})
		local success = spSetProjectileTarget(proID, missiles[proOwnerID].target[1], missiles[proOwnerID].target[2], missiles[proOwnerID].target[3])
		debugecho(tostring(success))
		missiles[proOwnerID].missiles[proID] = true
		missiles[proOwnerID].numMissiles = missiles[proOwnerID].numMissiles + 1
		prolist[proID] = proOwnerID
	end
end

function gadget:ProjectileDestroyed(proID)
	if prolist[proID] then
		debugecho("destroyed " .. proID)
		missiles[prolist[proID]].missiles[proID] = nil
		missiles[prolist[proID]].numMissiles = missiles[prolist[proID]].numMissiles - 1
		prolist[proID] = nil
	end
end

function gadget:GameFrame(f)
	if f%3 == 0 then
		for id, data in pairs(missiles) do
			if f - data.lastframe > 10 and data.numMissiles > 0 then
				data.state = "lost"
				for pid,_ in pairs(data.missiles) do
					if not GG.GetMissileCruising(pid) then
						local x,y,z = spGetProjectilePosition(pid)
						y = spGetGroundHeight(x,z)
						debugecho("Setting " .. pid .. " lost target:" .. x .. "," .. y .. "," .. z)
						local success = spSetProjectileTarget(pid, x, y, z)
						debugecho("Success: " .. tostring(success))
					end
				end
			elseif f - data.lastframe < 10 and data.state ~= "normal" and data.numMissiles > 0 then
				data.state = "normal"
			end
			if data.state == "normal" and data.numMissiles > 0 then
				for pid,_ in pairs(data.missiles) do
					if not GG.GetMissileCruising(pid) then
						spSetProjectileTarget(pid, data.target[1], data.target[2], data.target[3])
					end
				end
			end
			if not spGetValidUnitID(id) and data.numMissiles == 0 then
				debugecho("removing " .. id)
				--spDestroyUnit(data.target)
				for pid,_ in pairs(data.missiles) do
					local x,y,z = spGetProjectilePosition(pid)
					y = spGetGroundHeight(x,z)
					debugecho("Setting " .. pid .. " lost target:" .. x .. "," .. y .. "," .. z)
					local success = spSetProjectileTarget(pid, x, y, z)
					debugecho("Success: " .. tostring(success))
				end
				missiles[id] = nil
			end
		end
	end
end
