-- reloadTime is in seconds

local oneClickWepDefs = {}

local oneClickWepDefNames = {
	terraunit = {
		{ functionToCall = "Detonate", name = "Cancel", tooltip = "Cancel selected terraform units.", texture = "LuaUI/Images/Commands/Bold/cancel.png", partBuilt = true},
	},
	subscout = {
		{ functionToCall = "Detonate", name = "Cancel", tooltip = "Cancel selected terraform units.", texture = "LuaUI/Images/Commands/Bold/cancel.png", partBuilt = true},
	},
	vehraid = {
		{ functionToCall = "Sprint", reloadTime = 300, name = "Sprint", useSpecialReloadFrame = true, tooltip = "Sprint: Increase speed by 380% for 1.5seconds, slow down by 33% afterward for 0.6s. 10sec cooldown.", texture = "LuaUI/Images/Commands/Bold/sprint.png",},
	},
	shipriot = {
		{ functionToCall = "Sprint", reloadTime = 600, name = "Sprint", useSpecialReloadFrame = true, tooltip = "Sprint: Increase speed by 100% for 3 seconds, slow down by 20% afterward for 17s. 20sec cooldown.", texture = "LuaUI/Images/Commands/Bold/sprint.png",},
	},
	gunshipkrow = {
		{ functionToCall = "ClusterBomb", reloadTime = 854, name = "Annhilator Beam", tooltip = "Annhilator Beam: Activates a massive death laser to erase ground-loving plebs from exsitance.", weaponToReload = 3, texture = "LuaUI/Images/Commands/Bold/bomb.png",},
	},
	--hoverdepthcharge = {
	--	{ functionToCall = "ShootDepthcharge", reloadTime = 256, name = "Drop Depthcharge", tooltip = "Drop Depthcharge: Drops a on the sea surface or ground.", weaponToReload = 1, texture = "LuaUI/Images/Commands/Bold/dgun.png",},
	--},
	cloakbomb = {
		{ functionToCall = "Detonate", name = "Detonate", tooltip = "Detonate: Kill selected bomb units.",  texture = "LuaUI/Images/Commands/Bold/detonate.png",},
	},
	shieldbomb = {
		{ functionToCall = "Detonate", name = "Detonate", tooltip = "Detonate: Kill selected bomb units.", texture = "LuaUI/Images/Commands/Bold/detonate.png",},
	},
	jumpbomb = {
		{ functionToCall = "Detonate", name = "Detonate", tooltip = "Detonate: Kill selected bomb units.",  texture = "LuaUI/Images/Commands/Bold/detonate.png",},
	},
	gunshipbomb = {
		{ functionToCall = "Detonate", name = "Detonate", tooltip = "Detonate: Kill selected bomb units.", texture = "LuaUI/Images/Commands/Bold/detonate.png",},
	},
	amphbomb = {
		{ functionToCall = "Detonate", name = "Detonate", tooltip = "Detonate: Kill selected bomb units.",  texture = "LuaUI/Images/Commands/Bold/detonate.png",},
	},
	shieldscout = {
		{ functionToCall = "Detonate", name = "Detonate", tooltip = "Detonate: Kill selected bomb units.", texture = "LuaUI/Images/Commands/Bold/detonate.png",},
	},
	bomberdisarm = {
		{ functionToCall = "StartRun", name = "Start Run", tooltip = "Unleash Lightning: Manually activate Thunderbird run.", texture = "LuaUI/Images/Commands/Bold/bomb.png",},
	},
	planelightscout = {
		{ functionToCall = "UseDgun", name = "Discharge Battery", tooltip = "Battery Discharge\nDischarge the entire battery below you, dealing EMP damage.", texture = "LuaUI/Images/Commands/Bold/bomb.png",},
	},
	tankraid = {
		{ functionToCall = "FlameTrail", reloadTime = 450, name = "Afterburner Overload", tooltip = "Blast ahead and leave a path of devastating flame in your wake", useSpecialReloadFrame = true, texture = "LuaUI/Images/Commands/Bold/sprint.png",},
	},
	tankheavyassault = {
		{ functionToCall = "Minigun", reloadTime = 2250, name = "Hellfire Minigun", tooltip = "Activate the Hellfire Miniguns to spray incendiary rounds around the front of the turret.", useSpecialReloadFrame = true, texture = "LuaUI/Images/commands/Bold/dgun.png",},
	},
	--planefighter = {
	--	{ functionToCall = "Sprint", reloadTime = 850, name = "Speed Boost", tooltip = "Speed boost (5x for 1 second)", useSpecialReloadFrame = true, texture = "LuaUI/Images/Commands/Bold/sprint.png",},
	--},
	planecon = {
		{ functionToCall = "Sprint", reloadTime = 1200, name = "Speed Boost", tooltip = "Speed boost (5x for 1 second)", useSpecialReloadFrame = true, texture = "LuaUI/Images/Commands/Bold/sprint.png",},
	},
	vehassault = {
		{ functionToCall = "Sprint", reloadTime = 600, name = "Pursuit", tooltip = "Increase speed by 3x for 1.5s, followed by a slowdown of 66% for 3s.\n20s cooldown.", useSpecialReloadFrame = true, texture = "LuaUI/Images/Commands/Bold/sprint.png",},
	},
	planescout = {
		{ functionToCall = "Cloak", reloadTime = 900, name = "Activate Deep Cloak", tooltip = "Cloaks for 10 seconds. Does not decloak when hit unless stunned. 30s cooldown.", useSpecialReloadFrame = true, texture = "LuaUI/Images/Commands/Bold/deepcloak.png"},
	},
	gunshipheavytrans = {
		{ functionToCall = "ForceDropUnit", reloadTime = 7, name = "Drop Cargo", tooltip = "Eject Cargo: Drop the unit in the transport.", useSpecialReloadFrame = true,},
	},
	gunshiptrans = {
		{ functionToCall = "ForceDropUnit", reloadTime = 7, name = "Drop Cargo", tooltip = "Eject Cargo: Drop the unit in the transport.", useSpecialReloadFrame = true,},
	},
	gunshipraid = {
		{ functionToCall = "Overdrive", reloadTime = 900, name = "Overdrive", tooltip = "For 7 seconds: Increase weapon damage by 33%, reload and movement speed by 50%. Main weapon becomes instant hit. Disables weapons for 10 seconds afterwards.", useSpecialReloadFrame = true, texture = "LuaUI/Images/Commands/Bold/sprint.png",},
	},
	--staticmissilesilo = {
	--	dummy = true,
	--	{ functionToCall = nil, name = "Select Missiles", tooltip = "Select missiles", texture = "LuaUI/Images/Commands/Bold/missile.png"},
	--},
}


for name, data in pairs(oneClickWepDefNames) do
	if UnitDefNames[name] then
		oneClickWepDefs[UnitDefNames[name].id] = data
	end
end

return oneClickWepDefs
