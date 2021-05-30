-- TODO: CACHE INCLUDE FILE
local CMD_JUMP = Spring.Utilities.CMD.JUMP
local GiveClampedOrderToUnit = Spring.Utilities.GiveClampedOrderToUnit
local jumpRange = tonumber(UnitDefs[unitDefID].customParams.jump_range)
local jumpRangeBonus = 1
local retreattype = UnitDefs[unitDefID].customParams.jumpretreattype or "always"

local retreating = false

local function RetreatThread(hx, hy, hz)
	--Spring.Echo("RetreatThread")
	local reload, disarmed, ux, uy, uz, moveDistance, disScale, cx, cy, cz
	local realrange = jumpRange * jumpRangeBonus -- this can't be cached for some reason.
	while retreating do
		reload = Spring.GetUnitRulesParam(unitID, "jumpReload") or 1
		disarmed = (Spring.GetUnitRulesParam(unitID, "disarmed") or 0) == 1
		--Spring.Echo("Reload: " .. tostring(reload) .. " / 1\nDisarmed: " .. tostring(disarmed))
		if reload >= 1 and not disarmed then
			ux, uy, uz = Spring.GetUnitPosition(unitID)
			moveDistance = math.sqrt(((ux - hx) * (ux - hx)) + ((uz - hz) * (uz - hz)))
			--Spring.Echo("MoveDistance: " .. moveDistance)
			if moveDistance < 100 then -- don't jump around in haven or waste it near it.
				--Spring.Echo("Stopping JumpRetreat: Low Distance.")
				retreating = false -- stop watching reload states.
			else
				disScale = realrange/moveDistance*0.95
				cx, cy, cz = ux + disScale*(hx - ux), hy, uz + disScale*(hz - uz)
				GiveClampedOrderToUnit(unitID, CMD.INSERT, { 0, CMD_JUMP, CMD.OPT_INTERNAL, cx, cy, cz}, CMD.OPT_ALT)
				if retreattype == "once" then
					--Spring.Echo("Stopping JumpRetreat: One Jump only.")
					retreating = false
				end
			end
		else
			Sleep(33)
		end
	end
end

function RetreatFunction(hx, hy, hz)
	if retreattype == "none" then
		return
	end
	if Spring.GetUnitRulesParam(unitID, "comm_jumprange_bonus") then -- if it's a custom comm with an upgrade..
		jumpRangeBonus = 1 + (Spring.GetUnitRulesParam(unitID, "comm_jumprange_bonus"))
	end
	if not retreating then
		StartThread(RetreatThread, hx, hy, hz)
		retreating = true
	end
end

function StopRetreatFunction()
	retreating = false
end
