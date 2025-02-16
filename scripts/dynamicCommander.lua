-- TODO: CACHE INCLUDE FILE
-- May not be worth it due to the rarity of comms, and the complexity of this file.
local INLOS = {inlos = true}
local spSetUnitShieldState = Spring.SetUnitShieldState

local dgunTable
local weapon1
local weapon2
local shield
local weaponNumMap = {}
local weaponsInitialized = false
local paceMult
local scaleMult
local weaponCegs = {}
local weaponDef1
local weaponDef2

local commWreckUnitRulesParam = {"comm_baseWreckID", "comm_baseHeapID"}
local moduleWreckNamePrefix = {"module_wreck_", "module_heap_"}

local isManual = {}

local shields = {}
local unitWeaponNames = {} -- Unit weapons by name
local wepTable = UnitDefs[unitDefID].weapons
for num = 1, #wepTable do
	local wd = WeaponDefs[wepTable[num].weaponDef]
	if wd.type == "Shield" then
		shields[#shields + 1] = num
	end
	local weaponName = string.sub(wd.name, (string.find(wd.name,"commweapon") or 0), 100)
	if weaponName then
		if unitWeaponNames[weaponName] then
			unitWeaponNames[weaponName].num2 = num
		else
			unitWeaponNames[weaponName] = {
				num = num,
				weaponDefID = wd.id,
				manualFire = (wd.customParams and wd.customParams.manualfire and true) or false
			}
		end
	end
end

local function IsManualFire(num)
	return isManual[num]
end

local levelScale = {
    [0] = 1,
    [1] = 1,
    [2] = 1.1,
    [3] = 1.2,
    [4] = 1.25,
    [5] = 1.3,
}
local levelToPace = {}
for key, value in pairs(levelScale) do
	levelToPace[key] = 1/value
end

local function GetLevel()
	local ud = UnitDefs[unitDefID]
	return Spring.GetUnitRulesParam(unitID, "comm_level") or tonumber(ud.customParams.level) or 0
end

local function CalculatePaceMult()
	paceMult = levelToPace[GetLevel()] or levelToPace[5]
	return paceMult
end

local function GetPace()
	return paceMult or CalculatePaceMult()
end

local function CalculateScaleMult()
	scaleMult = levelScale[GetLevel()] or levelScale[5]
	return scaleMult
end

local function GetScale()
	return scaleMult or CalculateScaleMult()
end

local function GetWeapon(num)
	local retNum = GG.Upgrades_WeaponNumMap(unitID, num) or weaponNumMap[num]
	if retNum then
		return retNum
	end
	if not weaponsInitialized then
		local tempWeapon1 = Spring.GetUnitRulesParam(unitID, "comm_weapon_num_1")
		local tempWeapon2 = Spring.GetUnitRulesParam(unitID, "comm_weapon_num_2")
		local tempShield = Spring.GetUnitRulesParam(unitID, "comm_shield_num")
		if num == tempWeapon1 then
			return 1
		elseif num == tempWeapon2 then
			return 2
		elseif num == tempShield then
			return 3
		end
	end
	return false
end

local function EmitWeaponFireSfx(pieceNum, num)
	local weaponNum = GetWeapon(num)
	if Spring.GetCEGID then
		if weaponCegs[weaponNum] and weaponCegs[weaponNum].misc then
			EmitSfx(pieceNum, weaponCegs[weaponNum].misc)
		end
	else
		if weaponNum == 1 then
			if weapon1 then
				EmitSfx(pieceNum, 1029 + weapon1*2)
			end
		elseif weaponNum == 2 then
			if weapon1 then
				EmitSfx(pieceNum, 1029 + weapon2*2)
			end
		end
	end
end

local function EmitWeaponShotSfx(pieceNum, num)
	local weaponNum = GetWeapon(num)
	if Spring.GetCEGID then
		if weaponCegs[weaponNum] and weaponCegs[weaponNum].muzzle then
			EmitSfx(pieceNum, weaponCegs[weaponNum].muzzle)
		end
	else
		if weaponNum == 1 then
			if weapon1 then
				EmitSfx(pieceNum, 1030 + weapon1*2)
			end
		elseif weaponNum == 2 then
			if weapon2 then
				EmitSfx(pieceNum, 1030 + weapon2*2)
			end
		end
	end
end

local function GetCegTable(wd)
	if not Spring.GetCEGID then
		return
	end
	local cp = wd.customParams
	if not (cp and (cp.muzzleeffectshot or cp.misceffectshot)) then
		return
	end
	local cegs = {
		muzzle = cp.muzzleeffectshot and (SFX.GLOBAL + Spring.GetCEGID(cp.muzzleeffectshot:gsub("custom:",""))),
		misc = cp.misceffectshot and (SFX.GLOBAL + Spring.GetCEGID(cp.misceffectshot:gsub("custom:",""))),
	}
	return cegs
end

local function DoExtraWeaponStuff(extraInfo, weaponNum, wd, weaponID)
	local INLOS = {inlos = true}
	local ei = extraInfo
	if ei.reloadBonus ~= 0 or ei.reloadOverride then
		local reloadBonus
		if ei.reloadBonus < 0 then
			reloadBonus = 1 / (-ei.reloadBonus + 1)
		else
			reloadBonus = 1 + ei.reloadBonus
		end
		local newReloadTime = ei.reloadOverride or wd.reload
		newReloadTime = math.max(math.ceil(((newReloadTime * 30) / reloadBonus)), 1) / 30 -- multiply by 30 to do frame rounding.
		Spring.SetUnitWeaponState(unitID, weaponID, "reloadTime", newReloadTime)
		Spring.SetUnitRulesParam(unitID, weaponID .. "_basereload", newReloadTime, INLOS)
	end
	if ei.burstOverride then
		Spring.SetUnitWeaponState(unitID, weaponID, "burst", ei.burstOverride)
		Spring.SetUnitRulesParam(unitID, weaponID .. "_updatedburst_count", ei.burstOverride, INLOS)
	end
	if ei.burstRateOverride then
		Spring.SetUnitWeaponState(unitID, weaponID, "burstRate", ei.burstRateOverride)
		Spring.SetUnitRulesParam(unitID, weaponID .. "_baseburstrate", ei.burstRateOverride, INLOS)
	end
	if ei.accuracyBonus ~= 1 or ei.accuracyOverride then
		local newAccuracy = ei.accuracyOverride or wd.accuracy
		newAccuracy = math.max(newAccuracy - (newAccuracy * (1 - ei.accuracyBonus)), 0)
		Spring.SetUnitWeaponState(unitID, weaponID, "accuracy", newAccuracy)
		Spring.SetUnitRulesParam(unitID, weaponID .. "_accuracy", newAccuracy, INLOS)
	end
	if ei.projectileSpeedBonus ~= 1 then
		if ei.projectileSpeedBonus < 0.05 then ei.projectileSpeedBonus = 0.05 end
		local newSpeed = math.max(wd.projectilespeed * ei.projectileSpeedBonus, 10)
		Spring.SetUnitWeaponState(unitID, weaponID, "projectileSpeed", newSpeed)
		Spring.SetUnitRulesParam(unitID, weaponID .. "_speed", newSpeed, INLOS)
	end
	if ei.projectileBonus ~= 0 or ei.projectileOverride then
		local baseProjectiles = ei.projectileOverride or wd.projectiles
		local newProjectileCount = math.max(baseProjectiles + ei.projectileBonus, 1)
		Spring.SetUnitWeaponState(unitID, weaponID, "projectiles", newProjectileCount)
		Spring.SetUnitRulesParam(unitID, weaponID .. "_projectilecount_override", newProjectileCount, INLOS)
	end
	if ei.sprayAngleBonus or ei.sprayAngleOverride then
		local baseSprayAngle = ei.sprayAngleOverride or wd.sprayAngle
		local bonus = ei.sprayAngleBonus + 1
		if bonus < 0 then bonus = 0 end
		local newSprayAngle = math.max(baseSprayAngle * bonus, 0)
		Spring.SetUnitWeaponState(unitID, weaponID, "sprayAngle", newSprayAngle)
		Spring.SetUnitRulesParam(unitID, weaponID .. "_sprayangle", newSprayAngle, INLOS)
	end
end

local function UpdateWeapons(weaponName1, weaponName2, shieldName, rangeMult, damageMult, extraInfo)
	local weaponDef1 = weaponName1 and unitWeaponNames[weaponName1]
	local weaponDef2 = weaponName2 and unitWeaponNames[weaponName2] 
	local shieldDef = shieldName and unitWeaponNames[shieldName]
	local wd1 = weaponDef1 and WeaponDefs[weaponDef1.weaponDefID]
	local wd2 = weaponDef2 and WeaponDefs[weaponDef2.weaponDefID] or nil
	
	weapon1 = weaponDef1 and weaponDef1.num
	weapon2 = weaponDef2 and (weaponDef2.num2 or weaponDef2.num)
	shield  = shieldDef and shieldDef.num
	
	if weapon1 then
		Spring.SetUnitRulesParam(unitID, "comm_weapon_name_1", weaponName1, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_weapon_id_1", (weaponDef1 and weaponDef1.weaponDefID) or 0, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_weapon_num_1", weapon1, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_weapon_manual_1", (weaponDef1 and weaponDef1.manualFire and 1) or 0, INLOS)
		weaponCegs[1] = GetCegTable(WeaponDefs[weaponDef1.weaponDefID])
	end
	
	if weapon2 then
		Spring.SetUnitRulesParam(unitID, "comm_weapon_name_2", weaponName2, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_weapon_id_2", (weaponDef2 and weaponDef2.weaponDefID) or 0, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_weapon_num_2", weapon2, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_weapon_manual_2", (weaponDef2 and weaponDef2.manualFire and 1) or 0, INLOS)
		weaponCegs[2] = GetCegTable(WeaponDefs[weaponDef2.weaponDefID])
	end

	if shield then
		Spring.SetUnitRulesParam(unitID, "comm_shield_name", shieldName, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_shield_id", shieldDef.weaponDefID, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_shield_num", shield, INLOS)
		Spring.SetUnitRulesParam(unitID, "comm_shield_max", WeaponDefs[shieldDef.weaponDefID].shieldPower, INLOS)
	else
		Spring.SetUnitRulesParam(unitID, "comm_shield_max", 0, INLOS)
	end
	
	weaponNumMap = {}
	if weapon1 then
		weaponNumMap[weapon1] = 1
	end
	if weapon2 then
		weaponNumMap[weapon2] = 2
	end
	if shield then
		weaponNumMap[shield] = 3
	end
	
	local hasManualFire = (weaponDef1 and weaponDef1.manualFire) or (weaponDef2 and weaponDef2.manualFire)
	local cmdDesc = Spring.FindUnitCmdDesc(unitID, CMD.MANUALFIRE)
	if not hasManualFire and cmdDesc then
		Spring.RemoveUnitCmdDesc(unitID, cmdDesc)
	elseif hasManualFire and not cmdDesc then
		cmdDesc = Spring.FindUnitCmdDesc(unitID, CMD.ATTACK) + 1 -- insert after attack so that it appears in the correct spot in the menu
		Spring.InsertUnitCmdDesc(unitID, cmdDesc, dgunTable)
	end

	local maxRange = 0
	local otherRange = false
	if weapon1 then
		local baserange = extraInfo[1].rangeOverride or tonumber(WeaponDefs[weaponDef1.weaponDefID].range)
		isManual[weapon1] = weaponDef1.manualFire
		local damageBooster = math.max(1 + extraInfo[1].damageBoost, 0.01)
		local range = baserange*rangeMult
		if weaponDef1.manualFire then
			otherRange = range
		else
			maxRange = range
		end
		Spring.SetUnitWeaponState(unitID, weapon1, "range", range)
		Spring.SetUnitWeaponDamages(unitID, weapon1, "dynDamageRange", range)
		
		
		local damages = WeaponDefs[weaponDef1.weaponDefID].damages
		for k, v in pairs(damages) do
			if type(k) == "number" then
				Spring.SetUnitWeaponDamages(unitID, weapon1, k, (v * damageBooster) * damageMult)
			end
		end
		Spring.SetUnitRulesParam(unitID, weapon1 .. "_actual_dmgboost", damageBooster * damageMult)
		DoExtraWeaponStuff(extraInfo[1], 1, wd1, weapon1)
	end
	
	if weapon2 then
		local baserange = extraInfo[2].rangeOverride or tonumber(WeaponDefs[weaponDef2.weaponDefID].range) -- why does this need ToNumber?
		isManual[weapon2] = weaponDef2.manualFire
		local range = baserange*rangeMult
		if maxRange then
			if weaponDef2.manualFire then
				otherRange = range
			elseif range > maxRange then
				otherRange = maxRange
				maxRange = range
			elseif range < maxRange then
				otherRange = range
			end
		else
			maxRange = range
		end
		Spring.SetUnitWeaponState(unitID, weapon2, "range", range)
		Spring.SetUnitWeaponDamages(unitID, weapon2, "dynDamageRange", range)
		local damageBooster = math.max(1 + extraInfo[2].damageBoost, 0.01)
		local damages = WeaponDefs[weaponDef2.weaponDefID].damages
		for k, v in pairs(damages) do
			if type(k) == "number" then
				Spring.SetUnitWeaponDamages(unitID, weapon2, k, (v * damageBooster) * damageMult)
			end
		end
		Spring.SetUnitRulesParam(unitID, weapon2 .. "_actual_dmgboost", damageBooster * damageMult)
		DoExtraWeaponStuff(extraInfo[2], 2, wd2, weapon2)
	end
	
	if weapon1 then
		if weapon2 then
			Spring.SetUnitRulesParam(unitID, "primary_weapon_override",  weapon1, INLOS)
			Spring.SetUnitRulesParam(unitID, "secondary_weapon_override",  weapon2, INLOS)
			
			local range1 = Spring.GetUnitWeaponState(unitID, weapon1, 'range')
			local range2 = Spring.GetUnitWeaponState(unitID, weapon2, 'range')
			if range1 > range2 then
				Spring.SetUnitRulesParam(unitID, "primary_weapon_range",  weapon1, INLOS)
			else
				Spring.SetUnitRulesParam(unitID, "primary_weapon_range",  weapon2, INLOS)
			end
		else
			Spring.SetUnitRulesParam(unitID, "primary_weapon_override",  weapon1, INLOS)
			Spring.SetUnitRulesParam(unitID, "primary_weapon_range",  weapon1, INLOS)
		end
	end
	
	-- Set other ranges to 0 for leashing
	if weapon1 ~= 1 and weapon2 ~= 1 then
		Spring.SetUnitWeaponState(unitID, 1, "range", maxRange)
	end
	for i = 2, 32 do
		if i ~= weapon1 and i ~= weapon2 then
			Spring.SetUnitWeaponState(unitID, i, "range", 0)
		end
	end
	Spring.SetUnitMaxRange(unitID, maxRange)
	local sightbonus = Spring.GetUnitRulesParam(unitID, "sightBonus") or 1
	Spring.SetUnitRulesParam(unitID, "sightRangeOverride", math.max(500, math.min(600, maxRange*1.1)) * sightbonus, INLOS)
	Spring.SetUnitRulesParam(unitID, "sonarRangeOverride", math.max(500, math.min(600, maxRange*1.1)) * sightbonus, INLOS)
	
	if otherRange then
		Spring.SetUnitRulesParam(unitID, "secondary_range", otherRange, INLOS)
	end
	
	-- shields
	for i = 1, #shields do
		--Spring.SetUnitShieldState(unitID, shields[i], false)
	end
	
	if (shield) then
		Spring.SetUnitShieldState(unitID, shield, true)
	end
	
	weaponsInitialized = true
end

local function SetupSpooling()
	local spool1 = false
	local spool2 = false
	local weaponname1 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1")
	local weaponname2 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_2")
	if weaponname1 then 
		local cp1 = WeaponDefs[unitWeaponNames[weaponname1].weaponDefID].customParams
		if cp1.recycler then
			--Spring.Echo("Weapon 1 is recycler!")
			GG.FireControl.ForceAddUnit(unitID, 1, tonumber(cp1["script_reload"]) * 30, tonumber(cp1["recycle_bonus"]), tonumber(cp1["recycle_reductionframes"]) * 30, tonumber(cp1["recycle_reduction"]), tonumber(cp1["recycle_reductiontime"]) * 30, tonumber(cp1["recycle_maxbonus"]), 0)
			spool1 = true
		end
	end
	if weaponname2 then
		local cp2 = WeaponDefs[unitWeaponNames[weaponname2].weaponDefID].customParams
		if cp2.recycler then
			--Spring.Echo("Weapon 2 is recycler!")
			GG.FireControl.ForceAddUnit(unitID, 2, tonumber(cp2["script_reload"]) * 30, tonumber(cp2["recycle_bonus"]), tonumber(cp2["recycle_reductionframes"]) * 30, tonumber(cp2["recycle_reduction"]), tonumber(cp2["recycle_reductiontime"]) * 30, tonumber(cp2["recycle_maxbonus"]), 0)
			spool2 = true
		end
	end
	return spool1, spool2
end

local function SetupAiming()
	local aimconfig = {[1] = {}, [2] = {}}
	local weaponname1 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1")
	local weaponname2 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_2")
	if weaponname1 then
		local cp1 = WeaponDefs[unitWeaponNames[weaponname1].weaponDefID].customParams
		if cp1.aimdelay then
			aimconfig[1].allowedpitch = cp1.allowedpitcherror
			aimconfig[1].allowedheadingerror = cp1.allowedheadingerror
			aimconfig[1].aimtime = cp1.aimdelay
		end
	end
	if weaponname2 then
		local cp2 = WeaponDefs[unitWeaponNames[weaponname2].weaponDefID].customParams
		if cp2.aimdelay then
			aimconfig[1].allowedpitch = cp2.allowedpitcherror
			aimconfig[1].allowedheadingerror = cp2.allowedheadingerror
			aimconfig[1].aimtime = cp2.aimdelay
		end
	end
	local aimbonus
	if aimconfig[1].aimtime or aimconfig[2].aimtime then
		
	end
	if aimconfig[1].aimtime and aimconfig[2].aimtime then
		Spring.SetUnitRulesParam(unitID, "comm_aimtime", math.max(aimconfig[1].aimtime, aimconfig[2].aimtime) * (Spring.GetUnitRulesParam(unitID, "comm_aimbonus") or 1), INLOS)
	elseif aimconfig[1].aimtime or aimconfig[2].aimtime then
		Spring.SetUnitRulesParam(unitID, "comm_aimtime", (aimconfig[1].aimtime or aimconfig[2].aimtime) * (Spring.GetUnitRulesParam(unitID, "comm_aimbonus") or 1), INLOS)
	end
	return aimconfig
end

local function GetOKP()
	local okp = {}
	local weaponname1 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1")
	local weaponname2 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_2")
	local damageMult = Spring.GetUnitRulesParam(unitID, "comm_damage_mult") or 1
	--Spring.Echo("GetOKP: " .. tostring(weaponname1) .. ", " .. tostring(weaponname2))
	local wep1 = WeaponDefs[unitWeaponNames[weaponname1].weaponDefID]
	local wep2 = weaponname2 and WeaponDefs[unitWeaponNames[weaponname2].weaponDefID] or nil
	okp[1] = {useokp = wep1.customParams["use_okp"] ~= nil}
	if wep2 ~= nil then
		okp[2] = {useokp = wep2.customParams["use_okp"] ~= nil}
	else
		okp[2] = {useokp = false}
	end
	if okp[1].useokp then
		okp[1].damage = (tonumber(wep1.customParams["okp_damage"]) or 0) * damageMult
		okp[1].speedmult = tonumber(wep1.customParams["okp_speedmult"]) or 1
		okp[1].structureonly = wep1.customParams["okp_structureonly"] ~= nil
		okp[1].radarmult = tonumber(wep1.customParams["okp_radarmult"]) or 1
		okp[1].timeout = tonumber(wep1.customParams["okp_timeout"]) or 30
	end
	if okp[2].useokp then
		okp[2].damage = tonumber(wep2.customParams["okp_damage"]) or 0 * damageMult
		okp[2].speedmult = tonumber(wep2.customParams["okp_speedmult"]) or 1
		okp[2].structureonly = wep2.customParams["okp_structureonly"] ~= nil
		okp[2].radarmult = tonumber(wep2.customParams["okp_radarmult"]) or 1
		okp[2].timeout = tonumber(wep2.customParams["okp_timeout"]) or 30
	end
	return okp
end

local function SetUpBatteryThread()
	local weaponname1 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1")
	while weaponname1 == nil do -- dynamic comm not set up yet
		weaponname1 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1")
		Sleep(33)
	end
	local battery = {}
	local weaponname2 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_2")
	local efficiency = Spring.GetUnitRulesParam(unitID, "comm_battery_efficiency") or 1
	local wep1 = WeaponDefs[unitWeaponNames[weaponname1].weaponDefID]
	local wep2 = weaponname2 and WeaponDefs[unitWeaponNames[weaponname2].weaponDefID] or nil
	if wep2 ~= nil then
		battery[2] = (tonumber(wep2.customParams["batterydrain"]) or 0) / efficiency
	end
	battery[1] = (tonumber(wep1.customParams["batterydrain"]) or 0) / efficiency
	local needsBattery = false
	if battery[1] > 0 or (battery[2] and battery[2] > 0) then
		needsBattery = true
	end
	return needsBattery
end

local function SetUpBattery()
	StartThread(SetUpBatteryThread)
end

local function Create()
	-- copy the dgun command table because we sometimes need to reinsert it
	local cmdID = Spring.FindUnitCmdDesc(unitID, CMD.MANUALFIRE)
	dgunTable = Spring.GetUnitCmdDescs(unitID, cmdID)[1]
	
	if Spring.GetUnitRulesParam(unitID, "comm_weapon_id_1") then
		UpdateWeapons(
			Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1"),
			Spring.GetUnitRulesParam(unitID, "comm_weapon_name_2"),
			Spring.GetUnitRulesParam(unitID, "comm_shield_name"),
			Spring.GetUnitRulesParam(unitID, "comm_range_mult") or 1,
			Spring.GetUnitRulesParam(unitID, "comm_damage_mult") or 1
		)
	end
end

local function DoDeathExplosion(x, y, z)
	local explosion = Spring.GetUnitRulesParam(unitID, "comm_deathexplosion")
	local alt = "commexplosion_default"
	if Spring.GetUnitIsStunned(unitID) or (Spring.GetUnitRulesParam(unitID, "disarmed") == 1) then
		explosion = alt
	end
	--Spring.Echo("Spawning " .. tostring(explosion))
	Spring.SpawnProjectile(WeaponDefNames[explosion].id, {
			pos = {x, y, z},
			["end"] = {x, y, z},
			speed = {0, 0, 0},
			ttl = 1,
			gravity = 0,
			team = Spring.GetGaiaTeamID(),
			owner = unitID,
		})
	return explosion ~= alt
end

local function PriorityAimCheck(weaponNum)
	--local num = unitWeaponNames[Spring.GetUnitRulesParam(unitID, "comm_weapon_name_" .. weaponNum].num
	local reloadFrame = Spring.GetUnitWeaponState(unitID, weaponNum, "reloadState")
	if reloadFrame == nil then return true end
	return reloadFrame <= Spring.GetGameFrame()
end

local function SpawnModuleWreck(moduleDefID, wreckLevel, totalCount, teamID, x, y, z, vx, vy, vz)
	local featureDefID = FeatureDefNames[moduleWreckNamePrefix[wreckLevel] .. moduleDefID]
	if not featureDefID then
		Spring.Echo("Cannot find module wreck", moduleWreckNamePrefix[wreckLevel] .. moduleDefID)
		return
	end
	featureDefID = featureDefID.id
	
	local dir = math.random()*2*math.pi
	local pitch = ((math.random()*2)^2 - 1)*math.pi/2
	local heading = math.random(65536)
	local mag = 60 + math.random()*(30 + 5*math.min(totalCount, 15))
	local horScale = mag*math.cos(pitch)
	vx, vy, vz = vx + math.cos(dir)*horScale, vy + math.sin(pitch)*mag, vz + math.sin(dir)*horScale
	
	local featureID = Spring.CreateFeature(featureDefID, x + vx, y, z + vz, heading, teamID)
end

local function SpawnModuleWrecks(wreckLevel)
	local x, y, z, mx, my, mz = Spring.GetUnitPosition(unitID, true)
	local vx, vy, vz = Spring.GetUnitVelocity(unitID)
	local teamID	= Spring.GetUnitTeam(unitID)
	local wreckLevel = wreckLevel or 2
	
	local moduleCount = Spring.GetUnitRulesParam(unitID, "comm_module_count") or 0;
	for i = 1, moduleCount do
		SpawnModuleWreck(Spring.GetUnitRulesParam(unitID, "comm_module_" .. i), wreckLevel, moduleCount, teamID, x, y, z, vx, vy, vz)
	end
end

local function TransferParamToFeature(featureID, paramName)
	Spring.SetFeatureRulesParam(featureID, paramName, Spring.GetUnitRulesParam(unitID, paramName), INLOS)
end

local function SetUpFeatureRules(featureID)
	local moduleCount = Spring.GetUnitRulesParam(unitID, "comm_module_count") or 0;
	local mass = Spring.GetUnitRulesParam(unitID, "massOverride")
	local _, maxHealth = Spring.GetUnitHealth(unitID)
	local cost = Spring.GetUnitRulesParam(unitID, "comm_cost")
	-- For context menu purposes --
	local decorationCount = Spring.GetUnitRulesParam(unitID, "comm_decoration_count")
	--Spring.Echo("decorationCount = " .. tostring(decorationCount))
	TransferParamToFeature(featureID, "comm_decoration_count")
	if decorationCount and decorationCount > 0 then
		for i = 1, decorationCount do
			TransferParamToFeature(featureID, "comm_decoration_" .. i)
		end
	end
	TransferParamToFeature(featureID, "upgradesSpeedMult")
	TransferParamToFeature(featureID, "carrier_count_drone")
	TransferParamToFeature(featureID, "comm_weapon_num_1")
	TransferParamToFeature(featureID, "comm_weapon_num_2")
	TransferParamToFeature(featureID, "comm_shield_num")
	TransferParamToFeature(featureID, "comm_damage_mult")
	TransferParamToFeature(featureID, "comm_range_mult")
	TransferParamToFeature(featureID, "buildpower_mult")
	TransferParamToFeature(featureID, "comm_area_cloak")
	TransferParamToFeature(featureID, "comm_area_cloak_upkeep")
	TransferParamToFeature(featureID, "comm_area_cloak_radius")
	TransferParamToFeature(featureID, "commander_reconpulse")
	TransferParamToFeature(featureID, "comm_personal_cloak")
	TransferParamToFeature(featureID, "comm_decloak_distance")
	TransferParamToFeature(featureID, "commcloakregen")
	TransferParamToFeature(featureID, "commrecloaktime")
	TransferParamToFeature(featureID, "radarRangeOverride")
	TransferParamToFeature(featureID, "jammingRangeOverride")
	TransferParamToFeature(featureID, "comm_jumprange_bonus")
	TransferParamToFeature(featureID, "comm_jumpreload_bonus")
	TransferParamToFeature(featureID, "comm_autorepair_rate")
	TransferParamToFeature(featureID, "commander_healthbonus")
	TransferParamToFeature(featureID, "comm_jammed")
	TransferParamToFeature(featureID, "commander_storage_override")
	TransferParamToFeature(featureID, "wanted_metalIncome")
	TransferParamToFeature(featureID, "wanted_energyIncome")
	TransferParamToFeature(featureID, "sightRangeOverride")
	TransferParamToFeature(featureID, "fireproof")
	TransferParamToFeature(featureID, "comm_drone_range")
	TransferParamToFeature(featureID, "carrier_count_dronecon")
	TransferParamToFeature(featureID, "carrier_count_droneassault")
	TransferParamToFeature(featureID, "carrier_count_droneheavyslow")
	TransferParamToFeature(featureID, "carrier_count_drone")
	if weapon2 then
		TransferParamToFeature(featureID, weapon2 .. "_sprayangle")
		TransferParamToFeature(featureID, weapon2 .. "_speed")
		TransferParamToFeature(featureID, weapon2 .. "_projectilecount_override")
		TransferParamToFeature(featureID, weapon2 .. "_accuracy")
		TransferParamToFeature(featureID, weapon2 .. "_updatedburst_count")
		TransferParamToFeature(featureID, weapon2 .. "_baseburstrate")
		TransferParamToFeature(featureID, weapon2 .. "_basereload")
		TransferParamToFeature(featureID, weapon2 .. "_actual_dmgboost")
	end
	TransferParamToFeature(featureID, weapon1 .. "_speed")
	TransferParamToFeature(featureID, weapon1 .. "_projectilecount_override")
	TransferParamToFeature(featureID, weapon1 .. "_sprayangle")
	TransferParamToFeature(featureID, weapon1 .. "_accuracy")
	TransferParamToFeature(featureID, weapon1 .. "_baseburstrate")
	TransferParamToFeature(featureID, weapon1 .. "_updatedburst_count")
	TransferParamToFeature(featureID, weapon1 .. "_basereload")
	TransferParamToFeature(featureID, weapon1 .. "_actual_dmgboost")
	
	-- Things tooltips need --
	TransferParamToFeature(featureID, "commander_owner")
	
	-- Set health --
	Spring.SetFeatureMaxHealth(featureID, maxHealth)
	Spring.SetFeatureHealth(featureID, maxHealth)
	-- Things we actually need --
	TransferParamToFeature(featureID, "comm_extra_drones")
	TransferParamToFeature(featureID, "comm_drone_buildrate")
	TransferParamToFeature(featureID, "comm_banner_overhead")
	TransferParamToFeature(featureID, "comm_texture")
	TransferParamToFeature(featureID, "comm_profileID")
	TransferParamToFeature(featureID, "comm_chassis")
	TransferParamToFeature(featureID, "comm_baseWreckID")
	TransferParamToFeature(featureID, "comm_baseHeapID")
	TransferParamToFeature(featureID, "comm_baseUnitDefID")
	TransferParamToFeature(featureID, "comm_module_count")
	TransferParamToFeature(featureID, "comm_name")
	TransferParamToFeature(featureID, "comm_level")
	TransferParamToFeature(featureID, "comm_cost")
	TransferParamToFeature(featureID, "massOverride") -- may not be necessary!
	Spring.SetFeatureMass(featureID, mass)
	Spring.SetFeatureResources(featureID, cost * 0.4, 0, cost * 0.4, 1.0, cost, cost)
	for i = 1, moduleCount do
		local commanderModule = Spring.GetUnitRulesParam(unitID, "comm_module_" .. i)
		Spring.SetFeatureRulesParam(featureID, "comm_module_" .. i, commanderModule)
	end
end

local function SpawnWreck(wreckLevel)
	local makeRezzable = (wreckLevel == 1)
	local wreckDef = FeatureDefs[Spring.GetUnitRulesParam(unitID, commWreckUnitRulesParam[wreckLevel])]
	local x, y, z = Spring.GetUnitPosition(unitID)
	
	local vx, vy, vz = Spring.GetUnitVelocity(unitID)
	
	if (wreckDef) then
		local heading   = Spring.GetUnitHeading(unitID)
		local teamID	= Spring.GetUnitTeam(unitID)
		local featureID = Spring.CreateFeature(wreckDef.id, x, y, z, heading, teamID)
		Spring.SetFeatureVelocity(featureID, vx, vy, vz)
		if makeRezzable then
			--local baseUnitDefID = Spring.GetUnitRulesParam(unitID, "comm_baseUnitDefID") or unitDefID
			Spring.SetFeatureResurrect(featureID, UnitDefs[Spring.GetUnitDefID(unitID)].name)
			SetUpFeatureRules(featureID)
		else
			SpawnModuleWrecks(2)
		end
	end
end

return {
	SetUpBattery      = SetUpBattery,
	GetPace           = GetPace,
	GetScale          = GetScale,
	GetWeapon         = GetWeapon,
	EmitWeaponFireSfx = EmitWeaponFireSfx,
	EmitWeaponShotSfx = EmitWeaponShotSfx,
	UpdateWeapons     = UpdateWeapons,
	IsManualFire      = IsManualFire,
	Create            = Create,
	SpawnModuleWrecks = SpawnModuleWrecks,
	SpawnWreck        = SpawnWreck,
	GetOKPConfig      = GetOKP,
	Explode			  = DoDeathExplosion,
	SetupSpooling     = SetupSpooling,
	PriorityAimCheck  = PriorityAimCheck,
}
