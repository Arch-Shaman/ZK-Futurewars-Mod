function widget:GetInfo()
	return {
		name      = "AI Notice",
		desc      = "Tells players when an AI has been disabled.",
		author    = "Shaman",
		date      = "12/19/2020",
		license   = "CC-0",
		layer     = -7,
		enabled   = true,
		alwaysStart = true,
	}
end

local spEcho = Spring.Echo

local function Echo(str)
	spEcho("game_message: " .. str)
end

local aiteams = {}
local debug = false
local botowners = {}
local namestocheck = {}
local nametoid = {}
local wantstate = false
local checkplayers = {}
local loaded = {}
do
	local teamlist = Spring.GetTeamList()
	for t = 1, #teamlist do
		local team = teamlist[t]
		if select(4, Spring.GetTeamInfo(team)) then
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
			if debug then
				spEcho("[AI Notice] Discovered " .. name .. " for " .. hostname)
			end
		end
	end
end

if not wantstate then
	spEcho("[AI Notice] No bots detected. Removing.")
	widgetHandler:RemoveWidget()
end

local function GetLeaver(str)
	for i = 1, #namestocheck do
		local name = namestocheck[i] 
		if debug then
			spEcho("Checking " .. name)
		end
		if str:find(name .. " ") then -- prevent Shaman, ShamanDev multidetection.
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
	Echo("WARNING: AI Host " .. aihost .. " " .. reason .. "! The following AIs will remain idle until they return:" .. str)
end

function widget:AddConsoleLine(msg, priority)
	if msg:find("Game::Load") then
		for i = 1, #namestocheck do
			local name = namestocheck[i]
			if msg:find("\"" .. name .. "\"") then
				loaded[name] = true
				return
			end
		end
	end
	if msg:find("left the game:") then -- determine who left
		if debug then
			spEcho("[AI Notice] Detected leaver!")
		end
		local aihost = GetLeaver(msg)
		if debug then
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
	if debug then
		spEcho("[AI Notice] Checking game start")
	end
	local ignoreowners = {}
	for id, ownername in pairs(aiteams) do
		if ignoreowners[ownername] ~= nil then
			local ping = select(6, Spring.GetPlayerInfo(nametoid[ownername]))
			spEcho("Ping time: " .. tostring(ping))
			if not loaded[ownername] then
				ReportLeaver(ownername, " has not loaded yet or left prematurely")
				ignoreowners[ownername] = true
			end
		end
	end
end
