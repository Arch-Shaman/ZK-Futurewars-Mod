include "constants.lua"
include "fakeUpright.lua"
include "bombers.lua"
include "fixedwingTakeOff.lua"

local base, Lwing, LwingTip, Rwing, RwingTip, jet1, jet2,xp,zp,preDrop, drop, LBSpike, LFSpike,RBSpike, RFSpike = piece("Base", "LWing", "LWingTip", "RWing", "RWingTip", "Jet1", "Jet2","x","z","PreDrop", "Drop", "LBSpike", "LFSpike","RBSpike", "RFSpike")
local smokePiece = {base, jet1, jet2}

local doingRun = false
local preDropMoved = false
local sound_index = 0

local SIG_TAKEOFF = 1
local takeoffHeight = UnitDefNames["bomberdisarm"].wantedHeight

local function DoDrop()
	local noammo = Spring.GetUnitRulesParam(unitID, "noammo") or 0
	if noammo == 0 then
		for i = 1, 15 do
			EmitSfx(drop, GG.Script.FIRE_W1)
			Sleep(33)
		end
	end
end

local function StartDeathAnimation()
	local params = SFX.SMOKE + SFX.FIRE + SFX.EXPLODE + SFX.FALL
	if math.random() > 0.5 then -- start on left side.
		Explode(LwingTip, params)
		Hide(LwingTip)
		Sleep(133)
		Explode(RwingTip, params)
		Hide(RwingTip)
	else
		Explode(RwingTip, params)
		Hide(RwingTip)
		Sleep(133)
		Explode(LwingTip, params)
		Hide(LwingTip)
	end
	StartThread(DoDrop)
	Sleep(math.ceil(math.random() * 300))
	Explode(LWing, params)
	Sleep(100)
	Explode(Rwing, params)
	Sleep(100)
	if math.random() > 0.5 then
		Explode(LBSpike, params)
		Explode(LFSpike, params)
		Hide(LBSpike)
		Hide(LFSpike)
		Sleep(100)
		Explode(RBSpike, params)
		Explode(RFSpike, params)
		Hide(RBSpike)
		Hide(RFSpike)
	else
		Explode(RBSpike, params)
		Explode(RFSpike, params)
		Hide(RBSpike)
		Hide(RFSpike)
		Sleep(100)
		Explode(LBSpike, params)
		Explode(LFSpike, params)
		Hide(LBSpike)
		Hide(LFSpike)
		Explode(LBSpike, params)
		Explode(LFSpike, params)
		Hide(LBSpike)
		Hide(LFSpike)
	end
end

function OnStartingCrash()
	StartThread(StartDeathAnimation)
end

function script.Create()
	SetInitialBomberSettings()
	Hide(preDrop)
	Hide(drop)
	
	GG.FakeUpright.FakeUprightInit(xp, zp, drop)
	Turn(Lwing, z_axis, math.rad(90))
	Turn(Rwing, z_axis, math.rad(-90))
	Turn(LwingTip, z_axis, math.rad(-165))
	Turn(RwingTip, z_axis, math.rad(165))
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

function script.Activate()
	Turn(Lwing, z_axis, math.rad(90), 2)
	Turn(Rwing, z_axis, math.rad(-90), 2)
	Turn(LwingTip, z_axis, math.rad(-165), 2) --160
	Turn(RwingTip, z_axis, math.rad(165), 2) -- -160
end

function script.Deactivate()
	Turn(Lwing, z_axis, math.rad(10), 2)
	Turn(Rwing, z_axis, math.rad(-10), 2)
	Turn(LwingTip, z_axis, math.rad(-30), 2) -- -30
	Turn(RwingTip, z_axis, math.rad(30), 2) --30
	StartThread(GG.TakeOffFuncs.TakeOffThread, takeoffHeight, SIG_TAKEOFF)
end

function script.FireWeapon(checkHeight)
	if RearmBlockShot() then
		return
	end
	SetUnarmedAI()
	Sleep(300)
	Reload()
end

function StartRun()
	script.FireWeapon(true)
end

function script.QueryWeapon()
	return drop
end

function script.AimFromWeapon()
	return drop
end

function script.AimWeapon(num, heading, pitch)
	if (GetUnitValue(GG.Script.CRASHING) == 1) or num ~= 1 then
		return false
	end
	return true
end

function script.BlockShot(num)
	local ammo = Spring.GetUnitRulesParam(unitID, "noammo") or 0
	return (GetUnitValue(GG.Script.CRASHING) == 1) or num ~= 1 or ammo ~= 0
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity < 0.5 or (Spring.GetUnitMoveTypeData(unitID).aircraftState == "crashing") then
		Explode(base, SFX.NONE)
		Explode(jet1, SFX.SMOKE)
		Explode(jet2, SFX.SMOKE)
		Explode(Lwing, SFX.NONE)
		Explode(Rwing, SFX.NONE)
		return 1
	elseif severity < 0.75 then
		Explode(base, SFX.SHATTER)
		Explode(jet1, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(jet2, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(Lwing, SFX.FALL + SFX.SMOKE)
		Explode(Rwing, SFX.FALL + SFX.SMOKE)
		return 2
	else
		Explode(base, SFX.SHATTER)
		Explode(jet1, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(jet2, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(Lwing, SFX.SMOKE + SFX.EXPLODE)
		Explode(Rwing, SFX.SMOKE + SFX.EXPLODE)
		Explode(LwingTip, SFX.SMOKE + SFX.EXPLODE)
		Explode(RwingTip, SFX.SMOKE + SFX.EXPLODE)
		return 2
	end
end
