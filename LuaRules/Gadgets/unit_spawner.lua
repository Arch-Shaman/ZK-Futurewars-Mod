
-- NOTICE: Gadget moved to chicken_handler.lua


function gadget:GetInfo()
	return {
		name     = "Chicken Spawner",
		desc     = "Spawns burrows and chickens",
		author   = "quantum, improved by KingRaptor",
		date     = "April 29, 2008", --last update: Mei 7, 2014
		license  = "GNU GPL, v2 or later",
		layer    = 1000001,	-- must do the GameOver() thing only after gadget:awards.lua has finishes detect queen destroyed else queenKill award won't appear.
		enabled  = false --	loaded by default?
	}
end

