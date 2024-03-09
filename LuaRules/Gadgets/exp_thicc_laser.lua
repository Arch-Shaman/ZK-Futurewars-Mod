if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "CEG d overrider",
		desc      = "Allows more control over the d operator found in CEGs",
		author    = "Stuff/HTMLPhoton",
		date      = "14/01/2021",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = false,
	}
end

--[[
Expected customParams:
	CEGdOverride = number
the amount of times to override the d operator of CEG.
	explosionGenerator = str
Expected RulesParams:
	CEGdOverride# = number
# can be any number. but if it is higher than the customparams CEGdOverride then the rulesparam wouldn't have any effect
lower values of # take precidence. higher values will only be used if the lower value is nil or has timed out
	CEGdTimeout# = number
if the current frame is greater than this number, treat the CEGdOverride# with the same # as nil
]]--

---------------------------------------------------------------------
---------------------------------------------------------------------
--localising functions
local spEcho = Spring.Echo
local SpGetUnitRulesParam = Spring.GetUnitRulesParam
local SpGetGameFrame = Spring.GetGameFrame
local SpSpawnCEG = Spring.SpawnCEG
---------------------------------------------------------------------
---------------------------------------------------------------------
local handledExplosions = {}

---------------------------------------------------------------------
---------------------------------------------------------------------
local debugmode = false
---------------------------------------------------------------------
---------------------------------------------------------------------

if debugmode then 
	spEcho("CEG d Overrider: Scanning weapondefs")
end

for q=1, #WeaponDefs do
	local Wdef = WeaponDefs[q]
	local params = Wdef.customParams
	if params and params.explosion_generator then
		if debugmode then 
			spEcho("CDO: Pharsing Weapon. ID:" .. q .. " Name:".. Wdef.name)
		end
		handledExplosions[q] = {}
		handledExplosions[q].Overrides = tonumber(params.ceg_d_override) or 1
		handledExplosions[q].ExpGen = params.explosion_generator
		handledExplosions[q].OverrideStart = tonumber(params.ceg_d_override_start) or 1
		Script.SetWatchWeapon(q, true)
	end
end

if debugmode then 
	spEcho("CEG d Overrider: Finished scanning weapondefs")
end

function gadget:Explosion(weaponDefID, px, py, pz, AttackerID, ProjectileID)
	if handledExplosions[weaponDefID] then
		if debugmode then
			spEcho("CDO: Overriding d")
		end
			local d
			local handlingParams = handledExplosions[weaponDefID]
			local Overrides = handlingParams.Overrides
			local ExpGen = handlingParams.ExpGen
			local OverrideStart = handlingParams.OverrideStart
			local frame = SpGetGameFrame()
			for q=OverrideStart, Overrides do
				local z = SpGetUnitRulesParam(AttackerID, ("CEGdOverride" .. q))
				if z then
					local x = SpGetUnitRulesParam(AttackerID, ("CEGdTimeout" .. q))
					if x >= frame then
						d = tonumber(z)
						if debugmode then
							spEcho("CDO: Found D Override of " .. d .. " at iteration " .. q)
						end
						break
					end
				end
			end
			if d then
				if debugmode then
					spEcho("CDO: Spawning CEG " .. ExpGen .. " at (" .. px .. "," .. py .. "," .. pz .. ") with a d of " .. d)
				end
				SpSpawnCEG(ExpGen, px, py, pz, 0, 0, 0, 0, d)
				return true
			end
			return false
	end
end
