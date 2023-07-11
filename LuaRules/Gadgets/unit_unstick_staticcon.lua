function gadget:GetInfo()
	return {
		name      = "Static Con Unsticker",
		desc      = "Implements Caretaker / rejuvenator unstick.",
		author    = "Shaman",
		date      = "4-20-2022",
		license   = "PD",
		layer     = 0,
		enabled   = true,
	}
end

if not (gadgetHandler:IsSyncedCode()) then
	return
end

local delay = 15
local debugMode = false

local handled = {} -- [f] = {[1] = unitID}
local buildRanges = {} -- [unitDefID] = buildDistance

for i = 1, #UnitDefs do
	local def = UnitDefs[i]
	if def.isBuilder and def.customParams.like_structure then
		buildRanges[i] = def.buildDistance
	end
end

--[[local buildRanges = {
	[UnitDefNames["staticrepair"].id] = UnitDefNames["staticrepair"].buildDistance,
	[UnitDefNames["staticcon"].id] = UnitDefNames["staticcon"].buildDistance,
	[UnitDefNames["striderhub"].id] = UnitDefNames["striderhub"].buildDistance,
}]]

-- Speedups --
local CMD_INSERT = CMD.INSERT
local CMD_REPAIR = CMD.REPAIR
local CMD_RECLAIM = CMD.RECLAIM
local CMD_RESURRECT = CMD.RESURRECT
local CMD_REMOVE = CMD.REMOVE
local spEcho = Spring.Echo
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spValidUnitID = Spring.ValidUnitID
local spGetGameFrame = Spring.GetGameFrame
local spGetUnitIsStunned = Spring.GetUnitIsStunned
local spGetUnitCurrentCommand = Spring.GetUnitCurrentCommand
local spValidFeatureID = Spring.ValidFeatureID
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitDefID = Spring.GetUnitDefID
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetUnitTeam = Spring.GetUnitTeam
--local EMPTY = {}

local function DebugEcho(str)
	spEcho("[unit_staticcon_unsticker]: " .. str)
end

local function GetDistance(unitID, targetID, isReclaim)
	local x, _, z = spGetUnitPosition(unitID)
	local x2, z2
	if isReclaim then
		if spValidFeatureID(targetID) then
			x2, _, z2 = spGetFeaturePosition(targetID)
		elseif spValidUnitID(targetID) then -- live reclaim
			x2, _, z2 = spGetUnitPosition(targetID)
		end
	else
		x2, _, z2 = spGetUnitPosition(targetID)
	end
	if not x2 then
		if debugMode then DebugEcho("Target doesn't exist?") end
		return 9999
	end
	return math.sqrt(((x2 - x) * (x2 - x)) + ((z2 - z) * (z2 - z)))
end

local function IsObjectCloseEnough(unitID, targetID, cmd) -- Note: build ranges are 2D usually.
	if cmd == CMD_REPAIR and spValidUnitID(targetID) then
		local dist = GetDistance(unitID, targetID, false)
		if debugMode then
			DebugEcho(unitID .. ": Distance: " .. dist .. " (Build Range: " .. buildRanges[spGetUnitDefID(unitID)] .. ")")
		end
		return dist <= buildRanges[spGetUnitDefID(unitID)]
	elseif (cmd == CMD_RECLAIM or cmd == CMD_RESURRECT) then
		local dist
		if spValidFeatureID(targetID) then
			dist = GetDistance(unitID, targetID, true)
		else
			dist = GetDistance(unitID, targetID, false)
		end
		if debugMode then
			DebugEcho(unitID .. ": Distance: " .. dist .. " (Build Range: " .. buildRanges[spGetUnitDefID(unitID)] .. ")")
		end
		return dist <= buildRanges[spGetUnitDefID(unitID)]
	else
		return false
	end
end

local function HandleUnit(unitID, f)
	if spValidUnitID(unitID) then
		local _, _, unbuilt = spGetUnitIsStunned(unitID)
		if not unbuilt then -- if caretaker is reversed built, UnitFinished should retrigger to readd it, though nobody really unbuilds caretakers.
			local cmdID, _, cmdTag, cmdParam1, cmdParam2, cmdParam3, cmdParam4, cmdParam5 = spGetUnitCurrentCommand(unitID)
			if cmdParam1 and spValidFeatureID(cmdParam1 - Game.maxUnits) then
				cmdParam1 = cmdParam1 - Game.maxUnits
			end
			if debugMode then DebugEcho(unitID .. ": " .. tostring(cmdID) .. ", " .. tostring(cmdParam1) .. ", " .. tostring(cmdParam2)) end
			local range = buildRanges[spGetUnitDefID(unitID)]
			if cmdID and (cmdID == CMD_RECLAIM or cmdID == CMD_RESURRECT) and cmdParam1 and (spValidFeatureID(cmdParam1) or spValidUnitID(cmdParam1)) then
				if debugMode then DebugEcho(unitID .. ": Valid command, checking distance.") end
				if not IsObjectCloseEnough(unitID, cmdParam1, cmdID) or (cmdID == CMD_RECLAIM and cmdParam5 and cmdParam5 == range and not GG.CheckORPForTeam(spGetUnitTeam(unitID)) and not GG.GetORPState(unitID)) then
					if debugMode then DebugEcho(unitID .. ": Command dropped (Out of Range / ORP)") end
					spGiveOrderToUnit(unitID, CMD_REMOVE, cmdTag, 0)
					if cmdParam5 and cmdParam5 ~= range then -- this was an area command added by the user.
						if debugMode then DebugEcho("Readding area command: " .. tostring(cmdParam2) .. ", " .. tostring(cmdParam3) .. ", " .. tostring(cmdParam4) .. ", " .. tostring(cmdParam5)) end
						spGiveOrderToUnit(unitID, CMD_INSERT, {0, cmdID, CMD.OPT_SHIFT, cmdParam2, cmdParam3, cmdParam4, cmdParam5}, CMD.OPT_ALT) -- For whatever reason, when removing reclaim/repair orders from area orders, it removes the command itself. Don't ask me.
					end
				end
			elseif debugMode then
				DebugEcho("Invalid command handled for " .. unitID)
			end
			handled[f + delay] = handled[f + delay] or {} -- check back in 15 frames.
			handled[f + delay][#handled[f + delay] + 1] = unitID
		elseif debugMode then 
			DebugEcho(unitID .. ": Exited drop (Reverse Built)")
		end
	end
end

--[[function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams)
	if buildRanges[unitDefID] == nil or cmdID ~= CMD_RECLAIM then
		return true
	elseif cmdID == CMD_RECLAIM and not GG.GetORPState(unitID) and not GG.CheckORPForTeam(unitTeam) then 
		return false
	else
		return true
	end
end]]

function gadget:GameFrame(f)
	if handled[f] then
		for i = 1, #handled[f] do
			if debugMode then DebugEcho("Check " .. handled[f][i]) end
			HandleUnit(handled[f][i], f)
		end
		handled[f] = nil
	end
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if buildRanges[unitDefID] then
		if debugMode then DebugEcho(unitID .. ": Added to check loop.") end
		local f = spGetGameFrame() + delay
		handled[f] = handled[f] or {}
		handled[f][#handled[f] + 1] = unitID
	end
end

function gadget:Initialize()
	-- load active units
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		local _,_,inBuild = Spring.GetUnitIsStunned(unitID)
		if not inBuild then
			gadget:UnitFinished(unitID, unitDefID)
		end
	end
end
