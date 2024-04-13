--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Order and State Panel Positions

-- Commands are placed in their position, with conflicts resolved by pushng those
-- with less priority (higher number = less priority) along the positions if 
-- two or more commands want the same position.
-- The command panel is propagated left to right, top to bottom.
-- The state panel is propagate top to bottom, right to left.
-- * States can use posSimple to set a different position when the panel is in
--   four-row mode.
-- * Missing commands have {pos = 1, priority = 100}

local SUC = Spring.Utilities.CMD

local cmdPosDef = {
	-- Commands
	[CMD.STOP]          = {pos = 1, priority = 1},
	[CMD.FIGHT]         = {pos = 1, priority = 2},
	[SUC.RAW_MOVE]      = {pos = 1, priority = 3},
	[CMD.PATROL]        = {pos = 1, priority = 4},
	[CMD.ATTACK]        = {pos = 1, priority = 5},
	[SUC.SUBMUNITION_TARGET] = {pos = 1, priority = 6},
	[SUC.JUMP]          = {pos = 1, priority = 6},
	[SUC.AREA_GUARD]    = {pos = 1, priority = 10},
	[CMD.AREA_ATTACK]   = {pos = 1, priority = 11},
	[SUC.SWEEPFIRE]     = {pos = 7, priority = 12},
	[SUC.SWEEPFIRE_CANCEL] = {pos = 8, priority = 12}, 
	
	[SUC.UPGRADE_UNIT]  = {pos = 7, priority = -8},
	[SUC.UPGRADE_STOP]  = {pos = 7, priority = -7},
	[SUC.MORPH]         = {pos = 7, priority = -6},
	
	[SUC.STOP_NEWTON_FIREZONE] = {pos = 7, priority = -4},
	[SUC.NEWTON_FIREZONE]      = {pos = 7, priority = -3},
	
	[CMD.MANUALFIRE]      = {pos = 7, priority = 0.1},
	[SUC.AIR_MANUALFIRE]  = {pos = 7, priority = 0.12},
	[SUC.PLACE_BEACON]    = {pos = 7, priority = 0.2},
	[SUC.ONECLICK_WEAPON] = {pos = 7, priority = 0.24},
	[CMD.STOCKPILE]       = {pos = 7, priority = 0.25},
	[SUC.ABANDON_PW]      = {pos = 7, priority = 0.3},
	[SUC.GBCANCEL]        = {pos = 7, priority = 0.4},
	[SUC.STOP_PRODUCTION] = {pos = 7, priority = 0.7},
	
	[SUC.BUILD]         = {pos = 7, priority = 0.8},
	[SUC.AREA_MEX]      = {pos = 7, priority = 1},
	[CMD.REPAIR]        = {pos = 7, priority = 2},
	[CMD.RECLAIM]       = {pos = 7, priority = 3},
	[SUC.GREYGOO]       = {pos = 7, priority = 3},
	[CMD.RESURRECT]     = {pos = 7, priority = 4},
	[CMD.WAIT]          = {pos = 7, priority = 5},
	[SUC.FIND_PAD]      = {pos = 7, priority = 6},
	
	[CMD.LOAD_UNITS]    = {pos = 7, priority = 7},
	[CMD.UNLOAD_UNITS]  = {pos = 7, priority = 8},
	[SUC.RECALL_DRONES] = {pos = 7, priority = 10},
	[SUC.DRONE_SET_TARGET] = {pos = 7, priority = 11},
	[SUC.SELECT_DRONES] = {pos = 7, priority = 12},
	
	[SUC.FIELD_FAC_SELECT]       = {pos = 13, priority = 0.6},
	[SUC.MISC_BUILD]             = {pos = 13, priority = 0.7},
	[SUC.AREA_TERRA_MEX]         = {pos = 13, priority = 1},
	[SUC.UNIT_SET_TARGET_CIRCLE] = {pos = 13, priority = 2},
	[SUC.UNIT_CANCEL_TARGET]     = {pos = 13, priority = 3},
	[SUC.EMBARK]                 = {pos = 13, priority = 5},
	[SUC.DISEMBARK]              = {pos = 13, priority = 6},
	[SUC.EXCLUDE_PAD]            = {pos = 13, priority = 7},
	[SUC.IMMEDIATETAKEOFF] = {pos = 13, priority = 8},
	-- States
	[CMD.REPEAT]           = {pos = 1, priority = 1},
	[SUC.RETREAT]          = {pos = 1, priority = 2},
	[SUC.RETREATSHIELD]    = {pos = 1, priority = 3},
	[SUC.OVERRECLAIM]      = {pos = 1, priority = 4},
	[CMD.MOVE_STATE]       = {pos = 6, posSimple = 5, priority = 1},
	[CMD.FIRE_STATE]       = {pos = 6, posSimple = 5, priority = 2},
	[SUC.FACTORY_GUARD]    = {pos = 6, posSimple = 5, priority = 3},
	[SUC.FIRECYCLE]        = {pos = 6, priority = 5},
	[SUC.AUTOJUMP]         = {pos = 1, priority = 5},
	[SUC.QUEUE_MODE]       = {pos = 1, priority = 5},
	[SUC.AIR_STRAFE]       = {pos = 1, priority = 99},
	
	[SUC.SELECTION_RANK]   = {pos = 6, posSimple = 1, priority = 1.5},
	
	[SUC.PRIORITY]         = {pos = 1, priority = 10},
	[SUC.MISC_PRIORITY]    = {pos = 1, priority = 11},
	[SUC.CLOAK_SHIELD]     = {pos = 1, priority = 11.5},
	[SUC.WANT_CLOAK]       = {pos = 1, priority = 11.6},
	[SUC.WANT_ONOFF]       = {pos = 1, priority = 13},
	[SUC.PREVENT_BAIT]     = {pos = 1, priority = 13.1},
	[SUC.PREVENT_OVERKILL] = {pos = 1, priority = 13.2},
	[SUC.FIRE_TOWARDS_ENEMY] = {pos = 1, priority = 13.25},
	[SUC.FIRE_AT_SHIELD]   = {pos = 1, priority = 13.3},
	[CMD.TRAJECTORY]       = {pos = 1, priority = 14},
	[SUC.UNIT_FLOAT_STATE] = {pos = 1, priority = 15},
	[SUC.TOGGLE_DRONES]    = {pos = 1, priority = 16},
	[SUC.PUSH_PULL]        = {pos = 1, priority = 17},
	[CMD.IDLEMODE]         = {pos = 1, priority = 18},
	[SUC.AP_FLY_STATE]     = {pos = 1, priority = 19},
	[SUC.ARMORSTATE]       = {pos = 1, priority = 20},
	[SUC.AUTO_CALL_TRANSPORT] = {pos = 1, priority = 21},
}

for _, id in pairs(extras) do
	cmdPosDef[id] = {pos = 1, priority = 15}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Factory Units Panel Positions

-- These positions must be distinct

-- Locally defined intermediate positions to cut down repetitions.
local unitTypes = {
	CONSTRUCTOR     = {order = 1, row = 1, col = 1},
	RAIDER          = {order = 2, row = 1, col = 2},
	SKIRMISHER      = {order = 3, row = 1, col = 3},
	RIOT            = {order = 4, row = 1, col = 4},
	ASSAULT         = {order = 5, row = 1, col = 5},
	ARTILLERY       = {order = 6, row = 1, col = 6},

	-- note: row 2 column 1 purposefully skipped, since
	-- that allows giving facs Attack orders via hotkey
	WEIRD_RAIDER    = {order = 7, row = 2, col = 2},
	ANTI_AIR        = {order = 8, row = 2, col = 3},
	HEAVY_SOMETHING = {order = 9, row = 2, col = 4},
	SPECIAL         = {order = 10, row = 2, col = 5},
	UTILITY         = {order = 11, row = 2, col = 6},
	SPECIAL2        = {order = 12, row = 3, col = 1},
}

local factoryUnitPosDef = {
	factorycomm = {
		dynsupport0 = unitTypes.CONSTRUCTOR,
		dynrecon0 = unitTypes.RAIDER,
		dynassault0 = unitTypes.SKIRMISHER,
		dynstrike0 = unitTypes.ASSAULT,
		dynriot0 = unitTypes.RIOT,
	},
	factorycloak = {
		cloakcon          = unitTypes.CONSTRUCTOR,
		cloakraid         = unitTypes.RAIDER,
		cloakheavyraid    = unitTypes.WEIRD_RAIDER,
		cloakriot         = unitTypes.RIOT,
		cloakskirm        = unitTypes.SKIRMISHER,
		cloakarty         = unitTypes.ARTILLERY,
		cloakaa           = unitTypes.ANTI_AIR,
		cloakassault      = unitTypes.ASSAULT,
		cloaksnipe        = unitTypes.HEAVY_SOMETHING,
		cloakbomb         = unitTypes.SPECIAL,
		cloakjammer       = unitTypes.UTILITY,
	},
	factoryshield = {
		shieldcon         = unitTypes.CONSTRUCTOR,
		shieldscout       = unitTypes.WEIRD_RAIDER,
		shieldraid        = unitTypes.RAIDER,
		shieldriot        = unitTypes.RIOT,
		shieldskirm       = unitTypes.SKIRMISHER,
		shieldarty        = unitTypes.ARTILLERY,
		shieldaa          = unitTypes.ANTI_AIR,
		shieldassault     = unitTypes.ASSAULT,
		shieldfelon       = unitTypes.HEAVY_SOMETHING,
		shieldbomb        = unitTypes.SPECIAL,
		shieldshield      = unitTypes.UTILITY,
	},
	factoryveh = {
		vehcon            = unitTypes.CONSTRUCTOR,
		vehscout          = unitTypes.WEIRD_RAIDER,
		vehraid           = unitTypes.RAIDER,
		vehriot           = unitTypes.RIOT,
		vehsupport        = unitTypes.SKIRMISHER, -- Not really but nowhere else to go
		veharty           = unitTypes.ARTILLERY,
		vehaa             = unitTypes.ANTI_AIR,
		vehassault        = unitTypes.ASSAULT,
		vehheavyarty      = unitTypes.HEAVY_SOMETHING,
		vehcapture        = unitTypes.SPECIAL,
	},
	factoryhover = {
		hovercon          = unitTypes.CONSTRUCTOR,
		hoverraid         = unitTypes.RAIDER,
		hoverheavyraid    = unitTypes.WEIRD_RAIDER,
		hoverdepthcharge  = unitTypes.SPECIAL,
		hoverriot         = unitTypes.RIOT,
		hoverskirm        = unitTypes.SKIRMISHER,
		hoverarty         = unitTypes.ARTILLERY,
		hoveraa           = unitTypes.ANTI_AIR,
		hoverassault      = unitTypes.ASSAULT,
	},
	factorygunship = {
		gunshipcon        = unitTypes.CONSTRUCTOR,
		gunshipemp        = unitTypes.WEIRD_RAIDER,
		gunshipraid       = unitTypes.RAIDER,
		gunshipheavyskirm = unitTypes.ARTILLERY,
		gunshipskirm      = unitTypes.SKIRMISHER,
		gunshiptrans      = unitTypes.SPECIAL,
		gunshipheavytrans = unitTypes.UTILITY,
		gunshipaa         = unitTypes.ANTI_AIR,
		gunshipassault    = unitTypes.ASSAULT,
		gunshipkrow       = unitTypes.HEAVY_SOMETHING,
		gunshipbomb       = unitTypes.RIOT,
	},
	factoryplane = {
		planecon          = unitTypes.CONSTRUCTOR,
		planefighter      = unitTypes.RAIDER,
		bomberriot        = unitTypes.RIOT,
		bomberstrike      = unitTypes.SKIRMISHER,
		-- No Plane Artillery
		planeheavyfighter = unitTypes.WEIRD_RAIDER,
		planescout        = unitTypes.UTILITY,
		planelightscout   = unitTypes.ARTILLERY,
		bomberprec        = unitTypes.ASSAULT,
		bomberheavy       = unitTypes.HEAVY_SOMETHING,
		bomberdisarm      = unitTypes.SPECIAL,
	},
	factoryspider = {
		spidercon         = unitTypes.CONSTRUCTOR,
		spiderscout       = unitTypes.RAIDER,
		spiderriot        = unitTypes.RIOT,
		spiderskirm       = unitTypes.SKIRMISHER,
		-- No Spider Artillery
		spideraa          = unitTypes.ANTI_AIR,
		spideremp         = unitTypes.WEIRD_RAIDER,
		spiderassault     = unitTypes.ASSAULT,
		spidercrabe       = unitTypes.HEAVY_SOMETHING,
		spiderantiheavy   = unitTypes.SPECIAL,
	},
	factoryjump = {
		jumpcon           = unitTypes.CONSTRUCTOR,
		jumpscout         = unitTypes.WEIRD_RAIDER,
		jumpraid          = unitTypes.RAIDER,
		jumpblackhole     = unitTypes.RIOT,
		jumpskirm         = unitTypes.SKIRMISHER,
		jumparty          = unitTypes.ARTILLERY,
		jumpaa            = unitTypes.ANTI_AIR,
		jumpassault       = unitTypes.ASSAULT,
		jumpsumo          = unitTypes.HEAVY_SOMETHING,
		jumpbomb          = unitTypes.SPECIAL,
	},
	factorytank = {
		tankcon           = unitTypes.CONSTRUCTOR,
		tankraid          = unitTypes.WEIRD_RAIDER,
		tankheavyraid     = unitTypes.RAIDER,
		tankriot          = unitTypes.RIOT,
		tankarty          = unitTypes.ARTILLERY,
		tankheavyarty     = unitTypes.UTILITY,
		tankaa            = unitTypes.ANTI_AIR,
		tankassault       = unitTypes.ASSAULT,
		tankheavyassault  = unitTypes.HEAVY_SOMETHING,
	},
	factoryamph = {
		amphcon           = unitTypes.CONSTRUCTOR,
		amphraid          = unitTypes.RAIDER,
		amphriot          = unitTypes.RIOT,
		amphskirm         = unitTypes.SKIRMISHER,
		amphfloater       = unitTypes.ASSAULT,
		amphsupport       = unitTypes.ARTILLERY,
		amphimpulse       = unitTypes.WEIRD_RAIDER,
		amphaa            = unitTypes.ANTI_AIR,
		amphassault       = unitTypes.HEAVY_SOMETHING,
		amphlaunch        = unitTypes.UTILITY,
		amphbomb          = unitTypes.SPECIAL,
		--amphtele          = unitTypes.SPECIAL2, -- TODO: Fix.
	},
	factoryship = {
		shipcon           = unitTypes.CONSTRUCTOR,
		shipriot          = unitTypes.RAIDER,
		shiptorpraider    = unitTypes.SKIRMISHER,
		shipassault       = unitTypes.RIOT,
		shiparty          = unitTypes.ASSAULT, 
		shipheavyarty     = unitTypes.ARTILLERY,
		shipscout         = unitTypes.WEIRD_RAIDER,
		shipaa            = unitTypes.ANTI_AIR,
		shipskirm         = unitTypes.HEAVY_SOMETHING,
		shiplightcarrier  = unitTypes.SPECIAL,
		shipcarrier	   = unitTypes.UTILITY,
	},
	pw_bomberfac = {
		bomberriot        = unitTypes.RIOT,
		bomberprec        = unitTypes.ASSAULT,
		bomberheavy       = unitTypes.HEAVY_SOMETHING,
		bomberdisarm      = unitTypes.SPECIAL,
	},
	pw_dropfac = {
		gunshiptrans      = unitTypes.SPECIAL,
		gunshipheavytrans = unitTypes.UTILITY,
	},
}

-- Factory plates copy their parents.
factoryUnitPosDef.platecloak   = Spring.Utilities.CopyTable(factoryUnitPosDef.factorycloak)
factoryUnitPosDef.plateshield  = Spring.Utilities.CopyTable(factoryUnitPosDef.factoryshield)
factoryUnitPosDef.plateveh     = Spring.Utilities.CopyTable(factoryUnitPosDef.factoryveh)
factoryUnitPosDef.platehover   = Spring.Utilities.CopyTable(factoryUnitPosDef.factoryhover)
factoryUnitPosDef.plategunship = Spring.Utilities.CopyTable(factoryUnitPosDef.factorygunship)
factoryUnitPosDef.plateplane   = Spring.Utilities.CopyTable(factoryUnitPosDef.factoryplane)
factoryUnitPosDef.platespider  = Spring.Utilities.CopyTable(factoryUnitPosDef.factoryspider)
factoryUnitPosDef.platejump    = Spring.Utilities.CopyTable(factoryUnitPosDef.factoryjump)
factoryUnitPosDef.platetank    = Spring.Utilities.CopyTable(factoryUnitPosDef.factorytank)
factoryUnitPosDef.plateamph    = Spring.Utilities.CopyTable(factoryUnitPosDef.factoryamph)
factoryUnitPosDef.plateship    = Spring.Utilities.CopyTable(factoryUnitPosDef.factoryship)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Construction Panel Structure Positions

-- These positions must be distinct

local factory_commands = {
	factorycloak      = {order = 1, row = 1, col = 1},
	factoryshield     = {order = 2, row = 1, col = 2},
	factoryveh        = {order = 3, row = 1, col = 3},
	factoryhover      = {order = 4, row = 1, col = 4},
	factorygunship    = {order = 5, row = 1, col = 5},
	factoryplane      = {order = 6, row = 1, col = 6},
	factoryspider     = {order = 7, row = 2, col = 1},
	factoryjump       = {order = 8, row = 2, col = 2},
	factorytank       = {order = 9, row = 2, col = 3},
	factoryamph       = {order = 10, row = 2, col = 4},
	factoryship       = {order = 11, row = 2, col = 5},
	striderhub        = {order = 12, row = 2, col = 6},
	factorycomm       = {order = 13, row = 3, col = 1},
	[SUC.BUILD_PLATE] = {order = 14, row = 3, col = 2},
}

local econ_commands = {
	staticmex         = {order = 1, row = 1, col = 1},
	staticenergyrtg   = {order = 2, row = 3, col = 1},
	energywind        = {order = 3, row = 2, col = 1},
	energysolar       = {order = 4, row = 2, col = 2},
	energygeo         = {order = 5, row = 2, col = 3},
	energyfusion      = {order = 6, row = 2, col = 4},
	energysingu       = {order = 7, row = 2, col = 5},
	energyprosperity  = {order = 8, row = 2, col = 6},
	--staticstorage     = {order = 8, row = 3, col = 1},
	energypylon       = {order = 9, row = 3, col = 2},
	staticcon         = {order = 10, row = 3, col = 3},
	staticrearm       = {order = 11, row = 3, col = 4},
}

local defense_commands = {
	turretlaser       = {order = 2, row = 1, col = 1},
	turretmissile     = {order = 1, row = 1, col = 2},
	turretriot        = {order = 2, row = 1, col = 3},
	turretemp         = {order = 3, row = 1, col = 4},
	turretgauss       = {order = 5, row = 1, col = 5},
	turretheavylaser  = {order = 6, row = 1, col = 6},
	
	turretaaclose     = {order = 9, row = 2, col = 1},
	turretaalaser     = {order = 10, row = 2, col = 2},
	turretaaflak      = {order = 11, row = 2, col = 3},
	turretaafar       = {order = 12, row = 2, col = 4},
	turretaaheavy     = {order = 13, row = 2, col = 5},

	turretimpulse     = {order = 4, row = 3, col = 1},
	turrettorp        = {order = 14, row = 3, col = 2},
	turretheavy       = {order = 16, row = 3, col = 3},
	turretantiheavy   = {order = 17, row = 3, col = 4},
	staticshield      = {order = 18, row = 3, col = 5},
	turretsunlance    = {order = 19, row = 3, col = 6},
}

local special_commands = {
	staticradar       = {order = 10, row = 1, col = 1},
	staticjammer      = {order = 12, row = 1, col = 2},
	turretdecloak	  = {order = 1, row = 1, col = 3},
	--staticheavyradar  = {order = 14, row = 1, col = 3},
	staticmissilesilo = {order = 15, row = 1, col = 4},
	staticantinuke    = {order = 16, row = 1, col = 5},
	staticheavyshield = {order = 17, row = 1, col = 6}, -- TODO: reorganize this.
	staticarty        = {order = 2, row = 2, col = 1},
	staticheavyarty   = {order = 3, row = 2, col = 2},
	staticnuke        = {order = 4, row = 2, col = 3},
	raveparty         = {order = 5, row = 2, col = 4},
	mahlazer          = {order = 6, row = 2, col = 5},
	zenith            = {order = 7, row = 2, col = 6},
	[SUC.RAMP]        = {order = 16, row = 3, col = 1},
	[SUC.LEVEL]       = {order = 17, row = 3, col = 2},
	[SUC.RAISE]       = {order = 18, row = 3, col = 3},
	[SUC.RESTORE]     = {order = 19, row = 3, col = 4},
	[SUC.SMOOTH]      = {order = 20, row = 3, col = 5},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return cmdPosDef, factoryUnitPosDef, factory_commands, econ_commands, defense_commands, special_commands

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
