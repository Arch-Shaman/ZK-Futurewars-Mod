--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "Chili Commander Upgrade",
    desc      = "Interface for commander upgrade selection.",
    author    = "GoogleFrog",
    date      = "29 December 2015",
    license   = "GNU GPL, v2 or later",
	handler   = true,
    layer     = -10,
    enabled   = true
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

include("colors.lua")
VFS.Include("LuaRules/Configs/constants.lua")
local CMD_MORPH_UPGRADE_INTERNAL = Spring.Utilities.CMD.MORPH_UPGRADE_INTERNAL
local CMD_UPGRADE_UNIT = Spring.Utilities.CMD.UPGRADE_UNIT

local Chili
local Button
local Label
local Window
local Panel
local StackPanel
local LayoutPanel
local Image
local screen0
local topLabel
local morphRateLabel

local localization = {}

local HP_MULT = 1
if (Spring.GetModOptions) then
	local modOptions = Spring.GetModOptions()
    if modOptions then
        if modOptions.hpmult and modOptions.hpmult ~= 1 then
            HP_MULT = modOptions.hpmult
        end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Most things are local to their own code block. These blocks are (in order)
-- * Replacement Button Handler. This creates and keeps track of buttons
--   which appear in the replacement window.
-- * Replacement Window Handler. This creates and updates the window which holds
--   the replacement buttons.
-- * Current Module Tracker. This does not directly control Chili. This block of
--   code keeps track of the data behind the modules system. This includes a
--   list of current modules and functions for getting the replacementSet and
--   whether a module choice is still valid.
-- * Main Button Handler. This updates the module selection buttons and keeps
--   click functions and restrictions.
-- * Main Window Handler. This handles the main chili window. Will handle
--   acceptance and rejection of the current module setup.
-- * Command Handling. Handles command displaying and issuing to the upgradable
--   units.
-- * Callins. This block handles widget callins. Does barely anything.

-- Module config
local moduleDefs, chassisDefs, upgradeUtilities, LEVEL_BOUND, _, moduleDefNames = VFS.Include("LuaRules/Configs/dynamic_comm_defs.lua")
WG.ModuleTranslations = {} -- Store these so we can use them in Context Menu as well as the comm upgrade one.
local nullweapon = moduleDefNames["nullbasicweapon"]
local nulladvweapon = moduleDefNames["nulladvweapon"]

-- Configurable things, possible to add to Epic Menu later.
local BUTTON_SIZE = 55
local ROW_COUNT = 6

-- Index of module which is selected for the purposes of replacement.
local activeSlotIndex

-- Whether already owned modules are shown
local alreadyOwnedShown = false

-- StackPanel containing the buttons for the current list of modules
local currentModuleList

-- Button for viewing owned modules
local viewAlreadyOwnedButton

local moduleTextColor = {.8,.8,.8,.9}

local damageBooster = 1
local rangeBooster = 1
local morphBuildPower = 0.1

local commanderUnitDefID = {}
for i = 1, #UnitDefs do
	if UnitDefs[i].customParams.dynamic_comm then
		commanderUnitDefID[i] = true
	end
end

-- Nullweapon and Nulladvweapon are both technical junk that users should NOT see in FW. Probably in base game too?
local defaultweapons = {
	[1] = "commweapon_heavyrifle", -- strike
	[2] = "commweapon_heatray", -- recon
	[3] = "commweapon_beamlaser", -- support
	[4] = "commweapon_rocketbarrage", -- bombard
	[5] = "commweapon_heavymachinegun", -- riot
	[6] = "commweapon_beamlaser", -- knight (presumably?)
	[7] = "commweapon_heavymachinegun", -- riot
}

local UPGRADE_CMD_DESC = {
	id      = CMD_UPGRADE_UNIT,
	type    = CMDTYPE.ICON,
	tooltip = 'Upgrade Commander',
	cursor  = 'Repair',
	action  = 'upgradecomm',
	params  = {},
	texture = 'LuaUI/Images/commands/Bold/upgrade.png',
}

-- IN8N
local needsExtraHelp = {
	["module_heavy_armor"] = true,
	["module_fireproofing"] = true,
	["module_high_power_servos_improved"] = true,
	["module_cloakregen"] = true,
}

local translationOverrides = {
	["module_heavyprojector_second"] = "module_heavyprojector",
	["module_shotgunlaser_second"] = "module_shotgunlaser",
	["module_heavyordinance_second"] = "module_heavyordinance",
	["module_heavy_barrel2"] = "module_heavy_barrel",
	["nulladvweapon"] = "nullbasicweapon",
}

local weaponTemplate, shieldTemplate, aoeTemplate, waterCapableTemplate
local acceptText, cancelText, viewText

local function GetWeaponTemplate()
	weaponTemplate = "\n\255\255\061\061" .. WG.Translate("interface", "module_weapon_notes") .. ":\n\255\255\255\031- " .. WG.Translate("interface", "stats_range") .. ":\255\255\255\255_range_"
	weaponTemplate = weaponTemplate .. "\n\255\255\255\031- " .. WG.Translate("interface", "acronyms_dps") ..  ":\255\255\255\255_dps_\n"
	shieldTemplate = "\n\255\255\255\031" .. WG.Translate("interface", "shield_hp") ..  ":\255\255\255\255 %shield_hp% " ..  WG.Translate("interface", "health") .. "\n\255\255\255\031" .. WG.Translate("interface", "regen") .. ":\255\255\255\255 %shieldregen% " .. WG.Translate("interface", "health") .. " / " .. WG.Translate("interface", "acronyms_second") .. "\n\255\255\255\031"  .. WG.Translate("interface", "shield_regencost") .. ": \255\255\255\255 %shieldregencost%" .. " " .. string.lower(WG.Translate("interface", "energy")) .. " / " .. WG.Translate("interface", "acronyms_second") .. "\n\255\255\255\031" .. WG.Translate("interface", "radius") .. ":\255\255\255\255 %radius%"
	aoeTemplate = "\n\255\255\255\031- " .. WG.Translate("interface", "stats_aoe") .. ":\255\255\255\255 _aoe_\n"
	waterCapableTemplate = "\n\255\255\255\031- \255\031\255\255" .. WG.Translate("interface", "weapon_water_capable") .. "\255\255\255\255"
end

local function GetTimeString(val)
	if val < 60 then return string.format("00:%02d", val) end
	local seconds = val%60
	local minutes = (val - seconds) / 60
	local hours = 0
	if minutes > 60 then
		hours = math.floor(minutes / 60)
		minutes = minutes % 60
		if hours < 10 then hours = "0" .. hours end
	end
	if hours > 0 then
		return hours .. string.format(":%02d:02d", minutes, seconds)
	else
		return string.format("%02d:%02d", minutes, seconds)
	end
end

local function comma_value(amount)
	local formatted = amount .. ''
	local k
	while true do
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

local function OnLocaleChanged()
	acceptText = WG.Translate("interface", "commupgrade_accept")
	cancelText = WG.Translate("interface", "commupgrade_cancel")
	viewText   = WG.Translate("interface", "commupgrade_view")
	if topLabel then
		topLabel:SetCaption(WG.Translate("interface", "modules"))
	end
	local cost = WG.Translate("interface", "commodule_cost")
	local limit = WG.Translate("interface", "commodule_limit")
	local hp = WG.Translate("interface", "acronyms_hp")
	local sec = WG.Translate("interface", "acronyms_second")
	GetWeaponTemplate() -- reduce the number of translations we need to do.
	for internalName, translation in pairs(WG.ModuleTranslations) do
		local def = moduleDefs[moduleDefNames[internalName]]
		local name
		--spring.echo("Translating " .. internalName)
		if translationOverrides[internalName] then
			name = WG.Translate("interface", translationOverrides[internalName] .. "_name")
			--spring.echo("Overriding " .. internalName .. " -> " .. translationOverrides[internalName] .. ": '" .. tostring(name) .. "'")
		else
			--spring.echo("No override needed")
			name = WG.Translate("interface", internalName .. "_name")
		end
		if not name then
			name = def.humanName .. " (\255\255\061\061ERROR: MISSING LOCALIZATION! REPORT THIS!\255\255\255\031)"
		end
		WG.ModuleTranslations[internalName].name = name
		local descStringName = internalName .. "_desc"
		local desc = name .. "\n" .. cost .. comma_value(def.cost or 0)
		if def.cost > 0 then desc = desc .. " [+_time_]" end
		desc = desc .. "\n"
		if def.slotType ~= "basic_weapon" and def.slotType ~= "adv_weapon" then
			desc = desc .. limit .. ": "
			local moduleLimit = def.limit
			if moduleLimit then
				desc = desc .. moduleLimit .. "\n\n"
			else
				desc = desc .. "∞\n\n"
			end
		end
		if internalName == "module_detpack" then
			desc = desc .. "\n" .. WG.Translate("interface", descStringName, {health = 1000*HP_MULT})
		elseif internalName == "module_autorepair" then
			desc = desc .. "\n" .. WG.Translate("interface", descStringName, {health = 20*HP_MULT .. hp .. "/" .. sec})
		elseif internalName == "module_nanorepair_upgrade_regen" then
			desc = desc .. "\n" .. WG.Translate("interface", descStringName, {regen_mult = 3 * HP_MULT, max_regen = 30 * HP_MULT, max_health = 500 * HP_MULT})
		elseif internalName == "module_ablative_armor" then
			desc = desc .. "\n" .. WG.Translate("interface", descStringName, {health = 1200 * HP_MULT})
		elseif internalName == "module_heavy_armor" then
			desc = desc .. "\n" .. WG.Translate("interface", descStringName, {health = 4000 * HP_MULT})
		elseif internalName == "module_fireproofing" then
			desc = desc .. "\n" .. WG.Translate("interface", descStringName, {health = 550 * HP_MULT})
		elseif internalName == "module_high_power_servos_improved" then
			desc = desc .. "\n" .. WG.Translate("interface", descStringName, {health = 500*HP_MULT})
		elseif internalName == "module_cloakregen" then
			desc = desc .. "\n" ..  WG.Translate("interface", descStringName, {health = 20*HP_MULT .. " " .. hp .. "/" .. sec})
		else
			if translationOverrides[internalName] then
				desc = desc .. "\n" .. WG.Translate("interface", translationOverrides[internalName] .. "_desc")
			else
				desc = desc .. "\n" .. WG.Translate("interface", internalName .. "_desc")
			end
		end
		if def.slotType == "basic_weapon" or def.slotType == "adv_weapon" then -- add stats
			local wd
			if internalName == "commweapon_heatray_recon" then
				wd = WeaponDefNames["0_commweapon_heatray"]
			else
				wd = WeaponDefNames["0_" .. internalName]
			end
			desc = desc .. weaponTemplate
			if wd then
				if not wd.impactOnly then
					desc = desc .. "\n" .. aoeTemplate
					desc = desc:gsub("_aoe_", wd.damageAreaOfEffect)
				end
				if wd.waterWeapon then
					desc = desc .. waterCapableTemplate
				end
			else
				--spring.echo("Unable to load " .. internalName .. " weaponDef, skipping")
			end
		elseif internalName:find("shield") then
			desc = desc .. shieldTemplate
		end
		translation.desc = desc
		--Spring.Echo("Done. " .. internalName .. " : " .. tostring(desc))
	end
	--spring.echo("Finished setting up translation")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- New Module Selection Button Handling

local newButtons = {}

local function GetModuleDescription(moduleData) -- dynamically updated.
	local isShield = moduleData.name:find("shield") ~= nil
	local costTime = moduleData.cost / morphBuildPower
	local name = moduleData.name
	local description = WG.ModuleTranslations[name].desc:gsub("_time_", GetTimeString(costTime))
	if moduleData.slotType == "module" and not isShield then
		return description
	else -- dynamically generated.
		if not isShield then
			--spring.echo("GetModuleDescription::InternalName: " .. tostring(name))
			local wd
			if name == "commweapon_heatray_recon" then
				wd = WeaponDefNames["0_commweapon_heatray"]
			else
				wd = WeaponDefNames["0_" .. name]
			end
			if wd then
				local aoe = wd.damageAreaOfEffect
				local reload = wd.reload
				local customparams = wd.customParams or wd.customparams or {}
				local extradps = "" -- damagemult, rangemult
				local dps = ""
				local projectiles = wd.projectiles or 1
				local burst = wd.salvoSize or 1
				local damage = wd.damages[1] * burst * projectiles 
				if customparams.extra_damage_mult then -- emp
					--spring.echo("EMP")
					local extradmg = tonumber(customparams.extra_damage_mult) or 0
					local empdps = (extradmg * damage * damageBooster) / reload
					extradps = extradps .. "\255\51\179\255" .. string.format("%.1f", empdps) .. "P\255\255\255\255"
				end
				--spring.echo("EMP: " .. extradps)
				if customparams.is_capture then
					local capture = " \255\153\255\153" .. string.format("%.1f", damage * damageBooster / reload) .. WG.Translate("interface", "acronyms_capture") .. "\255\255\255\255"
					if extradps == "" then
						extradps = capture
					else
						extradps = extradps .. " \255\255\255\031+" .. capture
					end
				end
				if customparams.timeslow_damagefactor or customparams.timeslow_onlyslow then
					local factor = tonumber(customparams.timeslow_damagefactor) or 0
					if factor * damage > 0 then
						local slow = damage * damageBooster * factor
						local slowstr = "\255\230\51\255" .. string.format("%.1f", slow) .. WG.Translate("interface", "acronyms_slow") .. "\255\255\255\255"
						if extradps == "" then
							extradps = slowstr
						else
							extradps = extradps .. "\255\255\255\031+ " .. slowstr
						end
					end
				end
				if customparams.disarmDamageOnly or customparams.disarmdamageonly then
					local disarm = "\255\128\128\128" .. string.format("%.1f", damage * damageBooster / reload) .. WG.Translate("interface", "acronyms_disarm") .. "\255\255\255\255"
					if extradps ~= "" then
						extradps = extradps .. " \255\255\255\031+\255\128\128\128 " .. disarm
					else
						extradps = disarm
					end
				end
				--spring.echo("Disarm: " .. extradps)
				if wd.paralyzeTime == nil and wd.paralyzetime == nil then
					if not customparams.disarmDamageOnly and not customparams.disarmdamageonly and not customparams.timeslow_onlyslow then
						dps = "\255\255\255\255 " .. string.format("%.1f", damage * damageBooster / reload)
					end
				else
					dps = "\255\51\179\255 " .. string.format("%.1f", damage * damageBooster / reload) .. "P"
				end
				--spring.echo("Final: " .. extradps)
				if extradps ~= "" and dps ~= "" then
					description = string.gsub(description, "_dps_", dps .. "(" .. extradps .. ")")
				elseif dps == "" then
					description = string.gsub(description, "_dps_", extradps)
				else
					description = string.gsub(description, "_dps_", dps)
				end
				description = string.gsub(description, "_dps_", extradps .. dps)
				description = string.gsub(description, "_range_", wd.range * rangeBooster)
				if customparams.setunitsonfire then
					local burntime = tonumber(customparams.burntime) or 0
					burntime = burntime / 30 -- convert to seconds
					description = description .. "\255\255\77\0 " .. string.format("%.1f", damage * damageBooster / reload) .. " (" .. string.format("%.1f", burntime) .. WG.Translate("interface", "acronyms_second") .. ")"
				end
				if aoe > 16 and not wd.impactOnly then
					description = description:gsub("_aoe_", aoe)
				end
				return description:gsub("_time_", GetTimeString(costTime))
			else
				--spring.echo("Failed to load weapondef for " .. moduleData.name)
			end
		else -- this is a shield.
			local wd = WeaponDefNames["0_" .. name]
			local cp = wd.customParams
			local shieldHealth = comma_value(wd.shieldPower)
			local regenCost = comma_value(cp.shield_drain or 0)
			local shieldRegen = comma_value(cp.shield_rate or 0)
			local radius = comma_value(wd.shieldRadius)
			return description:gsub("%%shieldregen%%", shieldRegen):gsub("%%shieldregencost%%", regenCost):gsub("%%shield_hp%%", shieldHealth):gsub("%%radius%%", radius)
		end
	end
end

local function AddNewSelectonButton(buttonIndex, moduleDefID)
	local moduleData = moduleDefs[moduleDefID]
	local newButton = Button:New{
		caption = "",
		width = BUTTON_SIZE,
		minHeight = BUTTON_SIZE,
		padding = {0, 0, 0, 0},
		OnClick = {
			function(self)
				SelectNewModule(self.moduleDefID)
			end
		},
		backgroundColor = {0.5,0.5,0.5,0.1},
		color = {1,1,1,0.1},
		tooltip = GetModuleDescription(moduleData)
	}

	Image:New{
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		keepAspect = true,
		file = moduleData.image,
		parent = newButton,
	}
	
	newButton.moduleDefID = moduleDefID
	
	newButtons[buttonIndex] = newButton
end

local function UpdateNewSelectionButton(buttonIndex, moduleDefID)
	local moduleData = moduleDefs[moduleDefID]
	local button = newButtons[buttonIndex]
	button.tooltip = GetModuleDescription(moduleData) 
	button.moduleDefID = moduleDefID
	button.children[1].file = moduleData.image
	button.children[1]:Invalidate()
	return button
end

local function GetNewSelectionButton(buttonIndex, moduleDefID)
	if newButtons[buttonIndex] then
		UpdateNewSelectionButton(buttonIndex, moduleDefID)
	else
		AddNewSelectonButton(buttonIndex, moduleDefID)
	end
	return newButtons[buttonIndex]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Selection Window Handling

local selectionWindow

local function CreateModuleSelectionWindow()
	local selectionButtonPanel = LayoutPanel:New{
		x = 0,
		y = 0,
		right = 0,
		orientation = "vertical",
		columns = 7,
		--width  = "100%",
		height = "100%",
		backgroundColor = {1,1,1,1},
		color = {1,1,1,1},
		--children = buttons,
		itemPadding = {0,0,0,0},
		itemMargin  = {0,0,0,0},
		resizeItems = false,
		centerItems = false,
		autosize = true,
	}
	
	local fakeSelectionWindow = Panel:New{
		x = 75,
		width = 20,
		y = 0,
		height = 20,
		padding = {0, 0, 0, 0},
		backgroundColor = {1, 1, 1, 0.8},
		children = {selectionButtonPanel}
	}
	
	local screenWidth,screenHeight = Spring.GetViewGeometry()
	local minimapHeight = screenWidth/6 + 45
	
	local selectionWindowMain = Window:New{
		name = "ModuleSelectionWindow",
		fontsize = 20,
		x = 370,
		y = minimapHeight,
		clientWidth = 575,
		clientHeight = 500,
		minWidth = 0,
		minHeight = 0,
		padding = {0, 0, 0, 0},
		resizable = false,
		draggable = false,
		dockable = true,
		dockableSavePositionOnly = true,
		dockableNoResize = true,
		tweakDraggable = true,
		tweakResizable = true,
		color = {0,0,0,0},
		children = {fakeSelectionWindow}
	}

	return {
		window = selectionWindowMain,
		fakeWindow = fakeSelectionWindow,
		panel = selectionButtonPanel,
		windowShown = false,
	}
end

local function HideModuleSelection()
	if selectionWindow and selectionWindow.windowShown then
		selectionWindow.windowShown = false
		screen0:RemoveChild(selectionWindow.window)
	end
end

local function ShowModuleSelection(moduleSet, supressButton)
	if not selectionWindow then
		selectionWindow = CreateModuleSelectionWindow()
	end
	
	local panel = selectionWindow.panel
	local fakeWindow = selectionWindow.fakeWindow
	local window = selectionWindow.window
	
	-- The number of modules which need to be displayed.
	local moduleCount = #moduleSet
	
	if moduleCount == 0 then
		HideModuleSelection()
		return
	end
	
	-- Update buttons
	if moduleCount < #panel.children then
		-- Remove buttons if there are too many
		for i = #panel.children, moduleCount + 1, -1  do
			panel:RemoveChild(panel.children[i])
		end
	else
		-- Add buttons if there are too few
		for i = #panel.children + 1, moduleCount do
			local button = GetNewSelectionButton(i, moduleSet[i])
			panel:AddChild(button)
			button.supressButtonReaction = supressButton
		end
	end
	
	-- Update buttons which were not added or removed.
	local forLimit = math.min(moduleCount, #panel.children)
	for i = 1, forLimit do
		local button = UpdateNewSelectionButton(i, moduleSet[i])
		button.supressButtonReaction = supressButton
	end
	
	-- Resize window to fit module count
	local rows, columns
	if moduleCount < 3*ROW_COUNT then
		columns = math.min(moduleCount, 3)
		rows = math.ceil(moduleCount/3)
	else
		columns = math.ceil(moduleCount/ROW_COUNT)
		rows = math.ceil(moduleCount/columns)
	end
	
	-- Column updating works without Invalidate
	panel.columns = columns
	window:Resize(columns*BUTTON_SIZE + 10 + 75, rows*BUTTON_SIZE + 10)
	fakeWindow:Resize(columns*BUTTON_SIZE + 10 + 75, rows*BUTTON_SIZE + 10)
	
	-- Display window if not already shown
	if not selectionWindow.windowShown then
		selectionWindow.windowShown = true
		screen0:AddChild(window)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Keep track of the current modules and generate restrictions

local alreadyOwnedModules = {}
local alreadyOwnedModulesByDefID = {}

local currentModulesBySlot = {}
local currentModulesByDefID = {}

local function ResetCurrentModules(newAlreadyOwned)
	currentModulesBySlot = {}
    currentModulesByDefID = {}
	alreadyOwnedModules = newAlreadyOwned
	alreadyOwnedModulesByDefID = upgradeUtilities.ModuleListToByDefID(newAlreadyOwned)
end

local function GetCurrentModules()
	return currentModulesBySlot
end

local function GetAlreadyOwned()
	return alreadyOwnedModules
end

local function GetSlotModule(slot, emptyModule)
	--spring.echo("EmptyModule: " .. tostring(emptyModule))
	return currentModulesBySlot[slot] or emptyModule
end

local function UpdateSlotModule(slot, moduleDefID)
	if currentModulesBySlot[slot] then
		local oldID = currentModulesBySlot[slot]
		local count = currentModulesByDefID[oldID]
		if count and count > 1 then
			currentModulesByDefID[oldID] = count - 1
		else
			currentModulesByDefID[oldID] = nil
		end
	end
	
	currentModulesBySlot[slot] = moduleDefID
	currentModulesByDefID[moduleDefID] = (currentModulesByDefID[moduleDefID] or 0) + 1
end

local function ModuleIsValid(level, chassis, slotAllows, slotIndex)
	local moduleDefID = currentModulesBySlot[slotIndex]
	return upgradeUtilities.ModuleIsValid(level, chassis, slotAllows, moduleDefID, alreadyOwnedModulesByDefID, currentModulesByDefID)
end

local function CountModulesInSet(set, ignoreSlot)
	local count = 0
	for i = 1, #set do
		local req = set[i]
		count = count + (alreadyOwnedModulesByDefID[req] or 0)
		              + (currentModulesByDefID[req] or 0)
		              - (currentModulesBySlot[ignoreSlot] == req and 1 or 0)
	end
	return count
end

local function GetNewReplacementSet(level, chassis, slotAllows, ignoreSlot)
	local replacementSet = {}
	local haveEmpty = false
	for i = 1, #moduleDefs do
		local data = moduleDefs[i]
		if slotAllows[data.slotType] and (data.requireLevel or 0) <= level and
				((not data.requireChassis) or data.requireChassis[chassis]) and not data.unequipable then
			local accepted = true
			
			-- Check whether required modules are present, not counting ignored slot
			if data.requireOneOf and CountModulesInSet(data.requireOneOf, ignoreSlot) < 1 then
				accepted = false
			end
			if data.requireTwoOf and CountModulesInSet(data.requireTwoOf, ignoreSlot) < 2 then
				accepted = false
			end
			
			-- Check whether prohibited modules are present, not counting ignored slot
			if accepted and data.prohibitingModules and CountModulesInSet(data.prohibitingModules, ignoreSlot) > 0 then
				accepted = false
			end

			-- cheapass hack to prevent cremcom dual wielding same weapon (not supported atm)
			-- proper solution: make the second instance of a weapon apply projectiles x2 or reloadtime x0.5 and get cremcoms unit script to work with that
			local limit = data.limit
			if chassis == 6 and data.slotType == "basic_weapon" and limit == 2 then
				limit = 1
			end

			-- Check against module limit, not counting ignored slot
			if accepted and limit and (currentModulesByDefID[i] or alreadyOwnedModulesByDefID[i]) then
				local count = (currentModulesByDefID[i] or 0) + (alreadyOwnedModulesByDefID[i] or 0)
				if currentModulesBySlot[ignoreSlot] == i then
					count = count - 1
				end
				if count >= limit then
					accepted = false
				end
			end
			
			-- Only put one empty module in the accepted set (for the case of slots which allow two or more types)
			if accepted and data.emptyModule then
				if haveEmpty then
					accepted = false
				else
					haveEmpty = true
				end
			end
			
			-- Add the module once accepted
			if accepted and i ~= nullweapon and i ~= nulladvweapon then
				replacementSet[#replacementSet + 1] = i
			end
		end
	end
	return replacementSet
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Current Module Button Handling

-- Two seperate lists because buttons are stored, module data is not and
-- may change size between invocations of the window.
local currentModuleData = {}
local currentModuleButton = {}

local function ResetCurrentModuleData()
	currentModuleData = {}
end

local function ClearActiveButton()
	if alreadyOwnedShown then
		viewAlreadyOwnedButton.backgroundColor = {0.5,0.5,0.5,0.5}
		viewAlreadyOwnedButton:Invalidate()
		alreadyOwnedShown = false
	end
	if activeSlotIndex then
		currentModuleButton[activeSlotIndex].backgroundColor = {0.5,0.5,0.5,0.5}
		currentModuleButton[activeSlotIndex]:Invalidate()
	end
	alreadyOwnedShown = false
	activeSlotIndex = false
end

local function CurrentModuleClick(self, slotIndex)
	if (not activeSlotIndex) or activeSlotIndex ~= slotIndex then
		ClearActiveButton()
		self.backgroundColor = {0,1,0,1}
		activeSlotIndex = slotIndex
		ShowModuleSelection(currentModuleData[slotIndex].replacementSet)
	else
		self.backgroundColor = {0.5,0.5,0.5,0.5}
		activeSlotIndex = false
		HideModuleSelection()
	end
end

local function AlreadyOwnedModuleClick(self)
	if not alreadyOwnedShown then
		ClearActiveButton()
		self.backgroundColor = {0,1,0,1}
		alreadyOwnedShown = true
		ShowModuleSelection(GetAlreadyOwned(), true)
	else
		self.backgroundColor = {0.5,0.5,0.5,0.5}
		alreadyOwnedShown = false
		HideModuleSelection()
	end
end

local function AddCurrentModuleButton(slotIndex, moduleDefID)
	local moduleData = moduleDefs[moduleDefID]
	local newButton = Button:New{
		caption = "",
		x = 0,
		y = 0,
		right = 0,
		minHeight = BUTTON_SIZE,
		height = BUTTON_SIZE,
		padding = {0, 0, 0, 0},
		backgroundColor = {0.5,0.5,0.5,0.5},
		OnClick = {
			function(self)
				CurrentModuleClick(self, slotIndex)
			end
		},
		tooltip = GetModuleDescription(moduleData)
	}

	Image:New{
		x = 0,
		y = 0,
		bottom = 0,
		keepAspect = true,
		file = moduleData.image,
		parent = newButton,
	}
	
	local textBox = Chili.TextBox:New{
		x      = 64,
		y      = 10,
		right  = 8,
		bottom = 8,
		valign = "left",
		text   = WG.ModuleTranslations[moduleData.name].name,
		font   = {size = 16, outline = true, color = moduleTextColor, outlineWidth = 2, outlineWeight = 2},
		parent = newButton,
	}
	
	currentModuleButton[slotIndex] = newButton
end

-- This type of module replacement updates the button as well.
-- UpdateSlotModule only updates module tracking. This function
-- does not update replacementSet.
local function ModuleReplacmentWithButton(slotIndex, moduleDefID)
	local moduleData = moduleDefs[moduleDefID]
	local button = currentModuleButton[slotIndex]
	button.tooltip = GetModuleDescription(moduleData)
	button.children[1].file = moduleData.image
	button.children[1]:Invalidate()
	button.children[2]:SetText(WG.ModuleTranslations[moduleData.name].name)
	--spring.echo("SetChild2: " .. WG.ModuleTranslations[moduleData.name].name)
	UpdateSlotModule(slotIndex, moduleDefID)
end

local function GetCurrentModuleButton(moduleDefID, slotIndex, level, chassis, slotAllows, empty, alreadyOwnedModules)
	if not currentModuleButton[slotIndex] then
		AddCurrentModuleButton(slotIndex, moduleDefID)
	end
	
	currentModuleData[slotIndex] = currentModuleData[slotIndex] or {}
	local current = currentModuleData[slotIndex]
	
	current.level = level
	current.chassis = chassis
	current.slotAllows = slotAllows
	if empty ~= nullweapon and empty ~= nulladvweapon then
		current.empty = empty
	else
		current.empty = defaultweapons[chassis]
	end
	current.replacementSet = GetNewReplacementSet(level, chassis, slotAllows, slotIndex)

	ModuleReplacmentWithButton(slotIndex, moduleDefID)
	
	return currentModuleButton[slotIndex]
end

function SelectNewModule(moduleDefID)
	if (not activeSlotIndex) or alreadyOwnedShown then
		return
	end
	
	ModuleReplacmentWithButton(activeSlotIndex, moduleDefID)
	
	-- Check whether module choices are still valid
	local requireUpdate = true
	local newCost = 0
	for repeatBreak = 1, 2 * #currentModuleData do
		newCost = 0
		requireUpdate = false
		for i = 1, #currentModuleData do
			local data = currentModuleData[i]
			if ModuleIsValid(data.level, data.chassis, data.slotAllows, i) then
				newCost = newCost + moduleDefs[GetSlotModule(i, data.empty)].cost
			else
				requireUpdate = true
				ModuleReplacmentWithButton(i, data.empty)
			end
		end
		if not requireUpdate then
			break
		end
	end
	
	UpdateMorphCost(newCost)
	
	-- Update each replacement set
	for i = 1, #currentModuleData do
		local data = currentModuleData[i]
		data.replacementSet = GetNewReplacementSet(data.level, data.chassis, data.slotAllows, i)
	end
	
	ShowModuleSelection(currentModuleData[activeSlotIndex].replacementSet)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Main Module Window Handling

local mainWindowShown = false
local mainWindow, timeLabel, costLabel

function UpdateMorphCost(newCost)
	newCost = (newCost or 0) + morphBaseCost
	costLabel:SetCaption(comma_value(math.floor(newCost)))
	timeLabel:SetCaption(GetTimeString(math.floor(newCost/morphBuildPower)))
	morphRateLabel:SetCaption(comma_value(morphBuildPower))
end

local function HideMainWindow()
	if mainWindowShown then
		SaveModuleLoadout()
		screen0:RemoveChild(mainWindow)
		mainWindowShown = false
	end
	HideModuleSelection()
end

local function CreateMainWindow()
	local screenWidth, screenHeight = Spring.GetViewGeometry()
	local minimapHeight = screenWidth/6 + 45
	
	local mainHeight = math.min(420, math.max(325, screenHeight - 450))
	
	mainWindow = Window:New{
		classname = "main_window_small_tall",
		name = "CommanderUpgradeWindow",
		fontsize = 20,
		x = 0,
		y = minimapHeight,
		width = 270,
		height = 332,
		minWidth = 270,
		minHeight = 332,
		resizable = false,
		draggable = false,
		dockable = true,
		dockableSavePositionOnly = true,
		tweakDraggable = true,
		tweakResizable = true,
		parent = screen0,
	}
	
	mainWindowShown = true

	-- The rest of the window is organized top to bottom
	topLabel = Chili.Label:New{
		x      = 0,
		right  = 0,
		y      = 0,
		height = 35,
		valign = "center",
		align  = "center",
		caption = WG.Translate("interface", "modules"),
		autosize = false,
		font   = {size = 20, outline = true, color = {.8,.8,.8,.9}, outlineWidth = 2, outlineWeight = 2},
		parent = mainWindow,
	}
	
	currentModuleList = StackPanel:New{
		x = 3,
		right = 2,
		y = 36,
		bottom = 0,
		padding = {0, 0, 0, 0},
		itemPadding = {2,2,2,2},
		itemMargin  = {0,0,0,0},
		backgroundColor = {1, 1, 1, 0.8},
		resizeItems = false,
		centerItems = false,
		parent = mainWindow,
	}
	
	local cyan = {0,1,1,1}
	
	local timeImage = Image:New{
		x = 15,
		bottom  = 85,
		file ='LuaUI/images/clock.png',
		height = 24,
		width = 24,
		keepAspect = true,
		parent = mainWindow,
	}
	
	timeLabel = Chili.Label:New{
		x = 42,
		right  = 0,
		bottom  = 87,
		valign = "top",
		align  = "left",
		caption = 0,
		autosize = false,
		font    = {size = 24, outline = true, color = cyan, outlineWidth = 2, outlineWeight = 2},
		parent = mainWindow,
	}
	
	local costImage = Image:New{
		x = 15,
		bottom  = 60,
		file ='LuaUI/images/costIcon.png',
		height = 24,
		width = 24,
		keepAspect = true,
		parent = mainWindow,
	}
	
	local rateLabel = Image:New{
		x = 137,
		bottom  = 85,
		file = 'LuaUI/Images/commands/Bold/buildsmall.png',
		height = 24,
		width = 24,
		keepAspect = true,
		parent = mainWindow,
	}
	
	morphRateLabel = Chili.Label:New{
		x = 162,
		right  = 0,
		bottom  = 87,
		valign = "top",
		align  = "left",
		caption = 0,
		autosize = false,
		font     = {size = 24, outline = true, color = cyan, outlineWidth = 2, outlineWeight = 2},
		parent = mainWindow,
	}
	
	costLabel = Chili.Label:New{
		x = 42,
		right  = 0,
		bottom  = 62,
		valign = "top",
		align  = "left",
		caption = 0,
		autosize = false,
		font     = {size = 24, outline = true, color = cyan, outlineWidth = 2, outlineWeight = 2},
		parent = mainWindow,
	}
	
	local acceptButton = Button:New{
		caption = "",
		x = 6,
		bottom = 5,
		width = 75,
		height = 50,
		padding = {0, 0, 0, 0},
		backgroundColor = {0.5,0.5,0.5,0.5},
		tooltip = acceptText,
		OnClick = {
			function()
				if mainWindowShown then
					SendUpgradeCommand(GetCurrentModules())
				end
			end
		},
		parent = mainWindow,
	}
	
	viewAlreadyOwnedButton = Button:New{
		caption = "",
		x = 85,
		bottom = 5,
		width = 75,
		height = 50,
		padding = {0, 0, 0, 0},
		backgroundColor = {0.5,0.5,0.5,0.5},
		tooltip =  viewText,
		OnClick = {
			function(self)
				AlreadyOwnedModuleClick(self)
			end
		},
		parent = mainWindow,
	}
	
	local cancelButton = Button:New{
		caption = "",
		x = 164,
		bottom = 5,
		width = 75,
		height = 50,
		padding = {0, 0, 0, 0},
		backgroundColor = {0.5,0.5,0.5,0.5},
		tooltip = cancelText,
		OnClick = {
			function()
				----spring.echo("Upgrade UI Debug - Cancel Clicked")
				HideMainWindow()
			end
		},
		parent = mainWindow,
	}
	
	Image:New{
		x = 2,
		right = 2,
		y = 0,
		bottom = 0,
		keepAspect = true,
		file = "LuaUI/Images/dynamic_comm_menu/tick.png",
		parent = acceptButton,
	}
	
	Image:New{
		x = 2,
		right = 2,
		y = 0,
		bottom = 0,
		keepAspect = true,
		file = "LuaUI/Images/dynamic_comm_menu/eye.png",
		parent = viewAlreadyOwnedButton,
	}
	
	Image:New{
		x = 2,
		right = 2,
		y = 0,
		bottom = 0,
		keepAspect = true,
		file = "LuaUI/Images/commands/Bold/cancel.png",
		parent = cancelButton,
	}
end

local function ShowModuleListWindow(slotDefaults, level, chassis, alreadyOwnedModules)
	if not currentModuleList then
		CreateMainWindow()
	end
	
	if level > chassisDefs[chassis].maxNormalLevel then
		morphBaseCost = chassisDefs[chassis].extraLevelCostFunction(level)
		level = chassisDefs[chassis].maxNormalLevel
		morphBuildPower = chassisDefs[chassis].levelDefs[level].morphBuildPower
	else
		morphBaseCost = chassisDefs[chassis].levelDefs[level].morphBaseCost
		morphBuildPower = chassisDefs[chassis].levelDefs[level].morphBuildPower
	end
	
	local slots = chassisDefs[chassis].levelDefs[level].upgradeSlots

	if not mainWindowShown then
		screen0:AddChild(mainWindow)
		mainWindowShown = true
	end
	
	-- Removes all previous children
	for i = #currentModuleList.children, 1, -1  do
		currentModuleList:RemoveChild(currentModuleList.children[i])
	end
	
	ClearActiveButton()
	HideModuleSelection()
	ResetCurrentModuleData()
	ResetCurrentModules(alreadyOwnedModules)
	
	-- Data is added here to generate reasonable replacementSets in actual adding.
	for i = 1, #slots do
		local slotData = slots[i]
		UpdateSlotModule(i, (slotDefaults and slotDefaults[i]) or slotData.defaultModule)
	end
	
	-- Check that the module in each slot is valid
	local requireUpdate = true
	local newCost = 0
	for repeatBreak = 1, 2 * #slots do
		requireUpdate = false
		newCost = 0
		for i = 1, #slots do
			local slotData = slots[i]
			if ModuleIsValid(level, chassis, slotData.slotAllows, i) then
				newCost = newCost + moduleDefs[GetSlotModule(i, slotData.empty)].cost
			else
				requireUpdate = true
				UpdateSlotModule(i, slotData.empty)
			end
		end
		if not requireUpdate then
			break
		end
	end
	
	UpdateMorphCost(newCost)
	
	-- Actually add the default modules and slot data
	for i = 1, #slots do
		local slotData = slots[i]
		currentModuleList:AddChild(GetCurrentModuleButton(GetSlotModule(i, slotData.empty), i, level, chassis, slotData.slotAllows, slotData.empty, alreadyOwnedModules))
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Command Handling

local upgradeSignature = {}
local savedSlotLoadout = {}

function SendUpgradeCommand(newModules)
	-- Find selected eligible units
	local units = Spring.GetSelectedUnits()
	local upgradableUnits = {}
	for i = 1, #units do
		local unitID = units[i]
		local level = Spring.GetUnitRulesParam(unitID, "comm_level")
		local chassis = Spring.GetUnitRulesParam(unitID, "comm_chassis")
		if level == upgradeSignature.level and chassis == upgradeSignature.chassis then
			local alreadyOwned = {}
			local moduleCount = Spring.GetUnitRulesParam(unitID, "comm_module_count")
			for i = 1, moduleCount do
				local module = Spring.GetUnitRulesParam(unitID, "comm_module_" .. i)
				alreadyOwned[#alreadyOwned + 1] = module
			end
			
			table.sort(alreadyOwned)
			
			if upgradeUtilities.ModuleSetsAreIdentical(alreadyOwned, upgradeSignature.alreadyOwned) then
				upgradableUnits[#upgradableUnits + 1] = unitID
			end
		end
	end
	
	-- Create upgrade command params and issue it to units.
	if #upgradableUnits > 0 then
		local params = {}
		params[1] = upgradeSignature.level
		params[2] = upgradeSignature.chassis
		params[3] = #upgradeSignature.alreadyOwned
		params[4] = #newModules
		
		local index = 5
		for j = 1,  #upgradeSignature.alreadyOwned do
			params[index] = upgradeSignature.alreadyOwned[j]
			index = index + 1
		end
		for j = 1,  #newModules do
			params[index] = newModules[j]
			index = index + 1
		end
		Spring.GiveOrderToUnitArray(upgradableUnits, CMD_MORPH_UPGRADE_INTERNAL, params, 0)
	end
	
	-- Remove main window
	----spring.echo("Upgrade UI Debug - Upgrade Command Sent")
	HideMainWindow()
end

function SaveModuleLoadout()
	local currentModules = GetCurrentModules()
	if not (upgradeSignature and currentModules) then
		return
	end
	local profileID = upgradeSignature.profileID
	local level = upgradeSignature.level
	if not (profileID and level) then
		return
	end
	savedSlotLoadout[profileID] = savedSlotLoadout[profileID] or {}
	savedSlotLoadout[profileID][level] = GetCurrentModules()
end

local function CreateModuleListWindowFromUnit(unitID)
	local level = Spring.GetUnitRulesParam(unitID, "comm_level")
	local chassis = Spring.GetUnitRulesParam(unitID, "comm_chassis")
	local profileID = Spring.GetUnitRulesParam(unitID, "comm_profileID")
	
	if not (chassisDefs[chassis] and chassisDefs[chassis].levelDefs[math.min(chassisDefs[chassis].maxNormalLevel, level+1)]) then
		return
	end
	
	-- Find the modules which are already owned
	local alreadyOwned = {}
	local moduleCount = Spring.GetUnitRulesParam(unitID, "comm_module_count")
	for i = 1, moduleCount do
		local module = Spring.GetUnitRulesParam(unitID, "comm_module_" .. i)
		alreadyOwned[#alreadyOwned + 1] = module
	end
	table.sort(alreadyOwned)
	damageBooster = Spring.GetUnitRulesParam(unitID, "comm_damage_mult") or 1
	rangeBooster  = Spring.GetUnitRulesParam(unitID, "comm_range_mult") or 1
	-- Record the signature of the morphing unit for later application.
	upgradeSignature.level = level
	upgradeSignature.chassis = chassis
	upgradeSignature.profileID = profileID
	upgradeSignature.alreadyOwned = alreadyOwned
	
	-- Load default loadout
	local slotDefaults = {}
	if profileID and level then
		if savedSlotLoadout[profileID] and savedSlotLoadout[profileID][level] then
			slotDefaults = savedSlotLoadout[profileID][level]
		else
			local commProfileInfo = WG.ModularCommAPI.GetCommProfileInfo(profileID)
			if commProfileInfo and commProfileInfo.modules and commProfileInfo.modules[level + 1] then
				local defData = commProfileInfo.modules[level + 1]
				for i = 1, #defData do
					slotDefaults[i] = moduleDefNames[defData[i]]
				end
			end
		end
	end
	
	-- Create the window
	ShowModuleListWindow(slotDefaults, level + 1, chassis, alreadyOwned)
end

local function GetCommanderUpgradeAttributes(unitID, cullMorphing)
	local unitDefID = Spring.GetUnitDefID(unitID)
	if not commanderUnitDefID[unitDefID] then
		return false
	end
	if cullMorphing and Spring.GetUnitRulesParam(unitID, "morphing") == 1 then
		return false
	end
	local level = Spring.GetUnitRulesParam(unitID, "comm_level")
	if not level then
		return false
	end
	local chassis = Spring.GetUnitRulesParam(unitID, "comm_chassis")
	local staticLevel = Spring.GetUnitRulesParam(unitID, "comm_staticLevel")
	return level, chassis, staticLevel
end

function widget:CommandNotify(cmdID, cmdParams, cmdOptions)
	if cmdID ~= CMD_UPGRADE_UNIT then
		return false
	end
	
	local units = Spring.GetSelectedUnits()
	local upgradeID = false
	for i = 1, #units do
		local unitID = units[i]
		local level, chassis, staticLevel = GetCommanderUpgradeAttributes(unitID, true)
		if level and (not staticLevel) and chassis and (not LEVEL_BOUND or level < LEVEL_BOUND) then
			upgradeID = unitID
			break
		end
	end
	
	if not upgradeID then
		return true
	end
	
	CreateModuleListWindowFromUnit(upgradeID)
	return true
end

local cachedSelectedUnits
function widget:SelectionChanged(selectedUnits)
	cachedSelectedUnits = selectedUnits
end

function widget:CommandsChanged()
	local units = cachedSelectedUnits or Spring.GetSelectedUnits()
	if mainWindowShown then
		----spring.echo("Upgrade UI Debug - Number of units selected", #units)
		local foundMatchingComm = false
		for i = 1, #units do
			local unitID = units[i]
			local level, chassis, staticLevel = GetCommanderUpgradeAttributes(unitID)
			if level and (not staticLevel) and level == upgradeSignature.level and chassis == upgradeSignature.chassis then
				local alreadyOwned = {}
				local moduleCount = Spring.GetUnitRulesParam(unitID, "comm_module_count")
				for i = 1, moduleCount do
					local module = Spring.GetUnitRulesParam(unitID, "comm_module_" .. i)
					alreadyOwned[#alreadyOwned + 1] = module
				end
				table.sort(alreadyOwned)

				if upgradeUtilities.ModuleSetsAreIdentical(alreadyOwned, upgradeSignature.alreadyOwned) then
					foundMatchingComm = true
					break
				end
			end
		end
		
		if foundMatchingComm then
			local customCommands = widgetHandler.customCommands
			customCommands[#customCommands+1] = UPGRADE_CMD_DESC
		else
			------spring.echo("Upgrade UI Debug - Commander Deselected")
			HideMainWindow() -- Hide window if no commander matching the window is selected
		end
	end
	
	if not mainWindowShown then
		local foundRulesParams = false
		for i = 1, #units do
			local unitID = units[i]
			local level, chassis, staticLevel = GetCommanderUpgradeAttributes(unitID, true)
			if level and (not staticLevel) and chassis and (not LEVEL_BOUND or level < LEVEL_BOUND) then
				foundRulesParams = true
				break
			end
		end
		
		if foundRulesParams then
			local customCommands = widgetHandler.customCommands

			customCommands[#customCommands+1] = {
				id      = CMD_UPGRADE_UNIT,
				type    = CMDTYPE.ICON,
				tooltip = 'Upgrade Commander',
				cursor  = 'Repair',
				action  = 'upgradecomm',
				params  = {},
				texture = 'LuaUI/Images/commands/Bold/upgrade.png',
			}
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

function widget:Initialize()
	-- setup Chili
	Chili = WG.Chili
	Button = Chili.Button
	Label = Chili.Label
	Window = Chili.Window
	Panel = Chili.Panel
	StackPanel = Chili.StackPanel
	LayoutPanel = Chili.LayoutPanel
	Image = Chili.Image
	Progressbar = Chili.Progressbar
	screen0 = Chili.Screen0
	for _, modDef in pairs(moduleDefs) do -- preload for translation, translation will occur post loading.
		--spring.echo(modDef.name)
		if modDef.slotType ~= "decoration" then
			--spring.echo("Adding " .. modDef.name)
			WG.ModuleTranslations[modDef.name] = {name = modDef.humanName, desc = modDef.description}
		end
	end
	
	if (not Chili) then
		widgetHandler:RemoveWidget()
		return
	end
	WG.InitializeTranslation(OnLocaleChanged, "gui_chili_commander_upgrade")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
