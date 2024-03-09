include "constants.lua"

local base = piece "base"
local smoke1 = piece "smoke1"
local smoke2 = piece "smoke2"
local smoke3 = piece "smoke3"

function script.Create()
	Spin (smoke1, y_axis, math.rad(1000))
	StartThread(GG.Script.SmokeUnit, unitID, {smoke1, smoke2, smoke2, smoke3, smoke3, smoke3}, 6)
end

function script.Killed(recentDamage, maxHealth)
	local px, py, pz = Spring.GetUnitPosition(unitID)
	Spring.SpawnProjectile(WeaponDefNames["energyheavygeo_yellowstone"].id, {
		pos = {px, py + 5, pz},
		["end"] = {px, py, pz},
		speed = {0, 0, 0},
		ttl = 10,
		gravity = 1,
		team = Spring.GetGaiaTeamID(),
		owner = unitID,
	})
	local severity = recentDamage / maxHealth
	if (severity <= .25) then
		Explode(base, SFX.NONE)
		return 1 -- corpsetype
	elseif (severity <= .5) then
		Explode(base, SFX.NONE)
		return 1 -- corpsetype
	else
		Explode(base, SFX.SHATTER)
		return 2 -- corpsetype
	end
end
