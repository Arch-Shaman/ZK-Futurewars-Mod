local function PreprendTable(prependee, prepender)
	for i=1, #prependee do
		prepender[#prepender+1] = prependee[i]
	end
	return prepender
end

local lastWrittenVersion = 39.14
local showBriefing = false
local configLocation = "luaui\\config\\fw_patchnotes.lua"
local gameVersion = Game.gameVersion
gameVersion = string.gsub(gameVersion, "v", "")
version = gameVersion
local splittedVersion = {}
gameVersion = string.gsub(gameVersion, ".", " ")
for str in string.gmatch(gameVersion, "%S+") do
	splittedVersion[#splittedVersion + 1] = str
end
local lastSeenVersion
if VFS.FileExists(configLocation) then
	lastSeenVersion = VFS.Include(configLocation) or "0"
	lastSeenVersion = tonumber(lastSeenVersion)
else
	lastSeenVersion = ""
end

if lastSeenVersion == "" then
	showBriefing = true
else
	local modoptions = Spring.GetModOptions()
	showBriefing = lastSeenVersion < lastWrittenVersion and not ((modoptions.commwars and modoptions.commwars == "1") or Spring.GetGameRulesParam("chicken_difficulty") ~= nil)
end

local briefing = {
	modname = Game.gameName,
	version = Game.gameVersion,
	entries = {}
}

if showBriefing then
	briefing["entries"] = {
		{"update_header", fontsize = 24},
		{"entry_1"},
		{"entry_2"},
		{"entry_3", image = "unitpics/athena.png"},
		{"entry_4"},
		{""},
		{""},
	}
end

if Spring.GetGameRulesParam("chicken_difficulty") then
	local newEntries = {
		[1] = {"chicken_header", fontsize = 24},
		[2] = {"chicken_entry_1", image = "unitpics/chicken.png"},
		[3] = {"chicken_entry_2", image = "unitpics/chicken_dragon.png"},
		[4] = {"chicken_entry_3", image = "unitpics/chickenflyerqueen.png"},
		[5] = {""},
		[6] = {""},
	}
	briefing.entries = PreprendTable(briefing.entries, newEntries)
end

local modoptions = Spring.GetModOptions()

if (tonumber(modoptions["commwars"]) or 0) == 1 then
	local newEntries = {
		[1] = {"comm_wars_header", fontsize = 24},
		[2] = {"comm_wars_entry_1", image = "unitpics/commstrike.png"},
		[3] = {"comm_wars_entry_2", image = "unitpics/commweapon_disintegrator.png"},
		[4] = {""},
		[5] = {""},
	}
	if modoptions.houserules and modoptions.houserules ~= "" then
		newEntries[6] = {"houserules", fontsize = 24}
		newEntries[7] = {modoptions.houserules, notranslation = true}
	end
	briefing.entries = PreprendTable(briefing.entries, newEntries)
end

return briefing, lastWrittenVersion
