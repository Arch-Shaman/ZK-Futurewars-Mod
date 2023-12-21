local body = piece 'body' 
local head = piece 'head' 
local tail = piece 'tail' 
local lthigh = piece 'lthigh' 
local lknee = piece 'lknee' 
local lshin = piece 'lshin' 
local lfoot = piece 'lfoot' 
local rthigh = piece 'rthigh' 
local rknee = piece 'rknee' 
local rshin = piece 'rshin' 
local rfoot = piece 'rfoot' 
local rsack = piece 'rsack' 
local lsack = piece 'lsack' 

local rad = math.rad
local bMoving, restore_delay, bDigging

-- Signal definitions
local SIG_RESTORE = 2
local SIG_STATE = 4

include "constants.lua"

local function lua_ReplaceMe() return 0 end
local function lua_Surface() return 0 end


local function activatescr()
	bDigging = true
 
	Move(body, y_axis, -30.0)
	Turn(body, x_axis, rad(-45))
 
	Show(body)
	Show(head)
	Show(tail)
	Show(lthigh)
	Show(lknee)
	Show(lshin)
	Show(lfoot)
	Show(rthigh)
	Show(rknee)
	Show(rshin)
	Show(rfoot)
	Show(rsack)
	Show(lsack)
		
	if not bMoving then 
		Turn(body, y_axis, rad(180))
		Turn(body, y_axis, 0, rad(150))
	end
     	
	Move(body, y_axis, 0, 8)
	Turn(body, x_axis, 0, rad(10))
	WaitForMove(body, y_axis)

	bDigging = false
	
end

local function digdig()
	while true do
		lua_Surface()
		Sleep(500)
	end
end

local function deactivatescr()
	bDigging = true
	
	--StartThread(digdig)
	
	if not bMoving then 
		Turn(body, y_axis, rad(180), rad(150))
	end
			
	Turn(body, x_axis, rad(45), rad(30))	
	Move(body, y_axis, -30, 6)

	WaitForMove(body, y_axis)
	Turn(body, y_axis, 0)
	bDigging = false		

end

local function Go()
	Signal(SIG_STATE)
	SetSignalMask(SIG_STATE)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1/3)
	GG.UpdateUnitAttributes(unitID)
	 activatescr()
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	GG.UpdateUnitAttributes(unitID)
end

local function Stop()
	Signal(SIG_STATE)
	SetSignalMask(SIG_STATE)
	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1)
	GG.UpdateUnitAttributes(unitID)
	deactivatescr()
	
	lua_Surface()
	lua_ReplaceMe()
end

function script.Activate()
	StartThread(Go)
end

function script.Deactivate()
	StartThread(Stop)
end

local function walk()
	Turn(lthigh, x_axis, rad(70), rad(57))
	Turn(lknee, x_axis, rad(-40), rad(67))
	Turn(lshin, x_axis, rad(20), rad(67))
	Turn(lfoot, x_axis, rad(-50), rad(125))
	
	Turn(rthigh, x_axis, rad(-20), rad(105))
	Turn(rknee, x_axis, rad(-60), rad(105))
	Turn(rshin, x_axis, rad(50), rad(105))
	Turn(rfoot, x_axis, rad(30), rad(105))
	
	Turn(body, z_axis, rad(-5), rad(10))
	Turn(lthigh, z_axis, rad(5), rad(10))
	Turn(rthigh, z_axis, rad(5), rad(10))
	--Move(body, y_axis, 0.7, 8000)			
	Turn(tail, y_axis, rad(10), rad(20))
	Turn(head, x_axis, rad(-10), rad(10))
	Turn(tail, x_axis, rad(10), rad(10))
	WaitForTurn(lthigh, x_axis)
	
	Turn(lthigh, x_axis, rad(-10), rad(80))
	Turn(lknee, x_axis, rad(15), rad(67))
	Turn(lshin, x_axis, rad(-60), rad(125))
	Turn(lfoot, x_axis, rad(30), rad(67))
	
	Turn(rthigh, x_axis, rad(40), rad(67))
	Turn(rknee, x_axis, rad(-35), rad(67))
	Turn(rshin, x_axis, rad(-40), rad(67))
	Turn(rfoot, x_axis, rad(35), rad(67))
	
	--Move(body, y_axis, 0, 8000)
	Turn(head, x_axis, rad(10), rad(10))
	Turn(tail, x_axis, rad(-10), rad(10))
	WaitForTurn(lshin, x_axis)
	
	Turn(rthigh, x_axis, rad(70), rad(57))
	Turn(rknee, x_axis, rad(-40), rad(67))
	Turn(rshin, x_axis, rad(20), rad(67))
	Turn(rfoot, x_axis, rad(-50), rad(105))
	
	Turn(lthigh, x_axis, rad(-20), rad(105))
	Turn(lknee, x_axis, rad(-60), rad(105))
	Turn(lshin, x_axis, rad(50), rad(105))
	Turn(lfoot, x_axis, rad(30), rad(105))
	
	Turn(tail, y_axis, rad(-10), rad(20))
	Turn(body, z_axis, rad(5), rad(10))
	Turn(lthigh, z_axis, rad(-5), rad(10))
	Turn(rthigh, z_axis, rad(-5), rad(10))
	--Move(body, y_axis, 0.7, 8000)
	Turn(head, x_axis, rad(-10), rad(10))
	Turn(tail, x_axis, rad(10), rad(10))
	WaitForTurn(rthigh, x_axis)
	
	Turn(rthigh, x_axis, rad(-10), rad(80))
	Turn(rknee, x_axis, rad(15), rad(67))
	Turn(rshin, x_axis, rad(-60), rad(125))
	Turn(rfoot, x_axis, rad(30), rad(67))
	
	Turn(lthigh, x_axis, rad(40), rad(67))
	Turn(lknee, x_axis, rad(-35), rad(67))
	Turn(lshin, x_axis, rad(-40), rad(67))
	Turn(lfoot, x_axis, rad(35), rad(67))
	
	
	--Move(body, y_axis, 0, 8000)
	Turn(head, x_axis, rad(10), rad(10))
	Turn(tail, x_axis, rad(-10), rad(10))
	WaitForTurn(rshin, x_axis)
end
local function stopwalk()
	Turn(lfoot, x_axis, 0, rad(100))
	Turn(rfoot, x_axis, 0, rad(100))
	Turn(rthigh, x_axis, 0, rad(100))
	Turn(lthigh, x_axis, 0, rad(100))
	Turn(lshin, x_axis, 0, rad(100))
	Turn(rshin, x_axis, 0, rad(100))
	Turn(lfoot, y_axis, 0, rad(100))
	Turn(rfoot, y_axis, 0, rad(100))
	Turn(rthigh, y_axis, 0, rad(100))
	Turn(lthigh, y_axis, 0, rad(100))
	Turn(lshin, y_axis, 0, rad(100))
	Turn(rshin, y_axis, 0, rad(100))
end

local function MotionControl(moving, justmoved, digging)
	justmoved = true
	while true do
		moving = bMoving
		digging = bDigging
		if moving and not digging then
			walk()
			justmoved = true
		end
		if not moving and not digging and justmoved then
			 stopwalk()
			justmoved = false
		end
		Sleep(100)
	end
end

function script.StartMoving()
	bMoving = true
	--StartThread(walk)
end

function script.StopMoving()
	bMoving = false
	stopwalk()
end

function script.Create()
	EmitSfx(body, 1024+2)
	
	Hide(body)
	Hide(head)
	Hide(tail)
	Hide(lthigh)
	Hide(lknee)
	Hide(lshin)
	Hide(lfoot)
	Hide(rthigh)
	Hide(rknee)
	Hide(rshin)
	Hide(rfoot)
	Hide(rsack)
	Hide(lsack)
		
	bMoving = false
	bDigging = true

	Spring.SetUnitRulesParam(unitID, "selfMoveSpeedChange", 1/3)
	GG.UpdateUnitAttributes(unitID)
	
	StartThread(MotionControl)
	
	restore_delay = 3000

	StartThread(Go)
end
	

function script.HitByWeaponId()	
	EmitSfx(body, 1024)
	return 100
end

function script.Killed(recentDamage, maxHealth)
	EmitSfx(body, 1025)
	return(0)
end
