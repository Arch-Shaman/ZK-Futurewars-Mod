--local output, minoutput, decaytime, decaymult
local base = piece 'Base'
local fin0 = piece 'Fin0'
local fin1 = piece 'Fin1'
local fin2 = piece 'Fin2'
local fin3 = piece 'Fin3'
local fin4 = piece 'Fin4'
local fin5 = piece 'Fin5'
local fin6 = piece 'Fin6'
local fin7 = piece 'Fin7'
local tower = piece 'Tower'

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity < 0.5 then
		Explode(fin0, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin3, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin5, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		return 1
	else
		Explode(fin0, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin2, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin3, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin4, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin5, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin6, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin7, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(tower, SFX.SHATTER)
		Explode(base, SFX.SHATTER)
		return 2
	end
end
