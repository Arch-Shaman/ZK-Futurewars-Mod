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
local spSetUnitMass = Spring.SetUnitMass
local spRemoveUnitCmdDesc = Spring.RemoveUnitCmdDesc
local spSetUnitStealth = Spring.SetUnitStealth
local spGetUnitHealth = Spring.GetUnitHealth
local CMD_UPGRADE_STOP = Spring.Utilities.CMD.UPGRADE_STOP
local zombies = false

local defaultProfiles = {
	[1] = "dyntrainer_strike",
	[2] = "dyntrainer_recon",
	[3] = "dyntrainer_support",
	[4] = "dyntrainer_assault",
	[5] = "dyntrainer_riot",
	[6] = "dyntrainer_support", -- Probably bad!
	[7] = "dyntrainer_riot",
}

local freeWreckModule = true

do
	local modoptions = Spring.GetModOptions()
	if tonumber(modoptions.zombies) == 1 then
		zombies = true
	end
	if tonumber(modoptions.requirewreckmodule) or 0 == 1 then
		freeWreckModule = false
	end
end

local recentlyResurrected = {} -- do on the next frame.

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
	-- other, volume 2 --
	"Legendary GhostFenixx", -- GhostFenixx collected all the versions!
	"I didn't die, it was selfd!",
	"Traitor Coffee", -- Shaman Meme
	"Surprise Base Trader",
	"Bomb disguised as a Comm",
	"Im not Oppressive, just uncounterable!",
	"Mudosaka's Murder Machine",
	"Buzzing Bees, Deadly Drones!",
	"Explosive Enforcer",
	-- other, dlc edition
	"Blame it on Skill Issue",
	"Liberator target",
	"Kill me and u r n00b",
	"Warning: Contents may violently explode",
	"To unlock, complete the season pass!",
	"Kalsarikannit moment",
	"Captain obvious",
	"Major stupidity",
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
	"rikkaruohomyrkky", -- User: Shaman
	"Harhautus", -- User:Shaman
	"Boi 1", -- User: Sprang
	"Boi 2", -- User: Sprang
	"Default boi", -- User: Ehal45
	"Legion", -- User: IIOuroborosII
	"CombatEngineer", -- User: SparkezelPL
	"Combat Necromancer", -- User: Someone64
	"Hit and Run", -- User: Someone64
	"Did he just walk up?", -- User: Jenbak
	"Raiden", -- User: Shyrka
	"Duke Nuke Them", -- User: MidnightTelevision
	"Nuclear Warhead", -- User: Myopic
	"Hayasaka", -- User: Myopic
	"Com Attack", -- User: wptr_007
	"Superbuild", -- User: Saber
	"smashy smashy robots", -- User: rifqifajarzain, but Shaman meme!
	"Rifqi", -- User: rifqifajarzain
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

if freeWreckModule then
	for i = 1, #defaultaddons do
		defaultaddons[i][#defaultaddons[i] + 1] = "module_resmodule"
	end
end

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

local function compare(a, b)
	return (a and a[1] < b[1]) or false
end

local function OrganizeModuleListByEffectOrder(moduleList)
	local newList = {}
	local ret = {}
	local moduleNames
	for i = 1, #moduleList do
		--Spring.Echo(moduleList[i])
		if moduleList[i] ~= nil then
			newList[#newList + 1] = {moduleDefs[moduleList[i]].effectPriority or 5, moduleList[i]}
		end
	end
	--Spring.Echo("New list size: " .. #newList)
	table.sort(newList, compare)
	for i = 1, #newList do
		ret[i] = newList[i][2]
	end
	return ret
end

local function SetUnitRulesModule(unitID, counts, moduleDefID)
	local slotType = moduleSlotTypeMap[moduleDefs[moduleDefID].slotType]
	counts[slotType] = counts[slotType] + 1
	spSetUnitRulesParam(unitID, "comm_" .. slotType .. "_" .. counts[slotType], moduleDefID, INLOS)
end

local function SetModuleCounts(unitID) -- used by some dynamic comm LUS.
	local modules = {}
	local count = spGetUnitRulesParam(unitID, "comm_module_count")
	if count > 0 then
		for i = 1, count do
			local moduleID = Spring.GetUnitRulesParam(unitID, "comm_module_" .. i)
			modules[moduleID] = (modules[moduleID] or 0) + 1
		end
		for moduleID, moduleCount in pairs(modules) do
			local name = moduleDefs[moduleID].name
			spSetUnitRulesParam(unitID, name .. "_count", moduleCount, INLOS)
		end
	end
end
	

local function SetUnitRulesModuleCounts(unitID, counts)
	for name, value in pairs(counts) do
		spSetUnitRulesParam(unitID, "comm_" .. name .. "_count", value, INLOS)
	end
	SetModuleCounts(unitID)
end

local function ApplyWeaponData(unitID, weapon1, weapon2, shield, rangeMult, damageMult, chassis, extraWeaponInfo)
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
	
	local env = Spring.UnitScript.GetScriptEnv(unitID) or {}
	CallAsUnitIfExists(unitID, env.dyncomm.UpdateWeapons, weapon1, weapon2, shield, rangeMult, damageMult, extraWeaponInfo)
end

local function StartReconPulse(unitID)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if env then
		Spring.UnitScript.CallAsUnit(unitID, env.StartReconPulse)
	end
end

local function ApplyModuleEffects(unitID, data, totalCost, images, chassis)
	local ud = UnitDefs[spGetUnitDefID(unitID)]
	spSetUnitRulesParam(unitID, "resurrectableCommander", 1, INLOS)
	-- Update ApplyModuleEffectsFromUnitRulesParams if any non-unitRulesParams changes are made.
	if data.speedMod or data.speedMalus then
		local speedMalus = ((data.speedMalus or 0) * (data.malusMult or 1))
		local speedBonus = data.speedMod or 0
		local finalSpeed = speedBonus + ud.speed - speedMalus
		local speedMult = finalSpeed/ud.speed
		spSetUnitRulesParam(unitID, "upgradesSpeedMult", speedMult, INLOS)
	end
	if data.reconPulse then
		spSetUnitRulesParam(unitID, "commander_reconpulse", 1, INLOS)
		StartReconPulse(unitID)
	end
	if data.alwaysDropWreck then
		spSetUnitRulesParam(unitID, "commander_alwaysdropwreck", 1, INLOS)
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
	if data.battery then
		local weaponname1 = data.weapon1
		local weaponname2 = data.weapon2
		local efficiency = data.batteryefficiency or 1
		local chargeRate = data.batteryrechargerate or 10
		local chargeMax = data.batterymax or 300
		local wep1 = WeaponDefs[unitWeaponNames[weaponname1].weaponDefID]
		local wep2 = weaponname2 and WeaponDefs[unitWeaponNames[weaponname2].weaponDefID] or nil
		local morphedFrom = Spring.GetUnitRulesParam(unitID, "wasMorphedTo")
		local costs = {}
		local checks = {}
		costs[1] = (tonumber(wep1.customParams.batterydrain) or 0) * efficiency
		checks[1] = math.ceil(costs[1] * 1.1)
		if wep2 then
			costs[2] = (tonumber(wep2.customParams.batterydrain) or 0) * efficiency
			checks[2] = math.ceil(costs[2] * 1.1)
		end
		if morphedFrom then
			local charge = Spring.GetUnitRulesParam(morphedFrom, "battery") or 0.75 * chargeMax
			if GG.BatteryManagement.IsUnitManaged(morphedFrom) then
				GG.BatteryManagement.SetUpMorphedUnit(unitID, morphedFrom)
				GG.BatteryManagement.SetBatteryStats(unitID, charge, chargeMax, chargeRate, costs, checks)
			else
				GG.BatteryManagement.SetBatteryStats(unitID, charge, chargeMax, chargeRate, costs, checks)
			end
		end
	end
	if data.aimbonus then
		spSetUnitRulesParam(unitID, "comm_aimbonus", data.aimbonus, INLOS)
	end
	if data.tolerancebonus then
		spSetUnitRulesParam(unitID, "comm_tolerancebonus", data.tolerancebonus, INLOS)
	end
	if data.damageMult and data.damageMult < 0.1 then
		data.damageMult = 0.1
	end
	if data.fireproof then
		spSetUnitRulesParam(unitID, "fireproof", 1, INLOS)
		GG.MakeUnitFireproof(unitID)
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
	if data.extradroneslots then
		spSetUnitRulesParam(unitID, "comm_extra_drones", data.extradroneslots, INLOS)
	end
	if data.dronebuildmod then
		spSetUnitRulesParam(unitID, "comm_drone_buildrate", data.dronebuildmod, INLOS)
	end
	if data.dronereloadtime then
		spSetUnitRulesParam(unitID, "comm_drone_rebuildrate", data.dronereloadtime, INLOS)
	end
	if data.dronerange then
		spSetUnitRulesParam(unitID, "comm_drone_range", data.dronerange, INLOS)
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
		local newMaxHealth = math.max(maxHealth + data.healthBonus, 100)
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
	
	if data.drones or data.droneheavyslows or data.dronecon or data.droneassault or data.dronesplus or data.droneheavyslowsplus or data.droneconplus or data.droneassaultplus then
		if data.drones then
			spSetUnitRulesParam(unitID, "carrier_count_drone", data.drones, INLOS)
		end
		if data.droneheavyslows then
			spSetUnitRulesParam(unitID, "carrier_count_droneheavyslow", data.droneheavyslows, INLOS)
		end
		if data.dronecon then
			spSetUnitRulesParam(unitID, "carrier_count_dronecon", data.dronecon, INLOS)
		end
		if data.droneassault then
			spSetUnitRulesParam(unitID, "carrier_count_droneassault", data.droneassault, INLOS)
		end
		if data.dronesplus then
			spSetUnitRulesParam(unitID, "carrier_count_droneplus", data.dronesplus, INLOS)
		end
		if data.droneheavyslowsplus then
			spSetUnitRulesParam(unitID, "carrier_count_droneheavyslowplus", data.droneheavyslowsplus, INLOS)
		end
		if data.droneconplus then
			spSetUnitRulesParam(unitID, "carrier_count_droneconplus", data.droneconplus, INLOS)
		end
		if data.droneassaultplus then
			spSetUnitRulesParam(unitID, "carrier_count_droneassaultplus", data.droneassaultplus, INLOS)
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
	spSetUnitMass(unitID, effectiveMass)
	-- Peaceful Wind --
	local detpack = data.detpacklv or 0
	spSetUnitRulesParam(unitID, "comm_deathexplosion", detpacktable[detpack], INLOS)
	local extraWeaponInfo = {
		[1] = {
			damageBoost = data.damageBooster1 or 0,
			burstOverride = data.burstOverride1,
			burstRateOverride = data.burstRateOverride1,
			accuracyOverride = data.accuracyOverride1,
			accuracyBonus = (data.accuracyMult or 1) + (data.accuracyBonus1 or 0),
			reloadBonus = (data.reloadBonus or 0) + (data.reloadBonus1 or 0),
			reloadOverride = data.reloadOverride1,
			projectileOverride = data.projectileOverride1,
			projectileBonus = data.projectileBonus1 or 0,
			projectileSpeedBonus = data.projectileSpeedBonus1 or 1,
			sprayAngleOverride = data.sprayAngleOverride1,
			sprayAngleBonus = data.sprayAngleBonus1,
			rangeOverride = data.rangeoverride1,
		},
		[2] = {
			damageBoost = data.damageBooster2 or 0,
			burstOverride = data.burstOverride2,
			burstRateOverride = data.burstRateOverride2,
			accuracyOverride = data.accuracyOverride2,
			accuracyBonus = (data.accuracyMult or 1) + (data.accuracyBonus2 or 0),
			reloadBonus = (data.reloadBonus or 0) + (data.reloadBonus2 or 0),
			reloadOverride = data.reloadOverride2,
			projectileOverride = data.projectileOverride2,
			projectileBonus = data.projectileBonus2 or 0,
			projectileSpeedBonus = data.projectileSpeedBonus2 or 1,
			sprayAngleOverride = data.sprayAngleOverride2,
			sprayAngleBonus = data.sprayAngleBonus2,
			rangeOverride = data.rangeoverride2,
		},
	}
	ApplyWeaponData(unitID, data.weapon1, data.weapon2, data.shield, data.rangeMult, data.damageMult, chassis, extraWeaponInfo)
	
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
	moduleList = OrganizeModuleListByEffectOrder(moduleList)
	local moduleEffectData = {}
	for i = 1, #moduleList do
		local moduleDef = moduleDefs[moduleList[i]]
		if moduleDef.applicationFunction then
			moduleDef.applicationFunction(moduleByDefID, moduleEffectData)
		end
	end
	
	-- Apply the magical free benefits of level-up
	-- Note that level is here 1 less than the value that is shown to the player
	if chassis ~= nil and level ~= nil then    -- paranoid variable checking, similar to the original code
		local levelFunction = chassisDefs[chassis].chassisApplicationFunction
		if levelFunction then
			levelFunction(level, moduleByDefID, moduleEffectData)
		end
	end
	
	return moduleEffectData
end

local function IsModuleUnique(moduleList, moduleName)
	local id = moduleDefNames[moduleName]
	local ret = true
	if #moduleList == 0 then
		return true
	end
	for i = 1, #moduleList do
		if moduleList[i] == id then
			ret = false
			break
		end
	end
	return ret
end

local function AddAddons(moduleList, chassis)
	moduleList = moduleList or {}
	local addons = defaultaddons[chassis]
	for _, v in pairs(addons) do
		if IsModuleUnique(moduleList, v) then
			moduleList[#moduleList + 1] = moduleDefNames[v]
		end
	end
	return moduleList
end

local function InitializeDynamicCommander(unitID, level, chassis, totalCost, name, baseUnitDefID, baseWreckID, baseHeapID, moduleList, moduleEffectData, images, profileID, staticLevel)
	-- This function sets the UnitRulesParams and updates the unit attributes after
	-- a commander has been created. This can either happen internally due to a request
	-- to spawn a commander or with rezz/construction/spawning.
	if (level == 0 or staticLevel) then
		moduleList = AddAddons(moduleList, chassis)
	end
	moduleEffectData = GetModuleEffectsData(moduleList, level, chassis)
	if moduleEffectData.personalCloak then
		unitCreatedCloak = true
	end
	if moduleEffectData.radarJammingRange then
		unitCreatedJammingRange = COMMANDER_JAMMING_COST
	end
	
	if moduleEffectData.areaCloak then
		unitCreatedCloakShield = true
	end
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
	else -- we need the default profileIDs.
		profileID = defaultProfiles[chassis]
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
	if not unitID then
		Spring.Echo("game_message: [unit_commander_upgrade] Warning: Upgraded unit NOT created successfully.\nTHIS MAY RESULT IN BUGS.\nDefname, teamID ", defName, unitTeam)
		Spring.MarkerAddPoint(x, y, z, "This unit did not morph correctly!", true)
		return false
	end
	
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

local function TransferParamFromFeature(featureID, unitID, param)
	spSetUnitRulesParam(unitID, param, Spring.GetFeatureRulesParam(featureID, param), INLOS)
end

local function GetCommanderInfoFromWreck(featureID, unitID)
	local modules = {}
	local count = Spring.GetFeatureRulesParam(featureID, "comm_module_count")
	local name = Spring.GetFeatureRulesParam(featureID, "comm_name")
	local totalCost = Spring.GetFeatureRulesParam(featureID, "comm_cost")
	local level = Spring.GetFeatureRulesParam(featureID, "comm_level")
	local profileID = Spring.GetFeatureRulesParam(featureID, "comm_profileID")
	local baseWreckID = Spring.GetFeatureRulesParam(featureID, "comm_baseWreckID")
	local baseHeapID = Spring.GetFeatureRulesParam(featureID, "comm_baseHeapID")
	local chassisID = Spring.GetFeatureRulesParam(featureID, "comm_chassis")
	local overheadBanner = Spring.GetFeatureRulesParam(featureID, "comm_banner_overhead")
	local decorationCount = Spring.GetFeatureRulesParam(featureID, "comm_decoration_count") or 0
	TransferParamFromFeature(featureID, unitID, "comm_decoration_count")
	--Spring.Echo("Count: " .. decorationCount)
	if decorationCount > 0 then
		for i = 1, decorationCount do
			TransferParamFromFeature(featureID, unitID, "comm_decoration_" .. i)
		end
	end
	local skin = Spring.GetFeatureRulesParam(featureID, "comm_texture") 
	TransferParamFromFeature(featureID, unitID, "comm_banner_overhead")
	if chassisID == 1 then
		spSetUnitRulesParam(unitID, "comm_personal_cloak", 1, INLOS)
	end
	--Spring.Echo("Module count: " .. tostring(count))
	for i = 1, count do
		modules[i] = Spring.GetFeatureRulesParam(featureID, "comm_module_" .. i)
	end
	if overheadBanner ~= nil then
		modules[#modules + 1] = moduleDefNames["banner_overhead"]
	end
	if skin ~= nil then
		modules[#modules + 1] = moduleDefNames["skin_" .. skin]
	end
	-- do some transfer --
	TransferParamFromFeature(featureID, unitID, "commander_owner")
	TransferParamFromFeature(featureID, unitID, "comm_personal_cloak")
	TransferParamFromFeature(featureID, unitID, "comm_jammed")
	TransferParamFromFeature(featureID, unitID, "comm_shield_num")
	TransferParamFromFeature(featureID, unitID, "comm_texture")
	--
	--Spring.Echo("Got:" .. totalCost, level, name, baseWreckID, baseHeapID, profileID, chassisID)
	return modules, totalCost, level, name, baseWreckID, baseHeapID, profileID, chassisID
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	local isCommander = UnitDefs[unitDefID].customParams.commtype or UnitDefs[unitDefID].customParams.level or UnitDefs[unitDefID].customParams.dynamic_comm
	if not isCommander then -- filter out the normal units
		return
	end
	if spGetUnitRulesParam(unitID, "comm_level") then
		return
	end
	
	if builderID then
		local cmd = Spring.GetUnitCommands(builderID, 1) or {}
		if cmd[1] then
			cmd = cmd[1]
			local cmdID = cmd.id
			if cmdID == CMD.RESURRECT then
				--Spring.Echo("Unit was resurrected!")
				--for k, v in pairs(cmd.params) do
					--Spring.Echo(k .. ": " .. tostring(v))
				--end
				local featureID = cmd.params[1] - Game.maxUnits
				--Spring.Echo("FeatureID", featureID)
				local modules, totalCost, level, name, baseWreckID, baseHeapID, profileID, chassisID = GetCommanderInfoFromWreck(featureID, unitID)
				local profileID = profileID or GG.ModularCommAPI.GetProfileIDByBaseDefID(unitDefID)
				local commProfileInfo = GG.ModularCommAPI.GetCommProfileInfo(profileID)
				local moduleEffects = GetModuleEffectsData(modules, level, chassisID)
				if commProfileInfo then
					InitializeDynamicCommander(
						unitID,
						level,
						chassisID,
						totalCost,
						name,
						unitDefID,
						baseWreckID,
						baseHeapID,
						modules,
						moduleEffects,
						commProfileInfo.images,
						profileID
					)
				else
					InitializeDynamicCommander(
						unitID,
						level,
						chassisID,
						totalCost,
						name,
						unitDefID,
						baseWreckID,
						baseHeapID,
						modules,
						moduleEffects,
						{},
						profileID
					)
				end
				ApplyModuleEffectsFromUnitRulesParams(unitID)
				GG.ReinitCloak(unitID, unitDefID)
				return
			end
		end
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
			GG.ModularCommAPI.GetProfileIDByBaseDefID(unitDefID) or {}
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
	
	-- Increase level, and bound it by the available config
	-- Note that level is 1 less than the player-visible value
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
