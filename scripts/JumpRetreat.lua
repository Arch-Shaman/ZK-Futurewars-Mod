-- TODO: CACHE INCLUDE FILE
local CMD_JUMP = Spring.Utilities.CMD.JUMP
local GiveClampedOrderToUnit = Spring.Utilities.GiveClampedOrderToUnit
local jumpRange = tonumber(UnitDefs[unitDefID].customParams.jump_range) * (Spring.GetUnitRulesParam(unitID, "comm_jumprange_bonus") or 1)
local retreattype = UnitDefs[unitDefID].customParams.jumpretreattype or "always"

local retreating = false

local function RetreatThread(hx, hy, hz)
	local reload, disarmed, ux, uy, uz, moveDistance, disScale, cx, cy, cz
	while retreating do
		reload = Spring.GetUnitRulesParam(unitID, "jumpReload") or 1
		disarmed = (Spring.GetUnitRulesParam(unitID, "disarmed") or 0) == 1
		if reload >= 1 and not disarmed then
			ux, uy, uz = Spring.GetUnitPosition(unitID)
			moveDistance = math.sqrt(((ux - hx) * (ux - hx)) + ((uz - hz) * (uz - hz)))
			if moveDistance < jumpRange / 2 and moveDistance < 300 then -- don't jump around in haven or waste it near it.
				retreating = false -- stop watching reload states.
			else
				disScale = jumpRange/moveDistance*0.95
				cx, cy, cz = ux + disScale*(hx - ux), hy, uz + disScale*(hz - uz)
				GiveClampedOrderToUnit(unitID, CMD.INSERT, { 0, CMD_JUMP, CMD.OPT_INTERNAL, cx, cy, cz}, CMD.OPT_ALT)
				if retreattype == "once" then
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
	if not retreating then
		StartThread(RetreatThread, hx, hy, hz)
		retreating = true
	end
end

function StopRetreatFunction()
	retreating = false
end
