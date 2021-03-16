-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "MIRV Target Painter",
    desc      = "Paintin' the Target",
    author    = "Stuff/HTMLPhoton",
    date      = "12/3/2021",
    license   = "GNU GPL, v2 or later",
	handler   = true,
    layer     = 0,
    enabled   = true,
  }
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------


-- speed-ups

local spEcho = Spring.Echo

local spGetGameFrame = Spring.GetGameFrame
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetGroundHeight = Spring.GetGroundHeight
local spGetActiveCommand = Spring.GetActiveCommand
local spTraceScreenRay = Spring.TraceScreenRay
local spGetMouseState = Spring.GetMouseState

local glDepthTest      = gl.DepthTest
local glAlphaTest      = gl.AlphaTest
local glTexture        = gl.Texture
local glTexRect        = gl.TexRect
local glTranslate      = gl.Translate
local glBillboard      = gl.Billboard
local glColor          = gl.Color
local glVertex         = gl.Vertex
local glBeginEnd       = gl.BeginEnd
local glRotate		   = gl.Rotate
local glScale		   = gl.Scale
local GL_GREATER       = GL.GREATER
local GL_LINES         = GL.LINES

local min	= math.min
local max = math.max
local floor = math.floor
local abs 	= math.abs
local sin 	= math.sin
local cos 	= math.cos

local fullturn = 2*math.pi

local selectedMIRV = false
local selectedDefID = 0
local drawMIRVCircle = false
local mousePos = {}

local wanteddefs = VFS.Include("LuaRules/Configs/setprojectiletargetdefs.lua") or {}
--Spring.Utilities.TableEcho(wanteddefs)

local function VertexList(point)
	for i = 1, #point do
		glVertex(point[i])
	end
end


local function VertexListCircle(x,y,z,r,i)
	for i = 0, fullturn, i do
		vx = x + sin(i)*r
		vz = z + cos(i)*r
		--vy = spGetGroundHeight(vx,vz)
		glVertex(vx,y,vz)
	end
end

function widget:SelectionChanged(newSelection)
	selectedMIRV = false
	for i = 1, #newSelection do
		local unitID = newSelection[i]
		local unitDefID = Spring.GetUnitDefID(unitID)
		if unitDefID then
			if wanteddefs[unitDefID] then
				selectedMIRV = unitID
				selectedDefID = unitDefID
				return
			end
		end
	end
end

local function DrawWorldFunc()
	local rotation = (spGetGameFrame() / 1) % 360
	
	if Spring.IsGUIHidden() then
		return
	end
	
	if selectedMIRV then
		--spEcho(selectedMIRV)
		--glDepthTest(true)
		local x,y,z
		local def = wanteddefs[selectedDefID]
		if drawMIRVCircle then
			x,y,z = mousePos[1],mousePos[2],mousePos[3]
			
			gl.LineWidth(8)
			glColor(1, 0, 0, 0.8)
			--gl.DrawGroundCircle(x, y, z, 1000, 256)
			glBeginEnd(GL_LINES, VertexListCircle, x, y, z, def.range, math.rad(5))
		end
		
		local TargetCount = spGetUnitRulesParam(selectedMIRV, "subprojectile_target_count") or 0
		--spEcho(TargetCount)
		if TargetCount > 0 then
			--glDepthTest(true)
			gl.LineWidth(10)
			glAlphaTest(GL_GREATER, 0)
			glColor(1,1,1,0.8)
			glTexture('LuaUI/Images/commands/Bold/nuke.png')
			
			local drawnTargets = def.targets
			
			for i = 1, TargetCount do
				local targetX = spGetUnitRulesParam(selectedMIRV, "subprojectile_target_" .. i .. "_x")
				local targetZ = spGetUnitRulesParam(selectedMIRV, "subprojectile_target_" .. i .. "_z")
				local targetY = spGetGroundHeight(targetX, targetZ)
				
				--spEcho("targetX: " .. targetX .. ", targetY: " .. targetY .. ", targetZ: " .. targetZ)
				
				if drawMIRVCircle and drawnTargets > 0 and (targetX-x)^2+(targetZ-z)^2 < def.range2 then
					local vertices = {{targetX, targetY, targetZ}, mousePos}
					
					glTexture(false)
					gl.LineWidth(10)
					glColor(0,1,0,0.6)
					glBeginEnd(GL_LINES, VertexList, vertices)
					--Spring.Utilities.TableEcho(vertices)
					glColor(1,1,1,1)
					--spEcho("darn son")
					glTexture(true)
					
					drawnTargets = drawnTargets - 1
				end
				
				gl.PushMatrix()
				glTranslate(targetX, max(targetY, 0.0), targetZ)
				--glBillboard()
				glRotate(rotation, 0, 1, 0)
				glRotate(90, 1, 0, 0)
				--glScale(1, 0.66, 1)
				glTexRect(-64, -64, 64, 64)
				
				gl.PopMatrix()
			end --for
			
			glTexture(false)
			glAlphaTest(false)
			glDepthTest(false)
		end
	end
end

local function SetMouseData(cmdID)
	if cmdID ~= CMD.ATTACK then
		return false
	end
	
	local mx, my = spGetMouseState()
	local _, mouse = spTraceScreenRay(mx, my, true, true)
	if not mouse then
		return false
	end
	
	mouse = {mouse[1], mouse[2], mouse[3]}
	
	if not mouse then
		return false
	end
	
	mousePos = mouse
	
	--Spring.Utilities.TableEcho(mouse)
	
	return true
end

function widget:Update()
	local _, cmdID = spGetActiveCommand()
	
	drawMIRVCircle = SetMouseData(cmdID)
	--spEcho(drawMIRVCircle)
end

function widget:DrawWorldPreUnit()
	DrawWorldFunc()
end --DrawWorld