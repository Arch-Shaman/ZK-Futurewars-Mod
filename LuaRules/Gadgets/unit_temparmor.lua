if not gadgetHandler:IsSyncedCode() then -- SYNCED
	return
end

function gadget:GetInfo()
	return {
		name      = "Armor States",
		desc      = "Haxy Armors",
		author    = "Shaman",
		date      = "02-28-2023",
		license   = "CC-0",
		layer     = 0,
		enabled   = true,
	}
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local handledUnits = IterableMap.New() -- which units currently have armor. Table structure: {duration = number, armorValue = number}
local armoredUnits = {} -- table that holds units with armor.
local watchWeapons = {} -- table that tells PreDamageWantedDefs which weapondefs we want
local bufferProjectiles = {} -- stores information we may need for ranged units.
local deleteProjectiles = {} -- deletes from the buffer.

-- configs --
local MAXARMOR = 0.1
local CHECKTIME = 3 -- 10 hz or about 100ms

-- Speed ups --
-- These just make the code run faster.

local spValidUnitID = Spring.ValidUnitID
local spSetUnitArmored = Spring.SetUnitArmored
local INLOS = {inlos = true}
local debugMode = false

-- Config --
local configs = {}
for i = 1, #WeaponDefs do -- Iterate through every weapon def. WeaponDefs is an ordered table (meaning we have entries between 1 and some arbitrary number [like 863]
	local weaponDef = WeaponDefs[i] -- Store the current metatable so we can reference it.
	if weaponDef.customParams.grants_armor then -- does this weapon grant armor?
		local armorValue = tonumber(weaponDef.customParams.grants_armor)
		local armorDuration = math.ceil((tonumber(weaponDef.customParams.armor_duration) or 3) * 30) -- in seconds
		local impactEnemies = weaponDef.customParams.affects_enemy ~= nil
		local needsCaching = weaponDef.customParams.needscaching ~= nil -- use this to prevent lua errors on activated abilities.
		local noScaling = weaponDef.customParams.noscaling ~= nil -- use this to stop all scaling
		local noTimeScaling = noScaling or weaponDef.customParams.notimescaling ~= nil
		local noStacking = weaponDef.customParams.nostacking ~= nil
		if weaponDef.customParams.armor_duration == nil then
			Spring.Echo("[ArmorStates]: missing duration for " .. weaponDef.name .. " (ID " .. i .. "). Defaulting to 3s!")
		end
		if armorValue and armorDuration then
			configs[i] = {value = 1 - armorValue, duration = armorDuration, alliedOnly = not impactEnemies, noScaling = noScaling, noTimeScaling = noTimeScaling, noStacking = noStacking} -- store the info in the metatable.
			watchWeapons[#watchWeapons + 1] = i -- Add to watch weapon table so we can filter stuff out we don't need.
			if needsCaching then
				Script.SetWatchWeapon(i, true)
			end
			if debugMode then
				Spring.Echo("[ArmorStates] Added WeaponID " .. i .. " to gadget")
			end
		else -- something went wrong
			Spring.Echo("[ArmorStates]: missing armor value for " .. weaponDef.name .. " (ID " .. i .. ").")
		end
	end
end

function GG.SetUnitArmor(unitID, value) -- needed for crab and halberd or other armor changers. You'll need to set this up in unitscript.
	armoredUnits[unitID] = value
	if IterableMap.InMap(handledUnits, unitID) then
		local data = IterableMap.Get(handledUnits, unitID)
		if value < 1.0 then
			local newValue = math.max(value * data.armorValue, MAXARMOR)
			data.armorValue = newValue
			spSetUnitArmored(unitID, true, newValue)
		else
			spSetUnitArmored(unitID, true, data.armorValue)
		end
	else
		if value < 1.0 then
			spSetUnitArmored(unitID, true, value)
		else
			spSetUnitArmored(unitID, false, value)
		end
	end
end

local function CleanUpUnit(unitID)
	if armoredUnits[unitID] then
		spSetUnitArmored(unitID, true, armoredUnits[unitID]) -- revert to old armor.
	else
		spSetUnitArmored(unitID, false)
	end
	IterableMap.Remove(handledUnits, unitID)
	Spring.SetUnitRulesParam(unitID, "temporaryarmorduration", nil)
	Spring.SetUnitRulesParam(unitID, "temporaryarmormaxduration", nil)
	Spring.SetUnitRulesParam(unitID, "temporaryarmor", nil)
end

local function UpdateArmor(unitID, value, duration)
	if armoredUnits[unitID] then
		local newValue = math.max(value * armoredUnits[unitID], MAXARMOR)
		spSetUnitArmored(unitID, true, newValue)
	else
		spSetUnitArmored(unitID, true, value)
	end
	Spring.SetUnitRulesParam(unitID, "temporaryarmor", 1 - value, INLOS)
	Spring.SetUnitRulesParam(unitID, "temporaryarmorduration", duration, INLOS)
	if debugMode then Spring.Echo("Update Armor: " .. unitID .. ", " .. value) end
end
	

local function AddUnit(unitID, value, duration, noStacking)
	local data = IterableMap.Get(handledUnits, unitID)
	if data then
		if noStacking then
			if value == data.armorValue then 
				data.duration = math.max(duration, data.duration)
				UpdateArmor(unitID, value, data.duration)
			else
				local newDuration = (data.duration + duration) / 2 -- average out the duration
				local newValue = (data.armorValue + value) / 2
				data.armorValue = newValue
				data.duration = newDuration
				UpdateArmor(unitID, newValue, newDuration)
			end
		else
			data.duration = math.max(duration, data.duration)
			newValue = data.armorValue * value
			if newValue < MAXARMOR then newValue = MAXARMOR end
			data.armorValue = newValue
			UpdateArmor(unitID, newValue, newDuration)
		end
	else
		IterableMap.Add(handledUnits, unitID, {duration = duration, armorValue = value})
		UpdateArmor(unitID, value, duration)
	end
end

function gadget:UnitDestroyed(unitID)
	if IterableMap.InMap(handledUnits, unitID) then
		IterableMap.Remove(handledUnits, unitID)
	end
	armoredUnits[unitID] = nil
end

local function SpawnCEGForUnit(unitID)
	local _, _, _, x, y, z = Spring.GetUnitPosition(unitID, true)
	Spring.SpawnCEG("armor_vaporspawner", x, y, z, 0, 0, 0)
end

--              UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	local armorerTeam = (bufferProjectiles[projectileID] and bufferProjectiles[projectileID].teamID) or attackerTeam
	if debugMode then Spring.Echo("UnitPreDamaged: " .. unitID .. ", weaponDefID: " .. weaponDefID .. ", attackerTeam: " .. tostring(attackerTeam) .. ", AttackerID: " .. tostring(armorerTeam)) end
	if not armorerTeam then 
		if debugMode then 
			Spring.Echo("No Armorer Team") 
		end 
		return 0, 0 
	end
	local allyCheck = not configs[weaponDefID].alliedOnly or Spring.AreTeamsAllied(unitTeam, armorerTeam)
	if debugMode then
		Spring.Echo("UnitPreDamaged: Teams are allied: " .. tostring(allyCheck)) 
	end
	if allyCheck then
		local mult
		if configs[weaponDefID].noScaling then
			mult = 1
		else
			local wd = WeaponDefs[weaponDefID]
			local potentialDamage = wd.damages[1] -- probably default?
			mult = damage / potentialDamage
		end
		local duration = configs[weaponDefID].duration
		if not (configs[weaponDefID].noScaling or configs[weaponDefID].noTimeScaling) then
			duration = duration * mult
		end
		local armorValue = 1 - (mult * configs[weaponDefID].value)
		AddUnit(unitID, armorValue, duration, configs[weaponDefID].noStacking)
		SpawnCEGForUnit(unitID)
	end
	if bufferProjectiles[projectileID] and not bufferProjectiles[projectileID].willBeDeleted then
		local f = Spring.GetGameFrame() + (CHECKTIME * 10)
		if deleteProjectiles[f] then
			deleteProjectiles[f][#deleteProjectiles[f] + 1] = projectileID
		else
			deleteProjectiles[f] = {[1] = projectileID}
		end
		bufferProjectiles[projectileID].willBeDeleted = true
	end
	return 0, 0
end

function gadget:UnitPreDamaged_GetWantedWeaponDef() -- only do certain weapons.
	return watchWeapons
end

function gadget:ProjectileCreated(proID, proOwnerID, proWeaponDefID)
	if configs[proWeaponDefID] then 
		bufferProjectiles[proID] = {teamID = Spring.GetUnitTeam(proOwnerID), ownerID = proOwnerID, willBeDeleted = false}
	end
end

function gadget:GameFrame(f)
	if f%CHECKTIME == 0 then
		for unitID, data in IterableMap.Iterator(handledUnits) do
			if spValidUnitID(unitID) then -- protect us from invalid units.
				data.duration = data.duration - CHECKTIME
				if data.duration < 0 then
					CleanUpUnit(unitID)
				else
					data.duration = data.duration - CHECKTIME
					Spring.SetUnitRulesParam(unitID, "temporaryarmorduration", data.duration, INLOS)
				end
			end
		end
		if deleteProjectiles[f] then
			for i = 1, #deleteProjectiles do
				bufferProjectiles[deleteProjectiles[i]] = nil
			end
			deleteProjectiles[f] = nil
		end
	end
end

