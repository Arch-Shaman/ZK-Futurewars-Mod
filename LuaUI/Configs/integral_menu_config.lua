local buildCmdFactory, buildCmdEconomy, buildCmdDefence, buildCmdSpecial, buildCmdUnits, cmdPosDef, factoryUnitPosDef = include("Configs/integral_menu_commands_processed.lua", nil, VFS.RAW_FIRST)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tooltips

local imageDir = 'LuaUI/Images/commands/'

local _, ammoCMDS = VFS.Include("LuaRules/Configs/ammostateinfo.lua")
local SUC = Spring.Utilities.CMD

local tooltips = {
	WANT_ONOFF = "Activation (_STATE_)\n  Toggles unit abilities such as radar, shield charge, and radar jamming.",
	UNIT_AI = "Unit AI (_STATE_)\n  Move intelligently in combat.",
	FIRE_AT_SHIELD = "Fire at Shields (_STATE_)\n  Shoot at the shields of Thugs, Felons and Convicts when nothing else is in range.",
	FIRE_TOWARDS_ENEMY = "Fire Towards Enemies (_STATE_)\n  Shoot towards enemies when there are no other targets.",
	REPEAT = "Repeat (_STATE_)\n  Loop factory construction, or the command queue for units.",
	WANT_CLOAK = "Cloak (_STATE_)\n  Turn invisible. Disrupted by damage, firing, abilities, and nearby enemies.",
	CLOAK_SHIELD = "Area Cloaker (_STATE_)\n  Cloak all friendly units in the area. Does not apply to structures or shield bearers.",
	PRIORITY = "Construction Priority (_STATE_)\n  Higher priority construction takes resources before lower priorities.",
	MISC_PRIORITY = "Misc. Priority (_STATE_)\n  Priority for other resource use, such as morph, stockpile and radar.",
	FACTORY_GUARD = "Auto Assist (_STATE_)\n  Newly built constructors stay to assist and boost production.",
	AUTO_CALL_TRANSPORT = "Call Transports (_STATE_)\n  Automatically call transports between constructor tasks.",
	GLOBAL_BUILD = "Global Build Command (_STATE_)\n  Sets constructors to execute global build orders.",
	MOVE_STATE = "Hold Position (_STATE_)\n  Prevent units from moving when idle. States are persistent and togglable.",
	FIRE_STATE = "Hold Fire (_STATE_)\n  Prevent units from firing unless a direct command or target is set.",
	RETREAT = "Retreat (_STATE_)\n  Retreat to the closest Airpad or Retreat Zone (placed via the top left of the screen). Right click to disable.",
	RETREATSHIELD = "Retreat (_STATE_)\n  Retreat to the closest Airpad or Retreat Zone (placed via the top left of the screen) when shield is below a threshold. Right click to disable.",
	AUTOJUMP = "Current Stance: _STATE_\n Allows the unit to use its jump to prevent fall damage, close into enemies, or avoid enemy units.",
	IDLEMODE = "Air Idle State (_STATE_)\n  Set whether aircraft land when idle.",
	AP_FLY_STATE = "Air Factory Idle State (_STATE_)\n  Set whether produced aircraft land when idle.",
	UNIT_BOMBER_DIVE_STATE = "Bomber Dive State (_STATE_)\n  Set when Ravens dive.",
	UNIT_KILL_SUBORDINATES = "Kill Captured (_STATE_)\n  Set whether to kill captured units.",
	GOO_GATHER = "Puppy Replication (_STATE_)\n  Set whether Puppies use nearby wrecks to make more Puppies.",
	DISABLE_ATTACK = "Allow Attack Commands (_STATE_)\n  Set whether the unit responds to attack commands.",
	PUSH_PULL = "Impulse Mode (_STATE_)\n  Set whether gravity guns push or pull.",
	DONT_FIRE_AT_RADAR = "Fire At Radar State (_STATE_)\n  Set whether precise units with high reload time fire at radar dots.",
	PREVENT_BAIT = "Avoid Bad Targets (_STATE_)\n  _DESC_",
	PREVENT_OVERKILL = "Overkill Prevention (_STATE_)\n  Prevents units from shooting at already doomed enemies.",
	TRAJECTORY = "Trajectory (_STATE_)\n  Set whether units fire at a high or low arc.",
	AIR_STRAFE = "Gunship Strafe (_STATE_)\n  Set whether gunships strafe when fighting.",
	UNIT_FLOAT_STATE = "Float State (_STATE_)\n  Set when certain amphibious units float to the surface.",
	SELECTION_RANK = "Selection Rank (_STATE_)\n  Priority for selection filtering.",
	FORMATION_RANK = "Formation Rank (_STATE_)\n  set rank in formation.",
	TOGGLE_DRONES = "Drone Construction (_STATE_)\n  Toggle drone creation.",
	OVERRECLAIM = "Overreclaim Prevention (_STATE_)\nBlocks constructors from reclaiming when storage is nearly full.",
	FIRECYCLE = "Spread napalm (_STATE_)\nSets whether this unit should prioritize spreading burning status.",
	ARMORSTATE = "Hunker (_STATE_)\n Hunker down to reduce damage but lose access to weapons.",
	AMMOSTATE = "Selected Ammo: _STATE_\n_DESCRIPTION_",
	QUEUEMODE = "Rally Point Edit Mode: _STATE_\nThis controls whether or not the commands will be used for rally point or for unit control.",
	AUTOEXPAND = "Automatic Expansion: _STATE_\nConstructor will seek out new expansion and balance energy demand (with a 9 energy buffer).",
}

local tooltipsAlternate = {
	MOVE_STATE = "Move State (_STATE_)\n  Sets how far out of its way a unit will move to attack enemies.",
	FIRE_STATE = "Fire State (_STATE_)\n  Sets when a unit will automatically shoot.",
}

local commandDisplayConfig = {
	[CMD.ATTACK] = { texture = imageDir .. 'Bold/attack.png', tooltip = "Force Fire: Shoot at a particular target. Units will move to find a clear shot."},
	[CMD.STOP] = { texture = imageDir .. 'Bold/cancel.png', tooltip = "Stop: Halt the unit and clear its command queue."},
	[CMD.FIGHT] = { texture = imageDir .. 'Bold/fight.png', tooltip = "Attack Move: Move to a position engaging targets along the way."},
	[CMD.GUARD] = { texture = imageDir .. 'Bold/guard.png'},
	[CMD.MOVE] = { texture = imageDir .. 'Bold/move.png'},
	[SUC.RAW_MOVE] = { texture = imageDir .. 'Bold/move.png'},
	[CMD.PATROL] = { texture = imageDir .. 'Bold/patrol.png', tooltip = "Patrol: Attack Move back and forth between one or more waypoints."},
	[CMD.WAIT] = { texture = imageDir .. 'Bold/wait.png', tooltip = "Wait: Pause the units command queue and have it hold its current position."},
	[SUC.SUBMUNITION_TARGET] = { texture = imageDir .. 'Bold/nuke.png', tooltip = "Set Submunition Target: Adds a payload target at the selected position. Payloads without a target will be targeted at a random nearby location (Issue on exsiting target to cancel target)"},
	[CMD.REPAIR] = {texture = imageDir .. 'Bold/repair.png', tooltip = "Repair: Assist construction or repair a unit. Click and drag for area repair."},
	[CMD.RECLAIM] = {texture = imageDir .. 'Bold/reclaim.png', tooltip = "Reclaim: Take resources from a wreck. Click and drag for area reclaim."},
	[CMD.RESURRECT] = {texture = imageDir .. 'Bold/resurrect.png', tooltip = "Resurrect: Spend energy to turn a wreck into a unit."},
	[SUC.BUILD] = {texture = imageDir .. 'Bold/build.png'},
	[CMD.MANUALFIRE] = { texture = imageDir .. 'Bold/dgun.png', tooltip = "Fire Special Weapon: Fire the unit's special weapon."},
	[SUC.AIR_MANUALFIRE] = { texture = imageDir .. 'Bold/dgun.png', tooltip = "Fire Special Weapon: Fire the unit's special weapon."},
	[CMD.STOCKPILE] = {tooltip = "Stockpile: Queue missile production. Right click to reduce the queue."},

	[CMD.LOAD_UNITS] = { texture = imageDir .. 'Bold/load.png', tooltip = "Load: Pick up a unit. Click and drag to load unit in an area."},
	[CMD.UNLOAD_UNITS] = { texture = imageDir .. 'Bold/unload.png', tooltip = "Unload: Set down a carried unit. Click and drag to unload in an area."},
	[CMD.AREA_ATTACK] = { texture = imageDir .. 'Bold/areaattack.png', tooltip = "Area Attack: Indiscriminately bomb the terrain in an area."},
	[SUC.BUILD_PLATE] = {texture = imageDir .. 'Bold/buildplate.png', tooltip = "Build Plate: Place near a factory for an extra production queue."},

	[SUC.RAMP] = {texture = imageDir .. 'ramp.png'},
	[SUC.LEVEL] = {texture = imageDir .. 'level.png'},
	[SUC.RAISE] = {texture = imageDir .. 'raise.png'},
	[SUC.SMOOTH] = {texture = imageDir .. 'smooth.png'},
	[SUC.RESTORE] = {texture = imageDir .. 'restore.png'},
	[SUC.BUMPY] = {texture = imageDir .. 'bumpy.png'},

	[SUC.AREA_GUARD] = { texture = imageDir .. 'Bold/guard.png', tooltip = "Guard: Protect the target and assist its production."},

	[SUC.AREA_MEX] = {texture = imageDir .. 'Bold/mex.png'},
	[SUC.AREA_TERRA_MEX] = {texture = imageDir .. 'Bold/mex.png'},

	[SUC.JUMP] = {texture = imageDir .. 'Bold/jump.png'},

	[SUC.FIND_PAD] = {texture = imageDir .. 'Bold/rearm.png', tooltip = "Resupply: Return to nearest Airpad for repairs and, for bombers, ammo."},
	
	[SUC.SWEEPFIRE] = {texture = imageDir .. 'sweepfire.png', tooltip = "Sweepfire: Sets a direction for sweeping an area with attack commands."},
	[SUC.SWEEPFIRE_MINES] = {texture = imageDir .. 'sweepfire.png', tooltip = "Lay Mines: Sets a direction for randomly laying mines in."},
	[SUC.SWEEPFIRE_CANCEL] = {texture = imageDir .. 'sweepfire_cancel.png', tooltip = "Clear Sweepfire: Clears the sweepfire command for this unit."},
	[SUC.GREYGOO] = {texture = imageDir .. 'Bold/GreyGoo.png', tooltip = "Reclaim (Grey Goo): Consumes wreck(s) in an area (or a single wreck)."},
	[SUC.EXCLUDE_PAD] = {texture = imageDir .. 'Bold/excludeairpad.png', tooltip = "Exclude Airpad: Toggle whether any of your aircraft use the targeted airpad."},
	[SUC.FIELD_FAC_SELECT] = {texture = imageDir .. 'Bold/fac_select.png', tooltip = "Copy Factory Blueprint: Copy a production option from target functional friendly factory."},
	[SUC.IMMEDIATETAKEOFF] = {texture = imageDir .. 'takeoff.png', tooltip = "Abort Landing\nImmediately take off from airpads or abort landing."},
	[SUC.EMBARK] = {texture = imageDir .. 'Bold/embark.png'},
	[SUC.DISEMBARK] = {texture = imageDir .. 'Bold/disembark.png'},

	[SUC.ONECLICK_WEAPON] = {},--texture = imageDir .. 'Bold/action.png'},
	[SUC.UNIT_SET_TARGET_CIRCLE] = {texture = imageDir .. 'Bold/settarget.png'},
	[SUC.UNIT_CANCEL_TARGET] = {texture = imageDir .. 'Bold/canceltarget.png'},

	[SUC.ABANDON_PW] = {texture = imageDir .. 'Bold/drop_beacon.png'},

	[SUC.PLACE_BEACON] = {texture = imageDir .. 'Bold/drop_beacon.png'},
	[SUC.UPGRADE_STOP] = { texture = imageDir .. 'Bold/cancelupgrade.png'},
	[SUC.STOP_PRODUCTION] = { texture = imageDir .. 'Bold/stopbuild.png'},
	[SUC.GBCANCEL] = { texture = imageDir .. 'Bold/stopbuild.png'},

	[SUC.RECALL_DRONES] = {texture = imageDir .. 'Bold/recall_drones.png'},
	[SUC.DRONE_SET_TARGET] = { texture = imageDir .. 'Bold/dronesettarget.png'},

	-- states
	[SUC.WANT_ONOFF] = {
		texture = {imageDir .. 'states/off.png', imageDir .. 'states/on.png'},
		stateTooltip = {tooltips.WANT_ONOFF:gsub("_STATE_", "Off"), tooltips.WANT_ONOFF:gsub("_STATE_", "On")}
	},
	[SUC.UNIT_AI] = {
		texture = {imageDir .. 'states/bulb_off.png', imageDir .. 'states/bulb_on.png'},
		stateTooltip = {tooltips.UNIT_AI:gsub("_STATE_", "Disabled"), tooltips.UNIT_AI:gsub("_STATE_", "Enabled")},
	},
	[SUC.FIRE_TOWARDS_ENEMY] = {
		texture = {imageDir .. 'states/shoot_towards_off.png', imageDir .. 'states/shoot_towards_on.png'},
		stateTooltip = {tooltips.FIRE_TOWARDS_ENEMY:gsub("_STATE_", "Disabled"), tooltips.FIRE_TOWARDS_ENEMY:gsub("_STATE_", "Enabled")},
	},
	[SUC.FIRE_AT_SHIELD] = {
		texture = {imageDir .. 'states/ward_off.png', imageDir .. 'states/ward_on.png'},
		stateTooltip = {tooltips.FIRE_AT_SHIELD:gsub("_STATE_", "Disabled"), tooltips.FIRE_AT_SHIELD:gsub("_STATE_", "Enabled")},
	},
	[CMD.REPEAT] = {
		texture = {imageDir .. 'states/repeat_off.png', imageDir .. 'states/repeat_on.png'},
		stateTooltip = {tooltips.REPEAT:gsub("_STATE_", "Disabled"), tooltips.REPEAT:gsub("_STATE_", "Enabled")}
	},
	[SUC.WANT_CLOAK] = {
		texture = {imageDir .. 'states/cloak_off.png', imageDir .. 'states/cloak_on.png'},
		stateTooltip = {tooltips.WANT_CLOAK:gsub("_STATE_", "Disabled"), tooltips.WANT_CLOAK:gsub("_STATE_", "Enabled")}
	},
	[SUC.CLOAK_SHIELD] = {
		texture = {imageDir .. 'states/areacloak_off.png', imageDir .. 'states/areacloak_on.png'},
		stateTooltip = {tooltips.CLOAK_SHIELD:gsub("_STATE_", "Disabled"), tooltips.CLOAK_SHIELD:gsub("_STATE_", "Enabled")}
	},
	[SUC.PRIORITY] = {
		texture = {imageDir .. 'states/wrench_low.png', imageDir .. 'states/wrench_med.png', imageDir .. 'states/wrench_high.png'},
		stateTooltip = {
			tooltips.PRIORITY:gsub("_STATE_", "Low"),
			tooltips.PRIORITY:gsub("_STATE_", "Normal"),
			tooltips.PRIORITY:gsub("_STATE_", "High")
		}
	},
	[SUC.OVERRECLAIM] = {
		texture = {imageDir .. 'states/goo_off.png', imageDir .. 'states/goo_cloak.png'},
		stateTooltip = {
			tooltips.OVERRECLAIM:gsub("_STATE_", "Enabled"),
			tooltips.OVERRECLAIM:gsub("_STATE_", "Disabled"),
		}
	},
	[SUC.FIRECYCLE] = {
		texture = {imageDir .. 'states/firecycle_off.png', imageDir .. 'states/firecycle_on.png'},
		stateTooltip = {
			tooltips.FIRECYCLE:gsub("_STATE_", "Disabled"),
			tooltips.FIRECYCLE:gsub("_STATE_", "Enabled"),
		}
	},
	[SUC.AUTOEXPAND] = {
		texture = {imageDir .. 'states/autoexpand_off.png', imageDir .. 'states/autoexpand_on.png'},
		stateTooltip = {
			tooltips.AUTOEXPAND:gsub("_STATE_", "Disabled"),
			tooltips.AUTOEXPAND:gsub("_STATE_", "Enabled"),
		},
	},
	[SUC.MISC_PRIORITY] = {
		texture = {imageDir .. 'states/wrench_low_other.png', imageDir .. 'states/wrench_med_other.png', imageDir .. 'states/wrench_high_other.png'},
		stateTooltip = {
			tooltips.MISC_PRIORITY:gsub("_STATE_", "Low"),
			tooltips.MISC_PRIORITY:gsub("_STATE_", "Normal"),
			tooltips.MISC_PRIORITY:gsub("_STATE_", "High")
		}
	},
	[SUC.FACTORY_GUARD] = {
		texture = {imageDir .. 'states/autoassist_off.png',
		imageDir .. 'states/autoassist_on.png'},
		stateTooltip = {tooltips.FACTORY_GUARD:gsub("_STATE_", "Disabled"), tooltips.FACTORY_GUARD:gsub("_STATE_", "Enabled")}
	},
	[SUC.AUTO_CALL_TRANSPORT] = {
		texture = {imageDir .. 'states/auto_call_off.png', imageDir .. 'states/auto_call_on.png'},
		stateTooltip = {tooltips.AUTO_CALL_TRANSPORT:gsub("_STATE_", "Disabled"), tooltips.AUTO_CALL_TRANSPORT:gsub("_STATE_", "Enabled")}
	},
	[SUC.GLOBAL_BUILD] = {
		texture = {imageDir .. 'Bold/buildgrey.png', imageDir .. 'Bold/build_light.png'},
		stateTooltip = {tooltips.GLOBAL_BUILD:gsub("_STATE_", "Disabled"), tooltips.GLOBAL_BUILD:gsub("_STATE_", "Enabled")}
	},
	[CMD.MOVE_STATE] = {
		texture = {imageDir .. 'states/move_hold.png', imageDir .. 'states/move_engage.png', imageDir .. 'states/move_roam.png'},
		stateTooltip = {
			tooltips.MOVE_STATE:gsub("_STATE_", "Enabled"),
			tooltips.MOVE_STATE:gsub("_STATE_", "Disabled"),
			tooltips.MOVE_STATE:gsub("_STATE_", "Roam")
		},
		stateNameOverride = {"Enabled", "Disabled", "Roam (not in toggle)"},
		altConfig = {
			texture = {imageDir .. 'states/move_hold.png', imageDir .. 'states/move_engage.png', imageDir .. 'states/move_roam.png'},
			stateTooltip = {
				tooltipsAlternate.MOVE_STATE:gsub("_STATE_", "Hold Position"),
				tooltipsAlternate.MOVE_STATE:gsub("_STATE_", "Maneuver"),
				tooltipsAlternate.MOVE_STATE:gsub("_STATE_", "Roam")
			},
		}
	},
	[CMD.FIRE_STATE] = {
		texture = {imageDir .. 'states/fire_hold.png', imageDir .. 'states/fire_return.png', imageDir .. 'states/fire_atwill.png'},
		stateTooltip = {
			tooltips.FIRE_STATE:gsub("_STATE_", "Enabled"),
			tooltips.FIRE_STATE:gsub("_STATE_", "Return Fire"),
			tooltips.FIRE_STATE:gsub("_STATE_", "Disabled")
		},
		stateNameOverride = {"Enabled", "Return Fire (not in toggle)", "Disabled"},
		altConfig = {
			texture = {imageDir .. 'states/fire_hold.png', imageDir .. 'states/fire_return.png', imageDir .. 'states/fire_atwill.png'},
			stateTooltip = {
				tooltipsAlternate.FIRE_STATE:gsub("_STATE_", "Hold Fire"),
				tooltipsAlternate.FIRE_STATE:gsub("_STATE_", "Return Fire"),
				tooltipsAlternate.FIRE_STATE:gsub("_STATE_", "Fire At Will")
			},
		}
	},
	[SUC.PREVENT_BAIT] = {
		texture = {
			imageDir .. 'states/bait_off_alternate.png',
			imageDir .. 'states/bait_1.png',
			imageDir .. 'states/bait_2.png',
			imageDir .. 'states/bait_3.png',
			imageDir .. 'states/bait_4.png',
		},
		stateTooltip = {
			tooltips.PREVENT_BAIT:gsub("_STATE_", "Disabled"):gsub("_DESC_", "Enable this to ignore bad targets when not on Force Fire or Attack Move."),
			tooltips.PREVENT_BAIT:gsub("_STATE_", "Free"):gsub("_DESC_", "Avoid light drones, Wind, Solar, Claw, Dirtbag and armoured targets."),
			tooltips.PREVENT_BAIT:gsub("_STATE_", "Light"):gsub("_DESC_", "Avoid cost under 90, Razor, Sparrow, unknown radar and armour."),
			tooltips.PREVENT_BAIT:gsub("_STATE_", "Medium"):gsub("_DESC_", "Avoid cost under 240, minus Stardust, Raptor, unknown radar and armour."),
			tooltips.PREVENT_BAIT:gsub("_STATE_", "Heavy"):gsub("_DESC_", "Avoid cost under 420, unknown radar dots and armour."),
		}
	},
	[SUC.RETREAT] = {
		texture = {imageDir .. 'states/retreat_off.png', imageDir .. 'states/retreat_30.png', imageDir .. 'states/retreat_60.png', imageDir .. 'states/retreat_90.png'},
		stateTooltip = {
			tooltips.RETREAT:gsub("_STATE_", "Disabled"),
			tooltips.RETREAT:gsub("_STATE_", "30%% Health"),
			tooltips.RETREAT:gsub("_STATE_", "65%% Health"),
			tooltips.RETREAT:gsub("_STATE_", "99%% Health")
		}
	},
	[SUC.RETREATSHIELD] = {
		texture = {imageDir .. 'states/shield_off.png', imageDir .. 'states/shield_30.png', imageDir .. 'states/shield_50.png', imageDir .. 'states/shield_80.png'},
		stateTooltip = {
			tooltips.RETREATSHIELD:gsub("_STATE_", "Disabled"),
			tooltips.RETREATSHIELD:gsub("_STATE_", "30%% Shield"),
			tooltips.RETREATSHIELD:gsub("_STATE_", "50%% Shield"),
			tooltips.RETREATSHIELD:gsub("_STATE_", "80%% Shield")
		}
	},
	[SUC.AUTOJUMP] = {
		texture = {imageDir .. 'states/autojumpoff.png', imageDir .. 'states/autojumpon.png',},
		stateTooltip = {
			tooltips.AUTOJUMP:gsub("_STATE_", "Manual Jump Only"),
			tooltips.AUTOJUMP:gsub("_STATE_", "Up to Unit"),
		}
	},
	[CMD.IDLEMODE] = {
		texture = {imageDir .. 'states/fly_on.png', imageDir .. 'states/fly_off.png'},
		stateTooltip = {tooltips.IDLEMODE:gsub("_STATE_", "Fly"), tooltips.IDLEMODE:gsub("_STATE_", "Land")}
	},
	[SUC.AP_FLY_STATE] = {
		texture = {imageDir .. 'states/fly_on.png', imageDir .. 'states/fly_off.png'},
		stateTooltip = {tooltips.AP_FLY_STATE:gsub("_STATE_", "Fly"), tooltips.AP_FLY_STATE:gsub("_STATE_", "Land")}
	},
	[SUC.UNIT_BOMBER_DIVE_STATE] = {
		texture = {imageDir .. 'states/divebomb_off.png', imageDir .. 'states/divebomb_shield.png', imageDir .. 'states/divebomb_attack.png', imageDir .. 'states/divebomb_always.png'},
		stateTooltip = {
			tooltips.UNIT_BOMBER_DIVE_STATE:gsub("_STATE_", "Always Fly High"),
			tooltips.UNIT_BOMBER_DIVE_STATE:gsub("_STATE_", "Against Shields and Units"),
			tooltips.UNIT_BOMBER_DIVE_STATE:gsub("_STATE_", "Against Units"),
			tooltips.UNIT_BOMBER_DIVE_STATE:gsub("_STATE_", "Always Fly Low")
		}
	},
	[SUC.UNIT_KILL_SUBORDINATES] = {
		texture = {imageDir .. 'states/capturekill_off.png', imageDir .. 'states/capturekill_on.png'},
		stateTooltip = {tooltips.UNIT_KILL_SUBORDINATES:gsub("_STATE_", "Keep"), tooltips.UNIT_KILL_SUBORDINATES:gsub("_STATE_", "Kill")}
	},
	[SUC.GOO_GATHER] = {
		texture = {imageDir .. 'states/goo_off.png', imageDir .. 'states/goo_on.png', imageDir .. 'states/goo_cloak.png'},
		stateTooltip = {
			tooltips.GOO_GATHER:gsub("_STATE_", "Off"),
			tooltips.GOO_GATHER:gsub("_STATE_", "On except when cloaked"),
			tooltips.GOO_GATHER:gsub("_STATE_", "On always")
		}
	},
	[SUC.DISABLE_ATTACK] = {
		texture = {imageDir .. 'states/disableattack_off.png', imageDir .. 'states/disableattack_on.png'},
		stateTooltip = {tooltips.DISABLE_ATTACK:gsub("_STATE_", "Allowed"), tooltips.DISABLE_ATTACK:gsub("_STATE_", "Blocked")}
	},
	[SUC.ARMORSTATE] = {
		texture = {imageDir .. 'states/armor_off.png', imageDir .. 'states/armor_on.png'},
		stateTooltip = {tooltips.ARMORSTATE:gsub("_STATE_", "Off"), tooltips.ARMORSTATE:gsub("_STATE_", "On")}
	},
	[SUC.PUSH_PULL] = {
		texture = {imageDir .. 'states/pull_alt.png', imageDir .. 'states/push_alt.png'},
		stateTooltip = {tooltips.PUSH_PULL:gsub("_STATE_", "Pull"), tooltips.PUSH_PULL:gsub("_STATE_", "Push")}
	},
	[SUC.DONT_FIRE_AT_RADAR] = {
		texture = {imageDir .. 'states/stealth_on.png', imageDir .. 'states/stealth_off.png'},
		stateTooltip = {tooltips.DONT_FIRE_AT_RADAR:gsub("_STATE_", "Fire"), tooltips.DONT_FIRE_AT_RADAR:gsub("_STATE_", "Hold Fire")}
	},
	[SUC.PREVENT_OVERKILL] = {
		texture = {imageDir .. 'states/overkill_off.png', imageDir .. 'states/overkill_on.png'},
		stateTooltip = {tooltips.PREVENT_OVERKILL:gsub("_STATE_", "Disabled"), tooltips.PREVENT_OVERKILL:gsub("_STATE_", "Enabled")}
	},
	[CMD.TRAJECTORY] = {
		texture = {imageDir .. 'states/traj_low.png', imageDir .. 'states/traj_high.png'},
		stateTooltip = {tooltips.TRAJECTORY:gsub("_STATE_", "Low"), tooltips.TRAJECTORY:gsub("_STATE_", "High")}
	},
	[SUC.AIR_STRAFE] = {
		texture = {imageDir .. 'states/strafe_off.png', imageDir .. 'states/strafe_on.png'},
		stateTooltip = {tooltips.AIR_STRAFE:gsub("_STATE_", "No Strafe"), tooltips.AIR_STRAFE:gsub("_STATE_", "Strafe")}
	},
	[SUC.UNIT_FLOAT_STATE] = {
		texture = {imageDir .. 'states/amph_sink.png', imageDir .. 'states/amph_attack.png', imageDir .. 'states/amph_float.png'},
		stateTooltip = {
			tooltips.UNIT_FLOAT_STATE:gsub("_STATE_", "Never Float"),
			tooltips.UNIT_FLOAT_STATE:gsub("_STATE_", "Float To Fire"),
			tooltips.UNIT_FLOAT_STATE:gsub("_STATE_", "Always Float")
		}
	},
	[SUC.SELECTION_RANK] = {
		texture = {imageDir .. 'states/selection_rank_0.png', imageDir .. 'states/selection_rank_1.png', imageDir .. 'states/selection_rank_2.png', imageDir .. 'states/selection_rank_3.png'},
		stateTooltip = {
			tooltips.SELECTION_RANK:gsub("_STATE_", "0"),
			tooltips.SELECTION_RANK:gsub("_STATE_", "1"),
			tooltips.SELECTION_RANK:gsub("_STATE_", "2"),
			tooltips.SELECTION_RANK:gsub("_STATE_", "3")
		}
	},
	[SUC.FORMATION_RANK] = {
		texture = {imageDir .. 'states/formation_rank_0.png', imageDir .. 'states/formation_rank_1.png', imageDir .. 'states/formation_rank_2.png', imageDir .. 'states/formation_rank_3.png'},
		stateTooltip = {
			tooltips.FORMATION_RANK:gsub("_STATE_", "0"),
			tooltips.FORMATION_RANK:gsub("_STATE_", "1"),
			tooltips.FORMATION_RANK:gsub("_STATE_", "2"),
			tooltips.FORMATION_RANK:gsub("_STATE_", "3")
		}
	},
	[SUC.TOGGLE_DRONES] = {
		texture = {imageDir .. 'states/drones_off.png', imageDir .. 'states/drones_on.png'},
		stateTooltip = {
			tooltips.TOGGLE_DRONES:gsub("_STATE_", "Disabled"),
			tooltips.TOGGLE_DRONES:gsub("_STATE_", "Enabled"),
		}
	},
	[SUC.QUEUE_MODE] = {
		texture = {imageDir .. 'states/queueoff.png', imageDir .. 'states/queueon.png'},
		stateTooltip = {
			tooltips.QUEUEMODE:gsub("_STATE_", "Unit Command"),
			tooltips.QUEUEMODE:gsub("_STATE_", "Rally point"),
		},
	},
}

for id, data in pairs(ammoCMDS) do
	commandDisplayConfig[id] = {
		texture = {},
		stateTooltip = {},
	}
	for i = 1, #data.stateTooltip do
		commandDisplayConfig[id].stateTooltip[i] = tooltips.AMMOSTATE:gsub("_STATE_", data.stateTooltip[i]):gsub("_DESCRIPTION_", data.stateDesc[i])
		commandDisplayConfig[id].texture[i] = imageDir .. data.texture[i]
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Panel Configuration and Layout

local function CommandClickFunction(isInstantCommand, isStateCommand)
	local _,_, meta,_ = Spring.GetModKeyState()
	if not meta then
		return false
	end
	
	if isStateCommand then
		WG.crude.OpenPath("Hotkeys/Commands/State")
	elseif isInstantCommand then
		WG.crude.OpenPath("Hotkeys/Commands/Instant")
	else
		WG.crude.OpenPath("Hotkeys/Commands/Targeted")
	end
	WG.crude.ShowMenu() --make epic Chili menu appear.
	return true
end

local textConfig = {
	bottomLeft = {
		name = "bottomLeft",
		x = "15%",
		right = 0,
		bottom = 2,
		height = 12,
		fontsize = 12,
	},
	topLeft = {
		name = "topLeft",
		x = "12%",
		y = "11%",
		fontsize = 12,
	},
	bottomRightLarge = {
		name = "bottomRightLarge",
		right = "14%",
		bottom = "16%",
		fontsize = 14,
	},
	queue = {
		name = "queue",
		right = "18%",
		bottom = "14%",
		align = "right",
		fontsize = 16,
		height = 16,
	},
}

local buttonLayoutConfig = {
	command = {
		image = {
			x = "7%",
			y = "7%",
			right = "7%",
			bottom = "7%",
			keepAspect = true,
		},
		ClickFunction = CommandClickFunction,
	},
	build = {
		image = {
			x = "5%",
			y = "4%",
			right = "5%",
			bottom = 12,
			keepAspect = false,
		},
		tooltipPrefix = "Build",
		showCost = true
	},
	buildunit = {
		image = {
			x = "5%",
			y = "4%",
			right = "5%",
			bottom = 12,
			keepAspect = false,
		},
		tooltipPrefix = "BuildUnit",
		showCost = true
	},
	queue = {
		image = {
			x = "5%",
			y = "5%",
			right = "5%",
			height = "90%",
			keepAspect = false,
		},
		showCost = false,
		queueButton = true,
		tooltipOverride = "\255\1\255\1Left/Right click \255\255\255\255: Add to/subtract from queue\n\255\1\255\1Hold Left mouse \255\255\255\255: Drag to a different position in queue",
		dragAndDrop = true,
	},
	queueWithDots = {
		image = {
			x = "5%",
			y = "5%",
			right = "5%",
			height = "90%",
			keepAspect = false,
		},
		caption = "...",
		showCost = false,
		queueButton = true,
		-- "\255\1\255\1Hold Left mouse \255\255\255\255: drag drop to different factory or position in queue\n"
		tooltipOverride = "\255\1\255\1Left/Right click \255\255\255\255: Add to/subtract from queue\n\255\1\255\1Hold Left mouse \255\255\255\255: Drag to a different position in queue",
		dragAndDrop = true,
		dotDotOnOverflow = true,
	}
}

local specialButtonLayoutOverride = {}
for i = 1, 5 do
	specialButtonLayoutOverride[i] = {
		[3] = {
			buttonLayoutConfig = buttonLayoutConfig.command,
			isStructure = false,
		}
	}
end

local commandPanels = {
	{
		humanName = "Orders",
		name = "orders",
		inclusionFunction = function(cmdID)
			return cmdID >= 0 and not buildCmdSpecial[cmdID] -- Terraform
		end,
		loiterable = true,
		buttonLayoutConfig = buttonLayoutConfig.command,
	},
	{
		humanName = "Econ",
		name = "economy",
		inclusionFunction = function(cmdID)
			local position = buildCmdEconomy[cmdID]
			return position and true or false, position
		end,
		isBuild = true,
		isStructure = true,
		gridHotkeys = true,
		returnOnClick = "orders",
		optionName = "tab_economy",
		buttonLayoutConfig = buttonLayoutConfig.build,
	},
	{
		humanName = "Defence",
		name = "defence",
		inclusionFunction = function(cmdID)
			local position = buildCmdDefence[cmdID]
			return position and true or false, position
		end,
		isBuild = true,
		isStructure = true,
		gridHotkeys = true,
		returnOnClick = "orders",
		optionName = "tab_defence",
		buttonLayoutConfig = buttonLayoutConfig.build,
	},
	{
		humanName = "Special",
		name = "special",
		inclusionFunction = function(cmdID)
			local position = buildCmdSpecial[cmdID]
			return position and true or false, position
		end,
		isBuild = true,
		isStructure = true,
		notBuildRow = 3,
		gridHotkeys = true,
		returnOnClick = "orders",
		optionName = "tab_special",
		buttonLayoutConfig = buttonLayoutConfig.build,
		buttonLayoutOverride = specialButtonLayoutOverride,
	},
	{
		humanName = "Factory",
		name = "factory",
		inclusionFunction = function(cmdID)
			local position = buildCmdFactory[cmdID]
			return position and true or false, position
		end,
		isBuild = true,
		isStructure = true,
		gridHotkeys = true,
		returnOnClick = "orders",
		optionName = "tab_factory",
		buttonLayoutConfig = buttonLayoutConfig.build,
	},
	{
		humanName = "Units",
		name = "units_mobile",
		inclusionFunction = function(cmdID, factoryUnitDefID)
			return not factoryUnitDefID -- Only called if previous funcs don't
		end,
		isBuild = true,
		gridHotkeys = true,
		returnOnClick = "orders",
		optionName = "tab_units",
		buttonLayoutConfig = buttonLayoutConfig.build,
	},
	{
		humanName = "Units",
		name = "units_factory",
		inclusionFunction = function(cmdID, factoryUnitDefID)
			if not (factoryUnitDefID and buildCmdUnits[factoryUnitDefID]) then
				return false
			end
			local buildOptions = UnitDefs[factoryUnitDefID].buildOptions
			for i = 1, #buildOptions do
				if buildOptions[i] == -cmdID then
					local position = buildCmdUnits[factoryUnitDefID][cmdID]
					return position and true or false, position
				end
			end
			return false
		end,
		loiterable = true,
		factoryQueue = true,
		isBuild = true,
		hotkeyReplacement = "Orders",
		gridHotkeys = true,
		disableableKeys = true,
		buttonLayoutConfig = buttonLayoutConfig.buildunit,
	},
}

local commandPanelMap = {}
for i = 1, #commandPanels do
	commandPanelMap[commandPanels[i].name] = commandPanels[i]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Hidden Commands

local instantCommands = {
	[CMD.SELFD] = true,
	[CMD.STOP] = true,
	[CMD.WAIT] = true,
	[SUC.FIND_PAD] = true,
	[SUC.EMBARK] = true,
	[SUC.DISEMBARK] = true,
	[SUC.LOADUNITS_SELECTED] = true,
	[SUC.ONECLICK_WEAPON] = true,
	[SUC.UNIT_CANCEL_TARGET] = true,
	[SUC.STOP_NEWTON_FIREZONE] = true,
	[SUC.RECALL_DRONES] = true,
	[SUC.MORPH_UPGRADE_INTERNAL] = true,
	[SUC.UPGRADE_STOP] = true,
	[SUC.STOP_PRODUCTION] = true,
	[SUC.RESETFIRE] = true,
	[SUC.RESETMOVE] = true,
}

-- Commands that only exist in LuaUI cannot have a hidden param. Therefore those that should be hidden are placed in this table.
local widgetSpaceHidden = {
	[60] = true, -- CMD.PAGES
	[SUC.RETREAT_ZONE] = true,
	[SUC.SET_AI_START] = true,
	[SUC.CHEAT_GIVE] = true,
	[SUC.SET_FERRY] = true,
	[CMD.MOVE] = true,
}

local factoryPlates = {
	"platecloak",
	"plateshield",
	"plateveh",
	"platehover",
	"plategunship",
	"plateplane",
	"platespider",
	"platejump",
	"platetank",
	"plateamph",
	"plateship",
	"platestrider",
}

-- Hide factory plates
for i = 1, #factoryPlates do
	local plateDefID = UnitDefNames[factoryPlates[i]].id
	widgetSpaceHidden[-plateDefID] = true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return commandPanels, commandPanelMap, commandDisplayConfig, widgetSpaceHidden, textConfig, buttonLayoutConfig, instantCommands, cmdPosDef

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

