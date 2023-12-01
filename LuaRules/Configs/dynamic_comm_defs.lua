-- mission editor compatibility
Spring.GetModOptions = Spring.GetModOptions or function() return {} end

local skinDefs
local SKIN_FILE = "LuaRules/Configs/dynamic_comm_skins.lua"
if VFS.FileExists(SKIN_FILE) then
	skinDefs = VFS.Include(SKIN_FILE)
else
	skinDefs = {}
end

local moduleDefNames = {}

local LEVEL_BOUND = math.floor(tonumber(Spring.GetModOptions().max_com_level or 0))
if LEVEL_BOUND <= 0 then
	LEVEL_BOUND = nil -- unlimited
else
	LEVEL_BOUND = LEVEL_BOUND - 1 -- UI counts from 1 but internals count from 0
end

local COST_MULT = 1
local HP_MULT = 1
local allowCommEco = false
local disabledModules = {}
local commwars = false

if (Spring.GetModOptions) then
	local modOptions = Spring.GetModOptions()
    if modOptions then
        if modOptions.hpmult and modOptions.hpmult ~= 1 then
            HP_MULT = modOptions.hpmult
        end
		allowCommEco = (modOptions.commeco or 0) == 1
		commwars = modOptions.commwars or "0" == "1"
		if modOptions.disabledcommmodules and modOptions.disabledcommmodules ~= "" then
			local s = modOptions.disabledcommmodules
			s = string.gsub(s, " ", "") -- remove whitespace
			for w in s:gmatch("[a-zA-Z_0-9]+") do
				disabledModules[w] = true
			end
			disabledModules["econ"] = nil -- do not ban basic income!
		end
    end
	if commwars then
		COST_MULT = COST_MULT * 0.5
	end
end

local moduleImagePath = "unitpics/"

------------------------------------------------------------------------
-- Module Definitions
------------------------------------------------------------------------

local function ApplyHighFrequencyBeamKit(modules, sharedData)
	local upgrade = {
		["commweapon_disruptorprojector"] = "commweapon_disruptorprojector_heavy",
		["commweapon_beamlaser"] = "commweapon_beamlaser_heavy",
		["commweapon_lparticlebeam"] = "commweapon_hparticlebeam",
		["commweapon_disruptor"] = "commweapon_heavy_disruptor",
	}
	local wantsfireatradar = {
		["commweapon_disruptorprojector_heavy"] = true,
		["commweapon_beamlaser_heavy"] = true,
		["commweapon_hparticlebeam"] = true,
	}
	if sharedData.weapon1 and upgrade[sharedData.weapon1] then
		sharedData.weapon1 = upgrade[sharedData.weapon1]
		sharedData.wantsfireatradar = sharedData.wantsfireatradar or wantsfireatradar[sharedData.weapon1]
	elseif sharedData.weapon2 and upgrade[sharedData.weapon2] then
		sharedData.weapon2 = upgrade[sharedData.weapon2]
		sharedData.wantsfireatradar = sharedData.wantsfireatradar or wantsfireatradar[sharedData.weapon2]
	end
end

local function ApplyDisintegratorUpgrade(modules, sharedData)
	if sharedData.weapon1 and sharedData.weapon1 == "commweapon_light_disintegrator" then
		sharedData.weapon1 = "commweapon_disintegrator"
	elseif sharedData.weapon2 and sharedData.weapon2 == "commweapon_light_disintegrator" then
		sharedData.weapon2 = "commweapon_disintegrator"
	end
end

local function ApplyHeavyOrdinance1(modules, sharedData)
	local upgrade = {
		["commweapon_artillery_heavy"] = "commweapon_artillery_heavy_nuclear",
		["commweapon_rocketbarrage"] = "commweapon_rocketbarrage_nuclear",
		["commweapon_rocketlauncher"] = "commweapon_rocketlauncher_nuclear",
		["commweapon_artillery_light"] = "commweapon_artillery_light_nuclear",
		["commweapon_taclaser"] = "commweapon_megalaser",
	}
	local wantsfireatradar = {
		["commweapon_artillery_heavy_nuclear"] = true,
		["commweapon_rocketbarrage_nuclear"] = false,
		["commweapon_rocketlauncher_nuclear"] = false,
		["commweapon_artillery_light_nuclear"] = false,
		["commweapon_megalaser"] = true,
	}
	if sharedData.weapon1 and upgrade[sharedData.weapon1] then
		sharedData.weapon1 = upgrade[sharedData.weapon1]
		sharedData.wantsfireatradar = sharedData.wantsfireatradar or wantsfireatradar[sharedData.weapon1]
	elseif sharedData.weapon2 and upgrade[sharedData.weapon2] then
		sharedData.weapon2 = upgrade[sharedData.weapon2]
		sharedData.wantsfireatradar = sharedData.wantsfireatradar or wantsfireatradar[sharedData.weapon2]
	end
end
	
local function ApplyHeavyOrdinance2(modules, sharedData)
	local upgrade = {
		["commweapon_artillery_heavy"] = "commweapon_artillery_heavy_nuclear",
		["commweapon_rocketbarrage"] = "commweapon_rocketbarrage_nuclear",
		["commweapon_rocketlauncher"] = "commweapon_rocketlauncher_nuclear",
		["commweapon_artillery_light"] = "commweapon_artillery_light_nuclear",
		["commweapon_taclaser"] = "commweapon_megalaser",
	}
	local wantsfireatradar = {
		["commweapon_artillery_heavy_nuclear"] = true,
		["commweapon_rocketbarrage_nuclear"] = false,
		["commweapon_rocketlauncher_nuclear"] = false,
		["commweapon_artillery_light_nuclear"] = false,
		["commweapon_megalaser"] = true,
	}
	if sharedData.weapon2 and upgrade[sharedData.weapon2] then
		sharedData.weapon2 = upgrade[sharedData.weapon2]
		sharedData.wantsfireatradar = sharedData.wantsfireatradar or wantsfireatradar[sharedData.weapon2]
	end
end

local function ApplyHeavyBarrel(modules, sharedData, weaponNum)
	local acceptableWeapons = {
		["commweapon_shotgun"] = true,
		["commweapon_heavyrifle"] = true,
		["commweapon_shotgun_disrupt"] = true,
		["commweapon_heavyrifle_disrupt"] = true,
		["commweapon_sunburst"] = true,
	}
	local shotguns = {
		["commweapon_shotgun"] = true,
		["commweapon_shotgun_disrupt"] = true,
	}
	if weaponNum == 1 then
		if sharedData.weapon1 and acceptableWeapons[sharedData.weapon1] then
			if shotguns[sharedData.weapon1] then
				sharedData.reloadOverride1 = 3.0
				sharedData.burstOverride1 = 2
				sharedData.burstRateOverride1 = 0.1
				sharedData.projectileBonus1 = 5
				sharedData.sprayAngleOverride1 = 2000
			end
		end
	else
		
	end
end

local function ApplyShotgunModule(modules, sharedData)
	local upgrade = {
		["commweapon_leolaser"] = "commweapon_leolaser_shotgun",
		["commweapon_leolaser_disrupt"] = "commweapon_leolaser_shotgun_disrupt"
	}
	if sharedData.weapon1 and upgrade[sharedData.weapon1] then
		sharedData.weapon1 = upgrade[sharedData.weapon1]
	elseif sharedData.weapon2 and upgrade[sharedData.weapon2] then
		sharedData.weapon2 = upgrade[sharedData.weapon2]
	end
end

local moduleDefs = {
	-- Empty Module Slots
	{
		name = "nullmodule",
		humanName = "No Module",
		description = "",
		image = "LuaUI/Images/dynamic_comm_menu/cross.png",
		limit = false,
		emptyModule = true,
		cost = 0,
		requireLevel = 0,
		slotType = "module",
	},
	{
		name = "nullbasicweapon", -- TODO: Remove.
		humanName = "No Weapon",
		description = "",
		image = "LuaUI/Images/dynamic_comm_menu/cross.png",
		limit = false,
		emptyModule = true,
		cost = 0,
		requireLevel = 0,
		slotType = "basic_weapon",
	},
	{
		name = "nulladvweapon", -- TODO: Remove.
		humanName = "No Weapon",
		description = "",
		image = "LuaUI/Images/dynamic_comm_menu/cross.png",
		limit = false,
		emptyModule = true,
		cost = 0 * COST_MULT,
		requireLevel = 0,
		slotType = "adv_weapon",
	},
	
	-- Weapons
	{
		name = "commweapon_beamlaser",
		humanName = "Beam Laser",
		description = "An effective short-range cutting tool",
		image = moduleImagePath .. "commweapon_beamlaser.png",
		limit = 2,
		cost = 0 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_beamlaser"
			else
				sharedData.weapon2 = "commweapon_beamlaser"
			end
		end
	},
	{
		name = "commweapon_flamethrower",
		humanName = "Heavy Flamethrower",
		description = "Good for deep-frying swarmers and large targets alike, but poor range.",
		image = moduleImagePath .. "commweapon_flamethrower.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"riot", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_flamethrower"
			else
				sharedData.weapon2 = "commweapon_flamethrower"
			end
		end
	},
	{
		name = "commweapon_light_flamethrower",
		humanName = "Light Flamethrower",
		description = "A lighter version of the Riot commander's flamethrower. Good at rapidly melting nearby units, set back by its poor range.",
		image = moduleImagePath .. "commweapon_flamethrower.png",
		limit = 2,
		cost = 75 * COST_MULT,
		requireChassis = {"recon"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_light_flamethrower"
			else
				sharedData.weapon2 = "commweapon_light_flamethrower"
			end
		end
	},
	{
		name = "commweapon_light_disintegrator",
		humanName = "Light Disintegrator Rifle",
		description = "A light Disintegrator that deals damage as it passes through units. Similar to the Ultimatium's Disintegrator, but cannot pass through ground.",
		image = moduleImagePath .. "commweapon_heatray.png",
		limit = 2,
		cost = 250 * COST_MULT,
		requireChassis = {"strike"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_light_disintegrator"
			else
				sharedData.weapon2 = "commweapon_light_disintegrator"
			end
		end
	},
	{
		name = "commweapon_heatray",
		humanName = "Heatray",
		description = "Rapidly melts anything at short range; steadily loses all of its damage over distance",
		image = moduleImagePath .. "commweapon_heatray.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_heatray"
			else
				sharedData.weapon2 = "commweapon_heatray"
			end
		end
	},
	{
		name = "commweapon_microriftgenerator",
		humanName = "Microrift Generator",
		description = "Instantly teleports your commander to any location within range. +75% damage.\nDisables Peaceful Wind module.",
		image = moduleImagePath .. "commweapon_microrift.png",
		limit = 1,
		cost = 100 * COST_MULT,
		requireChassis = {"strike"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			sharedData.weapon2 = "commweapon_microriftgenerator"
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.75
		end
	},
	{
		name = "commweapon_taclaser",
		humanName = "Flare Tactical Laser",
		description = "Miniture tachyon emitter designed to snipe units from afar. Requires unimpeded path to enemy making it poor in hilly regions.",
		image = moduleImagePath .. "commweapon_heatray.png",
		limit = 2,
		cost = 125 * COST_MULT,
		requireChassis = {"assault"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			sharedData.wantsfireatradar = true
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_taclaser"
			else
				sharedData.weapon2 = "commweapon_taclaser"
			end
		end
	},
	{
		name = "commweapon_heatray_recon",
		humanName = "Heatray",
		description = "Rapidly melts anything at short range; steadily loses all of its damage over distance",
		override = "commweapon_heatray",
		image = moduleImagePath .. "commweapon_heatray.png",
		limit = 2,
		cost = 0 * COST_MULT,
		requireChassis = {"recon"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_heatray"
			else
				sharedData.weapon2 = "commweapon_heatray"
			end
		end
	},
	{
		name = "commweapon_heavymachinegun",
		humanName = "Chaingun",
		description = "Automatic weapon with AoE that spools up over time.\nShaman's note: The actual DPS is much higher!",
		image = moduleImagePath .. "commweapon_heavymachinegun.png",
		limit = 2,
		cost = 0 * COST_MULT,
		requireChassis = {"riot", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local modifiers = ""
			if modules[moduleDefNames.conversion_disruptor] then -- Not implemented?
				modifiers = "_disrupt"
			end
			if modules[moduleDefNames.weaponmod_napalm_warhead_riot] then
				modifiers = modifiers .. "_napalm"
			end
			local weaponName = "commweapon_heavymachinegun" .. modifiers
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_heavyrifle",
		humanName = "Heavy Rifle",
		description = "Medium range and medium damage assault rifle for hunting down light units.",
		image = moduleImagePath .. "commweapon_emg.png",
		limit = 2,
		cost = 0 * COST_MULT,
		requireChassis = {"strike"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.conversion_disruptor] and "commweapon_heavyrifle_disrupt") or "commweapon_heavyrifle"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_emg",
		humanName = "Medium EMG Rifle",
		description = "Fast firing medium damage assault rifle. Single target only.",
		image = moduleImagePath .. "commweapon_emg.png",
		limit = 2,
		cost = 75 * COST_MULT,
		requireChassis = {"recon"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.conversion_disruptor] and "commweapon_emg_disrupt") or "commweapon_emg"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_tankbuster",
		humanName = "Tank Buster Cannon",
		description = "Extremely hard hitting, low fire rate antiheavy cannon. 20% Armor piercing.",
		image = moduleImagePath .. "commweapon_assaultcannon.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"strike"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.conversion_disruptor] and "commweapon_buster_disrupt") or "commweapon_tankbuster"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	--[[{
		name = "commweapon_hparticlebeam",
		humanName = "Heavy Particle Beam",
		description = "Heavy Particle Beam - Replaces other weapons. Short range, high-power beam weapon with moderate reload time. May be bugged?",
		image = moduleImagePath .. "conversion_hparticlebeam.png",
		limit = 1,
		cost = 100 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 1,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.conversion_disruptor] and "commweapon_heavy_disruptor") or "commweapon_hparticlebeam"
			sharedData.weapon1 = weaponName
			sharedData.weapon2 = nil
			sharedData.noMoreWeapons = true
		end
	},]]
	{
		name = "commweapon_artillery_heavy",
		humanName = "Plasma Artillery",
		description = "Long range, slow moving projectile that deals area damage.",
		image = moduleImagePath .. "commweapon_assaultcannon.png",
		limit = 2,
		cost = 200 * COST_MULT,
		requireChassis = {"assault"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = "commweapon_artillery_heavy"
			sharedData.wantsfireatradar = true
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_lightninggun",
		humanName = "Lightning Rifle",
		description = "Paralyzes and damages annoying bugs",
		image = moduleImagePath .. "commweapon_lightninggun.png",
		limit = 2,
		cost = 50 * COST_MULT,
		requireChassis = {"support", "strike", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.weaponmod_stun_booster] and "commweapon_lightninggun_improved") or "commweapon_lightninggun"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_lparticlebeam",
		humanName = "Light Particle Beam",
		description = "Fast, light pulsed energy weapon",
		image = moduleImagePath .. "commweapon_lparticlebeam.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.conversion_disruptor] and "commweapon_disruptor") or "commweapon_lparticlebeam"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_missilelauncher",
		humanName = "Missile Launcher",
		description = "Lightweight seeker missile with good range", -- Unused, besides knight
		image = moduleImagePath .. "commweapon_missilelauncher.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_missilelauncher"
			else
				sharedData.weapon2 = "commweapon_missilelauncher"
			end
		end
	},
	{
		name = "commweapon_rocketbarrage",
		humanName = "Light Long Range Missile Battery",
		description = "Also known as LLRMs. These light missiles spread over a large area, dealing lots of low level splash damage.",
		image = moduleImagePath .. "commweapon_missilelauncher.png",
		limit = 2,
		cost = 0 * COST_MULT,
		requireChassis = {"assault"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_rocketbarrage"
			else
				sharedData.weapon2 = "commweapon_rocketbarrage"
			end
		end
	},
	{
		name = "commweapon_riotcannon",
		humanName = "Riot Burst Cannon",
		description = "Fragmentation cannon that breaks into small pieces on impact.",
		image = moduleImagePath .. "commweapon_riotcannon.png",
		limit = 2,
		cost = 75 * COST_MULT,
		requireChassis = {"riot", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.weaponmod_napalm_warhead_riot] and "commweapon_riotcannon_napalm") or "commweapon_riotcannon"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_rocketlauncher",
		humanName = "Portable EOS Launcher",
		description = "Long range nuclear cruise missile that seeks its target before dropping out of the air and exploding. High damage and long range makes it good for sniping buildings and slow units. May be upgraded to a heavier, longer reload version (NYI).",
		image = moduleImagePath .. "commweapon_rocketlauncher.png",
		limit = 2,
		cost = 750 * COST_MULT,
		requireChassis = {"assault"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.weaponmod_napalm_warhead] and "commweapon_rocketlauncher_napalm") or "commweapon_rocketlauncher"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_capray",
		humanName = "Virus Uplink",
		description = "Uploads a capture/disarming virus onto enemy units, giving control over to you. The uplink must recharge after capturing a unit.",
		image = moduleImagePath .. "commweapon_capray.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"support"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = "commweapon_capray"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_shotgun",
		humanName = "Shotgun",
		description = "Can hammer a single large target or shred several small ones",
		image = moduleImagePath .. "commweapon_shotgun.png",
		limit = 2,
		cost = 50 * COST_MULT,
		requireChassis = {"strike", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.conversion_disruptor] and "commweapon_shotgun_disrupt") or "commweapon_shotgun"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_leolaser",
		humanName = "LEO Laser",
		description = "Hammers a single target with bursts of lasers.",
		image = moduleImagePath .. "commweapon_leolaser.png",
		limit = 2,
		cost = 50 * COST_MULT,
		requireChassis = {"recon"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.conversion_disruptor] and "commweapon_leolaser_disrupt") or "commweapon_leolaser"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_canistercannon",
		humanName = "Canister Cannon",
		description = "Releases tiny fragments at a certain range. May impact multiple units.",
		image = moduleImagePath .. "commweapon_canister.png",
		limit = 2,
		cost = 50 * COST_MULT,
		requireChassis = {"riot"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = "commweapon_canistercannon"
			if modules[moduleDefNames.weaponmod_napalm_warhead_riot] then
				weaponName = weaponName .. "_napalm"
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_grenadelauncher",
		humanName = "Grenade Launcher",
		description = "Like explosions? This weapon features a 10 round burst of light HE grenades, ruining any raider's day or dealing massive damage up close.",
		image = moduleImagePath .. "commweapon_grenadelauncher.png",
		limit = 2,
		cost = 75 * COST_MULT,
		requireChassis = {"riot"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = "commweapon_grenadelauncher"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_impulse_laser",
		humanName = "Repulsor",
		description = "A lightly damaging laser that phases through enemies, dealing higher damage to fatter units. High impulse.",
		image = moduleImagePath .. "commweapon_impulse_laser.png",
		limit = 2,
		cost = 75 * COST_MULT,
		requireChassis = {"support"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = "commweapon_impulse_laser"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_disruptorprojector",
		humanName = "Disruptor Projector",
		description = "Deals some damage and slows targets in a small area. Can be converted into a heavy AOE slow beam.",
		image = moduleImagePath .. "commweapon_disruptorprojector.png",
		limit = 2,
		cost = 75 * COST_MULT,
		requireChassis = {"support"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = "commweapon_disruptorprojector"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "module_heavyprojector",
		humanName = "High Frequency Beam Kit",
		description = "Converts a disruptor or beam into a heavier version.",
		image = moduleImagePath .. "module_beamamplifier.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"support"},
		requireOneOf = {"commweapon_disruptorprojector", "commweapon_beamlaser", "commweapon_lparticlebeam"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = ApplyHighFrequencyBeamKit
	},
	{
		name = "module_heavyordinance",
		humanName = "Heavy Ordinance Kit",
		description = "Converts weapons into a heavier, longer reload version. Increases AOE, Damage, and reload time.",
		image = moduleImagePath .. "weaponmod_plasma_containment.png",
		limit = 1,
		cost = 1500 * COST_MULT,
		requireChassis = {"assault"},
		requireOneOf = {"commweapon_artillery_heavy", "commweapon_taclaser", "commweapon_rocketbarrage", "commweapon_rocketlauncher", "commweapon_artillery_light"},
		requireLevel = 6,
		slotType = "module",
		applicationFunction = ApplyHeavyOrdinance1
	},
	{
		name = "module_heavydgun",
		humanName = "Disintegrator Amplifier",
		description = "Converts a single Light Disintegrator into its heavier counterpart.",
		image = moduleImagePath .. "weaponmod_plasma_containment.png",
		limit = 2,
		cost = 1250 * COST_MULT,
		requireChassis = {"strike"},
		requireOneOf = {"commweapon_light_disintegrator"},
		requireLevel = 10,
		slotType = "module",
		applicationFunction = ApplyDisintegratorUpgrade
	},
	{
		name = "module_shotgunlaser",
		humanName = "Beam Splitter",
		description = "Splits LEO Lasers, creating a shotgun-like effect. Increases DPS up close in exchange for high spread.",
		image = moduleImagePath .. "commweapon_leolaser_shotgun.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"recon"},
		requireOneOf = {"commweapon_leolaser"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = ApplyShotgunModule
	},
	{
		name = "module_shotgunlaser_second",
		humanName = "Beam Splitter",
		description = "Splits LEO Lasers, creating a shotgun-like effect. Increases DPS up close in exchange for high spread.",
		image = moduleImagePath .. "commweapon_leolaser_shotgun.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"recon"},
		requireTwoOf = {"commweapon_leolaser"},
		requireLevel = 4,
		slotType = "module",
		applicationFunction = ApplyShotgunModule
	},
	{
		name = "module_heavyordinance_second",
		humanName = "Heavy Ordinance Kit",
		description = "Converts weapons into a heavier, longer reload version. Increases AOE, Damage, and reload time.",
		image = moduleImagePath .. "weaponmod_plasma_containment.png",
		limit = 1,
		cost = 1200 * COST_MULT,
		requireChassis = {"assault"},
		requireTwoOf = {"commweapon_artillery_heavy", "commweapon_taclaser", "commweapon_rocketbarrage", "commweapon_rocketlauncher"},
		requireLevel = 7,
		slotType = "module",
		applicationFunction = ApplyHeavyOrdinance2
	},
	{
		name = "module_heavyprojector_second",
		humanName = "High Frequency Beam Kit",
		description = "Converts a disruptor or beam into a heavier version.",
		image = moduleImagePath .. "module_beamamplifier.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"support"},
		requireTwoOf = {"commweapon_disruptorprojector", "commweapon_beamlaser", "commweapon_lparticlebeam"},
		requireLevel = 4,
		slotType = "module",
		applicationFunction = ApplyHighFrequencyBeamKit
	},
	{
		name = "commweapon_shockrifle",
		humanName = "Sniper Rifle",
		description = "Long range sniper rifle. Good for sniping single units.",
		image = moduleImagePath .. "commweapon_shockrifle.png",
		limit = 2,
		cost = 200 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			local weaponName = "commweapon_shockrifle"
			if sharedData.noMoreWeapons then
				return
			end
			sharedData.wantsfireatradar = true
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_sonicgun",
		humanName = "Heavy Sonic Cannon",
		description = "Weapon that does some direct damage followed by a blastwave.",
		image = moduleImagePath .. "commweapon_sonicgun.png",
		limit = 2,
		cost = 70 * COST_MULT,
		requireChassis = {"riot"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			local weaponName = "commweapon_sonicgun"
			if sharedData.noMoreWeapons then
				return
			end
			sharedData.wantsfireatradar = true
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	
	{
		name = "commweapon_clusterbomb",
		humanName = "Cluster Bomb",
		description = "Manually fired burst of bombs.",
		image = moduleImagePath .. "commweapon_clusterbomb.png",
		limit = 1,
		cost = 250 * COST_MULT,
		requireChassis = {"recon", "assault", "knight"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_clusterbomb"
			else
				sharedData.weapon2 = "commweapon_clusterbomb"
			end
		end
	},
	{
		name = "commweapon_vacuumgun",
		humanName = "Vacuum Gun",
		description = "Manually fired blackhole. Deals heavy damage and pulls units inward.",
		image = moduleImagePath .. "commweapon_clusterbomb.png",
		limit = 1,
		cost = 450 * COST_MULT,
		requireChassis = {"riot"},
		requireLevel = 2,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_vacuumgun"
			else
				sharedData.weapon2 = "commweapon_vacuumgun"
			end
		end
	},
	{
		name = "commweapon_minefieldinacan",
		humanName = "Minefield In A Can",
		description = "A canister full of surprises, waiting for your enemies.",
		image = moduleImagePath .. "commweapon_minefieldinacan.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"recon", "strike"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_minefieldinacan"
			else
				sharedData.weapon2 = "commweapon_minefieldinacan"
			end
		end
	},
	{
		name = "commweapon_concussion",
		humanName = "Concussion Shell",
		description = "Manually fired high impulse projectile.",
		image = moduleImagePath .. "commweapon_concussion.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"recon", "riot", "knight"},
		requireLevel = 2,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_concussion"
			else
				sharedData.weapon2 = "commweapon_concussion"
			end
		end
	},
	{
		name = "commweapon_disintegrator",
		humanName = "Disintegrator",
		description = "Manually fired weapon that destroys almost everything it touches.",
		image = moduleImagePath .. "commweapon_disintegrator.png",
		limit = 1,
		cost = 750 * COST_MULT,
		requireChassis = {"knight"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_disintegrator"
			else
				sharedData.weapon2 = "commweapon_disintegrator"
			end
		end
	},
	{
		name = "commweapon_sunburst",
		humanName = "Sunburst Cannon",
		description = "Manually fired weapon that ruin's a single target's day with a high damage shot. Deals additional damage to shields, allowing it to bypass shields in some cases.",
		image = moduleImagePath .. "commweapon_sunburst.png",
		limit = 1,
		cost = 400 * COST_MULT,
		requireChassis = {"strike", "knight"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon2 then
				sharedData.weapon2 = "commweapon_sunburst"
			end
		end
	},
	{
		name = "commweapon_disruptorbomb",
		humanName = "Disruptor Bomb",
		description = "Manually fired bomb that slows enemies in a large area.",
		image = moduleImagePath .. "commweapon_disruptorbomb.png",
		limit = 1,
		cost = 400 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_disruptorbomb"
			else
				sharedData.weapon2 = "commweapon_disruptorbomb"
			end
		end
	},
	{
		name = "commweapon_multistunner",
		humanName = "Multistunner",
		description = "Manually fired sustained burst of lightning.",
		image = moduleImagePath .. "commweapon_multistunner.png",
		limit = 1,
		cost = 400 * COST_MULT,
		requireChassis = {"support", "strike", "knight"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.weaponmod_stun_booster] and "commweapon_multistunner_improved") or "commweapon_multistunner"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
		{
		name = "commweapon_gaussrepeater",
		humanName = "Gauss Repeater",
		description = "A penetrating, rapid fire short range rifle for raiding while underwater.",
		image = moduleImagePath .. "commweapon_gaussrifle.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"recon"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = "commweapon_gaussrepeater"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_napalmgrenade",
		humanName = "Hellfire Grenade",
		description = "Manually fired bomb that inflames a large area.",
		image = moduleImagePath .. "commweapon_napalmgrenade.png",
		limit = 1,
		cost = 200 * COST_MULT,
		requireChassis = {"assault", "recon", "knight"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_napalmgrenade"
			else
				sharedData.weapon2 = "commweapon_napalmgrenade"
			end
		end
	},
	{
		name = "commweapon_singulauncher",
		humanName = "Singularity Launcher",
		description = "Manually launched Singularity generator. Pulls units, wrecks and projectiles inward.",
		image = moduleImagePath .. "commweapon_concussion.png",
		limit = 1,
		cost = 200 * COST_MULT,
		requireChassis = {"support"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_singulauncher"
			else
				sharedData.weapon2 = "commweapon_singulauncher"
			end
		end
	},
	--{
		--name = "commweapon_artillery_light",
		--humanName = "Rapid Fire Artillery Gun",
		--description = "Rapid fire edition of the artillery gun.",
		--image = moduleImagePath .. "commweapon_heavymachinegun.png",
		--limit = 2,
		--cost = 100 * COST_MULT,
		--requireChassis = {"assault"},
		--requireLevel = 1,
		--slotType = "basic_weapon",
		--applicationFunction = function (modules, sharedData)
			--if sharedData.noMoreWeapons then
				--return
			--end
			--if not sharedData.weapon1 then
				--sharedData.weapon1 = "commweapon_artillery_light"
			--else
				--sharedData.weapon2 = "commweapon_artillery_light"
			--end
		--end
	--},
	{
		name = "commweapon_slamrocket",
		humanName = "S.L.A.M. Rocket",
		description = "Manually fired miniature tactical nuke.",
		image = moduleImagePath .. "commweapon_slamrocket.png",
		limit = 1,
		cost = 200 * COST_MULT,
		requireChassis = {"knight"},
		requireLevel = 3,
		slotType = "adv_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			if not sharedData.weapon1 then
				sharedData.weapon1 = "commweapon_slamrocket"
			else
				sharedData.weapon2 = "commweapon_slamrocket"
			end
		end
	},
	
	-- Unique Modules
	{
		name = "econ",
		humanName = "Vanguard Economy Pack",
		description = "A vital part of establishing a beachhead, this module is equipped by all new commanders to kickstart their economy. Provides 4 metal income and 6 energy income.",
		image = moduleImagePath .. "module_energy_cell.png",
		limit = 1,
		unequipable = true,
		cost = 100 * COST_MULT,
		requireLevel = 0,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.metalIncome = (sharedData.metalIncome or 0) + 6
			sharedData.energyIncome = (sharedData.energyIncome or 0) + 8
		end
	},
	{
		name = "commweapon_personal_shield",
		humanName = "Personal Shield",
		description = "A small, protective bubble shield.\nMutually Exclusive with Area Jammer and Personal Cloak.",
		image = moduleImagePath .. "module_personal_shield.png",
		limit = 1,
		cost = 600 * COST_MULT,
		prohibitingModules = {"module_personal_cloak", "module_jammer"},
		requireChassis = {"support", "riot", "recon", "assault", "knight"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			-- Do not override area shield
			sharedData.shield = sharedData.shield or "commweapon_personal_shield"
		end
	},
	{
		name = "commweapon_areashield",
		humanName = "Area Shield",
		description = "Projects a large shield. Replaces Personal Shield.",
		image = moduleImagePath .. "module_areashield.png",
		limit = 1,
		cost = 750 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireOneOf = {"commweapon_personal_shield"},
		prohibitingModules = {"module_personal_cloak", "module_jammer"},
		requireLevel = 3,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.shield = "commweapon_areashield"
		end
	},
	{
		name = "weaponmod_napalm_warhead_riot",
		humanName = "Incendiary Rounds",
		description = "Reduces direct damage by 20% in exchange for setting an area on fire.\nRequires: Canister Cannon, Chaingun, or Riot Cannon.",
		image = moduleImagePath .. "weaponmod_napalm_warhead.png",
		limit = 1,
		cost = 375 * COST_MULT,
		requireChassis = {"knight", "riot"},
		requireOneOf = {"commweapon_riotcannon", "commweapon_canistercannon", "commweapon_heavymachinegun"},
		requireLevel = 2,
		slotType = "module",
	},
	{
		name = "weaponmod_napalm_warhead",
		humanName = "Napalm Warhead",
		description = "Riot Cannon and Rocket Launcher set targets on fire. Reduced direct damage.",
		image = moduleImagePath .. "weaponmod_napalm_warhead.png",
		limit = 1,
		cost = 350 * COST_MULT,
		requireChassis = {"knight"},
		requireOneOf = {"commweapon_rocketlauncher", "commweapon_artillery_heavy", "commweapon_riotcannon"},
		requireLevel = 2,
		slotType = "module",
	},
	{
		name = "conversion_disruptor",
		humanName = "Disruptor Ammo",
		description = "Heavy Machine Gun, Tank Buster, EMG, Shotgun and Particle Beams deal slow damage. Reduced direct damage.",
		image = moduleImagePath .. "weaponmod_disruptor_ammo.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"strike", "recon", "support", "knight"},
		requireOneOf = {"commweapon_heavymachinegun", "commweapon_leolaser", "commweapon_heavyrifle", "commweapon_tankbuster", "commweapon_emg", "commweapon_shotgun", "commweapon_hparticlebeam", "commweapon_lparticlebeam"},
		requireLevel = 2,
		slotType = "module",
	},
	{
		name = "weaponmod_stun_booster",
		humanName = "Flux Amplifier",
		description = "Lightning rifle is upgraded to be heavier (longer reload, better EMP, more damage). Improves EMP time on Multistunner.",
		image = moduleImagePath .. "weaponmod_stun_booster.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"support", "strike", "recon", "knight"},
		requireOneOf = {"commweapon_lightninggun", "commweapon_multistunner"},
		requireLevel = 4,
		slotType = "module",
	},
	{
		name = "module_jammer",
		humanName = "Radar Jammer",
		description = "Hide the radar signals of nearby units.",
		image = moduleImagePath .. "module_jammer.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		requireChassis = {"support", "knight"},
		applicationFunction = function (modules, sharedData)
			if not sharedData.cloakFieldRange then
				sharedData.radarJammingRange = 500
			end
		end
	},
	{
		name = "module_personaljammer",
		humanName = "Personal Radar Jammer",
		description = "Hides you from radar.",
		image = moduleImagePath .. "module_jammer.png",
		limit = 1,
		cost = 500 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"recon", "strike"},
		applicationFunction = function (modules, sharedData)
			if not sharedData.cloakFieldRange then
				sharedData.personaljammer = true
			end
		end
	},
	{
		name = "module_radarnet",
		humanName = "Field Radar",
		description = "Attaches a basic radar system.",
		image = moduleImagePath .. "module_fieldradar.png",
		limit = 1,
		cost = 75 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.radarRange = 1800
		end
	},
	{
		name = "module_radaramplifier",
		humanName = "Radar Amplifier",
		description = "Increases radar by 10%.",
		image = moduleImagePath .. "module_fieldradar.png",
		limit = 8,
		requireChassis = {"recon"},
		cost = 75 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.radarRange = (sharedData.radarRange or 1800) + 180
		end
	},
	{
		name = "module_visionenhancer",
		humanName = "Enhanced Sensors",
		description = "Increases sight radius by 20%.",
		image = moduleImagePath .. "module_radarnet2.png",
		limit = 8,
		requireChassis = {"recon"},
		cost = 125 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.sightrangebonus = (sharedData.sightrangebonus or 1) + .2
		end
	},
	{
		name = "module_personal_cloak",
		humanName = "Personal Cloak",
		description = "A personal cloaking device.\nRecon and Bombard only.",
		image = moduleImagePath .. "module_personal_cloak.png",
		limit = 1,
		cost = 400 * COST_MULT,
		prohibitingModules = {"commweapon_personal_shield", "commweapon_areashield"},
		requireChassis = {"strike", "knight"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.decloakDistance = math.max(sharedData.decloakDistance or 0, 150)
			sharedData.personalCloak = true
			sharedData.recloaktime = 300
		end
	},
	{
		name = "module_cloak_field",
		humanName = "Cloaking Field",
		description = "Cloaks all nearby units in a 350m radius.",
		image = moduleImagePath .. "module_cloak_field.png",
		limit = 1,
		cost = 600 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireOneOf = {"module_jammer"},
		requireLevel = 3,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.areaCloak = true
			sharedData.decloakDistance = 180
			sharedData.cloakFieldRange = 350
			sharedData.cloakFieldUpkeep = 15
			sharedData.radarJammingRange = 350
			sharedData.recloaktime = 300
		end
	},
	{
		name = "module_resurrect",
		humanName = "Support Package",
		description = "Upgrade nanolathe to allow resurrection and adds 20 bp along with 1k storage.\nExclusive with Drone Package.",
		image = moduleImagePath .. "module_resurrect.png",
		limit = 1,
		cost = 140 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 2, -- hard limit
		slotType = "module",
		prohibitingModules = {"module_drone_package"},
		applicationFunction = function (modules, sharedData)
			sharedData.canResurrect = true
			sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 20
			sharedData.extrastorage = (sharedData.extrastorage or 0) + 1000
		end
	},
	{
		name = "module_drone_package",
		humanName = "Drone Package",
		description = "Unlocks advanced drone production moudles, Increases drone build slots by 1 and improves drone build speed by 50%. Adds 1 heavy drone, 1 repair drone, and 2 companion drones. Companion Drone modules add an extra drone.\nExclusive with Support Package.",
		image = moduleImagePath .. "module_dronepackage.png",
		limit = 1,
		cost = 200 * COST_MULT,
		requireChassis = {"support"},
		requireLevel = 2,
		slotType = "module",
		prohibitingModules = {"module_resurrect"},
		applicationFunction = function (modules, sharedData)
			sharedData.extradroneslots = (sharedData.extradroneslots or 1) + 1
			sharedData.dronebuildmod = (sharedData.dronebuildmod or 1) + 0.5
			sharedData.drone = (sharedData.drone or 0) + 2
			sharedData.droneheavyslows = (sharedData.droneheavyslows or 1) + 1
			sharedData.dronecon = (sharedData.dronecon or 0) + 1
		end
	},
	{
		name = "module_jumpreload",
		humanName = "Efficient Jumpjets",
		description = "Reduces jumpjet cooldown by 20%.\nIncreases jump speed slightly.\nMutually Exclusive with: Improved Jumpjets & High Performance Jumpjets.",
		image = moduleImagePath .. "module_jumpjetrecharge.png",
		limit = 4,
		cost = 200 * COST_MULT,
		requireChassis = {"recon"},
		prohibitingModules = {"module_jumprange", "module_jumpretrofit"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			local reloadbonus = sharedData.jumpreloadbonus or 0
			sharedData.jumpreloadbonus = reloadbonus + 0.2
			local speedbonus = sharedData.jumpspeedbonus or 0
			sharedData.jumpspeedbonus = speedbonus + 0.25
		end
	},
	{
		name = "module_detpack",
		humanName = "\"Peaceful Wind\" Asset Denial System",
		description = "Mutually Assured Destruction guaranteed or your metal back!\n\nThe commander will no longer leave a wreck when it dies. Increases the severity of the commander death explosion. At maximum level, it is equivalent to a nuclear detonation.\nReduces HP by " .. 1000*HP_MULT .. ".\n\n\255\255\061\06WARNING\255\255\255: Disarm/EMP will prevent explosion from going off.",
		image = moduleImagePath .. "module_detpack.png",
		limit = 3,
		cost = 850 * COST_MULT,
		requireLevel = 5,
		slotType = "module",
		prohibitingModules = {"commweapon_microriftgenerator"},
		applicationFunction = function (modules, sharedData)
			local detpacklv = (sharedData.detpacklv or 0) + 1
			sharedData.healthBonus = (sharedData.healthBonus or 0) - 1000*HP_MULT
			sharedData.detpacklv = detpacklv
		end
	},
	{
		name = "module_jumpretrofit",
		humanName = "Improved Jumpjets",
		description = "Increases jumpjet range by 20%.\nIncreases jump speed moderately.\nDecreases jumpjet reload by 7.5%\nMutually Exclusive with: High Performance Jumpjets & Efficient Jumpjets.",
		image = moduleImagePath .. "module_jumpjetretrofit.png",
		limit = 4,
		cost = 220 * COST_MULT,
		requireChassis = {"recon"},
		prohibitingModules = {"module_jumpreload", "module_jumprange"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			local rangebonus = sharedData.jumprangebonus or 0
			local reloadbonus = sharedData.jumpreloadbonus or 0
			local speedbonus = sharedData.jumpspeedbonus or 0
			sharedData.jumpspeedbonus = speedbonus + 0.5
			sharedData.jumprangebonus = rangebonus + 0.2
			sharedData.jumpreloadbonus = reloadbonus + 0.075
		end
	},
	{
		name = "module_jumprange",
		humanName = "High Performance Jumpjets",
		description = "Increases jumpjet range by 50%.\nIncreases jump speed signifcantly.\nMutually Exclusive with: Improved Jumpjets & Efficient Jumpjets.",
		image = moduleImagePath .. "module_jumpjetpower.png",
		limit = 4,
		cost = 350 * COST_MULT,
		requireChassis = {"recon"},
		prohibitingModules = {"module_jumpreload", "module_jumpretrofit"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			local rangebonus = sharedData.jumprangebonus or 0
			sharedData.jumprangebonus = rangebonus + 0.5
			local speedbonus = sharedData.jumpspeedbonus or 0
			sharedData.jumpspeedbonus = speedbonus + 0.75
		end
	},
	{
		name = "module_jumpjet",
		humanName = "Jumpjets",
		description = "Leap over obstacles and out of danger.",
		image = moduleImagePath .. "module_jumpjet.png",
		limit = 1,
		cost = 400 * COST_MULT,
		requireChassis = {"knight"},
		requireLevel = 3,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.canJump = true
		end
	},
	
	-- Repeat Modules
	{
		name = "module_companion_drone",
		humanName = "Companion Drone",
		description = "Adds a light protective drone. With the Drone Package, spawn 2 instead.",
		image = moduleImagePath .. "module_companiondrone.png",
		limit = 8,
		cost = 75 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			if modules[moduleDefNames.module_drone_package] then
				sharedData.drones = (sharedData.drones or 0) + 2
			else
				sharedData.drones = (sharedData.drones or 0) + 1
			end
		end
	},
	{
		name = "module_battle_drone",
		humanName = "Battle Drone",
		description = "Commander spawns a heavy drone.",
		image = moduleImagePath .. "module_droneheavyslow.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireChassis = {"support"},
		requireOneOf = {"module_drone_package"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.droneheavyslows = (sharedData.droneheavyslows or 0) + 1
		end
	},
	{
		name = "module_drone_range",
		humanName = "Drone Order Transmission Array",
		description = "Increases the range drones acquire and chase targets by 50%.",
		image = moduleImagePath .. "module_dronerange.png",
		limit = 8,
		cost = 200 * COST_MULT,
		requireChassis = {"support"},
		requireOneOf = {"module_drone_package"},
		requireLevel = 5,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.dronerange = (sharedData.dronerange or 1) + 0.5
		end
	},
	{
		name = "module_improved_choke",
		humanName = "Improved Choke",
		description = "Improved Choke:\nImproves shotgun accuracy at the cost of damage output. Better performance for long range.\nShotguns:\nSpread: -30%\nprojectiles -4",
		image = moduleImagePath .. "module_improved_choke.png",
		limit = 3,
		cost = 100 * COST_MULT,
		requireChassis = {"strike"},
		requireLevel = 3,
		slotType = "module",
		prohibitingModules = {"module_full_choke"},
		requireOneOf = {"commweapon_shotgun"},
		applicationFunction = function (modules, sharedData)
			if sharedData.weapon1 and (sharedData.weapon1 == "commweapon_shotgun" or sharedData.weapon1 == "commweapon_shotgun_disrupt") then
				sharedData.sprayAngleBonus1 = (sharedData.sprayAngleBonus1 or 0) - 0.3
				sharedData.accuracyBonus1 = (sharedData.accuracyBonus1 or 0) + 0.3
				sharedData.projectileBonus1 = (sharedData.projectileBonus1 or 0) - 4
			end
			if sharedData.weapon2 and (sharedData.weapon2 == "commweapon_shotgun" or sharedData.weapon2 == "commweapon_shotgun_disrupt") then
				sharedData.sprayAngleBonus2 = (sharedData.sprayAngleBonus2 or 0) - 0.3
				sharedData.accuracyBonus2 = (sharedData.accuracyBonus2 or 0) + 0.3
				sharedData.projectileBonus2 = (sharedData.projectileBonus2 or 0) - 4
			end
		end
	},
	{
		name = "module_full_choke",
		humanName = "Flechette Engineering",
		description = "Flechette Engineering:\nImproves damage output for shotguns at the cost of higher spread.\nShotguns:\nSpread: +11%\nprojectiles +5",
		image = moduleImagePath .. "module_full_choke.png",
		limit = 3,
		cost = 75 * COST_MULT,
		requireChassis = {"strike"},
		requireLevel = 3,
		slotType = "module",
		requireOneOf = {"commweapon_shotgun"},
		prohibitingModules = {"module_improved_choke"},
		applicationFunction = function (modules, sharedData)
			if sharedData.weapon1 and (sharedData.weapon1 == "commweapon_shotgun" or sharedData.weapon1 == "commweapon_shotgun_disrupt") then
				sharedData.sprayAngleBonus1 = (sharedData.sprayAngleBonus1 or 0) + 0.11
				sharedData.accuracyBonus1 = (sharedData.accuracyBonus1 or 0) + 0.11
				sharedData.projectileBonus1 = (sharedData.projectileBonus1 or 0) + 5
			end
			if sharedData.weapon2 and (sharedData.weapon2 == "commweapon_shotgun" or sharedData.weapon2 == "commweapon_shotgun_disrupt") then
				sharedData.sprayAngleBonus2 = (sharedData.sprayAngleBonus2 or 0) + 0.11
				sharedData.accuracyBonus2 = (sharedData.accuracyBonus2 or 0) + 0.11
				sharedData.projectileBonus2 = (sharedData.projectileBonus2 or 0) + 5
			end
		end
	},
	{
		name = "module_autoflechette",
		humanName = "Autoflechette",
		description = "Autoflechette:\nShotguns: Increase reload speed by 33%, but fire 5 less flechettes.",
		image = moduleImagePath .. "module_autoflechette.png",
		limit = 1,
		cost = 75 * COST_MULT,
		requireOneOf = {"commweapon_shotgun"},
		requireChassis = {"strike"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			if sharedData.weapon1 and (sharedData.weapon1 == "commweapon_shotgun" or sharedData.weapon1 == "commweapon_shotgun_disrupt") then
				sharedData.reloadOverride1 = 26/30
				sharedData.projectileBonus1 = (sharedData.projectileBonus1 or 0) - 5
			end
			if sharedData.weapon2 and (sharedData.weapon2 == "commweapon_shotgun" or sharedData.weapon2 == "commweapon_shotgun_disrupt") then
				sharedData.reloadOverride2 = 26/30
				sharedData.projectileBonus2 = (sharedData.projectileBonus2 or 0) - 5
			end
		end
	},
	{
		name = "module_repair_drone",
		humanName = "Repair Drone",
		description = "Adds a Repair Drone to your maximum drone control. Repair drones have a shield and can repair friendly units at 10 bp.",
		image = moduleImagePath .. "module_dronecon.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireChassis = {"support"},
		requireOneOf = {"module_drone_package"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.dronecon = (sharedData.dronecon or 0) + 1
		end
	},
	{
		name = "module_assault_drone",
		humanName = "Assault Drone",
		description = "Adds an Assault Drone to your maximum drone control. Assault drones have high hp, and fire a cannon at targets.",
		image = moduleImagePath .. "module_droneassault.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireChassis = {"support"},
		requireOneOf = {"module_drone_package"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.droneassault = (sharedData.droneassault or 0) + 1
		end
	},
	{
		name = "module_drone_buildslot",
		humanName = "Drone Autofab",
		description = "Requires Drone Package.\nAdds a drone build slot. +10% drone build speed.",
		image = moduleImagePath .. "module_extraslots.png",
		limit = 4,
		cost = 120 * COST_MULT,
		requireChassis = {"support"},
		requireLevel = 2,
		slotType = "module",
		requireOneOf = {"module_drone_package"},
		applicationFunction = function (modules, sharedData)
			sharedData.extradroneslots = (sharedData.extradroneslots or 1) + 1 -- should equal 6 at max level. 1 from drone package + 4 from this.
			sharedData.dronebuildmod = (sharedData.dronebuildmod or 1) + 0.1
			sharedData.dronereloadtime = (sharedData.dronereloadtime or 1) + 0.1
		end
	},
	{
		name = "module_drone_buildspeed",
		humanName = "Drone Autofab Improvements",
		description = "Requires Drone Package.\n+50% drone build speed.",
		image = moduleImagePath .. "module_drone_buildspeed.png",
		limit = 8,
		cost = 120 * COST_MULT,
		requireChassis = {"support"},
		requireLevel = 2,
		slotType = "module",
		requireOneOf = {"module_drone_package"},
		applicationFunction = function (modules, sharedData)
			sharedData.dronebuildmod = (sharedData.dronebuildmod or 1) + 0.5
			sharedData.dronereloadtime = (sharedData.dronereloadtime or 1) + 0.2
		end
	},
	{
		name = "module_autorepair",
		humanName = "Damage Control Systems",
		description = "Commander self-repairs at +10 hp/s.",
		image = moduleImagePath .. "module_autorepair.png",
		limit = 8,
		cost = 175 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"recon", "assault", "support", "strike", "knight"},
		prohibitingModules = {"module_striderpower"},
		applicationFunction = function (modules, sharedData)
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 10
			--sharedData.healthBonus = (sharedData.healthBonus or 0) - 75*HP_MULT
		end
	},
	{
		name = "module_nanorepair",
		humanName = "Nanoreactive Armor Installment",
		description = "Installs a nanite repair system into the armor. As damage is inflicted, more nanites are released into the armor to repair it, granting up to 210 hp/sec repair. May be upgraded further past level 5. Riot only.",
		image = moduleImagePath .. "module_autorepair.png",
		limit = 1,
		cost = 900 * COST_MULT,
		requireLevel = 2,
		requireChassis = {"riot"},
		requireOneOf = {"module_striderpower"},
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.nanoregen = (sharedData.nanoregen or 0) + 21
			sharedData.nanomax = (sharedData.nanomax or 0) + 10
		end
	},
	{
		name = "module_nanorepair_upgrade_regen",
		humanName = "Nanite Dense Armor",
		description = "Improves base nanoreactive regeneration speed by 3, increasing max regeneration by 30. Increases health by " .. 500*HP_MULT .. "Riot only.",
		image = moduleImagePath .. "module_nano_armor.png",
		limit = 4,
		cost = 400 * COST_MULT,
		requireLevel = 5,
		requireChassis = {"riot"},
		requireOneOf = {"module_nanorepair"},
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.nanoregen = (sharedData.nanoregen or 0) + 3
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 500*HP_MULT
		end
	},
	{
		name = "module_nanorepair_upgrade_max",
		humanName = "Improved Nanite Response Time",
		description = "Improves nanoreactive regeneration effectiveness by 20%, allowing higher regen speed. Riot only.",
		image = moduleImagePath .. "module_repair_field.png",
		limit = 5,
		cost = 600 * COST_MULT,
		requireLevel = 2,
		requireChassis = {"riot"},
		requireOneOf = {"module_nanorepair"},
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.nanomax = (sharedData.nanomax or 0) + 2
		end
	},
	{
		name = "module_ablative_armor",
		humanName = "Ablative Armour Plates",
		description = "Provides " .. 1400*HP_MULT .. " health.",
		image = moduleImagePath .. "module_ablative_armor.png",
		limit = 8,
		cost = 200 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 1400*HP_MULT
		end
	},
	{
		name = "module_fireproofing",
		humanName = "Heat-Dissipating Armor",
		description = "Installs an additional mixture of heat resistant, fireproof, and dissipative materials to the commander's outer armor layers. Provides afterburn and napalm immunity. Increases health by " .. 550 * HP_MULT .. " but reduces speed by 6.",
		image = moduleImagePath .. "module_fireproof_armor.png",
		limit = 1,
		cost = 350 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		requireChassis = {"riot"},
		applicationFunction = function (modules, sharedData)
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 550 * HP_MULT
			sharedData.speedMalus = (sharedData.speedMalus or 0) + 6
			sharedData.fireproof = true
		end
	},
	{
		name = "module_heavy_armor",
		humanName = "High Density Plating",
		description = "Provides " .. 4000*HP_MULT .. " health but reduces speed by 0.35.\nRiot exclusive.",
		image = moduleImagePath .. "module_heavy_armor.png",
		limit = 8,
		cost = 200 * COST_MULT,
		requireOneOf = {"module_ablative_armor"},
		requireChassis = {"riot"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 4000*HP_MULT
			sharedData.speedMalus = (sharedData.speedMalus or 0) + 0.35
		end
	},
	{
		name = "module_dmg_booster_adv",
		humanName = "Weapon Retrofits",
		description = "Provides a 15% boost in firepower. Increases HP by " .. 200*HP_MULT ..	".\nRiot Exclusive.",
		image = moduleImagePath .. "module_dmg_booster.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 4,
		slotType = "module",
		requireChassis = {"riot"},
		requireOneOf = {"module_striderpower"},
		applicationFunction = function (modules, sharedData)
			-- Damage boost is applied via clone swapping
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.15
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 200*HP_MULT
		end
	},
	{
		name = "module_alphastrike",
		humanName = "Alpha Strike",
		description = "Provides a 70% boost in firepower. Decreases reload speed by 50%.\nGhost Exclusive.",
		image = moduleImagePath .. "module_alphastrike.png",
		limit = 4,
		cost = 100 * COST_MULT,
		requireLevel = 6,
		slotType = "module",
		requireChassis = {"strike"},
		prohibitingModules = {"module_autoloader"},
		applicationFunction = function (modules, sharedData)
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.70
			sharedData.reloadBonus = (sharedData.reloadBonus or 0) - 0.50
		end
	},
	{
		name = "module_heavyrocket",
		humanName = "Heavy Rocket Motors",
		description = "Improves rocket range at the cost of reload speed. Increases base range by 33% (range before modifications), reload speed -50%.\nArtillery Exclusive.",
		image = moduleImagePath .. "module_heavy_rocket.png",
		limit = 4,
		cost = 800 * COST_MULT,
		requireLevel = 9,
		slotType = "module",
		requireChassis = {"assault"},
		requireOneOf = {"commweapon_rocketbarrage", "commweapon_rocketlauncher"},
		prohibitingModules = {"module_rocketrangereducer"},
		applicationFunction = function (modules, sharedData)
			local baseRange = {
				["commweapon_rocketlauncher"] = 720,
				["commweapon_rocketlauncher_nuclear"] = 800,
				["commweapon_rocketbarrage_nuclear"] = 800,
				["commweapon_rocketbarrage"] = 800,
				["commweapon_slamrocket"] = 1000,
			}
			local baseReload = {
				["commweapon_rocketlauncher"] = 12.2,
				["commweapon_rocketlauncher_nuclear"] = 60,
				["commweapon_rocketbarrage"] = 7.2,
				["commweapon_rocketbarrage_nuclear"] = 25,
			}
			local rangeMod = 1/3
			sharedData.rocketrangeboosts = (sharedData.rocketrangeboosts or 0) + 1
			--sharedData.reloadBonus = (sharedData.reloadBonus or 0) - 0.75
			if sharedData.weapon1 and baseRange[sharedData.weapon1] then
				local reload = baseReload[sharedData.weapon1]
				sharedData.reloadOverride1 = (sharedData.reloadOverride1 or reload) + (reload / 2)
				sharedData.rangeoverride1 = baseRange[sharedData.weapon1] * (1 + (rangeMod * sharedData.rocketrangeboosts))
			end
			if sharedData.weapon2 and baseRange[sharedData.weapon2] then
				local reload = baseReload[sharedData.weapon2]
				sharedData.reloadOverride2 = (sharedData.reloadOverride2 or reload) + (reload / 2)
				sharedData.rangeoverride2 = baseRange[sharedData.weapon2] * (1 + (rangeMod * sharedData.rocketrangeboosts))
			end
		end
	},
	{
		name = "module_rocketrangereducer",
		humanName = "Explosive Rocket Fuel",
		description = "Reduces base range (before range boosters) by 11.5%. Base damage (before damage boosters) is increased by 25%.\nArtillery Exclusive.",
		image = moduleImagePath .. "module_rocketrangereduction.png",
		limit = 4,
		cost = 800 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		requireChassis = {"assault"},
		requireOneOf = {"commweapon_rocketbarrage", "commweapon_rocketlauncher"},
		prohibitingModules = {"module_heavyrocket"},
		applicationFunction = function (modules, sharedData)
			local baseRange = {
				["commweapon_rocketlauncher"] = 720,
				["commweapon_rocketlauncher_nuclear"] = 800,
				["commweapon_rocketbarrage_nuclear"] = 800,
				["commweapon_rocketbarrage"] = 800,
				["commweapon_slamrocket"] = 1000,
			}
			sharedData.rocketrangeboosts = (sharedData.rocketrangeboosts or 0) + 1
			if sharedData.weapon1 and baseRange[sharedData.weapon1] then
				sharedData.rangeoverride1 = baseRange[sharedData.weapon1] * (1 - (0.115 * sharedData.rocketrangeboosts))
				sharedData.damageBooster1 = (sharedData.damageBooster1 or 0) + 0.25
			end
			if sharedData.weapon2 and baseRange[sharedData.weapon2] then
				sharedData.rangeoverride2 = baseRange[sharedData.weapon2] * (1 - (0.115 * sharedData.rocketrangeboosts))
				sharedData.damageBooster2 = (sharedData.damageBooster2 or 0) + 0.25
			end
		end
	},
	{
		name = "module_expandedrocketsalvo",
		humanName = "Expanded Rocket Ammunition Storage",
		description = "Expand your rocket reserves significantly, creating a torrent of rockets to fly at your foes. Increases Rocket Barrage size by 8 projectiles, increases reload by 0.8s. If you have heavy ordinance installed, increase projectile count by 10 instead and reload by 5.4s instead.\nArtillery Exclusive. Mutually exclusive with Conservative Rocket Deployment.",
		image = moduleImagePath .. "module_rocketammo.png",
		limit = 8,
		cost = 800 * COST_MULT,
		requireLevel = 9,
		slotType = "module",
		requireChassis = {"assault"},
		requireOneOf = {"commweapon_rocketbarrage"},
		prohibitingModules = {"module_rocketconservation"},
		applicationFunction = function (modules, sharedData)
			if sharedData.weapon1 and sharedData.weapon1 == "commweapon_rocketbarrage" then
				local basereload = 7.2
				sharedData.burstOverride1 = (sharedData.burstOverride1 or 6) + 2
				sharedData.reloadOverride1 = (sharedData.reloadOverride1 or basereload) + 0.8
			elseif sharedData.weapon1 and sharedData.weapon1 == "commweapon_rocketbarrage_nuclear" then
				local basereload = 25
				sharedData.burstOverride1 = (sharedData.burstOverride1 or 30) + 10
				sharedData.reloadOverride1 = (sharedData.reloadOverride1 or basereload) + 5.4
			end
			if sharedData.weapon2 and sharedData.weapon2 == "commweapon_rocketbarrage" then
				local basereload = 7.2
				sharedData.burstOverride2 = (sharedData.burstOverride2 or 6) + 2
				sharedData.reloadOverride2 = (sharedData.reloadOverride2 or basereload) + 0.8
			elseif sharedData.weapon2 and sharedData.weapon2 == "commweapon_rocketbarrage_nuclear" then
				local basereload = 25
				sharedData.burstOverride2 = (sharedData.burstOverride2 or 30) + 10
				sharedData.reloadOverride2 = (sharedData.reloadOverride2 or basereload) + 5.4
			end
		end
	},
	{
		name = "module_rocketconservation",
		humanName = "Conservative Deployment",
		description = "Hold much of your rocket ammunition in reserve, granting you faster reload time. Reduces the number of rockets in a barrage by 2 but decreases reload by 0.8s. If you have heavy ordinance installed, decrease reload speed by 3s instead.\nArtillery exclusive. Mutually exclusive with Expanded Rocket Ammunition Storage.",
		image = moduleImagePath .. "module_rocketconservation.png",
		limit = 8,
		cost = 800 * COST_MULT,
		requireLevel = 8,
		slotType = "module",
		requireChassis = {"assault"},
		prohibitingModules = {"module_expandedrocketsalvo"},
		requireOneOf = {"commweapon_rocketbarrage"},
		applicationFunction = function (modules, sharedData)
			sharedData.conservativedeployments = (sharedData.conservativedeployments or 0) + 1
			if sharedData.weapon1 and sharedData.weapon1 == "commweapon_rocketbarrage" then
				local basereload = 7.2
				if sharedData.conservativedeployments%2 == 1 then
					sharedData.burstOverride1 = 12 - sharedData.conservativedeployments
					sharedData.burstRateOverride1 = 2/30
					sharedData.projectileOverride1 = 2
				else
					sharedData.burstOverride1 = 6 - (sharedData.conservativedeployments / 2)
					sharedData.burstRateOverride1 = 0.1
					sharedData.projectileOverride1 = 4
				end
				sharedData.reloadOverride1 = basereload - (0.8 * sharedData.conservativedeployments)
			elseif sharedData.weapon1 and sharedData.weapon1 == "commweapon_rocketbarrage_nuclear" then
				local basereload = 25
				sharedData.burstOverride1 = (sharedData.burstOverride1 or 30) - 2
				sharedData.reloadOverride1 = basereload - (3 * sharedData.conservativedeployments)
				sharedData.projectileOverride1 = 1
			end
			if sharedData.weapon2 and sharedData.weapon2 == "commweapon_rocketbarrage" then
				local basereload = 7.2
				if sharedData.conservativedeployments%2 == 1 then
					sharedData.burstOverride2 = 12 - sharedData.conservativedeployments
					sharedData.burstRateOverride2 = 2/30
					sharedData.projectileOverride2 = 2
				else
					sharedData.burstOverride2 = 6 - (sharedData.conservativedeployments / 2)
					sharedData.burstRateOverride2 = 0.1
					sharedData.projectileOverride2 = 4
				end
				sharedData.reloadOverride2 = basereload - (0.8 * sharedData.conservativedeployments)
			elseif sharedData.weapon2 and sharedData.weapon2 == "commweapon_rocketbarrage_nuclear" then
				local basereload = 25
				sharedData.burstOverride2 = (sharedData.burstOverride2 or 30) - 2
				sharedData.reloadOverride2 = basereload - (3 * sharedData.conservativedeployments)
				sharedData.projectileOverride2 = 1
			end
		end
	},
	{
		name = "module_autoloader",
		humanName = "Rapid Autoloader",
		description = "Increases reload speed by 50%. Reduces base damage by 12.5%. Burst Weapons (such as lightning guns or medium rifles) fire faster. Minimum 10% damage.\nGhost Exclusive.",
		image = moduleImagePath .. "module_reloader.png",
		limit = 4,
		cost = 800 * COST_MULT,
		requireLevel = 10,
		slotType = "module",
		requireChassis = {"strike"},
		prohibitingModules = {"module_alphastrike"},
		applicationFunction = function (modules, sharedData)
			-- Damage boost is applied via clone swapping
			--sharedData.damageMult = (sharedData.damageMult or 1) - 0.20
			--if sharedData.damageMult < 0.1 then sharedData.damageMult = 0.1 end
			if sharedData.weapon1 then
				sharedData.damageBooster1 = (sharedData.damageBooster1 or 0) - 0.125
				if sharedData.damageBooster1 < -0.95 then
					sharedData.damageBooster1 = -0.95
				end
			end
			if sharedData.weapon2 then
				sharedData.damageBooster2 = (sharedData.damageBooster2 or 0) - 0.125
				if sharedData.damageBooster2 < -0.95 then
					sharedData.damageBooster2 = -0.95
				end
			end
			sharedData.reloadBonus = (sharedData.reloadBonus or 0) + 0.5
			local changedWeapons = {
				["commweapon_lightninggun"] = 6,
				["commweapon_lightninggun_improved"] = 15,
				["commweapon_heavyrifle"] = 3,
				["commweapon_heavyrifle_disrupt"] = 3,
			}
			if sharedData.weapon1 and changedWeapons[sharedData.weapon1] then
				local burst = changedWeapons[sharedData.weapon1]
				local count = math.floor(sharedData.reloadBonus / 0.5)
				sharedData.burstRateOverride1 = math.max(burst * (1 - (count * 0.2)), 1) / 30
			end
			if sharedData.weapon2 and changedWeapons[sharedData.weapon2] then
				local burst = changedWeapons[sharedData.weapon2]
				local count = math.floor(sharedData.reloadBonus / 0.5)
				sharedData.burstRateOverride2 = math.max(burst * (1 - (count * 0.2)), 1) / 30
			end
		end
	},
	{
		name = "module_dmg_booster",
		humanName = "Enhanced Weapon Systems",
		description = "Increases damage by 10% but reduces speed by 1.",
		image = moduleImagePath .. "module_dmg_booster.png",
		--limit = 8, no limits, fw lategame has more crazier shit anyways
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"support", "assault", "recon", "knight", "strike"},
		applicationFunction = function (modules, sharedData)
			-- Damage boost is applied via clone swapping
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.1
			sharedData.speedMalus = (sharedData.speedMalus or 0) + 1
		end
	},
	{
		name = "module_striderpower",
		humanName = "Massive Weapons Relays",
		description = "Increases damage by 25%. Blocks access to Autorepair and grants access to strong powered modules. Commanders undertaking this should be considered strider level units.",
		image = moduleImagePath .. "module_energy_cell.png",
		limit = 1,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"riot"},
		prohibitingModules = {"module_autorepair"},
		applicationFunction = function (modules, sharedData)
			sharedData.speedMalus = (sharedData.speedMalus or 0) + 1.1
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.25
		end
	},
	{
		name = "module_high_power_servos_slow",
		humanName = "Additional Servos",
		description = "Increases speed by 1.5.",
		image = moduleImagePath .. "module_high_power_servos.png",
		limit = 8,
		cost = 200 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"riot", "assault"},
		applicationFunction = function (modules, sharedData)
			sharedData.speedMod = (sharedData.speedMod or 0) + 1.5
		end
	},
	{
		name = "module_malus_remover",
		humanName = "Load Reengineering Overhaul",
		description = "Removes 25% of all speed reductions from modules.",
		image = moduleImagePath .. "module_improved_servos.png",
		limit = 4,
		cost = 250 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.malusMult = math.max((sharedData.malusMult or 1) - 0.25, 0)
		end
	},
	{
		name = "module_high_power_servos",
		humanName = "Super Servos",
		description = "Increases speed by 2.5.",
		image = moduleImagePath .. "module_high_power_servos.png",
		limit = 8,
		cost = 150 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"strike", "support"},
		applicationFunction = function (modules, sharedData)
			sharedData.speedMod = (sharedData.speedMod or 0) + 2.5
		end
	},
	{
		name = "module_high_power_servos_extreme",
		humanName = "Recon Servos",
		description = "Increases speed by 3.25.",
		image = moduleImagePath .. "module_high_power_servos.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		requireChassis = {"recon"},
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.speedMod = (sharedData.speedMod or 0) + 3.25
		end
	},
	{
		name = "module_high_power_servos_improved",
		humanName = "Strike Servos",
		description = "Increases speed by 5, decreases health by " .. 500*HP_MULT,
		image = moduleImagePath .. "module_strike_servos.png",
		limit = 8,
		cost = 200 * COST_MULT,
		requireLevel = 3,
		slotType = "module",
		requireChassis = {"strike", "recon"},
		applicationFunction = function (modules, sharedData)
			sharedData.speedMod = (sharedData.speedMod or 0) + 5
			sharedData.healthBonus = (sharedData.healthBonus or 0) - 500*HP_MULT
		end
	},
	{
		name = "module_cloakregen",
		humanName = "Nanobot Sleeve",
		description = "Increases regen while cloaked by 20.",
		image = moduleImagePath .. "module_cloakregen.png",
		limit = 8,
		cost = 75 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"strike"},
		applicationFunction = function (modules, sharedData)
			sharedData.cloakregen = (sharedData.cloakregen or 0) + 20
		end
	},
	{
		name = "module_adv_targeting",
		humanName = "Adv. Targeting System",
		description = "Increases range by 7.5% but reduces speed by 0.75.",
		image = moduleImagePath .. "module_adv_targeting.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"strike", "recon", "support", "riot"},
		applicationFunction = function (modules, sharedData)
			sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.075
			sharedData.speedMalus = (sharedData.speedMalus or 0) + 0.75
		end
	},
	{
		name = "module_adv_targeting",
		humanName = "Improved Targeting System",
		description = "Increases range by 10% but reduces speed by 2.",
		image = moduleImagePath .. "module_adv_targeting.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"assault"},
		applicationFunction = function (modules, sharedData)
			sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.1
			sharedData.speedMalus = (sharedData.speedMalus or 0) + 2
		end
	},
	{
		name = "efficiency",
		humanName = "Efficient Resourcing",
		description = "By upgrading the Support comm's resource allocation algorithms, some extra metal and energy can be squeezed out of the chassis's resource generator.\nProvides 2.5m/sec and 5e/sec income",
		image = moduleImagePath .. "module_efficency.png",
		limit = 4,
		requireChassis = {"knight"},
		requireOneOf = {"econ"},
		cost = 100 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.metalIncome = (sharedData.metalIncome or 0) + 4
			sharedData.energyIncome = (sharedData.energyIncome or 0) + 6
		end
	},
	{
		name = "module_basic_nano",
		humanName = "Basic Nanolathe",
		description = "Increases build power by 1.5. Increases storage by 10.",
		image = moduleImagePath .. "module_adv_nano.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"assault", "riot"},
		applicationFunction = function (modules, sharedData)
			sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 1.5
			sharedData.extrastorage = (sharedData.extrastorage or 0) + 10
		end
	},
	{
		name = "module_adv_nano",
		humanName = "Advanced Nanolathe",
		description = "Increases build power by 2.5. Increases storage by 25.",
		image = moduleImagePath .. "module_adv_nano.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"strike", "recon"},
		applicationFunction = function (modules, sharedData)
			sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 2.5
			sharedData.extrastorage = (sharedData.extrastorage or 0) + 25
		end
	},
	{
		name = "module_adv_nano_support",
		humanName = "Superior Nanolathe",
		description = "Increases build power by 7.5. Increases storage by 75.",
		image = moduleImagePath .. "module_adv_nano.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"support"},
		applicationFunction = function (modules, sharedData)
			sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 7.5
			sharedData.extrastorage = (sharedData.extrastorage or 0) + 75
		end
	},
	{
		name = "module_recon_pulse",
		humanName = "Recon Pulse",
		description = "Adds a pulse that decloaks enemy cloaked units every 2 seconds. WARNING: DISABLES THE ABILITY TO CLOAK.\n- Range: 400\n- Does not trigger while airborn.",
		image = moduleImagePath .. "module_recon_pulse.png",
		limit = 1,
		cost = 350 * COST_MULT,
		requireLevel = 3,
		slotType = "module",
		requireChassis = {"recon"},
		prohibitingModules = {"module_personal_cloak"},
		applicationFunction = function (modules, sharedData)
			sharedData.reconPulse = 1
		end
	},
	
	-- Decorative Modules
	{
		name = "banner_overhead",
		humanName = "Banner",
		description = "",
		image = moduleImagePath .. "module_ablative_armor.png",
		limit = 1,
		cost = 0,
		requireChassis = {},
		requireLevel = 0,
		slotType = "decoration",
		applicationFunction = function (modules, sharedData)
			sharedData.bannerOverhead = true
		end
	},
}

for name, data in pairs(skinDefs) do
	moduleDefs[#moduleDefs + 1] = {
		name = "skin_" .. name,
		humanName = data.humanName,
		description = data.humanName,
		image = moduleImagePath .. "module_ablative_armor.png",
		limit = 1,
		cost = 0,
		requireChassis = {data.chassis},
		requireLevel = 0,
		slotType = "decoration",
		isDeco = true,
		applicationFunction = function (modules, sharedData)
			sharedData.skinOverride = name
		end
	}
end

for i = 1, #moduleDefs do
	if moduleDefs[i].name == "efficiency" and allowCommEco then
		moduleDefs[i].requireChassis[2] = "support"
	end
	moduleDefNames[moduleDefs[i].name] = i
end

------------------------------------------------------------------------
-- Chassis Definitions
------------------------------------------------------------------------

-- it'd help if there was a name -> chassisDef map you know

--------------------------------------------------------------------------------------
-- Must match staticomms.lua around line 250 (MakeCommanderChassisClones)
--------------------------------------------------------------------------------------
-- A note on personal shield and area shield:
-- The personal shield weapon is replaced by the area shield weapon in moduledefs.lua.
-- Therefore the clonedef with an area shield and no personal shield does not actually
-- have an area shield. This means that the below functions return the correct values,
-- if a commander has a an area shield and a personal shield it should return the
-- clone which was given those modules.

local function GetReconCloneModulesString(modulesByDefID)
	return (modulesByDefID[moduleDefNames.commweapon_personal_shield] or 0)
end

local function GetSupportCloneModulesString(modulesByDefID)
	return (modulesByDefID[moduleDefNames.commweapon_personal_shield] or 0) ..
		(modulesByDefID[moduleDefNames.commweapon_areashield] or 0) ..
		(modulesByDefID[moduleDefNames.module_resurrect] or 0)
end

local function GetAssaultCloneModulesString(modulesByDefID)
	return (modulesByDefID[moduleDefNames.commweapon_personal_shield] or 0) ..
		(modulesByDefID[moduleDefNames.commweapon_areashield] or 0)
end

local function GetRiotCloneModulesString(modulesByDefID)
	return (modulesByDefID[moduleDefNames.commweapon_personal_shield] or 0) ..
		(modulesByDefID[moduleDefNames.commweapon_areashield] or 0)
end

local function GetStrikeCloneModulesString(modulesByDefID)
	return (modulesByDefID[moduleDefNames.commweapon_personal_shield] or 0) ..
		(modulesByDefID[moduleDefNames.commweapon_areashield] or 0)
end

local function GetKnightCloneModulesString(modulesByDefID)
	return (modulesByDefID[moduleDefNames.commweapon_personal_shield] or 0) ..
		(modulesByDefID[moduleDefNames.commweapon_areashield] or 0) ..
		(modulesByDefID[moduleDefNames.module_resurrect] or 0) ..
		(modulesByDefID[moduleDefNames.module_jumpjet] or 0)
end

local maxCommLevel = 10  -- not really max, but the point where freebies stop
local morphCosts = {}

-- assign costs for levels that exceed the table above
local function extraLevelCostFunction(level)
	return math.max(300, level * 25 + 50) * COST_MULT
end

-- fill out the table using the function, which is strange, but works with existing code assumptions
for level = 1, maxCommLevel do
	morphCosts[level] = extraLevelCostFunction(level)
end

-- generate the verbose, repetitive structures that define properties of dynamic commanders at various levels
-- these were (apparently) designed to be extremely flexible, but that flexibility wasn't used, so they were just complex
-- by generating this structure dynamically, we simplify but leave other parts of the code alone
local function levelDefGenerator(commname, cloneModulesStringFunc, weapon2Level)
	local res = {
		[0] = {
			morphBuildPower = 10,
			morphBaseCost = 0,
			morphUnitDefFunction = function(modulesByDefID)
				return UnitDefNames[commname .. "0"].id
			end,
			upgradeSlots = {},
		}
	}
	local bpmult = 1
	if commwars then
		bpmult = 2
	end
	for i = 1, maxCommLevel do
		--Spring.Echo("Do idx " .. i .. " for comm " .. commname .. ".")
		res[i] = {
			morphBuildPower = 10 + math.ceil(i/2)*5 * bpmult,
			morphBaseCost = morphCosts[i],
			morphUnitDefFunction = function(modulesByDefID)
				local oneUnitDefName = commname .. math.ceil(i/2) .. "_" .. cloneModulesStringFunc(modulesByDefID)
				--Spring.Echo("Get ID of unit def by name: " .. oneUnitDefName .. ".")
				return UnitDefNames[oneUnitDefName].id
			end
		}

		if i < 3 then
			res[i].upgradeSlots = {
				{
					defaultModule = moduleDefNames.nullmodule,
					slotAllows = "module",
				},
				{
					defaultModule = moduleDefNames.nullmodule,
					slotAllows = "module",
				},
			}
		else
			res[i].upgradeSlots = {
				{
					defaultModule = moduleDefNames.nullmodule,
					slotAllows = "module",
				},
				{
					defaultModule = moduleDefNames.nullmodule,
					slotAllows = "module",
				},
				{
					defaultModule = moduleDefNames.nullmodule,
					slotAllows = "module",
				},
			}
		end
	end

	-- mark slots for weapons
	res[1].upgradeSlots[1] = {
		defaultModule = moduleDefNames.commweapon_beamlaser,
		slotAllows = "basic_weapon",
	}
	res[weapon2Level].upgradeSlots[1] = {
		defaultModule = moduleDefNames.commweapon_beamlaser,
		slotAllows = {"adv_weapon", "basic_weapon"},
	}

	return res
end

-- data structure that defines properties of dynamic comms for each level in which they have distinct properties
local chassisDefs = {
	{
		name = "strike",
		humanName = "Ghost",
		baseUnitDef = UnitDefNames and UnitDefNames["dynstrike0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = maxCommLevel,
		secondPeashooter = true,
		chassisApplicationFunction = function (level, modules, sharedData)
			-- level expected to be 1 less than the value the player sees
			--Spring.Echo("Apply level-up function to Ambusher lvl " .. (level+1) .. ".")
			if level > 1 then
				-- hit points (in terms of player-visible level) was 1=4200, 2=4200, 3=4000, 3=5000 ....
				-- (a change is now made over in dynstrike.lua to reduce the first levels to 3000)
				sharedData.healthBonus = (sharedData.healthBonus or 0) + 1000 * (level - 1)
			end
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
			sharedData.decloakDistance = 200 - 20 * math.min(level,6)
			sharedData.cloakregen = (sharedData.cloakregen or 0) + 10 * (level + 1)
			sharedData.personalCloak = true -- !!FREE!! cloak
			sharedData.speedMod = (sharedData.speedMod or 0) + 2
			sharedData.recloaktime = (sharedData.recloaktime or 300) - 30 * math.min(level,6)
		end,
		levelDefs = levelDefGenerator("dynstrike", GetStrikeCloneModulesString, 3)
	},
	{
		name = "recon",
		humanName = "Recon",
		baseUnitDef = UnitDefNames and UnitDefNames["dynrecon0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = maxCommLevel,
		chassisApplicationFunction = function (level, modules, sharedData)
			-- level expected to be 1 less than the value the player sees
			--Spring.Echo("Apply level-up function to Recon lvl " .. (level+1) .. ".")
			if level > 1 then
				-- hit points (in terms of player-visible level) was 1=3250, 2=3250, 3=4000, 3=4750 ....
				sharedData.healthBonus = (sharedData.healthBonus or 0) + 1000 * (level - 1)
				sharedData.jumpspeedbonus = (sharedData.jumpspeedbonus or 0) + 0.1 * (level - 1)
				sharedData.jumprangebonus = (sharedData.jumprangebonus or 0) + 0.025 * (level - 1)
			end
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
			sharedData.speedMod = (sharedData.speedMod or 0) + 7.5 + 3 * level
		end,
		levelDefs = levelDefGenerator("dynrecon", GetReconCloneModulesString, 3)
	},
	{
		name = "support",
		humanName = "Support",
		baseUnitDef = UnitDefNames and UnitDefNames["dynsupport0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = maxCommLevel,
		chassisApplicationFunction = function (level, modules, sharedData)
			-- level expected to be 1 less than the value the player sees
			--Spring.Echo("Apply level-up function to Support lvl " .. (level+1) .. ".")
			if level > 1 then
				-- hit points (in terms of player-visible level) was 1=3800, 2=3800, 3=4750, 3=5250 ....
				sharedData.healthBonus = (sharedData.healthBonus or 0) + 250 + 750 * (level - 1)
			end
			sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 5 * level
			sharedData.extrastorage = (sharedData.extrastorage or 0) + 200 + (200 * level)
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 2.5
		end,
		levelDefs = levelDefGenerator("dynsupport", GetSupportCloneModulesString, 3)
	},
	{
		name = "assault",
		humanName = "Bombard",
		baseUnitDef = UnitDefNames and UnitDefNames["dynassault0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = maxCommLevel,
		secondPeashooter = true,
		chassisApplicationFunction = function (level, modules, sharedData)
			-- level expected to be 1 less than the value the player sees
			--Spring.Echo("Apply level-up function to Bombard lvl " .. (level+1) .. ".")
			if level > 1 then
				-- hit points (in terms of player-visible level) was 1=4400, 2=4400, 3=3000, 4=3750, 5=4500 ....
				-- (a change is now made over in dynassault.lua to reduce the first levels to 2250)
				sharedData.healthBonus = (sharedData.healthBonus or 0) + 500 * (level - 1)
			end
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 2.5
			sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.075 * (level + 1)
		end,
		levelDefs = levelDefGenerator("dynassault", GetAssaultCloneModulesString, 3)
	},
	{
		name = "riot",
		humanName = "Riot",
		baseUnitDef = UnitDefNames and UnitDefNames["dynriot0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = maxCommLevel,
		secondPeashooter = true,
		chassisApplicationFunction = function (level, modules, sharedData)
			-- level expected to be 1 less than the value the player sees
			--Spring.Echo("Apply level-up function to Riot (comm) lvl " .. (level+1) .. ".")
			if level > 1 then
				-- hit points (in terms of player-visible level) was 1=5500, 2=5500, 3=7500, 3=9000, 4=10500 ....
				sharedData.healthBonus = (sharedData.healthBonus or 0) + 1000 + 1750 * (level - 1)
			end
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 10 * level
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.125 * (level + 1)
		end,
		levelDefs = levelDefGenerator("dynriot", GetRiotCloneModulesString, 2)
	},
	{
		name = "knight",
		humanName = "Knight",
		baseUnitDef = UnitDefNames and UnitDefNames["dynknight0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = maxCommLevel,
		notSelectable = (Spring.GetModOptions().campaign_chassis ~= "1"),
		secondPeashooter = true,
		chassisApplicationFunction = function (level, modules, sharedData)
			-- level expected to be 1 less than the value the player sees
			--Spring.Echo("Apply level-up function to Knight (comm) lvl " .. (level+1) .. ".")
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 1200 + 600 * level    -- 2=4600, 3=5200, 4=5800
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
		end,
		levelDefs = levelDefGenerator("dynknight", GetKnightCloneModulesString, 3)
	},
}

local chassisDefByBaseDef = {}
if UnitDefNames then
	for i = 1, #chassisDefs do
		chassisDefByBaseDef[chassisDefs[i].baseUnitDef] = i
	end
end

local chassisDefNames = {}
for i = 1, #chassisDefs do
	chassisDefNames[chassisDefs[i].name] = i
end

------------------------------------------------------------------------
-- Processing
------------------------------------------------------------------------

for i = 1, #moduleDefs do -- Add name, cost, dps, etc
	if not moduleDefs[i].isDeco then -- IMPORTANT NOTE: This is proccessed **BEFORE** weapondefs_post!!!!!!! (Mitä vitua?)
		local name = moduleDefs[i].name
		if moduleDefs[i].override then
			name = moduleDefs[i].override
		end
		--Spring.Echo("[Modular Comms] ModuleDefs: Proccessing description for " .. tostring(name))
		moduleDefs[i].description = moduleDefs[i].humanName ..":\nCost: " .. moduleDefs[i].cost .. "m" .. "\n" .. moduleDefs[i].description
		local wd
		if name:find("commweapon") or name:find("shield") then
			if VFS.FileExists("gamedata\\modularcomms\\weapons\\" .. name .. ".lua") then
				--Spring.Echo("Loading future wars file")
				_, wd = VFS.Include("gamedata\\modularcomms\\weapons\\" .. name .. ".lua")
			elseif VFS.FileExists("gamedata\\modularcomms\\weapons\\" .. name:gsub("commweapon_", "") .. ".lua") then
				--Spring.Echo("Falling back to base game")
				_, wd = VFS.Include("gamedata\\modularcomms\\weapons\\" .. name:gsub("commweapon_", "") .. ".lua")
			end
			--if VFS.FileExists("gamedata\\modularcomms\\weapons\\" .. string.gsub(name:gsub("commweapon_", ""), "_", "") .. ".lua") then
				--_, wd = VFS.Include("gamedata\\modularcomms\\weapons\\" .. string.gsub(name:gsub("commweapon_", ""), "_", "") .. ".lua")
			--end
		end
		if wd and not name:find("shield") then
			local projectiles = wd.projectiles or 1
			local burst = wd.burst or 1
			local damage = wd.damage.default * burst * projectiles
			--Spring.Echo("Calculate DPS: " .. projectiles .. "projectiles, " .. burst .. " bursts, " .. tostring(wd.damage.default) .. " damage = " .. damage .. ", Reload: " .. wd.reloadtime)
			local customparams = wd.customParams or wd.customparams or {}
			moduleDefs[i].description = moduleDefs[i].description .. "\n\255\255\061\061Weapon Notes:\n\255\255\255\031- Range:\255\255\255\255 " .. wd.range .. "\n\255\255\255\031- DPS:\255\255\255\255 "
			if customparams.extra_damage_mult then -- lightning gun
				local extradmg = tonumber(customparams.extra_damage_mult) or 0
				local extradps = (extradmg * damage) / wd.reloadtime
				extradps = "\255\51\179\255" .. string.format("%.1f", extradps) .. "P\255\255\255\255"
				moduleDefs[i].description = moduleDefs[i].description .. "\255\255\255\255 " .. string.format("%.1f", damage / wd.reloadtime) .. " + " .. extradps
			elseif customparams.is_capture then -- capture
				moduleDefs[i].description = moduleDefs[i].description .. "\255\153\255\153 " .. string.format("%.1f", damage / wd.reloadtime) .. "C"
			elseif customparams.setunitsonfire then -- napalm
				local burntime = tonumber(customparams.burntime) or 0
				burntime = burntime / 30 -- convert to seconds
				moduleDefs[i].description = moduleDefs[i].description .. "\255\255\77\0 " .. string.format("%.1f", damage / wd.reloadtime) .. " (" .. string.format("%.1f", burntime) .. "s)"
			elseif customparams.disarmDamageOnly or customparams.disarmdamageonly then -- pure disarm damage.
				moduleDefs[i].description = moduleDefs[i].description .. "\255\128\128\128" .. string.format("%.1f", damage / wd.reloadtime) .. "D"
			elseif wd.paralyzeTime == nil and wd.paralyzetime == nil then -- normal weapon
				moduleDefs[i].description = moduleDefs[i].description .. "\255\255\255\255 " .. string.format("%.1f", damage / wd.reloadtime)
			else -- pure paralyzer
				moduleDefs[i].description = moduleDefs[i].description .. "\255\51\179\255 " .. string.format("%.1f", damage / wd.reloadtime) .. "P"
			end
			local isDisarmOnly = customparams.disarmDamageOnly or customparams.disarmdamageonly or 0
			if (customparams.disarmDamageMult or customparams.disarmdamagemult) and isDisarmOnly == 0 then
				local disarm = (customparams.disarmDamageMult or customparams.disarmdamagemult) or 0
				local disarmdps = (damage * tonumber(disarm)) / wd.reloadtime
				if disarmdps > 0 then
					disarmdps = "\255\128\128\128" .. string.format("%.1f", disarmdps) .. "D"
					moduleDefs[i].description = moduleDefs[i].description .. " + " .. disarmdps
				end
			end
			if customparams.timeslow_damagefactor then
				local slow = damage * (tonumber(customparams.timeslow_damagefactor) or 0)
				if slow > 0 then
					local slowdps = string.format("%.1f", slow / wd.reloadtime)
					moduleDefs[i].description = moduleDefs[i].description .. " + \255\255\031\255" .. slowdps .. "S" .. "\255\255\255\255"
				end
			end
			if wd.paralyzeTime or wd.paralyzetime then
				local stuntime = wd.paralyzeTime or wd.paralyzetime or 0
				if stuntime ~= 0 then
					moduleDefs[i].description = moduleDefs[i].description .. "\n\255\255\255\031- Stun time:\255\255\255\255" .. stuntime .. "s"
				end
			end
			if not (wd.impactonly or wd.impactOnly) then
				local aoe = customparams.areaofeffectoverride or wd.areaOfEffect or wd.areaofeffect
				moduleDefs[i].description = moduleDefs[i].description .. "\n\255\255\255\031- AoE:\255\255\255\255 " .. aoe .. "m"
			end
			if wd.waterweapon or wd.waterWeapon then
				moduleDefs[i].description = moduleDefs[i].description .. "\n\255\255\255\031- \255\031\255\255WATER CAPABLE\255\255\255\255"
			end
		elseif wd and name:find("shield") then
			moduleDefs[i].description = moduleDefs[i].description .. "\n\255\255\255\031Shield Radius:\255\255\255\255 " .. wd.shieldRadius .. "\n\255\255\255\031Shield HP:\255\255\255\255 " .. wd.shieldPower .. "\n\255\255\255\031Shield Regen:\255\255\255\255 " .. wd.shieldPowerRegen .. "\n\255\255\255\031Shield Regen Cost:\255\255\255\255 " .. wd.shieldPowerRegenEnergy
		elseif not name:find("null") then
			moduleDefs[i].description = moduleDefs[i].description .. "\n\255\255\061\061Limit: " .. tostring(moduleDefs[i].limit) .. "\255\255\255\255" -- why does this have a boolean?
		end
		if disabledModules[name] then
			moduleDefs[i].requireChassis = {"banned"}
		end
		--Spring.Echo("Final description: " .. moduleDefs[i].description)
	end
end

-- Transform from human readable format into number indexed format
for i = 1, #moduleDefs do
	local data = moduleDefs[i]
	
	-- Required modules are a list of moduleDefIDs
	for _,list in pairs{"requireOneOf", "requireTwoOf", "prohibitingModules"} do
		if data[list] then
			local newRequire = {}
			for j = 1, #data[list] do
				local reqModuleID = moduleDefNames[data[list][j]]
				if reqModuleID then
					newRequire[#newRequire + 1] = reqModuleID
				end
			end
			data[list] = newRequire
		end
	end
	
	-- Required chassis is a map indexed by chassisDefID
	if data.requireChassis then
		local newRequire = {}
		for j = 1, #data.requireChassis do
			for k = 1, #chassisDefs do
				if chassisDefs[k].name == data.requireChassis[j] then
					newRequire[k] = true
					break
				end
			end
		end
		data.requireChassis = newRequire
	end
end

-- Find empty modules so slots can find their appropriate empty module
local emptyModules = {}
for i = 1, #moduleDefs do
	if moduleDefs[i].emptyModule then
		emptyModules[moduleDefs[i].slotType] = i
	end
end

-- Process slotAllows into a table of keys
for i = 1, #chassisDefs do
	for j = 0, #chassisDefs[i].levelDefs do
		local levelData = chassisDefs[i].levelDefs[j]
		for k = 1, #levelData.upgradeSlots do
			local slotData = levelData.upgradeSlots[k]
			if type(slotData.slotAllows) == "string" then
				slotData.empty = emptyModules[slotData.slotAllows]
				slotData.slotAllows = {[slotData.slotAllows] = true}
			else
				local newSlotAllows = {}
				slotData.empty = emptyModules[slotData.slotAllows[1]]
				for m = 1, #slotData.slotAllows do
					newSlotAllows[slotData.slotAllows[m]] = true
				end
				slotData.slotAllows = newSlotAllows
			end
		end
	end
end

-- Add baseWreckID and baseHeapID
if UnitDefNames then
	for i = 1, #chassisDefs do
		local data = chassisDefs[i]
		local wreckData = FeatureDefNames[UnitDefs[data.baseUnitDef].wreckName]

		data.baseWreckID = wreckData.id
		data.baseHeapID = wreckData.deathFeatureID
	end
end

------------------------------------------------------------------------
-- Utility Functions
------------------------------------------------------------------------

local function CountModulesInSet(set, owned, owned2)
	local count = 0
	for i = 1, #set do
		local req = set[i]
		count = count + (owned[req] or 0)
		              + (owned2 and owned2[req] or 0)
	end
	return count
end

local function ModuleIsValid(level, chassis, slotAllows, moduleDefID, alreadyOwned, alreadyOwned2)
	local data = moduleDefs[moduleDefID]
	if (not slotAllows[data.slotType]) or (data.requireLevel or 0) > level or
			(data.requireChassis and (not data.requireChassis[chassis])) or data.unequipable then
		return false
	end
	
	-- Check that requirements are met
	if data.requireOneOf and CountModulesInSet(data.requireOneOf, alreadyOwned, alreadyOwned2) < 1 then
		return false
	end
	if data.requireTwoOf and CountModulesInSet(data.requireTwoOf, alreadyOwned, alreadyOwned2) < 2 then
		return false
	end
	
	-- Check that nothing prohibits this module
	if data.prohibitingModules and CountModulesInSet(data.prohibitingModules, alreadyOwned, alreadyOwned2) > 0 then
		return false
	end

	-- cheapass hack to prevent cremcom dual wielding same weapon (not supported atm)
	-- proper solution: make the second instance of a weapon apply projectiles x2 or reloadtime x0.5 and get cremcoms unit script to work with that
	local limit = data.limit
	--Spring.Echo("Chassis: " .. chassis .. ", Module: " .. data.humanName)
	--Spring.Echo("Limit: " .. tostring(limit))
	if chassis == 6 and data.slotType == "basic_weapon" and limit == 2 then
		limit = 1
		--Spring.Echo("Limited to 1")
	end

	-- Check that the module limit is not reached
	if limit and (alreadyOwned[moduleDefID] or (alreadyOwned2 and alreadyOwned2[moduleDefID])) then
		local count = (alreadyOwned[moduleDefID] or 0) + ((alreadyOwned2 and alreadyOwned2[moduleDefID]) or 0)
		--Spring.Echo("Count: " .. count)
		if count > limit then
			return false
		end
	end
	return true
end

local function ModuleSetsAreIdentical(set1, set2)
	-- Sets should be sorted prior to this function
	if (not set1) or (not set2) or (#set1 ~= #set2) then
		return false
	end

	local validUnit = true
	for i = 1, #set1 do
		if set1[i] ~= set2[i] then
			return false
		end
	end
	return true
end

local function ModuleListToByDefID(moduleList)
	local byDefID = {}
	for i = 1, #moduleList do
		local defID = moduleList[i]
		byDefID[defID] = (byDefID[defID] or 0) + 1
	end
	return byDefID
end

local function GetUnitDefShield(unitDefNameOrID, shieldName)
	local unitDefID = (type(unitDefNameOrID) == "string" and UnitDefNames[unitDefNameOrID].id) or unitDefNameOrID
	local wepTable = UnitDefs[unitDefID].weapons
	for num = 1, #wepTable do
		local wd = WeaponDefs[wepTable[num].weaponDef]
		if wd.type == "Shield" then
			local weaponName = string.sub(wd.name, (string.find(wd.name,"commweapon") or 0), 100)
			if weaponName == shieldName then
				return wd.id, num
			end
		end
	end
end

local utilities = {
	ModuleIsValid          = ModuleIsValid,
	ModuleSetsAreIdentical = ModuleSetsAreIdentical,
	ModuleListToByDefID    = ModuleListToByDefID,
	GetUnitDefShield       = GetUnitDefShield
}

------------------------------------------------------------------------
-- Return Values
------------------------------------------------------------------------

return moduleDefs, chassisDefs, utilities, LEVEL_BOUND, chassisDefByBaseDef, moduleDefNames, chassisDefNames
