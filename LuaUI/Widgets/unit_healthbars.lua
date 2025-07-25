-- $Id: unit_healthbars.lua 4481 2009-04-25 18:38:05Z carrepairer $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  author:  jK
--
--  Copyright (C) 2007, 2008, 2009.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "HealthBars",
		desc      = "Gives various informations about units in form of bars.",
		author    = "jK",
		date      = "2009", --2013 May 12
		license   = "GNU GPL, v2 or later",
		layer     = -10,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local carrierDefs, _, _ = include "LuaRules/Configs/drone_defs.lua"

local barHeight = 3
local barWidth  = 14  --// (barWidth)x2 total width!!!
local barAlpha  = 0.9

local featureBarHeight = 3
local featureBarWidth  = 10
local featureBarAlpha  = 0.6

local drawBarTitles = true
local drawBarPercentages = true
local titlesAlpha   = 0.3*barAlpha

local drawFullHealthBars = false

local drawFeatureHealth  = false
local featureTitlesAlpha = featureBarAlpha * titlesAlpha/barAlpha
local featureHpThreshold = 0.85

local barScale = 1

local drawStunnedOverlay = true
local drawUnitsOnFire    = Spring.GetGameRulesParam("unitsOnFire")

local gameSpeed = Game.gameSpeed

local TELEPORT_CHARGE_NEEDED = Spring.GetGameRulesParam("pw_teleport_time") or gameSpeed*60

--// this table is used to shows the hp of perimeter defence, and filter it for default wreckages
local walls = {dragonsteeth = true, dragonsteeth_core = true, fortification = true, fortification_core = true, floatingteeth = true, floatingteeth_core = true, spike = true}

local stockpileH = 24
local stockpileW = 12

local captureReloadTime = tonumber(UnitDefNames["vehcapture"].customParams.post_capture_reload) -- Hackity hax --Probably will remove once mana recharges :P
local DISARM_DECAY_FRAMES = 1200

local destructableFeature = {}
local drawnFeature = {}
for i = 1, #FeatureDefs do
	destructableFeature[i] = FeatureDefs[i].destructable
	drawnFeature[i] = (FeatureDefs[i].drawTypeString == "model")
end

--------------------------------------------------------------------------------
-- LOCALISATION
--------------------------------------------------------------------------------

local messages = {
	shield_bar = "shield",
	health_bar = "health",
	building_bar = "building",
	morph_bar = "morph",
	stockpile_bar = "stockpile",
	paralyze_bar = "paralyze",
	disarm_bar = "disarm",
	capture_bar = "capture",
	water_tank = "water tank",
	teleport_bar = "teleport",
	ability_bar = "ability",
	reload_bar = "reload",
	reammo_bar = "reammo",
	slow_bar = "slow",
	goo_bar = "goo",
	jump_bar = "jump",
	reclaim_bar = "reclaim",
	resurrect_bar = "resurrect",
	-- future wars --
	aim = "aim",
	battery = "battery",
	engioverdrive = "Fab Overdrive",
	temporaryarmor = "Temp Armor",
	drones = "Drones",
	sensorsteal = "Sensors hacked",
	sensortag = "Unit Tracked",
	acronyms_second = "sec",
}

local function languageChanged ()
	for key, value in pairs(messages) do
		messages[key] = WG.Translate("interface", key)
	end
end

--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------
local function ReCacheReloadTimes()
	for _, ud in pairs(UnitDefs) do
		ud.reloadTime    = {};
		ud.primaryWeapon = {};
		ud.reloadOverride = {};
		ud.shieldPower   = 0;

		for i = 1, #ud.weapons do
			local WeaponDefID = ud.weapons[i].weaponDef;
			local WeaponDef   = WeaponDefs[ WeaponDefID ];
			local reload = tonumber(WeaponDef.customParams.post_capture_reload) or WeaponDef.reload
			if (((WeaponDef.customParams and tonumber(WeaponDef.customParams.reload_override)) or reload) > (options.minReloadTime.value or 0)) then
				ud.reloadTime[#ud.reloadTime+1]    = WeaponDef.reload;
				ud.primaryWeapon[#ud.primaryWeapon+1] = i;
				ud.reloadOverride[#ud.reloadOverride+1] = tonumber(WeaponDef.customParams.reload_override)
			end
		end
		local shieldDefID = ud.shieldWeaponDef
		ud.shieldPower = ((shieldDefID)and(WeaponDefs[shieldDefID].shieldPower))or(-1)
	end
end

local function OptionsChanged()
	drawFeatureHealth = options.drawFeatureHealth.value
	drawBarPercentages = options.drawBarPercentages.value
	barScale = options.barScale.value
	debugMode = options.debugMode.value
	
	healthbarDistSq    = options.unitMaxHeight.value*options.unitMaxHeight.value
	healthbarPercentSq = options.unitPercentHeight.value*options.unitPercentHeight.value
	healthbarTitleSq   = options.unitTitleHeight.value*options.unitTitleHeight.value
	
	featureDistSq      = options.featureMaxHeight.value*options.featureMaxHeight.value
	featurePercentSq   = options.featurePercentHeight.value*options.featurePercentHeight.value
	featureTitleSq     = options.featureTitleHeight.value*options.featureTitleHeight.value
	
	ReCacheReloadTimes()
end

options_path = 'Settings/Interface/Healthbars'
options_order = { 'showhealthbars', 'drawFeatureHealth', 'drawBarPercentages',
	'barScale', 'debugMode', 'minReloadTime',
	'unitMaxHeight', 'unitPercentHeight', 'unitTitleHeight',
	'featureMaxHeight', 'featurePercentHeight', 'featureTitleHeight',
}
options = {
	showhealthbars = {
		name = 'Show Healthbars',
		type = 'bool',
		value = true,
		--OnChange = function() Spring.SendCommands{'showhealthbars'} end,
	},
	drawFeatureHealth = {
		name = 'Draw health of features (corpses)',
		type = 'bool',
		value = false,
		noHotkey = true,
		desc = 'Shows healthbars on corpses',
		OnChange = OptionsChanged,
	},
	drawBarPercentages = {
		name = 'Draw percentages',
		type = 'bool',
		value = true,
		noHotkey = true,
		desc = 'Shows percentages next to bars',
		OnChange = OptionsChanged,
	},
	barScale = {
		name = 'Bar size scale',
		type = 'number',
		value = 1.5,
		min = 0.5,
		max = 6,
		step = 0.25,
		OnChange = OptionsChanged,
	},
	minReloadTime = {
		name = 'Min reload time',
		type = 'number',
		value = 3,
		min = 0.5,
		max = 10,
		step = 0.5,
		desc = 'Min reload time (sec), Requires restart/reload to take effect.',
		OnChange = OptionsChanged,
	},
	debugMode = {
		name = 'Debug Mode',
		type = 'bool',
		value = false,
		advanced = true,
		noHotkey = true,
		desc = 'Pings units with debug information',
		OnChange = OptionsChanged,
	},
	unitMaxHeight = {
		name = 'Unit Bar Fade Height',
		desc = 'If the camera is above this height, health bars will not be drawn.',
		type = 'number',
		min = 0, max = 8000, step = 50,
		value = 3000,
		OnChange = OptionsChanged,
	},
	unitPercentHeight = {
		name = 'Unit Bar Percentage Height',
		desc = 'If the camera is above this height, health bar percentages will not be drawn.',
		type = 'number',
		min = 0, max = 7000, step = 50,
		value = 1500,
		OnChange = OptionsChanged,
	},
	unitTitleHeight = {
		name = 'Unit Bar Title Heightt',
		desc = 'If the camera is above this height, health bar titles will not be drawn.',
		type = 'number',
		min = 0, max = 7000, step = 50,
		value = 1500,
		OnChange = OptionsChanged,
	},
	featureMaxHeight = {
		name = 'Wreckage Bar Fade Height',
		desc = 'If the camera is above this height, health bars will not be drawn.',
		type = 'number',
		min = 0, max = 7000, step = 50,
		value = 2200,
		OnChange = OptionsChanged,
	},
	featurePercentHeight = {
		name = 'Wreckage Bar Percentage Height',
		desc = 'If the camera is above this height, health bar percentages will not be drawn.',
		type = 'number',
		min = 0, max = 7000, step = 50,
		value = 500,
		OnChange = OptionsChanged,
	},
	featureTitleHeight = {
		name = 'Wreckage Bar Title Heightt',
		desc = 'If the camera is above this height, health bar titles will not be drawn.',
		type = 'number',
		min = 0, max = 7000, step = 50,
		value = 500,
		OnChange = OptionsChanged,
	},
}
OptionsChanged()

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local GL_TEXTURE_GEN_MODE    = GL.TEXTURE_GEN_MODE
local GL_EYE_PLANE           = GL.EYE_PLANE
local GL_EYE_LINEAR          = GL.EYE_LINEAR
local GL_T                   = GL.T
local GL_S                   = GL.S
local GL_ONE                 = GL.ONE
local GL_SRC_ALPHA           = GL.SRC_ALPHA
local GL_ONE_MINUS_SRC_ALPHA = GL.ONE_MINUS_SRC_ALPHA
local glUnit                 = gl.Unit
local glTexGen               = gl.TexGen
local glTexCoord             = gl.TexCoord
local glPolygonOffset        = gl.PolygonOffset
local glBlending             = gl.Blending
local glDepthTest            = gl.DepthTest
local glTexture              = gl.Texture
local GetCameraVectors       = Spring.GetCameraVectors
local abs                    = math.abs
local GL_QUADS               = GL.QUADS
local glVertex               = gl.Vertex
local glBeginEnd             = gl.BeginEnd
local glMultiTexCoord        = gl.MultiTexCoord
local glTexRect              = gl.TexRect
local glCallList             = gl.CallList
local glText                 = gl.Text
local glTranslate            = gl.Translate
local glPushMatrix           = gl.PushMatrix
local glPopMatrix            = gl.PopMatrix
local glBillboard            = gl.Billboard
local glColor                = gl.Color
local GetUnitIsStunned       = Spring.GetUnitIsStunned
local GetUnitHealth          = Spring.GetUnitHealth
local GetUnitWeaponState     = Spring.GetUnitWeaponState
local GetUnitShieldState     = Spring.GetUnitShieldState
local GetUnitViewPosition    = Spring.GetUnitViewPosition
local GetUnitStockpile       = Spring.GetUnitStockpile
local GetUnitRulesParam      = Spring.GetUnitRulesParam
local GetFeatureHealth       = Spring.GetFeatureHealth
local GetFeatureResources    = Spring.GetFeatureResources
local myAllyTeam = Spring.GetMyAllyTeamID()


local function lowerkeys(t)
	local tn = {}
	for i, v in pairs(t) do
		local typ = type(i)
		if type(v) == "table" then
			v = lowerkeys(v)
		end
		if typ == "string" then
			tn[i:lower()] = v
		else
			tn[i] = v
		end
	end
	return tn
end

local paralyzeOnMaxHealth = ((lowerkeys(VFS.Include"gamedata/modrules.lua") or {}).paralyze or {}).paralyzeonmaxhealth

local spGetGroundHeight = Spring.GetGroundHeight
local function IsCameraBelowMaxHeight()
	local cs = Spring.GetCameraState()
	if cs.name == "ta" then
		return cs.height < options.unitMaxHeight.value
	elseif cs.name == "ov" then
		return false
	else
		return (cs.py - spGetGroundHeight(cs.px, cs.pz)) < options.unitMaxHeight.value
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--// colors
local bkBottom   = { 0.40, 0.40, 0.40, barAlpha }
local bkTop      = { 0.10, 0.10, 0.10, barAlpha }
local hpcolormap = { {0.8, 0.0, 0.0, barAlpha},  {0.8, 0.6, 0.0, barAlpha}, {0.0, 0.70, 0.0, barAlpha} }
local bfcolormap = {}

local fbkBottom   = { 0.40, 0.40, 0.40, featureBarAlpha }
local fbkTop      = { 0.06, 0.06, 0.06, featureBarAlpha }
local fhpcolormap = { {0.8, 0.0, 0.0, featureBarAlpha},  {0.8, 0.6, 0.0, featureBarAlpha}, {0.0, 0.70, 0.0, featureBarAlpha} }

local barColors = {
	-- Units
	emp            = { 0.50, 0.50, 1.00, barAlpha },
	emp_p          = { 0.40, 0.40, 0.80, barAlpha },
	emp_b          = { 0.60, 0.60, 0.90, barAlpha },
	disarm         = { 0.50, 0.50, 0.50, barAlpha },
	disarm_p       = { 0.40, 0.40, 0.40, barAlpha },
	disarm_b       = { 0.60, 0.60, 0.60, barAlpha },
	capture        = { 1.00, 0.50, 0.00, barAlpha },
	capture_reload = { 0.00, 0.60, 0.60, barAlpha },
	build          = { 0.75, 0.75, 0.75, barAlpha },
	stock          = { 0.50, 0.50, 0.50, barAlpha },
	reload         = { 0.00, 0.60, 0.60, barAlpha },
	reload2        = { 0.80, 0.60, 0.00, barAlpha },
	reammo         = { 0.00, 0.60, 0.60, barAlpha },
	jump           = { 0.00, 0.90, 0.00, barAlpha },
	sheath         = { 0.00, 0.20, 1.00, barAlpha },
	fuel           = { 0.70, 0.30, 0.00, barAlpha },
	slow           = { 0.50, 0.10, 0.70, barAlpha },
	goo            = { 0.40, 0.40, 0.40, barAlpha },
	shield         = { 0.30, 0.0, 0.90, barAlpha },
	tank           = { 0.10, 0.20, 0.90, barAlpha },
	tele           = { 0.00, 0.60, 0.60, barAlpha },
	tele_pw        = { 0.00, 0.60, 0.60, barAlpha },
	aim            = { 0.30, 0.50, 0.40, barAlpha },
	battery        = { 0.76, 0.75, 0.31, barAlpha },
	drones         = { 0.00, 0.80, 1.00, barAlpha },
	sensorhacked   = { 0.00, 0.60, 0.00, barAlpha },
	sensortag      = { 0.30, 0.25, 0.40, barAlpha },
	temporaryarmor = { 0.678, 0.847, 0.902, barAlpha },
	sensorsteal    = {0.30, 0.25, 0.40, barAlpha}, -- TODO: change later on.
	

	-- Features
	resurrect = { 1.00, 0.50, 0.00, featureBarAlpha },
	reclaim   = { 0.75, 0.75, 0.75, featureBarAlpha },
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local blink = false
local gameFrame = 0

local empDecline = 1/40

local cx, cy, cz = 0, 0, 0 --// camera pos

local paraUnits   = {}
local disarmUnits = {}
local onFireUnits = {}
local UnitMorphs  = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--// speedup (there are a lot more localizations, but they are in limited scope cos we are running out of upvalues)
local glColor         = gl.Color
local glMyText        = gl.FogCoord
local floor           = math.floor

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local deactivated = false
local function showhealthbars(cmd, line, words)
	if ((words[1])and(words[1] ~= "0"))or(deactivated) then
		widgetHandler:UpdateCallIn('DrawWorld')
		deactivated = false
	else
		widgetHandler:RemoveCallIn('DrawWorld')
		deactivated = true
	end
end
options.showhealthbars.OnChange = function(self) showhealthbars(_, _, {self.value and '1' or '0'}) end

function GetColor(colormap, slider)
	local coln = #colormap
	if (slider >= 1) then
		local col = colormap[coln]
		return col[1], col[2], col[3], col[4]
	end
	if (slider < 0) then slider = 0 elseif(slider > 1) then
		slider = 1
	end
	local posn  = 1+(coln-1) * slider
	local iposn = floor(posn)
	local aa    = posn - iposn
	local ia    = 1-aa

	local col1, col2 = colormap[iposn], colormap[iposn+1]

	return col1[1]*ia + col2[1]*aa, col1[2]*ia + col2[2]*aa,
	       col1[3]*ia + col2[3]*aa, col1[4]*ia + col2[4]*aa
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function GetBarDrawer()
	--//speedup

	local barsN = 0
	local maxBars = 20
	local bars    = {}
	local barHeightL = barHeight + 2
	local barStart   = -(barWidth + 1)
	local fBarHeightL = featureBarHeight + 2
	local fBarStart   = -(featureBarWidth + 1)

	for i = 1, maxBars do
		bars[i] = {}
	end

	--//speedup


	local function DrawGradient(left, top, right, bottom, topclr, bottomclr)
		glColor(bottomclr)
		glVertex(left, bottom)
		glVertex(right, bottom)
		glColor(topclr)
		glVertex(right, top)
		glVertex(left, top)
	end

	local brightClr = {}
	local function DrawUnitBar(offsetY, percent, color)
		brightClr[1] = color[1]*1.5; brightClr[2] = color[2]*1.5; brightClr[3] = color[3]*1.5; brightClr[4] = color[4]
		local progress_pos = -barWidth + barWidth*2*percent
		local bar_Height  = barHeight+offsetY
		if percent < 1 then
			glBeginEnd(GL_QUADS, DrawGradient, progress_pos, bar_Height, barWidth, offsetY, bkTop, bkBottom)
		end
		glBeginEnd(GL_QUADS, DrawGradient, -barWidth, bar_Height, progress_pos, offsetY, brightClr, color)
	end

	local function DrawFeatureBar(offsetY, percent, color)
		brightClr[1] = color[1]*1.5; brightClr[2] = color[2]*1.5; brightClr[3] = color[3]*1.5; brightClr[4] = color[4]
		local progress_pos = -featureBarWidth+featureBarWidth*2*percent
		glBeginEnd(GL_QUADS, DrawGradient, progress_pos, featureBarHeight+offsetY, featureBarWidth, offsetY, fbkTop, fbkBottom)
		glBeginEnd(GL_QUADS, DrawGradient, -featureBarWidth, featureBarHeight+offsetY, progress_pos, offsetY, brightClr, color)
	end

	local externalFunc = {}

	function externalFunc.DrawStockpile(numStockpiled, numStockpileQued, freeStockpile)
		--// DRAW STOCKPILED MISSLES
		glColor(1, 1, 1, 1)
		glTexture("LuaUI/Images/nuke.png")
		local xoffset = barWidth+16
		for i = 1, ((numStockpiled > 3) and 3) or numStockpiled do
			glTexRect(xoffset, -(11*barHeight-2)-stockpileH, xoffset-stockpileW, -(11*barHeight-2))
			xoffset = xoffset-8
		end
		glTexture(false)
		if freeStockpile then
			glText(numStockpiled, barWidth + 1.7, -(11*barHeight - 2) - 16, 7.5, "cno")
		else
			glText(numStockpiled .. '/' .. numStockpileQued, barWidth + 1.7, -(11*barHeight-2)-16, 7.5, "cno")
		end
	end

	function externalFunc.AddBar(title, progress, color_index, text, color)
		barsN = barsN + 1
		local barInfo    = bars[barsN]
		if barInfo then
			barInfo.title    = title
			barInfo.progress = progress
			barInfo.color    = color or barColors[color_index]
			barInfo.text     = text
		end
	end

	function externalFunc.HasBars()
		return (barsN ~= 0)
	end

	function externalFunc.DrawBars()
		local yoffset = 0
		for i = 1, barsN do
			local barInfo = bars[i]
			DrawUnitBar(yoffset, barInfo.progress, barInfo.color)
			if (drawBarPercentages and barInfo.text) then
				glColor(1, 1, 1, barAlpha)
				glText(barInfo.text, barStart, yoffset, 4, "ro")
			end
			if (drawBarTitles and barInfo.title) then
				glColor(1, 1, 1, titlesAlpha)
				glText(barInfo.title, 0, yoffset, 2.5, "cdo")
			end
			yoffset = yoffset - barHeightL
		end

		barsN = 0 --//reset!
	end

	function externalFunc.DrawBarsFeature()
		local yoffset = 0
		for i = 1, barsN do
			local barInfo = bars[i]
			DrawFeatureBar(yoffset, barInfo.progress, barInfo.color)
			if (drawBarPercentages and barInfo.text) then
				glColor(1, 1, 1, featureBarAlpha)
				glText(barInfo.text, fBarStart, yoffset, 4, "ro")
			end
			if (drawBarTitles and barInfo.title) then
				glColor(1, 1, 1, featureTitlesAlpha)
				glText(barInfo.title, 0, yoffset, 2.5, "cdo")
			end
			yoffset = yoffset - fBarHeightL
		end

		barsN = 0 --//reset!
	end
	
	return externalFunc
end --//end GetBarDrawer

local barDrawer = GetBarDrawer()

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local customInfoUnits = {}

function JustGetOverlayInfos(unitID, unitDefID)
	local ux, uy, uz = GetUnitViewPosition(unitID)
	if not ux then
		return
	end
	local dx, dy, dz = ux-cx, uy-cy, uz-cz
	local dist = dx*dx + dy*dy + dz*dz

	if (dist > 9000000) then
		return
	end
	--// GET UNIT INFORMATION
	local health, maxHealth, paralyzeDamage = GetUnitHealth(unitID)
	paralyzeDamage = GetUnitRulesParam(unitID, "real_para") or paralyzeDamage

	local empHP = ((not paralyzeOnMaxHealth) and health) or maxHealth
	local emp = (paralyzeDamage or 0)/empHP
	--local hp  = (health or 0)/maxHealth
	local morph = UnitMorphs[unitID]

	if (drawUnitsOnFire)and(GetUnitRulesParam(unitID, "on_fire") == 1) then
		onFireUnits[#onFireUnits+1] = unitID
	end

	--// PARALYZE
	local stunned, _, inbuild = GetUnitIsStunned(unitID)
	if (emp > 0) and ((not morph) or morph.combatMorph) and (emp < 1e8) and (paralyzeDamage >= empHP) then
		if (stunned) then
			paraUnits[#paraUnits+1] = unitID
		end
	end

	--// DISARM
	if not stunned then
		local disarmed = GetUnitRulesParam(unitID, "disarmed")
		if disarmed and disarmed == 1 then
			disarmUnits[#disarmUnits+1] = unitID
		end
	end
end

local function CacheUnitInfo(unitDefID)
	local ud = UnitDefs[unitDefID]
	customInfoUnits[unitDefID] = {
		height        = Spring.Utilities.GetUnitHeight(ud) + 14,
		canJump       = (ud.customParams.canjump and true) or false,
		canGoo        = (ud.customParams.grey_goo and true) or false,
		canReammo     = (ud.customParams.requireammo and true) or false,
		isPwStructure = (ud.customParams.planetwars_structure and true) or false,
		usesSuperWeaponReload = (ud.customParams.superweapon and true) or false,
		needsFireControl = (ud.customParams.needsfirecontrol and true) or false,
		canCapture    = (ud.customParams.post_capture_reload and true) or false,
		usesAmmoState = (ud.customParams.ammocount and true) or false,
		maxShield     = ud.shieldPower - 10,
		canStockpile  = ud.canStockpile,
		gadgetStock   = ud.customParams.stockpiletime,
		primaryWeapon = ud.primaryWeapon,
		reloadOverride    = ud.reloadOverride,
		dyanmicComm   = ud.customParams.dynamic_comm,
		maxWaterTank  = ud.customParams.maxwatertank,
		freeStockpile = (ud.customParams.freestockpile and true) or nil,
		specialReload = ud.customParams.specialreloadtime,
		delaytime     = ud.customParams.aimdelay,
		batterymax    = tonumber(ud.customParams.battery),
		bpoverdrivebonus = tonumber(ud.customParams.bp_overdrive_bonus),
		dynamicComm   = ud.customParams.dynamic_comm ~= nil or ud.customParams.level ~= nil,
		hasDrones     = ud.customParams.dynamic_comm ~= nil or ud.customParams.level ~= nil or carrierDefs[unitDefID],
	}
	
	for i = 1, #ud.weapons do
		local wd = WeaponDefs[ud.weapons[i].weaponDef]
		if wd.customParams.targeter == nil and wd.customParams.bogus == nil then
			if wd.customParams.script_reload and not ud.customParams.superweapon then
				if customInfoUnits[unitDefID].scriptReload then
					customInfoUnits[unitDefID].scriptReload[#customInfoUnits[unitDefID].scriptReload + 1] = i
					customInfoUnits[unitDefID].scriptReloadTimes[i] = tonumber(wd.customParams.script_reload)
					customInfoUnits[unitDefID].scriptReloadBursts[i] = tonumber(wd.customParams.script_burst)
				else
					customInfoUnits[unitDefID].scriptReload = {[1] = i}
					customInfoUnits[unitDefID].scriptReloadTimes = {[i] = tonumber(wd.customParams.script_reload)}
					customInfoUnits[unitDefID].scriptReloadBursts = {[i] = tonumber(wd.customParams.script_burst)}
				end
			elseif not ud.customParams.superweapon then
				if customInfoUnits[unitDefID].reloadWatched then
					customInfoUnits[unitDefID].reloadWatched[#customInfoUnits[unitDefID].reloadWatched + 1] = i
				else
					customInfoUnits[unitDefID].reloadWatched = {}
					customInfoUnits[unitDefID].reloadWatched[1] = i
				end
			end
		end
	end
	if ud.name == "turretheavyaa" then
		usesSuperWeaponReload = false
	elseif ud.name == "raveparty" then
		customInfoUnits[unitDefID].weaponOverride = 7
	elseif ud.name == "turretaaheavy" then
		customInfoUnits[unitDefID].weaponOverride = 1
	elseif ud.name == "zenith" then
		customInfoUnits[unitDefID].weaponOverride = 2
	elseif ud.name == "staticnuke" then
		customInfoUnits[unitDefID].weaponOverride = 1
	elseif ud.name == "supernova_satellite" then
		customInfoUnits[unitDefID].usesSuperWeaponReload = false
		customInfoUnits[unitDefID].needsFireControl = false
	elseif ud.name == "supernova_base" then
		customInfoUnits[unitDefID].usesSuperWeaponReload = false
		customInfoUnits[unitDefID].needsFireControl = false
	elseif ud.name == "staticheavyshield" then
		customInfoUnits[unitDefID].needsFireControl = false
		customInfoUnits[unitDefID].usesSuperWeaponReload = false
	elseif ud.name == "staticarty" then
		customInfoUnits[unitDefID].usesSuperWeaponReload = false
		local wd = WeaponDefs[ud.weapons[1].weaponDef]
		customInfoUnits[unitDefID].scriptReload = {[1] = 1}
		customInfoUnits[unitDefID].scriptReloadTimes = {[1] = tonumber(wd.customParams.script_reload)}
		customInfoUnits[unitDefID].scriptReloadBursts = {[1] = tonumber(wd.customParams.script_burst)}
	end
end

local function ProcessWeapon(unitID, weaponID, ci, addPercent)
	local _, reloaded, reloadFrame = GetUnitWeaponState(unitID, weaponID)
	local captureReloadState = ci.canCapture and GetUnitRulesParam(unitID, "captureRechargeFrame") or 0
	if not reloaded and reloadFrame ~= nil and captureReloadState == 0 then
		local reloadTime, reloadOverride
		if ci.reloadOverride[weaponID] then
			reloadTime = ci.reloadOverride[weaponID] * (GetUnitRulesParam(unitID, "comm_reloadmult") or 1)
			reloadOverride = ci.reloadOverride[weaponID]
		else
			reloadTime = GetUnitWeaponState(unitID, weaponID, 'reloadTime')
		end
		if reloadTime and reloadTime >= options.minReloadTime.value then
			-- When weapon is disabled the reload time is constantly set to be almost complete.
			-- It results in a bunch of units walking around with 99% reload bars.
			if (reloadFrame > gameFrame + 6) or ((not reloadOverride) and (GetUnitRulesParam(unitID, "reloadPaused") ~= 1)) then -- UPDATE_PERIOD in unit_attributes.lua
				reload = 1 - ((reloadFrame-gameFrame)/gameSpeed) / reloadTime
				if (reload >= 0) then
					barDrawer.AddBar(addTitle and messages.reload_bar, reload, "reload", (addPercent and floor(reload*100) .. '%'))
				end
			end
		end
	end
end

function DrawUnitInfos(unitID, unitDefID)
	if (not customInfoUnits[unitDefID]) then
		CacheUnitInfo(unitDefID)
	end
	local ci = customInfoUnits[unitDefID]

	local ux, uy, uz = GetUnitViewPosition(unitID)
	if not ux then
		return
	end
	local dx, dy, dz = ux-cx, uy-cy, uz-cz
	local dist = dx*dx + dy*dy + dz*dz
	local reload, reloaded, reloadFrame

	if (dist > healthbarDistSq) then
		return
	end
	local addPercent = (dist < healthbarPercentSq)
	addTitle = (dist < healthbarTitleSq)

	--// GET UNIT INFORMATION
	local health, maxHealth, paralyzeDamage, capture, build = GetUnitHealth(unitID)
	paralyzeDamage = GetUnitRulesParam(unitID, "real_para") or paralyzeDamage
	--if (not health)    then health = -1   elseif(health < 1)    then health = 1    end
	if (not maxHealth)or(maxHealth < 1) then
		maxHealth = 1
	end
	if (not build) then
		build = 1
	end

	local empHP = (not paralyzeOnMaxHealth) and health or maxHealth
	local emp = (paralyzeDamage or 0)/empHP
	local hp  = (health or 0)/maxHealth

	if Spring.GetUnitIsDead(unitID) then
		health = false
	end

	if hp < 0 then
		hp = 0
	end

	local morph = UnitMorphs[unitID]

	if (drawUnitsOnFire) and (GetUnitRulesParam(unitID, "on_fire") == 1) then
		onFireUnits[#onFireUnits+1] = unitID
	end

	--// BARS //-----------------------------------------------------------------------------
	--// Shield
	if (ci.maxShield > 0) then
		local commShield = GetUnitRulesParam(unitID, "comm_shield_max")
		if commShield then
			if commShield ~= 0 then
				local shieldOn, shieldPower = GetUnitShieldState(unitID, GetUnitRulesParam(unitID, "comm_shield_num"))
				if (shieldOn)and(build == 1)and(shieldPower < commShield) then
					shieldPower = shieldPower / commShield
					barDrawer.AddBar(addTitle and messages.shield_bar, shieldPower, "shield", (addPercent and floor(shieldPower*100) .. '%'))
				end
			end
		else
			local shieldOn, shieldPower = GetUnitShieldState(unitID)
			if (shieldOn)and(build == 1)and(shieldPower < ci.maxShield) then
				shieldPower = shieldPower / ci.maxShield
				barDrawer.AddBar(addTitle and messages.shield_bar, shieldPower, "shield", (addPercent and floor(shieldPower*100) .. '%'))
			end
		end
	end

	--// HEALTH
	local hp100
	if (health) and ((drawFullHealthBars)or(hp < 1)) and ((build == 1)or(hp < 0.99 and (build > hp+0.01 or hp > build+0.01)) or (drawFullHealthBars)) then
		hp100 = hp*100; hp100 = hp100 - hp100%1; --//same as floor(hp*100), but 10% faster
		if (hp100 < 0) then hp100 = 0 elseif (hp100 > 100) then
			hp100 = 100
		end
		if (drawFullHealthBars)or(hp100 < 100) then
			barDrawer.AddBar(addTitle and messages.health_bar, hp, nil, (addPercent and hp100..'%') or '', bfcolormap[hp100])
		end
	end

	--// BUILD
	if (build < 1) then
		barDrawer.AddBar(addTitle and messages.building_bar, build, "build", (addPercent and floor(build*100) .. '%'))
	end

	--// MORPHING
	if (morph) then
		local build = morph.progress
		barDrawer.AddBar(addTitle and messages.morph_bar, build, "build", (addPercent and floor(build*100) .. '%'))
	end
	
	--// STOCKPILE
	local numStockpiled, numStockpileQued
	if (ci.canStockpile) then
		local stockpileBuild
		numStockpiled, numStockpileQued, stockpileBuild = GetUnitStockpile(unitID)
		if ci.gadgetStock then
			stockpileBuild = GetUnitRulesParam(unitID, "gadgetStockpile")
		end
		if numStockpiled and stockpileBuild and (numStockpileQued ~= 0) then
			barDrawer.AddBar(addTitle and messages.stockpile_bar, stockpileBuild, "stock", (addPercent and floor(stockpileBuild*100) .. '%'))
		end
	else
		numStockpiled = false
	end
	
		--// PARALYZE
	local paraTime = false
	local stunned = GetUnitIsStunned(unitID)
	if (emp > 0) and(emp < 1e8) then
		local infotext = ""
		stunned = stunned and paralyzeDamage >= empHP
		if (stunned) then
			paraTime = (paralyzeDamage-empHP)/(maxHealth*empDecline)
			paraUnits[#paraUnits+1] = unitID
			if (addPercent) then
				infotext = floor(paraTime) .. messages.acronyms_second
			end
			emp = 1
		else
			if (emp > 1) then
				emp = 1
			end
			if (addPercent) then
				infotext = floor(emp*100)..'%'
			end
		end
		local empcolor_index = (stunned and ((blink and "emp_b") or "emp_p")) or ("emp")
		barDrawer.AddBar(addTitle and messages.paralyze_bar, emp, empcolor_index, infotext)
	end
	local sensorStealDuration = 0
	local sensorTagDuration = 0
	if Spring.GetUnitAllyTeam(unitID) == myAllyTeam then
		sensorStealDuration = GetUnitRulesParam(unitID, "sensorsteal") or 0
		sensorTag = GetUnitRulesParam(unitID, "sensortag") or 0
	else
		sensorStealDuration = GetUnitRulesParam(unitID, "sensorsteal_" .. myAllyTeam) or 0
		sensorTagDuration = GetUnitRulesParam(unitID, "sensortag_" .. myAllyTeam) or 0
	end
	if sensorStealDuration > 0 then
		barDrawer.AddBar(addTitle and messages.sensorsteal, 1, "sensorsteal", string.format("%.1f", sensorStealDuration) .. messages.acronyms_second)
	elseif sensorTagDuration > 0 then
		barDrawer.AddBar(addTitle and messages.sensortag, 1, "sensortag", string.format("%.1f", sensorTagDuration) .. messages.acronyms_second)
	end
	 --// DISARM
	local disarmFrame = GetUnitRulesParam(unitID, "disarmframe")
	if disarmFrame and disarmFrame ~= -1 and disarmFrame > gameFrame then
		local disarmProp = (disarmFrame - gameFrame)/1200
		if disarmProp < 1 then
			if (not paraTime) and disarmProp > emp + 0.014 then -- 16 gameframes of emp time
				barDrawer.AddBar(addTitle and messages.disarm_bar, disarmProp, "disarm", (addPercent and floor(disarmProp*100) .. '%'))
			end
		else
			local disarmTime = (disarmFrame - gameFrame - 1200)/gameSpeed
			if (not paraTime) or disarmTime > paraTime + 0.5 then
				barDrawer.AddBar(addTitle and messages.disarm_bar, 1, ((blink and "disarm_b") or "disarm_p") or ("disarm"), floor(disarmTime) .. messages.acronyms_second)
				if not stunned then
					disarmUnits[#disarmUnits+1] = unitID
				end
			end
		end
	end
	
	--// CAPTURE (set by capture gadget)
	if ((capture or -1) > 0) then
		barDrawer.AddBar(addTitle and messages.capture_bar, capture, "capture", (addPercent and floor(capture*100) .. '%'))
	end
	
	--// CAPTURE RECHARGE
	if ci.canCapture then
		local captureReloadState = GetUnitRulesParam(unitID, "captureRechargeFrame")
		if (captureReloadState and captureReloadState > 0) then
			local capture = 1-(captureReloadState-gameFrame)/captureReloadTime
			barDrawer.AddBar(addTitle and messages.capture_bar_reload, capture, "reload", (addPercent and floor(capture*100) .. '%'))
		end
	end
	
	--// WATER TANK
	if ci.maxWaterTank then
		local waterTank = GetUnitRulesParam(unitID, "watertank")
		if waterTank then
			local prog = waterTank/ci.maxWaterTank
			if prog < 1 then
				barDrawer.AddBar(addTitle and messages.water_tank, prog, "tank", (addPercent and floor(prog*100) .. '%'))
			end
		end
	end
	
	--// Teleport progress
	local TeleportEnd = GetUnitRulesParam(unitID, "teleportend")
	local TeleportCost = GetUnitRulesParam(unitID, "teleportcost")
	if TeleportEnd and TeleportCost and TeleportEnd >= 0 then
		local prog
		if TeleportEnd > 1 then
			-- end frame given
			prog = 1 - (TeleportEnd - gameFrame)/TeleportCost
		else
			-- Same parameters used to display a static progress
			prog = 1 - TeleportEnd
		end
		if prog < 1 then
			barDrawer.AddBar(addTitle and messages.teleport_bar, prog, "tele", (addPercent and floor(prog*100) .. '%'))
		end
	end
	local tempArmor = GetUnitRulesParam(unitID, "temporaryarmor")
	if tempArmor then
		--local actualArmor = 1 - tempArmor
		local tempArmorDuration = (GetUnitRulesParam(unitID, "temporaryarmorduration") or 0) / 30
		local percent = string.format("%.0f", tempArmor * 100)
		barDrawer.AddBar(addTitle and string.gsub(messages.temporaryarmor, "{0}", percent) .. "%", tempArmor/0.9, "temporaryarmor", (addPercent and string.format("%.1f", tempArmorDuration) .. messages.acronyms_second))
	end
	
	--// Planetwars teleport progress
	if ci.isPwStructure then
		TeleportEnd = GetUnitRulesParam(unitID, "pw_teleport_frame")
		if TeleportEnd then
			local prog = 1 - (TeleportEnd - gameFrame)/TELEPORT_CHARGE_NEEDED
			if prog < 1 then
				barDrawer.AddBar(addTitle and messages.teleport_bar, prog, "tele_pw", (addPercent and floor(prog*100) .. '%'))
			end
		end
	end
	
	--// SPECIAL WEAPON
	if ci.specialReload then
		local specialReloadState = GetUnitRulesParam(unitID, "specialReloadFrame")
		if (specialReloadState and specialReloadState > gameFrame) then
			local slow = GetUnitRulesParam(unitID, "slowState") or 0
			slow = 1 - slow
			local special = 1-(specialReloadState-gameFrame)/(ci.specialReload/slow)	-- don't divide by gamespeed, since specialReload is also in gameframes
			local per = (addPercent and floor(special*100)) or 0
			per = math.max(0, per) -- do not allow it to go below 0%.
			barDrawer.AddBar(addTitle and messages.ability_bar, special, "reload2", (addPercent and floor(special*100) .. '%'))
		end
	end
	
	--// AIMING
	
	if ci.delaytime or GetUnitRulesParam(unitID, "comm_aimtime") then
		local aiming = GetUnitRulesParam(unitID, "aimdelay")
		if (aiming and aiming > gameFrame) then
			local delaytime = GetUnitRulesParam(unitID, "comm_aimtime") or ci.delaytime
			local aimProgress = (aiming-gameFrame)/delaytime	-- don't divide by gamespeed, since specialReload is also in gameframes
			local prog = 1 - aimProgress
			--Spring.Echo("AimProgress: " .. aimProgress)
			barDrawer.AddBar(addTitle and messages.aim, aimProgress, "aim", (addPercent and floor(prog*100) .. '%'))
		end
	end
	local bpOverdrive = GetUnitRulesParam(unitID, "bp_overdrive")
	if bpOverdrive then
		local bpProgress = floor(bpOverdrive * 100)
		if ci.bpoverdrivebonus then -- normal unit, not a commander.
			if ci.bpoverdrivebonus < 0 and bpOverdrive > 0 then
				barDrawer.AddBar(addTitle and messages.engioverdrive, bpOverdrive, "aim", (addPercent and 100 - bpProgress .. '%'))
			elseif ci.bpoverdrivebonus > 0 and bpOverdrive < 1 then
				barDrawer.AddBar(addTitle and messages.engioverdrive, bpOverdrive, "aim", (addPercent and bpProgress * ci.bpoverdrivebonus .. '%'))
			end
		else
			local bonus = GetUnitRulesParam(unitID, "comm_bpoverdrive_bonus") or 0
			if bonus > 0 and bpOverdrive < 100 then
				barDrawer.AddBar(addTitle and messages.engioverdrive, bpOverdrive, "aim", (addPercent and 100 - bpProgress .. '%'))
			elseif bonus < 1 and bpOverdrive > 0 then
				barDrawer.AddBar(addTitle and messages.engioverdrive, bpOverdrive, "aim", (addPercent and bpProgress * bonus .. '%'))
			end
		end
	end
	
	--// Battery
	if ci.batterymax then
		local currentBattery = GetUnitRulesParam(unitID, "battery")
		if currentBattery then
			local prog = currentBattery / ci.batterymax
			barDrawer.AddBar(addTitle and messages.battery, prog, "battery", (addPercent and floor(prog*100) .. '%'))
		end
	end
	
	--// REAMMO
	if ci.canReammo then
		local reammoProgress = GetUnitRulesParam(unitID, "reammoProgress")
		if reammoProgress then
			barDrawer.AddBar(addTitle and messages.reammo_bar, reammoProgress, "reammo", (addPercent and floor(reammoProgress*100) .. '%'))
		end
	end
	
	--// RELOAD
	if ci.reloadWatched and not ci.canReammo and not ci.usesSuperWeaponReload and not ci.usesSuperWeaponReload then
		if ci.dynamicComm then
			local primary = GetUnitRulesParam(unitID, "primary_weapon_override") or 1
			local secondary = GetUnitRulesParam(unitID, "secondary_weapon_override")
			ProcessWeapon(unitID, primary, ci, addPercent)
			if secondary then
				ProcessWeapon(unitID, secondary, ci, addPercent)
			end
		else
			for i = 1, #ci.reloadWatched do
				local weaponID = ci.reloadWatched[i]
				--Spring.Echo(weaponID)
				_, reloaded, reloadFrame = GetUnitWeaponState(unitID, weaponID)
				if (reloaded == false) then
					local reloadTime =  Spring.GetUnitWeaponState(unitID, weaponID, 'reloadTime')
					if reloadTime >= options.minReloadTime.value then
						if (reloadFrame > gameFrame + 6) or ((not reloadOverride) and (GetUnitRulesParam(unitID, "reloadPaused") ~= 1)) then -- UPDATE_PERIOD in unit_attributes.luaa
							reload = 1 - ((reloadFrame-gameFrame)/gameSpeed) / reloadTime
							if (reload >= 0) then
								barDrawer.AddBar(addTitle and messages.reload_bar, reload, "reload", (addPercent and floor(reload*100) .. '%'))
							end
						end
					end
				end
			end
		end
	end
	--[[if (ci.canReammo and not ci.usesSuperWeaponReload and not ci.needsFireControl) then
		for loop=1, (((ci.dyanmicComm and 2) or #ci.reloadTime)) do
			local primaryWeapon = (ci.dyanmicComm and ((loop==1 and GetUnitRulesParam(unitID, "primary_weapon_override")) or (loop==2 and GetUnitRulesParam(unitID, "secondary_weapon_override")))) or ci.primaryWeapon[loop]
			_, reloaded, reloadFrame = GetUnitWeaponState(unitID, primaryWeapon)
			if (reloaded == false) then
				local reloadOverride = ci.reloadOverride[(ci.dyanmicComm and primaryWeapon) or loop]
				local reloadTime = reloadOverride or Spring.GetUnitWeaponState(unitID, primaryWeapon, 'reloadTime')
				--(((q==1 and GetUnitRulesParam(unitID, "primary_weapon_reload_override"))) or ((q==2 and GetUnitRulesParam(unitID, "secondary_weapon_reload_override"))))
				if (not ci.dyanmicComm) or (reloadTime >= options.minReloadTime.value) then
					ci.reloadTime[loop] = reloadTime
					-- When weapon is disabled the reload time is constantly set to be almost complete.
					-- It results in a bunch of units walking around with 99% reload bars.
					if (reloadFrame > gameFrame + 6) or ((not reloadOverride) and (GetUnitRulesParam(unitID, "reloadPaused") ~= 1)) then -- UPDATE_PERIOD in unit_attributes.luaa
						reload = 1 - ((reloadFrame-gameFrame)/gameSpeed) / ci.reloadTime[loop];
						if (reload >= 0) then
							barDrawer.AddBar(addTitle and messages.reload_bar, reload, "reload", (addPercent and floor(reload*100) .. '%'))
						end
					end
				end
			end
		end
	end]]
	if ci.usesSuperWeaponReload then
		if ci.usesAmmoState then
			local currentAmmo = GetUnitRulesParam(unitID, "ammostate")
			if currentAmmo then
				currentAmmo = currentAmmo + 1
				local reloadProgress = GetUnitRulesParam(unitID, currentAmmo .. "_reload") or 1
				if reloadProgress < 1 then
					local speed = GetUnitRulesParam(unitID, "superweapon_mult") or 1
					local weaponDef = WeaponDefs[UnitDefs[unitDefID].weapons[currentAmmo].weaponDef]
					local reloadTime = math.ceil(((tonumber(weaponDef.customParams.script_reload) or 10) * 30) / speed) / 30 -- frame math
					if reloadTime >= options.minReloadTime.value then
						if (reloadProgress >= 0) then
							barDrawer.AddBar(addTitle and messages.reload_bar, reloadProgress, "reload", (addPercent and floor(reloadProgress*100) .. '%'))
						end
					end
				end
			end
		else
			if ci.weaponOverride then
				local reloadProgress = GetUnitRulesParam(unitID, ci.weaponOverride .. "_reload") or 1
				if reloadProgress < 1 then
					local speed = GetUnitRulesParam(unitID, "superweapon_mult") or 1
					local weaponDef = WeaponDefs[UnitDefs[unitDefID].weapons[ci.weaponOverride].weaponDef]
					local reloadTime = math.ceil(((tonumber(weaponDef.customParams.script_reload) or 10) * 30) / speed) / 30 -- frame math
					if reloadTime >= options.minReloadTime.value then
						if (reloadProgress >= 0) then
							barDrawer.AddBar(addTitle and messages.reload_bar, reloadProgress, "reload", (addPercent and floor(reloadProgress*100) .. '%'))
						end
					end
				end
			else
				for loop = 1, #ci.reloadWatched do
					local weaponID = ci.reloadWatched[loop]
					local reloadProgress = GetUnitRulesParam(weaponID .. "_reload") or 1
					if reloadProgress < 1 then
						local speed = GetUnitRulesParam(unitID, "superweapon_mult") or 1
						local weaponDef = WeaponDefs[UnitDefs[unitDefID].weapons[weaponID].weaponDef]
						local reloadTime = math.ceil(((tonumber(weaponDef.customParams.script_reload) or 10) * 30) / speed) / 30 -- frame math
						if reloadTime >= options.minReloadTime.value then
							if (reloadProgress >= 0) then
								barDrawer.AddBar(addTitle and messages.reload_bar, reloadProgress, "reload", (addPercent and floor(reloadProgress*100) .. '%'))
							end
						end
					end
				end
			end
		end
	end
	if ci.needsFireControl then
		for loop = 1, #ci.scriptReload do
			weaponID = ci.scriptReload[loop]
			reload = GetUnitRulesParam(unitID, weaponID .. "_reload") or 1
			if reload < 1 then
				local reloadTime = ci.scriptReloadTimes[weaponID] or 10
				speed = GetUnitRulesParam(unitID, "firecontrol_mult_" .. loop) or 1
				reloadTime = math.ceil((reloadTime * 30) / speed) / 30 -- frame math
				--Spring.Echo("Reload time: " .. reloadTime .. "(MinReloadTime: " .. options.minReloadTime.value .. ")")
				if reloadTime >= options.minReloadTime.value then
					--Spring.Echo("Reload: " .. reload)
					if (reload >= 0) then
						barDrawer.AddBar(addTitle and messages.reload_bar, reload, "reload", (addPercent and floor(reload*100) .. '%'))
					end
				end
			end
		end
	end
	if not ci.usesSuperWeaponReload and not ci.needsFireControl and ci.scriptReload then
		for i = 1, #ci.scriptReload do
			local weaponID = ci.scriptReload[i]
			local reloadTime = ci.scriptReloadTimes[weaponID]
			if reloadTime == nil then
				Spring.Echo("Warning: nil reload time for weaponID " .. tostring(weaponID) .. " , Unitdef: " .. UnitDefs[unitDefID].name)
			end
			if reloadTime >= options.minReloadTime.value then
				local reloadFrame = GetUnitRulesParam(unitID, "scriptReloadFrame")
				if reloadFrame and reloadFrame > gameFrame then
					local maxLoaded = ci.scriptReloadBursts[weaponID]
					local scriptLoaded = GetUnitRulesParam(unitID, "scriptLoaded") or maxLoaded
					local barText = string.format("%i/%i", scriptLoaded, maxLoaded) -- .. ' | ' .. floor(reload*100) .. '%'
					reload = Spring.GetUnitRulesParam(unitID, "scriptReloadPercentage") or (1 - ((reloadFrame - gameFrame)/gameSpeed) / reloadTime)
					if (reload >= 0) then
						barDrawer.AddBar(addTitle and messages.reload_bar, reload, "reload", (addPercent and barText))
					end
				end
			end
		end
	end
	
	--// SHEATH
	--local sheathState = GetUnitRulesParam(unitID, "sheathState")
	--if sheathState and (sheathState < 1) then
	--	barDrawer.AddBar("sheath", sheathState, "sheath", (addPercent and floor(sheathState*100) .. '%'))
	--end
	
	--// SLOW
	local slowState = GetUnitRulesParam(unitID, "slowState")
	if (slowState and (slowState > 0)) then
		if slowState > 0.5 then
			barDrawer.AddBar(addTitle and messages.slow_bar, 1, "slow", (addPercent and floor((slowState - 0.5)*25) .. messages.acronyms_second))
		else
			barDrawer.AddBar(addTitle and messages.slow_bar, slowState*2, "slow", (addPercent and floor(slowState*100) .. '%'))
		end
	end
	
	--// GOO
	if ci.canGoo then
		local gooState = GetUnitRulesParam(unitID, "gooState")
		if (gooState and (gooState > 0)) then
			barDrawer.AddBar(addTitle and messages.goo_bar, gooState, "goo", (addPercent and floor(gooState*100) .. '%'))
		end
	end
	
	--// JUMPJET
	if ci.canJump then
		local jumpReload = GetUnitRulesParam(unitID, "jumpReload")
		if (jumpReload and (jumpReload > 0) and (jumpReload < 1)) then
			barDrawer.AddBar(addTitle and messages.jump_bar, jumpReload, "jump", (addPercent and floor(jumpReload*100) .. '%'))
		end
	end

	--// DRONES
	if ci.hasDrones then
		local drones = GetUnitRulesParam(unitID, "dronesControlled")
		local maxDrones = GetUnitRulesParam(unitID, "dronesControlledMax")
		if (drones and maxDrones) then
			barDrawer.AddBar(addTitle and string.gsub(messages.drones, "{0}", drones.."/"..maxDrones), drones/maxDrones, "drones", (addPercent and drones.."/"..maxDrones))
		end
	end
	
	if debugMode then
		local x, y, z = Spring.GetUnitPosition(unitID)
		--Spring.MarkerAddPoint(x, y, z, "N" .. barsN)
	end

	if ((barDrawer.HasBars()) or (numStockpiled)) then
		glPushMatrix()
		glTranslate(ux, uy+ci.height, uz )
		gl.Scale(barScale, barScale, barScale)
		glBillboard()

		--// STOCKPILE ICON
		if (numStockpiled) then
			barDrawer.DrawStockpile(numStockpiled, numStockpileQued, ci.freeStockpile)
		end

		--// DRAW BARS
		barDrawer.DrawBars()

		glPopMatrix()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local DrawFeatureInfos
local customInfoFeatures = {}


function DrawFeatureInfos(featureID, featureDefID, addPercent, addTitle, fx, fy, fz)
	if (not customInfoFeatures[featureDefID]) then
		local featureDef = FeatureDefs[featureDefID or -1] or {height = 0, name = ''}
		customInfoFeatures[featureDefID] = {
			height = featureDef.height+14,
		}
	end
	local ci = customInfoFeatures[featureDefID]
	local reclaimLeft
	local health, maxHealth, resurrect = GetFeatureHealth(featureID)
	_, _, _, _, reclaimLeft      = GetFeatureResources(featureID) -- NB: the two resources' progresses are actually separate (goo can drain just M while keeping E)
	if (not resurrect) then
		resurrect = 0
	end
	if (not reclaimLeft) then
		reclaimLeft = 1
	end

	local hp = (health or 0)/(maxHealth or 1)

	--// filter all walls and none resurrecting features
	if (resurrect == 0) and
		 (reclaimLeft == 1) and
		 (hp > featureHpThreshold) then
		return
	end

	--// BARS //-----------------------------------------------------------------------------
	--// HEALTH
	if (hp < featureHpThreshold)and(drawFeatureHealth) then
		local hpcolor = {GetColor(fhpcolormap, hp)}
		barDrawer.AddBar(addTitle and messages.health_bar, hp, nil, (addPercent and floor(hp*100) .. '%'), hpcolor)
	end

	--// RESURRECT
	if (resurrect > 0) then
		barDrawer.AddBar(addTitle and messages.resurrect_bar, resurrect, "resurrect", (addPercent and floor(resurrect*100) .. '%'))
	end

	--// RECLAIMING
	if (reclaimLeft > 0 and reclaimLeft < 1) then
		barDrawer.AddBar(addTitle and messages.reclaim_bar, reclaimLeft, "reclaim", (addPercent and floor(reclaimLeft*100) .. '%'))
	end

	if barDrawer.HasBars() then
		glPushMatrix()
		glTranslate(fx, fy+ci.height, fz)
		local scale = options.barScale.value or 1
		gl.Scale(barScale, barScale, barScale)
		glBillboard()

		--// DRAW BARS
		barDrawer.DrawBarsFeature()

		glPopMatrix()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local DrawOverlays

function DrawOverlays()
	--// draw an overlay for stunned or disarmed units
	if (drawStunnedOverlay) and ((#paraUnits > 0) or (#disarmUnits > 0)) then
		glDepthTest(true)
		glPolygonOffset(-2, -2)
		glBlending(GL_SRC_ALPHA, GL_ONE)

		local alpha = ((5.5 * widgetHandler:GetHourTimer()) % 2) - 0.7
		if (#paraUnits > 0) then
			glColor(0, 0.7, 1, alpha/4)
			for i = 1, #paraUnits do
				glUnit(paraUnits[i], true)
			end
		end
		if (#disarmUnits > 0) then
			glColor(0.8, 0.8, 0.5, alpha/6)
			for i = 1, #disarmUnits do
				glUnit(disarmUnits[i], true)
			end
		end
		local shift = widgetHandler:GetHourTimer() / 20

		glTexCoord(0, 0)
		glTexGen(GL_T, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR)
		local cvs = GetCameraVectors()
		local v = cvs.right
		glTexGen(GL_T, GL_EYE_PLANE, v[1]*0.008, v[2]*0.008, v[3]*0.008, shift)
		glTexGen(GL_S, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR)
		v = cvs.forward
		glTexGen(GL_S, GL_EYE_PLANE, v[1]*0.008, v[2]*0.008, v[3]*0.008, shift)

		if (#paraUnits > 0) then
			glTexture("LuaUI/Images/paralyzed.png")
			glColor(0, 1, 1, alpha*1.1)
			for i = 1, #paraUnits do
				glUnit(paraUnits[i], true)
			end
		end
		if (#disarmUnits > 0) then
			glTexture("LuaUI/Images/disarmed.png")
			glColor(0.6, 0.6, 0.2, alpha*0.9)
			for i = 1, #disarmUnits do
				glUnit(disarmUnits[i], true)
			end
		end

		glTexture(false)
		glTexGen(GL_T, false)
		glTexGen(GL_S, false)
		glBlending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
		glPolygonOffset(false)
		glDepthTest(false)

		paraUnits = {}
		disarmUnits = {}
	end

	--// overlay for units on fire
	if (drawUnitsOnFire)and(onFireUnits) then
		glDepthTest(true)
		glPolygonOffset(-2, -2)
		glBlending(GL_SRC_ALPHA, GL_ONE)

		local alpha = abs((widgetHandler:GetHourTimer() % 2)-1)
		glColor(1, 0.3, 0, alpha/4)
		for i = 1, #onFireUnits do
			glUnit(onFireUnits[i], true)
		end

		glBlending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
		glPolygonOffset(false)
		glDepthTest(false)

		onFireUnits = {}
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function IsUnitMorphing(unitID)
	if not UnitMorphs then
		return false
	end
	if UnitMorphs[unitID] then
		return not UnitMorphs[unitID].combatMorph
	else
		return false
	end
end

function widget:Initialize()
	WG.InitializeTranslation (languageChanged, GetInfo().name)
	WG.IsUnitMorphing = IsUnitMorphing
	--// catch f9
	Spring.SendCommands({"showhealthbars 0"})
	Spring.SendCommands({"showrezbars 0"})
	widgetHandler:AddAction("showhealthbars", showhealthbars)
	Spring.SendCommands({"unbind f9 showhealthbars"})
	Spring.SendCommands({"bind f9 luaui showhealthbars"})

	--// find real primary weapon and its reloadtime
	ReCacheReloadTimes()

	--// link morph callins
	widgetHandler:RegisterGlobal('MorphUpdate', MorphUpdate)
	widgetHandler:RegisterGlobal('MorphFinished', MorphFinished)
	widgetHandler:RegisterGlobal('MorphStart', MorphStart)
	widgetHandler:RegisterGlobal('MorphStop', MorphStop)

	--// deactivate cheesy progress text
	widgetHandler:RegisterGlobal('MorphDrawProgress', function() return true end)

	--// wow, using a buffered list can give 1-2 frames in extreme(!) situations :p
	for hp = 0, 100 do
		bfcolormap[hp] = {GetColor(hpcolormap, hp*0.01)}
	end
end

function widget:Shutdown()
	WG.ShutdownTranslation(GetInfo().name)

	--// catch f9
	widgetHandler:RemoveAction("showhealthbars", showhealthbars)
	Spring.SendCommands({"unbind f9 luaui"})
	Spring.SendCommands({"bind f9 showhealthbars"})
	Spring.SendCommands({"showhealthbars 1"})
	Spring.SendCommands({"showrezbars 1"})

	widgetHandler:DeregisterGlobal('MorphUpdate', MorphUpdate)
	widgetHandler:DeregisterGlobal('MorphFinished', MorphFinished)
	widgetHandler:DeregisterGlobal('MorphStart', MorphStart)
	widgetHandler:DeregisterGlobal('MorphStop', MorphStop)

	widgetHandler:DeregisterGlobal('MorphDrawProgress')
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local visibleFeatures = {}
local visibleUnits = {}

do
	local ALL_UNITS            = Spring.ALL_UNITS
	local GetCameraPosition    = Spring.GetCameraPosition
	local GetUnitDefID         = Spring.GetUnitDefID
	local glDepthMask          = gl.DepthMask
	local glMultiTexCoord      = gl.MultiTexCoord

	function widget:DrawWorld()
		if not Spring.IsGUIHidden() then
			if (#visibleUnits + #visibleFeatures == 0) then
				return
			end

			-- Test camera height before processing
			if not IsCameraBelowMaxHeight() then
				return false
			end

			-- Processing
			if WG.Cutscene and WG.Cutscene.IsInCutscene() then
				return
			end
			--gl.Fog(false)
			--gl.DepthTest(true)
			glDepthMask(true)

			cx, cy, cz = GetCameraPosition()

			--// draw bars of units
			local unitID, unitDefID, unitDef
			for i = 1, #visibleUnits do
				unitID    = visibleUnits[i]
				unitDefID = GetUnitDefID(unitID)
				if (unitDefID) then
					if DrawUnitInfos(unitID, unitDefID) then
						local x, y, z = Spring.GetUnitPosition(unitID)
						if not (x and y and z) then
							Spring.Log("HealthBars", "error", "missing position and unitDef of unit " .. unitID)
						else
							Spring.MarkerAddPoint(x, y, z, "Missing unitDef")
						end
					end
				elseif debugMode then
					local x, y, z = Spring.GetUnitPosition(unitID)
					if not (x and y and z) then
						Spring.Log("HealthBars", "error", "missing position and unitDefID of unit " .. unitID)
					else
						Spring.MarkerAddPoint(x, y, z, "Missing unitDef")
					end
				end
			end

			--// draw bars for features
			local wx, wy, wz, dx, dy, dz, dist, featureID, valid
			local featureInfo
			for i = 1, #visibleFeatures do
				featureInfo = visibleFeatures[i]
				featureID = featureInfo[4]
				valid = Spring.ValidFeatureID(featureID)
				if (valid) then
					wx, wy, wz = featureInfo[1], featureInfo[2], featureInfo[3]
					dx, dy, dz = wx-cx, wy-cy, wz-cz
					dist = dx*dx + dy*dy + dz*dz
					if (dist < featureDistSq) then
						DrawFeatureInfos(featureInfo[4], featureInfo[5], (dist < featurePercentSq), (dist < featureTitleSq), wx, wy, wz)
					end
				end
			end
		else
			local unitID, unitDefID
			for i = 1, #visibleUnits do
				unitID    = visibleUnits[i]
				unitDefID = GetUnitDefID(unitID)
				if (unitDefID) then
					JustGetOverlayInfos(unitID, unitDefID)
				end
			end
		end

		glDepthMask(false)

		DrawOverlays()
		glMultiTexCoord(1, 1, 1, 1)
		glColor(1, 1, 1, 1)

		--gl.DepthTest(false)
	end
end --//end do

do
	local GetVisibleUnits      = Spring.GetVisibleUnits
	local GetVisibleFeatures   = Spring.GetVisibleFeatures
	local GetFeatureDefID      = Spring.GetFeatureDefID
	local GetFeaturePosition   = Spring.GetFeaturePosition
	local GetFeatureResources  = Spring.GetFeatureResources
	local select = select

	local sec = 0
	local sec2 = 0

	function widget:Update(dt)

		-- Test camera height before processing
		if not IsCameraBelowMaxHeight() then
			return false
		end

		-- Processing
		sec = sec+dt
		blink = (sec%1) < 0.5

		visibleUnits = GetVisibleUnits(-1, nil, false) --this don't need any delayed update or caching or optimization since its already done in "LUAUI/cache.lua"

		sec2 = sec2+dt
		if (sec2 > 1/3) then
			sec2 = 0
			visibleFeatures = GetVisibleFeatures(-1, nil, false, false)
			local cnt = #visibleFeatures
			local featureID, featureDefID, featureDef
			for i = cnt, 1, -1 do
				featureID    = visibleFeatures[i]
				featureDefID = GetFeatureDefID(featureID) or -1
				--// filter trees and none destructable features
				if destructableFeature[featureDefID] and (drawnFeature[featureDefID] or (select(5, GetFeatureResources(featureID)) < 1)) then
					local fx, fy, fz = GetFeaturePosition(featureID)
					visibleFeatures[i] = {fx, fy, fz, featureID, featureDefID}
				else
					visibleFeatures[i] = visibleFeatures[cnt]
					visibleFeatures[cnt] = nil
					cnt = cnt-1
				end
			end
		end

	end

end --//end do

function widget:GameFrame(f)
	gameFrame = f
end

function widget:PlayerChanged(playerID)
	if playerID == Spring.GetMyPlayerID() then
		myAllyTeam = Spring.GetMyAllyTeamID()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--// not 100% finished!

function MorphUpdate(morphTable)
	UnitMorphs = morphTable
end

function MorphStart(unitID, morphDef)
	--return false
end

function MorphStop(unitID)
	UnitMorphs[unitID] = nil
end

function MorphFinished(unitID)
	UnitMorphs[unitID] = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

