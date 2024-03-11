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
local shieldDefs = {}
local wanted = {}

Spring.Echo("[Blastwaves] Loading defs")
for i = 1, #WeaponDefs do
	local cp = WeaponDefs[i].customParams
	local id = WeaponDefs[i].id
	if cp["blastwave_size"] then
		local size = tonumber(cp["blastwave_size"]) or 0 -- how big does the blastwave start off?
		local impulse = tonumber(cp["blastwave_impulse"]) or 0 -- how much impulse it has.
		local speed = tonumber(cp["blastwave_speed"]) or 30 -- how fast outwards the blastwave travels. In elmos/frame
		local lifespan = tonumber(cp["blastwave_life"]) or 30 -- how long it lasts before disappaiting.
		local losscoef = tonumber(cp["blastwave_lossfactor"]) or 0.95 -- how much energy does it lose each check?
		local damage = tonumber(cp["blastwave_damage"]) or 0
		local paradamage = tonumber(cp["blastwave_empdmg"]) or 0
		local paratime = tonumber(cp["blastwave_emptime"]) or 1
		local slowdmg = tonumber(cp["blastwave_slowdmg"]) or 0
		local overslow = tonumber(cp["blastwave_overslow"]) or 0
		local disarm = tonumber(cp["blastwave_disarm"]) or 0
		local disarmtime = tonumber(cp["blastwave_diarm_time"]) or 1
		local damagesfriendly = cp["blastwave_nofriendly"] == nil
		local healing = tonumber(cp["blastwave_healing"]) or 0
		local onlyallies = cp["blastwave_onlyfriendly"] == nil
		local reductshealing = tonumber(cp["blastwave_healing_reduction"]) or 0
		local spawnCeg = cp["blastwave_spawnceg"]
		local cegFreq = tonumber(cp["blastwave_spawncegfreq"]) or 3
		local luaOnly = cp["blastwave_luaspawnonly"] ~= nil
		--local shieldrestore = tonumber(cp["blastwave_shieldhealing"]) or 0  -- TODO shield restore actually does something
		--local shielddamage = tonumber(cp["blastwave_shielddamage"]) or 0
		
		blastwaveDefs[id] = {
			size = size,
			impulse = impulse,
			speed = speed,
			lifespan = lifespan,
			losscoef = losscoef,
			damage = damage,
			paradmg = paradamage,
			paratime = paratime,
			disarmdmg = disarm,
			disarmtime = disarmtime,
			slowdmg = slowdmg,
			damagesfriendly = damagesfriendly,
			healshostiles = onlyallies,
			healing = healing,
			overslow = overslow / 30,
			healingreduction = reductshealing,
			spawnCeg = spawnCeg,
			cegFreq = cegFreq,
			--shielddamage = shielddamage,
		}
		if not luaOnly then
			wanted[#wanted + 1] = id
			Script.SetWatchExplosion(id, true)
		end
		--Spring.Echo("[Blastwaves] Added " .. id)
	end
end

local IterableMap = Spring.Utilities.IterableMap
local handled = IterableMap.New()

local spGetUnitsInSphere = Spring.GetUnitsInSphere
local spAddUnitImpulse = Spring.AddUnitImpulse
local spAddUnitDamage = Spring.AddUnitDamage -- does not seem to register.
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGetUnitTeam = Spring.GetUnitTeam
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitPosition = Spring.GetUnitPosition
local spSetUnitHealth = Spring.SetUnitHealth
local spGetUnitHealth = Spring.GetUnitHealth
local spSpawnCEG = Spring.SpawnCEG
local spGetUnitDefID = Spring.GetUnitDefID
local sqrt = math.sqrt
local min = math.min

local function distance2d(x1,y1,x2,y2)
	return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)))
end

local function Updateblastwave(data) -- Updateblastwave(x, y, z, size, impulse, damage, attackerID, attackerTeam, weaponDefID, slow, para, attackerTeamID)
	local x, y, z, size = data.x, data.y, data.z, data.size
	local affected = spGetUnitsInSphere(x, y, z, size)
	local weaponDefID = data.wepID
	local def = blastwaveDefs[weaponDefID]
	if #affected > 0 then
		local attackerID, attackerTeamID, attackerTeam = data.attacker, data.attackerteamID, data.attackerteam
		local damage, impulse, slow, para = data.damage, data.impulse, data.slowdmg, data.paradmg
		local healing = data.healing
		for i = 1, #affected do
			local unitID = affected[i]
			local unitTeam = spGetUnitAllyTeam(unitID)
			
			local hostileCheck = def.damagesfriendly or (not def.damagesfriendly) and (attackerTeam == nil or unitTeam ~=  attackerTeam)
			local friendlyCheck = def.healshostiles or (attackerTeam ~= nil and unitTeam == attackerTeam)
			--Spring.Echo("attacker Ally Team: " .. tostring(attackerTeam) .. "\nMyTeam: " .. tostring(spGetUnitAllyTeam(unitID)))
			if hostileCheck then
				local _, _, _, ux, uy, uz = spGetUnitPosition(unitID, true)
				local dx, dy, dz = (ux - x)/size, (uy - y)/size, (uz - z)/size
				local distance = distance2d(ux, uz, x, z)
				local ddist = (size - distance) / size
				local vx, vy, vz = impulse * dx, dy * impulse, dz * impulse
				local incoming = damage * ddist
				if not UnitDefs[spGetUnitDefID(unitID)].customParams.singuimmune then
					spAddUnitImpulse(unitID, vx, vy, vz)
				end
				spAddUnitDamage(unitID, incoming, 0, attackerID, weaponDefID, vx, vy, vz) -- real damage first
				if para and para > 0 then
					local paratime = blastwaveDefs[weaponDefID].paratime or 1
					spAddUnitDamage(unitID, para * ddist, paratime, attackerID, weaponDefID, 0, 0, 0)
				end
				if slow and slow > 0 then
					GG.dealSlowToUnit(unitID, slow * ddist, blastwaveDefs[weaponDefID].overslow, attackerTeamID)
				end
				if data.disarm and data.disarm > 0 then
					GG.AddDisarmDamage(unitID, data.disarm, blastwaveDefs[weaponDefID].disarmtime * 30, nil)
				end
				--Spring.Echo("Did " .. incoming .. " and " .. vx .. ", " .. vy .. ", " .. vz .. " to " .. unitID)
			end
			if healing > 0 and friendlyCheck then -- deals healing.
				local hp, maxhp = spGetUnitHealth(unitID)
				if hp ~= maxhp then
					local ux, uy, uz = spGetUnitPosition(unitID)
					local distance = distance2d(ux, uz, x, z)
					local ddist = (size - distance) / size
					local missinghp = maxhp - hp
					local healingtodo = min(ddist * healing, missinghp)
					spSetUnitHealth(unitID, healingtodo + hp)
					if def.healingreduction > 0 then
						data.healing = data.healing - healingtodo
					end
				end
			end
			--if shielddamage > 0 and hostileCheck then
				--
			--end
		end
	end
	return data
end

local function AddBlastwave(weaponDefID, px, py, pz, attackerID, projectileID, team)
	--Spring.Echo("Spawning a blastwave!")
	if projectileID and IterableMap.InMap(handled, projectileID) then
		return
	end
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
		disarm = conf.disarmdmg,
		healing = conf.healing,
		coef = conf.losscoef,
		shielddmg = conf.shielddamage,
		attackerteam = team,
	}
	if conf.spawnCeg then
		tab.cegcounter = 0
		tab.wantedceg = conf.spawnCeg
	end
	--Spring.Echo("attackerID: " .. tostring(attackerID) .."\nDamages Friendly: " .. tostring(conf.damagesfriendly))
	if attackerID and Spring.ValidUnitID(attackerID) then
		if not (conf.damagesfriendly or conf.healshostiles) then
			tab.attackerteam = team or spGetUnitAllyTeam(attackerID)
		end
		tab.attackerteamID = spGetUnitTeam(attackerID)
		local damagebonus = spGetUnitRulesParam(attackerID, "comm_damage_mult") or 1
		tab.damage = tab.damage * damagebonus
		tab.slowdmg = tab.slowdmg * damagebonus
		tab.paradmg = tab.paradmg * damagebonus
		tab.disarm = tab.disarm * damagebonus
		local bonuscoef = spGetUnitRulesParam(attackerID, "comm_blastwave_coefbonus") or 0
		tab.coef = tab.coef + bonuscoef
	end
	if projectileID and projectileID == -1 then
		local newid = 0
		repeat
			newid = math.random(0, 999999) * -1
		until IterableMap.Get(handled, newid) == nil
		projectileID = newid
	end
	IterableMap.Add(handled, projectileID, tab)
end

function gadget:Explosion(weaponDefID, px, py, pz, attackerID, projectileID)
	if blastwaveDefs[weaponDefID] then
		local attackerTeam = Spring.ValidUnitID(attackerID) and Spring.GetUnitAllyTeam(attackerID)
		AddBlastwave(weaponDefID, px, py, pz, attackerID, projectileID, attackerTeam)
	end
	return false
end

function gadget:Explosion_GetWantedWeaponDef()
	return wanted
end

--[[function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if blastwaveDefs[weaponDefID] and projectileID then
		local px, py, pz = Spring.GetProjectilePosition(projectileID)
		AddBlastwave(weaponDefID, px, py, pz, attackerID, projectileID)
	end
end]]

GG.AddBlastwave = AddBlastwave

function gadget:GameFrame(f)
	for id, data in IterableMap.Iterator(handled) do
		local config = blastwaveDefs[data.wepID]
		data = Updateblastwave(data)
		if data.lifespan == 0 then
			--Spring.Echo("Removing blastwave " .. id)
			IterableMap.Remove(handled, id)
		else
			local losscoef = data.coef
			if data.cegcounter then
				data.cegcounter = data.cegcounter + 1
				if data.cegcounter > config.cegFreq then
					data.cegcounter = 0
					local damage = data.damage
					if data.healing and data.healing > 0 then
						damage = data.healing
					end
					spSpawnCEG(data.wantedceg, data.x, data.y, data.z, 0, 0, 0, 0, damage)
				end
			end
			data.size = data.size + config.speed
			data.impulse = data.impulse * losscoef
			data.damage = data.damage * losscoef
			data.disarm = data.disarm * losscoef
			data.lifespan = data.lifespan - 1
			data.slowdmg = data.slowdmg * losscoef
			data.paradmg = data.paradmg * losscoef
			data.healing = data.healing * losscoef
			--Spring.Echo("Update:\nSize: " .. data.size .. "\nimpulse: " .. data.impulse .. "\ndamage: " .. data.damage .. "\nlifespan: " .. data.lifespan)
		end
	end
end
