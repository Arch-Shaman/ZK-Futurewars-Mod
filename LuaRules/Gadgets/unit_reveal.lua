if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Unit Reveal",
		desc      = "Spawns fake los units as configured by unitdef customParams",
		author    = "StuffPhoton",
		date      = "25/07/2023",
		license   = "CC-BY-SA, v4 or later",
		layer     = 0,
		enabled   = true,
	}
end

---------------------------------------------------------------------
---------------------------------------------------------------------

local sqrt = math.sqrt
local spGetUnitDefID = Spring.GetUnitDefID
local spGetTeamList = Spring.GetTeamList
local spGetAllyTeamList = Spring.GetAllyTeamList
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGetUnitTeam = Spring.GetUnitTeam
local spGetUnitPosition = Spring.GetUnitPosition
local spCreateUnit = Spring.CreateUnit
local spDestroyUnit = Spring.DestroyUnit
local spSetUnitPosition = Spring.SetUnitPosition
local spEcho = Spring.Echo

local unitDatas = {}
local tracked = {}
local configs = {}
local allyteamLosShare = true

local debugmode = false
local name = "[unit_reveal.lua]: "

---------------------------------------------------------------------
---------------------------------------------------------------------

local function InclusiveBoolCast(string, default)
	if string == nil then
		return default
	else
		return (string and string ~= "false" and string ~= "0")
	end
end

if debugmode then spEcho(name.."Scanning weapondefs") end
for uid, udef in pairs(UnitDefs) do
	local params = udef.customParams
	if params.reveal_losunit then
		local config = {}
		configs[uid] = config
		if not UnitDefNames[params.reveal_losunit] then
			spEcho(name.."Unitdefs Error: invalid losunit parameter of '"..params.reveal_losunit.."' for "..udef.name)
		end
		config.losunit = UnitDefNames[params.reveal_losunit].id
		config.onprogress = tonumber(params.reveal_onprogress)
		config.onfinish = InclusiveBoolCast(params.reveal_onfinish, true)
		if udef.speed and config.onfinish then
			config.tracking = true
		end
	end
end
if debugmode then Spring.Utilities.TableEcho(configs, name.."configs") end
if debugmode then spEcho(name.."Finished scanning weapondefs") end


local function setRevealState(unitID, state)
	if state == (unitDatas[unitID].losUnits and true or false) then
		return
	end
	if state then
		local config = configs[spGetUnitDefID(unitID)]
		local units = {}
		local teams
		local unitTeam = spGetUnitTeam(unitID)
		if allyteamLosShare then
			teams = spGetAllyTeamList()
			for k, v in pairs(teams) do
				teams[k] = spGetTeamList(v)[1]
			end
		else
			teams = spGetTeamList()
		end
		local x, y, z = spGetUnitPosition(unitID)
		if debugmode then spEcho(name.."spawning los units") end
		for _, teamID in pairs(teams) do
			if teamID ~= team then
				units[#units+1] = spCreateUnit(config.losunit, x, y, z, "n", teamID)
				if debugmode then spEcho(name.."spawning a los unit for team"..teamID) end
			end
		end
		unitDatas[unitID].losUnits = units
	else
		local units = unitDatas[unitID].losUnits
		if debugmode then spEcho(name.."removing units") end
		for _, uid in pairs(units) do
			spDestroyUnit(uid, false, true) --TODO: fill out the params
		end
	end
end


function gadget:GameFrame(f)
	if (f+19)%32  < 0.5 then
		for unitID, data in pairs(unitDatas) do
			local _, _, _, _, buildProgress = Spring.GetUnitHealth(unitID)
			local config = configs[spGetUnitDefID(unitID)]
			if buildProgress > 0.9999 then
				setRevealState(unitID, config.onfinish)
				if config.tracking then
					tracked[unitID] = true
				end
			else
				if config.tracking then
					tracked[unitID] = false
				end
				setRevealState(unitID, buildProgress >= config.onprogress)
			end
		end
	end
	if (f+1)%4 < 0.5 then
		local losUnits, x, y, z
		for unitID, _ in pairs(tracked) do
			x, y, z = spGetUnitPosition(unitID)
			losUnits = unitDatas[unitID].losUnits
			for _, unitID in pairs(losUnits) do
				spSetUnitPosition(unitID, x, z)
			end
		end
	end
end


function gadget:UnitCreated(unitID, unitDefID)
	if not configs[unitDefID] then
		return
	end
	unitDatas[unitID] = {}
end


function gadget:UnitDestroyed(unitID, unitDefID)
	if not configs[unitDefID] then
		return
	end
	setRevealState(unitID, false)
	unitDatas[unitID] = nil
end
