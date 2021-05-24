function gadget:GetInfo()
	return {
		name      = "NanoRegen",
		desc      = "Allows units with nanoregen to regen.",
		author    = "Shaman",
		date      = "1/17/2021",
		license   = "CC-0",
		layer     = 1,
		enabled   = true,
	}
end

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local units = {}
local config = {}
local updaterate = 15

-- speed ups --
local spGetUnitHealth = Spring.GetUnitHealth
local spSetUnitHealth = Spring.SetUnitHealth
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local INLOS = {inlos = true}
local min = math.min
local max = math.max

--config--

for i = 1, #UnitDefs do
	local def = UnitDefs[i]
	local cp = def.customParams
	if cp.nanoregen then
		config[i] = {
			regen = tonumber(cp.nanoregen) or 0,
			maxregenmult = tonumber(cp.nano_maxregen) or 300,
		}
		if config[i].regen == 0 then
			config[i] = nil
		else
			config[i].regen = config[i].regen / (30 / updaterate)
		end
	end
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if config[unitDefID] then
		units[unitID] = unitDefID
	end
end

function gadget:GameFrame(f)
	if f%updaterate == 3 then -- before idle regen.
		for id, unitdef in pairs(units) do
			local hp, maxhp = spGetUnitHealth(id)
			if hp then
				local data = config[unitdef]
				local actualregen = (data.regen * (1 - (spGetUnitRulesParam(id, "slowState") or 0))) * (30 / updaterate) * min(1/(max(hp, 1)/maxhp), data.maxregenmult)
				spSetUnitRulesParam(id, "nanoregen", actualregen, INLOS)
				if hp < maxhp then
					hp = min(hp + actualregen, maxhp)
					spSetUnitHealth(id, hp)
					if hp == maxhp then
						units[id] = nil
						spSetUnitRulesParam(id, "nanoregen", nil)
					end
				else
					units[id] = nil
					spSetUnitRulesParam(id, "nanoregen", nil)
				end
			else
				units[id] = nil
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	units[unitID] = nil
	spSetUnitRulesParam(unitID, "nanoregen", nil)
end

