--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if not gadgetHandler:IsSyncedCode() then
	return
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Sudden Death",
		desc      = "Implements sudden death mode.",
		author    = "GoogleFrog",
		date      = "24 June 2023",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local MAPSIDE_CONFIG_FILE = "mapconfig/map_sudden_death.lua"
local GAMESIDE_CONFIG_FILE = "LuaRules/Configs/MapSuddenDeath/" .. (Game.mapName or "") .. ".lua"

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local vecDistSq = Spring.Utilities.Vector.DistSq

local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitDefID    = Spring.GetUnitDefID
local spGetUnitHealth   = Spring.GetUnitHealth
local spSetUnitHealth   = Spring.SetUnitHealth
local spDestroyUnit     = Spring.DestroyUnit
local spGetUnitArmored  = Spring.GetUnitArmored

local MAP_WIDTH = Game.mapSizeX
local MAP_HEIGHT = Game.mapSizeZ

local UPDATE_FREQ = 9
local UPDATE_FREQ_DAMAGE = 4

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local allEligibleUnits = false -- Initialised when sudden death starts
local beingDamagedUnits = false
local elgibleDefIdCache = {}
local suddenDeathRadius = false
local suddenDeathRadiusSq = false
local nextAnnounceSecond = 60
local stopSuddenDeath = false

local function IsEligible(unitDefID)
	if not elgibleDefIdCache[unitDefID] then
		local ud = UnitDefs[unitDefID]
		elgibleDefIdCache[unitDefID] = (ud.customParams.dontkill and 0) or 1
	end
	return (elgibleDefIdCache[unitDefID] == 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Configurable via config

local originX = MAP_WIDTH/2
local originZ = MAP_HEIGHT/2
local startDistanceSq = originX*originX + originZ*originZ
local startDistance = math.sqrt(startDistanceSq)
local suddenDeathFrame = 60*20*30
local suddenSweepFrames = 10*60*30
local damageDoubleDistance = 400
local damageRampFactor = 2 ^ (1/(60*30))
local damageRampActive = false

local baseDamage          = 50 * UPDATE_FREQ_DAMAGE / 30
local propDamage          = 0.02 * UPDATE_FREQ_DAMAGE / 30

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Read configuration

local function GetDefaultConfig()
	local suddenDeathMinutes = tonumber((Spring.GetModOptions() or {}).sudden_death_minutes) or false
	local suddenDeathSweepSeconds = tonumber((Spring.GetModOptions() or {}).sudden_death_sweep_seconds) or false


	if (tonumber((Spring.GetModOptions() or {}).commwars) or 0) == 1 then
		suddenDeathMinutes = suddenDeathMinutes or 7
		suddenDeathSweepSeconds = suddenDeathSweepSeconds or 300
	end

	if not suddenDeathMinutes then
		return false
	end
	return {
		suddenDeathStartSeconds = suddenDeathMinutes*60,
		suddenDeathSweepSeconds = suddenDeathSweepSeconds or 600,
	}
end

local function SetupSuddenDeath()
	local gameConfig = VFS.FileExists(GAMESIDE_CONFIG_FILE) and VFS.Include(GAMESIDE_CONFIG_FILE) or false
	local mapConfig  = VFS.FileExists(MAPSIDE_CONFIG_FILE) and VFS.Include(MAPSIDE_CONFIG_FILE) or false
	local config     = gameConfig or mapConfig or GetDefaultConfig()
	if not config then
		return false
	end
	
	originX                 = config.originX or originX
	originZ                 = config.originZ or originZ
	suddenDeathFrame        = (config.suddenDeathStartSeconds and config.suddenDeathStartSeconds*30) or suddenDeathFrame
	suddenSweepFrames       = (config.suddenDeathSweepSeconds and config.suddenDeathSweepSeconds*30) or suddenSweepFrames
	startDistance           = config.startDistance or startDistance
	damageMult              = config.damageMult or false
	damageRampFactor        = math.max(config.damageRampFactor or damageRampFactor, 1.00002)
	
	startDistanceSq   = startDistance*startDistance
	if damageMult then
		baseDamage = baseDamage * damageMult
		propDamage = propDamage * damageMult
	end
	
	if suddenSweepFrames < 1 then
		suddenSweepFrames = 1
	end
	
	Spring.SetGameRulesParam("suddenDeathStartDistance", startDistance)
	Spring.SetGameRulesParam("suddenDeathOriginX", originX)
	Spring.SetGameRulesParam("suddenDeathOriginZ", originZ)
	Spring.SetGameRulesParam("suddenDeathFrames", suddenDeathFrame)
	return true
end


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Sudden Death Handling

local function CheckOutOfBounds(unitID)
	if stopSuddenDeath then
		return true
	end
	local x, _, z = spGetUnitPosition(unitID)
	if not x then
		return true
	end
	local distSq = vecDistSq(x, z, originX, originZ)
	
	if suddenDeathRadius > 0 and distSq < suddenDeathRadiusSq then
		-- Radius can be negative to eventually make even the centre of the map
		-- far from the border (for the purpose of progressive damage).
		return
	end
	
	IterableMap.Add(beingDamagedUnits, unitID)
end

local function CheckDamage(unitID)
	if stopSuddenDeath then
		return true
	end
	local x, _, z = spGetUnitPosition(unitID)
	if not x then
		return true
	end
	local distSq = vecDistSq(x, z, originX, originZ)
	
	if suddenDeathRadius > 0 and distSq < suddenDeathRadiusSq then
		-- Remove, only handle with CheckOutOfBounds
		return true
	end
	
	local inDist = math.sqrt(distSq) - suddenDeathRadius
	inDist = (inDist / damageDoubleDistance)
	local damageMult = (2 ^ inDist) - 0.9
	
	local health, maxHealth = spGetUnitHealth(unitID)
	local armored, armorMult = spGetUnitArmored(unitID)
	maxHealth = maxHealth / (armorMult or 1)

	local newHP = health - (baseDamage + propDamage * maxHealth) * damageMult
	if newHP < 0 then
		spDestroyUnit(unitID)
	end
	spSetUnitHealth(unitID, newHP)
end

local function UpdateSuddenDeathRing(n)
	if stopSuddenDeath then
		return
	end
	local progress = 0.1 ^ ((n - suddenDeathFrame) / suddenSweepFrames)
	suddenDeathRadius = progress * startDistance

	if (not damageRampActive) and n > (suddenDeathFrame + suddenSweepFrames) then
		damageRampActive = true
		Spring.Echo("game_priority_message: Ring of death damage will now double every minute!")
	end

	suddenDeathRadiusSq = suddenDeathRadius * suddenDeathRadius
	Spring.SetGameRulesParam("suddenDeathRadius", suddenDeathRadius)
	Spring.SetGameRulesParam("suddenDeathProgress", (1 - progress))
end

local function SuddenDeathActivate()
	gadgetHandler:UpdateCallIn("UnitCreated")
	gadgetHandler:UpdateCallIn("UnitDestroyed")
	
	allEligibleUnits = IterableMap.New()
	beingDamagedUnits = IterableMap.New()
	local allUnits = Spring.GetAllUnits()
	for i = 1, #allUnits do
		gadget:UnitCreated(allUnits[i], spGetUnitDefID(allUnits[i]))
	end
end

local function CheckSuddenDeathAnnouncement(n)
	if not (nextAnnounceSecond and n + nextAnnounceSecond*30 == suddenDeathFrame) then
		return
	end
	if nextAnnounceSecond == 0 then
		Spring.Echo("game_priority_message: Sudden death has begun!")
		nextAnnounceSecond = false
		return
	end
	Spring.Echo("game_priority_message: Sudden death in " .. nextAnnounceSecond .. "s")
	if nextAnnounceSecond > 10 then
		nextAnnounceSecond = nextAnnounceSecond - 50
	elseif nextAnnounceSecond > 4 then
		nextAnnounceSecond = nextAnnounceSecond - 7
	else
		nextAnnounceSecond = nextAnnounceSecond - 1
	end
	if nextAnnounceSecond < 1 then
		nextAnnounceSecond = 0
	end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Gagdet API

function gadget:GameFrame(n)
	CheckSuddenDeathAnnouncement(n)
	if n < suddenDeathFrame then
		return
	end
	UpdateSuddenDeathRing(n)
	if (not allEligibleUnits) then
		SuddenDeathActivate()
	end

	if damageRampActive then
		baseDamage = baseDamage * damageRampFactor
		propDamage = propDamage * damageRampFactor
	end

	IterableMap.ApplyFraction(allEligibleUnits, UPDATE_FREQ, n%UPDATE_FREQ, CheckOutOfBounds)
	IterableMap.ApplyFraction(beingDamagedUnits, UPDATE_FREQ_DAMAGE, n%UPDATE_FREQ_DAMAGE, CheckDamage)
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if suddenDeathRadius and IsEligible(unitDefID) then
		CheckOutOfBounds(unitID)
		IterableMap.Add(allEligibleUnits, unitID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if suddenDeathRadius and IsEligible(unitDefID) then
		IterableMap.Remove(allEligibleUnits, unitID)
	end
end

function gadget:Initialize()
	Spring.Echo("InitializeInitializeInitialize")
	if (not SetupSuddenDeath()) or Spring.IsGameOver() then
		gadgetHandler:RemoveGadget()
		return
	end
	gadgetHandler:RemoveCallIn("UnitCreated")
	gadgetHandler:RemoveCallIn("UnitDestroyed")
end

function gadget:GameOver()
	stopSuddenDeath = true
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
