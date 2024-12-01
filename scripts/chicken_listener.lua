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
local bMoving, restore_delay

-- Signal definitions
local SIG_RESTORE = 2
local SIG_STATE = 4

include "constants.lua"


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

local function MotionControl(moving, justmoved)
	justmoved = true
	while true do
		moving = bMoving
		if moving then
			walk()
			justmoved = true
		end
		if not moving and justmoved then
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
	Spring.SetUnitNanoPieces(unitID, {head})
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
