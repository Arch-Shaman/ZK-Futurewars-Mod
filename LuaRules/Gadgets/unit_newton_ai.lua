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

local IterableMap = Spring.Utilities.IterableMap
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
alwayspush[UnitDefNames["gunshipkrow"].id] = true -- scary laser
alwayspush[UnitDefNames["dronelight"].id] = true -- annoying flies
alwayspush[UnitDefNames["droneheavyslow"].id] = true
alwayspush[UnitDefNames["dronefighter"].id] = true
alwayspush[UnitDefNames["dronecarry"].id] = true
alwayspush[UnitDefNames["gunshipemp"].id] = true -- don't stun me
alwayspush[UnitDefNames["gunshipbomb"].id] = true -- explosives not allowed.
alwayspush[UnitDefNames["gunshipheavytrans"].id] = true
alwayspush[UnitDefNames["bomberdisarm"].id] = true

local holdatrange = {} -- which targets we want to hold at range
holdatrange[UnitDefNames["gunshiptrans"].id] = true
holdatrange[UnitDefNames["gunshipskirm"].id] = true
holdatrange[UnitDefNames["gunshipraid"].id] = true
holdatrange[UnitDefNames["gunshipheavyskirm"].id] = true
holdatrange[UnitDefNames["bomberprec"].id] = true
holdatrange[UnitDefNames["bomberriot"].id] = true

-- important config --
local handleallies = false
local debugMode = false

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
local spGetUnitDefDimensions = Spring.GetUnitDefDimensions
local sqrt = math.sqrt

local pushparam = {1}
local pullparam = {0}

local newtonRange = 550
local simframes = 11

local CMD_UNIT_AI = Spring.Utilities.CMD.UNIT_AI
local CMD_PUSH_PULL = Spring.Utilities.CMD.PUSH_PULL

local unitAICmdDesc = {
	id      = CMD_UNIT_AI,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Unit AI',
	action  = 'unitai',
	tooltip    = 'Toggles smart unit AI for the unit',
	params     = {1, 'AI Off','AI On'}
}

local maxRanges = {}

for i = 1, #UnitDefs do
	local def = UnitDefs[i]
	if def.isMobile and not (alwayspush[i] or alwayspull[i]) then
		if def.weapons and #def.weapons > 0 then -- armed
			local maxrange = 0
			for i = 1, #def.weapons do
				local wd = WeaponDefs[def.weapons[i].weaponDef]
				local range = (wd.customParams.isaa and 200) or wd.range
				if range > maxrange then
					maxrange = range
				end
			end
			if maxrange > newtonRange then
				maxrange = 400
			end
			maxRanges[i] = math.min(maxrange, 300)
		else
			maxRanges[i] = 200
		end
	end
end
		

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
	end
end

local function AddUnit(unitID)
	if debugMode then
		spEcho("[NewtonAI]: Add Unit " .. unitID)
	end
	local state = GetUnitIsActive(unitID)
	local def = UnitDefs[spGetUnitDefID(unitID)].name
	IterableMap.Add(newtons, unitID, {state = state, distance = 0, lasttarget = 0,}) -- distance here is so we can get a rate of change.
end

local function RemoveUnit(unitID)
	if debugMode then
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

local function Distance(x1, y1, x2, y2)
	return sqrt(((y2 - y1) * (y2 - y1)) + ((x2 - x1)* (x2 - x1)))
end

local function WillUnitHitMe(unitID, targetID, checktime)
	local basex, basey, basez, midx, midy, midz = spGetUnitPosition(unitID, true)
	local targetdef = spGetUnitDefID(targetID)
	local minheight = midy - 40
	local maxheight = midy + 40
	local radius = 75 -- newton's colvol is 50 wide, but we want a safety net.
	local tx, ty, tz = spGetUnitPosition(targetID)
	local groundheight = spGetGroundHeight(tx, tz)
	local vx, vy, vz = spGetUnitVelocity(targetID)
	local d = Distance(tx, tz, basex, basez)
	local unitHeight = ty - groundheight
	local pulling = not GetUnitIsActive(unitID)
	local unitIsLowerThanMe = ty < basey
	local unitIsHigherThanMe = ty >= maxheight
	if (vy > 1 and unitIsHigherThanMe) or (unitHeight > 25 and unitIsLowerThanMe) or (vy < 0 and unitIsLowerThanMe) or d < 120 then
		return true
	end
	local sx, sy, sz = tx, ty, tz
	local inHeightCylinder
	for i = 1, checktime do
		sx = tx + (vx * i)
		sy = ty + (vy * i)
		sz = tz + (vz * i)
		d = Distance(sx, sz, midx, midz)
		inHeightCylinder = sy >= minheight and sy <= maxheight
		--Spring.Echo("Sim frame " .. i, sx, sy, sz, tostring(inHeightCylinder))
		if inHeightCylinder and d <= radius then
			return true
		end
	end
	return false
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
	if not inlos then
		return
	end
	if alwayspull[targetdef] then
		-- ensure our current state is proper
		SetState(unitID, mystate, false)
		return
	end
	if alwayspush[targetdef] or hpratio <= 0.25  then
		SetState(unitID, mystate, true)
		return
	end
	SetState(unitID, mystate, WillUnitHitMe(unitID, currenttarget, simframes))
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
			if debugMode then
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
