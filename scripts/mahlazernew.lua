include "constants.lua"
include "pieceControl.lua"

local ActuatorBase = piece('ActuatorBase')
local ActuatorBase_1 = piece('ActuatorBase_1')
local ActuatorBase_2 = piece('ActuatorBase_2')
local ActuatorBase_3 = piece('ActuatorBase_3')
local ActuatorBase_4 = piece('ActuatorBase_4')
local ActuatorBase_5 = piece('ActuatorBase_5')
local ActuatorBase_6 = piece('ActuatorBase_6')
local ActuatorBase_7 = piece('ActuatorBase_7')
local ActuatorMiddle = piece('ActuatorMiddle')
local ActuatorMiddle_1 = piece('ActuatorMiddle_1')
local ActuatorMiddle_2 = piece('ActuatorMiddle_2')
local ActuatorMiddle_3 = piece('ActuatorMiddle_3')
local ActuatorMiddle_4 = piece('ActuatorMiddle_4')
local ActuatorMiddle_5 = piece('ActuatorMiddle_5')
local ActuatorMiddle_6 = piece('ActuatorMiddle_6')
local ActuatorMiddle_7 = piece('ActuatorMiddle_7')
local ActuatorTip = piece('ActuatorTip')
local ActuatorTip_1 = piece('ActuatorTip_1')
local ActuatorTip_2 = piece('ActuatorTip_2')
local ActuatorTip_3 = piece('ActuatorTip_3')
local ActuatorTip_4 = piece('ActuatorTip_4')
local ActuatorTip_5 = piece('ActuatorTip_5')
local ActuatorTip_6 = piece('ActuatorTip_6')
local ActuatorTip_7 = piece('ActuatorTip_7')

local Basis = piece('Basis')
local Dock = piece('Dock')
local Dock_1 = piece('Dock_1')
local Dock_2 = piece('Dock_2')
local Dock_3 = piece('Dock_3')
local Dock_4 = piece('Dock_4')
local Dock_5 = piece('Dock_5')
local Dock_6 = piece('Dock_6')
local Dock_7 = piece('Dock_7')
local Emitter = piece('Emitter')
local EmitterMuzzle = piece('EmitterMuzzle')

-- these are satellite pieces
local LimbA1 = piece('LimbA1')
local LimbA2 = piece('LimbA2')
local LimbB1 = piece('LimbB1')
local LimbB2 = piece('LimbB2')
local LimbC1 = piece('LimbC1')
local LimbC2 = piece('LimbC2')
local LimbD1 = piece('LimbD1')
local LimbD2 = piece('LimbD2')
local Satellite = piece('Satellite')
local SatelliteMuzzle = piece('SatelliteMuzzle')
local SatelliteMount = piece('SatelliteMount')


local LongSpikes = piece('LongSpikes')
local LowerCoil = piece('LowerCoil')

local ShortSpikes = piece('ShortSpikes')
local UpperCoil = piece('UpperCoil')

local DocksClockwise = {Dock,Dock_1,Dock_2,Dock_3}
local DocksCounterClockwise = {Dock_4,Dock_5,Dock_6,Dock_7}
local ActuatorBaseClockwise = {ActuatorBase,ActuatorBase_1,ActuatorBase_2,ActuatorBase_3}
local ActuatorBaseCCW = {ActuatorBase_4,ActuatorBase_5,ActuatorBase_6,ActuatorBase_7}
local ActuatorMidCW =  {ActuatorMiddle,ActuatorMiddle_1,ActuatorMiddle_2,ActuatorMiddle_3}
local ActuatorMidCCW = {ActuatorMiddle_4,ActuatorMiddle_5,ActuatorMiddle_6,ActuatorMiddle_7}
local ActuatorTipCW =  {ActuatorTip,ActuatorTip_1,ActuatorTip_2,ActuatorTip_3}
local ActuatorTipCCW = {ActuatorTip_4,ActuatorTip_5,ActuatorTip_6,ActuatorTip_7}

local smokePiece = {Basis,ActuatorBase,ActuatorBase_1,ActuatorBase_2,ActuatorBase_3,ActuatorBase_4,ActuatorBase_5,ActuatorBase_6,ActuatorBase_7}

local YAW_AIM_RATE = math.rad(2.5)
local PITCH_AIM_RATE = math.rad(0.75)

local oldHeight = 0
local shooting = 0

local ROTATION_PER_FRAME = YAW_AIM_RATE/30
local TARGET_ALT = 143565270/2^16
local Vector = Spring.Utilities.Vector
local max = math.max
local soundTime = 0
local spGetUnitIsStunned = Spring.GetUnitIsStunned
local spGetUnitRulesParam = Spring.GetUnitRulesParam

local satUnitID = false

local aimingDone = false
local isStunned = true

-- Signal definitions
local SIG_AIM = 2
local SIG_DOCK = 4

local function IsDisabled()
	return spGetUnitIsStunned(unitID) or (spGetUnitRulesParam(unitID, "disarmed") == 1) or (spGetUnitRulesParam(unitID, "lowpower") == 1)
end

local function DeferredInitialize()
	while IsDisabled() do
		Sleep(30)
	end
	
	Spin(UpperCoil, z_axis, 10,0.5)
	Spin(LowerCoil, z_axis, 10,0.5)
	
	Move(ShortSpikes,z_axis, 0,1)
	Move(LongSpikes,z_axis, 0,1.5)
	
	local x,y,z = Spring.GetUnitPiecePosDir(unitID,SatelliteMount)
	local dx, _, dz = Spring.GetUnitDirection(unitID)
	if not dx then
		return
	end
	local heading = Vector.Angle(dx, dz)
	
	while not Spring.ValidUnitID(satUnitID) do
		Sleep(30)
		satUnitID = Spring.CreateUnit('supernova_satellite',x,y,z,0,Spring.GetUnitTeam(unitID))
		if satUnitID then
			satelliteCreated = true
			Spring.SetUnitRulesParam(satUnitID,'cannot_damage_unit',unitID)
			Spring.SetUnitRulesParam(satUnitID,'parent_unit_id',unitID)
			Spring.SetUnitRulesParam(satUnitID,'untargetable',1)
			Spring.SetUnitRulesParam(unitID,'has_satellite',satUnitID)
			Spring.SetUnitCollisionVolumeData(satUnitID, 0,0,0, 0,0,0, -1,0,0)
			Hide(LimbA1)
			Hide(LimbA2)
			Hide(LimbB1)
			Hide(LimbB2)
			Hide(LimbC1)
			Hide(LimbC2)
			Hide(LimbD1)
			Hide(LimbD2)
			Hide(Satellite)
			Hide(SatelliteMuzzle)
		end
	end
end

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)

	--Move(ShortSpikes,z_axis, -5)
	--Move(LongSpikes,z_axis, -10)
	local facing = Spring.GetUnitBuildFacing(unitID)
	StartThread(DeferredInitialize)
end

function script.AimWeapon(num, heading, pitch)
	return false
end

function script.QueryWeapon(num)
	return SatelliteMuzzle
end

function script.AimFromWeapon(num)
	return SatelliteMuzzle
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth

	if (severity <= 0.25) then
		Explode(Basis, SFX.NONE)
		return 1 -- corpsetype
	elseif (severity <= 0.5) then
		Explode(Basis, SFX.NONE)
		return 1 -- corpsetype
	else
		Explode(Basis, SFX.SHATTER)
		return 2 -- corpsetype
	end
end

