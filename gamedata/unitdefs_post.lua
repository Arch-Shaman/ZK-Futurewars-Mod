
local modOptions = {}
if (Spring.GetModOptions) then
	modOptions = Spring.GetModOptions()
end

local nuclearwar = tonumber((modOptions["goingnuclear"]) or 0) == 1
local commwars = tonumber((modOptions["commwars"]) or 0) == 1


Spring.Echo("Loading UnitDefs_posts")
--Spring.Echo("UDP: Nuclear war mode: " .. tostring(nuclearwar) .. "\ngoing nuclear value: " .. tostring(modOptions["goingnuclear"]))

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Constants?
--

VFS.Include("LuaRules/Configs/constants.lua")
local TRANSPORT_LIGHT_COST_MAX = 1000
local TRANSPORT_STRUCT_COST_MAX = 2000
local TRANSPORT_LIGHT_STRUCT_COST_MAX = 600

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utility
--

local function round(num)
	return num - (num%1)
end

local function GetRandom(s, c)
	local n = 0
	for i = 1, s:len() do
		n = n + s:byte(i)
	end
	n = (math.sin(n) + 1) * 0.5 * (c - 1) + 1
	return round(n)
end

local function tobool(val)
	local t = type(val)
	if (t == 'nil') then
		return false
	elseif (t == 'boolean') then
		return val
	elseif (t == 'number') then
		return (val ~= 0)
	elseif (t == 'string') then
		return ((val ~= '0') and (val ~= 'false'))
	end
	return false
end

local function lowerkeys(t)
	local tn = {}
	if type(t) == "table" then
		for i,v in pairs(t) do
			local typ = type(i)
			if type(v)=="table" then
				v = lowerkeys(v)
			end
			if typ=="string" then
				tn[i:lower()] = v
			else
				tn[i] = v
			end
		end
	end
	return tn
end

local function Explode(div, str)
	if div == '' then
		return false
	end
	local pos, arr = 0, {}
	-- for each divider found
	for st, sp in function() return string.find(str, div, pos, true) end do
		table.insert(arr, string.sub(str, pos, st - 1)) -- Attach chars left of current divider
		pos = sp + 1 -- Jump past current divider
	end
	table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
	return arr
end

local function GetDimensions(scale)
	if not scale then
		return false
	end
	local dimensionsStr = Explode(" ", scale)
	-- string conversion (required for MediaWiki export)
	local dimensions = {}
	for i,v in pairs(dimensionsStr) do
		dimensions[i] = tonumber(v)
	end
	local largest = (dimensions and dimensions[1] and tonumber(dimensions[1])) or 0
	for i = 2, 3 do
		largest = math.max(largest, (dimensions and dimensions[i] and tonumber(dimensions[i])) or 0)
	end
	return dimensions, largest
end

--deep not safe with circular tables! defaults To false
Spring.Utilities = Spring.Utilities or {}
VFS.Include("LuaRules/Utilities/tablefunctions.lua")
CopyTable = Spring.Utilities.CopyTable
MergeTable = Spring.Utilities.MergeTable

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- ud.customparams IS NEVER NIL

for _, ud in pairs(UnitDefs) do
	if not ud.customparams then
		ud.customparams = {}
	end
 end
 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Balance Testing
--

-- modOptions.tweakdefs = 'Zm9yIG5hbWUsIHVkIGluIHBhaXJzKFVuaXREZWZzKSBkbwoJaWYgdWQubWF4dmVsb2NpdHkgdGhlbgoJCXVkLm1heHZlbG9jaXR5ID0gdWQubWF4dmVsb2NpdHkqMTAKCWVuZAplbmQ='

do
	local append = false
	local name = "tweakdefs"
	while modOptions[name] and modOptions[name] ~= "" do
		local postsFuncStr = Spring.Utilities.Base64Decode(modOptions[name])
		local postfunc, err = loadstring(postsFuncStr)
		Spring.Echo("Loading tweakdefs modoption", append or 0)
		if postfunc then
			postfunc()
		end
		append = (append or 0) + 1
		name = "tweakdefs" .. append
	end
end

--modOptions.tweakunits = 'ewpjbG9ha3JhaWQgPSB7YnVpbGRDb3N0TWV0YWwgPSAxMCwKd2VhcG9uRGVmcyA9IHtFTUcgPSB7ZGFtYWdlID0ge2RlZmF1bHQgPSAyMDB9fX19LAp9'

do
	local append = false
	local name = "tweakunits"
	while modOptions[name] and modOptions[name] ~= "" do
		local tweaks = Spring.Utilities.CustomKeyToUsefulTable(modOptions[name])
		if type(tweaks) == "table" then
			Spring.Echo("Loading tweakunits modoption", append or 0)
			for name, ud in pairs(UnitDefs) do
				if tweaks[name] then
					Spring.Echo("Loading tweakunits for " .. name)
					Spring.Utilities.OverwriteTableInplace(ud, lowerkeys(tweaks[name]), true)
				end
			end
		end
		append = (append or 0) + 1
		name = "tweakunits" .. append
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- because the way lua access to unitdefs and weapondefs is setup is insane
--

--[[for _, ud in pairs(UnitDefs) do
	if ud.collisionVolumeOffsets then
		ud.customparams.collisionVolumeOffsets = ud.collisionVolumeOffsets  -- For ghost site
	end
end]]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Unitdef generation handling
--

VFS.Include('gamedata/modularcomms/unitdefgen.lua')
VFS.Include('gamedata/planetwars/pw_unitdefgen.lua')
VFS.Include('gamedata/chicken/chickendefgen.lua')

-- Handle obsolete keys in mods gracefully while they migrate
for name, ud in pairs(UnitDefs) do
	if ud.metaluse then
		--Spring.Echo("ERROR: " .. name .. ".metalUse set, should be metalUpkeep instead!")
		ud.metalupkeep = ud.metalupkeep or ud.metaluse
	end
	if ud.energyuse then
		--Spring.Echo("ERROR: " .. name .. ".energyuse set, should be energyUpkeep instead!")
		ud.energyupkeep = ud.energyupkeep or ud.energyuse
	end
	if ud.buildcostmetal then
		--Spring.Echo("ERROR: " .. name .. ".buildCostMetal set, should be metalCost instead!")
		ud.metalcost = ud.metalcost or ud.buildcostmetal
	end
	if ud.buildcostenergy then
		--Spring.Echo("ERROR: " .. name .. ".buildCostEnergy set, should be energyCost instead!")
		ud.energycost = ud.energycost or ud.buildcostenergy
	end
	if ud.maxdamage then
		--Spring.Echo("ERROR: " .. name .. ".maxDamage set, should be health instead!")
		ud.health = ud.health or ud.maxdamage
	end
	if ud.maxvelocity then
		--Spring.Echo("ERROR: " .. name .. ".speed set, should be speed instead!")
		ud.speed = ud.speed or (ud.maxvelocity * Game.gameSpeed)
	end
	--if ud.maxreversevelocity then
		--Spring.Echo("ERROR: " .. name .. ".maxReverseVelocity set, should be rSpeed instead!")
		--ud.rspeed = ud.rspeed or (ud.maxreversevelocity * Game.gameSpeed)
	--end
	if ud.customparams.ismex then
		--Spring.Echo("ERROR: " .. name .. ".customParams.ismex set, should be metal_extractor_mult (= 1) instead!")
		ud.customparams.metal_extractor_mult = 1
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Make Terraunit not decloak enemies
--

--if Utilities.IsCurrentVersionNewerThan(104, 1400) and not Utilities.IsCurrentVersionNewerThan(104, 1470) then
--	UnitDefs.terraunit.collisionvolumeoffsets = [[0 -550 0]]
--	UnitDefs.terraunit.selectionvolumeoffsets = [[0 550 0]]
--	UnitDefs.terraunit.customparams.midposoffset = [[0 -550 0]]
--end -- No longer needed? (Ask sprung at some point.

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Convert all CustomParams to strings
--

-- FIXME: breaks with table keys
-- but why would you be using those anyway?
local function TableToString(tbl)
	local str = "{"
	for i, v in pairs(tbl) do
		if type(i) == "number" then
			str = str .. "[" .. i .. "] = "
		else
			str = str .. [[["]]..i..[["] = ]]
		end
		
		if type(v) == "table" then
			str = str .. TableToString(v)
		elseif type(v) == "boolean" then
			str = str .. tostring(v) .. ";"
		elseif type(v) == "string" then
			str = str .. "[[" .. v .. "]];"
		else
			str = str .. v .. ";"
		end
	end
	str = str .. "};"
	return str
end

local buildOpts = VFS.Include("gamedata/buildoptions.lua")
local autoheal_defaults = VFS.Include("gamedata/unitdef_defaults/autoheal_defs.lua")
local area_cloak_defaults = VFS.Include("gamedata/unitdef_defaults/area_cloak_defs.lua")
local jump_defaults = VFS.Include("gamedata/unitdef_defaults/jump_defs.lua")
local typeNames = {
	"CONSTRUCTOR",
	"RAIDER",
	"SKIRMISHER",
	"RIOT",
	"ASSAULT",
	"ARTILLERY",
	"WEIRD_RAIDER",
	"ANTI_AIR",
	"HEAVY_SOMETHING",
	"SPECIAL",
	"UTILITY",
}
local typeNamesLower = {}
for i = 1, #typeNames do
	typeNamesLower[i] = "pos_" .. typeNames[i]:lower()
end

local sqrt = math.sqrt
local cloakFootMult = 6 * sqrt(2)
local BP2RES = 0
local BP2RES_FACTORY = 0
local BP2TERRASPEED = 1000 --used to be 60 in most of the cases
local factorybonus = 500
local platebonus = 250
local conbonus = 15
local TURNRATE_MULT_BOT = 1
local TURNRATE_MULT_VEH = 1
local ACCEL_MULT_BOT = 1
local ACCEL_MULT_VEH = 1
local REPAIR_ENERGY_COST_FACTOR = (Game and Game.repairEnergyCostFactor) or 0.666 -- Game.repairEnergyCostFactor
local gifts = {"present_bomb1.s3o", "present_bomb2.s3o","present_bomb3.s3o"}
local VISUALIZE_SELECTION_VOLUME = false
local CYL_SCALE = 1.1
local CYL_LENGTH = 0.8
local CYL_ADD = 5
local SEL_SCALE = 1.5
local STATIC_SEL_SCALE = 1.35
local valkDef = UnitDefs.gunshiptrans
local valkMaxMass = valkDef.transportmass
local valkMaxSize = valkDef.transportsize

local nuclearwardefs = {
	["BIG_UNITEX"] = "BOMBERHEAVY_DEATHEXPLO",
	["PYRO_DEATH"] = "1_COMMWEAPON_SLAMROCKET",
	["SMALL_BUILDINGEX"] = "1_COMMWEAPON_SLAMROCKET",
	["ESTOR_BUILDINGEX"] = "BOMBERHEAVY_DEATHEXPLO",
	["BIG_UNITEX"] = "VEHHEAVYARTY_CORTRUCK_ROCKET",
	["ATOMIC_BLAST"] = "BOMBERHEAVY_DEATHEXPLO",
	["BIG_UNIT"] = "NUCLEAR_MISSILE",
	["ATOMIC_BLASTSML"] = "VEHHEAVYARTY_CORTRUCK_ROCKET",
	["FAC_PLATEEX"] = "VEHHEAVYARTY_CORTRUCK_ROCKET",
	["NOWEAPON"] = "1_COMMWEAPON_SLAMROCKET",
	["ESTOR_BUILDING"] = "BOMBERHEAVY_DEATHEXPLO",
	["SMALL_UNITEX"] = "TACNUKETRACKER_WEAPON",
	["LARGE_BUILDINGEX"] = "BOMBERHEAVY_DEATHEXPLO",
	["JUMPBOMB_DEATH"] = "BOMBERHEAVY_DEATHEXPLO",
	["CRAWL_BLASTSML"] = "NUCLEAR_MISSILE",
	["MEDIUM_BUILDINGEX"] = "TACNUKETRACKER_WEAPON",
	["GUNSHIPEX"] = "TACNUKETRACKER_WEAPON",
	["BIG_UNITEX_MERL"] = "NUCLEAR_MISSILE",
	["TINY_BUILDINGEX"] = "1_COMMWEAPON_SLAMROCKET",
}
	

for name, ud in pairs(UnitDefs) do
	local cp = ud.customparams
	-- custom params become strings --
	if (ud.customparams) then
		for tag, v in pairs(ud.customparams) do
			if (type(v) == "table") then
				local str = TableToString(v)
				ud.customparams[tag] = str
			elseif (type(v) ~= "string") then
				ud.customparams[tag] = tostring(v)
			end
		end
	end
	-- fix zk defs? --
	if ud.metalcost then
		ud.buildcostmetal = ud.metalcost
	end
	
	-- Speed fixes --
	if ud.speed and ud.speed > 0 and ud.speed < 30 then -- this should impact less units than the first time. FIXME: Remove when all base units are in the mod.
		ud.speed = ud.speed * 30
	end
	ud.rspeed = (ud.maxreversevelocity and ud.maxreversevelocity * 30) or (ud.speed and ud.speed / 8) or 0 -- maybe maxreversevelocity is still frame based?
	-- Set units that ignore map-side gadgetted placement resitrctions
	-- see http://springrts.com/phpbb/viewtopic.php?f=13&t=27550
	if (ud.speed and ud.speed > 0) or ud.customparams.mobilebuilding then
		ud.customparams.ignoreplacementrestriction = "true"
	end
	
	-- Add lowflying cat --
	if ud.cruisealt and ud.cruisealt <= 200 then
		ud.category = ud.category .. " lowflying"
	end
	
	-- set build options
	if ud.buildoptions and (#ud.buildoptions == 0) then
		ud.buildoptions = buildOpts
	end
	
	-- Set build options from pos_ customparam
	for i = 1, #typeNamesLower do
		local value = cp[typeNamesLower[i]]
		if value then
			ud.buildoptions = ud.buildoptions or {}
			ud.buildoptions[#ud.buildoptions + 1] = value
		end
	end
	
	-- nuclear war mode --
	if nuclearwar and ud.explodeas and name ~= "terraunit" then
		--Spring.Echo("Nuclear war: " .. name)
		ud.explodeas = string.upper(ud.explodeas)
		
		--Spring.Echo(tostring(ud.explodeas))
		if ((ud.explodeas == "SMALL_BUILDINGEX" or ud.explodeas == "ESTOR_BUILDINGEX") and ud.buildcostmetal > 200) or (ud.explodeas == "GUNSHIPEX" and ud.buildcostmetal > 500) then -- buildings with cost > 270 explode violently
			ud.explodeas = "BOMBERHEAVY_DEATHEXPLO"
		end
		
		if (ud.explodeas == "SMALL_BUILDINGEX" or ud.explodeas == "MEDIUM_BUILDINGEX") and ud.buildcostmetal < 200 then
			ud.explodeas = "TACNUKE_WEAPON"
		end
		if nuclearwardefs[ud.explodeas] then
			ud.explodeas = nuclearwardefs[ud.explodeas]
		end
		
		ud.selfdestructas = ud.explodeas or "NOWEAPON"
		Spring.Echo("Nuclear war: " .. name .. " final: " .. tostring(ud.explodeas))
		
		if name == "staticmissilesilo" or name == "staticnuke" or name == "missilenuke" or name == "tacnuke" then
			ud.buildcostmetal = math.floor(ud.buildcostmetal / 8)
		end
		if name == "staticnuke" or name == "subtacmissile" then
			ud.customparams.stockpiletime = tostring(math.ceil(tonumber(ud.customparams.stockpiletime) / 4))
			ud.customparams.stockpilecost = tostring(math.floor(tonumber(ud.customparams.stockpilecost) / 4))
		end
		if name == "staticantinuke" then
			ud.buildcostmetal = 600
			ud.customparams.neededlink = 30
		end
		if name == "bomberheavy" then
			ud.buildcostmetal =  1500
			ud.health = 4000
		end
		if name == "bomberstrike" then
			ud.buildcostmetal = 400
		end
	end
	
	if (string.find(ud.name, "dyn") or ud.customparams.commtype or ud.customparams.level) and commwars then
		ud.buildoptions = nil
		ud.canassist = false
		ud.repairspeed = ud.workertime * 3
		ud.health = ud.health * 3
		ud.autoheal = (ud.autoheal or 0) * 3
		ud.radardistance = 10000000
		ud.radaremitheight = 100000
	end
	
	-- 3dbuildrange for all none plane builders
	--if (tobool(ud.builder) and not tobool(ud.canfly)) then
	--	ud.buildrange3d = true
	--end
	-- Calculate mincloakdistance based on unit footprint size
	local fx = ud.customparams.decloak_footprint or (ud.footprintx and tonumber(ud.footprintx) or 1)
	local fz = ud.customparams.decloak_footprint or (ud.footprintz and tonumber(ud.footprintz) or 1)
	-- Note that the full power of this equation is never used in practise, since units have square
	-- footprints and most structures don't cloak (the ones that do have square footprints).
	local radius = cloakFootMult * sqrt((fx * fx) + (fz * fz)) + 56
	-- 2x2 = 80
	-- 3x3 = 92
	-- 4x4 = 104
	if (not ud.mincloakdistance) then
		ud.mincloakdistance = radius
	elseif radius < ud.mincloakdistance then
		ud.customparams.cloaker_bestowed_radius = radius
	end
	
	-- Tell UnitDefs about script_reload and script_burst
	if not ud.customparams.dynamic_comm then
		if ud.weapondefs then
			local cobWeapon = (ud.script and ud.script:find("%.cob"))
			for _, wd in pairs(ud.weapondefs) do
				if wd.customparams and wd.customparams.script_reload then
					ud.customparams.script_reload = wd.customparams.script_reload
				end
				if wd.customparams and wd.customparams.script_burst then
					ud.customparams.script_burst = wd.customparams.script_burst
				end
				if wd.customparams and wd.customparams.post_capture_reload then
					ud.customparams.post_capture_reload = wd.customparams.post_capture_reload
				end
				wd.customparams = wd.customparams or {}
				wd.customparams.is_unit_weapon = 1
				if cobWeapon then
					wd.customparams.cob_weapon = 1
				end
			end
		end
	end
	
	-- Units with shields cannot cloak
	-- Set easily readible shield power
	
	if not ud.customparams.dynamic_comm then
		local hasShield = false
		if ud.weapondefs then
			for _, wd in pairs(ud.weapondefs) do
				if wd.weapontype == "Shield" then
					hasShield = true
					if ud.activatewhenbuilt == nil then
						-- some aspects of shields require the unit to be enabled
						ud.activatewhenbuilt = true
					end
					ud.customparams.shield_radius = wd.shieldradius
					ud.customparams.shield_power = wd.shieldpower
					ud.customparams.shield_recharge_delay = (wd.customparams or {}).shield_recharge_delay or wd.shieldrechargedelay
					ud.customparams.shield_rate = (wd.customparams or {}).shield_rate or wd.shieldpowerregen
					break
				end
			end
		end
		if (hasShield or (((not ud.speed) or ud.speed == 0) and not ud.cloakcost)) then
			ud.customparams.cannotcloak = 1
			ud.mincloakdistance = 0
			ud.cloakcost = nil
			ud.cloakcostmoving = nil
			ud.cancloak = false
		end
	end
	
	-- UnitDefs Dont Repeat Yourself
	local cost = math.max (ud.buildcostenergy or 0, ud.buildcostmetal or 0, ud.buildtime or 0) --one of these should be set in actual unitdef file

	--setting uniform buildTime, M/E cost
	if not ud.buildcostenergy then ud.buildcostenergy = cost end
	if not ud.buildcostmetal then ud.buildcostmetal = cost end
	if not ud.buildtime then ud.buildtime = cost end
	if ud.buildtime <= 0 then ud.buildtime = 1 end
	if ud.sightdistance then 
		ud.sonardistance = ud.sightdistance
	end
	
	if ud.customparams.dynamic_comm then -- Dynamic commanders have their explosion handled by unitscript. Also gives them antibait
		ud.explodeas = "noweapon"
		ud.selfdestructas = "noweapon"
		ud.customparams.bait_level_default = 0
	end
	
	--setting uniform M/E storage
	local storage = math.max (ud.metalstorage or 0, ud.energystorage or 0)
	if name:find("factory") or name == "striderhub" then
		storage = factorybonus
	end
	if name:find("plate") then
		storage = platebonus
	end
	--[[if name == "striderfunnelweb" then
		storage = 1200
	end]] -- no longer a builder
	if (ud.workertime and name:find("con") and not name:find("dyn")) then
		storage = storage + (ud.workertime * conbonus)
	end
	if name == "athena" then
		storage = storage + (ud.workertime * 2.5 * conbonus)
	end
	
	if storage > 0 then
		if not ud.metalstorage then ud.metalstorage = storage end
		if not ud.energystorage then ud.energystorage = storage end
	end

	--setting metalmake, energymake, terraformspeed for construction units
	if tobool(ud.builder) and ud.workertime then
		local bp = ud.workertime

		local mult = (ud.customparams.dynamic_comm and 0) or 1
		if ud.customparams.factorytab then
			if not ud.metalmake then ud.metalmake = bp * BP2RES_FACTORY * mult end
			if not ud.energymake then ud.energymake = bp * BP2RES_FACTORY * mult end
		else
			if not ud.metalmake then ud.metalmake = bp * BP2RES * mult end
			if not ud.energymake then ud.energymake = bp * BP2RES * mult end
		end

		if not ud.terraformspeed then
			ud.terraformspeed = bp * BP2TERRASPEED
		end
	end

	--setting standard seismicSignature
	--[[
	if ud.floater or ud.canhover or ud.canfly then
		if not ud.seismicsignature then ud.seismicsignature = 0 end
	else
		if not ud.seismicsignature then ud.seismicsignature = SEISMICSIG end
	end
	]]--

	--setting levelGround
	--[[
	if (ud.isBuilding == true or ud.maxAcc == 0) and (not ud.customParams.mobilebuilding) then --looks like a building
		if ud.levelGround == nil then
			ud.levelGround = false -- or true
		end
	end
	]]--
	
	-- Lua implementation of energyUse
	local energyUse = tonumber(ud.energyuse or 0)
	if energyUse and (energyUse > 0) then
		ud.customparams.upkeep_energy = energyUse
		ud.energyuse = 0
	end
	
	-- Disable smoothmesh; allow use of airpads
	if (ud.canfly) then
		ud.usesmoothmesh = false
		if not ud.maxfuel then
			ud.maxfuel = 1000000
			ud.refueltime = ud.refueltime or 1
		end
	end
	
	-- Maneuverability multipliers, useful for testing.
	if ud.turnrate and ud.acceleration and ud.brakerate and ud.movementclass then
		local class = ud.movementclass

		if class:find("TANK") or class:find("BOAT") or class:find("HOVER") then
			-- NB: also contains some water-walking chickens (as hover)
			ud.turnrate = ud.turnrate * TURNRATE_MULT_VEH
			ud.acceleration = ud.acceleration * ACCEL_MULT_VEH
			ud.brakerate = ud.brakerate * ACCEL_MULT_VEH
			ud.customparams.turn_accel_factor = ud.customparams.turn_accel_factor or 1.2
		else
			ud.turnrate = ud.turnrate * TURNRATE_MULT_BOT
			ud.acceleration = ud.acceleration * ACCEL_MULT_BOT
			ud.brakerate = ud.brakerate * ACCEL_MULT_BOT
			ud.customparams.turn_accel_factor = ud.customparams.turn_accel_factor or 1.2
		end
	end
	
	-- Energy Bonus, fac cost mult
	if (modOptions and modOptions.energymult) then
		local em = UnitDefs[name].energymake
		if (em) then
			UnitDefs[name].energymake = em * modOptions.energymult
		end
	end
	if (modOptions and modOptions.metalmult) then
		UnitDefs[name].metalmake = (UnitDefs[name].metalmake or 0) * modOptions.metalmult
	end
	
	-- unitspeedmult
	if (modOptions and modOptions.unitspeedmult and modOptions.unitspeedmult ~= 1) then
		local unitspeedmult = modOptions.unitspeedmult
		if (ud.speed) then
			ud.speed = ud.speed * unitspeedmult
		end
		if (ud.acceleration) then
			ud.acceleration = ud.acceleration * unitspeedmult
		end
		if (ud.brakerate) then
			ud.brakerate = ud.brakerate * unitspeedmult
		end
		if (ud.turnrate) then
			ud.turnrate = ud.turnrate * unitspeedmult
		end
	end
	if (modOptions and modOptions.damagemult and modOptions.damagemult ~= 1) then
		local damagemult = modOptions.damagemult
		if (ud.autoheal) then
			ud.autoheal = ud.autoheal * damagemult
		end
		if (ud.idleautoheal) then
			ud.idleautoheal = ud.idleautoheal * damagemult
		end
		if (ud.capturespeed) then 
			ud.capturespeed = ud.capturespeed * damagemult
		elseif (ud.workertime) then
			ud.capturespeed = ud.workertime * damagemult
		end
		
		if (ud.repairspeed) then 
			ud.repairspeed = ud.repairspeed * damagemult
		elseif (ud.workertime) then
			ud.repairspeed = ud.workertime * damagemult
		end
	end
	
	-- Lua access to colvol axis is impossible I think, so let's add it to CP.
	if ud.collisionvolumetype then
		local t = ud.collisionvolumetype
		local r
		t = t:lower()
		if t == "sphere" or t == "box" then
			r = 0
		elseif t == "cylx" then
			r = 0
		elseif t == "cyly" then
			r = 1
		elseif t == "cylz" then
			r = 2
		else
			r = 0
		end
		ud.customparams.colvolaxis = r
	end
	
	-- Set turnInPlace speed limits, reverse velocities (but not for ships)
	if ud.turnrate and (ud.turnrate > 600 or ud.customparams.turnatfullspeed) then
		ud.turninplace = false
		ud.turninplacespeedlimit = (ud.speed or 0)
	elseif ud.turninplace ~= true then
		ud.turninplace = false	-- true
		ud.turninplacespeedlimit = ud.turninplacespeedlimit or (ud.speed and ud.speed*0.6 or 0)
		--ud.turninplaceanglelimit = 180
	end


	if ud.category and not (ud.category:find("SHIP", 1, true) or ud.category:find("SUB", 1, true)) then
		if (ud.speed) and not ud.maxreversevelocity then
			if not name:find("chicken", 1, true) then
				ud.maxreversevelocity = ud.speed * 0.33
			end
		end
	end
	
	-- Set to accelerate towards their destination regardless of heading
	if ud.hoverattack then
		ud.turninplaceanglelimit = 180
	end
	
	-- 2x repair speed than BP
	if (ud.repairspeed) then
		ud.repairspeed = ud.repairspeed / REPAIR_ENERGY_COST_FACTOR
	elseif (ud.workertime) then
		ud.repairspeed = ud.workertime / REPAIR_ENERGY_COST_FACTOR
	end
	
	-- Set higher default losEmitHeight. Engine default is 20.
	if not ud.losEmitHeight then
		ud.losEmitHeight = 30
	end
	
	-- Avoid firing at unarmed
	if (ud.weapons and not ud.canfly) then
		for wName, wDef in pairs(ud.weapons) do
			if wDef.badtargetcategory then
				wDef.badtargetcategory = wDef.badtargetcategory .. " STUPIDTARGET"
			else
				wDef.badtargetcategory = "STUPIDTARGET"
			end
		end
	end
	if not ud.customparams.chase_everything then
		if not ud.canfly then
			ud.nochasecategory = (ud.nochasecategory or "") .. " STUPIDTARGET"
		else
			ud.nochasecategory = (ud.nochasecategory or "") .. " SOLAR"
		end
	end
	-- Avoid neutral	-- breaks explicit attack orders
	--[[if (ud.weapondefs) then
		for wName,wDef in pairs(ud.weapondefs) do
			wDef.avoidneutral = true
		end
	end]]
	
	-- Set airLOS
	ud.airsightdistance = (ud.sightdistance or 0)
	
	-- Set mass
	ud.mass = (((ud.buildtime/2) + (ud.health/8))^0.6)*6.5
	if ud.customparams.massmult then
		ud.mass = ud.mass*ud.customparams.massmult
	end
	if ud.customparams.massoverride then
		ud.mass = tonumber(ud.customparams.massoverride) or ud.mass
	end
	
	-- Set incomes
	if ud.metalmake and ud.metalmake > 0 then
		ud.customparams.income_metal = ud.metalmake
		ud.activatewhenbuilt = true
		ud.metalmake = 0
	end
	if ud.energymake and ud.energymake > 0 then
		ud.customparams.income_energy = ud.energymake
		ud.activatewhenbuilt = true
		ud.energymake = 0
	end
	
	-- Cost Checking
	--if ud.buildcostmetal ~= ud.buildcostenergy or ud.buildtime ~= ud.buildcostenergy then
	--	Spring.Echo("Inconsistent Cost for " .. ud.name)
	--end
	
	-- Festive units mod option (CarRepairer's WIP)
	if (modOptions and tobool(modOptions.xmas)) then
		if (type(ud.weapondefs) == "table") then
			for wname, wd in pairs(ud.weapondefs) do
				if (wd.weapontype == "AircraftBomb" or ( wd.name:lower() ):find("bomb")) and not wname:find("bogus") then
					--Spring.Echo(wname)
					wd.model = gifts[ GetRandom(wname, #gifts) ]
				end
			end
		end
	end

	-- Make statics unable to pen rafflesia
	-- We check if speed is lower than 1 since starlight_satellite has a speed of 0.03
	if ((ud.speed or 0) < 1) then
		if (type(ud.weapondefs) == "table") then
			for wname, weaponDef in pairs(ud.weapondefs) do
				--if weaponDef.interceptedbyshieldtype and weaponDef.range and weaponDef.range > 1500 and
				--	not weaponDef.customparams.not_artillery then
				if weaponDef.interceptedbyshieldtype then
					local mod = weaponDef.interceptedbyshieldtype % 16
					if mod < 8 then
						weaponDef.interceptedbyshieldtype = weaponDef.interceptedbyshieldtype + 8
					end
				end
			end
		end
	end
	
	-- Remove initCloaked because cloak state is no longer used
	if tobool(ud.initcloaked) then
		ud.initcloaked = false
		ud.customparams.initcloaked = "1"
	end
	
	-- Automatically generate some big selection volumes.
	local scale = STATIC_SEL_SCALE
	if ud.acceleration and ud.acceleration > 0 and ud.canmove then
		scale = SEL_SCALE
	end
	if ud.customparams.selectionscalemult then
		scale = ud.customparams.selectionscalemult
	end
	
	if ud.collisionvolumescales or ud.selectionvolumescales then
		-- Do not override default colvol because it is hard to measure.
		
		if not ud.selectionvolumescales then
			local size = math.max(ud.footprintx or 0, ud.footprintz or 0)*15
			if size > 0 then
				local dimensions, largest = GetDimensions(ud.collisionvolumescales)
				local x, y, z = size, size, size
				if size > largest then
					ud.selectionvolumeoffsets = ud.selectionvolumeoffsets or "0 0 0"
					ud.selectionvolumetype    = ud.selectionvolumetype or "ellipsoid"
				elseif string.lower(ud.collisionvolumetype) == "cylx" then
					ud.selectionvolumeoffsets = ud.selectionvolumeoffsets or ud.collisionvolumeoffsets or "0 0 0"
					x = dimensions[1]*CYL_LENGTH
					y = math.max(dimensions[2], math.min(size, CYL_ADD + dimensions[2]*CYL_SCALE))
					z = math.max(dimensions[3], math.min(size, CYL_ADD + dimensions[3]*CYL_SCALE))
					ud.selectionvolumetype    = ud.selectionvolumetype or ud.collisionvolumetype
				elseif string.lower(ud.collisionvolumetype) == "cyly" then
					ud.selectionvolumeoffsets = ud.selectionvolumeoffsets or ud.collisionvolumeoffsets or "0 0 0"
					x = math.max(dimensions[1], math.min(size, CYL_ADD + dimensions[1]*CYL_SCALE))
					y = dimensions[2]*CYL_LENGTH
					z = math.max(dimensions[3], math.min(size, CYL_ADD + dimensions[3]*CYL_SCALE))
					ud.selectionvolumetype    = ud.selectionvolumetype or ud.collisionvolumetype
				elseif string.lower(ud.collisionvolumetype) == "cylz" then
					ud.selectionvolumeoffsets = ud.selectionvolumeoffsets or ud.collisionvolumeoffsets or "0 0 0"
					x = math.max(dimensions[1], math.min(size, CYL_ADD + dimensions[1]*CYL_SCALE))
					y = math.max(dimensions[2], math.min(size, CYL_ADD + dimensions[2]*CYL_SCALE))
					z = dimensions[3]*CYL_LENGTH
					ud.selectionvolumetype    = ud.selectionvolumetype or ud.collisionvolumetype
				elseif string.lower(ud.collisionvolumetype) == "box" then
					ud.selectionvolumeoffsets = ud.selectionvolumeoffsets or "0 0 0"
					x = dimensions[1]
					y = dimensions[2]
					z = dimensions[3]
					ud.selectionvolumetype    = ud.selectionvolumetype or ud.collisionvolumetype
				end
				ud.selectionvolumescales  = math.ceil(x*scale) .. " " .. math.ceil(y*scale) .. " " .. math.ceil(z*scale)
			end
		end
	else
		ud.customparams.lua_selection_scale = scale -- Scale default colVol units in lua, where we can read their model radius.
	end
	
	if VISUALIZE_SELECTION_VOLUME then
		if ud.selectionvolumescales then
			ud.collisionvolumeoffsets = ud.selectionvolumeoffsets
			ud.collisionvolumescales  = ud.selectionvolumescales
			ud.collisionvolumetype    = ud.selectionvolumetype
		end
	end
	--Spring.Echo("VISUALIZE_SELECTION_VOLUME", ud.name, ud.collisionvolumescales, ud.selectionvolumescales)
	
	-- Altered unit health mod option
	if modOptions and modOptions.hpmult and modOptions.hpmult ~= 1 then
		local hpMulti = modOptions.hpmult
		if ud.health and ud.unitname ~= "terraunit" then
			ud.health = math.max(ud.health * hpMulti, 1)
		end
	end
	
	-- Remove Restore
	if tobool(ud.builder) then
		ud.canrestore = false
		--ud.shownanospray = true
	end
	
	-- Set chicken cost
	--[[if (ud.unitname:sub(1,7) == "chicken") then
		ud.buildcostmetal = ud.buildtime
		ud.buildcostenergy = ud.buildtime
	end]]
	
	-- Category changes
	if ((ud.speed or 0) > 0) then
		ud.category = ud.category .. " MOBILE"
	end
	
	-- Implement modelcenteroffset
	if ud.modelcenteroffset then
		ud.customparams.aimposoffset = ud.modelcenteroffset
		ud.customparams.midposoffset = ud.modelcenteroffset
		ud.modelcenteroffset = "0 0 0"
	end
	
	-- Replace regeneration with Lua
	if (ud.autoheal and (ud.autoheal > 0)) then
		ud.customparams.idle_regen = ud.autoheal
		ud.idletime = 0
	else
		ud.customparams.idle_regen = ud.idleautoheal or autoheal_defaults.idleautoheal
		ud.idletime = ud.idletime or autoheal_defaults.idletime
	end

	ud.idleautoheal = 0
	ud.autoheal = 0
	
	-- Set defaults for area cloak
	if cp.area_cloak and (cp.area_cloak ~= "0") then
		if not cp.area_cloak_upkeep then cp.area_cloak_upkeep = tostring(area_cloak_defaults.upkeep) end
		if not cp.area_cloak_radius then cp.area_cloak_radius = tostring(area_cloak_defaults.radius) end

		if not cp.area_cloak_grow_rate then cp.area_cloak_grow_rate = tostring(area_cloak_defaults.grow_rate) end
		if not cp.area_cloak_shrink_rate then cp.area_cloak_shrink_rate = tostring(area_cloak_defaults.shrink_rate) end
		if not cp.area_cloak_decloak_distance then cp.area_cloak_decloak_distance = tostring(area_cloak_defaults.decloak_distance) end

		if not cp.area_cloak_init then cp.area_cloak_init = tostring(area_cloak_defaults.init) end
		if not cp.area_cloak_draw then cp.area_cloak_draw = tostring(area_cloak_defaults.draw) end
		if not cp.area_cloak_self then cp.area_cloak_self = tostring(area_cloak_defaults.self) end
	end
	
	-- Set defaults for jump
	if cp.canjump == "1" then
		if not cp.jump_range then cp.jump_range = tostring(jump_defaults.range) end
		if not cp.jump_height then cp.jump_height = tostring(jump_defaults.height) end
		if not cp.jump_speed then cp.jump_speed = tostring(jump_defaults.speed) end
		if not cp.jump_reload then cp.jump_reload = tostring(jump_defaults.reload) end
		if not cp.jump_delay then cp.jump_delay = tostring(jump_defaults.delay) end

		if not cp.jump_from_midair then cp.jump_from_midair = tostring(jump_defaults.from_midair) end
		if not cp.jump_rotate_midair then cp.jump_rotate_midair = tostring(jump_defaults.rotate_midair) end
		if not cp.jump_spread_exception then cp.jump_spread_exception = tostring(jump_defaults.spread_exception) end
	end
	
	-- Remove engine transport limits
	if not Script then -- 104-600, but Script.IsEngineMinVersion wasn't available back then
		-- set up structure transports:
		if ud.yardmap ~= nil and ud.customparams.istacmissile == nil and ud.customparams.isgeo == nil and ud.buildcostmetal <= TRANSPORT_STRUCT_COST_MAX and not ud.customparams.child_of_factory and not ud.customparams.parent_of_plate and not ud.customparams.ismex then
			if ud.buildcostmetal > TRANSPORT_LIGHT_STRUCT_COST_MAX then
				ud.customparams.requireheavytrans = 1
			end
			ud.cantbetransported = false
			ud.transportbyenemy = false
		end
			
		ud.transportmass = nil
		if ud.buildcostmetal and tonumber(ud.buildcostmetal) > TRANSPORT_LIGHT_COST_MAX then
			ud.customparams.requireheavytrans = 1
		end
	else
		--[[ old engines handle transporting rules entirely on their own,
	     but mark units anyway so that other code doesn't need to
	     replicate these checks ]]
		if ud.mass > valkMaxMass or
				ud.footprintx > valkMaxSize or
				ud.footprintz > valkMaxSize then
			ud.customparams.requireheavytrans = 1
		end
	end
end

local ai_start_units = VFS.Include("LuaRules/Configs/ai_commanders.lua")
for i = 1, #ai_start_units do
	UnitDefs[ai_start_units[i]].customparams.ai_start_unit = true
end

if not Script or not Script.IsEngineMinVersion(105, 0, 1801) then
	for name, ud in pairs(UnitDefs) do
		ud.metaluse  = ud.metalupkeep
		ud.energyuse = ud.energyupkeep
		ud.buildcostmetal  = ud.metalcost
		ud.buildcostenergy = ud.energycost
		ud.health = ud.health
		if ud.speed then
			ud.speed = ud.speed / Game.gameSpeed
		end
		if ud.rspeed then
			ud.maxreversevelocity = ud.rspeed / Game.gameSpeed
		end
	end
end
