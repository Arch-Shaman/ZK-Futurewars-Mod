
function widget:GetInfo()
	return {
		name      = "Decloak Tower Range",
		desc      = "Displays the Decloak Tower's Range. (Based on silo range widget)",
		author    = "Shaman",
		date      = "Feb 4, 2021",
		license   = "CC-0",
		layer     = 0,
		enabled   = true,
		alwaysEnabled = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Config

local drawRadius = {}

--large textSize & opacity for large radius/tiny text & opacity for small radius, help increase text visibility during zoom-out/zoom-in
drawRadius[1] = {
	range = WeaponDefs[UnitDefNames["turretdecloak"].weapons[1].weaponDef].damageAreaOfEffect,
	color = {0.8, 0.8, 0.2,1},
	text = "",
	width = 1,
	miniWidth = 1,
	textSize = 180,
}

drawRadius[2] = {
	range = WeaponDefs[UnitDefNames["factoryspider"].weapons[1].weaponDef].damageAreaOfEffect,
	color = {0.8, 0.8, 0.2,1},
	text = "",
	width = 1,
	miniWidth = 1,
	textSize = 180,
}

local circleDivs = 64

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Speedup

VFS.Include("LuaRules/Utilities/glVolumes.lua")

local spGetActiveCommand = Spring.GetActiveCommand
local spTraceScreenRay   = Spring.TraceScreenRay
local spGetMouseState    = Spring.GetMouseState
local spTraceScreenRay   = Spring.TraceScreenRay
local spGetGroundHeight  = Spring.GetGroundHeight
local spGetCameraState   = Spring.GetCameraState

local wantedIDs = {
	[-UnitDefNames["turretdecloak"].id] = true,
	[-UnitDefNames["factoryspider"].id] = true,
}

local floor = math.floor
local cos = math.cos
local sin = math.sin
local mapX = Game.mapSizeX
local mapZ = Game.mapSizeZ

local glColor               = gl.Color
local glLineWidth           = gl.LineWidth
local glDepthTest           = gl.DepthTest
local glTexture             = gl.Texture
local glDrawCircle          = gl.Utilities.DrawCircle
local glDrawGroundCircle    = gl.DrawGroundCircle
local glPopMatrix           = gl.PopMatrix
local glPushMatrix          = gl.PushMatrix
local glTranslate           = gl.Translate
local glBillboard           = gl.Billboard
local glText                = gl.Text
local glScale               = gl.Scale
local glRotate              = gl.Rotate
local glLoadIdentity        = gl.LoadIdentity
local glLineStipple         = gl.LineStipple

local mouseX, mouseZ

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function DrawActiveCommandRanges()
	local _, cmd_id = spGetActiveCommand()
	
	if not (cmd_id and wantedIDs[cmd_id]) then
		return
	end
	
	local mx, my = spGetMouseState()
	local _, mouse = spTraceScreenRay(mx, my, true, true)
	
	if not mouse then
		return
	end
	
	mouseX = floor((mouse[1]+8)/16)*16
	mouseZ = floor((mouse[3]+8)/16)*16
	
	local height = spGetGroundHeight(mouseX, mouseZ)
	
	--handle COFC rotation
	local cs = spGetCameraState()
	local dx,dz = 0, 1
	if cs.ry then
		local rotY = cs.ry - 1.5707
		dx = cos(rotY)
		dz = sin(rotY)
	end
	
	for i = 1, 1 do
		local radius = drawRadius[i]
		
		glLineWidth(radius.width)
		glColor(radius.color[1], radius.color[2], radius.color[3], radius.color[4] )
		if radius.stipple then
			glLineStipple(radius.stipple[1],radius.stipple[2])
		else
			glLineStipple(false)
		end
		
		glDrawGroundCircle(mouseX, 0, mouseZ, radius.range, circleDivs )
		
		glPushMatrix()
		glTranslate(mouseX + radius.range*dx,  height, mouseZ - (radius.range*dz)-5)
		glBillboard()
		glText( radius.text, 0, 0, radius.textSize, "cn")
		glPopMatrix()
	end
	
	glLineStipple(false)
	glLineWidth(1)
	glColor(1, 1, 1, 1)
end

local function DrawActiveCommandRangesMinimap(minimapX, minimapY)
	local _, cmd_id = spGetActiveCommand()
	
	if not (cmd_id and wantedIDs[cmd_id]) then
		return
	end
	
	if not mouseX then
		return
	end
	
	local height = spGetGroundHeight(mouseX,mouseZ)
	
	glTranslate(0,minimapY,0)
	glScale(minimapX/mapX, -minimapY/mapZ, 1)
	
	
	for i = 1, 1 do
		local radius = drawRadius[i]
		
		glLineWidth(radius.miniWidth)
		glColor(radius.color[1], radius.color[2], radius.color[3], radius.color[4] )
		if radius.stipple then
			glLineStipple(radius.stipple[1],radius.stipple[2])
		else
			glLineStipple(false)
		end
		
		glDrawCircle(mouseX, mouseZ, radius.range)
	end
	
	glScale(1, 1, 1)
	glLineStipple(false)
	glLineWidth(1)
	glColor(1, 1, 1, 1)
end

function widget:DrawInMiniMap(minimapX, minimapY)
	DrawActiveCommandRangesMinimap(minimapX, minimapY)
end

function widget:DrawWorld()
	DrawActiveCommandRanges()
end

function widget:Shutdown()
	WG.ShutdownTranslation(GetInfo().name)
end
