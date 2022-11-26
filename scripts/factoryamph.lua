include "constants.lua"

local base, turret, arm_1, arm_2, arm_3, nanobase, nanoemit, pad, nozzle, cylinder, body = piece ('base', 'turret', 'arm_1', 'arm_2', 'arm_3', 'nanobase', 'nanoemit', 'pad', 'nozzle', 'cylinder', 'body')

local nanoPieces = { nanoemit }
local smokePiece = { base }

local spGetUnitRulesParam = Spring.GetUnitRulesParam
local BEACON_SPAWN_SPEED = 8 / tonumber(UnitDef.customParams.teleporter_beacon_spawn_time)

local PRIVATE = {private = true}
local INLOS = {inlos = true}

--local deployed = false
local beaconCreateX, beaconCreateZ

local SIG_BEACON = 2

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- Create beacon animation and delay


local function Create_Beacon_Thread(x,z)
	--Spring.Echo("Create_Beacon")
	local y = Spring.GetGroundHeight(x,z) or 0
	
	Signal(SIG_BEACON)
	SetSignalMask(SIG_BEACON)
	
	beaconCreateX, beaconCreateZ = x, z
	Spring.SetUnitRulesParam(unitID, "tele_creating_beacon_x", x, PRIVATE)
	Spring.SetUnitRulesParam(unitID, "tele_creating_beacon_z", z, PRIVATE)
	GG.PlayFogHiddenSound("sounds/misc/teleport_loop.wav", 3, x, y, z)
	for i = 1, 90 do
		local speedMult = (spGetUnitRulesParam(unitID,"baseSpeedMult") or 1) * BEACON_SPAWN_SPEED
		Sleep(100/speedMult)
		if i == 1 then
			GG.WaitWaitMoveUnit(unitID)
		end
		local stunnedOrInbuild = Spring.GetUnitIsStunned(unitID)
		local disarm = spGetUnitRulesParam(unitID,"disarmed") == 1
		while stunnedOrInbuild or disarm do
			Sleep(100)
			stunnedOrInbuild = Spring.GetUnitIsStunned(unitID)
			disarm = spGetUnitRulesParam(unitID,"disarmed") == 1
		end
		Spring.SpawnCEG("teleport_progress", x, y + 14, z, 0, 0, 0, 0)
		if i == 30 or i == 60 then
			GG.PlayFogHiddenSound("sounds/misc/teleport_loop.wav", 3, x, y, z)
		end
	end

	GG.tele_createBeacon(unitID,x,z)
	
	Spring.SetUnitRulesParam(unitID, "tele_creating_beacon_x", nil, PRIVATE)
	Spring.SetUnitRulesParam(unitID, "tele_creating_beacon_z", nil, PRIVATE)
	beaconCreateX, beaconCreateZ = nil, nil
	
	Spring.SpawnCEG("teleport_in", x, y, z, 0, 0, 0, 1)
	Spring.SetUnitRulesParam(unitID, "teleActive", 1, INLOS)
	GG.tele_deployTeleport(unitID)
end

function StopCreateBeacon(resetAnimation)
	Signal(SIG_BEACON)
	if beaconCreateX then
		Spring.SetUnitRulesParam(unitID, "tele_creating_beacon_x", nil, PRIVATE)
		Spring.SetUnitRulesParam(unitID, "tele_creating_beacon_z", nil, PRIVATE)
		beaconCreateX, beaconCreateZ = nil, nil
	end
end

function Create_Beacon(x,z)
	--Spring.Echo("Create_Beacon")
	if x == beaconCreateX and z == beaconCreateZ then
		return
	end
	StartThread(Create_Beacon_Thread,x,z)
end

function UndeployTeleport()
	--deployed = false
end

function activity_mode(n) -- needed otherwise bad things happen.
	
end

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

local function Open ()
	Signal (1)
	SetSignalMask (1)

	Turn (arm_1, x_axis, math.rad(-85), math.rad(85))
	Turn (arm_2, x_axis, math.rad(170), math.rad(170))
	Turn (arm_3, x_axis, math.rad(-60), math.rad(60))
	Turn (nanobase, x_axis, math.rad(10), math.rad(10))

	SetUnitValue(COB.YARD_OPEN, 1)
	SetUnitValue(COB.INBUILDSTANCE, 1)
	--SetUnitValue (COB.BUGGER_OFF, 1)
	GG.Script.UnstickFactory(unitID)
end

local function Close()
	Signal (1)
	SetSignalMask (1)

	SetUnitValue(COB.YARD_OPEN, 0)
	--SetUnitValue (COB.BUGGER_OFF, 0)
	SetUnitValue(COB.INBUILDSTANCE, 0)

	Turn (arm_1, x_axis, 0, math.rad(34))
	Turn (arm_2, x_axis, 0, math.rad(68))
	Turn (arm_3, x_axis, 0, math.rad(24))
	Turn (nanobase, x_axis, 0, math.rad(4))
end

function script.Create()
	StartThread (GG.Script.SmokeUnit, unitID, smokePiece)
	Spring.SetUnitNanoPieces (unitID, nanoPieces)
end

function script.QueryNanoPiece ()
	GG.LUPS.QueryNanoPiece (unitID, unitDefID, Spring.GetUnitTeam(unitID), nanoemit)
	return nanoemit
end

function script.Activate ()
	StartThread (Open)
end

function script.Deactivate ()
	StartThread (Close)
end

function script.QueryBuildInfo ()
	return pad
end

local explodables = {nozzle, cylinder, arm_1, arm_2, arm_3}
function script.Killed (recentDamage, maxHealth)
	local severity = recentDamage / maxHealth

	for i = 1, #explodables do
		if (severity > math.random()) then Explode(explodables[i], SFX.SMOKE + SFX.FIRE) end
	end

	if (severity <= .5) then
		return 1
	else
		Explode (body, SFX.SHATTER)
		return 2
	end
end
