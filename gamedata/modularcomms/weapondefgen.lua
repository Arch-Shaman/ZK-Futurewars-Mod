local CopyTable = Spring.Utilities.CopyTable

local weaponsList = VFS.DirList("gamedata/modularcomms/weapons", "*.lua") or {}
local subprojectileList = VFS.DirList("gamedata/modularcomms/subprojectiles", "*.lua") or {}
local explosionList = VFS.DirList("gamedata/modularcomms/deathexplosions", "*.lua") or {}

Spring.Echo("[Modular Comms] generating weapondefs.")

for i = 1, #weaponsList do
	if weaponsList[i]:find("commweapon") or weaponsList[i]:find("shield") then -- load only future wars weapondefs. Declutters weapondefs.
		local name, array = VFS.Include(weaponsList[i])
		--Spring.Echo("[Modular Comms] proccessing " .. name .. "[" .. weaponsList[i] .. "]")
		--Spring.Echo("Parsing " .. name)
		local weapon = lowerkeys(array)
		for boost = 0, 8 do
			local weaponData = CopyTable(weapon, true)
			if weaponData.customparams == nil then
				weaponData.customparams = {}
			end
			weaponData.size = (weaponData.size or (2 + math.min((weaponData.damage.default or 0) * 0.0025, (weaponData.areaofeffect or 0) * 0.1))) * (1 + boost/8)
			
			for armorname, dmg in pairs(weaponData.damage) do
				weaponData.damage[armorname] = dmg + dmg * boost*0.1
			end
			if weaponData.customparams.area_damage_dps then
				weaponData.customparams.area_damage_dps = weaponData.customparams.area_damage_dps * (1 + (boost * 0.1))
			end
			if weaponData.customparams.extra_damage_mult then
				weaponData.customparams.extra_damage = weaponData.customparams.extra_damage_mult * weaponData.damage.default
				weaponData.customparams.extra_damage_mult = nil
			end
			if weaponData.customparams.burntime then
				weaponData.customparams.burntime = tostring(math.ceil(tonumber(weaponData.customparams.burntime) * (1 + (0.1 * boost))))
			end
			for p, v in pairs(weapon.customparams) do
				weaponData.customparams[p] = v
			end
			if weaponData.customparams.projectile1 then
				local cp = weaponData.customparams
				local p = 1
				while cp["projectile" .. p] do
					weaponData.customparams["projectile" .. p] = boost .. "_" .. weaponData.customparams["projectile" .. p]
					p = p + 1
				end
			end
			
			if weaponData.thickness then
				weaponData.thickness = weaponData.thickness * (1 + boost/8)
			end
			
			if weaponData.corethickness then
				weaponData.corethickness = weaponData.corethickness * (1 + boost/8)
			end
			
			WeaponDefs[boost .. "_" .. name] = weaponData
		end
	else
		--Spring.Echo("[Modular Comms] Skipping " .. "[" .. weaponsList[i] .. "] (Probably base game. Ensure proper naming convention!)")
	end
end

for i = 1, #subprojectileList do
	local name, array = VFS.Include(subprojectileList[i])
	--Spring.Echo("Parsing " .. name)
	local weapon = lowerkeys(array)
	for boost = 0, 8 do
		local weaponData = CopyTable(weapon, true)
		if weaponData.customparams == nil then
			weaponData.customparams = {}
		end
		if weaponData.customparams.projectile1 then
			local cp = weaponData.customparams
			local p = 1
			while cp["projectile" .. p] do
				weaponData.customparams["projectile" .. p] = boost .. "_" .. weaponData.customparams["projectile" .. p]
				p = p + 1
			end
		end
		weaponData.size = (weaponData.size or (2 + math.min((weaponData.damage.default or 0) * 0.0025, (weaponData.areaofeffect or 0) * 0.1))) * (1 + boost/8)
		
		for armorname, dmg in pairs(weaponData.damage) do
			weaponData.damage[armorname] = dmg + dmg * boost*0.1
		end
		if weaponData.customparams.area_damage_dps then
			weaponData.customparams.area_damage_dps = weaponData.customparams.area_damage_dps * (1 + (boost * 0.1))
		end
		if weaponData.customparams.burntime then
			weaponData.customparams.burntime = tostring(math.ceil(tonumber(weaponData.customparams.burntime) * (1 + (0.1 * boost))))
		end
		if weaponData.customparams.extra_damage_mult then
			weaponData.customparams.extra_damage = weaponData.customparams.extra_damage_mult * weaponData.damage.default
			weaponData.customparams.extra_damage_mult = nil
		end
		
		if weaponData.thickness then
			weaponData.thickness = weaponData.thickness * (1 + boost/8)
		end
		
		if weaponData.corethickness then
			weaponData.corethickness = weaponData.corethickness * (1 + boost/8)
		end
		
		WeaponDefs[boost .. "_" .. name] = weaponData
	end
end

for i = 1, #explosionList do
	local name, array = VFS.Include(explosionList[i])
	local weapon = lowerkeys(array)
	local weaponData = CopyTable(weapon, true)
	WeaponDefs[name] = weaponData
end

