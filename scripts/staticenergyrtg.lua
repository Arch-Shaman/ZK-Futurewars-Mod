local output, minoutput, decaytime, decaymult
local base = Piece 'Base'
local fin0 = Piece 'Fin0'
local fin1 = Piece 'Fin1'
local fin2 = Piece 'Fin2'
local fin3 = Piece 'Fin3'
local fin4 = Piece 'Fin4'
local fin5 = Piece 'Fin5'
local fin6 = Piece 'Fin6'
local fin7 = Piece 'Fin7'
local tower = Piece 'Tower'

do -- this is to confine UnitDefID to this area.
	local UnitDefID = Spring.GetUnitDefID(unitID) -- so we don't have to set it to nil or have a useless variable floating about.
	output = UnitDefs[unitDefID].energyMake
	minoutput = UnitDefs[unitDefID].customParams["decay_minoutput"]
	decaytime = UnitDefs[unitDefID].customParams["decay_time"] * 1000
	decaymult = 1 - UnitDefs[unitDefID].customParams["decay_rate"]
end

local function DecayThread()
    while output ~= minoutput do
        Sleep(decaytime)
        output = output * decaymult
        Spring.SetUnitResourcing(unitID, "e", output)
    end
end

function script.Create()
    StartThread(DecayThread)
end

function script.Killed(recentDamage, maxHealth)
    local severity = recentDamage/maxHealth
    if severity < 0.5 then
        Explode(fin0, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin3, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin5, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
        return 1
    else
		Explode(fin0, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin1, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin2, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin3, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin4, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin5, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin6, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(fin7, SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		Explode(tower, SFX.SHATTER)
		Explode(base, SFX.SHATTER)
        return 2
    end
end
