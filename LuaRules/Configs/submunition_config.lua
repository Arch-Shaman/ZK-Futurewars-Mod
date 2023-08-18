local config = {}

local i, m, j
local debugMode = false
local spreadModes = {"none", "cylY", "cylX", "cylZ", "box", "sphere"}
local spreadModesCount = #spreadModes
for i=1, spreadModesCount do
	spreadModes[spreadModes[i]] = i
end

local function throw(str)
	Spring.Log(GetInfo().name, "fatal", "[submunition_config.lua] Weapondefs Error: "..str)
end

local function InclusiveBoolCast(string, default)
	if string == nil then
		return default
	else
		return (string and string ~= "false" and string ~= "0")
	end
end

Spring.Echo("CAS: Discovered ()")

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if curRef and (curRef.projectile1 or curRef.spawnsfx) then -- found it!
		if debugMode then
			Spring.Echo("CAS: Discovered " .. i .. "(" .. wd.name .. ")")
		end
		if not ((type(curRef.spawndist) == "string") or curRef.noairburst) then
			throw(wd.name.." has neither spawndist nor noairburst!")
		end
		Script.SetWatchWeapon(i, true)
		if debugMode then
			Spring.Echo("[CAS] Enabled watch for " .. i)
		end
		--parent projectile Defs
		config[i] = {}
		local projConfig = config[i]
		projConfig["spawndist"] = tonumber(curRef.spawndist)
		projConfig.timer = tonumber(curRef.timeddeploy) or math.huge
		projConfig["use2ddist"] = InclusiveBoolCast(curRef.use2ddist)
		projConfig["isBomb"] = wd.type == "AircraftBomb"
		projConfig["launcher"] = wd.type == "StarburstLauncher"
		projConfig["timeoutspawn"] = InclusiveBoolCast(curRef.timeoutspawn, true) 
		projConfig["proxy"] = InclusiveBoolCast(curRef.proxy)
		projConfig["proxydist"] = tonumber(curRef.proxydist) or projConfig["spawndist"] or 0
		projConfig["alwaysvisible"] = InclusiveBoolCast(curRef.alwaysvisible) -- FIXME: read and use spring's native alwaysvisible flag
		projConfig["clustercharges"] = tonumber(curRef.clustercharges) or 1
		projConfig["clusterdelay"] = tonumber(curRef.clusterdelay) or 5
		projConfig["clusterdelaytype"] = tonumber(curRef.clusterdelaytype) or 0
		projConfig["useheight"] = projConfig["isBomb"] or InclusiveBoolCast(curRef.useheight) -- bombs ignore distance and explode based on height. This is due to bomb ground attacks being absolutely fucked in current spring build.
		projConfig["dynDamage"] = InclusiveBoolCast(curRef.dyndamage)
		projConfig["airburst"] = not InclusiveBoolCast(curRef.noairburst)
		projConfig["useasl"] = InclusiveBoolCast(curRef.useasl)
		projConfig["onExplode"] = InclusiveBoolCast(curRef.onexplode)
		projConfig["usertarget"] = InclusiveBoolCast(curRef.usertargetable)
		projConfig["noceg"] = InclusiveBoolCast(curRef.clusternoceg)
		projConfig["block_check_during_cruise"] = InclusiveBoolCast(cas_nocruisecheck)
		if projConfig.useheight then
			projConfig.maxvelocity = tonumber(curRef.maxvelocity) or (projConfig["isBomb"] and math.huge or 0)
		end
		-- child projectile defs
		-- the basic idea is this. instead of pulling let say curRef.projectile we pull curRef.projectile1 or curRef.projectile2 for the different
		-- projectiles that the bullet splits into
		projConfig["frags"] = {}
		local fragnum = 1
		while (curRef["projectile" .. fragnum] or tonumber(curRef["spawnsfx" .. fragnum])) do
			projConfig["frags"][fragnum] = {}
			local fragConfig = projConfig["frags"][fragnum]
			local projectile = curRef["projectile" .. fragnum]
			if not WeaponDefNames[projectile] then
				throw("frag #"..fragnum.." of "..wd.name.." has an invalid projectile param")
			end
			fragConfig["projectile"] = WeaponDefNames[projectile].id -- transform into an id
			fragConfig["spawnsfx"] = tonumber(curRef["spawnsfx" .. fragnum])
			fragConfig["numprojectiles"] = tonumber(curRef["numprojectiles" .. fragnum]) or 1
			if curRef["posspread"..fragnum] then
				posdata = Spring.Utilities.ExplodeString(",", curRef["posspread"..fragnum])
				for j=1, 3 do
					local a = tonumber(posdata[j])
					if not a then
						throw("frag #"..fragnum.." of "..wd.name.." has an invalid posspread param. The first 3 values must all be non-nil")
					end
					local b = tonumber(posdata[j+3]) or -a
					posdata[j], posdata[j+3] = (a+b)/2, (a-b)/2
				end
				fragConfig["posSpread"] = posdata
				spreadMode = curRef["posspreadmode"..fragnum] or "cylY"
				if spreadModes[spreadMode] then
					fragConfig["posSpreadMode"] = spreadModes[spreadMode]
				else
					throw("frag #"..fragnum.." of "..wd.name.." has an invalid posspreadmode param")
				end
			else
				fragConfig["posSpreadMode"] = spreadModes["none"]
			end
			if curRef["velspread"..fragnum] then
				veldata = Spring.Utilities.ExplodeString(",", curRef["velspread"..fragnum], ",")
				for j=1, 3 do
					local a = tonumber(veldata[j])
					if not a then
						throw("frag #"..fragnum.." of "..wd.name.." has an invalid velspread param. The first 3 values must all be non-nil")
					end
					local b = tonumber(veldata[j+3]) or -a
					veldata[j], veldata[j+3] = (a+b)/2, (a-b)/2
				end
				fragConfig["velSpread"] = veldata
				spreadMode = curRef["velspreadmode"..fragnum] or "cylY"
				if spreadModes[spreadMode] then
					fragConfig["velSpreadMode"] = spreadModes[spreadMode]
				else
					throw("frag #"..fragnum.." of "..wd.name.." has an invalid posspreadmode param")
				end
			else
				fragConfig["velSpreadMode"] = spreadModes["none"]
			end
			local keepmomentum = curRef["keepmomentum" .. fragnum]
			if type(keepmomentum) ~= "string" then
				if not projConfig["onExplode"] then
					fragConfig["keepmomentum"] = {1,1,1}
				end
			else
				if string.find(keepmomentum,",") then -- projectile velocity offsets
					fragConfig["keepmomentum"] = {}
					fragConfig["keepmomentum"] = table.pack(keepmomentum:match("([^,]+),([^,]+),([^,]+)"))
					for j=1, 3 do
						fragConfig["keepmomentum"][j] = tonumber(fragConfig["keepmomentum"][j])
					end
				else
					fragConfig.keepmomentum = {}
					for j=1,3 do
						fragConfig["keepmomentum"][j] = tonumber(keepmomentum)
					end
				end
			end
			fragnum = fragnum + 1
		end
		projConfig.fragcount =  fragnum - 1
		if debugMode then
			Spring.Echo("[CAS] Frag count: " .. fragnum - 1)
		end
	end
	wd = nil
	curRef = nil
end

return config
