local trackedMissiles = include("LuaRules/Configs/tracked_missiles.lua")
local cruiseMissileCache = {} -- Most cruise missiles have the same ascent and descent timers, 
local cauToRad = (2 * math.pi) / 65536

-- Fundamental assumption: All rise times are going to be the same since these are all mostly surface launch missiles.
for k, v in pairs(trackedMissiles) do
	local weaponDef = WeaponDefs[k]
	local cruiseAlt = tonumber(weaponDef.customParams.cruisealt)
	local maxSpeed = tonumber(weaponDef.customParams.weaponvelocity) / 30
	local intialVelocity = tonumber(weaponDef.customParams.startvelocity) / 30 -- elmo/sec -> elmo/frame
	local accel = weaponDef.weaponAcceleration -- It's already elmo/frame. Don't worry about math.
	if cruiseAlt then --
		Spring.Echo("Cruise missile: " .. k .. ": " .. weaponDef.name)
		Spring.Echo("Turn rate: " .. weaponDef.turnRate)
		Spring.Echo("Acceleration: " .. weaponDef.weaponAcceleration)
		local tab = {}
		local vy = intialVelocity -- elmo/sec -> elmo/frame
		local currentAlt = 0
		local predictedFrame = 0
		local isStillAccelerating = true
		repeat
			currentAlt = currentAlt + vy
			if vy <= maxSpeed then
				vy = vy + accel
				if vy > maxSpeed then 
					vy = maxSpeed 
					isStillAccelerating = false
				end
			elseif isStillAccelerating then
				isStillAccelerating = false
			end
			predictedFrame = predictedFrame + 1
		until predictedFrame >= 6000 or currentAlt >= cruiseAlt
		tab.riseTime = predictedFrame
		Spring.Echo(k .. ": Predicted Rise Time: " .. predictedFrame .. "f") 
		local turnRate = weaponDef.turnRate -- is in rad/frame
		local o = turnRate
		local turnTime = math.ceil(math.pi / (2 * o))
		Spring.Echo(k .. ": Predicted time to begin cruise: " .. turnTime .. "f")
		tab.turnTime = turnTime
		local dist
		if isStillAccelerating then
			accelTime = math.max(0, (maxSpeed - vy) / accel)
			accelTime = math.min(accelTime, turnTime)
			local accelAngle = o * accelTime
			local remainingTime = turnTime - accelTime
			local accelDistance = vy * (1 - math.cos(math.pi / 2)) / o + accel * (accelTime / o - math.sin(accelAngle) / (o * o))
			dist = maxSpeed * (math.cos(accelAngle) - math.cos(math.pi / 2)) / o
			dist = dist + accelDistance
			speedAfterTurn = vy + (turnTime * accel)
			if speedAfterTurn < maxSpeed then
				tab.cruiseSpeed = speedAfterTurn
			else
				tab.cruiseSpeed = maxSpeed
			end
		else
			dist = (maxSpeed / o) * (1 - math.cos(math.pi / 2))
			tab.cruiseSpeed = maxSpeed
		end
		if tab.cruiseSpeed ~= maxSpeed then
			local sprintTime = math.ceil((maxSpeed - tab.cruiseSpeed) / accel)
			local sprintDist = tab.cruiseSpeed * sprintTime + 0.5 * accel * sprintTime * sprintTime
			tab.sprintTime = sprintTime
			tab.sprintDist = sprintDist
		else
			tab.sprintTime = 0
			tab.sprintDist = 0
		end
		tab.turnTime = turnTime
		tab.distanceDuringTurn = dist
		tab.descentToImpact = turnTime + (cruiseAlt / maxSpeed)
		Spring.Echo(k .. ": Turn time: " .. tab.turnTime .. "f")
		Spring.Echo(k .. ": Turn Dist: " .. dist .. " elmos")
		Spring.Echo(k .. ": Impact time: " .. tab.descentToImpact .. "f")
		cruiseMissileCache[k] = tab
	end
end

return cruiseMissileCache
