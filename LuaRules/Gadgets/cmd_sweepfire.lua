if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
  return {
    name      = "Sweepfire",
    desc      = "A Sweepfire Command.",
    author    = "Shaman based on terve886's widgets.",
    date      = "2/21/2021",
    license   = "CC-0",
    layer     = 5,
    enabled   = true,
  }
end

-- Speedups --

local spEcho = Spring.Echo
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitNearestEnemy = Spring.GetUnitNearestEnemy
local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitWeaponTarget = Spring.GetUnitWeaponTarget
local spGetUnitWeaponState = Spring.GetUnitWeaponState
local spGetUnitHeading = Spring.GetUnitHeading
local spGetGameFrame = Spring.GetGameFrame
local spValidUnitID = Spring.ValidUnitID
local spUtilitiesGetEffectiveWeaponRange = Spring.Utilities.GetEffectiveWeaponRange
local cos = math.cos
local sin = math.sin
local floor = math.floor
local rad = math.rad
local abs = math.abs
local min = math.min
local atan2 = math.atan2
local pi = math.pi
local random = math.random
local ceil = math.ceil
local deg = math.deg
local IterableMap = Spring.Utilities.IterableMap

local CMD_SWEEPFIRE = Spring.Utilities.CMD.SWEEPFIRE
local CMD_SWEEPFIRE_MINES = Spring.Utilities.CMD.SWEEPFIRE_MINES

-- constants --
local headingtorad = (math.pi * 2 / 65536)

-- Defs --

spEcho("Sweapfire: Loading defs..")
local config, minelayerdefs, reverseweaponids = VFS.Include("LuaRules/Configs/sweapfire_defs.lua")
-- descriptions --

local sweapfire_desc = {
	id      = CMD_SWEEPFIRE,
	type    = CMDTYPE.ICON_MAP,
	name	= 'Sweep Attack',
	tooltip = 'Makes this unit attack positions in the direction of this command',
	cursor  = 'Attack',
	action  = 'sweepfire',
}

local minelayer_desc = {
	id      = CMD_SWEEPFIRE_MINES,
	type    = CMDTYPE.ICON_MAP,
	name	= 'Lay Mines',
	tooltip = 'Makes this unit lay mines in the direction of this command.',
	cursor  = 'Attack',
	action  = 'sweepfire',
}

-- Variables --
local UnitData = IterableMap.New()
local debugMode = false
local CommandOrder = 123456
local overrides = {}

-- Debug --

local function DebugEcho(str)
	spEcho("[Sweepfire]: " .. str)
end

local function PrintConfig()
	local str = ''
	for id, data in pairs(config) do
		str = str .. '\n\t' .. id .. ':'
		for i = 1, #data do
			for k, v in pairs(data[i]) do
				str = str .. '\n\t\t' .. k .. ': ' .. tostring(v)
			end
		end
	end
	DebugEcho("Starting Game with configuration: " .. str)
end

if debugMode then
	PrintConfig()
end

-- Utilities --

local function HeadingToRad(heading)
	return heading * headingtorad
end

local function GetUnitHeading(unitID)
	return HeadingToRad(spGetUnitHeading(unitID))
end

local function GetWeaponDefID(def, weaponnum)
	return WeaponDefs[UnitDefs[def].weapons[weaponnum].weaponDef].id
end

local function ReverseLookup(def, weaponum)
	return reverseweaponids[def][weaponum]
end

local function GetLowestHeightOnCircle(x, z, radius, points)
	local anglepercheck = rad(360 / (points + 1))
	local currentangle = 0
	local lowest = math.huge
	for i = 1, points + 1 do
		local cx = x + radius * cos(currentangle)
		local cz = z + radius * sin(currentangle)
		currentangle = currentangle + anglepercheck
		local groundy = spGetGroundHeight(cx, cz)
		if groundy < lowest then
			lowest = groundy
		end
	end
	if lowest < 0 then -- don't bother with UW stuff.
		lowest = 0
	end
	return lowest
end

local function GetUnitRange(unitID, weaponNum, runs, unitDefID)
	local x, y, z = spGetUnitPosition(unitID)
	--local unitDefID = spGetUnitDefID(unitID)
	local weapondefid = UnitDefs[unitDefID].weapons[weaponNum].weaponDef
	local weapondef = WeaponDefs[weapondefid]
	local originalrange = weapondef.range
	local config = config[unitDefID][ReverseLookup(unitDefID, weaponNum)]
	--spEcho("Maxrangemult: " .. tostring(config[weapondefid].maxrangemult))
	if config.maxrangemult and config.maxrangemult ~= 1 then
		return originalrange * config.maxrangemult
	end
	if weapondef.type == "BeamLaser" then
		return originalrange * 0.9 -- for whatever reason lotus doesn't like to attack at maxrange.
	end
	if weapondef.type ~= "Cannon" then
		return originalrange
	end
	if runs == nil or runs == 1 then
		local oy = GetLowestHeightOnCircle(x, z, originalrange, 9)
		return spUtilitiesGetEffectiveWeaponRange(unitDefID, y - oy, weaponNum)
	else
		for i = 1, runs do
			local oy = GetLowestHeightOnCircle(x, z, originalrange, 9)
			originalrange = spUtilitiesGetEffectiveWeaponRange(unitDefID, y - oy, weaponNum)
		end
		return originalrange
	end
end

local function CalculateAngle(x, z, targetx, targetz) -- first set of coords: center, second: point
	--local heading = GetUnitHeading(unitID)
	local angle = atan2(targetz - z, targetx - x )
	if debugMode then
		DebugEcho("Initial heading: " .. deg(angle))
	end
	return angle -- Used for determining the center of the arc.
end

local function GetFiringPoint(radius, x, z, angle)
	return x + (radius * cos(angle)), z + (radius * sin(angle))
end

local function ForceFireAtPoint(unitID, x, z, weaponID)
	GG.SetTemporaryPosTarget(unitID, x, spGetGroundHeight(x, z), z, false, 1, weaponID)
end


local function UpdateOffset(unitID, weaponID)
	local data = IterableMap.Get(UnitData, unitID)
	local configuration = config[data.unitdef][weaponID]
	local currentoffset = data.weaponstates[weaponID].currentoffset
	local offset = currentoffset + (((data.weaponstates[weaponID].reversed and -1) or 1) * configuration.step)
	if debugMode then
		DebugEcho(unitID .. " Offset: " .. currentoffset .. " -> " .. offset)
	end
	data.weaponstates[weaponID].currentoffset = offset
	if abs(offset) >= configuration.maxangle then
		data.weaponstates[weaponID].reversed = not data.weaponstates[weaponID].reversed
	end
end

local function UpdateFiringPoint(unitID, weapon, angle, unitdef)
	local x, y, z = spGetUnitPosition(unitID, true)
	local range = GetUnitRange(unitID, weapon, 1, unitdef)
	local myconfig = config[unitdef][weapon]
	if myconfig.minelayer then
		range = random(ceil(range * 0.4), range)
		if debugMode then
			DebugEcho("New range: " .. range)
		end
	end
	local tx, tz = GetFiringPoint(range, x, z, angle)
	ForceFireAtPoint(unitID, tx, tz, weapon)
end

local function GetWeaponIsFiringAtSomething(unitID, weaponID)
	local type, isUserTarget = spGetUnitWeaponTarget(unitID, weaponID)
	if debugMode then
		DebugEcho("isUser: " .. tostring(isUserTarget) .. "\ntype: " .. tostring(type) .. "\nReturn: " .. tostring(type == 1 or isUserTarget == true))
	end
	return type == 1 or isUserTarget == true
end


local function AddUnit(unitID, cmdParams)
	if debugMode then
		local paramstr = ''
		if type(cmdParams):lower() == 'table' then
			for id, data in pairs(cmdParams) do
				paramstr = paramstr .. '\n\t' .. id .. ': ' .. tostring(data)
			end
		end
		DebugEcho("AddUnit: " .. unitID .. "\n\tParams:" .. paramstr)
	end
	local defid = spGetUnitDefID(unitID)
	local configuration = config[defid]
	if configuration == nil then
		return -- some other unit got batched in.
	end
	local tx = cmdParams[1]
	local tz = cmdParams[3]
	local x, _, z = spGetUnitPosition(unitID)
	local data = {sweeping = false, weaponstates = {}, nextupdate = 0, unitdef = defid, initialangle = CalculateAngle(x, z, tx, tz)}
	for i = 1, #configuration do
		local rev = random(0,4) >= 2
		data.weaponstates[i] = {reversed = rev, currentoffset = rad(random(-5, 5))}
	end
	IterableMap.Add(UnitData, unitID, data)
end

local function CheckUnitHasTargetInRange(unitID, range)
	if debugMode then
		DebugEcho("HasTargetInRange: " .. tostring(spGetUnitNearestEnemy(unitID, range, true) ~= nil))
	end
	return spGetUnitNearestEnemy(unitID, range, true) ~= nil
end

local function CheckUnitNeedsSweeping(unitID, def)
	local range = 0
	for i = 1, #UnitDefs[def].weapons do
		if config[def][ReverseLookup(def, i)] ~= nil then
			local myrange = GetUnitRange(unitID, i, 1, def)
			local isfiring = GetWeaponIsFiringAtSomething(unitID, i)
			if isfiring then
				return false
			end
			if myrange > range then
				range = myrange
			end
		end
	end
	if range == nil then
		return false
	end
	return not CheckUnitHasTargetInRange(unitID, range)
end

local function UpdateUnitInfo(unitID, cmdParams)
	local tx, tz = cmdParams[1], cmdParams[3]
	local x, z = spGetUnitPosition(unitID)
	local data = IterableMap.Get(UnitData, unitID)
	data.initialangle = CalculateAngle(x, z, tx, tz)
	local configuration = config[data.unitdef]
	for i = 1, #configuration do
		local rev = random(0,4) >= 2
		data.weaponstates[i].reversed = rev
		data.currentoffset = rad(random(-5, 5))
	end
end

local function RemoveUnit(unitID)
	if IterableMap.InMap(UnitData, unitID) then
		IterableMap.Remove(UnitData, unitID)
	end
end

local function ForceUnitHaveSweepFire(unitID, minelayer, maxangle, step, maxrange, weapon)
	if minelayer then
		spInsertUnitCmdDesc(unitID, CommandOrder, minelayer_desc)
	else
		spInsertUnitCmdDesc(unitID, CommandOrder, sweapfire_desc)
	end
	local updatespeed = WeaponDefs[UnitDefs[unitdefid].weapons[weapon].weaponDef].reload
	local unitdefid = spGetUnitDefID(unitID)
	if overrides[unitID] == nil then
		overrides[unitID] = {}
	end
	overrides[unitID][#overrides[unitID] + 1] = {maxangle = maxangle, step = step, updatespeed = updatespeed, maxrange = maxrange, weaponNum = weapon}
end

GG.AddSweepFireToUnit = ForceUnitHaveSweepFire

-- Callins --

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID) -- inject command.
	if config[unitDefID] then
		local def = config[unitDefID]
		if minelayerdefs[unitDefID] then
			spInsertUnitCmdDesc(unitID, CommandOrder, minelayer_desc)
		else
			spInsertUnitCmdDesc(unitID, CommandOrder, sweapfire_desc)
		end
	end
end

function gadget:UnitDestroyed(unitID)
	overrides[unitID] = nil
	if IterableMap.InMap(UnitData, unitID) then
		RemoveUnit(unitID)
	end
end
	
function gadget:AllowCommand_GetWantedCommand()
	local wanted = {[CMD_SWEEPFIRE] = true, [CMD_SWEEPFIRE_MINES] = true, [CMD.STOP] = true}
	return wanted
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions) -- route commands.
	if cmdID == CMD_SWEEPFIRE or cmdID == CMD_SWEEPFIRE_MINES then
		if not IterableMap.InMap(UnitData, unitID) then
			AddUnit(unitID, cmdParams)
		else
			UpdateUnitInfo(unitID, cmdParams)
		end
		return false
	else
		GG.RemoveTemporaryPosTarget(unitID)
		RemoveUnit(unitID)
		return true
	end
end

function gadget:GameFrame(f)
	for id, data in IterableMap.Iterator(UnitData) do
		if data.nextupdate <= f then
			if not spValidUnitID(id) then
				IterableMap.Remove(UnitData, id)
			else
				local wantssweep = CheckUnitNeedsSweeping(id, data.unitdef)
				if wantssweep then -- we have no target, so we can sweep away.
					data.sweeping = true
					local configuration = overrides[id] or config[data.unitdef]
					local nextupdate = math.huge
					for w = 1, #configuration do
						local weaponnum = configuration[w].weaponNum
						local reload = spGetUnitWeaponState(id, weaponnum, "reloadState")
						local potential = min(f + floor(WeaponDefs[UnitDefs[data.unitdef].weapons[weaponnum].weaponDef].reload * 30), reload)
						if potential < nextupdate then
							nextupdate = potential
						end
						if reload == nil or reload <= f then -- we're ready to go
							if configuration[w].centerreadjust then
								data.initialangle = GetUnitHeading(id)
							end
							UpdateOffset(id, weaponnum)
							nextupdate = f + ((configuration[w].fastupdate and 0) or 3)
							if debugMode then
								DebugEcho("Next update: " .. nextupdate)
							end
							local wantedangle = data.weaponstates[weaponnum].currentoffset + data.initialangle
							UpdateFiringPoint(id, weaponnum, wantedangle, data.unitdef)
						end
					end
					data.nextupdate = nextupdate
				else
					if data.sweeping then
						GG.RemoveTemporaryPosTarget(id)
						data.sweeping = false
					end
					data.nextupdate = f + 10 -- check again later.
				end
			end
		end
	end
end
