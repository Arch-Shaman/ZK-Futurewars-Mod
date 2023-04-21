local cmds = VFS.Include("LuaRules/Configs/ammostatecmds.lua")
local stateInfo = {}
local stateTypes = {}

for name, id in pairs(cmds) do
	local unitName = string.lower(name):gsub("ammo_select_", "")
	local customParams = UnitDefNames[unitName].customParams
	local count = customParams.ammocount
	stateTypes[id] = count
	stateInfo[id] = {texture = {}, stateTooltip = {}}
	for i = 1, count do
		stateInfo[id].texture[i] = customParams["ammotexture_" .. i]
		stateInfo[id].stateTooltip[i] = customParams["ammoname_" .. i]
	end
end

return stateTypes, stateInfo
