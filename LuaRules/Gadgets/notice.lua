if not gadgetHandler:IsSyncedCode() then -- no unsynced nonsense
	return
end

function gadget:GetInfo()
	return {
		name      = "Notice",
		desc      = "This is a modified game.",
		author    = "Shaman",
		date      = "12/19/2020",
		license   = "CC-0",
		layer     = -math.huge,
		enabled   = true,
	}
end

Spring.Echo("DEVELOPER NOTICE: This is a FUTURE WARS game. If you're getting any unusual crash reports with this message, please kindly open an issue here: https://github.com/Arch-Shaman/ZK-Futurewars-Mod/issues")

function gadget:Shutdown()
	Spring.Echo("FUTURE WARS GAME OVER.")
end
