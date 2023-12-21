function widget:GetInfo()
	return {
		name      = "AI Notice",
		desc      = "Tells players when an AI has been disabled.",
		author    = "Shaman",
		date      = "12/19/2020",
		license   = "CC-0",
		layer     = -7,
		enabled   = true,
	}
end

local spEcho = Spring.Echo

local function Echo(str)
	spEcho("game_message: " .. str)
end

local aiteams = {}
local debugmode = false
local botowners = {}
local namestocheck = {}
local nametoid = {}
local wantstate = false
local checkplayers = {}
local loaded = {}
local find = string.find

local function IsAIBlackListed(teamID)
	local luaAI = Spring.GetTeamLuaAI(teamID)
	return luaAI ~= nil
end

do
	local teamlist = Spring.GetTeamList()
	for t = 1, #teamlist do
		local team = teamlist[t]
		if select(4, Spring.GetTeamInfo(team)) and not IsAIBlackListed(team) then
			wantstate = true
			local _, name, host = Spring.GetAIInfo(team)
			local hostname = Spring.GetPlayerInfo(host)
			aiteams[team] = hostname
			if botowners[hostname] == nil then
				botowners[hostname] = {}
				namestocheck[#namestocheck + 1] = hostname
				checkplayers[host] = true
				nametoid[hostname] = host
				loaded[hostname] = false
			end
			botowners[hostname][#botowners[hostname] + 1] = name
			if debugmode then
				spEcho("[AI Notice] Discovered " .. name .. " for " .. hostname)
			end
		end
	end
end

local reasons = {
	["disconnected"] = "disconnected",
	["left_prematurely"] = "left prematurely",
}

local function OnLocaleChanged()
	for str, _ in pairs(reasons) do
		reasons[str] = WG.Translate("interface", "ai_warning_" .. str)
	end
end

function widget:Initialize()
	if not wantstate then
		spEcho("[AI Notice] No bots detected. Removing.")
		widgetHandler:RemoveWidget()
		return
	end
	WG.InitializeTranslation(OnLocaleChanged, GetInfo().name)
end

local function GetLeaver(str)
	for i = 1, #namestocheck do
		local name = namestocheck[i] 
		if debugmode then
			spEcho("[AI Notice] Checking " .. name)
		end
		if find(str, name .. " ") then -- prevent Shaman, ShamanDev multidetection.
			return name
		end
	end
	return "?"
end

local function ReportLeaver(aihost, reason)
	local str = ""
	for i = 1, #botowners[aihost] do
		str = str .. "\n" .. botowners[aihost][i]
	end
	local translatedReason = reasons[reason]
	
	Echo(WG.Translate("interface", "ai_warning", {
		name = aihost,
		reason = translatedReason,
	}) .. str)
end

function widget:AddConsoleLine(msg, priority)
	if find(msg, "Game::Load") then
		for i = 1, #namestocheck do
			local name = namestocheck[i]
			if msg:find("\"" .. name .. "\"") then
				loaded[name] = true
				return
			end
		end
	end
	if find(msg, "left the game:") then -- determine who left
		if debugmode then
			spEcho("[AI Notice] Detected leaver!")
		end
		local aihost = GetLeaver(msg)
		if debugmode then
			spEcho("[AI Notice] Got " .. aihost)
		end
		if aihost ~= "?" then -- some ais are broken now.
			local str = ""
			for i = 1, #botowners[aihost] do
				str = str .. "\n" .. botowners[aihost][i]
			end
			ReportLeaver(aihost, "disconnected")
		end
	end
end


function widget:GameStart()
	if debugmode then
		spEcho("[AI Notice] Checking game start")
	end
	local ignoreowners = {}
	for id, ownername in pairs(aiteams) do
		if ignoreowners[ownername] ~= nil then
			local ping = select(6, Spring.GetPlayerInfo(nametoid[ownername]))
			spEcho("Ping time: " .. tostring(ping))
			if not loaded[ownername] then
				ReportLeaver(ownername, "left_prematurely")
				ignoreowners[ownername] = true
			end
		end
	end
end
