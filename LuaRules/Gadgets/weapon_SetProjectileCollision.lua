-- Is this even used?

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "SetProjectileCollsion",
		desc      = "",
		author    = "Shaman",
		date      = "12/19/2020",
		license   = "CC-0",
		layer     = -9999,
		enabled   = true,
	}
end

local projectiles = {}
local spSetProjectileCollision = Spring.SetProjectileCollision

local function SetProjectileCollision(proID, state)
	if not state and not projectiles[proID] then
		projectiles[proID] = false
		spSetProjectileCollision(proID) -- toggle
	elseif state and projectiles[proID] == false then
		projectiles[proID] = true
		spSetProjectileCollision(proID)
	elseif not state and projectiles[proID] == true then
		projectiles[proID] = false
		spSetProjectileCollision(proID) -- toggle
	end
end

local function GetProjectileCollision(proID)
	return projectiles[proID] or true
end

GG.SetProjectileCollision = SetProjectileCollision
GG.GetProjectileCollision = GetProjectileCollision

function gadget:ProjectileDestroyed(proID)
	projectiles[proID] = nil
end
