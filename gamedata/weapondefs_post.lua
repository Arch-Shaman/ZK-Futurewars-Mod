-- $Id: weapondefs_post.lua 3171 2008-11-06 09:06:29Z det $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    weapondefs_post.lua
--  brief:   weaponDef post processing
--  author:  Dave Rodgers Rewritten by Shaman.
--
--  Copyright (C) 2008.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Spring.Echo("Loading WeaponDefs_posts")

--  Dynamic Comms
VFS.Include('gamedata/modularcomms/weapondefgen.lua')


--  Per-unitDef weaponDefs

local function isbool(x)
	return (type(x) == 'boolean') 
end
local function istable(x)
	return (type(x) == 'table')
end
local function isnumber(x)
	return (type(x) == 'number')
end
local function isstring(x)
	return (type(x) == 'string')
end


--------------------------------------------------------------------------------

local function RawCanAttack(ud)
	if (ud.weapons) then
		for i, weapon in pairs(ud.weapons) do
			if weapon.name == nil then
				Spring.Echo("Nil weapon name: " .. ud.name .. ": " .. i)
			end
			local wd = WeaponDefs[weapon.name:lower()]
			if wd.weapontype ~= "Shield" and not wd.interceptor then
				return true
			end
		end
	end
	if (ud.kamikaze) then
		return not ud.yardmap
	end
	return false
end

local function CanAttack(ud)
	local isFac = ud.yardmap and ud.buildoptions
	if isFac or RawCanAttack(ud) then
		return true
	end
	return false
end

local function ProcessUnitDef(udName, ud)

	local wds = ud.weapondefs
	if (not istable(wds)) then
		return
	end

	-- add this unitDef's weaponDefs
	for wdName, wd in pairs(wds) do
		if (isstring(wdName) and istable(wd)) then
			local fullName = udName .. '_' .. wdName
			WeaponDefs[fullName] = wd
			wd.filename = ud.filename
		end
	end

	-- convert the weapon names
	local weapons = ud.weapons
	if (istable(weapons)) then
		for i = 1, 16 do
			local w = weapons[i]
			if (istable(w)) then
				if (isstring(w.def)) then
					local ldef = string.lower(w.def)
					local fullName = udName .. '_' .. ldef
					local wd = WeaponDefs[fullName]
					if (istable(wd)) then
						w.name = fullName
					end
				end
				w.def = nil
			end
		end
	end
	
	-- convert the death explosions
	if (isstring(ud.explodeas)) then
		local fullName = udName .. '_' .. string.lower(ud.explodeas)
		if (WeaponDefs[fullName]) then
			ud.explodeas = fullName
		end
	end
	if (isstring(ud.selfdestructas)) then
		local fullName = udName .. '_' .. string.lower(ud.selfdestructas)
		if (WeaponDefs[fullName]) then
			ud.selfdestructas = fullName
		end
	end
	
	
	-- Fix the canAttack tag
	if not ud.canattack then
		ud.canattack = CanAttack(ud)
	end
	
end


-- Process the unitDefs

local UnitDefs = DEFS.unitDefs

for udName, ud in pairs(UnitDefs) do
	if (isstring(udName) and istable(ud)) then
		ProcessUnitDef(udName, ud)
	end
end

local modOptions = Spring.GetModOptions() or {}
local damagemult = modOptions.damagemult or 1
local area_damage_defaults = VFS.Include("gamedata/unitdef_defaults/area_damage_defs.lua")
local cratermults = modOptions.cratermult or 1

local aaDamageToGroundMult = 0.1

for defname, weaponDef in pairs(WeaponDefs) do -- In ZK's version this is a series of for loops. I've just unified them. Probably shaves some time off loading.
	-- customparams is never nil
	weaponDef.customparams = weaponDef.customparams or {} 
	
	-- Apply remaim_time
	if not (weaponDef.customparams.reaim_time or string.find(defname, "chicken")) then
		weaponDef.customparams.reaim_time = 5
	end

	-- Hack for flamer
	if weaponDef.cegtag == "flamer" then
		weaponDef.cegtag = "napalmtrail_halfsize"
	end
	
	if weaponDef.customparams["isaa"] then
		--for name, damage in pairs(weaponDef.damage) do
			--Spring.Echo(name, damage)
		--end
		--Spring.Echo(defname)
		local damage = weaponDef.damage["default"]
		weaponDef.damage["default"] = damage * aaDamageToGroundMult
		weaponDef.damage["planes"] = damage
	end
	
	-- Set shield starting power to 100%
	if weaponDef.shieldpower and (weaponDef.shieldpower < 2000) and not weaponDef.shieldstartingpower then
		weaponDef.shieldstartingpower = weaponDef.shieldpower
		weaponDef.customparams.shieldstartingpower = weaponDef.shieldstartingpower
	end
	
	-- Set lenient fire tolerance
	if not weaponDef.firetolerance then
		weaponDef.firetolerance = 32768 -- Full 180 degrees on either side.
	end
	
	-- Preserve crater sizes for new engine
	-- https://github.com/spring/spring/commit/77c8378b04907417a62c25218d69ff323ba74c8d
	
	if (not weaponDef.craterareaofeffect) then
		weaponDef.craterareaofeffect = tonumber(weaponDef.areaofeffect or 0) * 1.5
	end
	
	-- New engine seems to have covertly increased the effect of cratermult
	weaponDef.cratermult = (weaponDef.cratermult or 1) * 0.3 * (modOptions.cratermult or 1)
	
	-- https://github.com/spring/spring/commit/dd7d1f79c3a9b579f874c210eb4c2a8ae7b72a16
	if ((weaponDef.weapontype == "LightningCannon") and (not weaponDef.beamttl)) then
		weaponDef.beamttl = 10
	end
	
	-- Disable sweepfire until we know how to use it
	weaponDef.sweepfire = false -- Shaman's note: This is quite useless. Don't undisable it.
	
	-- Disable burnblow for LaserCannons because overshoot is not a problem for any
	-- of them and is important for some.
	if weaponDef.weapontype == "LaserCannon" then
		weaponDef.burnblow = false
	end
	
	-- Set myGravity for Cannons because maps cannot be trusted. Standard is 120,
	-- gravity of 150 can cause high things (such as HLT) to be unhittable.
	if weaponDef.weapontype == "Cannon" and not weaponDef.mygravity then
		weaponDef.mygravity = 2/15 -- 120/(GAME_SPEED^2)
	end
	
	-- because the way lua access to unitdefs and weapondefs is setup is insane
	if weaponDef.mygravity then
		weaponDef.customparams.mygravity = weaponDef.mygravity -- For attack AOE widget
    end
	if weaponDef.flighttime then
		weaponDef.customparams.flighttime = weaponDef.flighttime
    end
	if weaponDef.weapontimer then
		weaponDef.customparams.weapontimer = weaponDef.weapontimer
    end
	if weaponDef.weaponvelocity then
		weaponDef.customparams.weaponvelocity = weaponDef.weaponvelocity -- For attack AOE widget
	end
	if weaponDef.dyndamageexp and (weaponDef.dyndamageexp > 0) then
		weaponDef.customparams.dyndamageexp = weaponDef.dyndamageexp
	end
	if weaponDef.flighttime and (weaponDef.flighttime > 0) then
		weaponDef.customparams.flighttime = weaponDef.flighttime
	end
	
	local name = weaponDef.name
	if name:find('fake') or name:find('Fake') or name:find('Bogus') or name:find('NoWeapon') then
		weaponDef.customparams.fake_weapon = 1
	end
	
	-- Set defaults for napalm (area damage)
	if weaponDef.customparams.area_damage then
		if not weaponDef.customparams.area_damage_dps then weaponDef.customparams.area_damage_dps = area_damage_defaults.dps end
		if not weaponDef.customparams.area_damage_radius then weaponDef.customparams.area_damage_radius = area_damage_defaults.radius end
		if not weaponDef.customparams.area_damage_duration then weaponDef.customparams.area_damage_duration = area_damage_defaults.duration end
		if not weaponDef.customparams.area_damage_plateau_radius then weaponDef.customparams.area_damage_plateau_radius = area_damage_defaults.plateau_radius end
		if not weaponDef.customparams.area_damage_is_impulse then weaponDef.customparams.area_damage_is_impulse = area_damage_defaults.is_impulse end
		if not weaponDef.customparams.area_damage_range_falloff then weaponDef.customparams.area_damage_range_falloff = area_damage_defaults.range_falloff end
		if not weaponDef.customparams.area_damage_time_falloff then weaponDef.customparams.area_damage_time_falloff = area_damage_defaults.time_falloff end
	end
	
	-- default noSelfDamage
	weaponDef.noselfdamage = (weaponDef.noselfdamage ~= false)
	-- remove experience bonuses
	weaponDef.ownerExpAccWeight = 0
	-- Workaround for http://springrts.com/mantis/view.php?id=4104
	if weaponDef.texture1 == "largelaserdark" then
		weaponDef.texture1 = "largelaserdark_long"
		weaponDef.tilelength = (weaponDef.tilelength and weaponDef.tilelength*4) or 800
	end
	if weaponDef.texture1 == "largelaser" then
		weaponDef.texture1 = "largelaser_long"
		weaponDef.tilelength = (weaponDef.tilelength and weaponDef.tilelength*4) or 800
	end
	-- Take over the handling of shield energy drain from the engine.
	if weaponDef.shieldpowerregenenergy and weaponDef.shieldpowerregenenergy > 0 then
		weaponDef.customparams = weaponDef.customparams or {}
		
		weaponDef.customparams.shield_rate = weaponDef.shieldpowerregen
		weaponDef.customparams.shield_drain = weaponDef.shieldpowerregenenergy
		
		weaponDef.shieldpowerregen = 0
		weaponDef.shieldpowerregenenergy = 0
	end
	-- Set hardStop for defered lighting and to reduce projectile count
	if weaponDef.weapontype == "LaserCannon" and weaponDef.hardstop == nil then
		weaponDef.hardstop = true
	end
	-- Reduce rounding error in damage
	if weaponDef.impactonly then
		weaponDef.edgeeffectiveness = 1
	end
	-- ???
	if weaponDef.paralyzetime and not weaponDef.paralyzer then
		weaponDef.customparams.extra_paratime = weaponDef.paralyzetime
	end
	if not weaponDef.predictboost then
		weaponDef.predictboost = 1
	end
	
	-- Get rid of useless damage.
	if weaponDef.name == "NoWeapon" then
		weaponDef.customparams.norealdamage = 1
	end
	-- mass calculations
	
	if weaponDef.customparams.bogus == nil and weaponDef.customparams.mass == nil and weaponDef.weapontype ~= "Shield" and weaponDef.weapontype ~= "Laser" and not string.lower(weaponDef.name):find("fake") then
		local damageformass = 0
		local default = tonumber(weaponDef.damage["default"]) or 0
		local air = tonumber(weaponDef.damage["planes"]) or 0
		damageformass = math.max(default, air)
		local grav = weaponDef.mygravity or 0
		if grav == 0 then
			grav = 0.1
		end
		weaponDef.customparams.mass = math.max((damageformass / 100) / grav , 1)
		--Spring.Echo("ID: " .. weaponDef.name, weaponDef.customparams.mass)
	end
	if weaponDef.customparams.norealdamage then
		weaponDef.customparams["damage_vs_feature"] = "0"
	end
	-- Modoptions --
	if weaponDef.damage then --and weaponDef.name and not string.find(weaponDef.name, "Disintegrator")) then
		for damagetype, amount in pairs(weaponDef.damage) do
			weaponDef.damage[damagetype] = amount * damagemult
		end
	end
end
