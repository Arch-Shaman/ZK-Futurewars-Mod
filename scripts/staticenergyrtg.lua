-- insert piece stuff here--
local UnitDefID = Spring.GetUnitDefID(unitID)

local output = UnitDefs[unitDefID].energyMake
local minoutput = UnitDefs[unitDefID].customParams["decay_minoutput"]
local decaytime = UnitDefs[unitDefID].customParams["decay_time"] * 1000
local decaymult = 1 - UnitDefs[unitDefID].customParams["decay_rate"]

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
        -- stuff explodes **slightly** --
        return 1
    else
        -- stuff explodes very badly. leaves debris --
        return 2
    end
end
