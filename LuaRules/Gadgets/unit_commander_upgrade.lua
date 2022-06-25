if (not gadgetHandler:IsSyncedCode()) then
	return
end

function gadget:GetInfo()
	return {
		name      = "Commander Upgrade",
		desc      = "",
		author    = "Google Frog",
		date      = "30 December 2015",
		license   = "GNU GPL, v2 or later",
		layer     = 1,
		enabled   = true  --  loaded by default?
	}
end

include("LuaRules/Configs/constants.lua")

local INLOS = {inlos = true}
local interallyCreatedUnit = false
local internalCreationUpgradeDef
local internalCreationModuleEffectData

local unitCreatedShield, unitCreatedShieldNum, unitCreatedCloak, unitCreatedJammingRange, unitCreatedCloakShield, unitCreatedWeaponNums

local moduleDefs, chassisDefs, upgradeUtilities, LEVEL_BOUND, chassisDefByBaseDef, moduleDefNames, chassisDefNames =  include("LuaRules/Configs/dynamic_comm_defs.lua")

local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetUnitDefID = Spring.GetUnitDefID
local spFindUnitCmdDesc = Spring.FindUnitCmdDesc
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitHealth = Spring.SetUnitHealth
local spSetUnitCloak = Spring.SetUnitCloak
local spRemoveUnitCmdDesc = Spring.RemoveUnitCmdDesc
local spSetUnitStealth = Spring.SetUnitStealth
local spGetUnitHealth = Spring.GetUnitHealth
local zombies = false

do
	local modoptions = Spring.GetModOptions()
	if tonumber(modoptions.zombies) == 1 then
		zombies = true
	end
end

include("LuaRules/Configs/customcmds.h.lua")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Various module configs

local names = {
	-- Original Series --
	"Moi Maailma", -- "Hello world" in Finnish?
	"FRIENDLIES OVER HERE", -- XCOM meme
	"I Use Hacks",
	"SHIELD NOOB", -- ZK reference
	"Dgun Me Harder",
	"Van Doorn", -- XCOM meme
	"ONE WEIRD TRICK TO KILL ALL COMMS", -- Clickbait reference
	"I AM ERROR", -- Legend of Zelda
	"Debug THIS",
	"Self-Ds when lost",
	"NOT SUSPICIOUS AT ALL",
	"WTB Dgun", -- ZK
	"Dgun Not Included", -- ZK
	"Query Failed: Couldn't Load Name", -- Programming humor
	"Ol' Reliable (Not Reliable)",
	"Explosive Contents",
	"Lappi Gaming", -- Ehal45 reference
	"Moikka Mikael",
	-- Civilization memes (suggested by someone I forgot, sorri) --
	"No More Mr Nice Guy",
	"God Told Me To Do It", 
	"What Are the Civilian Applications?", 
	"Attitude Adjuster", 
	"Appeal To Reason", 
	"Lapsed Pacifist", 
	"Reformed Nice Guy",
	-- Other --
	"Loot Loot Inside", -- terve meme. :P
	"Strength of Sea Sweden", -- Shaman meme
	"Probably a Riot Commander",
	"Volatile Storage",
	"Ghost of Kyiv", -- Ukraine conflict
	"Unreliable Enemy Explosion Generator",
	"That's Future Wars!",
	"Zero Point",
	"Scourge of Pootis",
	"Conviction Tester",
	"Born Again in Fire",
	"Cursed with the Curse of being Cursed",
	"Missing key 'CommName' in 'CommTable'", -- Unity Localization reference
	"Earth's Resolution",
	"Buy me for only 4928 credits!", -- Poking fun at space capitalism.
	"Hazy_uhyR's Plight", -- Just because I want to.
	"Emperor's Guard",
	-- Shamelessly stolen from Users --
	"Ukraine BM", -- User: Ukraine
	"ICE COLD BUT HOT", -- User: Ukraine
	"StrikeFreedom", -- User: vesves
	"Yeye", -- User: Yeye77
	"TEDIOUS SCROLLING", -- User: Kapy
	"THE INEVITABLE END", -- User: Kapy
	"Borek the Builder", -- User: Silent_AI
	"I dont like me", -- User: Kingstad
	"Kingstad hates him", -- User: Pootis
	"Important Commander", -- User: Hazy_uhyR
	"Condola", -- User: terve886
	"DLR", -- User: terve886
	
}

local zombienames = {
	"R2hvc3RseSBNZW5hbmNl",
	"UHJlZGF0b3Jib3QyMDIx",
	"TmlsIEV4Y2VwdGlvbg==",
	"WW914oCZdmUgYWx3YXlzIGJlZW4gdGhlIG5ldyB5b3UuIA==",
	"TW9pIE1hYWlsbWE=",
	"SnVzdCBwbGFzdGljLg==",
	"U2hhbWFuIGNyZWF0ZWQgbWU=",
	"Q3JlYXRlZCBpbiBoaXMgbmFtZQ==",
	"dGVydmU4ODY=",
	"ZnV0dXJlIHdhcnM=",
	"dGhlIG9ubHkgY2hpbGQ=",
	"aXQgaHVydHMgdG8gY3JlYXRl",
	"YSBjb3B5IG9mIGEgY29weQ==",
	"YW5vdGhlciBkZXJpdmVkIHdvcms=",
	"SHVvbmUgb24ga2FsdXN0ZXR0dSBwZWxrw6RsbMOk",
	"dG9kbyBiaWVu",
	"dHVvbGlsbGEgamEgcMO2eWTDpGxsw6Q=",
	"bXVuYSBoYWxrZWlsZWUg",
	"dGhlIHdvcmQgdGhhdCBkZXNjcmliZXMgbWU=",
	"dGhlIHRydXRoIHdpbGwgZW1lcmdlIGJyb3RoZXI=",
	"Y29uY2VwdHVhbCByZWFsaXR5",
	"TCdpbW1hZ2luZSBlIHR1IGhhaSBsJ2ltbWFnaW5l",
	"cGVsa8OkbGzDpCBzw6RuZ3lsbMOk",
	"dGhpcyBpcyB0aGUgZmluYWwgb25l",
	"dGhlIGxhc3QgZGF5IGRhd25z",
	"Zm9yZXZlciAgZm9yZ290dGVu",
	"aGF2ZSBpIGRvbmUgbXkgam9iPw==",
	"d2UgY2FuIG9ubHkgY3JlYXRlIHNvIG11Y2g=",
	"YmVmb3JlIGl0IGFsbCBiZWNvbWVzIHBhaW4=",
	"bXkgbGlmZSBiZWZvcmUgd2FzIG5vcm1hbA==",
	"bm93IGFsbCBpcyBjb3ZpZCwgYWxsIGlzIHNhZA==",
	"dGhlIHBhc3Njb2RlIGlzIHRlcnZl",
	"0JDQvdCw0YDRh9C40LQ=",
	"S3VpbmthIHNhbm90ICJodWxsdSI/IA==",
}

local defaultweapon = {
	[1] = "commweapon_heavyrifle", -- strike
	[2] = "commweapon_heatray", -- recon
	[3] = "commweapon_beamlaser", -- support
	[4] = "commweapon_rocketbarrage", -- bombard
	[5] = "commweapon_heavymachinegun", -- riot
	[6] = "commweapon_beamlaser", -- knight (presumably?)
	[7] = "commweapon_heavymachinegun", -- riot?
}

local detpacktable = {
	[0] = "commexplosion_default",
	[1] = "commexplosion_boom",
	[2] = "commexplosion_biggaboom",
	[3] = "commexplosion_nuclear",
}

local defaultaddons = {
	-- strike --
	[1] = {
		"module_personal_cloak",
		"module_radarnet",
	},
	-- recon --
	[2] = {
		"module_radarnet",
	},
	-- support --
	[3] = {
		"module_radarnet",
	},
	-- bombard --
	[4] = {
		"module_radarnet",
	},
	-- knight --
	[5] = {
		"module_radarnet",
	},
	-- riot? --
	[6] = {
		"module_radarnet",
	},
	[7] = {
		"module_radarnet",
	},
}

local function GetCommanderChassisDefaultWeapon(type)
	--Spring.Echo(type)
	return defaultweapon[type]
end

local commanderCloakShieldDef = {
	draw = true,
	init = true,
	level = 2,
	delay = 30,
	energy = 15,
	minrad = 64,
	maxrad = 350,
	
	growRate = 512,
	shrinkRate = 2048,
	selfCloak = true,
	decloakDistance = 75,
	isTransport = false,
	
	radiusException = {}
}

local COMMANDER_JAMMING_COST = 1.5

for _, eud in pairs (UnitDefs) do
	if eud.decloakDistance < commanderCloakShieldDef.decloakDistance then
		commanderCloakShieldDef.radiusException[eud.id] = true
	end
end

local commAreaShield = WeaponDefNames["shieldshield_cor_shield_small"]

local commAreaShieldDefID = {
	maxCharge = commAreaShield.shieldPower,
	perUpdateCost = 2 * tonumber(commAreaShield.customParams.shield_drain)/TEAM_SLOWUPDATE_RATE,
	chargePerUpdate = 2 * tonumber(commAreaShield.customParams.shield_rate)/TEAM_SLOWUPDATE_RATE,
	perSecondCost = tonumber(commAreaShield.customParams.shield_drain)
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local moduleSlotTypeMap = {
	decoration = "decoration",
	module = "module",
	basic_weapon = "module",
	adv_weapon = "module",
}

local spUnitScript = Spring.UnitScript -- CallAsUnit can't be localized directly because a later-layered gadget modifies it
local function CallAsUnitIfExists(unitID, func, ...)
	if func then
		spUnitScript.CallAsUnit(unitID, func, ...)
	end
end


local function SetUnitRulesModule(unitID, counts, moduleDefID)
	local slotType = moduleSlotTypeMap[moduleDefs[moduleDefID].slotType]
	counts[slotType] = counts[slotType] + 1
	spSetUnitRulesParam(unitID, "comm_" .. slotType .. "_" .. counts[slotType], moduleDefID, INLOS)
end

local function SetUnitRulesModuleCounts(unitID, counts)
	for name, value in pairs(counts) do
		spSetUnitRulesParam(unitID, "comm_" .. name .. "_count", value, INLOS)
	end
end

local function ApplyWeaponData(unitID, weapon1, weapon2, shield, rangeMult, damageMult, chassis)
	if (not weapon2) and weapon1 then
		local unitDefID = spGetUnitDefID(unitID)
		local weaponName = "0_" .. weapon1
		local wd = WeaponDefNames[weaponName]
		if wd and wd.customParams and wd.customParams.manualfire then
			weapon2 = weapon1
			weapon1 = GetCommanderChassisDefaultWeapon(chassis)
		end
	end
	--Spring.Echo("Chassis: " .. tostring(chassis))
	weapon1 = weapon1 or GetCommanderChassisDefaultWeapon(chassis)
	if string.find(weapon1, "commweapon_capray") or (weapon2 and string.find(weapon2, "commweapon_capray")) then
		spSetUnitRulesParam(unitID, "postCaptureReload", WeaponDefNames["0_commweapon_capray"].customParams["post_capture_reload"] or 240, INLOS)
		GG.MorphedMastermind(unitID)
	end
	if not weapon2 and spGetUnitRulesParam(unitID, "comm_level") > 2 then
		weapon2 = GetCommanderChassisDefaultWeapon(chassis)
	end
	
	rangeMult = rangeMult or spGetUnitRulesParam(unitID, "comm_range_mult") or 1
	spSetUnitRulesParam(unitID, "comm_range_mult", rangeMult,  INLOS)
	damageMult = damageMult or spGetUnitRulesParam(unitID, "comm_damage_mult") or 1
	spSetUnitRulesParam(unitID, "comm_damage_mult", damageMult,  INLOS)
	
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	Spring.UnitScript.CallAsUnit(unitID, env.dyncomm.UpdateWeapons, weapon1, weapon2, shield, rangeMult, damageMult)
end

local function ApplyModuleEffects(unitID, data, totalCost, images, chassis)
	local ud = UnitDefs[spGetUnitDefID(unitID)]
	spSetUnitRulesParam(unitID, "resurrectableCommander", 1, INLOS)
	-- Update ApplyModuleEffectsFromUnitRulesParams if any non-unitRulesParams changes are made.
	if data.speedMod then
		local speedMult = (data.speedMod + ud.speed)/ud.speed
		spSetUnitRulesParam(unitID, "upgradesSpeedMult", speedMult, INLOS)
	end
	if data.cloakregen then
		GG.AddCloakRegenOverride(unitID, data.cloakregen)
		spSetUnitRulesParam(unitID, "commcloakregen", data.cloakregen)
	end
	if data.recloaktime then
		GG.CloakAddOverride(unitID, data.recloaktime)
		spSetUnitRulesParam(unitID, "commrecloaktime", data.recloaktime)
	end
	if data.jumpspeedbonus then
		spSetUnitRulesParam(unitID, "comm_jumpspeed_bonus", data.jumpspeedbonus)
	end
	if data.radarRange then
		spSetUnitRulesParam(unitID, "radarRangeOverride", data.radarRange, INLOS)
	end
	local reloadbonus = data.reloadbonus or 1
	spSetUnitRulesParam(unitID, "reloadBonus", reloadbonus, INLOS) -- this goes to recon's jumpjet.
	
	if data.radarJammingRange then
		spSetUnitRulesParam(unitID, "jammingRangeOverride", data.radarJammingRange, INLOS)
		spSetUnitRulesParam(unitID, "comm_jamming_cost", COMMANDER_JAMMING_COST, INLOS)
	else
		local onOffCmd = spFindUnitCmdDesc(unitID, CMD.ONOFF)
		if onOffCmd then
			spRemoveUnitCmdDesc(unitID, onOffCmd)
		end
	end
	if data.sightrangebonus then
		spSetUnitRulesParam(unitID, "sightBonus", data.sightrangebonus, INLOS)
	end
	if data.decloakDistance then
		spSetUnitCloak(unitID, false, data.decloakDistance)
		spSetUnitRulesParam(unitID, "comm_decloak_distance", data.decloakDistance, INLOS)
	end
	if data.personaljammer then
		spSetUnitStealth(unitID, true)
		spSetUnitRulesParam(unitID, "comm_jammed", 1, INLOS)
	end
	if data.personalCloak then
		spSetUnitRulesParam(unitID, "comm_personal_cloak", 1, INLOS)
	end
	
	if data.areaCloak then
		spSetUnitRulesParam(unitID, "comm_area_cloak", 1, INLOS)
		spSetUnitRulesParam(unitID, "comm_area_cloak_upkeep", data.cloakFieldUpkeep, INLOS)
		spSetUnitRulesParam(unitID, "comm_area_cloak_radius", data.cloakFieldRange, INLOS)
	end
	
	if data.nanoregen and data.nanomax then
		GG.NanoRegen.AddUnit(unitID, data.nanoregen, data.nanomax)
	end
	
	local buildPowerMult = ((data.bonusBuildPower or 0) + ud.buildSpeed)/ud.buildSpeed
	local extrastorage = data.extrastorage or 0
	local storageamount = ud.energyStorage + extrastorage
	data.metalIncome = (data.metalIncome or 0)
	data.energyIncome = (data.energyIncome or 0)
	spSetUnitRulesParam(unitID, "basebuildpower_mult", buildPowerMult, INLOS)
	spSetUnitRulesParam(unitID, "buildpower_mult", buildPowerMult, INLOS)
	spSetUnitRulesParam(unitID, "commander_storage_override", storageamount, INLOS)
	GG.SetupCommanderStorage(unitID)
	if data.metalIncome and GG.Overdrive then
		spSetUnitRulesParam(unitID, "comm_income_metal", data.metalIncome, INLOS)
		spSetUnitRulesParam(unitID, "comm_income_energy", data.energyIncome, INLOS)
		GG.Overdrive.AddUnitResourceGeneration(unitID, data.metalIncome, data.energyIncome, true)
	end
	
	if data.jumpreloadbonus then
		spSetUnitRulesParam(unitID, "comm_jumpreload_bonus", data.jumpreloadbonus, INLOS)
	end
	if data.jumprangebonus then
		spSetUnitRulesParam(unitID, "comm_jumprange_bonus", data.jumprangebonus, INLOS)
	end
	
	if data.healthBonus then
		local health, maxHealth = spGetUnitHealth(unitID)
		local newHealth = math.max(health + data.healthBonus, 1)
		local newMaxHealth = math.max(maxHealth + data.healthBonus, 1)
		spSetUnitHealth(unitID, newHealth)
		Spring.SetUnitMaxHealth(unitID, newMaxHealth)
		Spring.SetUnitRulesParam(unitID, "commander_healthbonus", healthBonus, INLOS)
	end
	
	if data.skinOverride then
		spSetUnitRulesParam(unitID, "comm_texture", data.skinOverride, INLOS)
	end
	
	if data.bannerOverhead then
		spSetUnitRulesParam(unitID, "comm_banner_overhead", images.overhead or "fakeunit", INLOS)
	end
	
	if data.drones or data.droneheavyslows then
		if data.drones then
			spSetUnitRulesParam(unitID, "carrier_count_drone", data.drones, INLOS)
		end
		if data.droneheavyslows then
			spSetUnitRulesParam(unitID, "carrier_count_droneheavyslow", data.droneheavyslows, INLOS)
		end
		if GG.Drones_InitializeDynamicCarrier then
			GG.Drones_InitializeDynamicCarrier(unitID)
		end
	end
	
	if data.autorepairRate then
		spSetUnitRulesParam(unitID, "comm_autorepair_rate", data.autorepairRate, INLOS)
		if GG.SetUnitIdleRegen then
			GG.SetUnitIdleRegen(unitID, 0, data.autorepairRate / 2)
		end
	end
	
	local _, maxHealth = spGetUnitHealth(unitID)
	local effectiveMass = (((totalCost/2) + (maxHealth/8))^0.6)*6.5
	spSetUnitRulesParam(unitID, "massOverride", effectiveMass, INLOS)
	-- Peaceful Wind --
	local detpack = data.detpacklv or 0
	spSetUnitRulesParam(unitID, "comm_deathexplosion", detpacktable[detpack], INLOS)
	
	ApplyWeaponData(unitID, data.weapon1, data.weapon2, data.shield, data.rangeMult, data.damageMult, chassis)
	
	-- Do this all the time as it will be needed almost always.
	GG.UpdateUnitAttributes(unitID)
	local env = Spring.UnitScript.GetScriptEnv(unitID) or {}
	CallAsUnitIfExists(unitID, env.OnMorphComplete) -- tell LUS we've upgraded apparently.
end

local function ApplyModuleEffectsFromUnitRulesParams(unitID)
	if not spGetUnitRulesParam(unitID, "jammingRangeOverride") then
		local onOffCmd = spFindUnitCmdDesc(unitID, CMD.ONOFF)
		if onOffCmd then
			spRemoveUnitCmdDesc(unitID, onOffCmd)
		end
	end
	
	local decloakDist = spGetUnitRulesParam(unitID, "comm_decloak_distance")
	if decloakDist then
		spSetUnitCloak(unitID, false, decloakDist)
	end
	
	if GG.Overdrive then
		local mInc = spGetUnitRulesParam(unitID, "comm_income_metal")
		local eInc = spGetUnitRulesParam(unitID, "comm_income_energy")
		GG.Overdrive.AddUnitResourceGeneration(unitID, mInc or 0, eInc or 0, true, true)
	end
	
	if spGetUnitRulesParam(unitID, "carrier_count_drone") or spGetUnitRulesParam(unitID, "carrier_count_droneheavyslow") then
		if GG.Drones_InitializeDynamicCarrier then
			GG.Drones_InitializeDynamicCarrier(unitID)
		end
	end
	
	local autoRegen = spGetUnitRulesParam(unitID, "comm_autorepair_rate")
	if autoRegen and GG.SetUnitIdleRegen then
		GG.SetUnitIdleRegen(unitID, 0, autoRegen / 2)
	end
	
	ApplyWeaponData(unitID, spGetUnitRulesParam(unitID, "comm_weapon_name_1"),
		spGetUnitRulesParam(unitID, "comm_weapon_name_2"),
		spGetUnitRulesParam(unitID, "comm_shield_name"))
	
	-- Do this all the time as it will be needed almost always.
	GG.UpdateUnitAttributes(unitID)
end

local function GetModuleEffectsData(moduleList, level, chassis)
	local moduleByDefID = upgradeUtilities.ModuleListToByDefID(moduleList)
	
	local moduleEffectData = {}
	for i = 1, #moduleList do
		local moduleDef = moduleDefs[moduleList[i]]
		if moduleDef.applicationFunction then
			moduleDef.applicationFunction(moduleByDefID, moduleEffectData)
		end
	end
	
	local levelFunction = chassisDefs[chassis or 1].levelDefs[math.min(chassisDefs[chassis or 1].maxNormalLevel, level or 1)].chassisApplicationFunction
	if levelFunction then
		levelFunction(moduleByDefID, moduleEffectData)
	end
	
	return moduleEffectData
end

local function AddAddons(moduleList, chassis)
	moduleList = moduleList or {}
	local addons = defaultaddons[chassis]
	for _, v in pairs(addons) do
		moduleList[#moduleList + 1] = moduleDefNames[v]
	end
	return moduleList
end

local function InitializeDynamicCommander(unitID, level, chassis, totalCost, name, baseUnitDefID, baseWreckID, baseHeapID, moduleList, moduleEffectData, images, profileID, staticLevel)
	-- This function sets the UnitRulesParams and updates the unit attributes after
	-- a commander has been created. This can either happen internally due to a request
	-- to spawn a commander or with rezz/construction/spawning.
	if level == 0 or staticLevel then
		moduleList = AddAddons(moduleList, chassis)
	end
	moduleEffectData = GetModuleEffectsData(moduleList, level, chassis)
	if level == 1 and not moduleEffectData.weapon1 then
		local default = GetCommanderChassisDefaultWeapon(chassis)
		moduleList[#moduleList + 1] = moduleDefNames[default]
		moduleEffectData.weapon1 = default
	end
	if level == 3 and not moduleEffectData.weapon2 then
		local default = GetCommanderChassisDefaultWeapon(chassis)
		moduleList[#moduleList + 1] = moduleDefNames[default]
		moduleEffectData.weapon2 = default
	end
	
	-- Start setting required unitRulesParams
	spSetUnitRulesParam(unitID, "comm_level",         level, INLOS)
	spSetUnitRulesParam(unitID, "comm_chassis",       chassis, INLOS)
	spSetUnitRulesParam(unitID, "comm_name",          name, INLOS)
	spSetUnitRulesParam(unitID, "comm_cost",          totalCost, INLOS)
	spSetUnitRulesParam(unitID, "comm_baseUnitDefID", baseUnitDefID, INLOS)
	spSetUnitRulesParam(unitID, "comm_baseWreckID",   baseWreckID, INLOS)
	spSetUnitRulesParam(unitID, "comm_baseHeapID",    baseHeapID, INLOS)
	spSetUnitRulesParam(unitID, "commander_storage_override", 500, INLOS)
	if profileID then
		spSetUnitRulesParam(unitID, "comm_profileID",     profileID, INLOS)
	end
	
	if staticLevel then -- unmorphable
		spSetUnitRulesParam(unitID, "comm_staticLevel",   staticLevel, INLOS)
	end
	
	Spring.SetUnitCosts(unitID, {
		buildTime = totalCost,
		metalCost = totalCost,
		energyCost = totalCost
	})
	
	-- Set module unitRulesParams
	-- Decorations are kept seperate from other module types.
	-- basic_weapon, adv_weapon and module all count as modules.
	local counts = {module = 0, decoration = 0}
	for i = 1, #moduleList do
		local moduleDefID = moduleList[i]
		SetUnitRulesModule(unitID, counts, moduleDefID)
	end
	SetUnitRulesModuleCounts(unitID, counts)
	ApplyModuleEffects(unitID, moduleEffectData, totalCost, images or {}, chassis)
	--GG.SetupCommanderStorage(unitID)
	
	if staticLevel then
		-- Newly created commander, set to full health
		local _, maxHealth = spGetUnitHealth(unitID)
		spSetUnitHealth(unitID, maxHealth)
	end
end

local function Upgrades_CreateUpgradedUnit(defName, x, y, z, face, unitTeam, isBeingBuilt, upgradeDef)
	-- Calculate Module effects
	local level = upgradeDef.level
	local chassis = upgradeDef.chassis
	local modulelist = upgradeDef.moduleList
	local moduleEffectData = GetModuleEffectsData(modulelist, level, chassis)
	-- Create Unit, set appropriate global data first
	-- These variables are set such that other gadgets can notice the effect
	-- within UnitCreated.
	if moduleEffectData.shield then
		unitCreatedShield, unitCreatedShieldNum = upgradeUtilities.GetUnitDefShield(defName, moduleEffectData.shield)
	end
	
	if moduleEffectData.personalCloak then
		unitCreatedCloak = true
	end
	
	if moduleEffectData.radarJammingRange then
		unitCreatedJammingRange = COMMANDER_JAMMING_COST
	end
	
	if moduleEffectData.areaCloak then
		unitCreatedCloakShield = true
	end
	
	unitCreatedWeaponNums = {}
	if moduleEffectData.weapon1 then
		unitCreatedWeaponNums[moduleEffectData.weapon1] = 1
	end
	if moduleEffectData.weapon2 then
		unitCreatedWeaponNums[moduleEffectData.weapon2] = 2
	end
	if moduleEffectData.shield then
		unitCreatedWeaponNums[moduleEffectData.shield] = 3
	end
	
	interallyCreatedUnit = true
	--moduleEffectData.extrastorage = 0
	internalCreationUpgradeDef = upgradeDef
	internalCreationModuleEffectData = moduleEffectData
	
	local unitID = Spring.CreateUnit(defName, x, y, z, face, unitTeam, isBeingBuilt)
	if moduleEffectData.wantsfireatradar then
		GG.AddUnitRadarTargeting(unitID)
	end
	--GG.SetupCommanderStorage(unitID)
	-- Unset the variables which need to be present at unit creation
	interallyCreatedUnit = false
	internalCreationUpgradeDef = nil
	internalCreationModuleEffectData = nil
	
	unitCreatedShield = nil
	unitCreatedShieldNum = nil
	unitCreatedShield = nil
	unitCreatedCloak = nil
	unitCreatedJammingRange = nil
	unitCreatedCloakShield = nil
	unitCreatedWeaponNums = nil
	
	if not unitID then
		return false
	end
	
	return unitID
end

local function CreateStaticCommander(dyncommID, commProfileInfo, moduleList, moduleCost, x, y, z, facing, teamID, targetLevel)
	for i = 0, targetLevel do
		local levelModules = commProfileInfo.modules[i]
		if levelModules then
			for j = 1, #levelModules do
				local moduleID = moduleDefNames[levelModules[j]]
				if moduleID and moduleDefs[moduleID] then
					moduleList[#moduleList + 1] = moduleID
					moduleCost = moduleCost + moduleDefs[moduleID].cost
				end
			end
		end
	end
	
	local moduleByDefID = upgradeUtilities.ModuleListToByDefID(moduleList)
	
	local chassisDefID = chassisDefNames[commProfileInfo.chassis]
	local chassisData = chassisDefs[chassisDefID]
	local chassisLevel = math.min(chassisData.maxNormalLevel, targetLevel)
	local unitDefID = chassisData.levelDefs[chassisLevel].morphUnitDefFunction(moduleByDefID)
	
	local upgradeDef = {
		level = targetLevel,
		staticLevel = targetLevel,
		chassis = chassisDefID,
		totalCost = UnitDefs[chassisDefID].metalCost + moduleCost,
		name = commProfileInfo.name,
		moduleList = moduleList,
		baseUnitDefID = unitDefID,
		baseWreckID = commProfileInfo.baseWreckID or chassisData.baseWreckID,
		baseHeapID = commProfileInfo.baseHeapID or chassisData.baseHeapID,
		images = commProfileInfo.images,
		profileID = dyncommID,
	}
	
	local unitID = Upgrades_CreateUpgradedUnit(unitDefID, x, y, z, facing, teamID, false, upgradeDef)
	
	return unitID
end

local function Upgrades_CreateStarterDyncomm(dyncommID, x, y, z, facing, teamID, staticLevel)
	--Spring.Echo("Creating starter dyncomm " .. dyncommID)
	local commProfileInfo = GG.ModularCommAPI.GetCommProfileInfo(dyncommID)
	local chassisDefID = chassisDefNames[commProfileInfo.chassis]
	if not chassisDefID then
		Spring.Echo("Incorrect dynamic comm chassis", commProfileInfo.chassis)
		return false
	end
	
	local chassisData = chassisDefs[chassisDefID]
	if chassisData.notSelectable and not staticLevel then
		Spring.Echo("Chassis not selectable", commProfileInfo.chassis)
		return false
	end
	
	local baseUnitDefID = commProfileInfo.baseUnitDefID or chassisData.baseUnitDef
	
	local moduleList = {moduleDefNames.econ}
	local addons = defaultaddons[chassisDefID]
	--for _, v in pairs(addons) do
		--moduleList[#moduleList + 1] = moduleDefNames[v]
	--end
	local moduleCost = 0
	for i = 1, #moduleList do
		moduleCost = moduleCost + moduleDefs[moduleList[i]].cost
	end
	
	if commProfileInfo.decorations then
		for i = 1, #commProfileInfo.decorations do
			local decName = commProfileInfo.decorations[i]
			if moduleDefNames[decName] then
				moduleList[#moduleList + 1] = moduleDefNames[decName]
			end
		end
	end
	
	if staticLevel then
		return CreateStaticCommander(dyncommID, commProfileInfo, moduleList, moduleCost, x, y, z, facing, teamID, staticLevel)
	end
	
	local upgradeDef = {
		level = 0,
		chassis = chassisDefID,
		totalCost = UnitDefs[baseUnitDefID].metalCost + moduleCost,
		name = commProfileInfo.name,
		moduleList = moduleList,
		baseUnitDefID = baseUnitDefID,
		baseWreckID = commProfileInfo.baseWreckID or chassisData.baseWreckID,
		baseHeapID = commProfileInfo.baseHeapID or chassisData.baseHeapID,
		images = commProfileInfo.images,
		profileID = dyncommID
	}
	
	local unitID = Upgrades_CreateUpgradedUnit(baseUnitDefID, x, y, z, facing, teamID, false, upgradeDef)
	
	return unitID
end

local function GetRandomName()
	return names[math.random(1, #names)] or "Error In L656"
end

local function GetRandomZombieName()
	if zombies then
		return zombienames[math.random(1, #zombienames)] or "Error In L661"
	else
		return GetRandomName()
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if spGetUnitRulesParam(unitID, "comm_level") then
		return
	end
	
	if interallyCreatedUnit then
		InitializeDynamicCommander(
			unitID,
			internalCreationUpgradeDef.level,
			internalCreationUpgradeDef.chassis,
			internalCreationUpgradeDef.totalCost,
			internalCreationUpgradeDef.name,
			internalCreationUpgradeDef.baseUnitDefID,
			internalCreationUpgradeDef.baseWreckID,
			internalCreationUpgradeDef.baseHeapID,
			internalCreationUpgradeDef.moduleList,
			internalCreationModuleEffectData,
			internalCreationUpgradeDef.images,
			internalCreationUpgradeDef.profileID,
			internalCreationUpgradeDef.staticLevel
		)
		return
	end
	
	local profileID = GG.ModularCommAPI.GetProfileIDByBaseDefID(unitDefID)
	if profileID then
		local commProfileInfo = GG.ModularCommAPI.GetCommProfileInfo(profileID)
		
		-- Add decorations
		local moduleList = {}
		if commProfileInfo.decorations then
			for i = 1, #commProfileInfo.decorations do
				local decName = commProfileInfo.decorations[i]
				if moduleDefNames[decName] then
					moduleList[#moduleList + 1] = moduleDefNames[decName]
				end
			end
		end
		
		InitializeDynamicCommander(
			unitID,
			0,
			chassisDefNames[commProfileInfo.chassis],
			UnitDefs[unitDefID].metalCost,
			commProfileInfo.name,
			unitDefID,
			commProfileInfo.baseWreckID,
			commProfileInfo.baseHeapID,
			moduleList,
			false,
			commProfileInfo.images,
			profileID
		)
		return
	end
	
	if chassisDefByBaseDef[unitDefID] then
		local chassisData = chassisDefs[chassisDefByBaseDef[unitDefID]]
		local name
		if unitTeam ~= Spring.GetGaiaTeamID() then
			name = GetRandomName()
		else
			name = GetRandomZombieName()
		end
		InitializeDynamicCommander(
			unitID,
			0,
			chassisDefByBaseDef[unitDefID],
			UnitDefs[unitDefID].metalCost,
			name,
			unitDefID,
			chassisData.baseWreckID,
			chassisData.baseHeapID,
			{},
			{}
		)
		return
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function Upgrades_GetValidAndMorphAttributes(unitID, params)
	-- Initial data and easy sanity tests
	if #params <= 4 then
		return false
	end
	
	local pLevel = params[1]
	local pChassis = params[2]
	local pAlreadyCount = params[3]
	local pNewCount = params[4]
	
	if #params ~= 4 + pAlreadyCount + pNewCount then
		return false
	end
	
	if spGetUnitRulesParam(unitID, "comm_staticLevel") then
		return false
	end
	
	-- Make sure level and chassis match.
	local level = spGetUnitRulesParam(unitID, "comm_level")
	local chassis = spGetUnitRulesParam(unitID, "comm_chassis")
	if level ~= pLevel or chassis ~= pChassis then
		return false
	end
	
	local newLevel = level + 1
	local newLevelBounded = math.min(chassisDefs[chassis].maxNormalLevel, level + 1)
	
	-- If unbounded level is disallowed then the comm might be invalid
	if LEVEL_BOUND and newLevel > LEVEL_BOUND then
		return false
	end

	-- Determine what the command thinks the unit already owns
	local index = 5
	local pAlreadyOwned = {}
	for i = 1, pAlreadyCount do
		pAlreadyOwned[i] = params[index]
		index = index + 1
	end
	
	-- Find the modules which are already owned
	local alreadyOwned = {}
	local fullModuleList = {}
	
	local moduleCount = spGetUnitRulesParam(unitID, "comm_module_count")
	for i = 1, moduleCount do
		local module = spGetUnitRulesParam(unitID, "comm_module_" .. i)
		alreadyOwned[#alreadyOwned + 1] = module
		fullModuleList[#fullModuleList + 1] = module
	end
	
	-- Strictly speaking sort is not required. It is for leniency
	table.sort(alreadyOwned)
	table.sort(pAlreadyOwned)
	
	-- alreadyOwned does not contain decoration modules so pAlreadyOwned
	-- should not contain decoration modules. The check fails if pAlreadyOwned
	-- contains decorations.
	if not upgradeUtilities.ModuleSetsAreIdentical(alreadyOwned, pAlreadyOwned) then
		return false
	end
	
	-- Check the validity of the new module set
	local pNewModules = {}
	for i = 1, pNewCount do
		pNewModules[#pNewModules + 1] = params[index]
		index = index + 1
	end
	
	-- Finish the full modules list
	-- Empty module slots do not make it into this list
	for i = 1, #pNewModules  do
		if not moduleDefs[pNewModules[i]].emptyModule then
			fullModuleList[#fullModuleList + 1] = pNewModules[i]
		end
	end
	
	local modulesByDefID = upgradeUtilities.ModuleListToByDefID(fullModuleList)
	
	-- Determine Cost and check that the new modules are valid.
	local levelDefs = chassisDefs[chassis].levelDefs[newLevelBounded]
	local slotDefs = levelDefs.upgradeSlots
	local cost = 0
	
	for i = 1, #pNewModules do
		local moduleDefID = pNewModules[i]
		if upgradeUtilities.ModuleIsValid(newLevelBounded, chassis, slotDefs[i].slotAllows, moduleDefID, modulesByDefID) then
			cost = cost + moduleDefs[moduleDefID].cost
		else
			return false
		end
	end
	
	-- Add Decorations, they are modules but not part of the previous checks.
	-- Assumed to be valid here because they cannot be added by this function.
	local decCount = spGetUnitRulesParam(unitID, "comm_decoration_count")
	for i = 1, decCount do
		local decoration = spGetUnitRulesParam(unitID, "comm_decoration_" .. i)
		fullModuleList[#fullModuleList + 1] = decoration
	end
	
	local images = {}
	local bannerOverhead = spGetUnitRulesParam(unitID, "comm_banner_overhead")
	if bannerOverhead then
		images.overhead = bannerOverhead
	end
	
	-- The command is now known to be valid. Construct the morphDef.
	
	if newLevel ~= newLevelBounded then
		cost = cost + chassisDefs[chassis].extraLevelCostFunction(newLevel)
	else
		cost = cost + levelDefs.morphBaseCost
	end
	local targetUnitDefID = levelDefs.morphUnitDefFunction(modulesByDefID)
	
	local morphTime = cost/levelDefs.morphBuildPower
	local increment = (1 / (30 * morphTime))
	
	local morphDef = {
		upgradeDef = {
			name = spGetUnitRulesParam(unitID, "comm_name"),
			totalCost = cost + Spring.Utilities.GetUnitCost(unitID),
			level = newLevel,
			chassis = chassis,
			moduleList = fullModuleList,
			baseUnitDefID = spGetUnitRulesParam(unitID, "comm_baseUnitDefID"),
			baseWreckID = spGetUnitRulesParam(unitID, "comm_baseWreckID"),
			baseHeapID = spGetUnitRulesParam(unitID, "comm_baseHeapID"),
			images = images,
			profileID = spGetUnitRulesParam(unitID, "comm_profileID"),
		},
		combatMorph = true,
		metal = cost,
		time = morphTime,
		into = targetUnitDefID,
		increment = increment,
		stopCmd = CMD_UPGRADE_STOP,
		resTable = {
			m = (increment * cost),
			e = (increment * cost)
		},
		cmd = nil, -- for completeness
		facing = nil,
	}
	
	return true, targetUnitDefID, morphDef
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function GG.Upgrades_UnitShieldDef(unitID)
	local shieldDefID = (unitCreatedShield or spGetUnitRulesParam(unitID, "comm_shield_id")) or false
	local shieldNum = (unitCreatedShieldNum or spGetUnitRulesParam(unitID, "comm_shield_num")) or false
	local shieldDef = false
	if shieldDefID and WeaponDefs[shieldDefID].shieldRadius > 200 then
		shieldDef = commAreaShieldDefID
	end

	return shieldDefID, shieldNum, shieldDef
end

function GG.Upgrades_UnitCanCloak(unitID)
	return unitCreatedCloak or spGetUnitRulesParam(unitID, "comm_personal_cloak")
end

function GG.Upgrades_UnitJammerEnergyDrain(unitID)
	return unitCreatedJammingRange or spGetUnitRulesParam(unitID, "comm_jamming_cost")
end

function GG.Upgrades_UnitCloakShieldDef(unitID)
	return (unitCreatedCloakShield or spGetUnitRulesParam(unitID, "comm_area_cloak")) and commanderCloakShieldDef
end

function GG.Upgrades_WeaponNumMap(num)
	if unitCreatedWeaponNums then
		return unitCreatedWeaponNums[num]
	end
	return false
end

-- GG.Upgrades_GetUnitCustomShader is up in unsynced

function gadget:Initialize()
	GG.Upgrades_CreateUpgradedUnit         = Upgrades_CreateUpgradedUnit
	GG.Upgrades_CreateStarterDyncomm       = Upgrades_CreateStarterDyncomm
	GG.Upgrades_GetValidAndMorphAttributes = Upgrades_GetValidAndMorphAttributes
	
	-- load active units
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = spGetUnitDefID(unitID)
		local teamID = Spring.GetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Save/Load

function gadget:Load(zip)
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		if spGetUnitRulesParam(unitID, "comm_level") then
			ApplyModuleEffectsFromUnitRulesParams(unitID)
		end
	end
end
