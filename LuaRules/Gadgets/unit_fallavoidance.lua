if (not gadgetHandler:IsSyncedCode()) then
	return false  --  no unsynced code
end

function gadget:GetInfo()
	return {
		name    	= "Fall Avoidance",
		desc  		= "Units jump to avoid fall damage",
		author    	= "Shaman",
		date    	= "20 Sept 2021",
		license   	= "CC-0",
		layer    	= -1, -- Before Tactical AI.
		enabled 	= true,
	}
end


local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
include("LuaRules/Configs/customcmds.h.lua")

local wantedDefs = {}
local canJumpDefs = {}
local units = IterableMap.New()

-- config --
local UpdateRate = 5 -- 6hz
local debug = false


for i = 1, #UnitDefs do
	local cp = UnitDefs[i].customParams
	if cp.canjump and cp.jump_from_midair and cp.jump_from_midair ~= '0' then
		wantedDefs[i] = tonumber(cp.jump_range)
	end
	if cp.canjump then
		canJumpDefs[i] = true
	end
end

-- speed up --

local cos = math.cos
local sin = math.sin
local atan2 = math.atan2
local spGetGameFrame = Spring.GetGameFrame
local spFindUnitCmdDesc = Spring.FindUnitCmdDesc
local spEditUnitCmdDesc = Spring.EditUnitCmdDesc
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spGetUnitPosition = Spring.GetUnitPosition
local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitVelocity = Spring.GetUnitVelocity
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitIsStunned = Spring.GetUnitIsStunned
local spEcho = Spring.Echo
local GiveClampedOrderToUnit = Spring.Utilities.GiveClampedOrderToUnit

local unitStates = {}

local CommandOrder = 123456
local sweapfire_desc = {
	id          = CMD_AUTOJUMP,
	type        = CMDTYPE.ICON_MODE,
	name        = 'Autojump',
	action      = 'autojump',
	tooltip     = "Toggles AI Use of Jump",
	params      = {1, 'Autojump Off', 'Autojump On'},
}



local function GetPoints(angle, x, z, dist)
	return x + (dist * cos(angle)), z + (dist * sin(angle))
end	

local function DoJump(data, unitID, x, y, z, vx, vz, distance)
	local cx, cy, cz
	cy = y
	if vx == 0 and vz == 0 then -- jump in place
		cx = x
		cz = z
	else
		local a = atan2(vz, vx) -- returns angle in radians
		cx, cz = GetPoints(a, x, z, distance * 0.98)
	end
	if debug then
		spEcho("DoJump: " .. cx .. "," .. cy .. "," .. cz)
	end
	if spGetGroundHeight(cx, cz) > -10 then
		GG.recursion_GiveOrderToUnit = true
		GiveClampedOrderToUnit(unitID, CMD.INSERT, { 0, CMD_JUMP, CMD.OPT_INTERNAL, cx, cy, cz}, CMD.OPT_ALT)
		GG.recursion_GiveOrderToUnit = false
		data.nextupdate = spGetGameFrame() + tonumber(UnitDefs[data.unitdef].customParams.jump_reload) -- assume we were successful.
	end
end

local function ToggleCommand(unitID, cmdParams)
	local state = cmdParams[1]
	local cmdDescID = spFindUnitCmdDesc(unitID, CMD_AUTOJUMP)
	
	if (cmdDescID) then
		sweapfire_desc.params[1] = state
		spEditUnitCmdDesc(unitID, cmdDescID, { params = sweapfire_desc.params})
	end
	unitStates[unitID] = state == 1
end

function GG.GetAutoJumpState(unitID)
	if unitStates[unitID] == nil then
		return true
	end
	return unitStates[unitID]
end

function gadget:UnitCreated(unitID, unitDefID)
	if canJumpDefs[unitDefID] then
		unitStates[unitID] = true -- default to ON.
		spInsertUnitCmdDesc(unitID, sweapfire_desc)
		ToggleCommand(unitID, {1}, {})
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if (cmdID ~= CMD_AUTOJUMP) then
		return true  -- command was not used
	end
	if unitStates[unitID] == nil then
		return false
	end
	ToggleCommand(unitID, cmdParams)
	return false
end

function gadget:UnitFinished(unitID, unitDefID)
	if wantedDefs[unitDefID] then
		IterableMap.Add(units, unitID, {nextupdate = 0, unitdef = unitDefID})
	end
end

function gadget:UnitReverseBuilt(unitID, unitDefID)
	if wantedDefs[unitDefID] then
		IterableMap.Remove(units, unitID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID)
	if wantedDefs[unitDefID] then
		IterableMap.Remove(units, unitID)
	end
end

function gadget:GameFrame(f)
	if f%UpdateRate == 2 then
		for id, data in IterableMap.Iterator(units) do
			if data.nextupdate < f then
				local canJump = (spGetUnitRulesParam(id, "jumpReload") or 1) >= 1 and (spGetUnitRulesParam(id, "disarmed") or 0) == 0 and not spGetUnitIsStunned(id)
				if canJump and unitStates[id] ~= false then
					local x, y, z = spGetUnitPosition(id)
					local gy = spGetGroundHeight(x, z)
					local currentheight = y - gy
					if debug then
						spEcho("GroundHeight: " .. currentheight)
					end
					if not GG.GetUnitFallDamageImmunity(id) and currentheight > 10 and currentheight <= 50 then
						local vx, vy, vz = spGetUnitVelocity(id)
						if debug then
							spEcho("Velocity: " .. vx .. ", " .. vy .. ", " .. vz)
						end
						if vy < -0.04 then
							DoJump(data, id, x, y, z, vx, vz, wantedDefs[data.unitdef])
						end
					end
				else
					data.nextupdate = f + (2 * UpdateRate)
				end
			end
		end
	end
end
