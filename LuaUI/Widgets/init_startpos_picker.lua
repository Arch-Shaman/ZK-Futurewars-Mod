function widget:GetInfo()
	return {
		name      = "Startposition Setting",
		desc      = "Allows one to control the placement of their commanders.",
		author    = "Shaman",
		date      = "10/20/2020",
		license   = "PD",
		layer     = 6,
		enabled   = true,
		alwaysStart = true,
	}
end

if Spring.GetGameFrame() > 0 then -- do not even bother for games that are in progress.
	return
end

local count = 0
local current = 1
local numentities = 0
local block = false
local Chili, Screen0, Window, ScrollGrid, Text
local myorigteamid = 0 -- 0 is myteam.
local indexes = {}
local myplayerID = Spring.GetMyPlayerID()
local spectator = Spring.GetSpectatingState()

-- we need to say 'startpos:teamID,index,x,z'


-- Strings (for localization) --
local pickdropzone = "Pick gate zone for "
local awaitingdrop = "Your commanders missing gate zone: "
local globalcomswaiting = "Squad's commanders missing gate zone: "
local missingplayers = "Waiting on "
local force = "Type !force to start sooner."
local droplock = "Gate zones locked in.\n\tPrepare for gate in " -- 3 2 1 0
local forcestart = "Forced gate in "

--[[ Example strings:
	Pick dropzone for Strike Trainer (1/2)
	Your commanders missing dropzones: 3
	Waiting on Firepluk, Slaab, Shaman, blah blah
	Commanders awaiting dropzone: 9
	
]]
function widget:PlayerChangedTeam(playerID, old, new)
	if playerID == myTeam then
		
	end
end

function widget:Initialize()
	local teamlist = Spring.GetTeamList()
	for i = 1, #teamlist do
		local teamID = teamlist[i]
		indexes[teamID] = Spring.GetTeamRulesParam(teamID, "startpos_indexes")
	end
	myorigteamid = Spring.GetPlayerRulesParam(myplayerID, )
	Chili = WG.Chili
	Screen0 = Chili.Screen0
	Window = Chili.Window:New{parent = Screen0, width = '20%', height = '40%',x = '0',y = '27.5%', resizable = false, draggable = true, visible = true, dockable = false}
	Window:Hide()
	Chili.TextBox:New{parent = Window, width = '60%', height  = '10%', y='2.5%', x = '27.5%', text = "Startpos Menu", textColor = {1.0,0.4,0.4}, fontsize = 17, color = {0,0.75,0.75}}
	Chili.Line:New{parent = Window, y = '7%', width = '100%'}
	Chili.ScrollPanel:New{parent = Window, verticalScrollbar = true, horizontalScrollbar = false, width='100%', height='85%', scrollBarSize=40, y = '13%'}
	ScrollGrid = Chili.Grid:New{columns = 1, x = 0, y = 0, width = '100%', height = 1700}
	text = Chili.TextBox:New{parent = Screen0, width = '35%', height = '20%', x = '25%', y = '70%', text = "Pick Startpos for Comm #1", fontsize = 16}
	text:Hide()
end

function widget:GameStart()
	text:Dispose()
	Window:Dispose()
	widgetHandler:RemoveWidget()
end
