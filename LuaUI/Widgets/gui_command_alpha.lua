
function widget:GetInfo()
	return {
		name      = "Command Alpha",
		desc      = "Sets custom command draw parameters.",
		author    = "GoogleFrog",
		date      = "5 April, 2020",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

----------------------------------------------------
----------------------------------------------------



local cmdAlpha = (tonumber(Spring.GetConfigString("CmdAlpha") or "0.7") or 0.7)
local terraformColor = {0.7, 0.75, 0, cmdAlpha}

function widget:Initialize()
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.ORBIT_DRAW, "Guard", {0.3, 0.3, 1.0, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.RAW_MOVE, "RawMove", {0.5, 1.0, 0.5, cmdAlpha}) -- "" mean there's no MOVE cursor if the command is drawn.
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.REARM, "Repair", {0, 1, 1, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.FIND_PAD, "Guard", {0, 1, 1, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.JUMP, "Jump", {0, 1, 0, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.JUMP, "Jump", {0, 1, 0, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.ONECLICK_WEAPON, "dgun", {1, 1, 1, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.UNIT_SET_TARGET, "SetTarget", {1.0, cmdAlpha, 0.0, cmdAlpha}, true)
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.UNIT_SET_TARGET_CIRCLE, "SetTarget", {1.0, cmdAlpha, 0.0, cmdAlpha}, true)
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.PLACE_BEACON, "Beacon", {0.2, 0.8, 0, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.WAIT_AT_BEACON, "Beacon Queue", {0.1, 0.1, 1, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.RAMP, "Ramp", terraformColor, false)
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.LEVEL, "Level", terraformColor, false)
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.RAISE, "Raise", terraformColor, false)
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.SMOOTH, "Smooth", terraformColor, false)
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.RESTORE, "Restore2", terraformColor, false)
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.EXTENDED_LOAD, CMD.LOAD_UNITS, {0,0.6,0.6,cmdAlpha},true)
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.EXTENDED_UNLOAD, CMD.UNLOAD_UNITS, {0.6,0.6,0,cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.TURN, "Patrol", {0, 1, 0, cmdAlpha})
	Spring.SetCustomCommandDrawData(Spring.Utilities.CMD.GREYGOO, "Reclaim", {0.8, 0.3, 0.3, cmdAlpha}, true)
end
