include "constants.lua"

local body = piece 'body'
local barrel = piece 'barrel'
local flare = piece 'flare'
local wings = piece 'wings'
local fan = piece 'fan'
local Rwingengine = piece 'Rwingengine'
local Lwingengine = piece 'Lwingengine'

local smokePiece = {body}

local spGetUnitVelocity = Spring.GetUnitVelocity

local function TiltWings()
	while true do
		if attacking then
			Turn(wings, x_axis, 0, math.rad(75))
			Sleep(250)
		else
			local vx,_,vz = spGetUnitVelocity(unitID)
			local speed = vx*vx + vz*vz
			Turn(wings, x_axis, math.rad(4.4 * speed), math.rad(75))
			Sleep(250)
		end
	end
end

function script.Create()
    StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(TiltWings)
	Spin(fan, y_axis, math.rad(500))
end

function script.QueryWeapon(num)
    return flare
end

function script.AimFromWeapon(num)
    return body
end

function script.AimWeapon(num, heading, pitch)
	return true
end

function script.FireWeapon()
    Sleep(1)
    Move(barrel, z_axis, -5, 1000)
	Sleep(100)
	Move(barrel, z_axis, 0, 10)
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
