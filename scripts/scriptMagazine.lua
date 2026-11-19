-- TODO: CACHE INCLUDE FILE
-- May not be worth it due to all the local data.

-- extension of scriptReload that is able to deal with multiple weapons

local ALLY_ACCESS = {allied = true}

local Magazine = {}

local sleeptime
local factor

local config
local weapons
local totalLoaded
Magazine.loaded = {} -- loaded shots per weapon
Magazine.reloadStartFrame = {}
Magazine.penaltyTime = {} -- not sure if needed

-- for abstract interface
Magazine.active = {}

-- todo: sequential mode (only one shot can reload at a time)
-- todo: whole mag mode (replenish whole magazine, but shooting resets cooldown)
function Magazine:SetupScriptMagazine(newMagazines, newSleeptime, newFactor)
	Spring.Utilities.TableEcho(newMagazines)
	self.sleeptime = newSleeptime or 100
	self.factor = newFactor or math.max(1,math.floor(self.sleeptime/33))
	self.config = newMagazines
	self.totalLoaded = 0
	self.weapons = {}
	for i,j in pairs(self.config) do
		table.insert(self.weapons, i)
		self.loaded[i] = j.size
		self.totalLoaded = self.totalLoaded + j.size
		self.reloadStartFrame[i] = {}
		self.penaltyTime[i] = {}
		self.active[i] = 0
	end
end

-- progress bar handling related (scriptReloadFrame)
function Magazine:SetReloadFrame(weapon)
	local minReloadFrame = math.huge
	local minReloadWeaponIdx = -1
	local minReloadShotIdx = -1
	local allReloaded = true
	for _, w in pairs({weapon} or self.weapons) do
		local reloadTime = self.config[w].reload
		for i = 0, self.config[w].size-1 do
			if self.reloadStartFrame[w][i] then
				allReloaded = false

				local value = self.reloadStartFrame[w][i] + (self.penaltyTime[w][i] or 0) + reloadTime
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

Magazine.zeroReloadMultSet = {}
--only gets called if unit was disabled or slowed down (reloadMult~=1.0)
function Magazine:UpdateReloadPenalty(weapon, shot, reloadMult)
	local penalty = (1 - reloadMult) * 3
	self.penaltyTime[weapon][shot] = (self.penaltyTime[weapon][shot] or 0) + penalty
	local minReloadWeaponIdx, minReloadShotIdx, minReloadFrame = self:SetReloadFrame(weapon)
	if (shot == minReloadShotIdx) and ((reloadMult > 0.0) or (not self.zeroReloadMultSet[weapon])) then
		Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", 1 - ((minReloadFrame-Spring.GetGameFrame())) / self.config[weapon].reload, ALLY_ACCESS)
		self.zeroReloadMultSet[weapon] = (reloadMult == 0.0)
	end
end

-- initiates reload
function Magazine:GunStartReload(weapon, shot)
	self.reloadStartFrame[weapon][shot] = Spring.GetGameFrame()
	self.penaltyTime[weapon][shot] = 0
	self.zeroReloadMultSet[weapon] = false

	self.loaded[weapon] = self.loaded[weapon] - 1
	self.totalLoaded = self.totalLoaded - 1
	Spring.SetUnitRulesParam(unitID, "scriptLoaded", self.totalLoaded, ALLY_ACCESS)
	Spring.SetUnitRulesParam(unitID, "scriptLoaded_"..weapon, self.loaded[weapon], ALLY_ACCESS)

	self:SetReloadFrame()
end

-- finishes reload
function Magazine:GunLoaded(weapon, shot)
	self.reloadStartFrame[weapon][shot] = nil
	self.penaltyTime[weapon][shot] = nil

	self.loaded[weapon] = self.loaded[weapon] + 1
	self.totalLoaded = self.totalLoaded + 1
	Spring.SetUnitRulesParam(unitID, "scriptLoaded", self.totalLoaded, ALLY_ACCESS)
	Spring.SetUnitRulesParam(unitID, "scriptLoaded_"..weapon, self.loaded[weapon], ALLY_ACCESS)

	if not self:SetReloadFrame() then
		Spring.SetUnitRulesParam(unitID, "scriptReloadFrame", nil, ALLY_ACCESS)
		Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", nil, ALLY_ACCESS)
	end
	return self.loaded[weapon] == self.config[weapon].size
end

-- updates (does it need shot??)
--reloadDuration in frames
function Magazine:SleepAndUpdateReload(weapon, shot, reloadDuration)
	local reloadTimer = 0
	local percentageSet

	while reloadTimer < reloadDuration do
		local stunnedOrInbuild = Spring.GetUnitIsStunned(unitID)
		local reloadMult = (stunnedOrInbuild and 0) or (Spring.GetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1)

		reloadTimer = reloadTimer + reloadMult * self.factor

		if percentageSet and (reloadMult == 1.0) then
			percentageSet = false
			Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", nil, ALLY_ACCESS)
		end

		if reloadMult < 1.0 then
			percentageSet = true
			self:UpdateReloadPenalty(weapon, shot, reloadMult)
		end



		Sleep(self.sleeptime) --3 frames
	end
end

function Magazine:SeqReload(weapon, shot, reloadDuration)
	local reloadTimer = 0
	local percentageSet

	while self.loaded[weapon] < self.config[weapon].size do
		local stunnedOrInbuild = Spring.GetUnitIsStunned(unitID)
		local reloadMult = (stunnedOrInbuild and 0) or (Spring.GetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1)

		reloadTimer = reloadTimer + reloadMult * self.factor

		if percentageSet and (reloadMult == 1.0) then
			percentageSet = false
			Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", nil, ALLY_ACCESS)
		end

		if reloadMult < 1.0 then
			percentageSet = true
			self:UpdateReloadPenalty(weapon, shot, reloadMult)
		end

		if reloadTimer >= reloadDuration then
			self:GunLoaded(weapon,shot)
			shot = (shot+1)%self.config[weapon].size
			reloadTimer = reloadTimer - reloadDuration
		end

		Sleep(self.sleeptime) --3 frames
	end
end

function Magazine:MagReload(weapon, reloadDuration)
	self.reloadTimer = 0
	local percentageSet

	while self.reloadTimer < reloadDuration do
		local stunnedOrInbuild = Spring.GetUnitIsStunned(unitID)
		local reloadMult = (stunnedOrInbuild and 0) or (Spring.GetUnitRulesParam(unitID, "totalReloadSpeedChange") or 1)

		self.reloadTimer = self.reloadTimer + reloadMult * self.factor

		if percentageSet and (reloadMult == 1.0) then
			percentageSet = false
			Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", nil, ALLY_ACCESS)
		end

		if reloadMult < 1.0 then
			percentageSet = true
			self:UpdateReloadPenalty(weapon, 0, reloadMult)
		end

		Sleep(self.sleeptime) --3 frames
	end

	local prev = self.loaded[weapon]
	self.loaded[weapon] = self.config[weapon].size
	self.totalLoaded = self.totalLoaded + self.loaded[weapon] - prev
	self.reloadStartFrame[weapon] = {}
	self.penaltyTime[weapon] = {}
	Spring.SetUnitRulesParam(unitID, "scriptLoaded", self.totalLoaded, ALLY_ACCESS)
	Spring.SetUnitRulesParam(unitID, "scriptLoaded_"..weapon, self.loaded[weapon], ALLY_ACCESS)
	Spring.SetUnitRulesParam(unitID, "scriptReloadFrame", nil, ALLY_ACCESS)
	Spring.SetUnitRulesParam(unitID, "scriptReloadPercentage", nil, ALLY_ACCESS)

end

-- internal management
function Magazine:ReloadThread(weapon, shot)
	self.active[weapon] = (shot+1)%(self.config[weapon].size)
	self:GunStartReload(weapon, shot)

	if self.config[weapon].mode == 1 then
		if self.reloading then return end
		self.reloading = true
		self:SeqReload(weapon, shot, self.config[weapon].reload)
		self.active[weapon] = 0
		self.reloading = false
	elseif self.config[weapon].mode == 2 then
		if self.reloading then
			self.reloadTimer = 0
			return
		end
		self.reloading = true
		self:MagReload(weapon, self.config[weapon].reload)
		self.active[weapon] = 0
		self.reloading = false
	elseif self.config[weapon].mode == 0 then
		self:SleepAndUpdateReload(weapon, shot, self.config[weapon].reload)
		if self:GunLoaded(weapon, shot) then
			self.active[weapon] = 0
		end
	end
end

function Magazine:Reload(weapon, shot)
	shot = shot or self.active[weapon]
	Spring.Echo("Reload "..weapon.." - "..(shot or "nil"))
	Spring.Utilities.TableEcho(self.reloadStartFrame)
	StartThread(self.ReloadThread, self, weapon, shot)
end

function Magazine:CanFire(weapon, shot)
	--Spring.Echo("CanFire "..weapon.." - "..(shot or "nil"))
	--Spring.Echo("active: "..(active[weapon] or "nil"))
	--Spring.Echo(type(weapon))
	--Spring.Echo(active[1])
	--Spring.Echo(active["1"])
	--Spring.Utilities.TableEcho(active)
	shot = shot or self.active[weapon]
	return not self.reloadStartFrame[weapon][shot]
end

--function externalFunctions.CanFireAny(weapon)
--	return not reloadStartFrame[weapon][active[weapon]]
--end

return Magazine