local turretantiheavy = {
	unitname						= "turretantiheavy",
		name							= "Azimuth",
	description						= "Tachyonic Anti-Heavy Turret - Requires connection to a 225 energy grid",
	activateWhenBuilt				= true,
	buildCostMetal					= 3400,
	builder							= false,
	buildingGroundDecalDecaySpeed	= 30,
	buildingGroundDecalSizeX		= 6,
	buildingGroundDecalSizeY		= 6,
	buildingGroundDecalType			= "turretantiheavy_aoplane.dds",
	buildPic						= "turretantiheavy.png",
	category						= "SINK TURRET",
	collisionVolumeOffsets			= "0 0 0",
	--collisionVolumeScales			= "75 100 75",
	--collisionVolumeType			= "CylY",
	corpse							= "DEAD",
	customParams					= {
		keeptooltip    = "any string I want",
		neededlink     = 300,
		pylonrange     = 50,
		aimposoffset   = "0 32 0",
		midposoffset   = "0 0 0",
		modelradius    = "40",
		bait_level_default = 3,
		hasarmorstate = 1,
		armortype = 1, -- for context menu.
		--dontfireatradarcommand = '0',
	},
	damageModifier					= 0.2,
	explodeAs						= "ESTOR_BUILDING",
	footprintX						= 4,
	footprintZ						= 4,
	iconType						= "fixedtachyon",
	idleAutoHeal					= 5,
	idleTime						= 1800,
	losEmitHeight					= 65,
	health   						= 12000,
	maxSlope						= 18,
	maxWaterDepth					= 0,
	minCloakDistance				= 150,
	noChaseCategory					= "FIXEDWING LAND SHIP SWIM GUNSHIP SUB HOVER",
	objectName						= "arm_annihilator.s3o",
	radarDistance					= 2850,
	radarEmitHeight					= 100,
	script							= "turretantiheavy.lua",
	selfdestructas					= "ESTOR_BUILDING",
	sfxtypes						= {},
	sightDistance					= 560,
	useBuildingGroundDecal			= true,
	yardMap							= "oooo oooo oooo oooo",
	weapons							= {
		{
			def					= "ATA",
			onlyTargetCategory	= "SWIM LAND SHIP SINK TURRET FLOAT HOVER LOWFLYING",
		},
	},
	weaponDefs                    = {
		ATA = { -- changing the name causes an Vanilla gadget to become borked
			name					= "Tachyonic Feedback Loop",
			areaOfEffect			= 20,
			avoidFeature			= false,
			avoidNeutral			= false,
			beamTime				= 1/30, --llt has a rof of 10/s. domi has 30/s. 
			beamttl					= 6,
			coreThickness			= 0.5,
			craterBoost				= 0,
			craterMult				= 0,
			canattackground         = false,
			customParams			= {
				light_color = "1.6 1.05 2.25",
					light_radius = 320,
				stats_hide_damage = 1, -- continuous laser
				stats_hide_reload = 1,
				dmg_scaling = 1/30,
				dmg_scaling_max = 7,
				dmg_scaling_keeptime = 10,
				dmg_scaling_falloff = 10000,
				reload_override = 6,	
				ceg_d_override = 2,
				explosion_generator = "ataalasergrow",
			},
			damage					= {
				default = 10.1,
			},
			explosionGenerator		= "custom:ataalaser",
			fireTolerance			= 8192, -- 45 degrees
			impactOnly				= true,
			impulseBoost			= 0,
			impulseFactor			= 0,
			interceptedByShieldType	= 1, --maybe set back to 1?
			largeBeamLaser			= true,
			laserFlareSize			= 10,
			leadLimit				= 18,
			minIntensity			= 1,
			noSelfDamage			= true,
			range					= 1440,
			reloadtime				= 1/30,
			rgbColor				= "1 0.25 0",
			soundStart				= "weapon/laser/heavy_laser6",
			soundStartVolume		= 15,
			texture1				= "largelaser",
			texture2				= "flare",
			texture3				= "flare",
			texture4				= "smallflare",
			thickness				= 10,
			tolerance				= 10000,
			turret					= true,
			weaponType				= "BeamLaser",
			weaponVelocity			= 1400,
		},
	},
	featureDefs                   = {
		DEAD = {
			blocking		= true,
			featureDead		= "HEAP",
			footprintX		= 4,
			footprintZ		= 4,
			object			= "arm_annihilator_dead.s3o",
		},
			HEAP = {
			blocking		= false,
			footprintX		= 4,
			footprintZ		= 4,
			object			= "debris3x3a.s3o",
		},
	},
}
	

function Spring.Utilities.MergeWithDefault(default, override)
	local new = Spring.Utilities.CopyTable(default, true)
	for key, v in pairs(override) do
		-- key not used in default, assign it the value at same key in override
		if not new[key] and type(v) == "table" then
			new[key] = Spring.Utilities.CopyTable(v, true)
		-- values at key in both default and override are tables, merge those
		elseif type(new[key]) == "table" and type(v) == "table"  then
			new[key] = Spring.Utilities.MergeWithDefault(new[key], v)
		else
			new[key] = v
		end
	end
	return new
end

local i
for i=0, 60 do
	local mult = 1 + i / 10
	-- turretantiheavy.weapons[#turretantiheavy.weapons+1] = Spring.Utilities.MergeWithDefault(turretantiheavy.weapons[1], {
	-- 	def = "ATA_"..i,
	-- })
	turretantiheavy.weaponDefs["ATA_"..i] = Spring.Utilities.MergeWithDefault(turretantiheavy.weaponDefs.ATA, {
		customParams = {
			bogus = 1,
		},
		damage = {
			default = 20.1 * mult,
		},
		laserFlareSize = 10 / math.sqrt(mult),
		thickness = 10 * mult,
	})
end

return {turretantiheavy = turretantiheavy}
