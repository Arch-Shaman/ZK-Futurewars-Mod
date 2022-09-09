include("keysym.lua")
local versionNumber = "1.2"

function widget:GetInfo()
	return {
		name      = "Blast Radius",
		desc      = "[v" .. string.format("%s", versionNumber ) .. "] Displays blast radius of select units (META+X) and while placing buildings (META)",
		author    = "very_bad_soldier",
		date      = "April 7, 2009",
		license   = "GNU GPL v2",
		layer     = 0,
		enabled   = true
	}
end

--These can be modified if needed
local blastCircleDivs = 64
local blastLineWidth = 2.0
local blastAlphaValue = 0.5

--------------------------------------------------------------------------------
local blastColor = { 1.0, 0.0, 0.0 }
local expBlastAlphaValue = 1.0
local expBlastColor = { 1.0, 0.0, 0.0}

local lastColorChangeTime = 0.0
local selfdCycleDir = false
local selfdCycleTime = 0.3
local expCycleTime = 0.5

-------------------------------------------------------------------------------

local udefTab				= UnitDefs
local weapNamTab			= WeaponDefNames
local weapTab				= WeaponDefs

local spGetActiveCommand 	= Spring.GetActiveCommand
local spGetKeyState         = Spring.GetKeyState
local spGetModKeyState      = Spring.GetModKeyState
local spGetSelectedUnits    = Spring.GetSelectedUnits
local spGetUnitDefID        = Spring.GetUnitDefID
local spGetUnitPosition     = Spring.GetUnitPosition
local spGetGameSeconds      = Spring.GetGameSeconds
local spGetActiveCmdDesc 	= Spring.GetActiveCmdDesc
local spGetMouseState       = Spring.GetMouseState
local spTraceScreenRay      = Spring.TraceScreenRay
local spEcho                = Spring.Echo
local spGetBuildFacing	    = Spring.GetBuildFacing
local spPos2BuildPos        = Spring.Pos2BuildPos

local glColor               = gl.Color
local glLineStipple         = gl.LineStipple
local glLineWidth           = gl.LineWidth
local glTexture             = gl.Texture
local glDrawGroundCircle    = gl.DrawGroundCircle
local glPopMatrix           = gl.PopMatrix
local glPushMatrix          = gl.PushMatrix
local glTranslate           = gl.Translate
local glBillboard           = gl.Billboard
local glText                = gl.Text

local max					= math.max
local min					= math.min
local sqrt					= math.sqrt
local lower                 = string.lower
local floor                 = math.floor

-----------------------------------------------------------------------------------
local alwaysDisplay = {
	[UnitDefNames.energyfusion.id] = true,
	[UnitDefNames.energysingu.id] = true,
	[UnitDefNames.staticcon.id] = true,
	[UnitDefNames.staticnuke.id] = true,
	[UnitDefNames.staticenergyrtg.id] = true,
	[UnitDefNames.energyprosperity.id] = true,
	[UnitDefNames.energygeo.id] = true,
}

-----------------------------------------------------------------------------------

function widget:DrawWorld()
	glLineStipple(true)
	DrawBuildMenuBlastRange()
	
	--hardcoded: meta + X
	local keyPressed = spGetKeyState( KEYSYMS.X )
	local alt,ctrl,meta,shift = spGetModKeyState()
		
	if (meta and keyPressed) then
		DrawBlastRadiusSelectedUnits()
	end
	
	ResetGl()
end

function ChangeBlastColor()
	--cycle red/yellow
	local time = spGetGameSeconds()
	local timediff = ( time - lastColorChangeTime )
		
	local addValueSelf = timediff/ selfdCycleTime
	local addValueExp = timediff/ expCycleTime

	if ( blastColor[2] >= 1.0 ) then
		selfdCycleDir = false
	elseif ( blastColor[2] <= 0.0 ) then
		selfdCycleDir = true
	end
	
	if ( expBlastColor[2] >= 1.0 ) then
		expCycleDir = false
	elseif ( expBlastColor[2] <= 0.0 ) then
		expCycleDir = true
	end

	if ( selfdCycleDir == false ) then
		blastColor[2] = blastColor[2] - addValueSelf
		blastColor[2] = max( 0.0, blastColor[2] )
	else
		blastColor[2] = blastColor[2] + addValueSelf
		blastColor[2] = min( 1.0, blastColor[2] )
	end
	
	if ( expCycleDir == false) then
		expBlastColor[2] = expBlastColor[2] - addValueExp
		expBlastColor[2] = max( 0.0, expBlastColor[2] )
	else
		expBlastColor[2] = expBlastColor[2] + addValueExp
		expBlastColor[2] = min( 1.0, expBlastColor[2] )
	end
					
	lastColorChangeTime = time
end

local function DrawRadiusOnUnit(centerX, height, centerZ, blastRadius, text, invert)
	glLineWidth(blastLineWidth)
	local g = expBlastColor[2]
	if invert then
		g = 1 - g
	end
	glColor( expBlastColor[1], g, expBlastColor[3], blastAlphaValue )
	
	--draw static ground circle
	glDrawGroundCircle(centerX, 0, centerZ, blastRadius, blastCircleDivs )
	glPushMatrix()
	
	glTranslate(centerX , height, centerZ)
	glTranslate(-blastRadius / 2, 0, blastRadius / 2 )
	glBillboard()
	glText(text, 0.0, 0.0, sqrt(blastRadius), "cn")
	glPopMatrix()
	
	--tidy up
	glLineWidth(1)
	glColor(1, 1, 1, 1)
	
	--cycle colors for next frame
	ChangeBlastColor()
end
	

function DrawBuildMenuBlastRange()
	--check if valid command
	local idx, cmd_id, cmd_type, cmd_name = spGetActiveCommand()
	
	if (not cmd_id) then return end
	
	--check if META is pressed
	local alt,ctrl,meta,shift = spGetModKeyState()
		
	if ( not meta ) and not (alwaysDisplay[-cmd_id]) then --and keyPressed) then
		return
	end
	
	--check if build command
	local cmdDesc = spGetActiveCmdDesc( idx )
	
	if ( cmdDesc["type"] ~= 20 ) then
		--quit here if not a build command
		return
	end
	
	local unitDefID = -cmd_id
		
	local udef = udefTab[unitDefID]
	local morphdef = UnitDefs[unitDefID].customParams.morphto and UnitDefNames[UnitDefs[unitDefID].customParams.morphto]
	local baseExplosionDef = weapNamTab[lower(udef["deathExplosion"])] 
	local morphExplosionDef = morphdef and weapNamTab[lower(morphdef["deathExplosion"])]
	if not (baseExplosionDef or morphExplosionDef) then
		return
	end
	
	local mx, my = spGetMouseState()
	local _, coords = spTraceScreenRay(mx, my, true, true)
	if not coords then return end
	local centerX = coords[1]
	local centerZ = coords[3]
	centerX, _, centerZ = spPos2BuildPos( unitDefID, centerX, 0, centerZ, spGetBuildFacing() )
	local height = Spring.GetGroundHeight(centerX,centerZ)
	
	if baseExplosionDef then
		local blastRadius = baseExplosionDef.damageAreaOfEffect
		local damage = baseExplosionDef.customParams.shield_damage
		local text = ""
		if morphExplosionDef == nil or morphExplosionDef.id == baseExplosionDef.id then
			text = "Damage: " .. damage
		else
			text = "Unmorphed: " .. damage
		end
		DrawRadiusOnUnit(centerX, height, centerZ, blastRadius, text, false)
	end
	if morphExplosionDef and morphExplosionDef.id ~= baseExplosionDef.id then
		local blastRadius = morphExplosionDef.damageAreaOfEffect
		local defaultDamage = morphExplosionDef.customParams.shield_damage	--get default damage
		DrawRadiusOnUnit(centerX, height, centerZ, blastRadius, "Morphed: " .. defaultDamage, true)
	end
end

function DrawUnitBlastRadius( unitID )
	local unitDefID =  spGetUnitDefID(unitID)
	local udef = udefTab[unitDefID]
	local x, y, z = spGetUnitPosition(unitID)
	if ( weapNamTab[lower(udef["deathExplosion"])] ~= nil and weapNamTab[lower(udef["selfDExplosion"])] ~= nil ) then
		deathBlasId = weapNamTab[lower(udef["deathExplosion"])].id
		blastId = weapNamTab[lower(udef["selfDExplosion"])].id
		
		blastRadius = weapTab[blastId].damageAreaOfEffect
		deathblastRadius = weapTab[deathBlasId].damageAreaOfEffect
		
		blastDamage = weapTab[blastId].customParams.shield_damage
		deathblastDamage = weapTab[deathBlasId].customParams.shield_damage
		local height = Spring.GetGroundHeight(x,z)
		glLineWidth(blastLineWidth)
		glColor( blastColor[1], blastColor[2], blastColor[3], blastAlphaValue)
		glDrawGroundCircle( x,y,z, blastRadius, blastCircleDivs )
		glPushMatrix()
		glTranslate(x , height, z)
		glTranslate(-blastRadius / 2, 0, blastRadius / 2 )
		glBillboard()
		text = blastDamage --text = "SELF-D"
		if ( deathblastRadius == blastRadius ) then
			text = blastDamage .. " / " .. deathblastDamage --text = "SELF-D / EXPLODE"
		end

		glText( text, 0.0, 0.0, sqrt(blastRadius) , "cn")
		glPopMatrix()

		if ( deathblastRadius ~= blastRadius ) then
			glColor( expBlastColor[1], expBlastColor[2], expBlastColor[3], expBlastAlphaValue)
			glDrawGroundCircle( x,y,z, deathblastRadius, blastCircleDivs )

			glPushMatrix()
			glTranslate(x - ( deathblastRadius / 2 ), height , z  + ( deathblastRadius / 2) )
			glBillboard()
			glText( deathblastDamage , 0.0, 0.0, sqrt(deathblastRadius), "cn")
			glPopMatrix()
		end
	end
end

function DrawBlastRadiusSelectedUnits()
	glLineWidth(blastLineWidth)
  	  
	local units = spGetSelectedUnits()
	for i,unitID in ipairs(units) do
		DrawUnitBlastRadius( unitID )
	end
	ChangeBlastColor()
end

--Commons
function ResetGl()
	glColor( { 1.0, 1.0, 1.0, 1.0 } )
	glLineWidth( 1.0 )
	glTexture(false)
	glLineStipple(false)
end
