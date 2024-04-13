-- Note: This file contains our CMDs so I don't have to maintain the main list.
-- When adding a custom command use Spring.Utilities.CMD instead of the old method.

local fwCMDS = {
	SELECT_DRONES = 14003,
	AMMO_SELECT_GENERIC = 20500, -- Probably is safe.
	RETREATSHIELD = 34224,
	QUEUE_MODE = 34225,
	DRONE_SET_TARGET = 35302,
	GREYGOO = 35600,
	SWEEPFIRE = 38886, -- cmd_sweepfire gadget
	SWEEPFIRE_CANCEL = 38887,
	SWEEPFIRE_MINES = 38888,
	FIRECYCLE = 38889, -- cmd_firecycle gadget
	OVERRECLAIM = 38950,
	AUTOJUMP = 39382, -- Tactical AI / Jump Fall Avoidance
	ARMORSTATE = 39383, -- Bastion / Azimuth command.
	IMMEDIATETAKEOFF = 39384, -- Airpad abort.
}

local extras, _ = VFS.Include("LuaRules/Configs/ammostatecmds.lua")
for name, id in pairs(extras) do
	fwCMDS[name] = id
end

local overrides = {}

return fwCMDS, overrides, extras
