function gadget:GetInfo()
	return {
		name      = "Cluster Ammunition Spawner",
		desc      = "Spawns subprojectiles",
		author    = "_Shaman, Stuff",
		date      = "March 12, 2019",
		license   = "CC-0",
		layer     = 5,
		enabled   = true,
	}
end

--[[
	Expected customParams:
	{
		# - replace with subprojectile number.
		numprojectiles# = int, -- how many of the weapondef we spawn. OPTIONAL. Default: 1.
		projectile# = string, -- the weapondef name. we will convert this to an ID in init. REQUIRED. If defined in the unitdef, it will be unitdefname_weapondefname.
		keepmomentum# = 1/0, -- should the projectile we spawn keep momentum of the mother projectile? OPTIONAL. Default: True
		spreadradius# = num, -- used in clusters. OPTIONAL. Default: 100.
		clusterposition# = string,
		clustervelocity# = string,
		vradius# = num, -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Enter as "min,max" to define custom radius.

		use2ddist = 1/0, -- should we check 2d or 3d distance? OPTIONAL. Default: 0.
		spawndist = num, -- at what distance should we spawn the projectile(s)? REQUIRED.
		soundspawn = file, -- file to play when we spawn the projectiles. OPTIONAL. Default: None.
		timeoutspawn = 1/0, -- Can this missile spawn its subprojectiles when it times out? OPTIONAL. Default: 1.
		vradius = num, -- velocity that is randomly added. covers range of +-vradius. OPTIONAL. Enter as "min,max" to define custom radius.
		groundimpact = 1/0 -- check the distance between ground and projectile? OPTIONAL.
		proxy = 1/0 -- check for nearby units?
		proxydist = num, -- how far to check for units? Default: spawndist
		timedcharge = num, -- how long after reaching the spawndistance should it spawn projectiles? (in frames) -- NOTE: this disables the default behavior!
	}
]]

if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

--Speedups--
local spEcho = Spring.Echo
local spGetGameFrame = Spring.GetGameFrame
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetProjectilePosition = Spring.GetProjectilePosition
local spGetProjectileTarget = Spring.GetProjectileTarget
local spGetProjectileTimeToLive = Spring.GetProjectileTimeToLive
local spGetGroundHeight = Spring.GetGroundHeight
local spDeleteProjectile = Spring.DeleteProjectile
local spGetProjectileOwnerID = Spring.GetProjectileOwnerID
local spGetProjectileVelocity = Spring.GetProjectileVelocity
local spGetUnitTeam = Spring.GetUnitTeam
local spPlaySoundFile = Spring.PlaySoundFile
local spSpawnExplosion = Spring.SpawnExplosion
local spSpawnProjectile = Spring.SpawnProjectile
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder
local spGetUnitsInSphere = Spring.GetUnitsInSphere
local spSetProjectileTarget = Spring.SetProjectileTarget
local spSetProjectileIgnoreTrackingError = Spring.SetProjectileIgnoreTrackingError
local spGetProjectileDefID = Spring.GetProjectileDefID
local spAreTeamsAllied = Spring.AreTeamsAllied
local spGetUnitIsCloaked = Spring.GetUnitIsCloaked
local SetWatchWeapon = Script.SetWatchWeapon
local spSetProjectileAlwaysVisible = Spring.SetProjectileAlwaysVisible
local spGetProjectileIsIntercepted = Spring.GetProjectileIsIntercepted
local spGetProjectileTeamID = Spring.GetProjectileTeamID
local spSetProjectileDamages = Spring.SetProjectileDamages
local random = math.random
local sqrt = math.sqrt
local byte = string.byte
local abs = math.abs
local pi = math.pi
local abs = math.abs
local strfind = string.find
local gmatch = string.gmatch

local ground = byte("g")
local unit = byte("u")
local projectile = byte("p")
local feature = byte("f")

--variables--
local config = {} -- projectile configuration data
local projectiles = IterableMap.New() -- stuff we need to act on.
local debug = false
-- functions --
local function distance3d(x1, y1, z1, x2, y2, z2)
	return sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)) + ((z2 - z1) * (z2 - z1)))
end

spEcho("CAS: Scanning weapondefs")

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams -- hold table for referencing
	if curRef and curRef.projectile1 then -- found it!
		spEcho("CAS: Discovered " .. i .. "(" .. wd.name .. ")")
		if type(curRef.projectile1) == "string" then -- reason we use it like this is to provide an error if something doesn't seem right.
			if WeaponDefNames[curRef.projectile1] then
				if type(curRef.spawndist) == "string" then -- all ok
					SetWatchWeapon(i, true)
					if debug then
						spEcho("CAS: Enabled watch for " .. i)
					end
					--Mommy projectile Defs
					config[i] = {}
					if wd.type == "AircraftBomb" then
						config[i]["isBomb"] = true
					else
						config[i]["isBomb"] = false
					end
					config[i]["spawndist"] = tonumber(curRef.spawndist)
					if wd.type == "StarburstLauncher" then
						config[i]["launcher"] = true
					else
						config[i]["launcher"] = false
					end
					if curRef.timeddeploy then
						config[i].timer = tonumber(curRef.timeddeploy) or 5
					end
					if type(curRef.timeoutspawn) ~= "string" then
						config[i]["timeoutspawn"] = 1
					else
						config[i]["timeoutspawn"] = tonumber(curRef.timeoutspawn)
					end
					if type(curRef.use2ddist) ~= "string" then
						config[i]["use2ddist"] = 0
						spEcho("CAS: Set 2ddist to false for " .. name)
					else
						config[i]["use2ddist"] = tonumber(curRef.use2ddist)
					end
					if type(curRef.proxy) ~= "string" then
						config[i]["proxy"] = 0
					else
						config[i]["proxy"] = tonumber(curRef.proxy)
					end
					if type(curRef.proxydist) ~= "string" then
						config[i]["proxydist"] = config[i]["spawndist"]
					else
						config[i]["proxydist"] = tonumber(curRef.proxydist)
					end
					if type(curRef.alwaysvisible) ~= "string" then
						config[i]["alwaysvisible"] = false
					else
						config[i]["alwaysvisible"] = curRef.alwaysvisible
					end
					if type(curRef.useheight) ~= "string" then
						config[i]["useheight"] = 0
					else
						config[i]["useheight"] = tonumber(curRef.useheight)
					end
					if curRef.timedcharge and curRef.timedcharge > 0 then
						config[i]["type"] = "timedcharge"
					else
						config[i]["type"] = "normal"
					end
					if type(curRef.vlist) == "string" then
						config[i]["vlist"] = {}
						local x,y,z
						for w in gmatch(curRef.vlist,"%S+") do -- string should be "x,y,z/x,y,z/x,y,z,/x,y,z/etc
							x,y,z = w:match("([^,]+),([^,]+),([^,]+)")
							config[i]["vlist"][#config[i]["vlist"]+1] = {tonumber(x),tonumber(y),tonumber(z)}
						end
					end
					if wd.name:find("commweapon") then
						config[i].commweapon = true
					else
						config[i].commweapon = false
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
						local keepmomentum = curRef["keepmomentum" .. fragnum]
						if type(keepmomentum) ~= "string" then
							config[i]["frags"][fragnum]["keepmomentum"] = true
						else
							config[i]["frags"][fragnum]["keepmomentum"] = tonumber(keepmomentum) == 1
						end
						local spreadradius = curRef["spreadradius" .. fragnum]
						if type(spreadradius) ~= "string" then
							config[i]["frags"][fragnum]["spreadmin"] = -100
							config[i]["frags"][fragnum]["spreadmax"] = 100
						else
							if strfind(spreadradius,",") then -- projectile offsetting.
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
									spEcho("[CAS] WARNING: Illegal min,max value for spread on projectile ID " .. i .. " (" .. wd.name .. ").\n These values have been automatically switched, but you should fix your config!\nValues got:" .. config[i]["frags"][fragnum]["spreadmax"],config[i]["frags"][fragnum]["spreadmin"])
								end
							else
								config[i]["frags"][fragnum]["spreadmin"] = -abs(tonumber(spreadradius))
								config[i]["frags"][fragnum]["spreadmax"] = abs(tonumber(spreadradius))
							end
						end
						local vradius = curRef["vradius" .. fragnum]
						if type(vradius) ~= "string" then
							config[i]["frags"][fragnum]["veldata"] = {min = {-4.2,-4.2,-4.2}, max = {4.2,4.2,4.2}}
						else
							if strfind(vradius,",") then -- projectile velocity offsets
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
										spEcho("[CAS] WARNING: Illegal min,max value for velocity on projectile ID " .. i .. " (" .. wd.name .. ").\n These values have been automatically switched, but you should fix your config!\nValues got:" .. config[i]["frags"][fragnum]["veldata"].min[j],config[i]["frags"][fragnum]["veldata"].max[j])
									end
								end
							else
								config[i]["frags"][fragnum].veldata = {min = {}, max = {}}
								for j=1,3 do
									config[i]["frags"][fragnum]["veldata"].min[j] = -abs(tonumber(vradius))
									config[i]["frags"][fragnum]["veldata"].max[j] = abs(tonumber(vradius))
								end
							end
						end
						fragnum = fragnum + 1
					end
					config[i].fragcount =  fragnum - 1
					spEcho("Frag count: " .. fragnum - 1)
				else
					spEcho("Error: " .. i .. "(" .. WeaponDefs[i].name .. "): spawndist is not present.")
				end
			else
				spEcho("Error: " .. i .. "( " .. WeaponDefs[i].name .. "): subprojectile is not a valid weapondef name.")
			end
		else
			spEcho("Error: " .. i .. "( " .. WeaponDefs[i].name .. "): subprojectile is not a string.")
		end
	end
	wd = nil
	curRef = nil
end
spEcho("CAS: done processing weapondefs")

local function unittest(tab, self, teamID)
	if #tab == 0 or (#tab == 1 and tab[1] == self) then
		return false
	end
	for i=1, #tab do
		if not spAreTeamsAllied(spGetUnitTeam(tab[i]), teamID) and not spGetUnitIsCloaked(tab[i]) then -- condition: enemy unit that isn't cloaked.
			return true
		end
	end
	return false
end

if debug then 
	for name, data in pairs(config) do
		spEcho(name .. " : ON")
		for k,v in pairs(data) do
			spEcho(k .. " = " .. tostring(v))
		end
	end 
end

local function distance2d(x1,y1,x2,y2)
	return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)))
end

local function RegisterSubProjectiles(p, me, commbonus)
	if config[me] then
		IterableMap.Add(projectiles, p, {def = me, intercepted = false, ttl = config[me].timer, commbonus = commbonus})
		if config[me]["alwaysvisible"] then
			spSetProjectileAlwaysVisible(p, true)
		end
	end
end

local function ReplaceSubProjectile(wd, bonus)
	local name = WeaponDefs[wd].name
	local str = name:sub(2,-1)
	local num = bonus/.1
	num = tostring(num):sub(1,1)
	if debug then
		spEcho("replacing with " .. num)
	end
	str = num .. str
	return WeaponDefNames[str].id
end

local function SpawnSubProjectiles(id, wd, commbonus)
	if id == nil then
		return
	end
	--spawn all the subprojectiles
	local projectileattributes = {pos = {0,0,0}, speed = {0,0,0}, owner = 0, team = 0, ttl= 0,gravity = 0,tracking = false,}
	if debug then
		spEcho("Fire the submunitions!")
	end
	local x,y,z = spGetProjectilePosition(id)
	local vx,vy,vz = spGetProjectileVelocity(id)
	local ttype,target = spGetProjectileTarget(id)
	-- update projectile attributes --
	projectileattributes["owner"] = spGetProjectileOwnerID(id)
	projectileattributes["team"] = spGetProjectileTeamID(id)
	projectileattributes["pos"][1] = x
	projectileattributes["pos"][2] = y
	projectileattributes["pos"][3] = z
	projectileattributes["speed"][1] = vx
	projectileattributes["speed"][2] = vy
	projectileattributes["speed"][3] = vz
	local projectileConfig = config[wd].frags
	local step = {0,0,0}
	-- Create the projectiles --
	for j = 1, config[wd].fragcount do
		local me = projectileConfig[j]["projectile"]
		if config[wd].commweapon then
			me = ReplaceSubProjectile(me, commbonus)
		end
		local r = projectileConfig[j]["spreadradius"]
		local vr = projectileConfig[j]["veldata"]
		local projectilecount = projectileConfig[j]["numprojectiles"]
		for i=1, 3 do
			step[i] = (vr.max[i] - vr.min[i])/projectilecount
		end
		if debug then
			spEcho("Velocity: " ..tostring(projectileConfig[j].clusterpos),tostring(projectileConfig[j].clustervec) .. "\nstep: " .. tostring(step))
		end
		projectileattributes["ttl"] = WeaponDefs[me].flightTime
		projectileattributes["tracking"] = WeaponDefs[me].tracks or false
		projectileattributes["gravity"] = -WeaponDefs[me].myGravity or -1
		local positioning = projectileConfig[j].clusterpos or "none"
		local vectoring = projectileConfig[j].clustervec or "none"
		local keepmomentum = projectileConfig[j].keepmomentum
		for i = 1, projectilecount do
			local p
			if strfind(positioning,"random") then
				if strfind(positioning,"x") then
					projectileattributes["pos"][1] = x+random(-r,r)
				end
				if strfind(positioning,"y") then
					projectileattributes["pos"][2] = y+random(-r,r)
				end
				if strfind(positioning,"z") then
					projectileattributes["pos"][3] = z+random(-r,r)
				end
			end
			local vxf, vyf, vzf = vx, vy, vz
			if not keepmomentum then
				vxf = 0
				vyf = 0
				vzf = 0
			end
			if strfind(vectoring,"random") then
				if strfind(vectoring,"x") then
					projectileattributes["speed"][1] = vxf+random(vr.min[1],vr.max[1])
				end
				if strfind(vectoring,"y") then
					projectileattributes["speed"][2] = vyf+random(vr.min[2],vr.max[2])
				end
				if strfind(vectoring,"z") then
					projectileattributes["speed"][3] = vzf+random(vr.min[3],vr.max[3])
				end
			elseif strfind(vectoring,"even") then
				if strfind(vectoring,"x") then
					projectileattributes["speed"][1] = vxf+(vr.min[1]+(step[1]*(i-1)))
				end
				if strfind(vectoring,"y") then
					projectileattributes["speed"][2] = vyf+(vr.min[2]+(step[2]*(i-1)))
				end
				if strfind(vectoring,"z") then
					projectileattributes["speed"][3] = vzf+(vr.min[3]+(step[3]*(i-1)))
				end
			end
			if debug then
				spEcho("Projectile Speed: " .. projectileattributes["speed"][1],projectileattributes["speed"][2],projectileattributes["speed"][3])
			end
			p = spSpawnProjectile(me, projectileattributes)
			if ttype ~= ground then
				if debug then
					spEcho("setting target for " .. p .. " = " .. target)
				end
				spSetProjectileTarget(p, target,ttype)
			else
				spSetProjectileTarget(p, target[1], target[2], target[3])
			end
			RegisterSubProjectiles(p,me, commbonus)
		end
	end
	-- create the explosion --
	spSpawnExplosion(x,y,z,0,0,0,{weaponDef = wd, owner = spGetProjectileOwnerID(id), craterAreaOfEffect = WeaponDefs[wd].craterAreaOfEffect, damageAreaOfEffect = 0, edgeEffectiveness = 0, explosionSpeed = WeaponDefs[wd].explosionSpeed, impactOnly = WeaponDefs[wd].impactOnly, ignoreOwner = WeaponDefs[wd].noSelfDamage, damageGround = true})
	spPlaySoundFile(WeaponDefs[wd].hitSound[1].name,WeaponDefs[wd].hitSound[1].volume,x,y,z)
	spDeleteProjectile(id)
	local projectiledata = IterableMap.Get(projectiles, id)
	projectiledata.dead = true
end

local function CheckProjectile(id)
	if debug then 
		spEcho("CheckProjectile " .. id)
	end
	local projectile = IterableMap.Get(projectiles, id)
	local targettype, targetID = spGetProjectileTarget(id)
	if targettype == nil or projectile.dead then
		if debug then spEcho("projectile " .. id .. " deleted.") end
		IterableMap.Remove(projectiles, id)
		return
	end
	local wd = projectile.def or spGetProjectileDefID(id)
	if projectile.ttl then -- timed weapons don't need anything fancy.
		if projectile.ttl <= 0 then
			SpawnSubProjectiles(id, wd, projectile.commbonus)
		else
			return
		end
	end
	--spEcho("wd: " .. tostring(wd))
	projectile.intercepted = spGetProjectileIsIntercepted(id)
	local isMissile = false -- check for missile status. When the missile times out, the subprojectiles will be spawned if allowed.
	if WeaponDefs[wd]["flightTime"] ~= nil and WeaponDefs[wd].type == "Missile" then
		isMissile = true
	end
	local myConfig = config[wd]
	local vx,vy,vz = spGetProjectileVelocity(id)
	if myConfig.launcher and vy > -0.000001 then
		return
	end
	--spEcho("CheckProjectile: " .. id .. ", " .. wd)
	local ttl = spGetProjectileTimeToLive(id)
	if isMissile and debug then spEcho("ttl: " .. tostring(ttl)) end
	if isMissile and myConfig.timeoutspawn and ttl == 0 then
		SpawnSubProjectiles(id,wd, projectile.commbonus)
	end
	local use3d = (myConfig.use2ddist == 0)
	local distance
	local x2,y2,z2 = spGetProjectilePosition(id)
	local x1,y1,z1
	if debug then 
		spEcho("Attack type: " .. targettype .. "\nTarget: " .. tostring(targetID))
	end
	--debugEcho("Key: 'g' = " .. byte("g") .. "\n'u' = " .. byte("u") .. "\n'f' = " .. byte("f") .. "\n'p' = " .. byte("p"))
	if myConfig.useheight and myConfig.useheight ~= 0 then -- this spawns at the selected height when vy < 0
		if debug then
			spEcho("Useheight check")
		end
		if y2 - spGetGroundHeight(x2,z2) < myConfig.spawndist and vy < 0 then
			SpawnSubProjectiles(id,wd, projectile.commbonus)
		else
			return
		end
	end
	if targettype == ground then -- this is an undocumented case. Aircraft bombs when targeting ground returns 103 or byte(49).
		x1 = targetID[1]
		y1 = targetID[2]
		z1 = targetID[3]
		if debug then
			spEcho(x1,y1,z1)
		end
	elseif targettype == 103 then
		if debug then
			spEcho("103! \n" .. targetID[1],targetID[2],targetID[3])
		end
		x1 = x2
		y1 = spGetGroundHeight(x2,z2)
		z1 = z2
	elseif targettype == unit or targettype == 117 then
		x1,y1,z1 = spGetUnitPosition(targetID)
	elseif targettype == feature then
		x1,y1,z1 = spGetFeaturePosition(targetID)
	elseif targettype == projectile then
		x1,y1,z1 = spGetProjectilePosition(targetID)
	end
	if use3d then
		distance = distance3d(x2,y2,z2,x1,y1,z1)
	else
		distance = distance2d(x2,z2,x1,z1)
	end
	local height = y2 - spGetGroundHeight(x2,z2)
	if debug then
		spEcho("d: " .. distance .. "\nisBomb: " .. tostring(myConfig["isBomb"]) .. "\nVelocity: (" .. vx,vy,vz .. ")" .. "\nH: " .. height .. "\nexplosion dist: " .. height - myConfig.spawndist)
	end
	if distance < myConfig.spawndist and not myConfig["isBomb"] then -- bombs ignore distance and explode based on height. This is due to bomb ground attacks being absolutely fucked in current spring build.
		SpawnSubProjectiles(id, wd, projectile.commbonus)
		if debug then
			spEcho("distance")
		end
	elseif myConfig["isBomb"] and height <= myConfig.spawndist then
		SpawnSubProjectiles(id,wd, projectile.commbonus)
		if debug then
			spEcho("bomb engage")
		end
	elseif myConfig.groundimpact == 1 and vy < -1 and height <= myConfig.spawndist then
		if debug then
			spEcho("ground impact")
		end
		SpawnSubProjectiles(id,wd, projectile.commbonus)
	elseif myConfig["proxy"] == 1 then
		local units
		if use3d then
			units = spGetUnitsInSphere(x2,y2,z2, myConfig["proxydist"])
		else 
			units = spGetUnitsInCylinder(x2,z2, myConfig["proxydist"])
		end
		if unittest(units, projectile.owner, projectile.teamID) then
			if debug then
				spEcho("Unit passed unittest. Passed to SpawnSubProjectiles")
			end
			SpawnSubProjectiles(id, wd, projectile.commbonus)
		end
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if debug then
		spEcho("ProjectileCreated: " .. tostring(proID, proOwnerID, weaponDefID))
	end
	if weaponDefID == nil then
		weaponDefID = spGetProjectileDefID(proID)
	end
	local projectiledata = IterableMap.Get(projectiles, proID)
	if config[weaponDefID] and not projectiledata then
		if debug then
			spEcho("Registered projectile " .. proID)
		end
		local commbonus
		if config[weaponDefID].commweapon then
			commbonus = spGetUnitRulesParam(proOwnerID, "comm_damage_mult") or 1
			commbonus = commbonus - 1
			if debug then
				spEcho("Damage mult: " .. commbonus)
			end
		end
		IterableMap.Add(projectiles, proID, {def = weaponDefID, intercepted = false, owner = proOwnerID, teamID = spGetUnitTeam(proOwnerID), ttl = config[weaponDefID].timer, commbonus = commbonus})
		if config[weaponDefID]["alwaysvisible"] then
			spSetProjectileAlwaysVisible(proID,true)
		end
	end
end

function gadget:ProjectileDestroyed(proID)
	local projectiledata = IterableMap.Get(projectiles, proID)
	if projectiledata and not projectiledata.intercepted then
		local wd = projectiledata.def
		SpawnSubProjectiles(id, wd, projectiledata.commbonus)
	end
end

function gadget:GameFrame(f)
	for id, data in IterableMap.Iterator(projectiles) do
		if debug then spEcho(id .. ": Updating.") end
		if data.ttl then
			projectiles[id].ttl = projectiles[id].ttl - 1
		end
		CheckProjectile(id)
	end
end
