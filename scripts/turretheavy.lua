include "constants.lua"
include "QueryWeaponFixHax.lua"

--pieces
local base = piece "Base"
local shellbase = piece "ShellBase"
local shell_1 = piece "Shell_1"
local shell_2 = piece "Shell_2"

-- guns

local cannonAim = piece "cannonAim"
local cannonbase = piece "CannonBase"
local cannon = piece "Cannon"
local flare1 = piece "flare1"

local heatraybase = piece "HeatrayBase"
local heatray = piece "Heatray"
local flare2 = piece "flare2"
local flare3 = piece "flare3"
local armorValue = UnitDefs[unitDefID].armoredMultiple
local spGetUnitRulesParam 	= Spring.GetUnitRulesParam
local spGetUnitIsStunned = Spring.GetUnitIsStunned
local spSetUnitHealth = Spring.SetUnitHealth

local smokePiece = { shell_1, shell_2, cannonbase, heatray }

local BUNKERED_AUTOHEAL = tonumber (UnitDef.customParams.armored_regen or 20) / 2 -- applied every 0.5s

--variables
local heat = false
local on = false
--signals
local aim = 2
local aim2 = 4
local open = 8
local close = 16
local closeInterrupt = 32

local mainPitch = 0.5
local mainHeading = 0.8
local shellSpeed = 1.2

local position = 0

local tauOn16 = math.tau/16
local tauOn8 = math.tau/8

local spGetUnitHealth = Spring.GetUnitHealth

local function Open()
	Signal(close) --kill the closing animation if it is in process
	SetSignalMask(open) --set the signal to kill the opening animation
	
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end

	-- Open Main Shell
	Move(shell_1, x_axis, 0, shellSpeed * 4)
	Move(shell_2, x_axis, 0, shellSpeed * 4)
	-- Unsquish heatray
	Move(shellbase, y_axis, 0, 3 * 4)
	Move(heatraybase, y_axis, 0, 1.5 * 4)
	
	WaitForMove(shell_1, x_axis)
	WaitForMove(shellbase, y_axis)
	WaitForMove(heatraybase, y_axis)
	GG.SetUnitArmor(unitID, 1.0)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	-- Unstow Guns
	Turn(cannonbase, x_axis, 0, mainPitch * 4)
	Move(heatray,z_axis, 0, 8 * 4)
	
	WaitForTurn(cannonbase, x_axis)
	WaitForMove(heatray, z_axis)
	if spGetUnitRulesParam(unitID, "lowpower") == 1 then
		return
	end

	-- Ready Cannon Head
	Move(cannon, z_axis, 0, 10 * 4)
	WaitForMove(cannon, z_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	on = true
end

local function FinalCloseInterrupt()
	SetSignalMask(closeInterrupt)
	
	while true do
		if spGetUnitRulesParam(unitID, "lowpower") == 1 then
			Move(shell_1,x_axis,  15, 0.000000001)
			Move(shell_2,x_axis, -15, 0.000000001)
			StartThread(Close)
			return
		end
		Sleep(500)
	end
end

--closing animation of the factory
function Close()
	Signal(aim)
	Signal(aim2)
	Signal(closeInterrupt)
	Signal(open) --kill the opening animation if it is in process
	SetSignalMask(close) --set the signal to kill the closing animation
	
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	-- Prepare both guns to be stowed.
	Move(cannon, z_axis, -10, 10 * 4)
	Turn(heatray, x_axis, 0, 2 * 4)
	
	WaitForTurn(heatray, x_axis)
	WaitForMove(cannon, z_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	-- Stow Guns
	Turn(cannonbase, x_axis, 1.57, mainPitch * 4)
	Move(heatray,z_axis, -10, 4 * 4)
	
	WaitForTurn(cannonbase, x_axis)
	WaitForMove(heatray, z_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	-- Squish Heatray area
	Turn(shellbase, y_axis, tauOn8*position, mainHeading/4 * 4)
	Turn(heatraybase, y_axis, tauOn8*position, 1 * 3)
	WaitForTurn(shellbase, y_axis)
	WaitForTurn(heatraybase, y_axis)
	while spGetUnitRulesParam(unitID, "lowpower") == 1 do
		Sleep(500)
	end
	
	Move(shellbase, y_axis, -12.6, 3 * 4)
	Move(heatraybase, y_axis, -6.3, 1.5 * 4)
	-- Close Main Shell
	Move(shell_1,x_axis,  5, shellSpeed * 4)
	Move(shell_2,x_axis, -5, shellSpeed * 4)
	
	WaitForMove(shell_1,x_axis)
	WaitForMove(shell_2,x_axis)
	WaitForMove(shellbase,y_axis)
	WaitForMove(heatraybase,y_axis)
	
	StartThread(FinalCloseInterrupt)
	
	Signal(closeInterrupt)
	
	-- Set Armour
	GG.SetUnitArmor(unitID, armorValue)
	
	while true do
		local stunned_or_inbuild = spGetUnitIsStunned(unitID) or (spGetUnitRulesParam(unitID, "disarmed") == 1)
		if not stunned_or_inbuild then
			local hp = spGetUnitHealth(unitID)
			local slowMult = (spGetUnitRulesParam(unitID,"baseSpeedMult") or 1)
			local newHp = hp + slowMult*BUNKERED_AUTOHEAL
			spSetUnitHealth(unitID, newHp)
		end
		Sleep(500)
	end
end

function OnArmorStateChanged(state)
	local armored = state == 1
	if armored and on then
		StartThread(Close)
		on = false
	elseif not armored and not on then
		StartThread(Open)
		on = true
	end
end

function script.Create()
	on = true
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	SetupQueryWeaponFixHax(cannonAim, flare1)
	Hide(flare1)
end

local aimFromSet = {cannonAim, heatraybase, heatraybase, base}

function script.AimFromWeapon(num)
	return aimFromSet[num]
end

function script.AimWeapon(num, heading, pitch)
	if (not on) or (spGetUnitRulesParam(unitID, "lowpower") == 1) then
		return false
	end
	if num == 1 then
		Signal(aim)
		SetSignalMask(aim)

		position = math.floor((heading + tauOn16)/tauOn8)%8
		
		Turn(shellbase, y_axis, heading, mainHeading)
		Turn(cannonbase, x_axis, -pitch, mainPitch)
		WaitForTurn (shellbase, y_axis)
		WaitForTurn (cannonbase, x_axis)
		
		StartThread(AimingDone)
		
		return (spGetUnitRulesParam(unitID, "lowpower") == 0)	--checks for sufficient energy in grid
	elseif num == 2 or num == 3 then
		Signal(aim2)
		SetSignalMask(aim2)
		
		Turn(heatraybase, y_axis, heading, 3)
		Turn(heatray, x_axis, -pitch, 2)
		
		WaitForTurn (heatraybase, y_axis)
		WaitForTurn (heatray, x_axis)
		
		return (spGetUnitRulesParam(unitID, "lowpower") == 0)
	end
end

function script.QueryWeapon(num)
	if num == 1 then
		return GetQueryPiece()
	elseif num == 2 then
		return flare2
	elseif num == 3 then
		return flare3
	else
		return base
	end
end

local function RecoilThread()
	Move(cannon, z_axis, -24, 50)
	Sleep(400)
	Move(cannon, z_axis, 0, 3.68)
end

function script.FireWeapon(num)
	if num == 1 then
		EmitSfx(flare1, 1024)
		StartThread(RecoilThread)
	end
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth

	if (severity <= .25) then
		return 1 -- corpsetype
	elseif (severity <= .5) then
		return 1 -- corpsetype
	else
		return 2 -- corpsetype
	end
end