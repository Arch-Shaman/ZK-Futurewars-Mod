local config = {}

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if curRef and curRef.projectile1 then -- found it!
		if debug then
			Spring.Echo("CAS: Discovered " .. i .. "(" .. wd.name .. ")")
		end
		if type(curRef.projectile1) == "string" then -- reason we use it like this is to provide an error if something doesn't seem right.
			if WeaponDefNames[curRef.projectile1] then
				if type(curRef.spawndist) == "string" then -- all ok
					Script.SetWatchWeapon(i, true)
					if debug then
						Spring.Echo("[CAS] Enabled watch for " .. i)
					end
					--Mommy projectile Defs
					config[i] = {}
					config[i]["spawndist"] = tonumber(curRef.spawndist)
					if curRef.timeddeploy then
						config[i].timer = tonumber(curRef.timeddeploy) or 5
					end
					if type(curRef.use2ddist) ~= "string" then
						config[i]["use2ddist"] = 0
						if debug then
							Spring.Echo("[CAS] Set 2ddist to false for " .. wd.name)
						end
					else
						config[i]["use2ddist"] = tonumber(curRef.use2ddist)
					end
					if curRef.timedcharge and curRef.timedcharge > 0 then
						config[i]["type"] = "timedcharge"
					else
						config[i]["type"] = "normal"
					end
					if type(curRef.vlist) == "string" then
						config[i]["vlist"] = {}
						local x,y,z
						for w in string.gmatch(curRef.vlist,"%S+") do -- string should be "x,y,z/x,y,z/x,y,z,/x,y,z/etc
							x,y,z = w:match("([^,]+),([^,]+),([^,]+)")
							config[i]["vlist"][#config[i]["vlist"]+1] = {tonumber(x),tonumber(y),tonumber(z)}
						end
					end
					config[i]["isBomb"] = wd.type == "AircraftBomb"
					config[i]["launcher"] = wd.type == "StarburstLauncher"
					config[i]["timeoutspawn"] = tonumber(curRef.timeoutspawn) or 1
					config[i]["proxy"] = tonumber(curRef.proxy) or 0
					config[i]["proxydist"] = tonumber(curRef.proxydist) or config[i]["spawndist"] or 0
					config[i]["alwaysvisible"] = curRef.alwaysvisible ~= nil
					config[i]["clustercharges"] = tonumber(curRef.clustercharges) or 1
					config[i]["clusterdelay"] = tonumber(curRef.clusterdelay) or 5
					config[i]["clusterdelaytype"] = tonumber(curRef.clusterdelaytype) or 0
					config[i]["useheight"] = tonumber(curRef.useheight) or 0
					config[i]["dynDamage"] = type(curRef.dyndamage) == "string"
					config[i]["airburst"] = curRef.noairburst == nil
					config[i]["onExplode"] = curRef.onexplode ~= nil
					config[i]["usertarget"] = curRef.usertargetable ~= nil
					config[i]["noceg"] = curRef.clusternoceg ~= nil
					config[i]["block_check_during_cruise"] = curRef["cas_nocruisecheck"] ~= nil
					if config[i].useheight then
						config[i].minvelocity = tonumber(curRef.minvelocity) or 0
					end
					
					--sonny projectile defs
					
					--the basic idea is this. instead of pulling let say curRef.projectile we pull curRef.projectile1 or curRef.projectile2 for the different
					--projectiles that the bullet splits into
					
					config[i]["frags"] = {}
					
					local fragnum = 1
					while (curRef["projectile" .. fragnum]) do
						config[i]["frags"][fragnum] = {}
						local projectile = curRef["projectile" .. fragnum]
						config[i]["frags"][fragnum]["projectile"] = WeaponDefNames[projectile].id -- transform into an id
						local clusterpos = curRef["clusterpos" .. fragnum]
						if type(clusterpos) ~= "string" then
							config[i]["frags"][fragnum]["clusterpos"] = "no"
						else
							config[i]["frags"][fragnum]["clusterpos"] = clusterpos
						end
						local clustervec = curRef["clustervec" .. fragnum]
						if type(clustervec) ~= "string" then
							config[i]["frags"][fragnum]["clustervec"] = "no"
						else
							config[i]["frags"][fragnum]["clustervec"] = clustervec
						end
						local numprojectiles = curRef["numprojectiles" .. fragnum]
						if type(numprojectiles) ~= "string" then
							config[i]["frags"][fragnum]["numprojectiles"] = 1
						else
							config[i]["frags"][fragnum]["numprojectiles"] = tonumber(numprojectiles)
						end
						local spreadradius = curRef["spreadradius" .. fragnum]
						if type(spreadradius) ~= "string" then
							config[i]["frags"][fragnum]["spreadmin"] = -100
							config[i]["frags"][fragnum]["spreadmax"] = 100
						else
							if string.find(spreadradius,",") then -- projectile offsetting.
								config[i]["frags"][fragnum]["spreadmin"], config[i]["frags"][fragnum]["spreadmax"] = spreadradius:match("([^,]+),([^,]+)")
								config[i]["frags"][fragnum]["spreadmin"] = tonumber(config[i]["frags"][fragnum]["spreadmin"])
								config[i]["frags"][fragnum]["spreadmax"] = tonumber(config[i]["frags"][fragnum]["spreadmax"])
								if config[i]["frags"][fragnum]["spreadmax"] == "" or config[i]["frags"][fragnum]["spreadmax"] == nil then
									config[i]["frags"][fragnum]["spreadmax"] = config[i]["frags"][fragnum]["spreadmin"] * -1
								end
								if config[i]["frags"][fragnum]["spreadmin"] > config[i]["frags"][fragnum]["spreadmax"] then
									local mi = config[i]["frags"][fragnum]["spreadmax"]
									local ma = config[i]["frags"][fragnum]["spreadmin"]
									config[i]["frags"][fragnum]["spreadmin"] = mi
									config[i]["frags"][fragnum]["spreadmax"] = ma
									Spring.Echo("[CAS] WARNING: Illegal min,max value for spread on projectile ID " .. i .. " (" .. wd.name .. ").\n These values have been automatically switched, but you should fix your config!\nValues got:" .. config[i]["frags"][fragnum]["spreadmax"],config[i]["frags"][fragnum]["spreadmin"])
								end
							else
								config[i]["frags"][fragnum]["spreadmin"] = -math.abs(tonumber(spreadradius))
								config[i]["frags"][fragnum]["spreadmax"] = math.abs(tonumber(spreadradius))
							end
						end
						local vradius = curRef["vradius" .. fragnum]
						if type(vradius) ~= "string" then
							config[i]["frags"][fragnum]["veldata"] = {min = {-4.2,-4.2,-4.2}, max = {4.2,4.2,4.2}}
						else
							if string.find(vradius,",") then -- projectile velocity offsets
								config[i]["frags"][fragnum]["veldata"] = {min = {}, max = {}}
								config[i]["frags"][fragnum]["veldata"].min[1],config[i]["frags"][fragnum]["veldata"].min[2], config[i]["frags"][fragnum]["veldata"].min[3],config[i]["frags"][fragnum]["veldata"].max[1],config[i]["frags"][fragnum]["veldata"].max[2],config[i]["frags"][fragnum]["veldata"].max[3]  = vradius:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
								for j=1, 3 do
									config[i]["frags"][fragnum]["veldata"].min[j] = tonumber(config[i]["frags"][fragnum]["veldata"].min[j])
									config[i]["frags"][fragnum]["veldata"].max[j] = tonumber(config[i]["frags"][fragnum]["veldata"].max[j])
									if config[i]["frags"][fragnum].veldata.min[j] > config[i]["frags"][fragnum].veldata.max[j] then
										local mi = config[i]["frags"][fragnum]["veldata"].min[j]
										local ma = config[i]["frags"][fragnum]["veldata"].max[j]
										config[i]["frags"][fragnum]["veldata"].min[j] = mi
										config[i]["frags"][fragnum]["veldata"].max[j] = ma
										Spring.Echo("[CAS] WARNING: Illegal min,max value for velocity on projectile ID " .. i .. " (" .. wd.name .. ").\n These values have been automatically switched, but you should fix your config!\nValues got:" .. config[i]["frags"][fragnum]["veldata"].min[j],config[i]["frags"][fragnum]["veldata"].max[j])
									end
								end
							else
								config[i]["frags"][fragnum].veldata = {min = {}, max = {}}
								for j=1,3 do
									config[i]["frags"][fragnum]["veldata"].min[j] = -math.abs(tonumber(vradius))
									config[i]["frags"][fragnum]["veldata"].max[j] = math.abs(tonumber(vradius))
								end
							end
						end
						config[i]["frags"][fragnum]["veldata"].diff = {}
						for j=1,3 do
							config[i]["frags"][fragnum]["veldata"].diff[j] = config[i]["frags"][fragnum]["veldata"].max[j] - config[i]["frags"][fragnum]["veldata"].min[j]
						end
						local keepmomentum = curRef["keepmomentum" .. fragnum]
						if type(keepmomentum) ~= "string" then
							config[i]["frags"][fragnum]["keepmomentum"] = {1,1,1}
						else
							if string.find(keepmomentum,",") then -- projectile velocity offsets
								config[i]["frags"][fragnum]["keepmomentum"] = {}
								config[i]["frags"][fragnum]["keepmomentum"][1],config[i]["frags"][fragnum]["keepmomentum"][2], config[i]["frags"][fragnum]["keepmomentum"][3] = keepmomentum:match("([^,]+),([^,]+),([^,]+)")
								for j=1, 3 do
									config[i]["frags"][fragnum]["keepmomentum"][j] = tonumber(config[i]["frags"][fragnum]["keepmomentum"][j])
								end
							else
								config[i]["frags"][fragnum].keepmomentum = {}
								for j=1,3 do
									config[i]["frags"][fragnum]["keepmomentum"][j] = tonumber(keepmomentum)
								end
							end
						end
						local spawnsfx = curRef["spawnsfx" .. fragnum]
						if spawnsfx then
							config[i]["frags"][fragnum]["spawnsfx"] = tonumber(spawnsfx)
						end
						fragnum = fragnum + 1
					end
					config[i].fragcount =  fragnum - 1
					if debug then
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