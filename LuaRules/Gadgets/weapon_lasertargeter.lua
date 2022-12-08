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
local spSetProjectileTarget = Spring.SetProjectileTarget
local SetWatchWeapon = Script.SetWatchWeapon
local spGetValidUnitID = Spring.ValidUnitID
local debugMode = false

local missiles = {} -- id = {missiles = {projIDs},target = {x,y,z}, numMissiles = 0, fake = uid}
local config = {} -- targeter or tracker
local prolist = {} -- reverse lookup: proID = ownerID

for wid = 1, #WeaponDefs do
	--debugecho(wid .. ": " .. tostring(WeaponDefs[wid].type) .. "\ntracker: " .. tostring(WeaponDefs[wid].customParams.tracker))
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

if debugMode then PrintConfig() end

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, projectileID)
	--debugecho("Explosion: " .. tostring(weaponDefID, px, py, pz, AttackerID, projectileID))
	if config[weaponDefID] == 'targeter' then
		--spSetUnitPosition(missiles[AttackerID].target,px,py,pz)
		missiles[AttackerID].target[1] = px
		missiles[AttackerID].target[2] = py
		missiles[AttackerID].target[3] = pz
		if debugMode then
			local x = missiles[AttackerID].target[1]
			local y = missiles[AttackerID].target[2]
			local z = missiles[AttackerID].target[3]
			spEcho("position is: " .. tostring(x) .. ", " .. tostring(y) .. "," .. tostring(z))
			spEcho("Set " .. AttackerID .. " target: " .. tostring(px) .. "," .. tostring(py) .. "," .. tostring(pz))
			local ux,uy,uz = spGetUnitPosition(AttackerID)
			spEcho("UnitPosition: " .. ux .. "," .. uy .. "," .. uz)
		end
		missiles[AttackerID].lastframe = spGetGameFrame()
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID) -- proOwnerID is the unitID that fired the projectile
	if config[weaponDefID] and not missiles[proOwnerID] then
		missiles[proOwnerID] = {missiles = {}, target = {[1] = 0, [2] = 0, [3] = 0}, numMissiles = 0, lastframe = spGetGameFrame(), state = "normal"}
	end
	if config[weaponDefID] and config[weaponDefID] == 'tracker' then
		if debugMode then
			spEcho("Added " .. proID .. " to " .. proOwnerID)
		end
		spSetProjectileTarget(proID, missiles[proOwnerID].target[1], missiles[proOwnerID].target[2], missiles[proOwnerID].target[3])
		--debugecho(tostring(success))
		missiles[proOwnerID].missiles[proID] = true
		missiles[proOwnerID].numMissiles = missiles[proOwnerID].numMissiles + 1
		prolist[proID] = proOwnerID
	end
end

function gadget:ProjectileDestroyed(proID)
	if prolist[proID] then
		--debugecho("destroyed " .. proID)
		missiles[prolist[proID]].missiles[proID] = nil
		missiles[prolist[proID]].numMissiles = missiles[prolist[proID]].numMissiles - 1
		prolist[proID] = nil
	end
end

function GG.GetLaserTarget(proID)
	if prolist[proID] then
		local target = missiles[prolist[proID]].target
		if missiles[prolist[proID]].state == "normal" then
			return target[1], target[2], target[3]
		else
			local x, _, z = spGetProjectilePosition(proID)
			return x, spGetGroundHeight(x,z), z
		end
	else
		return nil
	end
end

function gadget:GameFrame(f)
	if f%3 == 0 then
		for id, data in pairs(missiles) do
			if f - data.lastframe > 20 and data.numMissiles > 0 then
				data.state = "lost"
				for pid,_ in pairs(data.missiles) do
					local x,y,z = spGetProjectilePosition(pid)
					y = spGetGroundHeight(x,z)
					if not GG.GetMissileCruising(pid) then
						if debugMode then
							spEcho("Setting " .. pid .. " lost target:" .. x .. "," .. y .. "," .. z)
						end
						local success = spSetProjectileTarget(pid, x, y, z)
						if debugMode then
							spEcho("Success: " .. tostring(success))
						end
					else
						GG.ForceCruiseUpdate(pid, x, y, z)
					end
				end
			elseif f - data.lastframe < 20 and data.state ~= "normal" and data.numMissiles > 0 then
				data.state = "normal"
			end
			if data.state == "normal" and data.numMissiles > 0 then
				for pid,_ in pairs(data.missiles) do
					if not GG.GetMissileCruising(pid) then
						spSetProjectileTarget(pid, data.target[1], data.target[2], data.target[3])
					else
						GG.ForceCruiseUpdate(pid, data.target[1], data.target[2], data.target[3])
					end
				end
			end
			if not spGetValidUnitID(id) and data.numMissiles == 0 then
				--debugecho("removing " .. id)
				for pid,_ in pairs(data.missiles) do
					local x,y,z = spGetProjectilePosition(pid)
					y = spGetGroundHeight(x,z)
					if debugMode then
						spEcho("Setting " .. pid .. " lost target:" .. x .. "," .. y .. "," .. z)
					end
					local success = spSetProjectileTarget(pid, x, y, z)
					if debugMode then
						spEcho("Success: " .. tostring(success))
					end
				end
				missiles[id] = nil
			end
		end
	end
end
