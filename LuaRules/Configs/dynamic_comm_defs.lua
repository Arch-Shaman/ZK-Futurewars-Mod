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
		description = "No Module",
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
		description = "No Weapon",
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
		description = "No Weapon",
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
		description = "Beam Laser: An effective short-range cutting tool",
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
		description = "Flamethrower: Good for deep-frying swarmers and large targets alike",
		image = moduleImagePath .. "commweapon_flamethrower.png",
		limit = 2,
		cost = 50 * COST_MULT,
		requireChassis = {"recon", "assault", "knight"},
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
		description = "Heatray: Rapidly melts anything at short range; steadily loses all of its damage over distance",
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
		description = "Heatray: Rapidly melts anything at short range; steadily loses all of its damage over distance",
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
		humanName = "Machine Gun",
		description = "Machine Gun: Close-in automatic weapon with AoE",
		image = moduleImagePath .. "commweapon_heavymachinegun.png",
		limit = 2,
		cost = 50 * COST_MULT,
		requireChassis = {"assault", "knight"},
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
		description = "Heavy Rifle:\n Medium range and medium damage assault rifle for hunting down light units.",
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
		description = "Medium EMG Rifle\n Fast firing medium damage assault rifle. Single target only.",
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
		description = "Tank Buster Cannon\n Extremely hard hitting, low fire rate antiheavy cannon.",
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
		name = "commweapon_hpartillery",
		humanName = "Plasma Artillery",
		description = "Plasma Artillery",
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
		description = "Lightning Rifle: Paralyzes and damages annoying bugs",
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
		description = "Light Particle Beam: Fast, light pulsed energy weapon",
		image = moduleImagePath .. "commweapon_lparticlebeam.png",
		limit = 2,
		cost = 100 * COST_MULT,
		requireChassis = {"support", "recon", "strike", "knight"},
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
		description = "Missile Launcher: Lightweight seeker missile with good range",
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
		description = "Riot Cannon: The weapon of choice for crowd control",
		image = moduleImagePath .. "commweapon_riotcannon.png",
		limit = 2,
		cost = 75 * COST_MULT,
		requireChassis = {"assault", "knight"},
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
		humanName = "Rocket Launcher",
		description = "Rocket Launcher: Medium-range, low-velocity hitter",
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
		humanName = "Virus Uplink (Capture)",
		description = "Virus Uplink\nUploads a capture virus onto enemy units, giving control over to you. The uplink must recharge after capturing a unit.\nWater Capable.",
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
		description = "Shotgun: Can hammer a single large target or shred several small ones",
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
		name = "commweapon_canister_cannon",
		humanName = "Canister Cannon",
		description = "Canister Cannon:\nReleases tiny fragments at a certain range. May impact multiple units.",
		image = moduleImagePath .. "commweapon_canister.png",
		limit = 2,
		cost = 0 * COST_MULT,
		requireChassis = {"assault"},
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
		name = "commweapon_disruptorprojector",
		humanName = "Disruptor Projector (Area Slow)",
		description = "Disruptor Projector (Area Slow)\nDeals some damage and slows targets in a small area. Low DPS. Can be converted into a heavy AOE slow beam.",
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
		description = "High Frequency Beam Kit\nConverts a disruptor or beam into a heavier version.",
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
		description = "High Frequency Beam Kit\nConverts a disruptor or beam into a heavier version.",
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
		description = "Sniper Rifle\n Long range sniper rifle. Long reload time, high damage, long range.",
		image = moduleImagePath .. "commweapon_shockrifle.png",
		limit = 2,
		cost = 50 * COST_MULT,
		requireChassis = {"support", "knight"},
		requireLevel = 1,
		slotType = "basic_weapon",
		applicationFunction = function (modules, sharedData)
			local weaponName = "commweapon_shockriflefw"
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
		description = "Cluster Bomb - Manually fired burst of bombs.",
		image = moduleImagePath .. "commweapon_clusterbomb.png",
		limit = 1,
		cost = 400 * COST_MULT,
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
		description = "Minefield In A Can:\nA canister full of surprises, waiting for your enemies.\nStrike and Recon only.",
		image = moduleImagePath .. "conversion_partillery.png",
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
		description = "Concussion Shell - Manually fired high impulse projectile.",
		image = moduleImagePath .. "commweapon_concussion.png",
		limit = 1,
		cost = 400 * COST_MULT,
		requireChassis = {"recon", "knight"},
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
		description = "Disintegrator\nManually fired weapon that destroys almost everything it touches.\nWater Capable.",
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
		description = "Sunburst Cannon\nManually fired weapon that ruin's a single target's day with a high damage shot. Quick reload.\nAmbusher only. Water Capable.",
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
		description = "Disruptor Bomb - Manually fired bomb that slows enemies in a large area.",
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
		description = "Multistunner - Manually fired sustained burst of lightning.",
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
		description = "Gauss Repeater\nA penetrating, rapid fire short range rifle for raiding while underwater.\nRecon only.",
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
		description = "Hellfire Grenade - Manually fired bomb that inflames a large area.",
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
		description = "S.L.A.M. Rocket - Manually fired miniature tactical nuke.",
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
		description = "Vanguard Economy Pack - A vital part of establishing a beachhead, this module is equipped by all new commanders to kickstart their economy. Provides 4 metal income and 6 energy income.",
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
		description = "By upgrading the Support comm's resource allocation algorithms, some extra metal and energy can be squeezed out of the chassis's resource generator.",
		image = moduleImagePath .. "module_efficency.png",
		limit = 4,
		requireChassis = {"support"},
		cost = 125 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.metalIncome = (sharedData.metalIncome or 0) + 0.5
			sharedData.energyIncome = (sharedData.energyIncome or 0) + 2
		end
	},
	{
		name = "commweapon_personal_shield",
		humanName = "Personal Shield",
		description = "Personal Shield\nA small, protective bubble shield.\nMutually Exclusive with Area Jammer and Personal Cloak.",
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
		description = "Area Shield\nProjects a large shield. Replaces Personal Shield.",
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
		description = "Napalm Warhead - Riot Cannon and Rocket Launcher set targets on fire. Reduced direct damage.",
		image = moduleImagePath .. "weaponmod_napalm_warhead.png",
		limit = 1,
		cost = 350 * COST_MULT,
		requireChassis = {"assault", "knight"},
		requireOneOf = {"commweapon_rocketlauncher", "commweapon_hpartillery", "commweapon_riotcannon"},
		requireLevel = 2,
		slotType = "module",
	},
	{
		name = "conversion_disruptor",
		humanName = "Disruptor Ammo",
		description = "Disruptor Ammo - Heavy Machine Gun, Tank Buster, EMG, Shotgun and Particle Beams deal slow damage. Reduced direct damage.",
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
		description = "Flux Amplifier - Improves EMP duration and strength of Lightning Rifle and Multistunner.",
		image = moduleImagePath .. "weaponmod_stun_booster.png",
		limit = 1,
		cost = 300 * COST_MULT,
		requireChassis = {"support", "strike", "recon", "knight"},
		requireOneOf = {"commweapon_lightninggun", "commweapon_multistunner"},
		requireLevel = 2,
		slotType = "module",
	},
	{
		name = "module_jammer",
		humanName = "Radar Jammer",
		description = "Radar Jammer - Hide the radar signals of nearby units.",
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
		description = "Personal Radar Jammer:\nHides you from radar.",
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
		description = "Field Radar - Attaches a basic radar system.",
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
		description = "Radar Amplifier:\nIncreases radar by 10%.\nRecon Only (Limit: 8)",
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
		description = "Enhanced Sensors:\nIncreases sight radius by 15%.\nRecon Only (Limit: 8)",
		image = moduleImagePath .. "module_radarnet2.png",
		limit = 8,
		requireChassis = {"recon"},
		cost = 125 * COST_MULT,
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.sightrangebonus = (sharedData.sightrangebonus or 1) + .15
		end
	},
	{
		name = "module_personal_cloak",
		humanName = "Personal Cloak",
		description = "Personal Cloak:\n A personal cloaking device.\nReduces speed by 2.\nRecon and Bombard only.",
		image = moduleImagePath .. "module_personal_cloak.png",
		limit = 1,
		cost = 400 * COST_MULT,
		prohibitingModules = {"commweapon_personal_shield", "commweapon_areashield"},
		requireChassis = {"recon", "assault", "strike", "knight"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.decloakDistance = math.max(sharedData.decloakDistance or 0, 150)
			sharedData.personalCloak = true
			sharedData.recloaktime = 300
			sharedData.speedMod = (sharedData.speedMod or 0) - 2
		end
	},
	{
		name = "module_cloak_field",
		humanName = "Cloaking Field",
		description = "Cloaking Field\nCloaks all nearby units.\nReduces speed by 3.\nSupport only.",
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
			sharedData.speedMod = (sharedData.speedMod or 0) - 3
		end
	},
	{
		name = "module_resurrect",
		humanName = "Lazarus Device",
		description = "Lazarus Device:\nUpgrade nanolathe to allow resurrection.\nSupport only.",
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
		description = "Efficient Jumpjets:\nReduces jumpjet cooldown by 20%.\nIncreases jump speed slightly.\nRecon only.\nMutually Exclusive with: Improved Jumpjets & High Performance Jumpjets.",
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
		description = "\"Peaceful Wind\" Asset Denial System:\nMutually Assured Destruction guaranteed or your metal back!\n\nIncreases the severity of the commander death explosion. At maximum level, it is equivalent to a nuclear detonation.",
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
		description = "Improved Jumpjets:\nIncreases jumpjet range by 20%.\nIncreases jump speed moderately.\nDecreases jumpjet reload by 7.5%\nRecon only.\nMutually Exclusive with: High Performance Jumpjets & Efficient Jumpjets.",
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
		description = "High Performance Jumpjets:\nIncreases jumpjet range by 50%.\nIncreases jump speed signifcantly.\nRecon only.\nMutually Exclusive with: Improved Jumpjets & Efficient Jumpjets.",
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
		description = "Jumpjets - Leap over obstacles and out of danger.",
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
		description = "Companion Drone:\nAdds a protective drone.\nSupport only (Limit: 8)",
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
		description = "Battle Drone:\nCommander spawns heavy drones.\nSupport only (Limit: 8, Requires 1 Companion Drone)",
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
		humanName = "Autorepair",
		description = "Autorepair:\nCommander self-repairs at +10 hp/s. Reduces Health by " .. 100*HP_MULT .. ".(Limit: 8)",
		image = moduleImagePath .. "module_autorepair.png",
		limit = 8,
		cost = 150 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.autorepairRate = (sharedData.autorepairRate or 0) + 10
			sharedData.healthBonus = (sharedData.healthBonus or 0) - 100*HP_MULT
		end
	},
	{
		name = "module_ablative_armor",
		humanName = "Ablative Armour Plates",
		description = "Ablative Armour Plates - Provides " .. 1250*HP_MULT .. " health. (Limit: 8)",
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
		description = "High Density Plating:\nProvides " .. 3000*HP_MULT .. " health but reduces speed by 1. " ..
		"\nGuardian Only. (Limit: 8, Requires Ablative Armour Plates)",
		image = moduleImagePath .. "module_heavy_armor.png",
		limit = 8,
		cost = 200 * COST_MULT,
		requireOneOf = {"module_ablative_armor"},
		requireChassis = {"assault"},
		requireLevel = 2,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.healthBonus = (sharedData.healthBonus or 0) + 3000*HP_MULT
			sharedData.speedMod = (sharedData.speedMod or 0) - 1
		end
	},
	{
		name = "module_dmg_booster",
		humanName = "Damage Booster",
		description = "Damage Booster:\nIncreases damage by 10% but reduces speed by 1. (Limit: 8)",
		image = moduleImagePath .. "module_dmg_booster.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			-- Damage boost is applied via clone swapping
			sharedData.damageMult = (sharedData.damageMult or 1) + 0.1
			sharedData.speedMod = (sharedData.speedMod or 0) - 1
		end
	},
	{
		name = "module_high_power_servos",
		humanName = "High Power Servos",
		description = "High Power Servos\nIncreases speed by 2. (Limit: 8)",
		image = moduleImagePath .. "module_high_power_servos.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		applicationFunction = function (modules, sharedData)
			sharedData.speedMod = (sharedData.speedMod or 0) + 2
		end
	},
	{
		name = "module_high_power_servos_improved",
		humanName = "Strike Servos",
		description = "Strike Servos\nIncreases speed by 4, decreases health by " .. 300*HP_MULT .. "\nRecon and Ambusher only. (Limit: 8)",
		image = moduleImagePath .. "module_strike_servos.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"strike", "recon"},
		applicationFunction = function (modules, sharedData)
			sharedData.speedMod = (sharedData.speedMod or 0) + 4
			sharedData.healthBonus = (sharedData.healthBonus or 0) - 300*HP_MULT
		end
	},
	{
		name = "module_cloakregen",
		humanName = "Nanobot Sleeve",
		description = "Nanobot Sleeve:\nIncreases regen while cloaked by 20.\nAmbusher only (Limit: 8)",
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
		description = "Advanced Targeting System:\nIncreases range by 7.5% but reduces speed by 1. (Limit: 8)",
		image = moduleImagePath .. "module_adv_targeting.png",
		limit = 8,
		cost = 100 * COST_MULT,
		requireLevel = 1,
		slotType = "module",
		requireChassis = {"strike", "recon", "support", "riot"},
		applicationFunction = function (modules, sharedData)
			sharedData.rangeMult = (sharedData.rangeMult or 1) + 0.075
			sharedData.speedMod = (sharedData.speedMod or 0) - 1
		end
	},
	{
		name = "module_adv_targeting",
		humanName = "Adv. Targeting System",
		description = "Improved Targeting System:\nIncreases range by 10% but reduces speed by 2.\nBombard only.(Limit: 8)",
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
		description = "Advanced Nanolathe:\nIncreases build power by 2.5 (+5 for support). Increases storage by 25 (50 for support).\nLimit: 8",
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
		description = "Advanced Nanolathe:\nIncreases build power by 5 (+2.5 for others). Increases storage by 50 (25 for others).\nLimit: 8",
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
		description = "Banner",
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

-- Set cost in module tooltip
for i = 1, #moduleDefs do
	local data = moduleDefs[i]
	if data.cost > 0 then
		data.description = data.description .. "\nCost: " .. data.cost
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
