-- reloadTime is in seconds
-- offsets = {x,y,z} , where x is left(-)/right(+), y is up(+)/down(-), z is forward(+)/backward(-)
local DRONES_COST_RESOURCES = false

local carrierDefs = {}

local carrierDefNames = {

	shipcarrier = {
		spawnPieces = {"DroneAft", "DroneFore", "DroneLower", "DroneUpper", "DroneInner"},
		{
			drone = UnitDefNames.dronecarry.id,
			reloadTime = 6,
			maxDrones = 5,
			spawnSize = 3,
			range = 500,
			maxChaseRange = 700,
			buildTime = 10,
			maxBuild = 5,
			launchVel = {0, 2, 0},
		},
		{
			drone = UnitDefNames.dronecon.id,
			reloadTime = 8,
			maxDrones = 5,
			spawnSize = 2,
			range = 500,
			maxChaseRange = 700,
			buildTime = 13,
			maxBuild = 5,
			launchVel = {0, 2, 0},
		},
		{
			drone = UnitDefNames.dronecarrybomber.id,
			reloadTime = 10,
			maxDrones = 16,
			spawnSize = 2,
			range = 200000,
			maxChaseRange = 200000,
			controllable = true,
			buildTime = 30,
			maxBuild = 5,
			launchVel = {0, 2, 0},
		},
	},
	shiplightcarrier = {
		noDroneSetTarget = true,
		spawnPieces = {"Drone1", "Drone2", "Drone3", "Drone4", "Drone5", "Drone6"},
		{
			drone = UnitDefNames.dronecarry.id,
			reloadTime = 9,
			maxDrones = 6,
			spawnSize = 1,
			range = 200000,
			maxChaseRange = 200000,
			buildTime = 10,
			sitsOnPad = true,
			untargetableOnPad = true,
			canLaunch = true,
			launchedLife = 21,
			maxBuild = 1,
			launchVel = {0, 4, 0},
		},
	},
	--gunshipkrow = { {drone = UnitDefNames.dronelight.id, reloadTime = 15, maxDrones = 6, spawnSize = 2, range = 900, buildTime=3,
	-- offsets = {0,0,0,colvolMidX=0, colvolMidY=0,colvolMidZ=0,aimX=0,aimY=0,aimZ=0}},
	striderfunnelweb = {
		spawnPieces = {"emitl", "emitr"},
		{
			drone = UnitDefNames.dronelight.id, 
			reloadTime = 5, 
			maxDrones = 9, 
			spawnSize = 2, 
			range = 1000,
			maxChaseRange = 1200,
			buildTime = 5, 
			maxBuild = 2,
			offsets = {0, 15, 0},
		},
		{
			drone = UnitDefNames.dronecon.id,
			reloadTime = 10,
			maxDrones = 6,
			spawnSize = 2,
			range = 600,
			maxChaseRange = 800,
			buildTime = 10,
			maxBuild = 2,
			offsets = {0, 15, 0},
		},
		{
			drone = UnitDefNames.droneheavyslow.id,
			reloadTime = 9, 
			maxDrones = 3, 
			spawnSize = 1, 
			range = 1000,
			maxChaseRange = 1200,
			buildTime = 8, 
			maxBuild = 2,
			offsets = {0, 15, 0},
		},
	},
	nebula = {
		spawnPieces = {"pad1", "pad2", "pad3", "pad4"},
		{
			drone = UnitDefNames.dronefighter.id,
			reloadTime = 4,
			maxDrones = 18,
			spawnSize = 4,
			range = 1000,
			maxChaseRange = 1200,
			buildTime = 5,
			maxBuild = 4,
			offsets = {0, 8, 0, colvolMidX = 0, colvolMidY = 30, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}, --shift colvol to avoid collision.
		},
	},
	factoryveh = {
		spawnPieces = {'Train', 'CoverL1', 'CoverR1'},
		{
			drone = UnitDefNames.dronelight.id, 
			reloadTime = 10, 
			maxDrones = 8, 
			spawnSize = 1, 
			range = 800,
			maxChaseRange = 1000,
			buildTime = 20, 
			maxBuild = 3,
			offsets = {0, 35, 0, colvolMidX = 0, colvolMidY = 30, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0},
		},
		{
			drone = UnitDefNames.droneheavyslow.id,
			reloadTime = 20,
			maxDrones = 2,
			spawnSize = 1,
			range = 500,
			maxChaseRange = 700,
			buildTime = 25,
			maxBuild = 1,
			offsets = {0, 35, 0, colvolMidX = 0, colvolMidY = 30, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}, --shift colvol to avoid collision.
		},
	}, --turret
	vehscout = {
		spawnPieces = {"turret"},
		{
			drone = UnitDefNames.dronelight.id, 
			reloadTime = 13, 
			maxDrones = 1, 
			spawnSize = 1, 
			range = 300,
			maxChaseRange = 400,
			buildTime = 15, 
			maxBuild = 1,
			offsets = {0, 35, 0, colvolMidX = 0, colvolMidY = 30, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0},
		},
	},
	vehcon = {
		spawnPieces = {"turret"},
		{
			drone = UnitDefNames.dronelight.id, 
			reloadTime = 10, 
			maxDrones = 1, 
			spawnSize = 1, 
			range = 350,
			maxChaseRange = 450,
			buildTime = 15, 
			maxBuild = 1,
			offsets = {0, 35, 0, colvolMidX = 0, colvolMidY = 30, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0},
		},
	},
	plateveh = {
		spawnPieces = {"train"},
		{
			drone = UnitDefNames.dronelight.id, 
			reloadTime = 15, 
			maxDrones = 5, 
			spawnSize = 1, 
			range = 700,
			maxChaseRange = 900,
			buildTime = 20, 
			maxBuild = 1,
			offsets = {0, 35, 0, colvolMidX = 0, colvolMidY = 30, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0},
		},
		{
			drone = UnitDefNames.droneheavyslow.id,
			reloadTime = 30,
			maxDrones = 1,
			spawnSize = 1,
			range = 400,
			maxChaseRange = 600,
			buildTime = 18,
			maxBuild = 1,
			offsets = {0, 35, 15, colvolMidX = 0, colvolMidY = 30, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}, --shift colvol to avoid collision.
		},
	},
	pw_garrison = {
		spawnPieces = {"drone"},
		{
			drone = UnitDefNames.dronelight.id,
			reloadTime = 3,
			maxDrones = 16,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 2,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
		{
			drone = UnitDefNames.droneheavyslow.id,
			reloadTime = 10,
			maxDrones = 2,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 5,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
		{
			drone = UnitDefNames.droneassault.id,
			reloadTime = 10,
			maxDrones = 2,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 5,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
	},
	pw_grid = {
		spawnPieces = {"drone"},
		{
			drone = UnitDefNames.droneheavyslow.id,
			reloadTime = 3,
			maxDrones = 12,
			spawnSize = 1,
			range = 1000,
			maxChaseRange = 1200,
			buildTime = 2,
			maxBuild = 1,
			offsets = {0, 5, 0},
		},
		{
			drone = UnitDefNames.dronecon.id,
			reloadTime = 5,
			maxDrones = 2,
			spawnSize = 1,
			range = 1000,
			maxChaseRange = 1200,
			buildTime = 5,
			maxBuild = 1,
			offsets = {0, 5, 0},
		},
	},
	pw_hq_attacker = {
		spawnPieces = {"drone"},
		{
			drone = UnitDefNames.dronelight.id,
			reloadTime = 1,
			maxDrones = 18,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 1,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
		{
			drone = UnitDefNames.droneheavyslow.id,
			reloadTime = 5,
			maxDrones = 3,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 3,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
		{
			drone = UnitDefNames.droneassault.id,
			reloadTime = 5,
			maxDrones = 3,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 3,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
		{
			drone = UnitDefNames.dronecon.id,
			reloadTime = 5,
			maxDrones = 4,
			spawnSize = 1,
			range = 500,
			maxChaseRange = 750,
			buildTime = 3,
			maxBuild = 1,
			offsets = {0, 5, 0},
		},
	},
	pw_hq_defender = {
		spawnPieces = {"drone"},
		{
			drone = UnitDefNames.dronelight.id,
			reloadTime = 1,
			maxDrones = 18,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 1,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
		{
			drone = UnitDefNames.droneheavyslow.id,
			reloadTime = 5,
			maxDrones = 3,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 3,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
		{
			drone = UnitDefNames.droneassault.id,
			reloadTime = 5,
			maxDrones = 3,
			spawnSize = 1,
			range = 1200,
			maxChaseRange = 1500,
			buildTime = 3,
			maxBuild = 1,
			offsets = {0, 3, 0},
		},
		{
			drone = UnitDefNames.dronecon.id,
			reloadTime = 5,
			maxDrones = 4,
			spawnSize = 1,
			range = 500,
			maxChaseRange = 700,
			buildTime = 3,
			maxBuild = 1,
			offsets = {0, 5, 0},
		},
	},
}

local presets = {
	module_companion_drone = {
		drone = UnitDefNames.dronelight.id,
		reloadTime = 3,
		maxDrones = 2,
		spawnSize = 2,
		range = 700,
		maxChaseRange = 850,
		buildTime = 2,
		maxBuild = 1,
		offsets = {0, 35, 0}
	},
	module_battle_drone = {
		drone = UnitDefNames.droneheavyslow.id,
		reloadTime = 6,
		maxDrones = 1,
		spawnSize = 2,
		range = 700,
		maxChaseRange = 850,
		buildTime = 4,
		maxBuild = 1,
		offsets = {0, 35, 0}
	},
}

local unitRulesCarrierDefs = {
	drone = {
		drone = UnitDefNames.dronelight.id,
		reloadTime = 15,
		maxDrones = 1,
		spawnSize = 2,
		range = 600,
		maxChaseRange = 800,
		buildTime = 20,
		maxBuild = 6,
		offsets = {0, 50, 0}
	},
	droneheavyslow = {
		drone = UnitDefNames.droneheavyslow.id,
		reloadTime = 20,
		maxDrones = 1,
		spawnSize = 2,
		range = 600,
		maxChaseRange = 800,
		buildTime = 20,
		maxBuild = 6,
		offsets = {0, 50, 0}
	},
	dronecon = {
		drone = UnitDefNames.dronecon.id,
		reloadTime = 20,
		maxDrones = 1,
		spawnSize = 2,
		range = 600,
		maxChaseRange = 800,
		buildTime = 20,
		maxBuild = 6,
		offsets = {0, 50, 0}
	},
	droneassault = {
		drone = UnitDefNames.droneassault.id,
		reloadTime = 20,
		maxDrones = 1,
		spawnSize = 2,
		range = 600,
		maxChaseRange = 800,
		buildTime = 20,
		maxBuild = 6,
		offsets = {0, 50, 0}
	},
}

--[[
for name, ud in pairs(UnitDefNames) do
	if ud.customParams.sheath_preset then
		sheathDefNames[name] = Spring.Utilities.CopyTable(presets[ud.customParams.sheath_preset], true)
	end
end
]]--
for id, ud in pairs(UnitDefs) do
	if ud.customParams and ud.customParams.drones then
		local droneFunc = loadstring("return "..ud.customParams.drones)
		local drones = droneFunc()
		carrierDefs[id] = {}
		for i=1,#drones do
			carrierDefs[id][i] = Spring.Utilities.CopyTable(presets[drones[i]])
		end
	end
end

for name, data in pairs(carrierDefNames) do
	-- Don't repeat yourself
	for i=1, #data do
		local droneSet = data[i]
		droneSet.offsets = droneSet.offsets or {}
		local offsets = droneSet.offsets
		offsets[1] = offsets[1] or 0
		offsets[2] = offsets[2] or 0
		offsets[3] = offsets[3] or 0
		offsets["colvolMidX"] = offsets["colvolMidX"] or 0
		offsets["colvolMidY"] = offsets["colvolMidY"] or 0
		offsets["colvolMidZ"] = offsets["colvolMidZ"] or 0
		offsets["aimX"] = offsets["aimX"] or 0
		offsets["aimY"] = offsets["aimY"] or 0
		offsets["aimZ"] = offsets["aimZ"] or 0
		droneSet.launchVel = droneSet.launchVel or {}
		local launchVel = droneSet.launchVel
		launchVel[1] = launchVel[1] or 0
		launchVel[2] = launchVel[2] or 0
		launchVel[3] = launchVel[3] or 0

		if droneSet.launchedLife then
			droneSet.launchedLife = droneSet.launchedLife * Game.gameSpeed
		end
	end
	
	if UnitDefNames[name] then
		carrierDefs[UnitDefNames[name].id] = data
	end
end

local thingsWhichAreDrones = {
	[UnitDefNames.dronecarry.id] = true,
	[UnitDefNames.dronelight.id] = true,
	[UnitDefNames.droneheavyslow.id] = true,
	[UnitDefNames.dronefighter.id] = true,
	[UnitDefNames.dronecon.id] = true,
	[UnitDefNames.droneassault.id] = true,
}

local function ProcessCarrierDef(carrierData)
	local ud = UnitDefs[carrierData.drone]
	-- derived from: time_to_complete = (1.0/build_step_fraction)*build_interval
	local buildUpProgress = 1/(carrierData.buildTime)*(1/30)
	carrierData.buildStep = buildUpProgress
	carrierData.buildStepHealth = buildUpProgress*ud.health
	
	if DRONES_COST_RESOURCES then
		carrierData.buildCost = ud.metalCost
		carrierData.buildStepCost = buildUpProgress*carrierData.buildCost
		carrierData.perSecondCost = carrierData.buildCost/carrierData.buildTime
	end
	
	carrierData.colvolTweaked = carrierData.offsets.colvolMidX ~= 0 or carrierData.offsets.colvolMidY ~= 0
									or carrierData.offsets.colvolMidZ ~= 0 or carrierData.offsets.aimX ~= 0
										or carrierData.offsets.aimY ~= 0 or carrierData.offsets.aimZ ~= 0
	return carrierData
end

for name, carrierData in pairs(carrierDefs) do
	for i = 1, #carrierData do
		carrierData[i] = ProcessCarrierDef(carrierData[i])
	end
end

for name, carrierData in pairs(unitRulesCarrierDefs) do
	carrierData = ProcessCarrierDef(carrierData)
end

local droneLaunchDefs = {}

for i = 1, #WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams and wd.customParams.drone_launch then
		droneLaunchDefs[i] = {
			launch_rate = tonumber(wd.customParams.drone_launch_rate) or 0,
		}
	end
end

return carrierDefs, thingsWhichAreDrones, unitRulesCarrierDefs, droneLaunchDefs
