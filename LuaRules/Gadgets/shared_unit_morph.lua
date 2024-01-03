if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Shared Unit Morph",
		desc      = "Provides a function to transmute a unit from one unitdef to another",
		author    = "Stuffphoton",
		date      = "28/12/2023",
		license   = "GNU GPL, v2 or later",
		layer     = -1, --must start after unit_priority.lua gadget to use GG.AddMiscPriority()
		enabled   = true,
	}
end

--[[
I ripped all of this straight out of unit_morph.lua. Remeber to update this with any upstream changes - Stuffphoton

The actual function you're all here for is `GG.MorphUnit`
unitID is the unit to morph
morphInto is the unitDefID to morph into
morphParams is a table describing the morph. it takes the following parameters:
upgradeDef is for commanders. it defines data related to comm upgrades. see GG.Upgrades_CreateUpgradedUnit
facing is something relating to facing. not sure what it does. I'd leave it as nil
cheap cuts out some expensive fanciness out. use it ONLY for drones and AI units that the player REALLY doesn't care about
Returns the new unitID if the new unit was sucessfully created, and nil if it wasn't. In the latter case the old unit is not deleted
Example:

local newUnitID = GG.MorphUnit(unitID, UnitDefNames.cloakraid.id, {upgradeDef = nil, facing = false, cheap = false})
--]]


include("LuaRules/Configs/customcmds.h.lua")

---------------------------------------------------------------------
---------------------------------------------------------------------
local spGetUnitTeam = Spring.GetUnitTeam
local spGetUnitPosition = Spring.GetUnitPosition
local spSetUnitPosition = Spring.SetUnitPosition
local spGetUnitHeading = Spring.GetUnitHeading
local spSetUnitBlocking = Spring.SetUnitBlocking
local spSetUnitRotation = Spring.SetUnitRotation
local spGetUnitDefID = Spring.GetUnitDefID
local spValidUnitID = Spring.ValidUnitID
local spGetUnitHealth = Spring.GetUnitHealth
local spSetUnitHealth = Spring.SetUnitHealth
local spGetFacingFromHeading = Spring.GetFacingFromHeading
local spSetTeamRulesParam = Spring.SetTeamRulesParam
local spSendCommands = Spring.SendCommands
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetCommandQueue = Spring.GetCommandQueue
local spGetUnitStates = Spring.GetUnitStates
local spGetUnitShieldState = Spring.GetUnitShieldState
local spAddUnitImpulse = Spring.AddUnitImpulse
local spGetUnitExperience = Spring.GetUnitExperience
local spDestroyUnit = Spring.DestroyUnit
local spGetUnitVelocity = Spring.GetUnitVelocity
local spGetGroundHeight = Spring.GetGroundHeight
local spSetUnitShieldState = Spring.SetUnitShieldState
local spGiveOrderArrayToUnitArray = Spring.GiveOrderArrayToUnitArray
local spSetUnitExperience = Spring.SetUnitExperience
local spGetUnitsInRectangle = Spring.GetUnitsInRectangle
local spSetUnitMoveGoal = Spring.SetUnitMoveGoal
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spGetAllUnits = Spring.GetAllUnits
local spCreateUnit = Spring.CreateUnit

local spEcho = Spring.Echo

local shields = {}
local unitsNeedingHax = {}

for i = 1, #UnitDefs do
	local def = UnitDefs[i]
	local weapons = def.weapons
	for w = 1, #weapons do
		local wep = weapons[w].weaponDef
		if WeaponDefs[wep].shieldPower and WeaponDefs[wep].shieldPower > 0 and shields[i] == nil then
			shields[i] = WeaponDefs[wep].id
			--Spring.Echo("Added shield retreat to " .. i .. " ( has " .. tostring(WeaponDefs[wep].shieldPower) .. ")")
		end
	end
end

---------------------------------------------------------------------
---------------------------------------------------------------------

local function DoesCMDNeedHax(cmdID, unitID, cmdParams)
	if cmdID == CMD.FIGHT or cmdID == CMD.MOVE or cmdID == CMD.ATTACK or cmdID == CMD.PATROL then return false end -- probably fine
	if cmdID == CMD_RAW_MOVE then return true, 16 end
	local ux, _, uz = spGetUnitPosition(unitID)
	local px, py, pz = cmdParams[1], cmdParams[2], cmdParams[3]
	--Spring.Echo("Unit needs hax")
	if px and pz then
		local xdiff = ux - px
		local zdiff = uz - pz
		local d = math.sqrt((xdiff * xdiff) + (zdiff * zdiff))
		local ud = UnitDefs[spGetUnitDefID(unitID)]
		local buildDist = ud.buildDistance
		if d >= buildDist then
			--Spring.Echo("Apply build hax")
			return true, buildDist
		else
			--Spring.Echo("Build dist too close")
			return false
		end
	else
		return false
	end
end
-- This function is terrible. The data structure of commands does not lend itself to a fundamentally nicer system though.

local unitTargetCommand = {
	[CMD.GUARD] = true,
	[CMD_ORBIT] = true,
}

local singleParamUnitTargetCommand = {
	[CMD.REPAIR] = true,
	[CMD.ATTACK] = true,
}


local function ReAssignAssists(newUnit,oldUnit)
	local allUnits = spGetAllUnits(newUnit)
	for i = 1, #allUnits do
		local unitID = allUnits[i]
		
		if GG.GetUnitTarget(unitID) == oldUnit then
			GG.SetUnitTarget(unitID, newUnit)
		end
		
		local cmds = spGetCommandQueue(unitID, -1)
		for j = 1, #cmds do
			local cmd = cmds[j]
			local params = cmd.params
			if (unitTargetCommand[cmd.id] or (singleParamUnitTargetCommand[cmd.id] and #params == 1)) and (params[1] == oldUnit) then
				params[1] = newUnit
				local opts = (cmd.options.meta and CMD.OPT_META or 0) + (cmd.options.ctrl and CMD.OPT_CTRL or 0) + (cmd.options.alt and CMD.OPT_ALT or 0)
				spGiveOrderToUnit(unitID, CMD.INSERT, {cmd.tag, cmd.id, opts, params[1], params[2], params[3]}, 0)
				spGiveOrderToUnit(unitID, CMD.REMOVE, {cmd.tag}, 0)
			end
		end
	end
end


local function CreateMorphedToUnit(defName, x, y, z, face, unitTeam, isBeingBuilt, upgradeDef)
	if upgradeDef and GG.Upgrades_CreateUpgradedUnit then
		return GG.Upgrades_CreateUpgradedUnit(defName, x, y, z, face, unitTeam, isBeingBuilt, upgradeDef)
	else
		return spCreateUnit(defName, x, y, z, face, unitTeam, isBeingBuilt)
	end
end


function GG.MorphUnit(unitID, morphInto, morphParams)
	local morphParams = morphParams or {}
	local upgradeDef = morphParams.upgradeDef
	local facing = morphParams.facing
	local cheap = morphParams.cheap
	
	local udDst = UnitDefs[morphInto]
	local unitDefID = spGetUnitDefID(unitID)
	local ud = UnitDefs[unitDefID]
	local defName = udDst.name
	local unitTeam = spGetUnitTeam(unitID)
	-- copy dominatrix stuff
	local originTeam, originAllyTeam, controllerID, controllerAllyTeam = GG.Capture.GetMastermind(unitID)
	
	-- you see, Anarchid's exploit is fixed this way
	if (originTeam ~= nil) and (spValidUnitID(controllerID)) then
		unitTeam = spGetUnitTeam(controllerID)
	end
	
	local px, py, pz = spGetUnitPosition(unitID)
	local h = spGetUnitHeading(unitID)
	spSetUnitBlocking(unitID, false)

	--// copy health
	local oldHealth,oldMaxHealth,paralyzeDamage,captureProgress,buildProgress = spGetUnitHealth(unitID)

	local isBeingBuilt = false
	if buildProgress < 1 then
		isBeingBuilt = true
	end
	
	local newUnit

	if udDst.isImmobile then
		local x = math.floor(px/16)*16
		local y = py
		local z = math.floor(pz/16)*16
		local face = spGetFacingFromHeading(h)
		local xsize = udDst.xsize
		local zsize =(udDst.zsize or udDst.ysize)
		if ((face == 1) or(face == 3)) then
			xsize, zsize = zsize, xsize
		end
		if xsize/4 ~= math.floor(xsize/4) then
			x = x+8
		end
		if zsize/4 ~= math.floor(zsize/4) then
			z = z+8
		end
		spSetTeamRulesParam(unitTeam, "morphUnitCreating", 1, PRIVATE)
		newUnit = CreateMorphedToUnit(defName, x, y, z, face, unitTeam, isBeingBuilt, upgradeDef)
		spSetTeamRulesParam(unitTeam, "morphUnitCreating", 0, PRIVATE)
		if not newUnit then
			return
		end
		spSetUnitPosition(newUnit, x, y, z)
	else
		spSetTeamRulesParam(unitTeam, "morphUnitCreating", 1, PRIVATE)
		newUnit = CreateMorphedToUnit(defName, px, py, pz, spGetFacingFromHeading(h), unitTeam, isBeingBuilt, upgradeDef)
		spSetTeamRulesParam(unitTeam, "morphUnitCreating", 0, PRIVATE)
		if not newUnit then
			return
		end
		spSetUnitRotation(newUnit, 0, -h * math.pi / 32768, 0)
		spSetUnitPosition(newUnit, px, py, pz)
	end

	--if (extraUnitMorphDefs[unitID] ~= nil) then
	-- nothing here for now
	--end
	
	if (hostName ~= nil) and PWUnits[unitID] then
		-- send planetwars deployment message
		PWUnit = PWUnits[unitID]
		PWUnit.currentDef = udDst
		local data = PWUnit.owner..","..defName..","..math.floor(px)..","..math.floor(pz)..",".."S" -- todo determine and apply smart orientation of the structure
		spSendCommands("w "..hostName.." pwmorph:"..data)
		extraUnitMorphDefs[unitID] = nil
		--GG.PlanetWars.units[unitID] = nil
		--GG.PlanetWars.units[newUnit] = PWUnit
		SendToUnsynced('PWCreate', unitTeam, newUnit)
	elseif (not facing) then	-- set rotation only if unit is not planetwars and facing is not true
		--spEcho(morphData.def.facing)
		spSetUnitRotation(newUnit, 0, -h * math.pi / 32768, 0)
	end

	--// copy lineage
	--local lineage = Spring.GetUnitLineage(unitID)
	--// copy facplop
	local facplop = spGetUnitRulesParam(unitID, "facplop")
	-- Remove old facplop due to a bug that allows facplop duplication if done during morph.
	if facplop and (facplop == 1) then
		spSetUnitRulesParam(unitID, "facplop", 0, {inlos = true})
	end
	--//copy command queue
	local cmds = spGetCommandQueue(unitID, -1)

	local states = spGetUnitStates(unitID) -- This can be left in table-state mode until REVERSE_COMPAT is not an issue.
	states.retreat = spGetUnitRulesParam(unitID, "retreatState") or 0
	states.buildPrio = spGetUnitRulesParam(unitID, "buildpriority") or 1
	states.miscPrio = spGetUnitRulesParam(unitID, "miscpriority") or 1

	--// copy cloak state
	local wantCloakState = spGetUnitRulesParam(unitID, "wantcloak")
	--// copy shield power
	local shieldNum = spGetUnitRulesParam(unitID, "comm_shield_num") or shields[unitDefID] or -1
	local oldShieldState, oldShieldCharge = spGetUnitShieldState(unitID, shieldNum)
	--//copy experience
	local newXp = spGetUnitExperience(unitID)
	local oldBuildTime = Spring.Utilities.GetUnitCost(unitID, unitDefID)
	--//copy unit speed
	local velX,velY,velZ = spGetUnitVelocity(unitID) --remember speed
 

	spSetUnitRulesParam(newUnit, "jumpReload", spGetUnitRulesParam(unitID, "jumpReload") or 1)
	
	--// FIXME: - re-attach to current transport?
	--// update selection
	SendToUnsynced("unit_morph_finished", unitID, newUnit)
	GG.wasMorphedTo[unitID] = newUnit
	spSetUnitRulesParam(unitID, "wasMorphedTo", newUnit)
	GG.UpdateAntibait(unitID, newUnit)
	spSetUnitBlocking(newUnit, true)
	
	-- Copy radar targeting state --
	local radarstate = GG.GetUnitRadarTargeting(unitID)
	local orpState = GG.GetORPState(unitID)
	if radarstate then
		GG.SetUnitRadarTargeting(newUnit, radarstate)
	end
	if orpState then
		GG.SetORPState(newUnit, orpState)
	end
	
	-- copy disarmed
	local paradisdmg, pdtime = GG.getUnitParalysisExternal(unitID)
	if (paradisdmg ~= nil) then
		GG.setUnitParalysisExternal(newUnit, paradisdmg, pdtime)
	end
	
	-- copy dominatrix lineage
	if (originTeam ~= nil) then
		GG.Capture.SetMastermind(newUnit, originTeam, originAllyTeam, controllerID, controllerAllyTeam)
	end
	
	spDestroyUnit(unitID, false, true) -- selfd = false, reclaim = true
	
	--//transfer unit speed
	local gy = spGetGroundHeight(px, pz)
	if py>gy+1 then --unit is off-ground
		spAddUnitImpulse(newUnit,0,1,0) --dummy impulse (applying impulse>1 stop engine from forcing new unit to stick on map surface, unstick!)
		spAddUnitImpulse(newUnit,0,-1,0) --negate dummy impulse
	end
	spAddUnitImpulse(newUnit,velX,velY,velZ) --restore speed

	-- script.StartMoving is not called if a unit is created and then given velocity via impulse.
	local speed = math.sqrt(velX^2 + velY^2 + velZ^2)
	if speed > 0.6 then
		local env = Spring.UnitScript.GetScriptEnv(newUnit)
		if env and env.script.StartMoving then
			Spring.UnitScript.CallAsUnit(newUnit,env.script.StartMoving)
		end
	end
	
	--// transfer facplop
	if facplop and (facplop == 1) then
		spSetUnitRulesParam(newUnit, "facplop", 1, {inlos = true})
	end
	
	--// transfer health
	-- old health is declared far above
	local _,newMaxHealth		 = spGetUnitHealth(newUnit)
	local newHealth = (oldHealth / oldMaxHealth) * newMaxHealth
	if newHealth <= 1 then
		newHealth = 1
	end
	
	local newPara = paralyzeDamage*newMaxHealth/oldMaxHealth
	local slowDamage = spGetUnitRulesParam(unitID,"slowState")
	if slowDamage then
		GG.addSlowDamage(newUnit, slowDamage*newMaxHealth)
	end
	spSetUnitHealth(newUnit, {health = newHealth, build = buildProgress, paralyze = newPara, capture = captureProgress })
	
	--//transfer experience
	newXp = newXp * (oldBuildTime / Spring.Utilities.GetUnitCost(newUnit, morphInto))
	spSetUnitExperience(newUnit, newXp)
	--// transfer shield power
	if oldShieldState then
		local newDef = spGetUnitDefID(newUnit)
		local maxcharge = WeaponDefs[shields[newDef]].shieldPower
		
		spSetUnitShieldState(newUnit, shieldNum, math.min(oldShieldCharge, maxcharge))
	end
	
	--//transfer some state
	spGiveOrderArrayToUnitArray({ newUnit }, {
		{CMD.FIRE_STATE,    { states.firestate             }, 0 },
		{CMD.MOVE_STATE,    { states.movestate             }, 0 },
		{CMD.REPEAT,        { states["repeat"] and 1 or 0  }, 0 },
		{CMD_WANT_CLOAK,    { wantCloakState or 0          }, 0 },
		{CMD.ONOFF,         { 1                            }, 0 },
		{CMD.TRAJECTORY,    { states.trajectory and 1 or 0 }, 0 },
		{CMD_PRIORITY,      { states.buildPrio             }, 0 },
		{CMD_RETREAT,       { states.retreat               }, states.retreat == 0 and CMD.OPT_RIGHT or 0 },
		{CMD_MISC_PRIORITY, { states.miscPrio              }, 0 },
	})
	
	--//reassign assist commands to new unit
	if not cheap then
		ReAssignAssists(newUnit,unitID)
	end
	--//transfer command queue
	for i = 1, #cmds do
		local cmd = cmds[i]
		local coded = cmd.options.coded + (cmd.options.shift and 0 or CMD.OPT_SHIFT) -- orders without SHIFT can appear at positions other than the 1st due to CMD.INSERT; they'd cancel any previous commands if added raw
		if cmd.id < 0 then -- repair case for construction
			local units = spGetUnitsInRectangle(cmd.params[1] - 16, cmd.params[3] - 16, cmd.params[1] + 16, cmd.params[3] + 16)
			local allyTeam = spGetUnitAllyTeam(unitID)
			local notFound = true
			for j = 1, #units do
				local areaUnitID = units[j]
				if allyTeam == spGetUnitAllyTeam(areaUnitID) and spGetUnitDefID(areaUnitID) == -cmd.id then
					spGiveOrderToUnit(newUnit, CMD.REPAIR, {areaUnitID}, coded)
					notFound = false
					break
				end
			end
			if notFound then
				spGiveOrderToUnit(newUnit, cmd.id, cmd.params, coded)
			end
		else
			spGiveOrderToUnit(newUnit, cmd.id, cmd.params, coded)
		end
	end
	if cmds[1] and cmds[1].id == CMD_RAW_MOVE then
		--spEcho("Fixing move order for unit " .. newUnit)
		spSetUnitMoveGoal(newUnit, cmds[1].params[1], cmds[1].params[2], cmds[1].params[3], cmds[1].params[4] or 16, nil, false)
	elseif cmds[1] then
		local needsHax, buildHaxDist = DoesCMDNeedHax(cmds[1].id, newUnit, cmds[1].params)
		if needsHax then
			unitsNeedingHax[newUnit] = {[1] = cmds[1].params[1], [2] = cmds[1].params[2], [3] = cmds[1].params[3], [4] = buildHaxDist or 16}
		end
	end

	return newUnit
end


function gadget:GameFrame(n)
	for unitID, data in pairs(unitsNeedingHax) do
		local ud = UnitDefs[Spring.GetUnitDefID(unitID)]
		local speedmult = (Spring.GetUnitRulesParam(unitID, "upgradesSpeedMult") or 1)
		local speed = ud.speed * speedmult
		Spring.SetUnitMoveGoal(unitID, data[1], data[2], data[3], data[4], speed, false)
		--Spring.Echo("Applied hax")
		unitsNeedingHax[unitID] = nil
	end
end
