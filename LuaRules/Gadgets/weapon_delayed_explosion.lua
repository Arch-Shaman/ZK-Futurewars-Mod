function gadget:GetInfo()
	return {
		name      = "Delayed AOE damage",
		desc      = "Implements delayed AOE damage for projectiles",
		author    = "_Shaman",
		date      = "3/21/2020",
		license   = "CC-0",
		layer     = 32,
		enabled   = false,
	}
end

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end
--[[
local config = {}
local proj = {}
local watchdefs = {}

Delayed: time it takes for the explosion to be delayed. [required]
wepd: the weapondef of the explosion when the timer goes off
damageair: damage % dealt to air units (post processing)
damageshield: damage % to shields
damageemp: amount of emp to deal (absolute)
damageslow: amount of slow damage to deal (absolute)
damagesub: damage % dealt to subs
damagefrequency: frequency (in frames) to deal damage. leave 0 for one off.
damageduration: duration for this explosion to be active.


for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if curRef and curRef.delayed then -- found it!
		Spring.Echo("Delayed AOE: Found projectile: " .. i)
		config[i] = {}
		if curRef.delayed then
			config[i].delay = curRef.delayed
		end
		if curRef.wepd then
			config[i].wepd = curRef.wepd
			local wepid = WeaponDefs[wepd].id
			watchdefs[wepid] = {airmult = 1.0, shieldmult = 1.0, damageslow = 0, damageemp = 0, submult = 1.0, burn = 0, burningdur = 0}
			if curRef.damageair then
				watchdefs[wepid].airmult = curRef.damageair
			end
			if curRef.damageshield then
				watchdefs[wepid].shieldmult = curRef.damageshield
			end
			if curRef.damageemp then
				watchdefs[wepid].emp = curRef.damageemp
			end
			if curRef.burn then
				watchdefs[wepid].burn = curRef.burn
			end
			if curRef.burndur then
				watchdefs[wepid].burndur = curRef.burndur
			end
			if curRef.damageslow then
				watchdefs[wepid].slow = curRef.damageslow
			end
			if curRef.damagesub then
				watchdefs[wepid].submult = curRef.damagesub
			end
			if curRef.damagefrequency then
				config[i].frequency = curRef.damagefrequency
			else
				config[i].frequency = 0
			end
			if curRef.damageduration then
				config[i].duration = curRef.damageduration
			else
				config[i].duration = 0
			end
		else
			
		end
	end
	wd = nil
	curRef = nil
end
spEcho("Delayed AOE: done processing weapondefs")

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if config[weaponDefID] then
		proj[ProjectileID] = {ref = weaponDefID, x = px, y = py,z = pz, delay = config[weaponDefID].delay, duration = config[weaponDefID].duration, freq = config[weaponDefID].frequency}
	end
end

function gadget:GameFrame(f)
	for id,data in pairs(proj) do
		local id = data.ref
		if data.delay > 0 then
			data.delay = proj[i].delay - 1
		else
			data.duration = proj[i].duration - 1
			if data.duration > -1 then
				if f%data.freq == 0 then
					
				end
				data.duration = data.duration - 1
			else
				proj[id] = nil
			end
		end
	end
end]]
