include "constants.lua"
include "nanoaim.h.lua"
include "plates.lua"

--pieces
local body = piece "body"
local aim = piece "aim"
local emitnano = piece "emitnano"

--local vars
local smokePiece = { piece "aim", piece "body" }
local nanoPieces = { piece "aim" }

local nanoTurnSpeedHori = 0.5 * math.pi
local nanoTurnSpeedVert = 0.3 * math.pi
local enabled = false

local function CheckStateThread()
	local noParent
	while true do
		noParent = (Spring.GetUnitRulesParam(unitID, "nofactory") or 0) == 1
		if enabled and noParent then
			SetUnitValue(COB.INBUILDSTANCE, 0)
			enabled = false
		elseif not enabled and not noParent then
			SetUnitValue(COB.INBUILDSTANCE, 1)
			enabled = true
		end
		Sleep(100)
	end
end

function script.Create()
	StartThread(CheckStateThread)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	StartThread(GG.NanoAim.UpdateNanoDirection, unitID, nanoPieces, 1000, nanoTurnSpeedHori, nanoTurnSpeedVert)
	Spring.SetUnitNanoPieces(unitID, {emitnano})
end

function script.StartBuilding()
	GG.NanoAim.UpdateNanoDirection(unitID, nanoPieces, nanoTurnSpeedHori, nanoTurnSpeedVert)
	Spring.SetUnitCOBValue(unitID, COB.INBUILDSTANCE, 1);
end


function script.StopBuilding()
	Spring.SetUnitCOBValue(unitID, COB.INBUILDSTANCE, 0);
end

function script.QueryWeapon()
	return aim
end

function script.AimWeapon()
	return false
end

function script.FireWeapon()
	
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
