if (not gadgetHandler:IsSyncedCode()) then return end

function gadget:GetInfo() return {
	name      = "Seismic Activity",
	desc      = "Creates Seismic activity.",
	author    = "Shaman",
	date      = "20 April 2023",
	license   = "CC BY-NC-ND",
	layer     = 1,
	enabled   = false,
} end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

local seismicEvents = IterableMap.New()

local spAddHeightMap = Spring.AddHeightMap
local spGetGroundHeight = Spring.GetGroundHeight
local spGetGroundInfo = Spring.GetGroundInfo
local spSetHeightMapFunc = Spring.SetHeightMapFunc
local spGetGameFrame = Spring.GetGameFrame
local spSpawnProjectile = Spring.SpawnProjectile
local gaiaTeam = Spring.GetGaiaTeamID()
local sin = math.sin
local sqrt = math.sqrt
local exp = math.exp

local HARDNESS_FACTOR = 120
local MAXX = Game.mapSizeX
local MAXZ = Game.mapSizeZ
local SQUARE_SIZE = Game.squareSize

--- Smoothing --
local VALUE = 3
local NUMERATOR = (2 + exp(VALUE) + exp(-1*VALUE))/(exp(VALUE) - exp(-1*VALUE))
local OFFSET = NUMERATOR/(1 + exp(VALUE))

-- Screen Shake --
local HEAVY_SHAKE = WeaponDefNames["seismic_camerashake_heavy"].id
local SMALL_SHAKE = WeaponDefNames["seismic_camerashake_twok"].id

local function FalloffFunc(disSQ, smoothradiusSQ, smoothExponent)
	return NUMERATOR/(1 + math.exp(2*VALUE*(disSQ/smoothradiusSQ)^smoothExponent - VALUE)) - OFFSET
end


--- config ---
local config = {}
local wantedList = {}
for i = 1, #WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams.isseismic then
		local radius = tonumber(wd.customParams.seismicradius)
		local duration = tonumber(wd.customParams.seismicduration) -- number of pulses.
		local distortionstrength = tonumber(wd.customParams.seismicdistortion)
		local delay = tonumber(wd.customParams.seismicdelay) or 0
		local strengthmult = tonumber(wd.customParams.seismicmult) or 0.75
		local pulse = tonumber(wd.customParams.seismicpulsedelay) or 10
		if radius and duration and distortionstrength then
			config[i] = {radius = radius, duration = duration, strength = distortionstrength, delay = delay, pulsedelay = pulse, strengthmult = strengthmult}
			Script.SetWatchExplosion(i, true)
			wantedList[i] = true
		end
	end
end
-- toolbox --

local function InCircle(x, z, cx, cz, dist)
	local d = dist * dist
	return ((cx - x)*(cx - x)) + ((cz - z) * (cz - z)) <= d
end

local function DistanceToEdges(cx, cz, dist)
	local minX = cx - dist
	local maxX = cx + dist
	local minZ = cz - dist
	local maxZ = cz + dist
	if minX < 0 then minX = 0 end
	if maxX >= MAXX then maxX = MAXX end
	if minZ < 0 then minZ = 0 end
	if maxZ >= MAXZ then maxZ = MAXZ end
	return cx - minX, maxX - cx, cz - minZ, maxZ - cz
end

local function GetNewHeight(distSqr, x, z, i)
	local _, _, tileHardness = spGetGroundInfo(x, z)
	local hardnessMult = HARDNESS_FACTOR / tileHardness
	local dist = sqrt(distSqr)
	if dist > 100 then
		dist = dist + (i * 5)
	end
	local effectiveDistance = dist^1.2/(SQUARE_SIZE * 5)
	return sin(effectiveDistance) * hardnessMult
end

local function SmoothAndRaise(distSqr, x, z, height, groundHeight, effectSize, i)
	local wantedHeight = GetNewHeight(distSqr, x, z, i)
	local currentHeight = spGetGroundHeight(x, z)
	local effectiveHeight = wantedHeight +  currentHeight
	local falloff = FalloffFunc(distSqr, effectSize * effectSize, 0.43)
	--(groundHeight - spGetGroundHeight(i,j)) * maxSmooth * FalloffFunc(disSQ, smoothradiusSQ, smoothExponent)
	local smoothHeight = (groundHeight - height) * 0.7 * falloff
	return wantedHeight + smoothHeight
end

local function SeismicFunction(centerX, centerZ, dist, heightDiff, iteration, centerHeight)
	local posX, posZ
	local minX, maxX, minZ, maxZ = DistanceToEdges(centerX, centerZ, dist)
	local centeringEffect = dist * 0.1
	for z = minZ, maxZ, SQUARE_SIZE do -- heightmap has a resolution of SQUARE_SIZE, apparently?
		for x = minX, maxX, SQUARE_SIZE do
			if InCircle(x, z, centerX, centerZ, dist) and GG.IsPositionTerraable(x, z, true) then
				local distanceSquared = ((centerX - x) * (centerX - x)) + ((centerZ - z) * (centerZ - z))
				spAddHeightMap(x, z, SmoothAndRaise(distanceSquared, x, z, heightDiff, centerHeight, dist, iteration))
			end
		end
	end
end

local function DoPulse(centerX, centerZ, radius, iteration, strength)
	local centerHeight = spGetGroundHeight(centerX, centerZ)
	local params = {
		pos = {centerX, centerHeight, centerZ},
		speed = {0, -5, 0},
		team = gaiaTeam,
		gravity = -1,
	}
	params["end"] = {centerX, centerHeight, centerZ}
	if strength < 50 then
		spSpawnProjectile(SMALL_SHAKE, params)
	else
		spSpawnProjectile(HEAVY_SHAKE, params)
	end
	spSetHeightMapFunc(SeismicFunction, centerX, centerZ, radius, strength, iteration, centerHeight)
end
	

function gadget:Explosion(weaponID, x, y, z, AttackerID, ProjectileID)
	if config[weaponID] and y <= spGetGroundHeight(x, z) then
		local c = config[weaponID]
		IterableMap.Add(SeismicEvents, ProjectileID, {pulsesLeft = c.duration, x = x, z = z, nextpulse = spGetGameFrame() + c.delay, pulsedelay = c.pulsedelay, radius = c.radius, currentStrength = c.strength, currentIteration = 0, strengthmult = c.strengthmult})
	end
end

function gadget:Explosion_GetWantedWeaponDef()
	return wantedList
end

function gadget:GameFrame(f)
	for id, data in IterableMap.Iterator(seismicEvents) do
		if f > data.nextpulse then
			DoPulse(data.x, data.z, data.radius, data.currentIteration)
			data.currentIteration = data.currentIteration + 1
			data.pulsesLeft = data.pulsesLeft - 1
			data.nextpulse = f + data.pulsedelay
			local m = math.random() - 0.5
			data.currentStrength = data.currentStrength * (data.strengthmult - m)
			if data.pulsesLeft == -1 then
				IterableMap.Remove(seismicEvents, id)
			end
		end
	end
end