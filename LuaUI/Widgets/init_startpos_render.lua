function widget:GetInfo()
	return {
		name      = "Lua Start positions",
		desc      = "Draws lua start positions.",
		author    = "Shaman",
		date      = "Aug 21, 2020",
		license   = "PD",
		layer     = -1,
		enabled   = true,
		alwaysStart = true,
		handler = true,
	}
end

--[[local modOptions = Spring.GetModOptions()

if modOptions.singleplayercampaignbattleid then
	Spring.Echo("StartHandler is using legacy start handler.")
	widgetHandler:RemoveWidget(widget)
	return
end]]

--Spring.IsAABBInView

--openGL speedups
local glColor = gl.Color
local glDepthTest = gl.DepthTest
local glDepthMask = gl.DepthMask
local glLighting = gl.Lighting
local glPushMatrix = gl.PushMatrix
local glLoadIdentity = gl.LoadIdentity
local glTranslate = gl.Translate
local glRotate = gl.Rotate
local glUnitShape = gl.UnitShape
local glPopMatrix = gl.PopMatrix
local glDrawGroundCircle = gl.DrawGroundCircle
local glText = gl.Text
local spEcho = Spring.Echo
local spGetTeamColor = Spring.GetTeamColor
local spGetGroundHeight = Spring.GetGroundHeight
local spGetPlayerInfo = Spring.GetPlayerInfo
local spWorldToScreenCoords = Spring.WorldToScreenCoords
local spGetTeamInfo = Spring.GetTeamInfo
local spSendLuaRulesMsg = Spring.SendLuaRulesMsg
local startpos = {}

local function Echo(txt)
	spEcho("[StartPosAPI] Rendering: " .. txt)
end

local function DrawCommander(uDefID, teamID, ux, uy, uz, startposnum) -- borrowed this from initial queue.
	if ux == 0 and uz == 0 then -- default position
		return
	end
	local r,g,b,a = spGetTeamColor(teamID)
	local textZ = uz - 10
	local textY = spGetGroundHeight(ux,textZ)
	local name = spGetPlayerInfo(select())
	if #spGetPlayerList(teamID) > 1 then
		name = name .. "'s squad (" .. startposnum .. ")"
	else
		name = name .. "(" .. startposnum .. ")"
	end
	glColor(1.0, 1.0, 1.0, 1.0)
	glDepthTest(GL.LEQUAL)
	glDepthMask(true)
	glLighting(true)
	if uDefID ~= '?' and uDefID ~= nil then
		glPushMatrix()
			glLoadIdentity()
			glTranslate(ux, uy, uz)
			glRotate(0, 0, 1, 0)
			glUnitShape(uDefID, teamID, false, false, false)
		glPopMatrix()
	end
	local sx, sy, sz = spWorldToScreenCoords(ux,uy,uz)
	if sx then
		if uDefID == nil or uDefID == '?' then
			glDrawGroundCircle(ux,uy,uz, 20,8)
		end
		glColor(r,g,b,a)
		glText(name,sx,sz,'co')
		glColor(1,1,1,1)
	end
	glLighting(false)
	glDepthTest(false)
	glDepthMask(false)
end

local function CheckIfExists(teamID,id)
	local startpos = knownCommanderStarts[teamID]
	for i=1, #startpos do
		if startpos[i].id == id then
			return i
		end
	end
end

local function StartUpdated(teamID)
	local starts = spGetTeamRulesParam(teamID, "startpos_num")
	if starts then
		if startpos[teamID] then
			for i = 1, starts do
				startpos[teamID][i].x = spGetTeamRulesParam(teamID, "startpos_" .. i .. "_x") or 0
				startpos[teamID][i].z = spGetTeamRulesParam(teamID, "startpos_" .. i .. "_z") or 0
				startpos[teamID][i].def = spGetTeamRulesParam(teamID, "startpos_ " .. i .. "_def") or '?'
				startpos[teamID][i].y = spGetGroundHeight(startpos[teamID][i].x, startpos[teamID][i].z) or 0
			end
		else
			startpos[teamID] = {}
			for i = 1, starts do
				local x = spGetTeamRulesParam(teamID, "startpos_" .. i .. "_x") or 0
				local z = spGetTeamRulesParam(teamID, "startpos_" .. i .. "_z") or 0
				local y = spGetGroundHeight(x,z)
				startpos[teamID][i] = {
					x   = x,
					y   = y,
					z   = z,
					def = spGetTeamRulesParam(teamID, "startpos_" .. i .. "_def") or '?',
				}
			end
		if WG then
			WG.StartPositions = startpos -- for other widgets.
		end
	end
end

function widget:DrawWorld()
	for teamID, starts in pairs(startpos) do
		if #starts > 0 then
			for i = 1, #starts do
				local x, y, z = starts[i].x, starts[i].y, starts[i].z
				DrawCommander(startpos[i].def, id, x, y, z, i)
			end
		end
	end
end

local function Shutdown()
	Echo("[Startpos] Removing renderer. (Game Start!)")
	widgetHandler:DeregisterGlobal('StartPosUpdate') -- no point in having this anymore.
	widgetHandler:RemoveCallin('DrawWorld')
	--widgetHandler:RemoveWidget(widget)
	WG.Commshares = nil
end

function widget:GameStart()
	Shutdown()
end

function widget:Initialize()
	if spGetGameFrame() > 0 then
		Shutdown()
		return
	end
	widgetHandler:RegisterGlobal('StartPosUpdate', StartUpdated)
	local allys = spGetAllyTeamList()
	for i = 1, #allys do
		local allyteam = allys[i]
		local teamlist = spGetTeamList(allyteam)
		for t = 1, #teamlist do
			startpos[teamID] = {}
			StartUpdated(teamlist[t])
		end
	end
end
