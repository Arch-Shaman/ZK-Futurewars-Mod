
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

local econMultEnabled = nil
local buildTimes = {}
local unitRanges = {}
local planetwarsStructure = {}
local buildPlate = {}
local buildPowerCache = {}
local rangeCache = {}
local dynComm = {}
local garmrRange = WeaponDefs[UnitDefNames["staticarty"].weapons[1].weaponDef].range
local variableCostUnit = {
	[UnitDefNames["terraunit"].id] = true
}
local superweapons = {}

local spGetUnitAllyTeam = Spring.GetUnitAllyTeam

for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	buildTimes[i] = ud.buildTime
	if ud.customParams.level or ud.customParams.dynamic_comm then
		variableCostUnit[i] = true
		dynComm[i] = true
	end
	if ud.customParams.superweapon then
		superweapons[UnitDefs[i].name] = true
	end
	if ud.customParams.planetwars_structure then
		planetwarsStructure[i] = true
	end
	if ud.customParams.child_of_factory then
		buildPlate[i] = true
	end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

local function GetCachedBaseBuildPower(unitDefID, ud)
	if not buildPowerCache[unitDefID] then
		ud = ud or UnitDefs[unitDefID]
		buildPowerCache[unitDefID] = (ud and ((ud.customParams.nobuildpower and 0) or ud.buildSpeed)) or 0
	end
	return buildPowerCache[unitDefID]
end

local function GetCachedBaseRange(unitDefID, ud)
	if not rangeCache[unitDefID] then
		ud = ud or UnitDefs[unitDefID]
		rangeCache[unitDefID] = ud.maxWeaponRange
	end
	return rangeCache[unitDefID]
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

local function GetUnitCost(unitID, unitDefID)
	unitDefID = unitDefID or Spring.GetUnitDefID(unitID)
	if unitID and variableCostUnit[unitDefID] then
		local realCost = Spring.GetUnitRulesParam(unitID, "comm_cost") or Spring.GetUnitRulesParam(unitID, "terraform_estimate")
		if realCost then
			return realCost
		end
	end
	if unitDefID and buildTimes[unitDefID] then
		return buildTimes[unitDefID]
	end
	return 50
end
Spring.Utilities.GetUnitCost = GetUnitCost

function Spring.Utilities.GetUnitValue(unitID, unitDefID)
	local cost = GetUnitCost(unitID, unitDefID)
	local _, buildProgress = Spring.GetUnitIsBeingBuilt(unitID)
	return cost * buildProgress
end

function Spring.Utilities.GetUnitCanBuild(unitID, unitDefID)
	unitDefID = unitDefID or Spring.GetUnitDefID(unitID)
	if not unitDefID then
		return false
	end
	return GetCachedBaseBuildPower(unitDefID) > 0
end

function Spring.Utilities.GetUnitBuildSpeed(unitID, unitDefID)
	unitDefID = unitDefID or Spring.GetUnitDefID(unitID)
	if not unitDefID then
		return 0
	end
	if econMultEnabled == nil then
		econMultEnabled = (Spring.GetGameRulesParam("econ_mult_enabled") and true) or false
	end
	local buildPower = GetCachedBaseBuildPower(unitDefID)
	local mult = 1
	if unitID then
		if econMultEnabled then
			mult = mult * (Spring.GetGameRulesParam("econ_mult_" .. (spGetUnitAllyTeam(unitID) or "")) or 1)
		end
		buildPower = buildPower * (Spring.GetUnitRulesParam(unitID, "buildpower_mult") or 1)
	elseif econMultEnabled and Spring.GetMyAllyTeamID then
		mult = mult * (Spring.GetGameRulesParam("econ_mult_" .. (Spring.GetMyAllyTeamID() or "")) or 1)
	end
	return mult * buildPower, buildPower
end

local spGetUnitBuildSpeed = Spring.Utilities.GetUnitBuildSpeed

function Spring.Utilities.GetUnitRange(unitID, unitDefID)
	unitDefID = unitDefID or Spring.GetUnitDefID(unitID)
	if not unitDefID then
		return false
	end
	if not dynComm[unitDefID] then
		local range = GetCachedBaseRange(unitDefID)
		return (range > 0) and range
	end
	return Spring.GetUnitRulesParam(unitID, "comm_max_range") or GetCachedBaseRange(unitDefID), Spring.GetUnitRulesParam(unitID, "primary_weapon_range")
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

local function GetGridTooltip(unitID, ud)
	if ud.customParams.keeptooltip or ud.customParams.superweapon then
		return
	end
	local gridCurrent = Spring.GetUnitRulesParam(unitID, "OD_gridCurrent")
	if not gridCurrent then return end

	local windStr = ""
	local minWind = Spring.GetUnitRulesParam(unitID, "minWind")
	if minWind then
		if econMultEnabled == nil then
			econMultEnabled = (Spring.GetGameRulesParam("econ_mult_enabled") and true) or false
		end
		local maxWind = (Spring.GetGameRulesParam("WindMax") or 2.5)
		if econMultEnabled then
			local mult = (Spring.GetGameRulesParam("econ_mult_" .. (spGetUnitAllyTeam(unitID) or "")) or 1)
			minWind = minWind * mult
			maxWind = maxWind * mult
		end
		minWind = math.round(minWind, 1)
		maxWind = math.round(maxWind, 1)
		windStr = "\n" ..  WG.Translate("interface", "wind_range") .. " " .. minWind .. " - " .. maxWind
	end

	if gridCurrent < 0 then
		return WG.Translate("interface", "disabled_no_grid") .. windStr
	end
	local gridMaximum = Spring.GetUnitRulesParam(unitID, "OD_gridMaximum") or 0
	local gridMetal = Spring.GetUnitRulesParam(unitID, "OD_gridMetal") or 0

	return WG.Translate("interface", "grid") .. ": " .. math.round(gridCurrent,2) .. "/" .. math.round(gridMaximum,2) .. " E => " .. math.round(gridMetal,2) .. " M " .. windStr
end

local function GetMexTooltip(unitID, ud)
	local metalMult = Spring.GetUnitRulesParam(unitID, "overdrive_proportion")
	if not metalMult then return end

	local currentIncome = Spring.GetUnitRulesParam(unitID, "current_metalIncome")
	local mexIncome = Spring.GetUnitRulesParam(unitID, "mexIncome") or 0
	local baseFactor = Spring.GetUnitRulesParam(unitID, "resourceGenerationFactor") or 1

	if currentIncome == 0 then
		return WG.Translate("interface", "disabled_base_metal") .. ": " .. math.round(mexIncome,2)
	end

	return WG.Translate("interface", "income") .. ": " .. math.round(mexIncome*baseFactor,2) .. " + " .. math.round(metalMult*100) .. "% " .. WG.Translate("interface", "overdrive")
end

local function GetTerraformTooltip(unitID)
	local spent = Spring.GetUnitRulesParam(unitID, "terraform_spent")
	if not spent then return end

	return WG.Translate("interface", "terraform") .. " - " .. WG.Translate("interface", "estimated_cost") .. ": " .. math.floor(spent) .. " / " .. math.floor(Spring.GetUnitRulesParam(unitID, "terraform_estimate") or 0)
end

local function GetZenithTooltip(unitID)
	local meteorsControlled = Spring.GetUnitRulesParam(unitID, "meteorsControlled") or "0"
	return (WG.Translate("units", "zenith.description") or "Meteor Controller") .. " - " .. (WG.Translate("interface", "meteors_controlled") or "Meteors controlled") .. " " .. meteorsControlled .. "/300"
end

local function GetSuperweaponTooltip(unitID, ud)
	if not superweapons[ud.name] then
		return
	end
	if ud.name == "staticarty" then
		local base = WG.Translate("units", "staticarty.description") or "Tactical Artillery"
		if (Spring.GetUnitRulesParam(unitID, "lowpower") or 0) == 1 then
			local grid = (Spring.GetUnitRulesParam(unitID, "OD_gridMaximum") or 0)
			grid = string.format("%.1f", math.round(grid, 1))
			return base .. "\n\255\255\061\061" .. (WG.Translate("interface", "needs_grid") or "Grid Power: ") .. grid .. " / " .. ud.customParams.neededlink .. "\255\255\255\255"
		end
		local od = (Spring.GetUnitRulesParam(unitID, "superweapon_mult") or 0)
		local range = math.max(garmrRange * od, 1000)
		od = string.format("%.2f %%", math.round(od * 100, 2))
		return base .. "\n" .. (WG.Translate("interface", "range") or "Current Range:") .. " " .. math.floor(range) .. "(" .. od .. ")" 
	end
	if ud.name == "zenith" then
		local base = GetZenithTooltip(unitID)
		base = base .. "\n"
		if (Spring.GetUnitRulesParam(unitID, "lowpower") or 0) == 1 then
			local grid = (Spring.GetUnitRulesParam(unitID, "OD_gridMaximum") or 0)
			grid = string.format("%.1f", math.round(grid, 1))
			return base .. "\255\255\061\061" .. (WG.Translate("interface", "needs_grid") or "Grid Power: ") .. grid .. " / " .. ud.customParams.neededlink .. "\255\255\255\255"
		end
		local superRate = (Spring.GetUnitRulesParam(unitID, "superweapon_mult") or 0) * 100
		local fireRate = ""
		if (Spring.GetUnitRulesParam(unitID,"disarmed") or 0) == 1 then
			fireRate = "\255\255\061\061DISABLED\255\255\255\255"
		else
			fireRate = string.format("%.2f %%", math.round(superRate, 2))
		end
		return base .. (WG.Translate("interface", "gather_rate") or "Meteor Gather Rate: ") .. " " .. fireRate
	end
	local superRate = Spring.GetUnitRulesParam(unitID, "superweapon_mult")
	if not superRate then
		return
	end
	if (Spring.GetUnitRulesParam(unitID, "lowpower") or 0) == 1 then
		local grid = (Spring.GetUnitRulesParam(unitID, "OD_gridMaximum") or 0)
		grid = string.format("%.1f", math.round(grid, 1))
		return WG.Translate("units", ud.name .. ".description") .. " - \255\255\061\061" .. (WG.Translate("interface", "needs_grid") or "Grid Power: ") .. grid .. " / " .. ud.customParams.neededlink .. "\255\255\255\255"
	end
	local superRate = (Spring.GetUnitRulesParam(unitID, "superweapon_mult") or 0) * 100
	local fireRate = ""
	if (Spring.GetUnitRulesParam(unitID,"disarmed") or 0) == 1 then
		fireRate = "\255\255\061\061DISABLED\255\255\255\255"
	else
		fireRate = string.format("%.2f %%", math.round(superRate, 2))
	end
	if ud.name == "supernova_base" or ud.name == "supernova_satellite" then
		return (WG.Translate("units", ud.name .. ".description") or "Supernova Basestation") .. "\n" .. (WG.Translate("interface", "supernova_rate") or "Satellite Amplification and Speed: ") .. fireRate
	end
	if ud.name == "turretaaheavy" then
		return (WG.Translate("units", ud.name .. ".description") or "Lolcannon") .. "\n" .. (WG.Translate("interface", "charge_rate") or "Charge Rate: ") .. fireRate
	end
	return (WG.Translate("units", ud.name .. ".description") or "Lolcannon") .. "\n" .. (WG.Translate("interface", "fire_rate") or "Fire Rate: ") .. " " .. fireRate
end

local function GetAvatarTooltip(unitID)
	local commOwner = Spring.GetUnitRulesParam(unitID, "commander_owner")
	if not commOwner then return end
	return commOwner or ""
end

local function GetLinkNeedTooltip(unitID, ud)
	if ud.customParams.neededlink == nil or ud.customParams.superweapon then
		return
	end
	if (Spring.GetUnitRulesParam(unitID, "lowpower") or 0) == 1 then
		local grid = (Spring.GetUnitRulesParam(unitID, "OD_gridMaximum") or 0)
		grid = string.format("%.1f", math.round(grid, 1))
		return WG.Translate("units", ud.name .. ".description") .. "\n\255\255\061\061" .. (WG.Translate("interface", "needs_grid") or "Insufficient grid power\255\255\255\255: ") .. grid .. " / " .. ud.customParams.neededlink
	else
		return WG.Translate("units", ud.name .. ".description")
	end
end

local function GetPlanetwarsTooltip(unitID, ud)
	if not planetwarsStructure[ud.id] then
		return false
	end
	local disabled = (Spring.GetUnitRulesParam(unitID, "planetwarsDisable") == 1)
	if not disabled then
		return
	end
	local name_override = ud.customParams.statsname or ud.name
	local desc = WG.Translate ("units", name_override .. ".description") or ud.tooltip
	return desc .. " - Disabled"
end

local function GetPlateTooltip(unitID, ud)
	local unitDefID = ud.id
	if not buildPlate[unitDefID] then
		return false
	end
	local disabled = (Spring.GetUnitRulesParam(unitID, "nofactory") == 1)
	if not disabled then
		return
	end
	local name_override = ud.customParams.statsname or ud.name
	local desc = WG.Translate ("units", name_override .. ".description") or ud.tooltip
	local buildSpeedRaw = spGetUnitBuildSpeed(unitID, unitDefID)
	if buildSpeedRaw > 0 and not ud.customParams.nobuildpower then
		local buildSpeed = buildSpeedRaw * (Spring.GetUnitRulesParam(unitID, "buildpower_mult") or 1)
		desc = WG.Translate("interface", "builds_at", {desc = desc, bp = math.round(buildSpeed, 1)}) or desc
	end
	return desc .. " Disabled - Too far from operational factory"
end

local function GetCustomTooltip (unitID, ud)
	if ud == nil then
		return "Unknown Unit"
	end
	return GetGridTooltip(unitID, ud)
	or GetSuperweaponTooltip(unitID, ud)
	or GetLinkNeedTooltip(unitID, ud)
	or GetTerraformTooltip(unitID)
	or GetMexTooltip(unitID)
	or GetAvatarTooltip(unitID)
	or GetPlanetwarsTooltip(unitID, ud)
	or GetPlateTooltip(unitID, ud)
end

function Spring.Utilities.GetHumanName(ud, unitID)
	if not ud then
		return ""
	end

	if unitID then
		local name = Spring.GetUnitRulesParam(unitID, "comm_name")
		if name then
			local level = Spring.GetUnitRulesParam(unitID, "comm_level")
			if level then
				return name .. " " .. WG.Translate("interface", "lvl") .. " " .. (level + 1)
			else
				return name
			end
		end
	end

	local name_override = ud.customParams.statsname or ud.name
	return WG.Translate ("units", name_override .. ".name") or ud.humanName
end

function Spring.Utilities.GetCommanderFeatureName(featureID)
	if not Spring.ValidFeatureID(featureID) then
		return "??NAME??"
	else
		local name = Spring.GetFeatureRulesParam(featureID, "comm_name") or "??NAME??"
		local level = Spring.GetFeatureRulesParam(featureID, "comm_level") or 0
		return name .. " " .. WG.Translate("interface", "lvl") .. " " .. (level + 1)
	end
end

function Spring.Utilities.GetDescription(ud, unitID)
	if not ud then
		return ""
	end

	local name_override = ud.customParams.statsname or ud.name
	local desc = WG.Translate ("units", name_override .. ".description") or ud.tooltip
	local isValidUnit = Spring.ValidUnitID(unitID)
	if isValidUnit then
		local customTooltip = GetCustomTooltip(unitID, ud)
		if customTooltip then
			return customTooltip
		end
	end
	
	local buildSpeed = spGetUnitBuildSpeed(unitID, ud.id)
	if buildSpeed > 0 and ud.canAssist then
		return WG.Translate("interface", "builds_at", {desc = desc, bp = math.round(buildSpeed, 1)}) or desc
	elseif buildSpeed > 0 and ud.canRepair then
		return WG.Translate("interface", "repairs_at", {desc = desc, bp = math.round(buildSpeed, 1)}) or desc
	end
	return desc
end

function Spring.Utilities.GetFeatureDescription(ud, unitID)
	if not ud then
		return ""
	end

	local name_override = ud.customParams.statsname or ud.name
	local desc = WG.Translate ("units", name_override .. ".description") or ud.tooltip
	local isValidUnit = Spring.ValidFeatureID(unitID)
	
	local buildSpeed = unitID and Spring.GetFeatureRulesParam(unitID, "buildpower_mult") or 1
	buildSpeed = buildSpeed * GetCachedBaseBuildPower(ud.id)
	if buildSpeed > 0 and ud.canAssist then
		return WG.Translate("interface", "builds_at", {desc = desc, bp = math.round(buildSpeed, 1)}) or desc
	elseif buildSpeed > 0 and ud.canRepair then
		return WG.Translate("interface", "repairs_at", {desc = desc, bp = math.round(buildSpeed, 1)}) or desc
	end
	return desc
end

function Spring.Utilities.GetFeatureName(ud, featureID)
	if Spring.GetFeatureRulesParam(featureID, "comm_name") then
		return Spring.Utilities.GetCommanderFeatureName(featureID)
	else
		return Spring.Utilities.GetDescription(ud, nil)
	end
end

function Spring.Utilities.GetHelptext(ud, unitID)
	local name_override = ud.customParams.statsname or ud.name
	return WG.Translate ("units", name_override .. ".helptext") or WG.Translate("interface", "no_helptext")
end

function Spring.Utilities.GetUnitHeight(ud)
	local customHeight = ud.customParams.custom_height
	return (customHeight and tonumber(customHeight)) or ud.height
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

if Spring.GetModOptions().techk == "1" and WG then
	local function GetTechLevel(unitID)
		if unitID then
			return Spring.GetUnitRulesParam(unitID, "tech_level") or 1
		end
		return (WG.SelectedTechLevel or 1)
	end
	
	Spring.Utilities.GetUnitMaxHealth = function(unitID, unitDefID, healthOverride)
		if healthOverride then
			return healthOverride * math.pow(2, GetTechLevel(unitID) - 1)
		end
		local ud = UnitDefs[unitDefID]
		return ud.health * math.pow(2, GetTechLevel(unitID) - 1)
	end
	
	Spring.Utilities.GetUnitCost = function(unitID, unitDefID)
		unitDefID = unitDefID or Spring.GetUnitDefID(unitID)
		if not (unitDefID and buildTimes[unitDefID]) then
			return 50
		end
		local cost = buildTimes[unitDefID]
		if unitID then
			if variableCostUnit[unitDefID] then
				cost = Spring.GetUnitRulesParam(unitID, "comm_cost") or Spring.GetUnitRulesParam(unitID, "terraform_estimate")
			else
				cost = cost * ((GG and (GG.att_CostMult[unitID] or 1)) or (Spring.GetUnitRulesParam(unitID, "costMult") or 1))
			end
		else
			cost = cost * math.pow(2, (WG.SelectedTechLevel or 1) - 1)
		end
		if not cost then
			Spring.Echo("TECHK, Spring.Utilities.GetUnitCost nil cost, unitID", unitID, "unitDefID", unitDefID)
			error("TECHK, Spring.Utilities.GetUnitCost nil cost")
		end
		return cost
	end

	Spring.Utilities.GetHumanName = function(ud, unitID)
		if not ud then
			return ""
		end
		
		local prefix = ""
		local level = GetTechLevel(unitID)
		local preLevel = level
		while preLevel > 7 do
			prefix = prefix .. "Über "
			preLevel = preLevel - 7
		end
		while preLevel > 3 do
			prefix = prefix .. "Super "
			preLevel = preLevel - 3
		end
		while preLevel > 1 do
			prefix = prefix .. "Adv. "
			preLevel = preLevel - 1
		end

		if unitID then
			local name = Spring.GetUnitRulesParam(unitID, "comm_name")
			if name then
				local level = Spring.GetUnitRulesParam(unitID, "comm_level")
				if level then
					return prefix .. name .. " " .. WG.Translate("interface", "lvl") .. " " .. (level + 1)
				else
					return prefix .. name
				end
			end
		end

		local name_override = ud.customParams.statsname or ud.name
		return prefix .. (WG.Translate ("units", name_override .. ".name") or ud.humanName)
	end

	Spring.Utilities.GetDescription = function(ud, unitID)
		if not ud then
			return ""
		end

		local name_override = ud.customParams.statsname or ud.name
		local desc = WG.Translate ("units", name_override .. ".description") or ud.tooltip
		local isValidUnit = Spring.ValidUnitID(unitID)
		if isValidUnit then
			local tech = GetTechLevel(unitID) or 1
			local customTooltip = GetCustomTooltip(unitID, ud, math.pow(3, tech - 1))
			if customTooltip then
				return customTooltip
			end
		end
		
		local buildSpeed = spGetUnitBuildSpeed(unitID, ud.id)
		if buildSpeed > 0 then
			if not unitID then
				local mult = math.pow(2, (WG.SelectedTechLevel or 1) - 1)
				buildSpeed = buildSpeed * mult
			end
			return WG.Translate("interface", "builds_at", {desc = desc, bp = math.round(buildSpeed, 1)}) or desc
		end
		return desc
	end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

function Spring.Utilities.UnitEcho(unitID, st)
	if type(st) == "boolean" then
		st = st and "T" or "F"
	end
	st = st or unitID
	if Spring.ValidUnitID(unitID) then
		local x,y,z = Spring.GetUnitPosition(unitID)
		Spring.MarkerAddPoint(x,y,z, st)
	else
		Spring.Echo("Invalid unitID")
		Spring.Echo(unitID)
		Spring.Echo(st)
	end
end

function Spring.Utilities.FeatureEcho(featureID, st)
	st = st or featureID
	if Spring.ValidFeatureID(featureID) then
		local x,y,z = Spring.GetFeaturePosition(featureID)
		Spring.MarkerAddPoint(x,y,z, st)
	else
		Spring.Echo("Invalid featureID")
		Spring.Echo(featureID)
		Spring.Echo(st)
	end
end
