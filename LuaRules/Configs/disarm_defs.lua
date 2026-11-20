
local FRAMES_PER_SECOND = Game.gameSpeed
local disarmWeapons = {}
local paraWeapons = {}
local overstunDamageMult = {}
local wantedWeaponList = {}

for wid = 1, #WeaponDefs do
	local wd = WeaponDefs[wid]
	local wcp = wd.customParams or {}
	if wcp.disarmdamagemult then
		local overstun_time = wcp.overstun_time
		if not overstun_time then
			Spring.Echo("WARNING: No overstun_time found for weaponDef ID: " .. wid .. "(" .. tostring(wd.name) .. "). Defaulting to 1")
			overstun_time = 1
		end
		disarmWeapons[wid] = {
			damageMult = wcp.disarmdamagemult,
			normalDamage = 1 - (wcp.disarmdamageonly or 0),
			disarmTimer = wcp.disarmtimer*FRAMES_PER_SECOND,
			overstunTime = overstun_time*FRAMES_PER_SECOND,
		}
		wantedWeaponList[#wantedWeaponList + 1] = wid
	elseif wd.paralyzer or wd.customParams.extra_damage then
		local overstun_time = wcp.overstun_time
		if not overstun_time then
			overstun_time = 1
			Spring.Echo("WARNING: No overstun_time found for weaponDef ID: " .. wid .. "(" .. tostring(wd.name) .. "). Defaulting to 1")
		end
		local paraTime = wd.paralyzer and wd.customParams.emp_paratime or wd.customParams.extra_paratime
		if not paraTime then
			Spring.Echo("WARNING: paraTime nil! WeaponID: " .. wid .. "(" .. tostring(wd.name) .. "). Check emp_paratime (" .. tostring(wd.customParams.emp_paratime) .. ") or extra_paratime (" .. tostring(wd.customParams.extra_paratime))
		end
		paraWeapons[wid] = {
			empTime = paraTime * FRAMES_PER_SECOND,
			overstunTime = overstun_time*FRAMES_PER_SECOND,
		}
		wantedWeaponList[#wantedWeaponList + 1] = wid
	end
	if wd.customParams and wd.customParams.overstun_damage_mult then
		overstunDamageMult[wid] = tonumber(wd.customParams.overstun_damage_mult)
	end
end
return disarmWeapons, paraWeapons, overstunDamageMult, wantedWeaponList
