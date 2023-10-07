if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Syphon/Phaser Handler",
		desc      = "Weapons that deal more damage the longer that are shooting at a  target",
		author    = "Stuff/HTMLPhoton",
		date      = "14/01/2021",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = false, -- Azi is now handled in LUS
	}
end

--[[
Pharsed tags:
(format: pharsed tag = default value
	dmg_scaling = 1					the amount the damage multipler for that weapon of the unit increases per FRAME!
	dmg_scaling_max = math.huge		the max amount the damage multipler can be.
	dmg_scaling_keeptime = 1		the amount of time(frames) before the damage multiplier starts decrasing
	dmg_scaling_falloff = 10		the rate (per FRAME!) at which the damage multipler decreases
	
Notes:
	dmg_scaling needs to be a none-nil value for weapon to have damage scaling
--]]


---------------------------------------------------------------------
---------------------------------------------------------------------
local spEcho = Spring.Echo
local SpGetGameFrame = Spring.GetGameFrame
local SpGetGameSeconds = Spring.GetGameSeconds
local SpGetUnitHealth = Spring.GetUnitHealth
local SpSetUnitRulesParam = Spring.SetUnitRulesParam
---------------------------------------------------------------------
---------------------------------------------------------------------
local units = {}
local phasers = {}
---------------------------------------------------------------------
---------------------------------------------------------------------
local elapsedsecs
local risingsecs
local fallingsecs
local unitdata
local weapondata
---------------------------------------------------------------------
---------------------------------------------------------------------
local newUnitTable = {scaling = 0, lasthittime = 0}
local inlosTrueTable = {inlos = true}
---------------------------------------------------------------------
---------------------------------------------------------------------
local debugmode = false --THIS WILL SPAM THE LIVING HELL OUT OF THE INFOLOGS
---------------------------------------------------------------------
---------------------------------------------------------------------

spEcho("Syphon/Phaser Handler: Scanning weapondefs")
--spEcho("Math.Huge is" .. math.huge)

for q = 1, #WeaponDefs do
	local Wdef = WeaponDefs[q]
	local params = Wdef.customParams
	if params and params.dmg_scaling then
		if debugmode then
			spEcho("SPH: Pharsing Weapon. ID:" .. q .. " Name:".. Wdef.name)
		end
		phasers[q] = {}
		phasers[q].scaling = tonumber(params.dmg_scaling) or 1
		phasers[q].scalingMax = tonumber(params.dmg_scaling_max) or math.huge
		phasers[q].keeptime = tonumber(params.dmg_scaling_keeptime) or 1
		phasers[q].falloff = tonumber(params.dmg_scaling_falloff) or math.huge
	end
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam, projectileID)
	if debugmode then
		spEcho("something got hurt. It still has " .. SpGetUnitHealth(unitID).. " hp remaining.")
	end
	if phasers[weaponDefID] and unitTeam ~= attackerTeam then
		if debugmode then
			spEcho("the attacker is a phaser")
		end
		if not units[unitID] then
			units[unitID] = {}
		end
		if not units[unitID][attackerID] then
			units[unitID][attackerID] = {}
		end
		if not units[unitID][attackerID][weaponDefID] then
			units[unitID][attackerID][weaponDefID] = newUnitTable
		end
		unitdata = units[unitID][attackerID][weaponDefID]
		bonusDmg = unitdata.scaling
		elapsedsecs = SpGetGameFrame()
		risingsecs = elapsedsecs - unitdata.lasthittime
		fallingsecs =  risingsecs - phasers[weaponDefID].keeptime
		if debugmode then
			spEcho("elapsedsecs: " .. elapsedsecs .. "     risingsecs: " .. risingsecs .. "     fallingsecs: " .. fallingsecs)
		end
		if fallingsecs < 0 then
			bonusDmg = bonusDmg + (phasers[weaponDefID].scaling * risingsecs)
			if bonusDmg > phasers[weaponDefID].scalingMax then
				if debugmode then
					spEcho("SPH: Weapon hit maximium dps!")
				end
				bonusDmg = phasers[weaponDefID].scalingMax
			end
		else
			if debugmode then
				spEcho("SPH: We might have a problem")
			end
			bonusDmg = bonusDmg - (phasers[weaponDefID].falloff * fallingsecs)
			if bonusDmg < 0 then
				bonusDmg = 0
			end
		end
		unitdata.lasthittime = elapsedsecs
		unitdata.scaling = bonusDmg
		units[unitID][attackerID][weaponDefID] = unitdata
		if debugmode then
			spEcho("SPH: It dealt " .. (damage * (1 + bonusDmg)) .. " damage with a multiplier of " .. bonusDmg)
		end
		
		SpSetUnitRulesParam(unitID, "CEGdOverride1", ((1 + bonusDmg)^0.67), inlosTrueTable)
		local timeout = SpGetGameFrame()
		timeout = timeout + 3
		SpSetUnitRulesParam(unitID, "CEGdTimeout1", timeout, inlosTrueTable)
		return (damage * (1 + bonusDmg))
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	units[unitID] = nil
end
--testing some stuff
--[[function gadget:GameFrame(f)
	local frame1, frame2 = SpGetGameFrame()
	local secs = SpGetGameSeconds()
	spEcho("frameNum%dayFrames is: " .. frame1 .. "     frameNum // dayFrames is: " .. frame2 .. "     In-game Seconds is: " .. secs)
end]]--
