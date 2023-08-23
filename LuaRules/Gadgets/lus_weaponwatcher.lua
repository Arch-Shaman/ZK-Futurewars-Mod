if not gadgetHandler:IsSyncedCode() then -- SYNCED
	return
end

function gadget:GetInfo()
  return {
    name      = "Watch Weapon Reload",
    desc      = "Watches for when weapons are reloaded to notify lus.",
    author    = "Shaman",
    date      = "21 Aug 2023",
    license   = "CC-0",
    layer     = -5, -- before LUS.
    enabled   = true,
  }
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")
local WatchUnits = IterableMap.New()
local WatchFrames = {}

local function RemoveUnit(unitID)
	IterableMap.Remove(WatchUnits, unitID)
end

local function AddUnitToWatchUnits(unitID, weaponNum)
	local data = IterableMap.Get(WatchUnits, unitID)
	if data then
		data[#data + 1] = weaponNum
	else
		local newData = {}
		newData[#newData + 1] = weaponNum
		IterableMap.Add(WatchUnits, unitID, newData)
	end
end

function GG.LusWatchWeaponReload(unitID, weaponNum)
	local reloadFrame = Spring.GetUnitWeaponState(unitID, weaponNum, "reloadState")
	if WatchFrames[reloadFrame] then
		local index = #WatchFrames[reloadFrame] + 1
		WatchFrames[reloadFrame][index] = {unitID = unitID, weaponNum = weaponNum}
	else
		WatchFrames[reloadFrame] = {[1] = {unitID = unitID, weaponNum = weaponNum}}
	end
end

local function ShiftTableDown(data, pos)
	if pos == #data then
		data[#data] = nil
	else
		data[pos] = data[#data]
		data[#data] = nil
	end
end

local function CallAsUnitIfExists(unitID, funcName, ...)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	if not env then
		return
	end
	if env and env[funcName] then
		Spring.UnitScript.CallAsUnit(unitID, env[funcName], ...)
	end
end

local function CallInAsUnit(unitID, weaponNum)
	CallAsUnitIfExists(unitID, "OnWeaponReload", weaponNum)
end

local function RemoveWeaponFromWatch(unitID, data, position)
	if #data == 1 then -- we're about to remove the unit.
		RemoveUnit(unitID)
	else
		ShiftTableDown(data, position)
	end
end

function gadget:GameFrame(f)
	if WatchFrames[f] then
		for i = 1, #WatchFrames[f] do
			local unitID = WatchFrames[f][i].unitID
			if Spring.ValidUnitID(unitID) then
				local WeaponNum = WatchFrames[f][i].weaponNum
				local reloadFrame = Spring.GetUnitWeaponState(unitID, WeaponNum, "reloadState")
				if reloadFrame <= f then
					CallInAsUnit(unitID, WeaponNum)
				else -- unit hasn't reloaded, check every frame.
					AddUnitToWatchUnits(unitID, WeaponNum)
				end
			end
		end
		WatchFrames[f] = nil
	end
	for unitID, data in IterableMap.Iterator(WatchUnits) do
		local removeNums = {}
		for i = 1, #data do
			local weaponNum = data[i]
			local reloadFrame = Spring.GetUnitWeaponState(unitID, weaponNum, "reloadState")
			if reloadFrame <= f then
				removeNums[#removeNums + 1] = i
			end
		end
		if #removeNums > 0 then
			if #removeNums == #data then -- we are removing the unit.
				for i = 1, #removeNums do
					CallInAsUnit(unitID, removeNums[i])
				end
				RemoveUnit(unitID)
			else
				for i = 1, #removeNums do
					local position = removeNums[i]
					CallInAsUnit(unitID, data[position])
					RemoveWeaponFromWatch(unitID, data, position)
				end
			end
		end
	end
end

function gadget:UnitDestroyed(unitID)
	RemoveUnit(unitID)
end
