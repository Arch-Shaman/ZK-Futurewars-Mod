--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "GameRules Events",
		desc = "Sets RulesParams to tell widgets what is going on in the game",
		author = "Google Frog",
		date = "15 August 2015",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true
	}
end

if not gadgetHandler:IsSyncedCode() then
	local warningframes = -5
	local playsound = -181
	local frame = -1
	local lastplayed = -5
	
	local function NukeLaunched(_, allyteam)
		local myallyteam = Spring.GetMyAllyTeamID()
		if myallyteam ~= allyteam then
			if Script.LuaUI('NukeAlert') then
				Script.LuaUI.NukeAlert(true)
				warningframes = frame + 100 + math.ceil(50*math.random())
				if playsound + 36 < frame then
					playsound = frame + 35
				end
			end
		end
	end
	
	function gadget:GameFrame(f)
		frame = f
		if f == warningframes then
			if Script.LuaUI('NukeAlert') then
				Script.LuaUI.NukeAlert(false)
			end
		end
		if playsound == f then
			Spring.PlaySoundFile("nukewarning", 100)
		end
	end
	
	function gadget:Initialize()
		gadgetHandler:AddSyncAction("nukelaunched", NukeLaunched)
	end
	
	return
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- The gadget intends to only tell players whether a nuke was launched recently
-- The lack of nuke counting or accurate timing is intentional.

local removeWarningFrame = false

local function GameRules_NukeLaunched(unitID)
	local allyteam = Spring.GetUnitAllyTeam(unitID)
	SendToUnsynced("nukelaunched", allyteam)
end

function gadget:Initialize()
	GG.GameRules_NukeLaunched = GameRules_NukeLaunched
end
