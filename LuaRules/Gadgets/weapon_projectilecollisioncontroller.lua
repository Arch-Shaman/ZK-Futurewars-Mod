if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Projectile Collision Controller",
		desc      = "a sane interface for SetProjectileCollsion and other projectile collision control tools",
		author    = "Shaman. Stuff",
		date      = "12/19/2020",
		license   = "CC-0",
		layer     = -math.huge,
		enabled   = true,
	}
end

local projectiles = {}
local queuedChanges = {}
local colCtrlDefs = {}

local spEcho = Spring.Echo
local spGetGameFrame = Spring.GetGameFrame
local spSetProjectileCollision = Spring.SetProjectileCollision

local debug = true

local function InclusiveBoolCast(string, default)
	if string == nil then
		return default
	else
		return (string and string ~= "false" and string ~= "0")
	end
end

for i=1, #WeaponDefs do
	local wd = WeaponDefs[i]
	local curRef = wd.customParams
	local wparam = {}
	
	wparam.colEnableTime = tonumber(curRef.colenabletime) and math.floor(tonumber(curRef.colenabletime))
	wparam.enableColAtApoapsis = InclusiveBoolCast(curRef.enablecolatapoapsis)
	
	if next(wparam) then
		colCtrlDefs[i] = wparam
	end
end

if debug then
	Spring.Utilities.TableEcho(colCtrlDefs, "colCtrlDefs")
end

local function SetProjectileCollision(proID, state)
	spEcho("checking"..tostring(projectiles[proID]))
	if not state and (projectiles[proID] == nil) then
		spEcho("disabling")
		projectiles[proID] = state
		spSetProjectileCollision(proID)
	elseif not state == projectiles[proID] then
		spEcho("toggling")
		projectiles[proID] = state
		spSetProjectileCollision(proID)
	end
end

local function QueueProjectileCollisionChange(proID, state, frame)
	if frame <= spGetGameFrame() then
		SetProjectileCollsion(proID, state)
	end
	queuedChanges[frame] = queuedChanges[frame] or {}
	queuedChanges[frame][proID] = state
end

local function GetProjectileCollision(proID)
	return projectiles[proID] or true
end

GG.SetProjectileCollision = SetProjectileCollision
GG.GetProjectileCollision = GetProjectileCollision
GG.QueueProjectileCollisionChange = QueueProjectileCollisionChange

function gadget:ProjectileDestroyed(proID)
	projectiles[proID] = nil
end

function gadget:GameFrame(f)
	for proID, state in pairs(queuedChanges[f] or {}) do
		SetProjectileCollision(proID, state)
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponDefID)
	if not colCtrlDefs[weaponDefID] then
		return
	end
	local colCtrlDef = colCtrlDefs[weaponDefID]
	if colCtrlDef.colEnableTime then
		spEcho("spawnprojectile call")
		SetProjectileCollision(proID, false)
		QueueProjectileCollisionChange(proID, true, spGetGameFrame() + colCtrlDef.colEnableTime)
	end
end
