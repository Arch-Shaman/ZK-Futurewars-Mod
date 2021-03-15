local sweepfireDefs = {}
local minelayerdefs = {}

for i = 1, #UnitDefs do
	local unitdef = UnitDefs[i]
	local num = 0
	for w = 1, #unitdef.weapons do
		local weapon = WeaponDefs[unitdef.weapons[w].weaponDef]
		local cp = weapon.customParams
		local lowest = math.huge
		if cp.sweepfire_minelayer or cp.sweepfire then
			if sweepfireDefs[i] == nil then
				sweepfireDefs[i] = {}
			end
			sweepfireDefs[i][num + 1] = {
				minelayer = cp.sweepfire_minelayer ~= nil,
				step = math.rad(tonumber(cp.sweepfire_step) or 15),
				maxangle = math.rad(tonumber(cp.sweepfire_maxangle) or 45),
				weaponNum = w,
				fastupdate = cp.sweepfire_fastupdate ~= nil,
				maxrangemult = tonumber(cp.sweepfire_maxrangemult) or 1,
				centerreadjust = cp.sweepfire_headingadjust ~= nil,
			}
			num = num + 1
		end
		if cp.sweepfire_minelayer then
			minelayerdefs[i] = true
		end
	end
end

return sweepfireDefs, minelayerdefs
