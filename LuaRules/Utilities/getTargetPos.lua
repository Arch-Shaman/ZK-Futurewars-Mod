-- Turns the result of a Spring.GetProjectileTarget() call into X, Y, Z coordinates
-- I don't know why this isn't shared already

local TARGET_GROUND     = string.byte('g')
local TARGET_UNIT       = string.byte('u')
local TARGET_FEATURE    = string.byte('f')
local TARGET_PROJECTILE = string.byte('p')

local spGetUnitPosition   = Spring.GetUnitPosition
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetProjectilePosition = Spring.GetProjectilePosition

Spring.Utilities = Spring.Utilities or {}

function Spring.Utilities.GetTargetPos(targetType, targetParam)
	if targetType == TARGET_UNIT then
		return spGetUnitPosition(targetParam)
	elseif targetType == TARGET_FEATURE then
		return spGetFeaturePosition(targetParam)
	elseif targetType == TARGET_GROUND then
		return targetParam[1], targetParam[2], targetParam[3]
	elseif targetType == TARGET_PROJECTILE then
		return spGetProjectilePosition(targetParam)
	else
		Spring.Log("GetTargetPos.lua", LOG.ERROR, "Bad target type. Got: " .. tostring(targetType))
	end
end
