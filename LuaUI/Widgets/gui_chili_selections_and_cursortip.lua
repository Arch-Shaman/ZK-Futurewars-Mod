
function widget:GetInfo()
	return {
		name      = "Chili Selections & CursorTip v2",
		desc      = "Chili Selection Window and Cursor Tooltip remade.",
		author    = "GoogleFrog", -- (CarRepairer and jK orginal)
		date      = "9 February 2017",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

include("keysym.lua")

include("Widgets/COFCTools/ExportUtilities.lua")
local CMD_LEVEL = Spring.Utilities.CMD.LEVEL
local CMD_RAISE = Spring.Utilities.CMD.RAISE
local CMD_RAMP  = Spring.Utilities.CMD.RAMP
local CMD_RESTORE = Spring.Utilities.CMD.RESTORE
local CMD_SMOOTH = Spring.Utilities.CMD.SMOOTH
local _, _, ammoStateInfo = VFS.Include("LuaRules/Configs/ammostateinfo.lua")

local spGetMouseState = Spring.GetMouseState
local spTraceScreenRay = Spring.TraceScreenRay
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitHealth = Spring.GetUnitHealth
local spGetUnitIsStunned = Spring.GetUnitIsStunned
local spGetGameRulesParam = Spring.GetGameRulesParam
local spGetModKeyState = Spring.GetModKeyState
local spSelectUnitArray = Spring.SelectUnitArray
local spGetUnitWeaponState = Spring.GetUnitWeaponState
local spGetUnitCurrentBuildPower = Spring.GetUnitCurrentBuildPower
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spScaledGetMouseState = Spring.ScaledGetMouseState
local spGetUnitShieldState = Spring.GetUnitShieldState
local spGetGameFrame = Spring.GetGameFrame

local GetUnitBuildSpeed = Spring.Utilities.GetUnitBuildSpeed
local GetHumanName = Spring.Utilities.GetHumanName
local GetUnitCost = Spring.Utilities.GetUnitCost
local GetDescription = Spring.Utilities.GetDescription
local GetHelptext = Spring.Utilities.GetHelptext

local strFormat = string.format

local green = '\255\1\255\1'
local red = '\255\255\1\1'
local cyan = '\255\1\255\255'
local white = '\255\255\255\255'
local yellow = '\255\255\255\1'

local selectionTooltip
local singleSelectionTooltip

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Chili
local screen0

local screenWidth, screenHeight = Spring.GetViewGeometry()

local tooltipWindow
local selectionWindow

local ICON_SIZE = 20
local BAR_SIZE = 22
local BAR_FONT = 13
local BAR_SPACING = 24
local IMAGE_FONT = 12
local DESC_FONT = 10
local TOOLTIP_FONT = 13
local STATS_FONT = 13
local NAME_FONT = 14
local LEFT_SPACE = 24
local LEFT_LABEL_HEIGHT = 16
local SEL_BUTTON_SHORTENING = 2

local LEFT_WIDTH = 55
local PIC_HEIGHT = LEFT_WIDTH*4/5 + 1
local RIGHT_WIDTH = 235
local GROUP_STATS_WIDTH = 150

local IMAGE = {
	HEALTH = 'LuaUI/images/commands/bold/health.png',
	SHIELD = 'LuaUI/Images/commands/Bold/guard.png',
	BUILD = 'LuaUI/Images/commands/Bold/buildsmall.png',
	COST = 'LuaUI/images/costIcon.png',
	TIME = 'LuaUI/images/clock.png',
	METAL = 'LuaUI/images/metalplus.png',
	ENERGY = 'LuaUI/images/energyplus.png',
	WIND_SPEED = 'LuaUI/images/windspeed.png',
	METAL_RECLAIM = 'LuaUI/images/ibeamReclaim.png',
	ENERGY_RECLAIM = 'LuaUI/images/energyReclaim.png',
	NO_AMMO =  'LuaUI/images/noammo.png',
	COMMAND_BASE = 'LuaUI/Images/Commands/',
}

local CURSOR_ERASE = 'eraser'
local CURSOR_POINT = 'flagtext'
local CURSOR_DRAW = 'pencil'
local CURSOR_ERASE_NAME = "map_erase"
local CURSOR_POINT_NAME = "map_point"
local CURSOR_DRAW_NAME = "map_draw"

local NO_TOOLTIP = "NONE"

local iconTypesPath = LUAUI_DIRNAME .. "Configs/icontypes.lua"
local icontypes = VFS.FileExists(iconTypesPath) and VFS.Include(iconTypesPath)
local _, iconFormat = VFS.Include(LUAUI_DIRNAME .. "Configs/chilitip_conf.lua" , nil, VFS.ZIP)
local UNIT_BURST_DAMAGES = VFS.Include(LUAUI_DIRNAME .. "Configs/burst_damages.lua" , nil, VFS.ZIP)
local reclaimedTooltip = "Reclaimed"
local builtTooltip = "Built"

local terraformGeneralTip =
	green.. 'Click&Drag'..white..': Free draw terraform. \n'..
	green.. 'Alt+Click&Drag'..white..': Box terraform. \n'..
	green.. 'Alt+Ctrl+Click&Drag'..white..': Hollow box terraform. \n'..
	green.. 'Ctrl+Click on unit' ..white..': Terraform around unit. \n'..
	'\n'

local terraCmdTip = {
	[CMD_RAMP] =
		yellow..'[Ramp between two points]\n'..
		'1: ' .. green.. 'Click&Drag'..white..' from start to end. \n' ..
		'2: ' .. green.. 'Click' ..white..' again to set width. \n'..
		'\n'..
		yellow..'[Ramp with raised end]\n'..
		'1: ' .. green.. 'Click'..white..' at start. \n'..
		'2: ' .. green.. 'Click&Drag'..white..' at end to set height. \n'..
		'3: ' .. green.. 'Click' ..white..' again to set width. \n'..
		'\n'..
		yellow..'[Modifiers]\n'..
		'- Hold '.. green..'Ctrl or Alt'..white..' and '.. green..'drag' ..white..' in Step 1 to set start height. \n'..
		'- Hold '.. green..'Alt'..white..' to snap height or gradient. \n'..
		'- Press '..green.. 'Space'..white..' to cycle raise/lower. \n'..
		'\n'..
		yellow..'[Wireframe indicator colors]\n'..
		green.. 'Green'..white..': All units can traverse. \n'..
		green.. 'Yellow'..white..': Vehicles cannot traverse. \n'..
		green.. 'Red'..white..': Only all-terrain units can traverse.',
	[CMD_LEVEL] = terraformGeneralTip ..
		yellow..'[During Terraform Draw]\n'..
		green.. 'Ctrl'..white..': Draw straight line segment. \n'..
		'\n'..
		yellow..'[After Terraform Draw]\n'..
		green.. 'Alt'..white..': Snap to starting height / below water level (prevent ships) / below water level (prevent land units). \n'..
		green.. 'Ctrl'..white..': Hold and point at terrain to level to height pointed at.\n'..
		'\n'..
		yellow..'[Any Time]\n'..
		green.. 'Space'..white..': Cycle through only raise/lower',
	[CMD_RAISE] = terraformGeneralTip ..
		yellow..'[During Terraform Draw]\n'..
		green.. 'Ctrl'..white..': Draw straight line segment. \n'..
		'\n'..
		yellow..'[After Terraform Draw]\n'..
		green.. 'Alt'..white..': Snap to steps of 6 height.\n(6 blocks vehicles, 18 blocks bots)\n'..
		green.. 'Ctrl'..white..': Reset to 0 height.',
	[CMD_SMOOTH] = terraformGeneralTip ..
		yellow..'[During Terraform Draw]\n'..
		green.. 'Ctrl'..white..': Draw straight line segment.',
	[CMD_RESTORE] = terraformGeneralTip ..
		yellow..'[Any Time]\n'..
		green.. 'Space'..white..': Limit to only raise/lower',
}

local DRAWING_TOOLTIP =
	green.. 'Left click'..white..': Draw on map.\n' ..
	green.. 'Right click'..white..': Erase.\n' ..
	green.. 'Middle click'..white..': Place marker.\n' ..
	green.. 'Double click'..white..': Place marker with label.\n' ..
	green.. '1' .. white .. ": Smart label: Will attempt to place a label based on context. (IE: repair me, enemy spotted, scout here, etc)\n" ..
	green.. '2' .. white .. ": Request reinforcements or assistance with building something.\n" ..
	green.. '3' .. white .. ": Tell an ally to retreat (hover over a unit to ping specific player)\n" ..
	green.. '4' .. white .. ": Tell allies to attack a position or unit\n" ..
	green.. '5' .. white .. ": Request Air Support at a location or to bomb/intercept a unit\n" ..
	green.. '6' .. white .. ": Request allies fire an EMP missile at a target\n" ..
	green.. '7' .. white .. ": Request artillery support\n" ..
	green.. '8' .. white .. ": Suggest an area to nuke"
	
	

local SPECIAL_WEAPON_RELOAD_PARAM = "specialReloadRemaining"
local JUMP_RELOAD_PARAM = "jumpReload"

local reloadBarColor = {013, 245, 243, 1}
local fullHealthBarColor = {0, 255, 0, 1}

local econStructureDefs = {}

local TIDAL_HEALTH = UnitDefNames.energywind.customParams.tidal_health

local dynamicTooltipDefs = {
	[UnitDefNames["terraunit"].id] = true,
	[UnitDefNames["energypylon"].id] = true,
	[UnitDefNames["zenith"].id] = true,
	[UnitDefNames["staticheavyarty"].id] = true,
	[UnitDefNames["staticarty"].id] = true,
	[UnitDefNames["raveparty"].id] = true,
	[UnitDefNames["supernova_base"].id] = true,
}

for unitDefID,_ in pairs(econStructureDefs) do
	dynamicTooltipDefs[unitDefID] = true
end

local filterUnitDefIDs = {
	[UnitDefNames["terraunit"].id] = true
}

local tidalHeight
local windMin
local windMax
local windGroundMin
local windGroundSlope
local windMinBound
local econMultEnabled

local GAIA_TEAM = Spring.GetGaiaTeamID()

local UPDATE_FREQUENCY = 0.2

local isCommander = {}
local maxShield = {}

local manualFireTimeDefs = {}
local specialReloadDefs = {}
local jumpReloadDefs = {}
local ammoRequiringDefs = {}
for unitDefID = 1, #UnitDefs do
	local ud = UnitDefs[unitDefID]
	local cp = UnitDefs[unitDefID].customParams
	local unitWeapon = (ud and ud.weapons)
	unitWeapon = unitWeapon and unitWeapon[3]
	--Note: weapon no.3 is by ZK convention is usually used for user controlled weapon
	if (unitWeapon ~= nil) and WeaponDefs[unitWeapon.weaponDef].manualFire then
		manualFireTimeDefs[unitDefID] = WeaponDefs[unitWeapon.weaponDef].reload
	end
	if ud.customParams.specialreloadtime then
		specialReloadDefs[unitDefID] = tonumber(ud.customParams.specialreloadtime)
	end
	if ud.customParams.canjump then
		jumpReloadDefs[unitDefID] = -1 --Signifies that reload time is not stored
	end
	if ud.customParams.reammoseconds then
		ammoRequiringDefs[unitDefID] = true
	end
	local energyIncome = tonumber(cp.income_energy) or 0
	if energyIncome > 0 then
		econStructureDefs[unitDefID] = {cost = ud.metalCost, income = energyIncome}
	end

	local mexMult = tonumber(cp.metal_extractor_mult) or 0
	if mexMult > 0 then
		econStructureDefs[unitDefID] = {cost = ud.metalCost, mex = mexMult}
	end
	if cp.level or cp.dynamic_comm then
		isCommander[unitDefID] = true
	end
	if cp.shield_power then
		maxShield[unitDefID] = tonumber(cp.shield_power)
	end
end

econStructureDefs[UnitDefNames.energywind.id].isWind = true

for _, entry in pairs(ammoStateInfo) do
	for key, pic in pairs(entry.texture) do
		entry.texture[key] = IMAGE.COMMAND_BASE .. pic
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables

local drawHotkeyBytes = {}
local drawHotkeyBytesCount = 0
local oldMouseX, oldMouseY = 0, 0
local stillCursorTime = 0
local global_totalBuildPower = 0

local sameObjectID
local sameObjectIDTime = 0

local selectedUnitsList = {}
local commanderManualFireReload = {}

local ctrlFilterUnits = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Settings

options_path = 'Settings/HUD Panels/Tooltip'
local selPath = 'Settings/HUD Panels/Selected Units Panel'

options_order = {
	--tooltip
	'tooltip_delay', 'independant_world_tooltip_delay',
	'show_for_units', 'show_for_wreckage', 'show_for_unreclaimable', 'showdrawtooltip','showterratooltip',
	'showDrawTools', 'tooltip_opacity',
	
	--selected units
	'selection_opacity', 'allowclickthrough', 'tooltipThroughPanels', 'groupbehaviour', 'showgroupinfo', 'ctrlFilter',
	'uniticon_size', 'manualWeaponReloadBar', 'jumpReloadBar',
	'fancySkinning', 'leftPadding',
}

local showManualFire = true
local showJumpReload = true

options = {
	tooltip_delay = {
		name = 'Tooltip display delay (0 - 4s)',
		desc = 'Determines how long you can leave the mouse idle until the tooltip is displayed.',
		type = 'number',
		min=0,max=4,step=0.05,
		value = 0,
	},
	independant_world_tooltip_delay = { -- Done
		name = 'Unit and Feature tooltip delay (0 - 4s)',
		--desc = 'Determines how long you can leave the mouse over a unit or feature until the tooltip is displayed.',
		type = 'number',
		min=0,max=4,step=0.05,
		value = 0.2,
	},
	show_for_units = {
		name = "Show Tooltip for Units",
		type = 'bool',
		value = true,
		noHotkey = true,
		desc = 'Show the tooltip for units.',
	},
	show_for_wreckage = {
		name = "Show Tooltip for Wreckage",
		type = 'bool',
		value = true,
		noHotkey = true,
		desc = 'Show the tooltip for wreckage and map features.',
	},
	show_for_unreclaimable = {
		name = "Show Tooltip for Unreclaimables",
		type = 'bool',
		advanced = true,
		value = false,
		noHotkey = true,
		desc = 'Show the tooltip for unreclaimable features.',
	},
	showdrawtooltip = {
		name = "Show Map-drawing Tooltip",
		type = 'bool',
		value = true,
		noHotkey = true,
		desc = 'Show map-drawing tooltip when holding down the tilde (~).',
	},
	showterratooltip = {
		name = "Show Terraform Tooltip",
		type = 'bool',
		value = true,
		noHotkey = true,
		desc = 'Show terraform tooltip when performing terraform commands.',
	},
	showDrawTools = {
		name = "Show Drawing Tools When Drawing",
		type = 'bool',
		value = true,
		noHotkey = true,
		desc = 'Show pencil or eraser when drawing or erasing.'
	},
	tooltipThroughPanels = {
		name='Allow hovering through', type='bool', value=false,
		desc = 'Show tooltips for units behind empty interface panels.',
	},
	tooltip_opacity = {
		name = "Opacity",
		type = "number",
		value = 0.92, min = 0, max = 1, step = 0.01,
		update_on_the_fly = true,
		OnChange = function(self)
			if not tooltipWindow then
				return
			end
			tooltipWindow.SetOpacity(self.value)
		end,
	},

	selection_opacity = {
		name = "Opacity",
		type = "number",
		value = 0.8, min = 0, max = 1, step = 0.01,
		update_on_the_fly = true,
		OnChange = function(self)
			if selectionWindow then
				selectionWindow.SetOpacity(self.value)
			end
		end,
		path = selPath,
	},
	allowclickthrough = {
		name = 'Allow clicking through', type='bool', value=false,
		desc = 'Mouse clicks through empty parts of the panel act on whatever is underneath.',
		path = selPath,
		OnChange = function(self)
			if selectionWindow then
				selectionWindow.SetAllowClickThrough(self.value)
			end
		end,
	},
	groupbehaviour = {name='Unit Grouping Behaviour', type='radioButton',
		value='overflow',
		items = {
			{key = 'overflow',	name = 'On window overflow'},
			{key = 'multitype',	name = 'With multiple unit types'},
			{key = 'always',		name = 'Always'},
		},
		path = selPath,
	},
	showgroupinfo = {name='Show Group Info', type='bool', value=true,
		path = selPath,
		OnChange = function(self)
			if selectionWindow then
				selectionWindow.SetGroupInfoVisible(self.value)
			end
		end,
	},
	ctrlFilter = {
		name = 'Ctrl Selection Filtering',
		type = 'bool',
		desc = "Hold Ctrl and click on some units. These units will be selected when Ctrl is released.",
		value = true,
		path = selPath,
	},
	--unitCommand = {
	--	name="Show Unit's Command",
	--	type='bool',
	--	value= false,
	--	noHotkey = true,
	--	desc = "Display current command on unit's icon (only for ungrouped unit selection)",
	--	path = selPath,
	--},
	uniticon_size = {
		name = 'Icon size on selection list',
		--desc = 'Determines how small the icon in selection list need to be.',
		type = 'number',
		min=30,max=100,step=1,
		value = 57,
		path = selPath,
		OnChange = function(self)
			if selectionWindow then
				selectionWindow.SetSelectionIconSize(self.value)
			end
		end,
	},
	manualWeaponReloadBar = {
		name="Show Unit's Special Weapon Status",
		type='bool',
		value= true,
		noHotkey = true,
		desc = "Show reload progress for weapon that use manual trigger (only for ungrouped unit selection)",
		path = selPath,
		OnChange = function(self)
			showManualFire = self.value
		end,
	},
	jumpReloadBar = {
		name="Show Unit's Jump Status",
		type='bool',
		value= true,
		noHotkey = true,
		desc = "Show reload progress for jumpjets (only for ungrouped unit selection)",
		path = selPath,
		OnChange = function(self)
			showJumpReload = self.value
		end,
	},
	fancySkinning = {
		name = 'Fancy Skinning',
		type = 'radioButton',
		value = 'panel',
		path = selPath,
		items = {
			{key = 'panel', name = 'None'},
			{key = 'panel_1120', name = 'Bottom Left Flush',},
			{key = 'panel_0120', name = 'Bot Mid Left Flush',},
			{key = 'panel_2120', name = 'Bot Mid Both Flush',},
		},
		OnChange = function (self)
			if selectionWindow then
				selectionWindow.SetSkin(self.value)
			end
		end,
		hidden = true,
		noHotkey = true,
	},
	leftPadding = {
		name = "Left Padding",
		type = "number",
		value = 0, min = 0, max = 500, step = 1,
		OnChange = function(self)
			if selectionWindow then
				selectionWindow.SetLeftPadding(self.value)
			end
		end,
		path = selPath,
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

function Round(num, idp)
	if (not idp) then
		return math.floor(num+.5)
	else
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end
end

local function Format(amount, displaySign)
	local formatted
	if type(amount) == "number" then
		if (amount ==0) then formatted = "0" else
			if (amount < 20 and (amount * 10)%10 ~=0) then
				if displaySign then
					formatted = strFormat("%+.1f", amount)
				else
					formatted = strFormat("%.1f", amount)
				end
			else
				if displaySign then
					formatted = strFormat("%+d", amount)
				else
					formatted = strFormat("%d", amount)
				end
			end
		end
	else
		formatted = amount .. ""
	end
	return formatted
end

local function FormatPlusMinus(num)
	if num > 0.04 then
		return green .. Format(num, true)
	elseif num < -0.04 then
		return red .. Format(num, true)
	end
	return Format(num)
end

local function SecondsToMinutesSeconds(seconds)
	if seconds%60 < 10 then
		return math.floor(seconds/60) ..":0" .. math.floor(seconds%60)
	else
		return math.floor(seconds/60) ..":" .. math.floor(seconds%60)
	end
end

local function UnitDefTableSort(a,b)
	return a and UnitDefs[a] and b and UnitDefs[b] and UnitDefs[a].name < UnitDefs[b].name
end

local function IsGroupingRequired(selectedUnits, selectionSortOrder, selectionSpace)
	if options.groupbehaviour.value == 'overflow' then
		return #selectedUnits > selectionSpace
	elseif options.groupbehaviour.value == 'multitype' then
		return not (#selectedUnits <= selectionSpace and #selectionSortOrder <= 1)
	else
		return true
	end
end

local function GetHealthColor(fraction, returnString)
	local midpt = (fraction > 0.5)
	local r, g
	if midpt then
		r = (1 - fraction)*2
		g = 1
	else
		r = 1
		g = fraction*2
	end
	if returnString then
		return string.char(255, math.floor(255*r), math.floor(255*g), 0)
	end
	return {r, g, 0, 1}
end

local function SetPanelSkin(targetPanel, className)
	local currentSkin = Chili.theme.skin.general.skinName
	local skin = Chili.SkinHandler.GetSkin(currentSkin)
	local newClass = skin.panel
	if skin[className] then
		newClass = skin[className]
	end
	
	targetPanel.tiles = newClass.tiles
	targetPanel.TileImageFG = newClass.TileImageFG
	--targetPanel.backgroundColor = newClass.backgroundColor
	targetPanel.TileImageBK = newClass.TileImageBK
	if newClass.padding then
		targetPanel.padding = newClass.padding
		targetPanel:UpdateClientArea()
	end
	targetPanel:Invalidate()
end

local iconTypeCache = {}
local function GetUnitIcon(unitDefID)
	if unitDefID and iconTypeCache[unitDefID] then
		return iconTypeCache[unitDefID]
	end
	local ud = UnitDefs[unitDefID]
	if not ud then
		return
	end
	iconTypeCache[unitDefID] = icontypes[(ud and ud.iconType or "default")].bitmap or 'icons/' .. ud.iconType .. iconFormat
	return iconTypeCache[unitDefID]
end

local function GetCurrentBuildSpeed(unitID, buildSpeed)
	return (Spring.GetUnitCurrentBuildPower(unitID) or 0)*(spGetUnitRulesParam(unitID, "totalEconomyChange") or 1)*buildSpeed
end

local unitBorderCache = {}
local function GetUnitBorder(unitDefID)
	if unitDefID and unitBorderCache[unitDefID] then
		return unitBorderCache[unitDefID]
	end
	local ud = UnitDefs[unitDefID]
	if not ud then
		return
	end
	unitBorderCache[unitDefID] = WG.GetBuildIconFrame and WG.GetBuildIconFrame(ud)
	return unitBorderCache[unitDefID]
end

local unitSelectionTooltipCache = {}
local function GetUnitSelectionTooltip(ud, unitDefID, unitID)
	if ud.level then
		return GetHumanName(ud, unitID) .. " - " .. GetDescription(ud, unitID) .. selectionTooltip
	end
	if not unitSelectionTooltipCache[unitDefID] then
		unitSelectionTooltipCache[unitDefID] = GetHumanName(ud, unitID) .. " - " .. GetDescription(ud, unitID) .. selectionTooltip
	end
	return unitSelectionTooltipCache[unitDefID]
end

local unitSingleSelectionTooltipCache = {}
local function GetSingleUnitSelectionTooltip(ud, unitDefID, unitID)
	if not unitSingleSelectionTooltipCache[unitDefID] then
		unitSingleSelectionTooltipCache[unitDefID] = GetHelptext(ud) .. singleSelectionTooltip
	end
	return unitSingleSelectionTooltipCache[unitDefID]
end

local function GetWeaponReloadStatus(unitID, weapNum, reloadTime)
	local _, _, weaponReloadFrame, _, _ = spGetUnitWeaponState(unitID, weapNum) --select weapon no.X
	if weaponReloadFrame then
		local currentFrame, _ = spGetGameFrame()
		local remainingTime = (weaponReloadFrame - currentFrame)/30
		local reloadFraction = 1 - remainingTime/reloadTime
		return reloadFraction, remainingTime
	end
	return nil --Note: this mean unit doesn't have weapon number 'weapNum'
end

local function GetRulesParamReloadStatus(unitID, rulesParam, reloadTime)
	local specialReloadState = spGetUnitRulesParam(unitID, rulesParam)
	if specialReloadState then
		if reloadTime > 0 then
			--local currentFrame, _ = spGetGameFrame()
			--local remainingTime = (specialReloadState - currentFrame)
			--local reloadFraction = 1 - remainingTime/reloadTime
			--return reloadFraction
			return 1 - specialReloadState
		end
		return specialReloadState
	end
	return false
end

local function GetUnitResources(unitID)
	local mm, mu, em, eu = Spring.GetUnitResources(unitID)
	
	mm = (mm or 0) + (spGetUnitRulesParam(unitID, "current_metalIncome") or 0)
	em = (em or 0) + (spGetUnitRulesParam(unitID, "current_energyIncome") or 0)
	eu = (eu or 0) + (spGetUnitRulesParam(unitID, "overdrive_energyDrain") or 0)
	
	if mm ~= 0 or mu ~= 0 or em ~= 0 or eu ~= 0 then
		return mm, (mu or 0), em, eu
	else
		return
	end
end

local function GetUnitRegenString(unitID, ud)
	if unitID and (not select(3, spGetUnitIsStunned(unitID))) then
		local regen_timer = spGetUnitRulesParam(unitID, "idleRegenTimer")
		if regen_timer and ud then
			if ((ud.idleTime <= 600) and (regen_timer > 0)) then
				return "  (" .. math.ceil(regen_timer / 30) .. "s)"
			else
				local totalregen = 0
				local regenMult = (1 - (spGetUnitRulesParam(unitID, "slowState") or 0)) * (1 - (spGetUnitRulesParam(unitID,"disarmed") or 0))
				if regenMult == 0 then
					return
				end

				local regen = 0
				
				if (regen_timer <= 0) then
					regen = regen + (spGetUnitRulesParam(unitID, "comm_autorepair_rate") or ud.customParams.idle_regen)
				end
				regen = regen + (spGetUnitRulesParam(unitID, "cloakregen") or 0)
				totalregen = totalregen + (spGetUnitRulesParam(unitID, "nanoregen") or 0)
				if ud.customParams.amph_regen then
					local x,y,z = Spring.GetUnitPosition(unitID)
					local h = Spring.GetGroundHeight(x,z) or y
					if (h < 0) then
						regen = regen + math.min(ud.customParams.amph_regen, ud.customParams.amph_regen*(-h / ud.customParams.amph_submerged_at))
					end
				end
				
				if ud.customParams.armored_regen and Spring.GetUnitArmored(unitID) then
					regen = regen + ud.customParams.armored_regen
				end
				if (regen > 0) then
					return "  (+" .. math.ceil(regenMult*regen) .. ")"
				end
			end
		end
	end
end

local function GetUnitShieldRegenString(unitID, ud)
	if spGetUnitRulesParam(unitID, "att_shieldDisabled") == 1 then
		return ""
	end
	local shieldDisruption = spGetUnitRulesParam(unitID, "shield_disrupted")
	if shieldDisruption then
		shieldDisruption = (shieldDisruption - spGetGameFrame()) / 30
		if shieldDisruption > 0 then
			return " " .. Chili.color2incolor({0.7, 0, 0, 1}) .. WG.Translate("interface", "shield_disrupted", {duration = strFormat("%+.1f", shieldDisruption)}) .. Chili.color2incolor({1,1,1,1})
		end
	end
	local shieldRegen = spGetUnitRulesParam(unitID, "shieldRegenTimer")
	if shieldRegen and shieldRegen > 0 then
		return "  (" .. math.ceil(shieldRegen / 30) .. "s)"
	end
	
	local mult = spGetUnitRulesParam(unitID,"totalReloadSpeedChange") or 1 * (1 - (spGetUnitRulesParam(unitID, "shieldChargeDisabled") or 0))
	if mult == 0 then
		return ""
	end

	-- FIXME: take energy stall into account
	local wd = WeaponDefs[ud.shieldWeaponDef]
	local wdc = wd.customParams
	local regen = (wdc.shield_rate_charge and Spring.GetUnitRulesParam(unitID, "shield_rate_override") and
			math.floor(Spring.GetUnitRulesParam(unitID, "shield_rate_override")*15 + 0.5)) or
			tonumber(wdc.shield_rate or wd.shieldPowerRegen)
	if not wd.customParams.slow_immune then
		regen = mult * regen
	end
	local sign = (regen >= 0) and "+" or ""
	if math.abs(math.ceil(regen) - regen) < 0.05 then
		return " (" .. sign .. math.ceil(regen - 0.2) .. ")"
	end
	return " (" .. sign .. strFormat("%+.1f", regen) .. ")"
end

local function IsUnitInLos(unitID)
	local spectating, fullView = Spring.GetSpectatingState()
	if fullView then
		return true
	end
	if not unitID then
		return false
	end
	local state = Spring.GetUnitLosState(unitID)
	return state and state.los
end

local function GetUnitNeedRearm(unitID, unitDefID)
	if not ammoRequiringDefs[unitDefID] then
		return false
	end
	local reammoState = (spGetUnitRulesParam(unitID, "noammo") or 0)
	return reammoState == 1 or reammoState == 2
end

local function GetUnitAmmoPic(unitID, unitDefID)
	if not (ammoStateInfo[unitDefID] and unitID and Spring.ValidUnitID(unitID)) then
		return
	end
	local ammoState = spGetUnitRulesParam(unitID, "ammostate") or 0
	return ammoStateInfo[unitDefID].texture[ammoState + 1]
end

local function GetManualFireReload(unitID, unitDefID)
	if not (unitDefID and showManualFire) then
		return false
	end
	
	if unitID and commanderManualFireReload[unitID] then
		local reload = commanderManualFireReload[unitID]
		if reload[1] == 0 then
			return false
		end
		return reload[1], reload[2]
	end
	unitDefID = unitDefID or Spring.GetUnitDefID(unitID)
	if not unitDefID then
		return false
	end
	
	if manualFireTimeDefs[unitDefID] then
		return manualFireTimeDefs[unitDefID], 3
	end
	if specialReloadDefs[unitDefID] then
		return specialReloadDefs[unitDefID], false, SPECIAL_WEAPON_RELOAD_PARAM
	end
	if not (unitID and isCommander[unitDefID]) then
		return false
	end
	
	local manualFire = spGetUnitRulesParam(unitID, "comm_weapon_manual_2")
	if manualFire ~= 1 then
		commanderManualFireReload[unitID] = {0}
		return false
	end
	
	local weaponNum = spGetUnitRulesParam(unitID, "comm_weapon_num_2")
	if not weaponNum then
		commanderManualFireReload[unitID] = {0}
		return false
	end
	
	local ud = UnitDefs[unitDefID]
	local unitWeapon = ud and ud.weapons and ud.weapons[weaponNum]
	if (unitWeapon ~= nil) and WeaponDefs[unitWeapon.weaponDef].manualFire then
		local reload = WeaponDefs[unitWeapon.weaponDef].reload
		commanderManualFireReload[unitID] = {reload, weaponNum}
		return reload, weaponNum
	end
	
	commanderManualFireReload[unitID] = {0}
	return false
end

local function GetJumpReload(unitID, unitDefID)
	if not (unitDefID and showJumpReload) then
		return false
	end
	unitDefID = unitDefID or Spring.GetUnitDefID(unitID)
	if not unitDefID then
		return false
	end
	if jumpReloadDefs[unitDefID] then
		return jumpReloadDefs[unitDefID]
	end
	return false
end

local function GetExtraBuildTooltipAndHealthOverride(unitDefID, mousePlaceX, mousePlaceY)
	local econDef = econStructureDefs[unitDefID]
	if not econDef then
		return
	end
	local mult = 1
	if econMultEnabled then
		mult = mult * (Spring.GetGameRulesParam("econ_mult_" .. (Spring.GetMyAllyTeamID() or "")) or 1)
	end
	
	if econDef.mex then
		if mousePlaceX and WG.mouseoverMexIncome then
			local finalBaseIncome = WG.mouseoverMexIncome * mult * econDef.mex
			local extraText = ", ".. WG.Translate("interface", "income") .. " +" .. math.round(finalBaseIncome, 2)
			if WG.mouseoverMexIncome > 0 then
				return extraText .. "\n" .. WG.Translate("interface", "base_payback") .. ": " .. SecondsToMinutesSeconds(econDef.cost / finalBaseIncome)
			else
				return extraText .. "\n" .. WG.Translate("interface", "base_payback") .. ": " .. WG.Translate("interface", "never")
			end
		end
		return
	end
	
	local income = econDef.income * mult
	local cost = econDef.cost
	local extraText = ""
	local healthOverride = false
	local minWind = 0
	if econDef.isWind then
		if mousePlaceX and mousePlaceY then
			local _, pos = spTraceScreenRay(mousePlaceX, mousePlaceY, true)
			if pos and pos[1] and pos[3] then
				local x,z = math.floor(pos[1]/16)*16,  math.floor(pos[3]/16)*16
				local y = Spring.GetGroundHeight(x,z)

				if y then
					if y <= tidalHeight then
						extraText = ", " .. WG.Translate("interface", "tidal_income") .. " +" .. math.round(income, 1)
						healthOverride = TIDAL_HEALTH
						minWind = income
					else
						local minWindIncome = (windMin + (windMax - windMin)*math.max(0, math.min(windMinBound, windGroundSlope*(y - windGroundMin))))
						extraText = ", " .. WG.Translate("interface", "wind_range") .. " " .. math.round(minWindIncome * mult, 1) .. " - " .. math.round(windMax * mult, 1)
						income = mult * (minWindIncome + windMax)/2
						minWind = minWindIncome
					end
				end
			end
		end
	else
		extraText = extraText .. " (+" .. math.round(income, ((mult == 1) and 0) or 1) .. ")"
	end
	
	local teamID = Spring.GetLocalTeamID()
	local metalOD = Spring.GetTeamRulesParam(teamID, "OD_team_metalOverdrive") or 0
	local energyOD = Spring.GetTeamRulesParam(teamID, "OD_team_energyOverdrive") or 0
	
	if metalOD and metalOD > 0 and energyOD and energyOD > 0 then
		-- Best case payback assumes that extra energy will make
		-- metal at the current energy:metal ratio. Note that if
		-- grids are linked better then better payback may be
		-- achieved.
		--local bestCasePayback = cost/(income*metalOD/energyOD)
		
		-- Uniform case payback assumes that all mexes are being
		-- overdriven equally and figures out their multiplier
		-- from the base mex income. It then figures out how many
		-- mexes there are and adds a portion of the new enginer to
		-- them.
		--local totalMexIncome = WG.mexIncome
		--if not totalMexIncome then
		--	local singleMexMult = math.sqrt(energyOD)/4
		--	totalMexIncome = metalOD/singleMexMult
		--end
		--local overdriveMult = metalOD/totalMexIncome
		--local energyPerMex = 16*overdriveMult^2
		--local mexCount = energyOD/energyPerMex
		--local incomePerMex = income/mexCount
		--local overdrivePerMex = metalOD/mexCount
		--local extraMetalPerMex = totalMexIncome/mexCount*math.sqrt(energyPerMex+incomePerMex)/4 - overdrivePerMex
		--local extraMetal = extraMetalPerMex*mexCount
		--local unitformCasePayback = cost/extraMetal
		
		-- Worst case payback assumes that all your OD metal is from
		-- a single mex and you are going to link your new energy to it.
		-- It seems to be equal to Uniform case payback and quite accurate.
		local singleMexMult = math.sqrt(energyOD) / 4
		local mexIncome = metalOD / singleMexMult
		local worstCasePayback = cost / (mexIncome*math.sqrt(energyOD + income)/4 - metalOD)
		
		--extraText = extraText
		--.. "\n overdriveMult: " .. overdriveMult
		--.. "\n energyPerMex: " .. energyPerMex
		--.. "\n mexCount: " .. mexCount
		--.. "\n incomePerMex: " .. incomePerMex
		--.. "\n overdrivePerMex: " .. overdrivePerMex
		--.. "\n extraMetalPerMex: " .. extraMetalPerMex
		--.. "\n extraMetal: " .. extraMetalza
		--.. "\n unitformCasePayback: " .. unitformCasePayback
		--.. "\n worstCasePayback: " .. worstCasePayback
		return extraText .. "\n" .. WG.Translate("interface", "od_payback") .. ": " .. SecondsToMinutesSeconds(worstCasePayback), healthOverride, minWind
	end
	return extraText .. "\n" .. WG.Translate("interface", "od_payback") .. ": " ..  WG.Translate("interface", "unknown"), healthOverride, minWind
end

local function GetPlayerCaption(teamID)
	local _, player,_,isAI = Spring.GetTeamInfo(teamID, false)
	local playerName
	if isAI then
		local _, aiName, _, shortName = Spring.GetAIInfo(teamID)
		playerName = aiName -- .. ' (' .. shortName .. ')'
	else
		playerName = (player and Spring.GetPlayerInfo(player, false)) or (teamID ~= GAIA_TEAM and "noname")
		if not playerName then
			return false
		end
	end
	local teamColor = Chili.color2incolor(Spring.GetTeamColor(teamID))
	return WG.Translate("interface", "player") .. ': ' .. teamColor .. playerName
end

local function GetIsHoldingDrawKey()
	if drawHotkeyBytesCount == 0 then
	WG.drawtoolKeyPressed = false
		return false
	end
	for i = 1, drawHotkeyBytesCount do
		local key = drawHotkeyBytes[i]
		if Spring.GetKeyState(key) then
			WG.drawtoolKeyPressed = true
			return true
		end
	end
	WG.drawtoolKeyPressed = false
	return false
end

local function UpdateMouseCursor(holdingDrawKey)
	if not (holdingDrawKey and options.showDrawTools.value) then
		return
	end
	local x, y, drawing, addingPoint, erasing = spGetMouseState()
	if addingPoint then
		Spring.SetMouseCursor(CURSOR_POINT_NAME)
	elseif erasing then
		Spring.SetMouseCursor(CURSOR_ERASE_NAME)
	else
		Spring.SetMouseCursor(CURSOR_DRAW_NAME)
	end
end

local function SelectionsIconClick(button, unitID, unitList, unitDefID)
	unitID = unitID or (unitList and unitList[1])
	
	if not unitID then
		return
	end
	local alt, ctrl, meta, shift = spGetModKeyState()

	if meta and (button == 1) and WG.MakeStatsWindow then  -- Space+Click - show unit stats
		local x, y = spGetMouseState()
		local udid = UnitDefs[spGetUnitDefID(unitID)]
		WG.MakeStatsWindow(udid, x, y, unitID)
		return true
	end

	-- selectedUnitsList is global and has the same ordering as unitList
	local newSelectedUnits
	
	if (button == 3) then
		if alt or shift then
			--// deselect whole block, or half if alt is held
			local toDeselect = #unitList
			if alt then
				toDeselect = math.floor(toDeselect / 2)
			end
			newSelectedUnits = {}
			local j = 1
			for i = 1, #selectedUnitsList do
				if toDeselect > 0 and unitList[j] and selectedUnitsList[i] == unitList[j] then
					j = j + 1
					toDeselect = toDeselect - 1
				else
					newSelectedUnits[#newSelectedUnits + 1] = selectedUnitsList[i]
				end
			end
		else
			--// deselect a single unit
			for i = 1, #selectedUnitsList do
				if selectedUnitsList[i] == unitID then
					selectedUnitsList[i] = selectedUnitsList[#selectedUnitsList]
					selectedUnitsList[#selectedUnitsList] = nil
				end
			end
			newSelectedUnits = selectedUnitsList
		end
		spSelectUnitArray(newSelectedUnits)
		widget:SelectionChanged(newSelectedUnits)
	elseif button == 1 then
		if ctrl then
			ctrlFilterUnits = ctrlFilterUnits or {}
			if shift or alt then
				local toSelect = #unitList
				if alt then
					toSelect = math.ceil(toSelect / 2)
				end
				for i = 1, toSelect do
					ctrlFilterUnits[#ctrlFilterUnits + 1] = unitList[i]
				end
			else
				ctrlFilterUnits[#ctrlFilterUnits + 1] = unitID
			end
		else
			if alt then
				local toSelect = math.ceil(#unitList / 2)
				newSelectedUnits = {}
				for i = 1, toSelect do
					newSelectedUnits[#newSelectedUnits + 1] = unitList[i]
				end
				spSelectUnitArray(newSelectedUnits)
			elseif shift then
				spSelectUnitArray(unitList) -- select all
			else
				spSelectUnitArray({unitID})  -- only 1
			end
		end
	else --button2 (middle)
		local x,y,z = Spring.GetUnitPosition(unitID)
		SetCameraTarget(x, y, z, 1)
	end
end

local function CheckCtrlFilterRelease()
	if not ctrlFilterUnits then
		return
	end
	spSelectUnitArray(ctrlFilterUnits)
	ctrlFilterUnits = false
end

local cacheFeatureTooltip = {}
local cacheFeatureUnitDefID = {}
local function GetFeatureDisplayAttributes(featureDefID)
	if cacheFeatureTooltip[featureDefID] or cacheFeatureUnitDefID[featureDefID] then
		return cacheFeatureTooltip[featureDefID], cacheFeatureUnitDefID[featureDefID]
	end
	local fd = FeatureDefs[featureDefID]
	
	local featureName = fd and fd.name
	local unitName
	if fd and fd.customParams and fd.customParams.unit then
		unitName = fd.customParams.unit
	else
		unitName = featureName:gsub('(.*)_.*', '%1') --filter out _dead or _dead2 or _anything
	end
	
	if specialName then
		specialName = Spring.Utilities.GetCommanderFeatureName(featureID)
		return specialName, UnitDefNames[unitName].id
	end
	
	local unitDefID
	if unitName and UnitDefNames[unitName] then
		unitDefID = UnitDefNames[unitName].id
	end
	
	if featureName:find("dead2") or featureName:find("heap") then
		addedName = " (" .. WG.Translate("interface", "debris") .. ")"
	elseif featureName:find("dead") then
		addedName = " (" .. WG.Translate("interface", "wreckage") .. ")"
	end
	
	if unitDefID then
		cacheFeatureUnitDefID[featureDefID] = unitDefID
		return nil, cacheFeatureUnitDefID[featureDefID]
	end
	cacheFeatureTooltip[featureDefID] = fd.tooltip
	return cacheFeatureTooltip[featureDefID]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Unit tooltip window components

local function GetBarWithImage(parentControl, name, initY, imageFile, color, colorFunc)
	local image = Chili.Image:New{
		name = name .. "_image",
		x = 2,
		y = initY,
		width = ICON_SIZE,
		height = ICON_SIZE,
		file = imageFile,
		parent = parentControl,
	}
	
	local bar = Chili.Progressbar:New {
		name = name .. "_bar",
		x = ICON_SIZE + 3,
		y = initY,
		right = 0,
		height = BAR_SIZE,
		max = 1,
		color = color,
		itemMargin  = {0,0,0,0},
		itemPadding = {0,0,0,0},
		padding     = {0,0,0,0},
		caption = '',
		objectOverrideFont = WG.GetFont(BAR_FONT),
		parent = parentControl
	}
	
	local function UpdateBar(visible, yPos, currentValue, maxValue, extraCaption, newCaption)
		image:SetVisibility(visible)
		bar:SetVisibility(visible)
		if not visible then
			return
		end
		if yPos then
			image:SetPos(nil, yPos, nil, nil, nil, true)
			bar:SetPos(nil, yPos, nil, nil, nil, true)
		end
		if not newCaption then
			newCaption = Format(currentValue) .. ' / ' .. Format(maxValue)
			if extraCaption then
				newCaption = newCaption .. extraCaption
			end
		end
		bar:SetCaption(newCaption)
		if colorFunc then
			color = colorFunc(currentValue/maxValue)
			bar.color = color
		end
		if maxValue == 0 then
			maxValue = 1
		end
		bar:SetValue(currentValue/maxValue)
	end
	
	return UpdateBar
end

local function GetImage(parentControl, name, initY, imageFile, iconSize, xOffset)
	iconSize = iconSize or ICON_SIZE
	xOffset = xOffset or 0
	
	local image = Chili.Image:New{
		name = name .. "_image",
		x = xOffset,
		y = initY,
		width = iconSize,
		height = iconSize,
		file = imageFile,
		parent = parentControl,
	}
	image:SetVisibility(false)
	
	local function Update(visible, newImage, yPos)
		image:SetVisibility(visible)
		if not visible then
			return
		end
		if yPos then
			image:SetPos(nil, yPos, nil, nil, nil, true)
			label:SetPos(nil, yPos + textOffset, nil, nil, nil, true)
		end
		if newImage ~= imageFile then
			imageFile = newImage
			image.file = imageFile
			image:Invalidate()
		end
	end
	
	return Update
end

local function GetImageWithText(parentControl, name, initY, imageFile, caption, fontSize, iconSize, textOffset, xOffset)
	fontSize = fontSize or IMAGE_FONT
	iconSize = iconSize or ICON_SIZE
	xOffset = xOffset or 0
	
	local image = Chili.Image:New{
		name = name .. "_image",
		x = xOffset,
		y = initY,
		width = iconSize,
		height = iconSize,
		file = imageFile,
		parent = parentControl,
	}
	local label = Chili.Label:New{
		name = name .. "_label",
		x = xOffset + iconSize + 2,
		y = initY + (textOffset or 0),
		right = 0,
		height = LEFT_LABEL_HEIGHT,
		caption = IMAGE_FONT,
		objectOverrideFont = WG.GetFont(fontSize),
		parent = parentControl,
	}
	image:SetVisibility(false)
	label:SetVisibility(false)
	
	local function Update(visible, newCaption, newImage, yPos)
		image:SetVisibility(visible)
		label:SetVisibility(visible)
		if not visible then
			return
		end
		if yPos then
			image:SetPos(nil, yPos, nil, nil, nil, true)
			label:SetPos(nil, yPos + textOffset, nil, nil, nil, true)
		end
		label:SetCaption(newCaption)
		if newImage ~= imageFile then
			if imageFile == nil then
				label:SetPos(iconSize + 2, nil, nil, nil, nil, true)
			elseif newImage == nil then
				label:SetPos(2, nil, nil, nil, nil, true)
			end
			imageFile = newImage
			image.file = imageFile
			image:Invalidate()
		end
	end
	
	return Update
end

local function GetCostInfoPanel(parentControl, yPos)
	local holder = Chili.Control:New{
		x = 0,
		y = yPos,
		right = 0,
		height = ICON_SIZE,
		padding = {0,0,0,0},
		parent = parentControl,
	}
	
	local nameLabel = Chili.Label:New{
		x = 4,
		y = 2,
		height = ICON_SIZE,
		width = 50,
		caption = cyan .. 'Morph:',
		objectOverrideFont = WG.GetFont(NAME_FONT),
		parent = holder,
	}
	local costImage = Chili.Image:New{
		x = 54,
		y = 0,
		width = ICON_SIZE,
		height = ICON_SIZE,
		file = IMAGE.COST,
		parent = holder,
	}
	local costLabel = Chili.Label:New{
		x = 54 + ICON_SIZE + 4,
		y = 2,
		right = 0,
		height = BAR_SIZE,
		caption = BAR_FONT,
		objectOverrideFont = WG.GetFont(NAME_FONT),
		parent = holder,
	}
	local timeImage = Chili.Image:New{
		x = 124,
		y = 0,
		width = ICON_SIZE,
		height = ICON_SIZE,
		file = IMAGE.TIME,
		parent = holder,
	}
	local timeLabel = Chili.Label:New{
		x = 124 + ICON_SIZE + 4,
		y = 2,
		right = 0,
		height = BAR_SIZE,
		caption = BAR_FONT,
		objectOverrideFont = WG.GetFont(NAME_FONT),
		parent = holder,
	}
	
	local function Update(visible, newTime, newCost, newName, yPos, textX)
		holder:SetVisibility(visible)
		if not visible then
			return
		end
		if textX then
			costImage:SetPos(textX)
			costLabel:SetPos(textX + ICON_SIZE + 4)
			timeImage:SetPos(textX + 70)
			timeLabel:SetPos(textX + 70 + ICON_SIZE + 4)
		end
		if yPos then
			holder:SetPos(nil, yPos, nil, nil, nil, true)
		end
		if newTime then
			timeLabel:SetCaption(cyan .. newTime)
		end
		if newCost then
			costLabel:SetCaption(cyan .. newCost)
			local width = 1 + math.floor(math.log(newCost + 1) / math.log(10))
			timeImage:SetPos(textX + 35 + width * 7)
			timeLabel:SetPos(textX + 35 + width * 7 + ICON_SIZE + 4)
		end
		if newName then
			nameLabel:SetCaption(cyan .. newName)
		end
	end
	
	return Update
end

local function UpdateManualFireReload(reloadBar, parentImage, unitID, weaponNum, rulesParam, reloadTime, onLeft)
	if not reloadBar then
		reloadBar = Chili.Progressbar:New {
			x = (onLeft and 5) or "82%",
			y = 5,
			right = ((not onLeft) and 5) or "82%",
			bottom = 5,
			minWidth = 4,
			max = 1,
			caption = false,
			noFont = true,
			color = reloadBarColor,
			skinName = 'default',
			orientation = "vertical",
			reverse = true,
			parent = parentImage,
		}
	end
	local reloadFraction
	if weaponNum then
		reloadFraction = GetWeaponReloadStatus(unitID, weaponNum, reloadTime)
	elseif rulesParam then
		reloadFraction = GetRulesParamReloadStatus(unitID, rulesParam, reloadTime)
	end
	
	if reloadFraction and reloadFraction < 1 then
		reloadBar:SetValue(reloadFraction)
		reloadBar:SetVisibility(true)
	else
		reloadBar:SetVisibility(false)
	end
	return reloadBar
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Group buttons window

local function GetUnitGroupIconButton(parentControl)
	
	local unitDefID
	local unitID
	local unitList
	local unitCount
	local unitpicBadge1Update, unitpicBadge2Update
	
	local size = options.uniticon_size.value
	
	local holder = Chili.Control:New{
		x = 0,
		y = 0,
		width = size,
		height = size,
		padding = {1,1,1,1},
		parent = parentControl,
	}
	
	local reloadBar, jumpBar
	local healthBar = Chili.Progressbar:New {
		x = 0,
		y = "80%",
		right = 0,
		height = 0,
		max = 1,
		caption = false,
		noFont = true,
		color = fullHealthBarColor,
		parent = holder
	}
	
	local unitImage = Chili.Image:New{
		keepAspect = false,
		x = 0,
		y = 0,
		right = 0,
		bottom = "20%",
		padding = {0,0,0,0},
		parent = holder,
		OnClick = {
			function(_,_,_,button)
				SelectionsIconClick(button, unitID, unitList, unitDefID)
			end
		}
	}
	
	local groupLabel = Chili.Label:New{
		x = 0,
		right = 2,
		bottom = 0,
		height = 25,
		align  = "right",
		valign = "top",
		objectOverrideFont = WG.GetSpecialFont(20, "outline", {outline = true}),
		parent = unitImage
	}
	
	local function UpdateUnitInfo()
		if unitID then
			local health, maxhealth = spGetUnitHealth(unitID)
			if health then
				healthBar.color = GetHealthColor(health/maxhealth)
				healthBar:SetValue(health/maxhealth)
			end
			local reloadTime, weaponNum, rulesParam = GetManualFireReload(unitID, unitDefID)
			if reloadTime then
				reloadBar = UpdateManualFireReload(reloadBar, unitImage, unitID, weaponNum, rulesParam, reloadTime)
			elseif reloadBar then
				reloadBar:SetVisibility(false)
			end
			local jumpReloadTime = GetJumpReload(unitID, unitDefID)
			if jumpReloadTime then
				jumpBar = UpdateManualFireReload(jumpBar, unitImage, unitID, false, JUMP_RELOAD_PARAM, jumpReloadTime, true)
			elseif jumpBar then
				jumpBar:SetVisibility(false)
			end
			local needRearm = GetUnitNeedRearm(unitID, unitDefID)
			if needRearm and (not unitpicBadge1Update) then
				unitpicBadge1Update = GetImage(unitImage, "costInfoUpdate", 4, IMAGE.NO_AMMO, ICON_SIZE, 4)
			end
			local ammoPic = GetUnitAmmoPic(unitID, unitDefID)
			if ammoPic and (not unitpicBadge2Update) then
				unitpicBadge2Update = GetImage(unitImage, "ammoPicInfoUpdate", size*0.8 - 4 - ICON_SIZE*1.3, ammoPic, ICON_SIZE*1.3, size - ICON_SIZE*1.3 - 4	)
			end
			if unitpicBadge1Update then
				unitpicBadge1Update(needRearm, IMAGE.NO_AMMO)
			end
			if unitpicBadge2Update then
				unitpicBadge2Update(true, ammoPic)
			end
			return
		end
		
		if reloadBar then
			reloadBar:SetVisibility(false)
		end
		if jumpBar then
			jumpBar:SetVisibility(false)
		end
		if unitpicBadge1Update then
			unitpicBadge1Update(false)
		end
		if unitpicBadge2Update then
			unitpicBadge2Update(false)
		end
		
		local totalHealth, totalMax = 0, 0
		for i = 1, #unitList do
			local health, maxhealth = spGetUnitHealth(unitList[i])
			if health and maxhealth then
				totalHealth = totalHealth + health
				totalMax = totalMax + maxhealth
			end
		end
		
		if totalMax > 0 then
			healthBar.color = GetHealthColor(totalHealth/totalMax)
			healthBar:SetValue(totalHealth/totalMax)
		end
	end
	
	local function UpdateUnitDefID(newUnitDefID)
		if newUnitDefID == unitDefID then
			return
		end
		unitDefID = newUnitDefID
		
		local ud = UnitDefs[unitDefID]
		if not ud then
			return
		end
		
		unitImage.tooltip = GetUnitSelectionTooltip(ud, unitDefID, unitID)
		unitImage.file = "#" .. unitDefID
		unitImage.file2 = GetUnitBorder(unitDefID)
		unitImage:Invalidate()
	end
	
	local function UpdateUnits(newUnitID, newUnitList)
		unitID = newUnitID
		unitList = newUnitList
		local newCount = (not unitID) and newUnitList and #newUnitList
		if newCount and newCount < 2 then
			newCount = false
		end
		if newCount == unitCount then
			return
		end
		unitCount = newCount
		
		groupLabel._relativeBounds.left = 0
		groupLabel._relativeBounds.right = 2
		groupLabel:SetCaption(unitCount or "")
	end
	
	local externalStuff = {
		visible = true
	}
	
	function externalStuff.SetPosition(x,y,size)
		holder:SetPos(x*size,y*size - SEL_BUTTON_SHORTENING*y,size,size)
	end
	
	function externalStuff.SetHidden()
		holder:SetVisibility(false)
		externalStuff.visible = false
	end
	
	function externalStuff.UpdateUnitButton()
		UpdateUnitInfo()
	end
	
	function externalStuff.SetGroupIconUnits(newUnitID, newUnitList, newUnitDefID)
		holder:SetVisibility(true)
		externalStuff.visible = true
		UpdateUnitDefID(newUnitDefID)
		UpdateUnits(newUnitID, newUnitList)
		UpdateUnitInfo()
	end
	
	function externalStuff.LanguageChange()
		if not unitDefID then
			return
		end

		local ud = UnitDefs[unitDefID]
		unitImage.tooltip = GetUnitSelectionTooltip(ud, unitDefID, unitID)
		unitImage:Invalidate()
	end

	return externalStuff
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Group info handler

local function GetSelectionStatsDisplay(parentControl)

	local holder = Chili.Control:New{
		name = "holder",
		y = 0,
		right = 0,
		bottom = 0,
		width = GROUP_STATS_WIDTH,
		padding = {0,0,0,0},
		parent = parentControl,
	}
	
	local selectedUnits
	local selectedUnitDefID = {}
	local visible = true
	
	local statLabel = Chili.Label:New{
		name = "statLabel",
		x = 0,
		y = 3,
		right = 0,
		valign  = 'top',
		objectOverrideFont = WG.GetFont(STATS_FONT),
		parent = holder,
	}
	
	local total_count = 0
	local total_finishedcost = 0
	local total_totalbp = 0
	local total_maxhp = 0
	local total_maxShield = 0
	local total_totalburst = 0
	local unreliableBurst = false
	local burstClass = 0
	
	local function UpdateDynamicGroupInfo()
		local total_cost = 0
		local total_hp = 0
		local total_shield = 0
		local total_metalincome = 0
		local total_metaldrain = 0
		local total_energyincome = 0
		local total_energydrain = 0
		local total_usedbp = 0
		
		local unitID, unitDefID, ud --micro optimization, avoiding repeated localization.
		local name, hp, paradam, cap, build, mm, mu, em, eu
		local stunned_or_inbuild
		for i = 1, total_count do
			unitID = selectedUnits[i]
			unitDefID = selectedUnitDefID[i]
			ud = unitDefID and UnitDefs[unitDefID]
			if ud then
				hp, _, paradam, cap, build = spGetUnitHealth(unitID)
				mm, mu, em, eu = GetUnitResources(unitID)
				
				if hp then
					total_cost = total_cost + GetUnitCost(unitID, unitDefID)*build
					total_hp = total_hp + hp
				end
				
				if maxShield[unitDefID] then
					local _, power = spGetUnitShieldState(unitID)
					total_shield = total_shield + (power or 0)
				end
				
				stunned_or_inbuild = spGetUnitIsStunned(unitID)
				if not stunned_or_inbuild then
					if mm then
						total_metalincome = total_metalincome + mm
						total_metaldrain = total_metaldrain + mu
						total_energyincome = total_energyincome + em
						total_energydrain = total_energydrain + eu
					end
					
					if ud.buildSpeed ~= 0 then
						local _, unhandicappedSpeed = GetUnitBuildSpeed(unitID, unitDefID)
						total_usedbp = total_usedbp + (GetCurrentBuildSpeed(unitID, unhandicappedSpeed) or 0)
					end
				end
			end
		end
		
		local unitInfoString = WG.Translate("interface", "selected_units") .. ": " .. Format(total_count) .. "\n" ..
			WG.Translate("interface", "value") .. ": " .. Format(total_cost) .. " / " ..  Format(total_finishedcost) .. "\n" ..
			WG.Translate("interface", "health") .. ": " .. Format(total_hp) .. " / " ..  Format(total_maxhp) .. "\n"
		
		if total_maxShield ~= 0 then
			unitInfoString = unitInfoString .. WG.Translate("interface", "shields") .. ": " .. Format(total_shield) .. " / " ..  Format(total_maxShield) .. "\n"
		end
		if total_totalbp ~= 0 then
			unitInfoString = unitInfoString ..
				WG.Translate("interface", "buildpower") .. ": " .. Format(total_usedbp) .. " / " .. Format(total_totalbp) .. "\n"
		end
		if total_metalincome ~= 0 or total_metaldrain ~= 0 or total_energyincome ~= 0 or total_energydrain ~= 0 then
			unitInfoString = unitInfoString ..
				WG.Translate("interface", "metal") .. ": " .. FormatPlusMinus(total_metalincome) .. white .. " / " ..  FormatPlusMinus(-total_metaldrain) .. white .. "\n" ..
				WG.Translate("interface", "energy") .. ": " .. FormatPlusMinus(total_energyincome) .. white .. " / " ..  FormatPlusMinus(-total_energydrain) .. white .. "\n"
		end
		if burstClass and total_totalburst ~= 0 then
			unitInfoString = unitInfoString ..
				WG.Translate("interface", "burst_damage") .. ": " .. ((unreliableBurst and "~") or "") .. Format(total_totalburst) .. "\n"
		end
		
		statLabel:SetCaption(unitInfoString)
	end
	
	--updates values that don't change over time for group info
	local function UpdateStaticGroupInfo()
		total_count = #selectedUnits
		total_finishedcost = 0
		total_totalbp = 0
		total_maxhp = 0
		total_maxShield = 0
		total_totalburst = 0
		unreliableBurst = false
		burstClass = 0
		
		local unitID, unitDefID
		for i = 1, total_count do
			unitID = selectedUnits[i]
			unitDefID = spGetUnitDefID(unitID)
			if unitDefID and not filterUnitDefIDs[unitDefID] then
				selectedUnitDefID[i] = unitDefID
				total_totalbp = total_totalbp + GetUnitBuildSpeed(unitID, unitDefID)
				total_maxhp = total_maxhp + (select(2, Spring.GetUnitHealth(unitID)) or 0)
				total_maxShield = total_maxShield + (maxShield[unitDefID] or 0)
				total_finishedcost = total_finishedcost + GetUnitCost(unitID, unitDefID)
				local burstData = UNIT_BURST_DAMAGES[unitDefID]
				if burstData and burstClass then
					if burstClass == 0 then
						burstClass = burstData.class
					end
					if burstClass == burstData.class then
						total_totalburst = total_totalburst + burstData.damage
						unreliableBurst = unreliableBurst or burstData.unreliable
					else
						burstClass = false
					end
				end
				
				global_totalBuildPower = total_totalbp
			end
		end

		total_totalburst = math.floor(total_totalburst / 10) * 10 -- round numbers are easier to parse and compare
		
		UpdateDynamicGroupInfo()
	end
	
	local externalFunctions = {}
	
	function externalFunctions.ChangeSelection(newSelection)
		selectedUnits = newSelection
		if visible and selectedUnits then
			UpdateStaticGroupInfo()
		end
	end
	
	function externalFunctions.UpdateStats()
		if visible and selectedUnits then
			UpdateDynamicGroupInfo()
		end
	end
	
	function externalFunctions.SetVisibile(newVisible)
		visible = newVisible
		holder:SetVisibility(newVisible)
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Group window

local function GetMultiUnitInfoPanel(parentControl)
	
	local holder = Chili.Control:New{
		x = 0,
		y = 0,
		right = GROUP_STATS_WIDTH,
		bottom = 0,
		padding = {-1,1,0,0},
		parent = parentControl,
	}
	
	local iconSize = options.uniticon_size.value
	local displayColumns = 5
	local displayRows = 3
	
	local displayUnits
	local displayButtons = {}
	
	local function UpdateButtonPosition(index)
		local col = (index - 1)%displayColumns
		local row = (index - 1 - col)/displayColumns
		displayButtons[index].SetPosition(col, row, iconSize)
	end
	
	local function GetButton(index)
		if not displayButtons[index] then
			displayButtons[index] = GetUnitGroupIconButton(holder)
			UpdateButtonPosition(index)
		end
		return displayButtons[index]
	end
	
	local function HideButtonsFromIndex(index)
		while displayButtons[index] and displayButtons[index].visible do
			displayButtons[index].SetHidden()
			index = index + 1
		end
	end
	
	local function Resize(self)
		local sizeX, sizeY = self.clientWidth, self.clientHeight
		
		local newIconSize = options.uniticon_size.value
		local newCols = math.floor(sizeX/iconSize)
		local newRows = math.floor(sizeY/(iconSize - SEL_BUTTON_SHORTENING))
		if newCols == displayColumns and newRows == displayRows and newIconSize == iconSize then
			return
		end
		iconSize = newIconSize
		displayColumns = newCols
		displayRows = newRows
		local displaySpace = displayRows*displayColumns
		
		local index = 1
		while displayButtons[index] and index <= displaySpace do
			UpdateButtonPosition(index)
			index = index + 1
		end
		HideButtonsFromIndex(displaySpace + 1)
	end
	holder.OnResize[#holder.OnResize + 1] = Resize
	
	local function StaticButtonUpdate(selectionSortOrder, displayUnitsByDefID)
		local displaySpace = displayRows*displayColumns
		
		local groupRequired = IsGroupingRequired(displayUnits, selectionSortOrder, displaySpace)
		local buttonIndex = 1
		for i = 1, #selectionSortOrder do
			if displaySpace < buttonIndex then
				return false
			end
			local unitDefID = selectionSortOrder[i]
			local unitList = displayUnitsByDefID[unitDefID]
			
			if groupRequired then
				local button = GetButton(buttonIndex)
				button.SetGroupIconUnits(nil, unitList, unitDefID)
				buttonIndex = buttonIndex + 1
			else
				for j = 1, #unitList do
					if displaySpace < buttonIndex then
						return false
					end
					local button = GetButton(buttonIndex)
					button.SetGroupIconUnits(unitList[j], unitList, unitDefID)
					buttonIndex = buttonIndex + 1
				end
			end
		end
		return buttonIndex
	end
	
	local function DynamicButtonUpdate()
		for i = 1, #displayButtons do
			local button = displayButtons[i]
			if button.visible then
				button.UpdateUnitButton()
			end
		end
	end
	
	local externalFunctions = {}
	
	function externalFunctions.UpdateUnitDisplay()
		if displayUnits then
			DynamicButtonUpdate()
		end
	end
	
	function externalFunctions.SetUnitDisplay(newDisplayUnits)
		if not newDisplayUnits then
			displayUnits = false
			holder:SetVisibility(false)
			return
		end
		holder:SetVisibility(true)
		
		displayUnits = newDisplayUnits
		local unitDefAdded = {}
		local displayUnitsByDefID = {}
		local selectionSortOrder = {}
		for i = 1, #displayUnits do
			local unitID = displayUnits[i]
			local unitDefID = spGetUnitDefID(unitID) or 0
			local byDefID = displayUnitsByDefID[unitDefID] or {}
			byDefID[#byDefID + 1] = unitID
			displayUnitsByDefID[unitDefID] = byDefID
			if not unitDefAdded[unitDefID] then
				selectionSortOrder[#selectionSortOrder + 1] = unitDefID
				unitDefAdded[unitDefID] = true
			end
		end
		
		table.sort(selectionSortOrder, UnitDefTableSort)
		
		local buttonIndex = StaticButtonUpdate(selectionSortOrder, displayUnitsByDefID)
		if buttonIndex then
			HideButtonsFromIndex(buttonIndex)
		end
	end
	
	function externalFunctions.SetRightPadding(newRightPadding)
		holder._relativeBounds.left = 0
		holder._relativeBounds.right = newRightPadding
		holder:UpdateClientArea()
	end
	
	function externalFunctions.SetIconSize(newIconSize)
		iconSize = newIconSize
		Resize(holder)
	end

	function externalFunctions.LanguageChange()
		for i = 1, #displayButtons do
			displayButtons[i].LanguageChange()
		end
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Unit tooltip window

local function GetSingleUnitInfoPanel(parentControl, isTooltipVersion)
	local selectedUnitID
	local endBarPosition = PIC_HEIGHT + 4 + BAR_SPACING + 32
	
	local leftPanel = Chili.Control:New{
		name = "leftPanel",
		x = 0,
		y = 0,
		width = LEFT_WIDTH,
		minWidth = LEFT_WIDTH,
		autosize = true,
		padding = {0,2,0,2},
		parent = parentControl,
	}
	local rightPanel = Chili.Control:New{
		name = "rightPanel",
		x = LEFT_WIDTH,
		y = 0,
		width = RIGHT_WIDTH,
		minWidth = RIGHT_WIDTH,
		autosize = true,
		padding = {2,2,0,2},
		parent = parentControl,
	}
	
	local reloadBar, jumpBar
	local unitImage = Chili.Image:New{
		name = "unitImage",
		x = 0,
		y = 0,
		right = 0,
		height = PIC_HEIGHT,
		keepAspect = false,
		file = imageFile,
		parent = leftPanel,
	}

	if not isTooltipVersion then
		unitImage.OnClick[#unitImage.OnClick + 1] = function(_,_,_,button)
			if not selectedUnitID then
				return false
			end
			local _, _, meta, _ = spGetModKeyState()
			if meta and (button == 1) and WG.MakeStatsWindow then  -- Space+Click - show unit stats
				local x, y = spGetMouseState()
				local ud = UnitDefs[spGetUnitDefID(selectedUnitID)]
				WG.MakeStatsWindow(ud, x, y, selectedUnitID)
				return true
			end
			local x,y,z = Spring.GetUnitPosition(selectedUnitID)
			SetCameraTarget(x, y, z, 1)
			return true
		end
	end
	
	local unitNameUpdate = GetImageWithText(rightPanel, "unitNameUpdate", 1, nil, nil, NAME_FONT, nil, 2, 1)
	
	local unitDesc = Chili.TextBox:New{
		name = "unitDesc",
		x = 4,
		y = 25,
		right = 0,
		height = BAR_SIZE,
		objectOverrideFont = WG.GetFont(DESC_FONT),
		parent = rightPanel,
	}
	
	local costInfoUpdate = GetImageWithText(leftPanel, "costInfoUpdate", PIC_HEIGHT + 4, IMAGE.COST, nil, nil, ICON_SIZE, 4)
	local metalInfoUpdate = GetImageWithText(leftPanel, "metalInfoUpdate", PIC_HEIGHT + LEFT_SPACE + 4, IMAGE.METAL, nil, nil, ICON_SIZE, 4)
	local energyInfoUpdate = GetImageWithText(leftPanel, "energyInfoUpdate", PIC_HEIGHT + 2*LEFT_SPACE + 4, IMAGE.ENERGY, nil, nil, ICON_SIZE, 4)
	local maxHealthLabel = GetImageWithText(rightPanel, "maxHealthLabel", PIC_HEIGHT + 4, IMAGE.HEALTH, nil, NAME_FONT, ICON_SIZE, 2, 2)
	
	local minWindLabel = GetImageWithText(leftPanel, "minWindLabel", PIC_HEIGHT + LEFT_SPACE + 4, IMAGE.WIND_SPEED, nil, nil, ICON_SIZE, 4)
	local healthBarUpdate = GetBarWithImage(rightPanel, "healthBarUpdate", PIC_HEIGHT + 4, IMAGE.HEALTH, {0, 1, 0, 1}, GetHealthColor)
	local unitpicBadge1Update = GetImage(unitImage, "costInfoUpdate", 4, IMAGE.NO_AMMO, ICON_SIZE, 4)
	local unitpicBadge2Update = GetImage(unitImage, "ammoPicInfoUpdate", PIC_HEIGHT - 4 - ICON_SIZE*1.3, IMAGE.NO_AMMO, ICON_SIZE*1.3, LEFT_WIDTH - ICON_SIZE*1.3 - 4)
	
	local metalInfo
	local energyInfo
	
	local spaceClickLabel, shieldBarUpdate, buildBarUpdate, costInfo, playerNameLabel
	if isTooltipVersion then
		playerNameLabel = Chili.Label:New{
			name = "playerNameLabel",
			x = 4,
			y = PIC_HEIGHT + 53,
			right = 0,
			height = BAR_FONT,
			objectOverrideFont = WG.GetFont(IMAGE_FONT),
			parent = rightPanel,
		}
		spaceClickLabel = Chili.Label:New{
			name = "spaceClickLabel",
			x = 4,
			y = PIC_HEIGHT + 73,
			right = 0,
			height = 18,
			objectOverrideFont = WG.GetFont(IMAGE_FONT),
			caption = green .. WG.Translate("interface", "space_click_show_stats"),
			parent = rightPanel,
		}
		costInfoPanel = GetCostInfoPanel(rightPanel, PIC_HEIGHT + 4)
		shieldBarUpdate = GetBarWithImage(rightPanel, "shieldBarUpdate", PIC_HEIGHT + 2, IMAGE.SHIELD, {0.3,0,0.9,1})
		buildProgressUpdate = GetBarWithImage(rightPanel, "buildProgress", PIC_HEIGHT + 2, IMAGE.BUILD, {0.8,0.8,0.2,1})
	else
		shieldBarUpdate = GetBarWithImage(rightPanel, "shieldBarUpdate", PIC_HEIGHT + 4, IMAGE.SHIELD, {0.3,0,0.9,1})
		buildBarUpdate = GetBarWithImage(rightPanel, "buildBarUpdate", PIC_HEIGHT + 58, IMAGE.BUILD, {0.8,0.8,0.2,1})
	end

	local prevUnitID, prevUnitDefID, prevFeatureID, prevFeatureDefID, prevVisible, prevMorphTime, prevMorphCost, prevMousePlace
	local externalFunctions = {}
		
	local function UpdateReloadTime(unitID, unitDefID)
		local reloadTime, weaponNum, rulesParam = GetManualFireReload(unitID, unitDefID)
		if reloadTime then
			reloadBar = UpdateManualFireReload(reloadBar, unitImage, unitID, weaponNum, rulesParam, reloadTime)
		elseif reloadBar then
			reloadBar:SetVisibility(false)
		end
		local jumpReloadTime = GetJumpReload(unitID, unitDefID)
		if jumpReloadTime then
			jumpBar = UpdateManualFireReload(jumpBar, unitImage, unitID, false, JUMP_RELOAD_PARAM, jumpReloadTime, true)
		elseif jumpBar then
			jumpBar:SetVisibility(false)
		end
	end

	local function UpdateDynamicUnitAttributes(unitID, unitDefID, ud)
		local mm, mu, em, eu = GetUnitResources(unitID)
		local showMetalInfo = false
		if mm then
			metalInfoUpdate(true, FormatPlusMinus(mm - mu), IMAGE.METAL, PIC_HEIGHT + LEFT_SPACE + 4)
			energyInfoUpdate(true, FormatPlusMinus(em - eu), IMAGE.ENERGY, PIC_HEIGHT + 2*LEFT_SPACE + 4)
			showMetalInfo = true
		else
			metalInfoUpdate(false)
			energyInfoUpdate(false)
		end
		minWindLabel(false)
		local health, maxHealth, _, _, progress = spGetUnitHealth(unitID)
		local healthPos = 0
		local hasShieldBar = false
		if shieldBarUpdate then
			if ud and ((ud.shieldPower or 0) > 0 or ud.level) then
				local shieldPower = spGetUnitRulesParam(unitID, "comm_shield_max") or ud.shieldPower
				local _, shieldCurrentPower = spGetUnitShieldState(unitID, -1)
				local wantBar = true
				if progress == nil or progress >= 1 then
					wantBar = false
				end
				if shieldCurrentPower and shieldPower then
					shieldBarUpdate(true, nil, shieldCurrentPower, shieldPower, (shieldCurrentPower < shieldPower) and GetUnitShieldRegenString(unitID, ud))
					endBarPosition = PIC_HEIGHT + 4 + BAR_SPACING + 32
					healthPos = PIC_HEIGHT + 4 + BAR_SPACING
					hasShieldBar = true
				end
			else
				shieldBarUpdate(false)
				healthPos = PIC_HEIGHT + 4
				endBarPosition = healthPos + BAR_SPACING
			end
		end
		
		if buildProgressUpdate and isTooltipVersion then
			progress = progress or 1 -- prevent nil error.
			if progress >= 1 then
				--Spring.Echo("Hide: " .. progress .. " " .. unitID)
				buildProgressUpdate(false) -- UpdateBar(visible, yPos, currentValue, maxValue, extraCaption, newCaption)
				if not hasShieldBar then
					endBarPosition = healthPos + BAR_SPACING
				end
			else
				--Spring.Echo("Show " .. unitID)
				progress = progress * 100
				buildProgressUpdate(true, nil, progress, 100, "", strFormat("%+.1f", progress) .. "% " .. builtTooltip)
				endBarPosition = PIC_HEIGHT + 4 + BAR_SPACING + 32
				healthPos = PIC_HEIGHT + 4 + BAR_SPACING
			end
		end
		if health and maxHealth then
			healthBarUpdate(true, healthPos, health, maxHealth, (health < maxHealth) and GetUnitRegenString(unitID, ud))
		end
		if buildBarUpdate then
			if ud and ud.buildSpeed > 0 then
				local metalMake, metalUse, energyMake,energyUse = Spring.GetUnitResources(unitID)
				
				local buildSpeed, unhandicappedSpeed = GetUnitBuildSpeed(unitID, unitDefID)
				local currentBuild = GetCurrentBuildSpeed(unitID, unhandicappedSpeed)
				buildBarUpdate(true, (healthPos or (PIC_HEIGHT + 4)) + BAR_SPACING, currentBuild or 0, buildSpeed)
			else
				buildBarUpdate(false)
			end
		end
		
		if dynamicTooltipDefs[unitDefID] then
			unitDesc:SetText(GetDescription(ud, unitID))
		end
		
		unitpicBadge1Update(GetUnitNeedRearm(unitID, unitDefID), IMAGE.NO_AMMO)
		local ammoPic = GetUnitAmmoPic(unitID, unitDefID)
		if ammoPic then
			unitpicBadge2Update(true, ammoPic)
		else
			unitpicBadge2Update(false)
		end
		
		UpdateReloadTime(unitID, unitDefID)
		if playerNameLabel then
			playerNameLabel:SetPos(nil, endBarPosition, nil, nil, nil, true)
			spaceClickLabel:SetPos(nil, endBarPosition + 14, nil, nil, nil, true)
		end
		
		return showMetalInfo
	end
	
	local function UpdateDynamicFeatureAttributes(featureID, unitDefID)
		local metal, metalMax, energy, energyMax, reclaimLeft = Spring.GetFeatureResources(featureID)
		local leftOffset = -2
		if unitDefID then
			leftOffset = PIC_HEIGHT + LEFT_SPACE
		end
		metalInfoUpdate(true, Format(metal), IMAGE.METAL_RECLAIM, leftOffset + 4)
		energyInfoUpdate(true, Format(energy), IMAGE.ENERGY_RECLAIM, leftOffset + LEFT_SPACE + 4)
		--local progress = math.max(metal/metalMax, energy/energyMax)
		if shieldBarUpdate then
			shieldBarUpdate(false)
		end
		if buildProgressUpdate then
			local value = 100 - (reclaimLeft * 100)
			buildProgressUpdate(true, nil, value, 100, "", value .. "% " .. reclaimedTooltip)
			if playerNameLabel then
				playerNameLabel:SetPos(nil, PIC_HEIGHT + 4 + BAR_SPACING, nil, nil, nil, true)
				spaceClickLabel:SetPos(nil, PIC_HEIGHT + 4 + BAR_SPACING + 14, nil, nil, nil, true)
			end
		end
	end
	
	local function UpdateDynamicEconInfo(unitDefID, mousePlaceX, mousePlaceY)
		local ud = UnitDefs[unitDefID]
		local extraTooltip, healthOverride
		if not (unitID or featureID) then
			extraTooltip, healthOverride, minWind = GetExtraBuildTooltipAndHealthOverride(unitDefID, mousePlaceX, mousePlaceY)
		end
		if extraTooltip then
			unitDesc:SetText(GetDescription(ud, unitID) .. extraTooltip)
		else
			unitDesc:SetText(GetDescription(ud, unitID))
		end
		unitDesc:Invalidate()
		
		if econStructureDefs[unitDefID].isWind then
			maxHealthLabel(true, healthOverride or ud.health, IMAGE.HEALTH)
			if mousePlaceX then
				minWindLabel(true, FormatPlusMinus(minWind), IMAGE.WIND_SPEED)
			else
				minWindLabel(false)
			end
		else
			minWindLabel(false)
		end
	end
	
	local function UpdateBuildTime(unitDefID, buildCost)
		if not costInfoPanel then
			return
		end
		if (global_totalBuildPower or 0) < 1 then
			costInfoPanel(true, "??")
			return
		end
		buildCost = buildCost or GetUnitCost(nil, unitDefID)
		if not buildCost then
			costInfoPanel(false)
			return
		end
		costInfoPanel(true, SecondsToMinutesSeconds(math.floor(buildCost/global_totalBuildPower)))
	end
	
	function externalFunctions.SetDisplay(unitID, unitDefID, featureID, featureDefID, blueprint, morphTime, morphCost, mousePlaceX, mousePlaceY, requiredOnly)
		local teamID
		local ud
		local metalInfoShown = false
		local maxHealthShown = false
		local morphShown = false
		local visible = IsUnitInLos(unitID)
		
		if prevUnitID == unitID and prevUnitDefID == unitDefID and prevFeatureID == featureID and prevFeatureDefID == featureDefID and
				prevVisible == visible and prevMorphTime == morphTime and prevMorphCost == morphCost and prevMousePlace == ((mousePlaceX and true) or false) then
			
			if not requiredOnly then
				if unitID and unitDefID and visible then
					UpdateDynamicUnitAttributes(unitID, unitDefID, UnitDefs[unitDefID])
				end
				if featureID then
					UpdateDynamicFeatureAttributes(featureID, prevUnitDefID)
				end
				if unitDefID and not (unitID or featureID) then
					if blueprint then
						UpdateBuildTime(unitDefID)
					end
					if econStructureDefs[unitDefID] then
						UpdateDynamicEconInfo(unitDefID, mousePlaceX, mousePlaceY)
					else
						minWindLabel(false)
					end
				end
			end
			return
		end
		
		if featureID then
			teamID = Spring.GetFeatureTeam(featureID)
			local featureTooltip, featureUnitDefID = GetFeatureDisplayAttributes(featureDefID)
			healthBarUpdate(false)
			minWindLabel(false)
			if featureUnitDefID then
				unitDefID = featureUnitDefID
				featureTooltip = featureTooltip or GetHumanName(UnitDefs[unitDefID], nil)
				unitNameUpdate(true, featureTooltip, GetUnitIcon(unitDefID))
				if playerNameLabel then
					playerNameLabel:SetPos(nil, PIC_HEIGHT + 8, nil, nil, nil, true)
					spaceClickLabel:SetPos(nil, PIC_HEIGHT + 32, nil, nil, nil, true)
				end
			else
				costInfoUpdate(false)
				unitNameUpdate(true, featureTooltip, nil)
				if playerNameLabel then
					playerNameLabel:SetPos(nil, PIC_HEIGHT - 13, nil, nil, nil, true)
					spaceClickLabel:SetPos(nil, PIC_HEIGHT + 12, nil, nil, nil, true)
				end
			end
			
			UpdateDynamicFeatureAttributes(featureID, featureUnitDefID)
			metalInfoShown = true
		end
		
		if unitDefID then
			ud = UnitDefs[unitDefID]

			if ud and not isTooltipVersion then
				unitImage.tooltip = GetSingleUnitSelectionTooltip(ud, unitDefID)
			end

			unitImage.file = "#" .. unitDefID
			unitImage.file2 = GetUnitBorder(unitDefID)
			unitImage:Invalidate()
			if unitID == nil and shieldBarUpdate then
				shieldBarUpdate(false)
			end
			if unitID == nil and buildProgressUpdate and not featureID then
				buildProgressUpdate(false)
			end
			local unitCost = math.floor(GetUnitCost(unitID, unitDefID) or 0)
			if featureID and UnitDefs[unitDefID].customParams.dynamic_comm then
				unitCost = Spring.GetFeatureRulesParam(featureID, "comm_cost") or 0
			end
			local smallCostDisplay = unitCost
			if smallCostDisplay >= 10000 then
				smallCostDisplay = math.floor(smallCostDisplay / 1000) .. "k"
			end
			costInfoUpdate(true, cyan .. smallCostDisplay, IMAGE.COST, PIC_HEIGHT + 4)
			
			local extraTooltip, healthOverride, minWind
			if not (unitID or featureID) then
				extraTooltip, healthOverride, minWind = GetExtraBuildTooltipAndHealthOverride(unitDefID, mousePlaceX, mousePlaceY)
			end
			if extraTooltip then
				unitDesc:SetText(GetDescription(ud, unitID) .. extraTooltip)
			else
				unitDesc:SetText(GetDescription(ud, unitID))
			end
			unitDesc:Invalidate()
			if not featureID then
				local unitName = GetHumanName(ud, unitID)
				unitNameUpdate(true, unitName, GetUnitIcon(unitDefID))
			end
			
			local unitName = GetHumanName(ud, unitID)
			unitNameUpdate(true, unitName, GetUnitIcon(unitDefID))
			
			if unitID then
				if playerNameLabel then
					playerNameLabel:SetPos(nil, endBarPosition, nil, nil, nil, true)
					spaceClickLabel:SetPos(nil, endBarPosition + 14, nil, nil, nil, true)
				end
			end
			if (not (unitID and visible)) and not featureDefID then
				healthBarUpdate(false)
				local maxHealthPos = PIC_HEIGHT + 4
				if blueprint and costInfoPanel then
					costInfoPanel(true, false, unitCost, "Cost:", nil, 46)
					UpdateBuildTime(unitDefID, unitCost)
					maxHealthPos = maxHealthPos + LEFT_SPACE
					if spaceClickLabel then
						spaceClickLabel:SetPos(nil, PIC_HEIGHT + LEFT_SPACE + 30, nil, nil, nil, true)
					end
				elseif morphTime and costInfoPanel then
					costInfoPanel(true, SecondsToMinutesSeconds(morphTime), morphCost, "Morph:", nil, 58)
					morphShown = true
					maxHealthPos = maxHealthPos + LEFT_SPACE
					if spaceClickLabel then
						spaceClickLabel:SetPos(nil, PIC_HEIGHT + LEFT_SPACE + 30, nil, nil, nil, true)
					end
				elseif spaceClickLabel and not unitID then
					spaceClickLabel:SetPos(nil, PIC_HEIGHT + 34, nil, nil, nil, true)
				end
				maxHealthShown = true
				maxHealthLabel(true, healthOverride or ud.health, IMAGE.HEALTH, maxHealthPos)
			end
		end
		
		if unitID then
			teamID = Spring.GetUnitTeam(unitID)
			if UpdateDynamicUnitAttributes(unitID, unitDefID, ud) then
				metalInfoShown = true
			end
			selectedUnitID = unitID
		else
			selectedUnitID = nil
			if reloadBar then
				reloadBar:SetVisibility(false)
			end
			if jumpBar then
				jumpBar:SetVisibility(false)
			end
		end
		
		if not metalInfoShown then
			metalInfoUpdate(false)
			energyInfoUpdate(false)
		end
		
		if playerNameLabel then
			local playerName = teamID and GetPlayerCaption(teamID)
			if playerName then
				playerNameLabel:SetCaption(playerName)
			end
			playerNameLabel:SetVisibility((playerName and true) or false)
		end
		
		local visibleUnitDefID = (unitDefID and true) or false
		unitImage:SetVisibility(visibleUnitDefID)
		unitDesc:SetVisibility(visibleUnitDefID)
		
		if spaceClickLabel then
			spaceClickLabel:SetVisibility(visibleUnitDefID)
		end
		
		if maxHealthLabel and not maxHealthShown then
			maxHealthLabel(false)
		end
		if costInfoPanel and not (morphShown or blueprint) then
			costInfoPanel(false)
		end
		
		prevUnitID, prevUnitDefID, prevFeatureID, prevFeatureDefID = unitID, unitDefID, featureID, featureDefID
		prevVisible = visible
		prevMorphTime, prevMorphCost, prevMousePlace = morphTime, morphCost, ((mousePlaceX and true) or false)
	end

	function externalFunctions.LanguageChange()
		if prevUnitDefID then
			local ud = UnitDefs[prevUnitDefID]
			unitDesc:SetText(GetDescription(ud, prevUnitID))
			unitDesc:Invalidate()

			local unitName = GetHumanName(ud, prevUnitID)
			unitNameUpdate(true, unitName, GetUnitIcon(prevUnitDefID))

			if not isTooltipVersion then
				unitImage.tooltip = GetSingleUnitSelectionTooltip(ud, prevUnitDefID)
				unitImage:Invalidate()
			elseif prevUnitID then
				local teamID = Spring.GetUnitTeam(prevUnitID)
				local playerName = teamID and GetPlayerCaption(teamID)
				if playerName then
					playerNameLabel:SetCaption(playerName)
				end
			end
		end
		if isTooltipVersion then
			spaceClickLabel:SetCaption(green .. WG.Translate("interface", "space_click_show_stats"))
		end
	end

	function externalFunctions.SetVisible(newVisible)
		leftPanel:SetVisibility(newVisible)
		rightPanel:SetVisibility(newVisible)
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tooltip window handler

local function GetTooltipWindow()
	local window = Chili.Window:New{
		name = "tooltipWindow",
		x = 300,
		y = 450,
		savespace = true,
		resizable = false,
		draggable = false,
		autosize  = true,
		minWidth = RIGHT_WIDTH,
		noFont = true,
		padding = {6,4,6,2},
		color = {1, 1, 1, options.tooltip_opacity.value},
		parent = screen0
	}
	window:Hide()
	
	local textTooltip = Chili.TextBox:New{
		name = "textTooltip",
		x = 0,
		y = 4,
		width = RIGHT_WIDTH - 10,
		height = 5,
		valign = "ascender",
		autoHeight = true,
		objectOverrideFont = WG.GetFont(TOOLTIP_FONT),
		parent = window,
	}
	textTooltip:SetVisibility(false)
	
	local unitDisplay = GetSingleUnitInfoPanel(window, true)
	
	local externalFunctions = {}
	
	function externalFunctions.LanguageChange()
		unitDisplay.LanguageChange()
	end

	function externalFunctions.SetVisible(newVisible)
		window:SetVisibility(newVisible)
	end

	function externalFunctions.SetOpacity(opacity)
		window.color[4] = opacity
		window:Invalidate()
	end
	
	function externalFunctions.SetPosition(x, y)
		y = screenHeight - y
		
		if x + window.width > screenWidth - 2 then
			x = screenWidth - window.width - 2
		end
		if y + window.height > screenHeight - 2 then
			y = screenHeight - window.height - 2
		end
		
		local map = WG.MinimapPosition
		if map then
			-- Only move tooltip up and/or left if it overlaps the minimap. This is because the
			-- minimap does not have tooltips.
			if x < map[1] + map[3] and y < map[2] + map[4] then
				local inX = x + window.width - map[1] + 2
				local inY = y + window.height - map[2] + 2
				if inX > 0 and inY > 0 then
					if inX > inY then
						y = y - inY
					else
						x = x - inX
					end
				end
			end
			
			if x + window.width > screenWidth - 2 then
				x = screenWidth - window.width - 2
			end
			if y + window.height > screenHeight - 2 then
				y = screenHeight - window.height - 2
			end
		end
		
		window:SetPos(x, y, nil, nil, nil, true)
		window:BringToFront()
	end
	
	function externalFunctions.SetTextTooltip(text)
		if text == "" then
			return false
		end
		textTooltip:SetText(text)
		textTooltip:Invalidate()
		textTooltip:SetVisibility(true)
		unitDisplay.SetVisible(false)
		return true
	end
	
	function externalFunctions.SetUnitishTooltip(unitID, unitDefID, featureID, featureDefID, blueprint, morphTime, morphCost, mousePlaceX, mousePlaceY, requiredOnly)
		if unitDefID or featureID or featureDefID then
			unitDisplay.SetDisplay(unitID, unitDefID, featureID, featureDefID, blueprint, morphTime, morphCost, mousePlaceX, mousePlaceY, requiredOnly)
			textTooltip:SetVisibility(false)
			unitDisplay.SetVisible(true)
		else
			externalFunctions.SetTextTooltip("Enemy unit")
		end
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tooltip updates

local function ShowUnitCheck(holdingSpace)
	if holdingSpace or options.show_for_units.value then
		return true
	end
end

local function ShowFeatureCheck(holdingSpace, featureDefID)
	if holdingSpace then
		return true
	end
	if options.show_for_wreckage.value then
		if options.show_for_unreclaimable.value then
			local fd = FeatureDefs[featureDefID]
			if not (fd and fd.reclaimable) then
				return false
			end
		end
		return true
	end
end

local function UpdateTooltipContent(mx, my, dt, requiredOnly)
	local holdingDrawKey = GetIsHoldingDrawKey()
	local holdingSpace = select(3, Spring.GetModKeyState()) and not Spring.IsUserWriting()
	UpdateMouseCursor(holdingDrawKey)
	
	if not (holdingSpace or (options.tooltip_delay.value == 0)) then
		local mouseMoved = (mx ~= oldMouseX or my ~= oldMouseY)
		if not mouseMoved then
			stillCursorTime = stillCursorTime + dt
			if stillCursorTime < options.tooltip_delay.value then
				return false
			end
		else
			stillCursorTime = 0
			oldMouseX = mx
			oldMouseY = my
			return false
		end
	end
	
	-- Mouseover build option tooltip (screen0.currentTooltip)
	local chiliTooltip = screen0.currentTooltip
	if chiliTooltip == NO_TOOLTIP then
		return false
	end
	
	if chiliTooltip and string.find(chiliTooltip, "BuildUnit") then
		local name = string.sub(chiliTooltip, 10)
		local ud = name and UnitDefNames[name]
		if ud then
			tooltipWindow.SetUnitishTooltip(nil, ud.id, nil, nil, true)
			return true
		end
	elseif chiliTooltip and string.find(chiliTooltip, "Build") then
		local name = string.sub(chiliTooltip, 6)
		local ud = name and UnitDefNames[name]
		if ud then
			tooltipWindow.SetUnitishTooltip(nil, ud.id, nil, nil, true)
			return true
		end
	end
	
	-- Mouseover morph tooltip (screen0.currentTooltip)
	if chiliTooltip and string.find(chiliTooltip, "Morph") then
		local unitDefID, morphTime, morphCost = chiliTooltip:match('(%d+) (%d+) (%d+)')
		if unitDefID and morphTime and morphCost then
			tooltipWindow.SetUnitishTooltip(nil, tonumber(unitDefID), nil, nil, false, tonumber(morphTime), tonumber(morphCost))
		end
		return true
	end
	
	-- Generic chili text tooltip
	if chiliTooltip then
		return tooltipWindow.SetTextTooltip(chiliTooltip)
	end
	
	-- Map drawing tooltip
	if holdingDrawKey and (holdingSpace or options.showdrawtooltip.value) then
		return tooltipWindow.SetTextTooltip(DRAWING_TOOLTIP)
	end
	
	-- Terraform tooltip (spring.GetActiveCommand)
	local index, cmdID, cmdType, cmdName = Spring.GetActiveCommand()
	if cmdID and terraCmdTip[cmdID] and (holdingSpace or options.showterratooltip.value) then
		return tooltipWindow.SetTextTooltip(terraCmdTip[cmdID])
	end
	
	-- Placing structure tooltip (spring.GetActiveCommand)
	if cmdID and cmdID < 0 then
		tooltipWindow.SetUnitishTooltip(nil, -cmdID, nil, nil, true, nil, nil, mx, my, requiredOnly)
		return true
	end
	
	if (not options.tooltipThroughPanels.value) and screen0.hoveredControl then
		return false
	end
	
	-- Unit or feature tooltip
	local thingType, thingID = spTraceScreenRay(mx,my)
	local thingIsUnit = (thingType == "unit")
	if thingIsUnit or (thingType == "feature") then
		local ignoreDelay = holdingSpace or (options.independant_world_tooltip_delay.value == 0)
		if ignoreDelay or (thingID == sameObjectID) then
			if ignoreDelay or (sameObjectIDTime > options.independant_world_tooltip_delay.value) then
				if thingIsUnit then
					local thingDefID = spGetUnitDefID(thingID)
					if ShowUnitCheck(holdingSpace) then
						tooltipWindow.SetUnitishTooltip(thingID, thingDefID, nil, nil, false, nil, nil, nil, nil, requiredOnly)
						return true
					end
				else
					local thingDefID = Spring.GetFeatureDefID(thingID)
					if ShowFeatureCheck(holdingSpace, thingDefID) then
						tooltipWindow.SetUnitishTooltip(nil, nil, thingID, thingDefID, false, nil, nil, nil, nil, requiredOnly)
						return true
					end
				end
			else
				sameObjectIDTime = sameObjectIDTime + dt
			end
		else
			sameObjectID = thingID
			sameObjectIDTime = 0
		end
	end
	
	-- Ground position tooltip (spGetCurrentTooltip())
	if holdingSpace then
		local springTooltip = Spring.GetCurrentTooltip()
		if springTooltip and string.find(springTooltip, "Terrain type:") then
			return tooltipWindow.SetTextTooltip(springTooltip)
		end
	end
	
	-- Start position tooltip (really bad widget interface)
	-- Don't want to implement this as is (pairs over positions registered in WG).
	
	-- Geothermal tooltip (WG.mouseAboveGeo)
	if WG.mouseAboveGeo then
		return tooltipWindow.SetTextTooltip(WG.Translate("interface", "geospot"))
	end
	
	return false
end

local function UpdateTooltip(dt, requiredOnly)
	local mx, my, _, _, _, outsideSpring = spScaledGetMouseState()
	local worldMx, worldMy = spGetMouseState()
	local visible = (not outsideSpring) and UpdateTooltipContent(worldMx, worldMy, dt, requiredOnly)
	tooltipWindow.SetVisible(visible)
	if visible then
		tooltipWindow.SetPosition(mx + 20/(WG.uiScale or 1), my - 20/(WG.uiScale or 1))
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Selection window handler

local function GetSelectionWindow()
	local integralWidth = math.max(350, math.min(450, screenWidth*screenHeight*0.0004))
	local integralHeight = math.min(screenHeight/4.5, 200*integralWidth/450)  + 8
	local x = integralWidth
	local visible = true
	local height = integralHeight*0.84

	local holderWindow = Chili.Window:New{
		name      = 'selections',
		x         = x,
		bottom    = 0,
		width     = 450,
		height    = height,
        minWidth  = 450,
		minHeight = 120,
		bringToFrontOnClick = false,
		dockable  = true,
		draggable = false,
		resizable = false,
		tweakDraggable = true,
		tweakResizable = true,
		noFont = true,
		padding = {0, 0, 0, -1},
		color = {0, 0, 0, 0},
		parent = screen0,
	}
	holderWindow:SendToBack()
	
	local mainPanel = Chili.Panel:New{
		name = "mainPanel",
		classname = options.fancySkinning.value,
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {8, 4, 4, 2},
		backgroundColor = {1, 1, 1, options.selection_opacity.value},
		OnClick = {
			function(self)
				local _,_, meta,_ = spGetModKeyState()
				if not meta then
					return false
				end
				WG.crude.OpenPath(selPath)
				WG.crude.ShowMenu()
				return true --skip button function, else clicking on build pic will also select the unit.
			end
		},
		noClickThrough = not options.allowclickthrough.value,
		parent = holderWindow
	}
	mainPanel.padding[1] = mainPanel.padding[1] + options.leftPadding.value
	mainPanel:Hide()
	
	local singleUnitDisplay = GetSingleUnitInfoPanel(mainPanel, false)
	local multiUnitDisplay = GetMultiUnitInfoPanel(mainPanel)
	local selectionStatsDisplay = GetSelectionStatsDisplay(mainPanel)
	local singleUnitID, singleUnitDefID
	
	local externalFunctions = {}
	
	function externalFunctions.LanguageChange()
		singleUnitDisplay.LanguageChange()
		multiUnitDisplay.LanguageChange()
	end

	function externalFunctions.ShowSingleUnit(unitID)
		singleUnitID, singleUnitDefID = unitID, spGetUnitDefID(unitID)
		singleUnitDisplay.SetDisplay(unitID, spGetUnitDefID(unitID))
		singleUnitDisplay.SetVisible(true)
		multiUnitDisplay.SetUnitDisplay()
		selectionStatsDisplay.ChangeSelection({unitID})
	end
	
	function externalFunctions.ShowMultiUnit(newSelection)
		singleUnitID = nil
		multiUnitDisplay.SetUnitDisplay(newSelection)
		singleUnitDisplay.SetVisible(false)
		selectionStatsDisplay.ChangeSelection(newSelection)
	end
	
	function externalFunctions.UpdateSelectionWindow()
		if not visible then
			return
		end
		if singleUnitID then
			singleUnitDisplay.SetDisplay(singleUnitID, singleUnitDefID)
		else
			multiUnitDisplay.UpdateUnitDisplay()
		end
		selectionStatsDisplay.UpdateStats()
	end
	
	function externalFunctions.SetVisible(newVisible)
		if not newVisible then
			singleUnitID = nil
		end
		visible = newVisible
		mainPanel:SetVisibility(newVisible)
		singleUnitDisplay.SetVisible(false)
		multiUnitDisplay.SetUnitDisplay(false)
	end
	
	function externalFunctions.SetOpacity(opacity)
		mainPanel.backgroundColor = {1,1,1,opacity}
		mainPanel:Invalidate()
	end
	
	function externalFunctions.SetSkin(className)
		SetPanelSkin(mainPanel, className)
	end
	
	function externalFunctions.SetLeftPadding(padding)
		mainPanel.padding[1] = 8 + padding
		mainPanel:UpdateClientArea()
	end
	
	function externalFunctions.SetAllowClickThrough(allowClickThrough)
		mainPanel.noClickThrough = not allowClickThrough
	end
	
	function externalFunctions.SetGroupInfoVisible(newVisible)
		local rightPadding = newVisible and GROUP_STATS_WIDTH or 0
		multiUnitDisplay.SetRightPadding(rightPadding)
		selectionStatsDisplay.SetVisibile(newVisible)
	end
	
	function externalFunctions.SetSelectionIconSize(iconSize)
		multiUnitDisplay.SetIconSize(iconSize)
	end
	
	-- Initialization
	externalFunctions.SetGroupInfoVisible(options.showgroupinfo.value)
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Selection update

local function UpdateSelection(newSelection)
	-- Check if selection is 0, hide window. Return
	-- Check if selection is 1, get unit tooltip
	-- Check if selection is many, get unit list tooltip
	-- Update group info.
	
	selectedUnitsList = newSelection
	
	if (not newSelection) or (#newSelection == 0) then
		selectionWindow.SetVisible(false)
		return
	end
	
	selectionWindow.SetVisible(true)
	if #newSelection == 1 then
		selectionWindow.ShowSingleUnit(newSelection[1])
	else
		selectionWindow.ShowMultiUnit(newSelection)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local function InitializeWindParameters()
	windMin = spGetGameRulesParam("WindMin")
	windMax = spGetGameRulesParam("WindMax")
	windGroundMin = spGetGameRulesParam("WindGroundMin")
	windGroundSlope = spGetGameRulesParam("WindSlope")
	windMinBound = spGetGameRulesParam("WindMinBound")
	tidalHeight = Spring.GetGameRulesParam("tidalHeight")
	econMultEnabled = (Spring.GetGameRulesParam("econ_mult_enabled") and true) or false
end

local updateTimer = 0
function widget:Update(dt)
	updateTimer = updateTimer + dt
	local slowUpdate = updateTimer > UPDATE_FREQUENCY
	UpdateTooltip(dt, not slowUpdate)
	
	if slowUpdate then
		selectionWindow.UpdateSelectionWindow()
		updateTimer = 0
	end
end

function widget:KeyRelease(key, modifier, isRepeat)
	if (key == KEYSYMS.LCTRL or key == KEYSYMS.RCTRL) then
		CheckCtrlFilterRelease()
	end
end

function widget:SelectionChanged(newSelection)
	UpdateSelection(newSelection)
end

function widget:ViewResize(vsx, vsy)
	screenWidth = vsx/(WG.uiScale or 1)
	screenHeight = vsy/(WG.uiScale or 1)
end

function widget:Initialize()
	Chili = WG.Chili
	screen0 = Chili.Screen0
	
	Spring.AssignMouseCursor(CURSOR_ERASE_NAME, CURSOR_ERASE, true, false) -- Hotspot center.
	Spring.AssignMouseCursor(CURSOR_POINT_NAME, CURSOR_POINT, true, true)
	Spring.AssignMouseCursor(CURSOR_DRAW_NAME, CURSOR_DRAW, true, true)
	
	Spring.SendCommands({"tooltip 0"})
	Spring.SetDrawSelectionInfo(false)
	
	local hotkeys = WG.crude.GetHotkeys("drawinmap")
	for k,v in pairs(hotkeys) do
		drawHotkeyBytesCount = drawHotkeyBytesCount + 1
		drawHotkeyBytes[drawHotkeyBytesCount] = v:byte(-1)
	end
	
	selectionWindow = GetSelectionWindow()
	tooltipWindow = (WG.Modding_TooltipOverride and WG.Modding_TooltipOverride()) or GetTooltipWindow()
	InitializeWindParameters()

	local function LanguageUpdate()
		singleSelectionTooltip = "\n" ..
			green .. WG.Translate("interface", "lmb") .. ": " .. "Center view" .. "\n" ..
			green .. WG.Translate("interface", "space_click_show_stats")
		--selectionTooltip = "\n" ..
		--	green .. WG.Translate("interface", "lmb") .. ": " .. WG.Translate("interface", "select") .. "\n" ..
		--	green .. WG.Translate("interface", "rmb") .. ": " .. WG.Translate("interface", "deselect") .. "\n" ..
		--	green .. WG.Translate("interface", "shift") .. "+" .. WG.Translate("interface", "lmb") .. ": " .. WG.Translate("interface", "select_type") .. "\n" ..
		--	green .. WG.Translate("interface", "shift") .. "+" .. WG.Translate("interface", "rmb") .. ": " .. WG.Translate("interface", "deselect_type") .. "\n" ..
		--	green .. WG.Translate("interface", "alt") .. "+" .. WG.Translate("interface", "lmb") .. ": " .. WG.Translate("interface", "select_type_half") .. "\n" ..
		--	green .. WG.Translate("interface", "alt") .. "+" .. WG.Translate("interface", "rmb") .. ": " .. WG.Translate("interface", "deselect_type_half") .. "\n" ..
		--	green .. WG.Translate("interface", "ctrl") .. "+" .. WG.Translate("interface", "lmb") .. ": " .. WG.Translate("interface", "defer_selection") .. "\n" ..
		--	green .. WG.Translate("interface", "mmb") .. ": " .. WG.Translate("interface", "go_to") .. "\n" ..
		--	green .. WG.Translate("interface", "space_click_show_stats")

		selectionTooltip = "\n" ..
			green .. WG.Translate("interface", "lmb")   .. ": " .. WG.Translate("interface", "select") .. "\n" ..
			green .. WG.Translate("interface", "rmb")   .. ": " .. WG.Translate("interface", "deselect") .. "\n" ..
			green .. "+ " .. WG.Translate("interface", "shift") .. ": " .. WG.Translate("interface", "select_type") .. "\n" ..
			green .. "+ " .. WG.Translate("interface", "alt")   .. ": " .. WG.Translate("interface", "select_type_half") .. "\n" ..
			green .. "+ " .. WG.Translate("interface", "ctrl")  .. ": " .. WG.Translate("interface", "defer_selection") .. "\n" ..
			green .. WG.Translate("interface", "mmb")   .. ": " .. WG.Translate("interface", "go_to") .. "\n" ..
			green .. WG.Translate("interface", "space_click_show_stats")
		reclaimedTooltip = WG.Translate("interface", "reclaimed")
		builtTooltip = WG.Translate("interface", "build_progress")
		unitSelectionTooltipCache = {}
		unitSingleSelectionTooltipCache = {}
		terraformGeneralTip = ""
		for i = 1, 4 do
			local str = green .. WG.Translate("interface", "terratooltip_" .. i)
			local injectLocation = string.find(str, ":")
			terraformGeneralTip = terraformGeneralTip .. string.sub(str, 1, injectLocation - 1) .. white .. string.sub(str, injectLocation) .. "\n"
		end
		if tooltipWindow.LanguageChange then
			tooltipWindow.LanguageChange()
		end
		selectionWindow.LanguageChange()
	end

	LanguageUpdate()
	WG.InitializeTranslation(LanguageUpdate, "gui_chili_selections_and_cursortip.lua")
end

function widget:UnitDestroyed(unitID)
	if commanderManualFireReload[unitID] then
		commanderManualFireReload[unitID] = nil
	end
end

function widget:Shutdown()
	WG.ShutdownTranslation("gui_chili_selections_and_cursortip.lua")
	Spring.SendCommands({"tooltip 1"})
	Spring.SetDrawSelectionInfo(true)
	Spring.SetDrawSelectionInfo(true)
end
