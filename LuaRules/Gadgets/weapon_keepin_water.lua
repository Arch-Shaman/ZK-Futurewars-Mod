function gadget:GetInfo()
	return {
		name      = "Keep Torpedos From Dolphining",
		desc      = "",
		author    = "Shaman",
		date      = "3/13/2021",
		license   = "CC-0",
		layer     = 0,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local config = {}
local projectiles = IterableMap.New()
local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local spGetProjectilePosition = Spring.GetProjectilePosition
local spSetProjectileGravity = Spring.SetProjectileGravity 

for i = 1, #WeaponDefs do
	local customparams = WeaponDefs[i].customParams
	if customparams.keepinwater then
		config[i] = true
		Script.SetWatchWeapon(i)
	end
end

function gadget:GameFrame(f)
	if f%5 == 0 then
		for id, _ in IterableMap.Iterator(projectiles)
			local _, y, _ = spGetProjectilePosition(id)
			if y <= -5 then
				spSetProjectileGravity(id, -500)
				IterableMap.Remove(projectiles, id)
			end
		end
	end
end

function gadget:ProjectileDestroyed(proID)
	if IterableMap.InMap(projectiles, proID) then
		IterableMap.Remove(projectiles, proID)
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if config[weaponDefID] then
		IterableMap.Add(projectiles, proID, true)
	end
end
