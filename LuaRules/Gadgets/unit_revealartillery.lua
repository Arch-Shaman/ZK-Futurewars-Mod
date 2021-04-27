if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name      = "Artillery Unit Self-Reveal",
		desc      = "Artillery units self reveal when firing",
		author    = "Shaman",
		date      = "4/23/2021",
		license   = "PD-0",
		layer     = 1,
		enabled   = true  --  loaded by default?
	}
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

local units = IterableMap.New()
local siloDefID = UnitDefNames.staticmissilesilo.id
local missiles = {}

local spSetUnitLosMask = Spring.SetUnitLosMask
local spSetUnitLosState = Spring.SetUnitLosState
local spGetAllyTeamList = Spring.GetAllyTeamList
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spIsUnitInJammer = Spring.IsUnitInJammer
local spIsPosInRadar = Spring.IsPosInRadar
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitIsCloaked = Spring.GetUnitIsCloaked
local spGetUnitDefID = Spring.GetUnitDefID
local spGetPositionLosState = Spring.GetPositionLosState

-- CONFIG --
local wantedDefs = {}

for w = 1, #WeaponDefs do
	local WeaponDef = WeaponDefs[w]
	local cp = WeaponDef.customParams
	if cp["reveal_unit"] then
		wantedDefs[w] = tonumber(cp["reveal_unit"])
	end
end

-- FUNCTIONS --

local function Reveal(unitID)
	local myAllyTeam = spGetUnitAllyTeam(unitID)
	local allyTeams = spGetAllyTeamList()
	local x, y, z = Spring.GetUnitPosition(unitID)
	for i = 1, #allyTeams do
		local allyTeamID = allyTeams[i]
		if myAllyTeam ~= allyTeamID then
			local _, inLOS, inRadar = spGetPositionLosState(x, y, z, allyTeamID)
			if inRadar and not inLOS then
				spSetUnitLosMask(unitID, allyTeamID, 15) -- see: https://github.com/ZeroK-RTS/Zero-K/blob/master/LuaRules/Gadgets/unit_show_shooter.lua
				spSetUnitLosState(unitID, allyTeamID, 15)
			else
				spSetUnitLosMask(unitID, allyTeamID, 0)
				spSetUnitLosState(unitID, allyTeamID, 0)
			end
		end
	end
end

local function Unreveal(unitID)
	local allyTeams = spGetAllyTeamList()
	local myAllyTeam = spGetUnitAllyTeam(unitID)
	local x, y, z = spGetUnitPosition(unitID)
	for i = 1, #allyTeams do
		local allyTeamID = allyTeams[i]
		if myAllyTeam ~= allyTeamID then
			spSetUnitLosMask(unitID, allyTeamID, 0)
			spSetUnitLosState(unitID, allyTeamID, 0)
		end
	end
end

local function CheckReveal(unitID)
	local x, y, z = spGetUnitPosition(unitID)
	local _, _, _, inJammer = spGetPositionLosState(x, y, z, myAllyTeam)
	local isCloaked = spGetUnitIsCloaked(unitID)
	if inJammer or isCloaked then
		Unreveal(unitID)
	elseif not inJammer and not isCloaked then
		Reveal(unitID)
	end
end

-- CALLINS --

function gadget:UnitFromFactory(unitID, unitDefID, unitTeam, facID, facDefID)
	if facDefID == siloDefID then
		missiles[unitID] = facID
	end
end

function gadget:UnitDestroyed(unitID)
	if IterableMap.InMap(units, unitID) then
		IterableMap.Remove(units, unitID)
	end
	missiles[unitID] = nil
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	if wantedDefs[weaponID] == nil then
		return
	end
	proOwnerID = missiles[proOwnerID] or proOwnerID
	IterableMap.Set(units, proOwnerID, wantedDefs[weaponID])
	CheckReveal(proOwnerID)
end

function gadget:UnitCloaked(unitID)
	if IterableMap.InMap(units, unitID) then
		CheckReveal(unitID) -- force the update to occur.
	end
end

function gadget:UnitDecloaked(unitID)
	if IterableMap.InMap(units, unitID) then
		CheckReveal(unitID) -- ditto.
	end
end

function gadget:GameFrame(f)
	if f%30 == 0 then -- 2hz
		for unitID, timer in IterableMap.Iterator(units) do
			timer = timer - 1
			IterableMap.Set(units, unitID, timer)
			--Spring.Echo("[RevealArty] " .. unitID .. ": " .. timer)
			if timer == 0 then
				Unreveal(unitID)
				IterableMap.Remove(units, unitID)
			else
				CheckReveal(unitID)
			end
		end
	end
end
