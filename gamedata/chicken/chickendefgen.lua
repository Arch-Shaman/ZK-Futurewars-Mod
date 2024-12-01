VFS.Include("LuaRules/Utilities/tablefunctions.lua")

local CopyTable = Spring.Utilities.CopyTable


local function genChix(name, step, chix)
	local params = chix.customparams

	local mult = 2.718281828 ^ (step/2)
	hpMult = mult^1.5
	dmgMult = mult
	rangeMult = 1 + step/10
	
	params.statsname = name
	params.original_chicken = name
	if params.model_rescale_script then
		params.model_rescale_script = (params.model_rescale_script or 1) * (1 + step/10)
	else
		params.model_rescale = (params.model_rescale or 1) * (1 + step/10)
	end
	chix.health = chix.health * hpMult
	chix.power = (chix.power or chix.buildtime) * mult
	chix.buildtime = chix.buildtime * mult
	--if chix.speed then
	--	chix.speed = chix.speed * rangeMult
	--end

	for name, wdef in pairs(chix.weapondefs or {}) do
		wdef.customparams = wdef.customparams or {}
		local params = wdef.customparams
		if wdef.range then
			params.combatrange = params.combatrange or wdef.range
			wdef.range = wdef.range * (1+step/10)
		end
		if wdef.weaponvelocity and not wdef.noexplode then
			wdef.weaponvelocity = wdef.weaponvelocity * rangeMult
		end
		if wdef.mygravity then
			wdef.mygravity = wdef.mygravity * rangeMult
		end
		if wdef.shieldpower then
			wdef.shieldpower = wdef.shieldpower * hpMult
			wdef.shieldstartingpower = wdef.shieldpower
		end
		if wdef.flightTime then
			wdef.sprayangle = wdef.flightTime * rangeMult
		end
		if params.spawns_name then
			params.spawns_name = params.spawns_name.."_"..step
		end
		for key, dmg in pairs(wdef.damage) do
			wdef.damage[key] = dmg * mult
		end
	end
end

local function postProcessChix(chix, step)
	local params = chix.customparams

	if params.chicken_disable_weapons_below_level and step < params.chicken_disable_weapons_below_level then
		chix.weapondefs = nil
		chix.weapons = nil
	end
end

-- Hold new chickens so pairs doesn't get confused
local chickenDefs = {}

for name, udef in pairs(UnitDefs) do
	local params = udef.customparams
	if params.chicken and (params.chicken_shield or params.chicken_menace or params.chicken_needs_bogus_defs or params.chicken_wants_bogus_defs) then
		if not params.chicken_wants_bogus_defs then
			params.chicken_needs_bogus_defs = true
		end
		minStep = -2
		maxStep = 20
		--if params.chicken_menace then
		--	minStep = -2
		--	maxStep = 17
		--elseif params.chicken_structure then
		--	maxStep = 15
		--end
		local step
		for i=minStep, maxStep do
			local chix = CopyTable(udef, true)
			local step = i
			if step < 0.5 then
				step = step - 1
			end
			genChix(name, step, chix)
			postProcessChix(chix, step)


			chickenDefs[name.."_"..step] = chix
		end
	end

	postProcessChix(udef, 0)
end

for name, udef in pairs(chickenDefs) do
	UnitDefs[name] = udef
end
	
