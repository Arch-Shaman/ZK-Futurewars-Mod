local nanoPieces = { 1 }

function script.Create()
	Spring.SetUnitNanoPieces(unitID, nanoPieces)
end

function script.QueryBuildInfo ()
	return 1
end

function script.Killed(recentDamage, maxHealth)
	return 0
end
