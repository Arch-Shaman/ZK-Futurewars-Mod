-- mission editor compatibility
Spring.GetModOptions = Spring.GetModOptions or function() return {} end

local skinDefs
local SKIN_FILE = "LuaRules/Configs/dynamic_comm_skins.lua"
if VFS.FileExists(SKIN_FILE) then
	skinDefs = VFS.Include(SKIN_FILE)
else
	skinDefs = {}
end

local LEVEL_BOUND = math.floor(tonumber(Spring.GetModOptions().max_com_level or 0))
if LEVEL_BOUND <= 0 then
	LEVEL_BOUND = nil -- unlimited
else
	LEVEL_BOUND = LEVEL_BOUND - 1 -- UI counts from 1 but internals count from 0
end

local COST_MULT = 1
local HP_MULT = 1

if (Spring.GetModOptions) then
	local modOptions = Spring.GetModOptions()
    if modOptions then
        if modOptions.hpmult and modOptions.hpmult ~= 1 then
            HP_MULT = modOptions.hpmult
        end
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

local moduleDefNames = {}

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
		name = "nullbasicweapon",
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
		name = "nulladvweapon",
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
		humanName = "Flamethrower",
		description = "Good for deep-frying swarmers and large targets alike",
		image = moduleImagePath .. "commweapon_flamethrower.png",
		limit = 2,
		cost = 50 * COST_MULT,
		requireChassis = {"recon", "riot", "knight"},
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
		name = "commweapon_heatray",
		humanName = "Heatray",
		description = "Rapidly melts anything at short range; steadily loses all of its damage over distance",
		image = moduleImagePath .. "commweapon_heatray.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"assault", "knight"},
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
		cost = 50 * COST_MULT,
		requireChassis = {"riot", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			if sharedData.noMoreWeapons then
				return
			end
			local weaponName = (modules[moduleDefNames.conversion_disruptor] and "commweapon_heavymachinegun_disrupt") or "commweapon_heavymachinegun"
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
		description = "Extremely hard hitting, low fire rate antiheavy cannon.",
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
			local weaponName = (modules[moduleDefNames.weaponmod_napalm_warhead] and "commweapon_artillery_heavy_napalm") or "commweapon_artillery_heavy"
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
		requireChassis = {"support", "recon", "knight"},
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
		name = "commweapon_riotcannon",
		humanName = "Riot Cannon",
		description = "The weapon of choice for crowd control",
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
			local weaponName = (modules[moduleDefNames.weaponmod_napalm_warhead] and "commweapon_riotcannon_napalm") or "commweapon_riotcannon"
			if not sharedData.weapon1 then
				sharedData.weapon1 = weaponName
			else
				sharedData.weapon2 = weaponName
			end
		end
	},
	{
		name = "commweapon_rocketlauncher",
		humanName = "Multiple Light Rocket Launcher",
		description = "Long range, indirect area bombardment. Spreads its DPS across a small area.",
		image = moduleImagePath .. "commweapon_rocketlauncher.png",
		limit = 2,
		cost = 75 * COST_MULT,
		requireChassis = {"assault", "knight"},
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
		requireChassis = {"recon", "strike", "knight"},
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
		image = moduleImagePath .. "commweapon_canister.png",
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
		requireLevel = 3,
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
		cost = 400 * COST_MULT,
		requireChassis = {"strike", "knight"},
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
		description = "Manually fired weapon that ruin's a single target's day with a high damage shot. Quick reload.",
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
		name = "commweapon_slamrocket",
		humanName = "S.L.A.M. Rocket",
		description = "Manually fired miniature tactical nuke.",
		image = moduleImagePath .. "commweapon_slamrocket.png",
		limit = 1,
		cost = 200 * COST_MULT,
		requireChassis = {"assault", "knight"},
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
			sharedData.metalIncome = (sharedData.metalIncome or 0) + 4
			sharedData.energyIncome = (sharedData.energyIncome or 0) + 6
		end
	},
	{
		name = "efficiency",
		humanName = "Efficient Resourcing",
		description = "By upgrading the Support comm's resource allocation algorithms, some extra metal and energy can be squeezed out of the chassis's resource generator.\nProvides 1.5m/sec and 3e/sec income",
		image = moduleImagePath .. "module_efficency.png",
		limit = 4,
		requireChassis = {"support"},
		cost = 125 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.metalIncome = (sharedData.metalIncome or 0) + 1.5
			sharedData.energyIncome = (sharedData.energyIncome or 0) + 3
		end
	},
	{
		name = "commweapon_personal_shield",
		humanName = "Personal Shield",
		description = "A small, protective bubble shield.\nMutually Exclusive with Area Jammer and Personal Cloak.",
		image = moduleImagePath .. "module_personal_shield.png",
		limit = 1,
		cost = 300 * COST_MULT,
		prohibitingModules = {"module_personal_cloak", "module_jammer"},
		requireChassis = {"support", "recon", "assault", "knight"},
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
		cost = 250 * COST_MULT,
		requireChassis = {"assault", "support", "knight"},
		requireOneOf = {"commweapon_personal_shield"},
		prohibitingModules = {"module_personal_cloak", "module_jammer"},
		requireLevel = 3,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.shield = "commweapon_areashield"
		end
	},
	{
		name = "weaponmod_napalm_warhead",
		humanName = "Napalm Warhead",
		description = "Riot Cannon and Rocket Launcher set targets on fire. Reduced direct damage.",
		image = moduleImagePath .. "weaponmod_napalm_warhead.png",
		limit = 1,
		cost = 350 * COST_MULT,
		requireChassis = {"assault", "knight"},
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
		requireOneOf = {"commweapon_heavymachinegun", "commweapon_heavyrifle", "commweapon_tankbuster", "commweapon_emg", "commweapon_shotgun", "commweapon_hparticlebeam", "commweapon_lparticlebeam"},
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
		cost = 500 * COST_MULT,
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
		humanName = "Lazarus Device",
		description = "Upgrade nanolathe to allow resurrection.",
		image = moduleImagePath .. "module_resurrect.png",
		limit = 1,
		cost = 400 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.canResurrect = true
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
		description = "Mutually Assured Destruction guaranteed or your metal back!\n\nIncreases the severity of the commander death explosion. At maximum level, it is equivalent to a nuclear detonation.",
		image = moduleImagePath .. "module_detpack.png",
		limit = 3,
		cost = 600 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			local detpacklv = (sharedData.detpacklv or 0) + 1
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
		cost = 200 * COST_MULT,
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
		description = "Adds a protective drone.",
		image = moduleImagePath .. "module_companion_drone.png",
		limit = 8,
		cost = 50 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.drones = (sharedData.drones or 0) + 1
		end
	},
	{
		name = "module_battle_drone",
		humanName = "Battle Drone",
		description = "Commander spawns a heavy drone.",
		image = moduleImagePath .. "module_battle_drone.png",
		limit = 8,
		cost = 125 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireOneOf = {"module_companion_drone"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.droneheavyslows = (sharedData.droneheavyslows or 0) + 1
		end
	},
	{
		name = "module_autorepair",
		humanName = "Damage Control Systems",
		description = "Commander self-repairs at +10 hp/s. Reduces Health by " .. 75*HP_MULT,
		image = moduleImagePath .. "module_autorepair.png",
		limit = 8,
		cost = 150 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 10
			sharedData.healthBonus = (sharedData.healthBonus or 0) - 75*HP_MULT
		end
	},
	{
		name = "module_ablative_armor",
		humanName = "Ablative Armour Plates",
		description = "Provides " .. 1250*HP_MULT .. " health.",
		image = moduleImagePath .. "module_ablative_armor.png",
		limit = 8,
		cost = 150 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 1250*HP_MULT
		end
	},
	{
		name = "module_heavy_armor",
		humanName = "High Density Plating",
		description = "Provides " .. 3000*HP_MULT .. " health but reduces speed by 1.\nRiot Commander exclusive.",
		image = moduleImagePath .. "module_heavy_armor.png",
		limit = 8,
		cost = 200 * COST_MULT,
		requireOneOf = {"module_ablative_armor"},
		requireChassis = {"riot"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 3000*HP_MULT
			sharedData.speedMod = (sharedData.speedMod or 0) - 1
		end
	},
	{
		name = "module_dmg_booster_adv",
		humanName = "Weapon Retrofits",
		description = "Provides a 12.5% boost in firepower. Increases HP by " .. 200*HP_MULT ..	". Decreases speed by 0.75.\nRiot Exclusive.",
		image = moduleImagePath .. "module_dmg_booster.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 4,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			-- Damage boost is applied via clone swapping
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.125
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 200*HP_MULT
			sharedData.speedMod = (sharedData.speedMod or 0) - 0.75
		end
	},
	{
		name = "module_dmg_booster",
		humanName = "Enhanced Weapon Systems",
		description = "Increases damage by 10% but reduces speed by 0.75.",
		image = moduleImagePath .. "module_dmg_booster.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			-- Damage boost is applied via clone swapping
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.1
			sharedData.speedMod = (sharedData.speedMod or 0) - 0.75
		end
	},
	{
		name = "module_high_power_servos",
		humanName = "High Power Servos",
		description = "Increases speed by 2.2.",
		image = moduleImagePath .. "module_high_power_servos.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.speedMod = (sharedData.speedMod or 0) + 2.2
		end
	},
	{
		name = "module_high_power_servos_improved",
		humanName = "Strike Servos",
		description = "Increases speed by 4, decreases health by " .. 275*HP_MULT,
		image = moduleImagePath .. "module_strike_servos.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"strike", "recon"},
		applicationFunction = function (modules, sharedData)
			sharedData.speedMod = (sharedData.speedMod or 0) + 4
			sharedData.healthBonus = (sharedData.healthBonus or 0) - 275*HP_MULT
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
			sharedData.speedMod = (sharedData.speedMod or 0) - 0.75
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
			sharedData.speedMod = (sharedData.speedMod or 0) - 2
		end
	},
	{
		name = "module_adv_nano",
		humanName = "Advanced Nanolathe",
		description = "Increases build power by 2.5 (+5 for support). Increases storage by 25 (50 for support).",
		image = moduleImagePath .. "module_adv_nano.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"assault", "strike", "recon"},
		applicationFunction = function (modules, sharedData)
			sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 2.5
			sharedData.extrastorage = (sharedData.extrastorage or 0) + 25
		end
	},
	{
		name = "module_adv_nano_support",
		humanName = "Advanced Nanolathe",
		description = "Increases build power by 5 (+2.5 for others). Increases storage by 50 (25 for others).",
		image = moduleImagePath .. "module_adv_nano.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"support"},
		applicationFunction = function (modules, sharedData)
			sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 5
			sharedData.extrastorage = (sharedData.extrastorage or 0) + 50
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
	}
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

local morphCosts = {
	75,
	100,
	125,
	150,
	175,
}

local function extraLevelCostFunction(level)
	return math.max(300, level * 25 + 50) * COST_MULT
end

local chassisDefs = {
	{
		name = "strike",
		humanName = "Ambusher",
		baseUnitDef = UnitDefNames and UnitDefNames["dynstrike0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = 5,
		secondPeashooter = true,
		levelDefs = {
			[0] = {
				morphBuildPower = 10,
				morphBaseCost = 0,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.decloakDistance = 200
					sharedData.cloakregen = (sharedData.cloakregen or 0) + 10
					sharedData.personalCloak = true -- !!FREE!! cloak
					sharedData.speedMod = (sharedData.speedMod or 0) + 2
					sharedData.recloaktime = (sharedData.recloaktime or 300)
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynstrike0"].id
				end,
				upgradeSlots = {},
			},
			[1] = {
				morphBuildPower = 10,
				morphBaseCost = morphCosts[1],
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.decloakDistance = 180
					sharedData.cloakregen = (sharedData.cloakregen or 0) + 20
					sharedData.speedMod = (sharedData.speedMod or 0) + 2
					sharedData.recloaktime = (sharedData.recloaktime or 300) - 30
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynstrike1_" .. GetStrikeCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = "basic_weapon",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[2] = {
				morphBuildPower = 15,
				morphBaseCost = morphCosts[2] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.decloakDistance = 160
					sharedData.cloakregen = (sharedData.cloakregen or 0) + 30
					sharedData.speedMod = (sharedData.speedMod or 0) + 2
					sharedData.recloaktime = (sharedData.recloaktime or 300) - 60
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynstrike2_" .. GetStrikeCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[3] = {
				morphBuildPower = 20,
				morphBaseCost = morphCosts[3] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.decloakDistance = 140
					sharedData.cloakregen = (sharedData.cloakregen or 0) + 40
					sharedData.speedMod = (sharedData.speedMod or 0) + 2
					sharedData.recloaktime = (sharedData.recloaktime or 300) - 90
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynstrike3_" .. GetStrikeCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = {"adv_weapon", "basic_weapon"},
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[4] = {
				morphBuildPower = 25,
				morphBaseCost = morphCosts[4] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.decloakDistance = 120
					sharedData.cloakregen = (sharedData.cloakregen or 0) + 50
					sharedData.speedMod = (sharedData.speedMod or 0) + 2
					sharedData.recloaktime = (sharedData.recloaktime or 300) - 120
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynstrike4_" .. GetStrikeCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
			[5] = {
				morphBuildPower = 30,
				morphBaseCost = morphCosts[5] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.decloakDistance = 100
					sharedData.cloakregen = (sharedData.cloakregen or 0) + 60
					sharedData.speedMod = (sharedData.speedMod or 0) + 2
					sharedData.recloaktime = (sharedData.recloaktime or 300) - 150
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynstrike5_" .. GetStrikeCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
		}
	},
	{
		name = "recon",
		humanName = "Recon",
		baseUnitDef = UnitDefNames and UnitDefNames["dynrecon0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = 5,
		levelDefs = {
			[0] = {
				morphBuildPower = 10,
				morphBaseCost = 0,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.speedMod = (sharedData.speedMod or 0) + 2
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynrecon0"].id
				end,
				upgradeSlots = {},
			},
			[1] = {
				morphBuildPower = 10,
				morphBaseCost = morphCosts[1],
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.speedMod = (sharedData.speedMod or 0) + 4
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynrecon1_" .. GetReconCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = "basic_weapon",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[2] = {
				morphBuildPower = 15,
				morphBaseCost = morphCosts[2] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.speedMod = (sharedData.speedMod or 0) + 6
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynrecon2_" .. GetReconCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[3] = {
				morphBuildPower = 20,
				morphBaseCost = morphCosts[3] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.speedMod = (sharedData.speedMod or 0) + 8
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynrecon3_" .. GetReconCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = {"adv_weapon", "basic_weapon"},
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[4] = {
				morphBuildPower = 25,
				morphBaseCost = morphCosts[4] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.speedMod = (sharedData.speedMod or 0) + 10
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynrecon4_" .. GetReconCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
			[5] = {
				morphBuildPower = 30,
				morphBaseCost = morphCosts[5] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.speedMod = (sharedData.speedMod or 0) + 12
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynrecon5_" .. GetReconCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
		}
	},
	{
		name = "support",
		humanName = "Support",
		baseUnitDef = UnitDefNames and UnitDefNames["dynsupport0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = 5,
		levelDefs = {
			[0] = {
				morphBuildPower = 10,
				morphBaseCost = 0,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynsupport0"].id
				end,
				upgradeSlots = {},
			},
			[1] = {
				morphBuildPower = 10,
				morphBaseCost = morphCosts[1],
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 2
					sharedData.extrastorage = (sharedData.extrastorage or 0) + 50
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynsupport1_" .. GetSupportCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = "basic_weapon",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[2] = {
				morphBuildPower = 15,
				morphBaseCost = morphCosts[2] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 4
					sharedData.extrastorage = (sharedData.extrastorage or 0) + 100
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynsupport2_" .. GetSupportCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[3] = {
				morphBuildPower = 20,
				morphBaseCost = morphCosts[3] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 6
					sharedData.extrastorage = (sharedData.extrastorage or 0) + 150
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynsupport3_" .. GetSupportCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = {"adv_weapon", "basic_weapon"},
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[4] = {
				morphBuildPower = 25,
				morphBaseCost = morphCosts[4],
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 9
					sharedData.extrastorage = (sharedData.extrastorage or 0) + 200
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynsupport4_" .. GetSupportCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
			[5] = {
				morphBuildPower = 30,
				morphBaseCost = morphCosts[5],
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.bonusBuildPower = (sharedData.bonusBuildPower or 0) + 12
					sharedData.extrastorage = (sharedData.extrastorage or 0) + 250
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynsupport5_" .. GetSupportCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
		}
	},
	{
		name = "assault",
		humanName = "Bombard",
		baseUnitDef = UnitDefNames and UnitDefNames["dynassault0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = 5,
		secondPeashooter = true,
		levelDefs = {
			[0] = {
				morphBuildPower = 10,
				morphBaseCost = 0,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.075
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynassault0"].id
				end,
				upgradeSlots = {},
			},
			[1] = {
				morphBuildPower = 10,
				morphBaseCost = morphCosts[1],
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.15
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynassault1_" .. GetAssaultCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = "basic_weapon",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[2] = {
				morphBuildPower = 15,
				morphBaseCost = morphCosts[2] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.225
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynassault2_" .. GetAssaultCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[3] = {
				morphBuildPower = 20,
				morphBaseCost = morphCosts[3] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.3
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynassault3_" .. GetAssaultCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = {"adv_weapon", "basic_weapon"},
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[4] = {
				morphBuildPower = 25,
				morphBaseCost = morphCosts[4] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.375
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynassault4_" .. GetAssaultCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
			[5] = {
				morphBuildPower = 30,
				morphBaseCost = morphCosts[5] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.45
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynassault5_" .. GetAssaultCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
		}
	},
	{
		name = "riot",
		humanName = "Riot",
		baseUnitDef = UnitDefNames and UnitDefNames["dynriot0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = 5,
		secondPeashooter = true,
		levelDefs = {
			[0] = {
				morphBuildPower = 10,
				morphBaseCost = 0,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
					sharedData.damageMult = (sharedData.damageMult or 1) + 0.05
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynriot0"].id
				end,
				upgradeSlots = {},
			},
			[1] = {
				morphBuildPower = 10,
				morphBaseCost = morphCosts[1],
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 10
					sharedData.damageMult = (sharedData.damageMult or 1) + 0.1
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynriot1_" .. GetRiotCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = "basic_weapon",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[2] = {
				morphBuildPower = 15,
				morphBaseCost = morphCosts[2] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 15
					sharedData.damageMult = (sharedData.damageMult or 1) + 0.15
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynriot2_" .. GetRiotCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = {"adv_weapon", "basic_weapon"},
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[3] = {
				morphBuildPower = 20,
				morphBaseCost = morphCosts[3] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 20
					sharedData.damageMult = (sharedData.damageMult or 1) + 0.2
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynriot3_" .. GetRiotCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
			[4] = {
				morphBuildPower = 25,
				morphBaseCost = morphCosts[4] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 25
					sharedData.damageMult = (sharedData.damageMult or 1) + 0.25
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynriot4_" .. GetRiotCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
			[5] = {
				morphBuildPower = 30,
				morphBaseCost = morphCosts[5] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 30
					sharedData.damageMult = (sharedData.damageMult or 1) + 0.3
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynriot5_" .. GetRiotCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
		}
	},
	{
		name = "knight",
		humanName = "Knight",
		baseUnitDef = UnitDefNames and UnitDefNames["dynknight0"].id,
		extraLevelCostFunction = extraLevelCostFunction,
		maxNormalLevel = 5,
		notSelectable = (Spring.GetModOptions().campaign_chassis ~= "1"),
		secondPeashooter = true,
		levelDefs = {
			[0] = {
				morphBuildPower = 10,
				morphBaseCost = 0,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					-- Level 1 is the same as level 0 in stats and has support for clone modules (such as shield).
					return UnitDefNames["dynknight1_" .. GetKnightCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {},
			},
			[1] = {
				morphBuildPower = 10,
				morphBaseCost = morphCosts[1],
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynknight1_" .. GetKnightCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = "basic_weapon",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[2] = {
				morphBuildPower = 15,
				morphBaseCost = morphCosts[2] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynknight2_" .. GetKnightCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[3] = {
				morphBuildPower = 20,
				morphBaseCost = morphCosts[3] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynknight3_" .. GetKnightCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
					{
						defaultModule = moduleDefNames.commweapon_beamlaser,
						slotAllows = {"adv_weapon", "basic_weapon"},
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
					{
						defaultModule = moduleDefNames.nullmodule,
						slotAllows = "module",
					},
				},
			},
			[4] = {
				morphBuildPower = 25,
				morphBaseCost = morphCosts[4] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynknight4_" .. GetKnightCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
			[5] = {
				morphBuildPower = 30,
				morphBaseCost = morphCosts[5] * COST_MULT,
				chassisApplicationFunction = function (modules, sharedData)
					sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 5
				end,
				morphUnitDefFunction = function(modulesByDefID)
					return UnitDefNames["dynknight5_" .. GetKnightCloneModulesString(modulesByDefID)].id
				end,
				upgradeSlots = {
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
				},
			},
		}
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
			if VFS.FileExists("gamedata\\modularcomms\\weapons\\" .. string.gsub(name:gsub("commweapon_", ""), "_", "") .. ".lua") then
				_, wd = VFS.Include("gamedata\\modularcomms\\weapons\\" .. string.gsub(name:gsub("commweapon_", ""), "_", "") .. ".lua")
			end
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
	if chassis == 5 and data.slotType == "basic_weapon" and limit == 2 then
		limit = 1
	end

	-- Check that the module limit is not reached
	if limit and (alreadyOwned[moduleDefID] or (alreadyOwned2 and alreadyOwned2[moduleDefID])) then
		local count = (alreadyOwned[moduleDefID] or 0) + ((alreadyOwned2 and alreadyOwned2[moduleDefID]) or 0)
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
