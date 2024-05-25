if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name = "Area Denial",
		desc = "Lets a weapon's damage persist in an area",
		author = "KDR_11k (David Becker), Google Frog",
		date = "2007-08-26",
		license = "Public domain",
		layer = 21,
		enabled = true
	}
end

local frameNum
local IterableMap = Spring.Utilities.IterableMap
local DAMAGE_PERIOD, weaponInfo = VFS.Include("LuaRules/Configs/area_damage_defs.lua", nil, VFS.GAME)
local explosions = IterableMap.New()
local explosionList = {}
local explosionCount = 0
local burnproof = {}
local spAddUnitDamage = Spring.AddUnitDamage
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitsInSphere = Spring.GetUnitsInSphere
local sqrt = math.sqrt

function gadget:UnitPreDamaged_GetWantedWeaponDef()
	local wantedWeaponList = {}
	for wdid = 1, #WeaponDefs do
		if weaponInfo[wdid] then
			wantedWeaponList[#wantedWeaponList + 1] = wdid
		end
	end
	return wantedWeaponList
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	if UnitDefs[unitDefID].customParams.fireproof then
		burnproof[unitID] = true
	end
end

function gadget:UnitDestroyed(unitID)
	burnproof[unitID] = nil
end

function GG.MakeUnitFireproof(unitID)
	burnproof[unitID] = true
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam)
	if weaponInfo[weaponDefID] and weaponInfo[weaponDefID].impulse then
		return 0
	end
	return damage
end

function gadget:Explosion_GetWantedWeaponDef()
	local wantedList = {}
	for wdid,_ in pairs(weaponInfo) do
		wantedList[#wantedList + 1] = wdid
	end
	return wantedList
end

function gadget:Explosion(weaponID, px, py, pz, ownerID)
	if (weaponInfo[weaponID]) then
		local weaponDamage = weaponInfo[weaponID].damage
		local timeLoss     = weaponInfo[weaponID].timeLoss
		local heightMax    = weaponInfo[weaponID].heightMax
		local isFire       = weaponInfo[weaponID].isFireDamage
		if heightMax then
			local heightInt = weaponInfo[weaponID].heightInt or heightMax
			local height = (py - math.max(0, Spring.Utilities.GetGroundHeightMinusOffmap(px, pz) or 0))
			if height > heightMax then
				return false
			elseif height > heightMax - heightInt then
				local mult = ((heightMax - height)/heightInt)
				weaponDamage = weaponDamage*mult
				timeLoss     = timeLoss*mult
				local heightReduce = weaponInfo[weaponID].heightReduce
				if heightReduce then
					py = py - (1 - mult)*heightReduce
				end
			end
		end
		IterableMap.AddSelf(explosions, {
			radius = weaponInfo[weaponID].radius,
			plateauRadius = weaponInfo[weaponID].plateauRadius,
			damage = weaponDamage,
			impulse = weaponInfo[weaponID].impulse,
			expiry = frameNum + weaponInfo[weaponID].duration,
			rangeFall = weaponInfo[weaponID].rangeFall,
			timeLoss = timeLoss,
			id = weaponID,
			pos = {x = px, y = py, z = pz},
			owner=ownerID,
			isFire = isFire,
		})
	end
	return false
end

local function GetDistance(x1, y1, x2, y2)
	return sqrt(((x2-x1)*(x2-x1)) + ((y2 - y1) * (y2 - y1)))
end

function gadget:GameFrame(f)
	frameNum = f
	if (f%DAMAGE_PERIOD == 0) then
		local i = 1
		for _, data in IterableMap.Iterator(explosions) do
			local pos = data.pos
			local ulist = spGetUnitsInSphere(pos.x, pos.y, pos.z, data.radius)
			if (ulist) then
				local divisor = data.radius - data.plateauRadius
				local damageFall = damage*data.rangeFall
				for j = 1, #ulist do
					local u = ulist[j]
					local ux, uy, uz = spGetUnitPosition(u)
					local damage = data.damage
					local distance = GetDistance(ux, uy, pos.x, pos.z)
					if data.rangeFall ~= 0 and distance > data.plateauRadius then
						damage = damage - damageFall * (distance - data.plateauRadius) / (divisor)
					end
					if data.impulse then
						GG.AddGadgetImpulse(u, pos.x - ux, pos.y - uy, pos.z - uz, damage, false, true, false, {0.22,0.7,1})
						GG.SetUnitFallDamageImmunity(u, f + 10)
						GG.DoAirDrag(u, damage)
					elseif data.isFire and not burnproof[u] then
						spAddUnitDamage(u, damage, 0, data.owner, data.id, 0, 0, 0)
					end
				end
			end
			data.damage = data.damage - data.timeLoss
			if f >= data.expiry then
				explosionList[i] = explosionList[explosionCount]
				explosionList[explosionCount] = nil
				explosionCount = explosionCount - 1
			else
				i = i + 1
			end
		end
	end
end

function gadget:Initialize()
	for w,_ in pairs(weaponInfo) do
		Script.SetWatchExplosion(w, true)
	end
end