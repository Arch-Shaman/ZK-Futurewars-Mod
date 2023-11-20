if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Ballistic Guidance",
		desc      = "Guidance for ballistic weapon Only works for high angle weapons",
		author    = "StuffPhoton",
		date      = "25/07/2023",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

--[[
Pharsed tags:
(format: pharsed tag = default value
	ballisticGuidance = number -- The guidance stregnth of the ballistic weapon
	
Notes:
	This gadget is designed to work only with high angle ballistic weapon, and only works well with them
	This gadget is probably not super lag friendly and probably isn't a good idea to apply to every weapon
--]]


---------------------------------------------------------------------
---------------------------------------------------------------------

local sqrt = math.sqrt
local spEcho = Spring.Echo
local spGetProjectilePosition = Spring.GetProjectilePosition
local spGetProjectileVelocity = Spring.GetProjectileVelocity
local spSetProjectileVelocity = Spring.SetProjectileVelocity
local spGetProjectileTarget = Spring.GetProjectileTarget
local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitPosition = Spring.GetUnitPosition
local spGetFeaturePosition = Spring.GetFeaturePosition
local SetWatchWeapon = Script.SetWatchWeapon
local spGetValidUnitID = Spring.ValidUnitID

local g_CHAR = string.byte('g')
local u_CHAR = string.byte('u')
local f_CHAR = string.byte('f')

local projectiles = {}
local config = {}

local debugModeEnabled = false
local name = "[weapon_ballisticguidance.lua]: "
local updateRate = 3

---------------------------------------------------------------------
---------------------------------------------------------------------


if debugModeEnabled then spEcho(name.."Scanning weapondefs") end
local wid
for wid = 1, #WeaponDefs do
	local wdef = WeaponDefs[wid]
	local params = wdef.customParams
	if params and params.ballistic_guidance then
		if debugModeEnabled then spEcho(name.."Parsing Weapon. ID:" .. wid .. " Name:".. wdef.name) end
		config[wid] = {}
		config[wid].guidance = tonumber(params.ballistic_guidance) / 900 * updateRate
		config[wid].grav = wdef.myGravity
		SetWatchWeapon(wid, true)
	end
end
if debugModeEnabled then spEcho(name.."Finished scanning weapondefs") end


function gadget:ProjectileCreated(proID, proOwnerID, wDefId)
	if config[wDefId] then
		if debugModeEnabled then spEcho(name.."Added Projectile. ID:" .. proID) end
		projectiles[proID] = {wDef = wDefId}
	end
end

local function getAirtime(yVel, grav, height)
	return (yVel + sqrt(2*grav*height + yVel^2)) / grav
end

function gadget:ProjectileDestroyed(proID)
	projectiles[proID] = nil
end

function gadget:GameFrame(f)
	if f % updateRate ~= 0 then
		return nil
	end

	for projID, proj in pairs(projectiles) do
		if debugModeEnabled then spEcho(name.."Processing Projectile. ID:" .. projID) end
		local projConfig = config[proj.wDef]
		local hastarget = true
		local tx, ty, tz
		local t, tpos = spGetProjectileTarget(projID)
		if t == g_CHAR then
			tx, ty, tz = tpos[1], tpos[2], tpos[3]
		elseif t == u_CHAR then
			tx, ty, tz = spGetUnitPosition(tpos)
		elseif t == f_CHAR then
			tx, ty, tz = spGetFeaturePosition(tpos)
		else -- If we really don't know what's going on, then safest to just not do anything
			hastarget = false
		end

		if hastarget then
			local px, py, pz = spGetProjectilePosition(projID)
			local vx, vy, vz = spGetProjectileVelocity(projID)
			local ttt = getAirtime(vy, projConfig.grav, py-ty)
			local dx, dz = (tx-px)/ttt - vx, (tz-pz)/ttt - vz
			local norm = math.min(1, projConfig.guidance/sqrt(dx*dx + dz*dz))
			local ax, az = dx*norm, dz*norm
			spSetProjectileVelocity(projID, vx+ax, vy, vz+az)
		end
	end
end
