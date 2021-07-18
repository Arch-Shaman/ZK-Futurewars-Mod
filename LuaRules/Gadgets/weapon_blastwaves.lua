if not (gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Blastwaves",
		desc      = "Simulates blastwaves effects (like nukes)",
		author    = "Shaman",
		date      = "06.17.21",
		license   = "CC-0",
		layer     = 0,
		enabled   = true
	}
end

local blastwaveDefs = {}
local wanted = {}

Spring.Echo("[Blastwaves] Loading defs")
for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	local id = WeaponDefs[i].id
	if cp["blastwave_size"] then
		local size = cp["blastwave_size"] -- how big does the blastwave start off?
		local impulse = cp["blastwave_impulse"] or 180 -- how much impulse it has.
		local speed = cp["blastwave_speed"] or 30 -- how fast outwards the blastwave travels. In elmos/frame
		local lifespan = cp["blastwave_life"] or 30 -- how long it lasts before disappaiting.
		local losscoef = cp["blastwave_lossfactor"] or 0.95 -- how much energy does it lose each check?
		local damage = cp["blastwave_damage"] or 0
		blastwaveDefs[id] = {
			size = size,
			impulse = impulse,
			speed = speed,
			lifespan = lifespan,
			losscoef = losscoef,
			damage = damage,
		}
		wanted[#wanted + 1] = id
		Script.SetWatchExplosion(id, true)
		Spring.Echo("[Blastwaves] Added " .. id)
	end
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local handled = IterableMap.New()

local spGetUnitsInSphere = Spring.GetUnitsInSphere
local spAddUnitImpulse = Spring.AddUnitImpulse
local spAddUnitDamage = Spring.AddUnitDamage -- does not seem to register.
local sqrt = math.sqrt

local function distance2d(x1,y1,x2,y2)
	return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)))
end

local function Updateblastwave(x, y, z, size, impulse, damage, attackerID, weaponDefID)
	local affected = spGetUnitsInSphere(x, y, z, size)
	if #affected == 0 then
		return
	end
	for i = 1, #affected do
		local unitID = affected[i]
		local ux, uy, uz = Spring.GetUnitPosition(unitID)
		local dx, dy, dz = (ux - x)/size, (uy - y)/size, (uz - z)/size
		local distance = distance2d(ux, uz, x, z)
		local ddist = 1 - ((size - distance) / size)
		local vx, vy, vz = impulse * dx, dy * impulse, dz * impulse
		local incoming = damage * ddist
		spAddUnitImpulse(unitID, vx, vy, vz)
		--spAddUnitDamage(unitID, incoming, 0, attackerID, -1, vx, vy, vz)
		spAddUnitDamage(unitID, incoming, 0, attackerID, weaponDefID, vx, vy, vz)
		--Spring.Echo("Did " .. incoming .. " and " .. vx .. ", " .. vy .. ", " .. vz .. " to " .. unitID)
	end
end

function gadget:Explosion(weaponDefID, px, py, pz, attackerID, projectileID)
	if blastwaveDefs[weaponDefID] then
		--Spring.Echo("Spawning a blastwave!")
		local conf = blastwaveDefs[weaponDefID]
		local tab = {
			x = px,
			y = py,
			z = pz,
			damage = conf.damage,
			impulse = conf.impulse,
			size = conf.size,
			lifespan = conf.lifespan,
			wepID = weaponDefID,
			attacker = attackerID,
		}
		if projectileID == -1 then
			local newid = 0
			repeat
				newid = math.random(0, 999999)
			until IterableMap.Get(handled, newid) == nil
			projectileID = newid
		end
		IterableMap.Add(handled, projectileID, tab)
	end
	return false
end

function gadget:Explosion_GetWantedWeaponDef()
	return wanted
end

function gadget:GameFrame(f)
	for id, data in IterableMap.Iterator(handled) do
		local config = blastwaveDefs[data.wepID]
		Updateblastwave(data.x, data.y, data.z, data.size, data.impulse, data.damage, data.attacker, data.wepID)
		if data.lifespan == 0 then
			--Spring.Echo("Removing blastwave " .. id)
			IterableMap.Remove(handled, id)
		else
			data.size = data.size + config.speed
			data.impulse = data.impulse * config.losscoef
			data.damage = data.damage * config.losscoef
			data.lifespan = data.lifespan - 1
			--Spring.Echo("Update:\nSize: " .. data.size .. "\nimpulse: " .. data.impulse .. "\ndamage: " .. data.damage .. "\nlifespan: " .. data.lifespan)
		end
	end
end
