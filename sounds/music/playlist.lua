-- IMPORTANT: No table specified for a type means autodetect,
-- empty table specified for a type means no tracks for that type!

-- To change the music used in each circumstance, add the file name of the track, ("Earth.ogg", for example)
-- inside the curly brackets of that circumstance (in the curly brackets of "--peace = {}," for example).
-- The file (e.g. "Earth.ogg") must be in the corresponding sub folder of [InsertGameDataFolderHere]/sounds/music
-- as the circumstance you want it to be played in ([InsertGameDataFolderHere]/sounds/music/peace for example).

local dir = "sounds/music/" -- Remember to actually update this with not placeholder music later! (IF that ever happens)
local tracks = {
    war = {
		[1] = dir .. "war/Yin & Yang.ogg",
		[2] = dir .. "war/Entering the Stronghold.ogg",
		[3] = dir .. "war/Thunderdome.ogg",
		[4] = dir .. "war/Anti-gravity.ogg",
		[5] = dir .. "war/Laser Tournament.ogg",
		[6] = dir .. "war/Rhythm of the Sea.ogg",
	},
    peace = {
		[1] = dir .. "peace/Virtual Reality.ogg",
		[2] = dir .. "loading/Landing on Titan.ogg",
		[3] = dir .. "peace/Super Nova.ogg",
		[4] = dir .. "peace/Orbital Duel.ogg",
	},
    victory = {
		[1] = dir .. "victory/Modern Warstory.ogg",
	},
    briefing = {
		[1] = dir .. "loading/Landing on Titan.ogg", -- does this actually play pre-game?
	},
    defeat = {
		[1] = dir .. "defeat/Exoplanet.ogg",
	},
}

-- auto-appends directory and extension to the track names
-- can be removed if you want to specify directory yourself
--[[for type,list in pairs(tracks) do
    for i=1,#list do
		list[i] = "sounds/music/"..type.."/"..list[i]..".ogg"
    end
end]] -- toss this out because we want CUSTOM MUSIC!

return tracks
-- Note: No idea if this file actually does anything -- Shaman
