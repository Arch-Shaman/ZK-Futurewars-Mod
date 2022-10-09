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

local function RewardVampire(unitID, unitDef, value)
	if Spring.ValidUnitID(unitID) then
		local eff = vampireDefs.units[unitDef]
		value = eff * value
		local health, maxhealth = Spring.GetUnitHealth(unitID)
		Spring.SetUnitHealth(unitID, health + value)
		Spring.SetUnitMaxHealth(unitID, maxhealth + value)
	end
end

local function RewardVampires(unitID)
	local data = IterableMap.Get(vampirism_rewards, unitID)
	if data then
		for id, value in IterableMap.Iterator(data.rewards) do
			if Spring.ValidUnitID(id) then
				local unitDef = Spring.GetUnitDefID(id)
				local eff = vampireDefs.units[unitDef]
				value = eff * value
				local health, maxhealth = Spring.GetUnitHealth(id)
				local hpratio = health/maxhealth
				local newmax = maxhealth + value
				Spring.SetUnitMaxHealth(id, newmax)
				Spring.SetUnitHealth(id, hpratio * newmax)
			end
		end
		IterableMap.Remove(vampirism_rewards, unitID)
	end
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	if vampireDefs.units[attackerDefID] and damage > 0 and not Spring.AreTeamsAllied(unitTeam, attackerTeam) then
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
				RewardVampire(unitID, unitDef, health)
			else
				local data = {lastAttack = Spring.GetGameFrame(), rewards = IterableMap.New()}
				IterableMap.Add(data.rewards, attackerID, damage)
				IterableMap.Add(vampirism_rewards, unitID, data)
			end
		end
	end
	if vampireDefs.weapons[weaponID] then
		local health, maxhealth = Spring.GetUnitHealth(attackerID)
		local value = damage * vampireDefs.weapons[weaponID]
		Spring.SetUnitHealth(attackerID, math.min(health + value, maxhealth))
	end
end

function gadget:UnitDestroyed(unitID)
	RewardVampires(unitID)
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
