local config = {}

local 

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if curRef and curRef.projectile1 then -- found it!
		if debugMode then
			Spring.Echo("CAS: Discovered " .. i .. "(" .. wd.name .. ")")
		end
		if type(curRef.projectile1) == "string" then -- reason we use it like this is to provide an error if something doesn't seem right.
			if WeaponDefNames[curRef.projectile1] then
				if type(curRef.spawndist) == "string" then -- all ok
					Script.SetWatchWeapon(i, true)
					if debugMode then
						Spring.Echo("[CAS] Enabled watch for " .. i)
					end
					--Mommy projectile Defs
					config[i] = {}
					local projConfig = config[i]
					projConfig["spawndist"] = tonumber(curRef.spawndist)
					if curRef.timeddeploy then
						projConfig.timer = tonumber(curRef.timeddeploy) or 5
					end
					if type(curRef.use2ddist) ~= "string" then
						projConfig["use2ddist"] = 0
						if debugMode then
							Spring.Echo("[CAS] Set 2ddist to false for " .. wd.name)
						end
					else
						projConfig["use2ddist"] = tonumber(curRef.use2ddist)
					end
					if curRef.timedcharge and curRef.timedcharge > 0 then
						projConfig["type"] = "timedcharge"
					else
						projConfig["type"] = "normal"
					end
					if type(curRef.vlist) == "string" then
						projConfig["vlist"] = {}
						local x,y,z
						for w in string.gmatch(curRef.vlist,"%S+") do -- string should be "x,y,z/x,y,z/x,y,z,/x,y,z/etc
							x,y,z = w:match("([^,]+),([^,]+),([^,]+)")
							projConfig["vlist"][#projConfig["vlist"]+1] = {tonumber(x),tonumber(y),tonumber(z)}
						end
					end
					projConfig["isBomb"] = wd.type == "AircraftBomb"
					projConfig["launcher"] = wd.type == "StarburstLauncher"
					projConfig["timeoutspawn"] = tonumber(curRef.timeoutspawn) or 1
					projConfig["proxy"] = tonumber(curRef.proxy) or 0
					projConfig["proxydist"] = tonumber(curRef.proxydist) or projConfig["spawndist"] or 0
					projConfig["alwaysvisible"] = curRef.alwaysvisible ~= nil
					projConfig["clustercharges"] = tonumber(curRef.clustercharges) or 1
					projConfig["clusterdelay"] = tonumber(curRef.clusterdelay) or 5
					projConfig["clusterdelaytype"] = tonumber(curRef.clusterdelaytype) or 0
					projConfig["useheight"] = tonumber(curRef.useheight) or 0
					projConfig["dynDamage"] = type(curRef.dyndamage) == "string"
					projConfig["airburst"] = curRef.noairburst == nil
					projConfig["useasl"] = curRef.useasl ~= nil
					projConfig["onExplode"] = curRef.onexplode ~= nil
					projConfig["usertarget"] = curRef.usertargetable ~= nil
					projConfig["noceg"] = curRef.clusternoceg ~= nil
					projConfig["block_check_during_cruise"] = curRef["cas_nocruisecheck"] ~= nil
					if projConfig.useheight then
						projConfig.minvelocity = tonumber(curRef.minvelocity) or 0
					end
					
					--sonny projectile defs
					
					--the basic idea is this. instead of pulling let say curRef.projectile we pull curRef.projectile1 or curRef.projectile2 for the different
					--projectiles that the bullet splits into
					
					projConfig["frags"] = {}
					
					local fragnum = 1
					while (curRef["projectile" .. fragnum]) do
						projConfig["frags"][fragnum] = {}
						local fragConfig = projConfig["frags"][fragnum]
						local projectile = curRef["projectile" .. fragnum]
						fragConfig["projectile"] = WeaponDefNames[projectile].id -- transform into an id
						local numprojectiles = curRef["numprojectiles" .. fragnum]
						if type(numprojectiles) ~= "string" then
							fragConfig["numprojectiles"] = 1
						else
							fragConfig["numprojectiles"] = tonumber(numprojectiles)
						end
						local posSpread = curRef["posspread"..fragnum]
						local velSpread = curRef["vekspread"..fragnum]
						posspread
						local keepmomentum = curRef["keepmomentum" .. fragnum]
						if type(keepmomentum) ~= "string" then
							fragConfig["keepmomentum"] = {1,1,1}
						else
							if string.find(keepmomentum,",") then -- projectile velocity offsets
								fragConfig["keepmomentum"] = {}
								fragConfig["keepmomentum"][1],fragConfig["keepmomentum"][2], fragConfig["keepmomentum"][3] = keepmomentum:match("([^,]+),([^,]+),([^,]+)")
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
						local spawnsfx = curRef["spawnsfx" .. fragnum]
						if spawnsfx then
							fragConfig["spawnsfx"] = tonumber(spawnsfx)
						end
						fragnum = fragnum + 1
					end
					projConfig.fragcount =  fragnum - 1
					if debugMode then
						Spring.Echo("[CAS] Frag count: " .. fragnum - 1)
					end
				else
					Spring.Echo("[CAS] Error: " .. i .. "(" .. WeaponDefs[i].name .. "): spawndist is not present.")
				end
			else
				Spring.Echo("[CAS] Error: " .. i .. "( " .. WeaponDefs[i].name .. "): subprojectile " .. curRef.projectile1 ..  " is not a valid weapondef name.")
			end
		else
			Spring.Echo("[CAS] Error: " .. i .. "( " .. WeaponDefs[i].name .. "): subprojectile is not a string.")
		end
	end
	wd = nil
	curRef = nil
end

return config
