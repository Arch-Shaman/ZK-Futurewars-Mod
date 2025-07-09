-- TODO: CACHE INCLUDE FILE
-- May not be worth it due to all the local data.

-- extension of scriptReload that is able to deal with multiple weapons

local ALLY_ACCESS = {allied = true}

local externalFunctions = {}

local sleeptime
local factor

local config
local weapons
local totalLoaded
local loaded = {} -- loaded shots per weapon
local reloadStartFrame = {}
local penaltyTime = {} -- not sure if needed
local loaded = {}

-- for abstract interface
local active = {}

-- todo: sequential mode (only one shot can reload at a time)
-- todo: whole mag mode (replenish whole magazine, but shooting resets cooldown)
function externalFunctions.SetupScriptMagazine(newMagazines, newSleeptime, newFactor)
	Spring.Utilities.TableEcho(newMagazines)
	sleeptime = newSleeptime or sleeptime or 100
	factor = newFactor or math.max(1,math.floor(sleeptime/33))
	config = newMagazines
	totalLoaded = 0
	weapons = {}
	for i,j in pairs(config) do
		table.insert(weapons, i)
		loaded[i] = j.size
		totalLoaded = totalLoaded + j.size
		reloadStartFrame[i] = {}
		penaltyTime[i] = {}
		active[i] = 0
	end
end

-- progress bar handling related (scriptReloadFrame)
local function SetReloadFrame(weapon)
	local minReloadFrame = math.huge
	local minReloadWeaponIdx = -1
	local minReloadShotIdx = -1
	local allReloaded = true
	for _, w in pairs({weapon} or weapons) do
		local reloadTime = config[w].reload
		for i = 0, config[w].size-1 do
			if reloadStartFrame[w][i] then
				allReloaded = false

				local value = reloadStartFrame[w][i] + (penaltyTime[w][i] or 0) + reloadTime
				if value < minReloadFrame then
					minReloadFrame = value
					minReloadShotIdx = i
				end
			end
		end
	end

	if allReloaded then
		return false
	end

	Spring.SetUnitRulesParam(unitID, "scriptReloadFrame", minReloadFrame, ALLY_ACCESS)
	return minReloadWeaponIdx, minReloadShotIdx, minReloadFrame
end

local zeroReloadMultSet = {}
--only gets called if unit was disabled or slowed down (reloadMult~=1.0)
local function UpdateReloadPenalty(weapon, shot, reloadMult)
	local penalty = (1 - reloadMult) * 3
	penaltyTime[weapon][shot] = (penaltyTime[weapon][shot] or 0) + penalty
	local minReloadWeaponIdx, minReloadShotIdx, minReloadFrame = SetReloadFrame(weapon)
	if (shot == minReloadShotIdx) and ((reloadMult > 0.0) or (not zeroReloadMultSet[weapon])) then
		Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", 1 - ((minReloadFrame-Spring.GetGameFrame())) / config[weapon].reload, ALLY_ACCESS)
		zeroReloadMultSet[weapon] = (reloadMult == 0.0)
	end
end

-- initiates reload
function externalFunctions.GunStartReload(weapon, shot)
	reloadStartFrame[weapon][shot] = Spring.GetGameFrame()
	penaltyTime[weapon][shot] = 0
	zeroReloadMultSet[weapon] = false

	loaded[weapon] = loaded[weapon] - 1
	totalLoaded = totalLoaded - 1
	Spring.SetUnitRulesParam(unitID, "scriptLoaded", totalLoaded, ALLY_ACCESS)
	Spring.SetUnitRulesParam(unitID, "scriptLoaded_"..weapon, loaded[weapon], ALLY_ACCESS)

	SetReloadFrame()
end

-- finishes reload
function externalFunctions.GunLoaded(weapon, shot)
	reloadStartFrame[weapon][shot] = nil
	penaltyTime[weapon][shot] = nil

	loaded[weapon] = loaded[weapon] + 1
	totalLoaded = totalLoaded + 1
	Spring.SetUnitRulesParam(unitID, "scriptLoaded", totalLoaded, ALLY_ACCESS)
	Spring.SetUnitRulesParam(unitID, "scriptLoaded_"..weapon, loaded[weapon], ALLY_ACCESS)

	if not SetReloadFrame() then
		Spring.SetUnitRulesParam(unitID, "scriptReloadFrame", nil, ALLY_ACCESS)
		Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", nil, ALLY_ACCESS)
	end
	return loaded[weapon] == config[weapon].size
end

-- updates (does it need shot??)
--reloadDuration in frames
function externalFunctions.SleepAndUpdateReload(weapon, shot, reloadDuration)
	local reloadTimer = 0
	local percentageSet

	while reloadTimer < reloadDuration do
		local stunnedOrInbuild = Spring.GetUnitIsStunned(unitID)
		local reloadMult = (stunnedOrInbuild and 0) or (Spring.GetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1)

		reloadTimer = reloadTimer + reloadMult * factor

		if percentageSet and (reloadMult == 1.0) then
			percentageSet = false
			Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", nil, ALLY_ACCESS)
		end

		if reloadMult < 1.0 then
			percentageSet = true
			UpdateReloadPenalty(weapon, shot, reloadMult)
		end

		Sleep(sleeptime) --3 frames
	end
end

-- internal management
local function ReloadThread(weapon, shot)
	active[weapon] = (shot+1)%config[weapon].size
	externalFunctions.GunStartReload(weapon, shot)
	externalFunctions.SleepAndUpdateReload(weapon, shot, config[weapon].reload)
	if externalFunctions.GunLoaded(weapon, shot) then
		active[weapon] = 0
	end
end

function externalFunctions.Reload(weapon, shot)
	shot = shot or active[weapon]
	Spring.Echo("Reload "..weapon.." - "..(shot or "nil"))
	Spring.Utilities.TableEcho(reloadStartFrame)
	StartThread(ReloadThread, weapon, shot)
end

function externalFunctions.CanFire(weapon, shot)
	--Spring.Echo("CanFire "..weapon.." - "..(shot or "nil"))
	--Spring.Echo("active: "..(active[weapon] or "nil"))
	--Spring.Echo(type(weapon))
	--Spring.Echo(active[1])
	--Spring.Echo(active["1"])
	--Spring.Utilities.TableEcho(active)
	shot = shot or active[weapon]
	return not reloadStartFrame[weapon][shot]
end

--function externalFunctions.CanFireAny(weapon)
--	return not reloadStartFrame[weapon][active[weapon]]
--end

return externalFunctions