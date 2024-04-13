-- Base game --

local CMDs = VFS.Include("LuaRules/Configs/customcmds.lua", nil, VFS.GAME)
local AmmoBasedCommands

-- Future Wars --
do
	local fwCMDs, overrides, extras = VFS.Include("LuaRules/Configs/fwcustomcmds.lua", nil, VFS.GAME)
	AmmoBasedCommands = extras
	for name, id in pairs(overrides) do
		CMDs[name] = id
	end
	for k, v in pairs(fwCMDs) do
		CMDs[k] = v
	end
end

Spring.Utilities.CMD = CMDs
Spring.Utilities.AmmoBasedCommands = AmmoBasedCommands