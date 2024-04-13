local extraStateTypes = Spring.Utilities.AmmoBasedCommands

local stateData = {
	[Spring.Utilities.CMD.WANT_ONOFF] = 2,
	[CMD.IDLEMODE] = 2,
	[Spring.Utilities.CMD.AP_FLY_STATE] = 2,
	[Spring.Utilities.CMD.CLOAK_SHIELD] = 2,
	[Spring.Utilities.CMD.DONT_FIRE_AT_RADAR] = 2,
	[Spring.Utilities.CMD.FACTORY_GUARD] = 2,
	[Spring.Utilities.CMD.WANT_CLOAK] = 2,
	[Spring.Utilities.CMD.PRIORITY] = 3,
	[Spring.Utilities.CMD.TOGGLE_DRONES] = 2,
	[Spring.Utilities.CMD.UNIT_FLOAT_STATE] = 3,
	[Spring.Utilities.CMD.AIR_STRAFE] = 2,
	[CMD.FIRE_STATE] = 3,
	[CMD.MOVE_STATE] = 3,
	[Spring.Utilities.CMD.PUSH_PULL] = 2,
	[Spring.Utilities.CMD.MISC_PRIORITY] = 3,
	[Spring.Utilities.CMD.GOO_GATHER] = 2,
	[CMD.REPEAT] = 2,
	[Spring.Utilities.CMD.RETREAT] = 4,
	[Spring.Utilities.CMD.RETREATSHIELD] = 4,
	[Spring.Utilities.CMD.AUTOJUMP] = 2,
	[CMD.TRAJECTORY] = 2,
	[Spring.Utilities.CMD.DISABLE_ATTACK] = 2,
	[Spring.Utilities.CMD.UNIT_BOMBER_DIVE_STATE] = 4,
	--[Spring.Utilities.CMD.AUTO_CALL_TRANSPORT] = 2, -- Handled entirely in luaUI so not included here.
	--[Spring.Utilities.CMD.GLOBAL_BUILD] = 2, -- Handled entirely in luaUI so not included here.
	[Spring.Utilities.CMD.UNIT_KILL_SUBORDINATES] = 2,
	[Spring.Utilities.CMD.PREVENT_OVERKILL] = 3,
	[Spring.Utilities.CMD.PREVENT_BAIT] = 5,
	[Spring.Utilities.CMD.FIRE_AT_SHIELD] = 2,
	[Spring.Utilities.CMD.FIRE_TOWARDS_ENEMY] = 2,
	--[Spring.Utilities.CMD.SELECTION_RANK] = 2, -- Handled entirely in luaUI so not included here.
	[Spring.Utilities.CMD.UNIT_AI] = 2,
	[Spring.Utilities.CMD.OVERRECLAIM] = 2,
	[Spring.Utilities.CMD.FIRECYCLE] = 2,
	[Spring.Utilities.CMD.ARMORSTATE] = 2,
	[Spring.Utilities.CMD.QUEUE_MODE] = 2,
}

local specialHandling = {
	[Spring.Utilities.CMD.RETREAT] = function (state, options)
		if options.right then
			state = 0
		elseif state == 0 then --note: this means that to set "Retreat Off" (state = 0) you need to use the "right" modifier, whether the command is given by the player using an ui button or by Lua
			state = 1
		end
		return state
	end,
	[Spring.Utilities.CMD.RETREATSHIELD] = function (state, options)
		if options.right then
			state = 0
		elseif state == 0 then --note: this means that to set "Retreat Off" (state = 0) you need to use the "right" modifier, whether the command is given by the player using an ui button or by Lua
			state = 1
		end
		return state
	end,
}

local gadgetReverse = {
	[Spring.Utilities.CMD.PRIORITY] = true,
	[Spring.Utilities.CMD.UNIT_FLOAT_STATE] = true,
	[Spring.Utilities.CMD.MISC_PRIORITY] = true,
	[Spring.Utilities.CMD.UNIT_BOMBER_DIVE_STATE] = true,
	[Spring.Utilities.CMD.PREVENT_BAIT] = true,
	[Spring.Utilities.CMD.PREVENT_OVERKILL] = true,
	[Spring.Utilities.CMD.GOO_GATHER] = true,
	[Spring.Utilities.CMD.OVERRECLAIM] = true,
	[Spring.Utilities.CMD.FIRECYCLE] = true,
	[Spring.Utilities.CMD.ARMORSTATE] = true,
	[Spring.Utilities.CMD.QUEUE_MODE] = true,
}

for id, num in pairs(extraStateTypes) do
	stateData[id] = num
	gadgetReverse[id] = true
end

return stateData, gadgetReverse, specialHandling
