include "constants.lua"
include "nanoaim.h.lua"

--pieces
local body = piece "base"
local aim = piece "post"
local emitnano = piece "nano"

--local vars
local smokePiece = { aim, body}
local nanoPieces = { emitnano }

local nanoTurnSpeedHori = 0.5 * math.pi
local nanoTurnSpeedVert = 0.3 * math.pi

function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(GG.NanoAim.UpdateNanoDirectionThread, unitID, nanoPieces, 1000, nanoTurnSpeedHori, nanoTurnSpeedVert)
	Spring.SetUnitNanoPieces(unitID, {emitnano})
end

function script.StartBuilding()
	GG.NanoAim.UpdateNanoDirection(unitID, nanoPieces, nanoTurnSpeedHori, nanoTurnSpeedVert)
	Spring.SetUnitCOBValue(unitID, COB.INBUILDSTANCE, 1);
end


function script.StopBuilding()
	Spring.SetUnitCOBValue(unitID, COB.INBUILDSTANCE, 0);
end


function script.QueryNanoPiece()
	--// send to LUPS
	GG.LUPS.QueryNanoPiece(unitID,unitDefID,Spring.GetUnitTeam(unitID),emitnano)

	return emitnano
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth

	if severity < 0.25 then
		return 1
	elseif severity < 0.50 then
		Explode (aim, SFX.FALL)
		return 1
	elseif severity < 0.75 then
		Explode (aim, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		return 2
	else
		Explode (body, SFX.SHATTER)
		Explode (aim, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE_ON_HIT)
		return 2
	end
end
