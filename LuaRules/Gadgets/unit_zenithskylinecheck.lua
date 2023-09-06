if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name    = "Zenith Skyline Checker",
		desc    = "Blocks Zenith Meteor spawn when the beam is broken",
		author  = "Shaman",
		date    = "July 8 2020",
		license = "PD",
		layer   = -1,
		enabled = false,
	}
end
