VFS.Include("LuaRules/Utilities/tablefunctions.lua")

local CopyTable = Spring.Utilities.CopyTable


local function genChix(name, step, chix)
	local params = chix.customparams

	local mult = 2.718281828 ^ (step/2)
	local hpMult, dmgMult, rangeMult
	if chix.chicken_structure then
		hpMult = mult^1.1
		dmgMult = mult^0.3
		rangeMult = (1 + step/5)^0.5
	else
		hpMult = mult^1.5
		dmgMult = mult
		rangeMult = 1 + step/10
	end
	
	params.statsname = name
	params.original_chicken = name
	if params.model_rescale_script then
		params.model_rescale_script = (params.model_rescale_script or 1) * (1 + step/10)
	else
		params.model_rescale = (params.model_rescale or 1) * (1 + step/10)
	end
	chix.health = chix.health * hpMult
	chix.power = chix.power * mult
	chix.buildtime = chix.buildtime * mult
	if chix.speed then
		chix.speed = chix.speed * rangeMult
	end
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

local function genDefs(defs, minStep, maxStep)
	minStep = minStep or 1
end

-- Hold new chickens so pairs doesn't get confused
local chickenDefs = {}

for name, udef in pairs(UnitDefs) do
	local params = udef.customparams
	if params.chicken then
		minStep = 1
		maxStep = 10
		if params.chicken_menace then
			minStep = -2
			maxStep = 17
		elseif params.chicken_structure then
			maxStep = 15
		end
		Spring.Echo("Generating internal unitDefs for "..name)
		local step
		for i=minStep, maxStep do
			local chix = CopyTable(udef, true)
			local step = i
			if step < 0.5 then
				step = step - 1
			end
			genChix(name, step, chix)
			
			chickenDefs[name.."_"..step] = chix
		end
	end
end

for name, udef in pairs(chickenDefs) do
	UnitDefs[name] = udef
end
	
