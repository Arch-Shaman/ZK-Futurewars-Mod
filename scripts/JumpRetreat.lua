-- TODO: CACHE INCLUDE FILE
local CMD_JUMP = Spring.Utilities.CMD.JUMP
local GiveClampedOrderToUnit = Spring.Utilities.GiveClampedOrderToUnit
local jumpRange = tonumber(UnitDefs[unitDefID].customParams.jump_range)
local jumpRangeBonus = 1
local retreattype = UnitDefs[unitDefID].customParams.jumpretreattype or "always"

local retreating = false

local function RetreatThread(hx, hy, hz)
	--Spring.Echo("RetreatThread")
	local reload, disarmed, ux, uy, uz, moveDistance, disScale, cx, cy, cz, isstunned
	local autoJumpEnabled = false
	local realrange = jumpRange * jumpRangeBonus -- this can't be cached for some reason.
	while retreating do
		autoJumpEnabled = GG.GetAutoJumpState(unitID)
		reload = Spring.GetUnitRulesParam(unitID, "jumpReload") or 1
		disarmed = (Spring.GetUnitRulesParam(unitID, "disarmed") or 0) == 1
		isstunned = Spring.GetUnitIsStunned(unitID)
		--Spring.Echo("Reload: " .. tostring(reload) .. " / 1\nDisarmed: " .. tostring(disarmed))
		if autoJumpEnabled and reload >= 1 and not disarmed and not isstunned then
			ux, uy, uz = Spring.GetUnitPosition(unitID)
			moveDistance = math.sqrt(((ux - hx) * (ux - hx)) + ((uz - hz) * (uz - hz)))
			--Spring.Echo("MoveDistance: " .. moveDistance)
			if moveDistance >= 200 and moveDistance < realrange then -- jump to finish reteating.
				GiveClampedOrderToUnit(unitID, CMD.INSERT, { 0, CMD_JUMP, CMD.OPT_INTERNAL, hx, hy, hz}, CMD.OPT_ALT)
				retreating = false
			elseif moveDistance < 200 then -- don't jump around in haven or waste it near it.
				--Spring.Echo("Stopping JumpRetreat: Low Distance.")
				retreating = false -- stop watching reload states.
			else
				disScale = realrange/moveDistance*0.95
				cx, cy, cz = ux + disScale*(hx - ux), hy, uz + disScale*(hz - uz)
				cy = Spring.GetGroundHeight(cx, cz)
				if cy >= 0 then
					GiveClampedOrderToUnit(unitID, CMD.INSERT, { 0, CMD_JUMP, CMD.OPT_INTERNAL, cx, cy, cz}, CMD.OPT_ALT)
					if retreattype == "once" then
						--Spring.Echo("Stopping JumpRetreat: One Jump only.")
						retreating = false
					end
				else
					Sleep(100)
				end
			end
		end
		Sleep(66)
	end
end

function RetreatFunction(hx, hy, hz)
	--Spring.Echo("Wanted retreat!")
	if retreattype == "none" then
		return
	end
	if Spring.GetUnitRulesParam(unitID, "comm_jumprange_bonus") then -- if it's a custom comm with an upgrade..
		jumpRangeBonus = 1 + Spring.GetUnitRulesParam(unitID, "comm_jumprange_bonus")
	end
	if not retreating then
		retreating = true
		StartThread(RetreatThread, hx, hy, hz)
	end
end

function StopRetreatFunction()
	retreating = false
end
