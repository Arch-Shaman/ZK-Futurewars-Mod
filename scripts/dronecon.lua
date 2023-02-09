include "constants.lua"

local body = piece 'body'
local wing1 = piece 'wing1'
local wing2 = piece 'wing2'
local wing3 = piece 'wing3'
local wing4 = piece 'wing4'
local exhaust1 = piece 'exhaust1'
local exhaust2 = piece 'exhaust2'
local exhaust3 = piece 'exhaust3'
local exhaust4 = piece 'exhaust4'
local nano = piece 'nano'

local smokePiece = {body}

local spGetUnitVelocity = Spring.GetUnitVelocity

local function TiltWings()
	while true do
	    local vx,_,vz = spGetUnitVelocity(unitID)
	    local speed = vx*vx + vz*vz
	    Turn(wing1, z_axis, math.rad(-2 * speed), math.rad(100))
	    Turn(wing2, z_axis, math.rad(2 * speed), math.rad(100))
		Turn(wing3, z_axis, math.rad(2 * speed), math.rad(100))
		Turn(wing4, z_axis, math.rad(-2 * speed), math.rad(100))
	    Sleep(250)
	end
end

function script.Create()
    StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(TiltWings)
end

function script.QueryNanoPiece()
    return nano
end

function script.StartBuilding(heading, pitch)
    SetUnitValue(COB.INBUILDSTANCE, 1)
end

function script.StopBuilding()
    SetUnitValue(COB.INBUILDSTANCE, 0)
end

function script.Killed(recentDamage, maxHealth)
	local severity = (recentDamage/maxHealth)
	if severity < .5 then
		Explode(body, SFX.NONE)
	elseif severity < 1 then
		Explode(body, SFX.NONE)
	else
		Explode(body, SFX.SHATTER)
	end
end
