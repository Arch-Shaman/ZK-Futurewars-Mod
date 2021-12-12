function gadget:GetInfo()
  return {
    name      = "Newton AI",
    desc      = "Handle newtons",
    author    = "Shaman",
    date      = "02-24-2021",
    license   = "CC-0",
    layer     = 0,
    enabled   = true,
  }
end

if not gadgetHandler:IsSyncedCode() then -- SYNCED
	return
end

VFS.Include("LuaRules/Configs/customcmds.h.lua")
local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local newtons = IterableMap.New()

-- config --
local wanteddefs = {} -- which defs have impulse weapons
wanteddefs[UnitDefNames["turretimpulse"].id] = true
--wanteddefs[UnitDefNames["jumpsumo"]].id = true -- Breaks horrendously

local alwayspull = {} -- which targets we want to always pull into us. (Think: Licho traps)
alwayspull[UnitDefNames["bomberheavy"].id] = true
alwayspull[UnitDefNames["athena"].id] = true
alwayspull[UnitDefNames["planeheavyfighter"].id] = true
alwayspull[UnitDefNames["planefighter"].id] = true
alwayspull[UnitDefNames["planescout"].id] = true
alwayspull[UnitDefNames["bomberstrike"].id] = true -- heretic can outrange us considerably, so it doesn't matter.

local alwayspush = {} -- which targets we want to always push away from us. (Think: defense)
alwayspush[UnitDefNames["cloakbomb"].id] = true
alwayspush[UnitDefNames["shieldbomb"].id] = true
alwayspush[UnitDefNames["jumpbomb"].id] = true
alwayspush[UnitDefNames["chicken_dodo"].id] = true
alwayspush[UnitDefNames["gunshipkrow"].id] = true -- scary clusterbombs
alwayspush[UnitDefNames["dronelight"].id] = true -- annoying flies
alwayspush[UnitDefNames["droneheavyslow"].id] = true
alwayspush[UnitDefNames["dronefighter"].id] = true
alwayspush[UnitDefNames["dronecarry"].id] = true
alwayspush[UnitDefNames["gunshipemp"].id] = true -- don't stun me
alwayspush[UnitDefNames["gunshipbomb"].id] = true -- explosives not allowed.

local holdatrange = {} -- which targets we want to hold at range
holdatrange[UnitDefNames["gunshiptrans"].id] = true
holdatrange[UnitDefNames["gunshipheavytrans"].id] = true
holdatrange[UnitDefNames["gunshipskirm"].id] = true
holdatrange[UnitDefNames["gunshipraid"].id] = true
holdatrange[UnitDefNames["gunshipheavyskirm"].id] = true
holdatrange[UnitDefNames["bomberdisarm"].id] = true
holdatrange[UnitDefNames["bomberprec"].id] = true
holdatrange[UnitDefNames["bomberriot"].id] = true

-- important config --
local handleallies = false
local debug = false

local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spEditUnitCmdDesc = Spring.EditUnitCmdDesc
local spFindUnitCmdDesc = Spring.FindUnitCmdDesc
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitWeaponTarget = Spring.GetUnitWeaponTarget
local spGetUnitStates = Spring.GetUnitStates
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spGetUnitSeparation = Spring.GetUnitSeparation
local spGetUnitVelocity = Spring.GetUnitVelocity
local spGetUnitTeam = Spring.GetUnitTeam
local spAreTeamsAllied = Spring.AreTeamsAllied
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGetUnitLosState = Spring.GetUnitLosState
local spGetUnitHealth = Spring.GetUnitHealth
local spGetUnitPosition = Spring.GetUnitPosition
local spGetGroundHeight = Spring.GetGroundHeight
local spEcho = Spring.Echo
local spValidUnitID = Spring.ValidUnitID

local pushparam = {1}
local pullparam = {0}

local unitAICmdDesc = {
	id      = CMD_UNIT_AI,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Unit AI',
	action  = 'unitai',
	tooltip    = 'Toggles smart unit AI for the unit',
	params     = {1, 'AI Off','AI On'}
}

local function GetUnitIsActive(unitID)
	if spValidUnitID(unitID) then
		local states = spGetUnitStates(unitID)
		return states["active"]
	else
		spEcho("[NewtonAI]: Bad state")
		return false
	end
end

local function SetState(unitID, state, wanted)
	if state == wanted then -- while these two conditionals aren't necessary they're good visualizers of intended behavior, i guess.
		return
	elseif not state and wanted then
		spGiveOrderToUnit(unitID, CMD_PUSH_PULL, pushparam, 0)
	elseif state and not wanted then
		spGiveOrderToUnit(unitID, CMD_PUSH_PULL, pullparam, 0)
	elseif not state and not wanted then
		return
	end
end

local function AddUnit(unitID)
	if debug then
		spEcho("[NewtonAI]: Add Unit " .. unitID)
	end
	local state = GetUnitIsActive(unitID)
	local def = UnitDefs[spGetUnitDefID(unitID)].name
	IterableMap.Add(newtons, unitID, {state = state, distance = 0, lasttarget = 0,}) -- distance here is so we can get a rate of change.
end

local function RemoveUnit(unitID)
	if debug then
		spEcho("[NewtonAI] Removing Unit " .. unitID)
	end
	IterableMap.Remove(newtons, unitID)
end

local function AIToggleCommand(unitID, cmdParams, cmdOptions)
	local def = spGetUnitDefID(unitID)
	if wanteddefs[def] then
		local state = cmdParams[1]
		local cmdDescID = spFindUnitCmdDesc(unitID, CMD_UNIT_AI)
		if (cmdDescID) then
			unitAICmdDesc.params[1] = state
			spEditUnitCmdDesc(unitID, cmdDescID, { params = unitAICmdDesc.params})
			if state == 1 then
				AddUnit(unitID)
			else
				RemoveUnit(unitID)
			end
		end
	end
end

local function CheckUnit(unitID, data, currenttarget)
	local mystate = data.state
	local targetdef = spGetUnitDefID(currenttarget)
	local targetstate = spGetUnitLosState(currenttarget, spGetUnitAllyTeam(unitID))
	local inlos = targetstate.los
	local hp, maxhp = spGetUnitHealth(unitID)
	local hpratio = hp/maxhp
	local lasttarget = data.lasttarget
	data.lasttarget = currenttarget
	if inlos and alwayspush[targetdef] then
		if mystate ~= true then
			SetState(unitID, mystate, true)
		end
		return
	end
	if inlos and alwayspull[targetdef] then
		-- ensure our current state is proper
		if mystate ~= false then
			SetState(unitID, mystate, false)
		end
		return
	elseif (inlos and alwayspush[targetdef]) or (hpratio <= 0.25 and not (inlos and (alwayspull[targetdef] or holdatrange[targetdef]))) then
		if mystate ~= true then
			SetState(unitID, mystate, true) -- push
		end
		return
	end
	if inlos then
		local distance = spGetUnitSeparation(unitID, currenttarget)
		local der = distance - data.distance
		local x, y, z = spGetUnitPosition(currenttarget)
		local x2, y2, z2 = spGetUnitPosition(unitID)
		local heightFromGround = y - spGetGroundHeight(x, z)
		local heightdifference = y - y2
		data.distance = distance
		if lasttarget ~= currenttarget then
			der = 0
		end
		local vx, vy, vz = spGetUnitVelocity(currenttarget)
		if debug and Spring.GetGameFrame()%4 == 0 then
			spEcho("Target: " .. currenttarget .. "\nVy: " .. vy .. "\ndist: " .. distance .. "\nder: " .. der .. "\nheight info: " .. heightFromGround .. " ( " .. heightdifference .. " )")
		end
		-- we use heightdifference here to tell when a target is above or at level with the newton. This is a cheap means of figuring out when we can launch them.
		-- distance is used to tell when the unit is careening towards us (BAD, we don't want to take collision damage!)
		-- VY is to tell when a unit is sent upwards (meaning: going to space)
		-- Most of the time this will result in units either being smashed repeatedly into terrain (lol) or going into space. Both are beneficial to us anyways.
		if not holdatrange[targetdef] then
			if (distance < 200 and der < -5) or (heightdifference >= 0 and heightFromGround >= 10) or der < -15 then
				if mystate ~= true then
					SetState(unitID, mystate, true) -- push
				end
				return
			elseif distance > 250 and vy < 0.5 and not (heightdifference > 0 and heightFromGround > 10) then
				if mystate then
					SetState(unitID, mystate, false) -- pull
				end
				return
			end
		else
			-- now this on the other hand, since Seperation is 3d distance (eww) we're kinda fucked when things go over our heads.
			-- 2d distance leads to a totally ineffectual response so this is here to stay, unfortunately.
			if distance > 370 and mystate then
				SetState(unitID, mystate, false)
			elseif distance < 370 and not mystate then
				SetState(unitID, mystate, true)
			end
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced) -- we get unitAI cmd from tactical ai. this just plugs it into this script.
	if (cmdID == CMD_UNIT_AI) and wanteddefs[unitDefID] then
		AIToggleCommand(unitID, cmdParams, cmdOptions)
		return false  -- command was used
	end
	return true  -- command wasnt used
end

function gadget:UnitDestroyed(unitID)
	if IterableMap.InMap(newtons, unitID) then
		RemoveUnit(unitID)
	end
end

function gadget:GameFrame(f)
	for unitID, data in IterableMap.Iterator(newtons) do
		if not spValidUnitID(unitID) then
			if debug then
				spEcho("[NewtonAI] Invalid unit detected.")
			end
			RemoveUnit(unitID)
		else
			data.state = GetUnitIsActive(unitID)
			local weapon = 2
			if not data.state then -- weapon 1 is pull while weapon 2 is push.
				weapon = 1
			end
			local type, _, currenttarget = spGetUnitWeaponTarget(unitID, weapon) -- sometimes weapons have different targets, for... reasons i don't fully understand.
			local newtonteam = spGetUnitTeam(unitID) -- so all this code here is just safety stuff.
			local isally = true
			if type == 1 and currenttarget then -- we want to only care about UNITS which are type 1. 0 is no target (afaik) and 2 is ground.
				local targetteam = spGetUnitTeam(currenttarget)
				isally = spAreTeamsAllied(newtonteam, targetteam)
			end
			if type == 1 and currenttarget and (handleallies or not isally) then -- we only care about shooting enemies (since newtons MAY be in newton fire zones).
				CheckUnit(unitID, data, currenttarget) -- note: newton fire zone automatically turns off the ai anyways, but we don't want to have our stuff smash into terrain (BAD)
			end
		end
	end
end
