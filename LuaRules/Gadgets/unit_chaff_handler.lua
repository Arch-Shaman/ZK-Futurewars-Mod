function gadget:GetInfo() 
	return {
		name      = "Radar Chaff",
		desc      = "Implements radar chaff.",
		author    = "Shaman",
		date      = "10 June 2024",
		license   = "CC BY-NC-ND",
		layer     = 1,
		enabled   = false,
	} 
end

--[[Design goals:
1. Chaff units despawn when their parent unit is spotted.
2. Chaff can be part of weapons
]]

local chaffUnits = {
	[UnitDefNames['chaffunit'].id] = true,
}

if (not gadgetHandler:IsSyncedCode()) then 
	function gadget:UnitEnteredLos(unitID, unitTeam, allyTeam, unitDefID)
		if chaffUnits[unitDefID] then
			
		end
	end
end

local IterableMap = Spring.Utilities.IterableMap
local chaffData = IterableMap.New() --[[ 
	unitID = {
		type = 0(stationary) || 1 (mobile),
		timer = num || nil (no timer),
		attachedUnit = unitID || nil (stationary),
		angle = num || nil.
		dist = num || nil,
		
]]
local ownerData = IterableMap.New()
local chaffByUnitID = {} -- unitID = {listOfChaff}
local ownerByChaffID = {}
local updateRate = 3

local spuTranslateLosBitToBools = Spring.Utilities.LosInfo.TranslateLosBitToBools

local function CheckChaffUnit(unitID)
	

local function SpawnChaffUnit(ownerID)
	
end

function gadget:GameFrame(f)
	if f%updateRate == 0 then
		for unitID, data in IterableMap.Iterator(chaffData) do
			
		end
	end
	if f%updateRate == 1 then
		for unitID, data in IterableMap.Iterator(ownerData) do
			
		end
	end
end
