local airpadDefs = {
	[UnitDefNames["factoryplane"].id] = {
		padPieceName = {"land"}
	},
	[UnitDefNames["staticrearm"].id] = {
		padPieceName = {"land1", "land2", "land3", "land4"}
	},
	[UnitDefNames["shipcarrier"].id] = {
		padPieceName = {"LandingFore1", "LandingFore2", "LandingFore3" ,"LandingFore4", "LandingAft1", "LandingAft2", "LandingAft3", "LandingAft4"},
		dronesOnly = true,
	},
}

for unitDefID, config in pairs(airpadDefs) do
    local ud = UnitDefs[unitDefID]

    config.mobile = (not ud.isImmobile)
    config.cap = tonumber(ud.customParams.pad_count)
end

return airpadDefs
