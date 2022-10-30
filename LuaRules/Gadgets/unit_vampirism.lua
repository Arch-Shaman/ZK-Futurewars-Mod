if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name    = "Vampirism",
		desc    = "Restores life / gives units max HP / hp based on damage value.",
		author  = "Shaman",
		date    = "30 July, 2022",
		license = "CC-0",
		layer   = 0,
		enabled = true,
	}

end
local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local vampirism_rewards = IterableMap.New() -- killed = {damager = damageValue}
local vampireDefs = {units = {}, weapons = {}}
local wantedWeapons = {}
local decaytime = 50*30
local decayfreq = 60
local decaymult = 0.6

local INLOS = {inlos = true}

Spring.Echo("[Vampirism] Loading config.")
for i = 1, #UnitDefs do
	local def = UnitDefs[i]
	if def.customParams.vampirism_kill then
		vampireDefs.units[i] = tonumber(def.customParams.vampirism_kill)
	end
end

for w = 1, #WeaponDefs do
	local def = WeaponDefs[w]
	local eff = tonumber(def.customParams.vampirism)
	if eff then
		wantedWeapons[#wantedWeapons + 1] = w
		vampireDefs.weapons[w] = eff
		Spring.Echo("[Vampirism] Enabled for " .. def.name)
	end
end

local function AddValueAndCleanup(unitID, unitDef, value)
	if not Spring.ValidUnitID(unitID) then
		return
	end
	local health, maxhealth = Spring.GetUnitHealth(unitID)
	if health > 0 then
		local commParam = Spring.GetUnitRulesParam(unitID, "comm_vampire")
		local eff = commParam or vampireDefs.units[unitDef]
		value = value * eff
		Spring.SetUnitMaxHealth(unitID, maxhealth + value)
		Spring.SetUnitHealth(unitID, health + value)
		if commParam then
			local old = Spring.GetUnitRulesParam(unitID, "comm_vampirebonus") or 0
			Spring.SetUnitRulesParam(unitID, "comm_vampirebonus", old + value, INLOS)
		end
	end
end

local function RewardVampires(unitID)
	local data = IterableMap.Get(vampirism_rewards, unitID)
	if data then
		for id, value in IterableMap.Iterator(data.rewards) do
			AddValueAndCleanup(id, Spring.GetUnitDefID(id), value)
		end
		IterableMap.Remove(vampirism_rewards, unitID)
	end
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	local validAttacker = Spring.ValidUnitID(attackerID)
	if not validAttacker then
		return
	end
	local isVampire = (vampireDefs.units[attackerDefID] or Spring.GetUnitRulesParam(attackerID, "comm_vampire") ~= nil)
	local vampirismMod = Spring.GetUnitRulesParam(attackerID, "comm_weapon_healing") or vampireDefs.weapons[weaponID]
	if not (isVampire or vampirismMod) then
		return
	end
	if isVampire and damage > 0 and not Spring.AreTeamsAllied(unitTeam, attackerTeam) then
		local data = IterableMap.Get(vampirism_rewards, unitID)
		if data then
			local reward = IterableMap.Get(data.rewards, attackerID)
			if reward then
				reward = reward + damage
				IterableMap.Set(data.rewards, attackerID, reward)
			else
				IterableMap.Add(data.rewards, attackerID, damage)
			end
			data.lastAttack = Spring.GetGameFrame()
		else
			local health, maxhealth = Spring.GetUnitHealth(unitID)
			if damage > health then
				AddValueAndCleanup(attackerID, attackerDefID, health)
			else
				local data = {lastAttack = Spring.GetGameFrame(), rewards = IterableMap.New()}
				IterableMap.Add(data.rewards, attackerID, damage)
				IterableMap.Add(vampirism_rewards, unitID, data)
			end
		end
	end
	if vampirismMod then
		local health, maxhealth = Spring.GetUnitHealth(attackerID)
		if health > 0 and health < maxhealth then
			local value = damage * vampirismMod
			Spring.SetUnitHealth(attackerID, math.min(health + value, maxhealth))
		end
	end
end

function gadget:UnitDestroyed(unitID)
	local morphedFrom = Spring.GetUnitRulesParam(unitID, "wasMorphedTo")
	if not morphedFrom then
		RewardVampires(unitID)
	end
end

function gadget:GameFrame(f)
	if f%30 == 0 then -- once a second.
		for id, data in IterableMap.Iterator(vampirism_rewards) do
			local lasttime = f - data.lastAttack
			if lasttime > 0 and lasttime%decayfreq == 0 then
				local count = 0
				for rewardee, reward in IterableMap.Iterator(data.rewards) do
					reward = reward * decaymult
					if reward < 1 then
						IterableMap.Remove(data.rewards, rewardee)
					else
						count = count + 1
						IterableMap.Set(data.rewards, rewardee, reward)
					end
				end
				if count == 0 then
					IterableMap.Remove(vampirism_rewards, id)
				end
			end
		end
	end
end
