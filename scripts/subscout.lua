local body = piece "body"
local tail = piece "tail"
local enginel = piece "enginel"
local enginer = piece "enginer"
local wingl = piece "wingl"
local wingr = piece "wingr"

function Detonate() -- Giving an order causes recursion.
	GG.QueueUnitDescruction(unitID)
end

function script.AimWeapon(num)
	if num == 2 then
		Detonate()
		return false
	end
	return true
end

local function FireThread()
	Sleep(33)
	GG.PuppyHandler_Shot(unitID)
end

function script.FireWeapon()
	StartThread(FireThread) -- Delay puppy hiding until after we fire the weapon
end

function script.AimFromWeapon()
	return body
end

function script.QueryWeapon()
	return body
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	local brutal = (severity > 0.5)
	local effect = SFX.FALL + (brutal and (SFX.SMOKE + SFX.FIRE) or 0)
	local explodables = {tail, enginel, enginer, wingl, wingr}
	for i = 1, #explodables do
		if math.random() < severity then
			Explode (explodables[i], effect)
		end
	end

	if not brutal then
		return 1
	else
		Explode (body, SFX.SHATTER)
		return 2
	end
end
