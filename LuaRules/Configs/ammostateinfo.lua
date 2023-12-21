local cmds = VFS.Include("LuaRules/Configs/ammostatecmds.lua")
local stateInfo = {}
local stateInfoByDefID = {}
local stateTypes = {}

for name, id in pairs(cmds) do
	local unitName = string.lower(name):gsub("ammo_select_", "")
	local customParams = UnitDefNames[unitName].customParams
	local count = customParams.ammocount
	stateTypes[id] = count
	stateInfo[id] = {texture = {}, stateTooltip = {}, stateDesc = {}}
	for i = 1, count do
		stateInfo[id].texture[i] = customParams["ammotexture_" .. i]
		stateInfo[id].stateTooltip[i] = customParams["ammoname_" .. i]
		stateInfo[id].stateDesc[i] = customParams["ammodesc_" .. i]
	end
	stateInfoByDefID[UnitDefNames[unitName].id] = stateInfo[id]
end

return stateTypes, stateInfo, stateInfoByDefID
