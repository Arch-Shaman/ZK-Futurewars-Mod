--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (not gadgetHandler:IsSyncedCode()) then
	return
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Aircraft Crashing",
    desc      = "Handles crashing planes",
    author    = "KingRaptor, Rewritten by Shaman",
    date      = "22 Jan 2011",
    license   = "GNU LGPL, v2.1 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end
--Revision 4
--------------------------------------------------------------------------------
-- speedups
--------------------------------------------------------------------------------
local spGetUnitIsStunned	= Spring.GetUnitIsStunned
local spGetUnitHealth		= Spring.GetUnitHealth
local IterableMap           = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

local aircraftDefIDs = {}
local transportDefs = {}

function gadget:Initialize()
	for i = 1, #UnitDefs do
		if UnitDefs[i].canFly and not UnitDefs[i].customParams.is_drone then
			aircraftDefIDs[i] = true
			if UnitDefs[i].transportSize then
				transportDefs[i] = true
			end
		end
	end
end

local LOS_ACCESS = {inlos = true}
local DAMAGE_MEMORY = 30	-- gameframes


local recentDamage = IterableMap.New()	-- indexed by unitID
local gameFrame = 0

function gadget:GameFrame(f)
	gameFrame = f
	for _, data in IterableMap.Iterator(recentDamage) do
		if data.removalFrames[f] then
			data.damage = data.damage - data.removalFrames[f]
			data.removalFrames[f] = nil
		end
	end
end

local function CallAsUnitIfExists(unitID, funcName)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if not env then
		return
	end
	if env and env[funcName] then
		Spring.UnitScript.CallAsUnit(unitID, env[funcName])
	end
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	if not aircraftDefIDs[unitDefID] then
		return
	end
	local _, _, inBuild = spGetUnitIsStunned(unitID)
	if inBuild then
		return
	end
	--Spring.Echo("Plane damaged")
	local data = IterableMap.Get(recentDamage, unitID)
	if data == nil then
		return
	end
	local health, maxHealth = spGetUnitHealth(unitID)
	data.damage = data.damage + damage -- store this so we don't have to recalculate it when a plane crashes.
	if  health < 0 and (transportDefs[unitDefID] or (data.damage / maxHealth) <= 0.5) then
		--Spring.Echo("Plane shot down")
		CallAsUnitIfExists(unitID, "OnStartingCrash") -- tell the LUS that we're crashing (mostly for transports)
		Spring.SetUnitCrashing(unitID, true)
		Spring.SetUnitNoSelect(unitID, true)
		Spring.SetUnitSensorRadius(unitID, "los", 0)
		Spring.SetUnitSensorRadius(unitID, "airLos", 0)
		Spring.SetUnitRulesParam(unitID, "crashing", 1, LOS_ACCESS)
		if (Spring.GetUnitRulesParam(unitID, "noammo") or 0) < 2 then
			if UnitDefs[unitDefID].hoverAttack then
				Spring.MoveCtrl.SetGunshipMoveTypeData(unitID, "altitudeRate", 75)
			else
				Spring.MoveCtrl.SetAirMoveTypeData(unitID, "myGravity", 2.75) -- try to pull it faster?
			end
		end
		GG.UpdateUnitAttributes(unitID)
		if GG.AircraftCrashingDown then
			GG.AircraftCrashingDown(unitID) --send event to unit_bomber_command.lua to cancel any airpad reservation hold by this airplane
		end
		IterableMap.Remove(recentDamage, unitID)
	elseif health > 0 then
		local removalFrame = gameFrame + DAMAGE_MEMORY
		data.removalFrames[removalFrame] = (data.removalFrames[removalFrame] or 0) + damage
	else
		IterableMap.Remove(recentDamage, unitID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if aircraftDefIDs[unitDefID] then
		IterableMap.Remove(recentDamage, unitID)
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if (not aircraftDefIDs[unitDefID]) or select(3, spGetUnitIsStunned(unitID)) then
		return
	end
	local data = {damage = 0, removalFrames = {}}
	IterableMap.Add(recentDamage, unitID, data)
end
