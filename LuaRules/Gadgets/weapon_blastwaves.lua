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
		local size = tonumber(cp["blastwave_size"]) or 0 -- how big does the blastwave start off?
		local impulse = tonumber(cp["blastwave_impulse"]) or 180 -- how much impulse it has.
		local speed = tonumber(cp["blastwave_speed"]) or 30 -- how fast outwards the blastwave travels. In elmos/frame
		local lifespan = tonumber(cp["blastwave_life"]) or 30 -- how long it lasts before disappaiting.
		local losscoef = tonumber(cp["blastwave_lossfactor"]) or 0.95 -- how much energy does it lose each check?
		local damage = tonumber(cp["blastwave_damage"]) or 0
		local paradamage = tonumber(cp["blastwave_empdmg"]) or 0
		local paratime = tonumber(cp["blastwave_emptime"]) or 1
		local slowdmg = tonumber(cp["blastwave_slowdmg"]) or 0
		local overslow = tonumber(cp["blastwave_overslow"]) or 0
		local damagesfriendly = cp["blastwave_nofriendly"] == nil
		blastwaveDefs[id] = {
			size = size,
			impulse = impulse,
			speed = speed,
			lifespan = lifespan,
			losscoef = losscoef,
			damage = damage,
			paradmg = paradamage,
			paratime = paratime,
			slowdmg = slowdmg,
			damagesfriendly = damagesfriendly,
			overslow = overslow / 30,
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
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGetUnitTeam = Spring.GetUnitTeam
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local sqrt = math.sqrt

local function distance2d(x1,y1,x2,y2)
	return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)))
end

local function Updateblastwave(x, y, z, size, impulse, damage, attackerID, attackerTeam, weaponDefID, slow, para, attackerTeamID)
	local affected = spGetUnitsInSphere(x, y, z, size)
	if #affected == 0 then
		return
	end
	for i = 1, #affected do
		local unitID = affected[i]
		--Spring.Echo("attacker Ally Team: " .. tostring(attackerTeam) .. "\nMyTeam: " .. tostring(spGetUnitAllyTeam(unitID)))
		if blastwaveDefs[weaponDefID].damagesfriendly or (not blastwaveDefs[weaponDefID].damagesfriendly and (attackerTeam == nil or spGetUnitAllyTeam(unitID) ~=  attackerTeam)) then
			local ux, uy, uz = Spring.GetUnitPosition(unitID)
			local dx, dy, dz = (ux - x)/size, (uy - y)/size, (uz - z)/size
			local distance = distance2d(ux, uz, x, z)
			local ddist = 1 - ((size - distance) / size)
			local vx, vy, vz = impulse * dx, dy * impulse, dz * impulse
			local incoming = damage * ddist
			spAddUnitImpulse(unitID, vx, vy, vz)
			spAddUnitDamage(unitID, incoming, 0, attackerID, weaponDefID, vx, vy, vz) -- real damage first
			if para and para > 0 then
				local paratime = blastwaveDefs[weaponDefID].paratime or 1
				spAddUnitDamage(unitID, para * ddist, paratime, attackerID, weaponDefID, 0, 0, 0)
			end
			if slow and slow > 0 then
				GG.dealSlowToUnit(unitID, slow * ddist, blastwaveDefs[weaponDefID].overslow, attackerTeamID)
			end
			--Spring.Echo("Did " .. incoming .. " and " .. vx .. ", " .. vy .. ", " .. vz .. " to " .. unitID)
		end
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
			slowdmg = conf.slowdmg,
			paradmg = conf.paradmg,
			coef = conf.losscoef,
		}
		--Spring.Echo("attackerID: " .. tostring(attackerID) .."\nDamages Friendly: " .. tostring(conf.damagesfriendly))
		if attackerID then
			if conf.damagesfriendly then
				tab.attackerteam = spGetUnitAllyTeam(attackerID)
			end
			tab.attackerteamID = spGetUnitTeam(attackerID)
			local damagebonus = spGetUnitRulesParam(attackerID, "comm_damage_mult") or 1
			tab.damage = tab.damage * damagebonus
			local bonuscoef = spGetUnitRulesParam(attackerID, "comm_blastwave_coefbonus") or 0
			tab.coef = tab.coef + bonuscoef
		end
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
		Updateblastwave(data.x, data.y, data.z, data.size, data.impulse, data.damage, data.attacker, data.attackerteam, data.wepID, data.slowdmg, data.paradmg, data.attackerteamID)
		if data.lifespan == 0 then
			--Spring.Echo("Removing blastwave " .. id)
			IterableMap.Remove(handled, id)
		else
			local losscoef = data.coef
			data.size = data.size + config.speed
			data.impulse = data.impulse * losscoef
			data.damage = data.damage * losscoef
			data.lifespan = data.lifespan - 1
			data.slowdmg = data.slowdmg * losscoef
			data.paradmg = data.paradmg * losscoef
			--Spring.Echo("Update:\nSize: " .. data.size .. "\nimpulse: " .. data.impulse .. "\ndamage: " .. data.damage .. "\nlifespan: " .. data.lifespan)
		end
	end
end
