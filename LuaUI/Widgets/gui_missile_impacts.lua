function widget:GetInfo()
	return {
		name = "Missile Impact Points New",
		desc = "Mark missile impact areas and ETAs from allies.",
		author = "esainane, localization by Shaman",
		date = "2020-07",
		license = "GPL v2.0+",
		layer = 0,
		enabled = true,
	}
end

local END_FADE_TIME = 12
local START_FADE_TIME = 8

options_order = {"alpha", "thickness"}
options = {
	alpha = {
		name = "Line opacity",
		type = "number",
		value = 0.6,
		min = 0,
		max = 1,
		step = 0.01,
	},
	thickness = {
		name = "Line thickness",
		type = "number",
		value = 3,
		min = 1,
		max = 10,
		step = 0.1,
	},
}
local trackedMissiles = include("LuaRules/Configs/tracked_missiles.lua")
for id, data in pairs(trackedMissiles) do
	data.radius = data.radiusOverride or math.floor(WeaponDefs[id].damageAreaOfEffect * (data.radiusMult or 1))
	local name = data.humanName
	local key = name .. " Color"
	local function OnChange(self)
		data.color = self.value
	end
	options_order[#options_order + 1] = key
	options[key] = {
		name = "Allied " .. name .. " target color",
		type = "colors",
		value = data.color,
		OnChange = OnChange
	}
end

options_path = 'Settings/Interface/Missile Warnings'

local isOn                 = true
local spGetCameraState     = Spring.GetCameraState
local spGetGroundHeight    = Spring.GetGroundHeight

local glLineWidth          = gl.LineWidth
local glColor              = gl.Color
local glDrawGroundCircle   = gl.DrawGroundCircle
local glPopMatrix          = gl.PopMatrix
local glPushMatrix         = gl.PushMatrix
local glTranslate          = gl.Translate
local glText               = gl.Text
local textParam            = "cs"
local df = 0
local spIsSphereInView = Spring.IsSphereInView
local spWorldToScreenCoords = Spring.WorldToScreenCoords

local max = math.max
local min = math.min

local localization = {
	["impact_time"] = "Time until Impact:",
	["tacnuke_label"] = "Tactical Nuke",
	["inbound_label"] = "Inbound",
	["napalm_label"] = "Napalm Dispersement",
	["kinetic_label"] = "Kinetic Strike",
	["emp_label"] = "EMP Burst",
	["nuke_label"] = "Nuclear Cruise Missile",
	["danger_label"] = "DANGER:",
	["scout_label"] = "Recon Missile",
	["quake_label"] = "Flattener Missile",
	["singularity_label"] = "Singularity Missile",
	["seconds"] = "seconds",
}

local weaponDefIDToLocalization = {
	[WeaponDefNames.missilenuke_nuke.id] = "nuke_label",
	[WeaponDefNames.tacnuke_weapon.id] = "tacnuke_label",
	[WeaponDefNames.empmissile_emp_weapon.id] = "emp_label",
	[WeaponDefNames.napalmmissile_weapon.id] = "napalm_label",
	[WeaponDefNames.seismic_seismic_weapon.id] = "quake_label",
	[WeaponDefNames.singularity_singularity_weapon.id] = "singularity_label",
	[WeaponDefNames.missileslow_weapon.id] = "scout_label",
	[WeaponDefNames.missilekinetic_weapon.id] = "kinetic_label",
}
	
	

-- id -> {x,y,z,impactFrame,weaponDefID}
local IterableMap = Spring.Utilities.IterableMap
local points = IterableMap.New()
local outerAlpha = options.alpha.value
local curFrame = Spring.GetGameFrame()
--        scriptMissileFired(proID, proOwnerID, weaponDefID, rx,       ry,        rz,        rt,     targetID, triggerFrame)

local function LocaleUpdated()
	for k, _ in pairs(localization) do
		localization[k] = WG.Translate ("interface", k)
	end
end

function widget:MissileFired(proID, proOwnerID, weaponDefID, impactX, impactY, impactZ, impactFrame, targetID, triggerFrame)
	if not isOn then
		widgetHandler:UpdateCallIn("DrawWorldPreUnit")
		isOn = true
	end
	local currentFrame = triggerFrame or Spring.GetGameFrame()
	local weaponDefConfig = trackedMissiles[weaponDefID]
	local impactFrameNew = math.max(currentFrame + 5, impactFrame)
	local impactProportion = (currentFrame - impactFrame) / (currentFrame - impactFrame)
	local radius = weaponDefConfig.radius
	local localizationKey = weaponDefIDToLocalization[weaponDefID]
	local textLocation = localizationKey and (impactZ + radius + 5)
	local data = {
		ix = impactX,
		iy = impactY,
		iz = impactZ,
		impactFrame = impactFrameNew,
		fireFrame = currentFrame,
		dieFrame = impactFrameNew + END_FADE_TIME,
		weaponDefID = weaponDefID,
		targetID = targetID,
		radius = radius,
		impactProportion = impactProportion,
		fadeIn = weaponDefConfig.fadeIn,
		insideRadius = math.max(2, radius * impactProportion),
		resolution = 8 + radius * impactProportion,
		outsideRadiusFallback = math.ceil(8 + weaponDefConfig.radius * 0.4),
		impactTime = string.format("%.1f", (impactFrameNew - currentFrame)/30),
		localizationKey = localizationKey,
		textLocation = textLocation
	}
	data.r, data.g, data.b = weaponDefConfig.color[1], weaponDefConfig.color[2], weaponDefConfig.color[3]
	IterableMap.Add(points, proID, data)
end

function widget:MissileDestroyed(proID)
	local proData = IterableMap.Get(points, proID)
	if proData then
		proData.dieFrame = math.min(Spring.GetGameFrame() + END_FADE_TIME, proData.dieFrame)
		proData.isDead = true
	end
end

local function GetCameraHeight()
	local cs = spGetCameraState()
	local gy = spGetGroundHeight(cs.px, cs.pz)
	local testHeight = cs.py - gy
	if cs.name == "ta" then
		testHeight = cs.height - gy
	end
	return testHeight
end

local function GetTextSize()
	local height = GetCameraHeight()
	if height < 1000 then
		return 20
	else
		return 20 + (height / 250)
	end
end

local function GetThicknessFactor()
	local height = GetCameraHeight()
	if height < 1000 then
		return 1
	end
	return 1000 / (1000 + height) + 0.5
end

--[[local function DrawPoint(proID, data, index)
	local r,g,b = data.r, data.g, data.b
	local radius = data.radius
	local fadeIn = data.fadeIn
	local impactProportion = data.impactProportion
	
	local innerAlpha = data.innerAlpha
	local outerAlpha = data.outerAlpha
	
	glLineWidth(options.thickness.value * GetThicknessFactor()) -- cannot optimize this math out, unfortunately.
	glColor(r, g, b, innerAlpha)
	glDrawGroundCircle(data.ix, data.iy, data.iz, data.insideRadius, data.resolution)
	glColor(r, g, b, outerAlpha)
	glDrawGroundCircle(data.ix, data.iy, data.iz, radius, (data.targetID and radius) or data.outsideRadiusFallback)
	glColor(1,1,1,1)
end]]

function widget:DrawWorldPreUnit()
	if Spring.IsGUIHidden() then
		return
	end
	glLineWidth(options.thickness.value * GetThicknessFactor()) -- cannot optimize this math out, unfortunately.
	local textSize = GetTextSize()
	for k, data in IterableMap.Iterator(points) do
		local x, y, z = data.ix, data.iy, data.iz
		local radius = data.radius
		if spIsSphereInView(x, y, z, radius) then
			local target = data.targetID
			local innerAlpha = data.innerAlpha
			local outerAlpha = data.outerAlpha
			local r,g,b = data.r, data.g, data.b
			local localizationKey = data.localizationKey
			local insideRadius = data.insideRadius
			glColor(r, g, b, innerAlpha)
			glDrawGroundCircle(x, y, z, data.insideRadius, data.resolution)
			glColor(r, g, b, outerAlpha)
			glDrawGroundCircle(x, y, z, radius, (target and radius) or data.outsideRadiusFallback)
			--[[if localizationKey then
				local tx, ty, tz = spWorldToScreenCoords(x, y - insideRadius, z)
				glColor(1,1,1,1)
				glText(localization[localizationKey] .. " " .. localization["inbound_label"], tx, tz + insideRadius, textSize, textParam)
				glText(localization["impact_time"] .. " " .. data.impactTime .. localization["seconds"], x, z + insideRadius - 6 - textSize, textSize, textParam)
			end]] -- WIP, fix me later.
		end
	end
	--IterableMap.Apply(points, DrawPoint, curFrame)
end

function widget:GameFrame(f) -- do all the heavy math here so DrawWorld can live in peace.
	local empty = IterableMap.IsEmpty(points)
	if not empty then
		curFrame = f
		outerAlpha = options.alpha.value -- FIXME: Change this to be only changed when updated.
		for k, data in IterableMap.Iterator(points) do
			if (data.isDead and f > data.dieFrame) or f > data.impactFrame then
				IterableMap.Remove(points, k) -- cleanup
			else
				local radius = data.radius
				local impactFrame = data.impactFrame
				local fireFrame = data.fireFrame
				local impactProportion = (f - impactFrame) / (fireFrame - impactFrame)
				local outter = outerAlpha
				local fadeIn = data.fadeIn
				local innerAlpha = max(0.1, min(1, (fadeIn - impactProportion)/fadeIn)) * outerAlpha
				if curFrame < data.fireFrame + START_FADE_TIME then
					local prop = math.sqrt((curFrame - data.fireFrame) / START_FADE_TIME)
					innerAlpha = innerAlpha * prop
					outter = outter * prop
				end
				if f + END_FADE_TIME > data.dieFrame then
					outerAlpha = outerAlpha * math.sqrt((data.dieFrame - curFrame) / END_FADE_TIME)
				end
				data.innerAlpha = innerAlpha
				data.outerAlpha = outter
				data.insideRadius = math.max(2, radius * impactProportion)
				data.resolution = 8 + radius * impactProportion
				data.outsideRadiusFallback = math.ceil(8 + radius * 0.4)
				data.impactTime = string.format("%.1f", (impactFrame - f)/30)
				data.textLocation = data.insideRadius + data.iz + 5
				if data.targetID and not data.isDead then
					local x, y, z = Spring.GetUnitPosition(data.targetID)
					if x and y and z then
						data.ix, data.iy, data.iz = x, y, z
					end
				end
			end
		end
	elseif isOn and empty then
		isOn = false
		widgetHandler:RemoveCallIn("DrawWorldPreUnit")
	end
end

function widget:Initialize()
	if Spring.GetGameFrame() > 0 then
		Spring.SendLuaRulesMsg("MissileImpacts reload")
	end
	WG.InitializeTranslation(OnLocaleChanged, GetInfo().name)
end
