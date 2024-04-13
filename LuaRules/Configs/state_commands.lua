local extras = Spring.Utilities.AmmoBasedCommands

local stateCommands = {
	[CMD.ONOFF] = true,
	[Spring.Utilities.CMD.WANT_ONOFF] = true,
	[CMD.FIRE_STATE] = true,
	[CMD.MOVE_STATE] = true,
	[CMD.REPEAT] = true,
	[CMD.CLOAK] = true,
	[CMD.STOCKPILE] = true,
	[CMD.TRAJECTORY] = true,
	[CMD.IDLEMODE] = true,
	[Spring.Utilities.CMD.GLOBAL_BUILD] = true,
	[Spring.Utilities.CMD.FACTORY_GUARD] = true,
	[Spring.Utilities.CMD.STEALTH] = true,
	[Spring.Utilities.CMD.CLOAK_SHIELD] = true,
	[Spring.Utilities.CMD.UNIT_FLOAT_STATE] = true,
	[Spring.Utilities.CMD.PRIORITY] = true,
	[Spring.Utilities.CMD.MISC_PRIORITY] = true,
	[Spring.Utilities.CMD.RETREAT] = true,
	[Spring.Utilities.CMD.RETREATSHIELD] = true,
	[Spring.Utilities.CMD.UNIT_BOMBER_DIVE_STATE] = true,
	[Spring.Utilities.CMD.AP_FLY_STATE] = true,
	[Spring.Utilities.CMD.AP_AUTOREPAIRLEVEL] = true,
	[Spring.Utilities.CMD.UNIT_SET_TARGET] = true,
	[Spring.Utilities.CMD.UNIT_CANCEL_TARGET] = true,
	[Spring.Utilities.CMD.UNIT_SET_TARGET_CIRCLE] = true,
	[Spring.Utilities.CMD.ABANDON_PW] = true,
	[Spring.Utilities.CMD.RECALL_DRONES] = true,
	[Spring.Utilities.CMD.UNIT_KILL_SUBORDINATES] = true,
	[Spring.Utilities.CMD.GOO_GATHER] = true,
	[Spring.Utilities.CMD.PUSH_PULL] = true,
	[Spring.Utilities.CMD.UNIT_AI] = true,
	[Spring.Utilities.CMD.WANT_CLOAK] = true,
	[Spring.Utilities.CMD.DONT_FIRE_AT_RADAR] = true,
	[Spring.Utilities.CMD.AIR_STRAFE] = true,
	[Spring.Utilities.CMD.PREVENT_OVERKILL] = true,
	[Spring.Utilities.CMD.TOGGLE_DRONES] = true,
	[Spring.Utilities.CMD.AUTO_CALL_TRANSPORT] = true,
	[Spring.Utilities.CMD.SELECTION_RANK] = true,
	[Spring.Utilities.CMD.FIRE_AT_SHIELD] = true,
	[Spring.Utilities.CMD.FIRE_TOWARDS_ENEMY] = true,
}

for _, id in pairs(extras) do
	stateCommands[id] = true
end

return stateCommands
