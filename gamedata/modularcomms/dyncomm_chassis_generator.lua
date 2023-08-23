local chassisDefs = {
	{
		name = "dynstrike1", -- 25/31 (UPDATE ME AS YOU ADD MORE WEAPONS)
		weapons = {
			"commweapon_tankbuster",
			"commweapon_tankbuster",
			"commweapon_buster_disrupt",
			"commweapon_buster_disrupt",
			"commweapon_shotgun",
			"commweapon_shotgun",
			"commweapon_shotgun_disrupt",
			"commweapon_shotgun_disrupt",
			"commweapon_heavyrifle",
			"commweapon_heavyrifle",
			"commweapon_heavyrifle_disrupt",
			"commweapon_heavyrifle_disrupt",
			"commweapon_lightninggun",
			"commweapon_lightninggun",
			"commweapon_lightninggun_improved",
			"commweapon_lightninggun_improved",
			"commweapon_multistunner",
			"commweapon_multistunner_improved",
			"commweapon_sunburst",
			"commweapon_light_disintegrator",
			"commweapon_light_disintegrator",
			"commweapon_disintegrator",
			"commweapon_disintegrator",
			"commweapon_minefieldinacan",
			"commweapon_microriftgenerator",
			-- Space for shield
		}
	},
	{
		name = "dynrecon1", -- 22/31
		weapons = {
			"commweapon_light_flamethrower",
			"commweapon_light_flamethrower",
			"commweapon_emg",
			"commweapon_emg",
			"commweapon_emg_disrupt",
			"commweapon_emg_disrupt",
			"commweapon_napalmgrenade",
			"commweapon_clusterbomb",
			"commweapon_concussion",
			"commweapon_heatray",
			"commweapon_heatray",
			"commweapon_gaussrepeater",
			"commweapon_gaussrepeater",
			"commweapon_minefieldinacan",
			"commweapon_leolaser",
			"commweapon_leolaser",
			"commweapon_leolaser_disrupt",
			"commweapon_leolaser_disrupt",
			"commweapon_leolaser_shotgun",
			"commweapon_leolaser_shotgun",
			"commweapon_leolaser_shotgun_disrupt",
			"commweapon_leolaser_shotgun_disrupt",
			-- Space for shield
		}
	},
	{
		name = "dynsupport1", -- 28/31
		weapons = {
			"commweapon_capray",
			"commweapon_capray",
			"commweapon_beamlaser",
			"commweapon_beamlaser",
			"commweapon_beamlaser_heavy",
			"commweapon_beamlaser_heavy",
			"commweapon_lparticlebeam",
			"commweapon_lparticlebeam",
			"commweapon_disruptor",
			"commweapon_disruptor",
			"commweapon_hparticlebeam",
			"commweapon_hparticlebeam",
			"commweapon_impulse_laser",
			"commweapon_impulse_laser",
			"commweapon_heavy_disruptor",
			"commweapon_heavy_disruptor",
			"commweapon_lightninggun",
			"commweapon_lightninggun_improved",
			"commweapon_disruptorprojector",
			"commweapon_disruptorprojector",
			"commweapon_shockrifle",
			"commweapon_shockrifle",
			"commweapon_multistunner", -- TODO: replace with EMP bomb.
			"commweapon_multistunner_improved",
			"commweapon_disruptorbomb",
			"commweapon_disruptorprojector_heavy",
			"commweapon_disruptorprojector_heavy",
			"commweapon_singulauncher",
			--
			-- Space for shield
		}
	},
	{
		name = "dynassault1", --18/31
		weapons = {
			"commweapon_rocketlauncher", -- 430
			"commweapon_rocketlauncher", -- 430
			"commweapon_artillery_heavy",
			"commweapon_artillery_heavy",
			"commweapon_rocketbarrage",
			"commweapon_rocketbarrage",
			"commweapon_rocketbarrage_nuclear",
			"commweapon_rocketbarrage_nuclear",
			"commweapon_rocketlauncher_nuclear",
			"commweapon_rocketlauncher_nuclear",
			"commweapon_artillery_heavy_nuclear",
			"commweapon_artillery_heavy_nuclear",
			"commweapon_napalmgrenade", -- TODO: replace with napalm mortar
			"commweapon_clusterbomb", -- TODO: replace with mortar
			"commweapon_megalaser", -- DEATH LASER LETS GO GAMERS.
			"commweapon_megalaser", -- DEATH LASER LETS GO GAMERS.
			"commweapon_taclaser",
			"commweapon_taclaser",
			-- Space for shield
		}
	},
	{
		name = "dynriot1", --20/31
		weapons = {
			"commweapon_canistercannon",
			"commweapon_canistercannon",
			"commweapon_canistercannon_napalm",
			"commweapon_canistercannon_napalm",
			"commweapon_heavymachinegun",
			"commweapon_heavymachinegun",
			"commweapon_sonicgun",
			"commweapon_sonicgun",
			"commweapon_grenadelauncher",
			"commweapon_grenadelauncher",
			"commweapon_riotcannon",
			"commweapon_riotcannon",
			"commweapon_riotcannon_napalm",
			"commweapon_riotcannon_napalm",
			"commweapon_heavymachinegun_napalm",
			"commweapon_heavymachinegun_napalm",
			"commweapon_flamethrower",
			"commweapon_flamethrower",
			"commweapon_concussion",
			"commweapon_vacuumgun",
			-- Space for shield
		}
	},
	{
		name = "dynknight1", -- don't care.
		weapons = {
			-- Aiming from earlier weapons is overridden by 
			"commweapon_rocketlauncher", -- 430
			"commweapon_rocketlauncher_napalm", -- 430
			"commweapon_missilelauncher", -- 415
			"commweapon_hparticlebeam", -- 390
			"commweapon_beamlaser", -- 330
			"commweapon_lightninggun", -- 300
			"commweapon_lightninggun_improved", -- 300
			"commweapon_lparticlebeam", -- 300
			"commweapon_riotcannon", -- 300
			"commweapon_riotcannon_napalm", -- 300
			"commweapon_disruptor", -- 300
			"commweapon_heatray", -- 300
			"commweapon_shotgun", -- 290
			"commweapon_shotgun_disrupt", -- 290
			"commweapon_heavymachinegun", -- 285
			"commweapon_heavymachinegun_disrupt", -- 285
			"commweapon_flamethrower", -- 270
			"commweapon_multistunner",
			"commweapon_multistunner_improved",
			"commweapon_artillery_heavy",
			"commweapon_artillery_heavy_napalm",
			"commweapon_disintegrator",
			"commweapon_napalmgrenade",
			"commweapon_slamrocket",
			"commweapon_disruptorbomb",
			"commweapon_concussion",
			"commweapon_clusterbomb",
			"commweapon_shockrifle",
			-- Space for shield
		}
	},
}

local commanderCost = 1100

local statOverrides = {
	cloakcost       = 5, -- For personal cloak
	cloakcostmoving = 10,
	onoffable       = true, -- For jammer and cloaker toggling
	canmanualfire   = true, -- For manualfire weapons.
	buildcostmetal  = commanderCost,
	buildcostenergy = commanderCost,
	buildtime       = commanderCost,
	power           = 1200,
}

for i = 1, #chassisDefs do
	local name = chassisDefs[i].name
	local unitDef = UnitDefs[name]
	
	for wreckName, wreckDef in pairs(unitDef.featuredefs) do
		wreckDef.metal = commanderCost * (wreckName == "heap" and 0.2 or 0.4)
		wreckDef.reclaimtime = wreckDef.metal
	end
	
	for key, data in pairs(statOverrides) do
		unitDef[key] = data
	end
	
	if name:find("dynstrike") then
		cloakcost = 2.5
	end
	
	for j = 1, 7 do
		unitDef.sfxtypes.explosiongenerators[j] = unitDef.sfxtypes.explosiongenerators[j] or [[custom:NONE]]
	end
	
	for num = 1, #chassisDefs[i].weapons do
		local weaponName = chassisDefs[i].weapons[num]
		DynamicApplyWeapon(unitDef, weaponName, num)
	end
	
	if #chassisDefs[i].weapons > 31 then
		-- Limit of 31 for shield space.
		Spring.Echo("Too many commander weapons on:", name, "Limit is 31, found weapons:", #chassisDefs[i].weapons)
	end
end
