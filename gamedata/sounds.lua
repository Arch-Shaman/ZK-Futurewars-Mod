-- see http://springrts.com/wiki/Sounds.lua for help
local maxdistance = 12000
local Sounds = {
	SoundItems = {
		default = {
		},
		IncomingChat = {
			--file = "sounds/talk.wav",
			file = nil,
		},
		--MultiSelect = {
		--   file = "sounds/button9.wav",
		--},
		MapPoint = {
			file = "sounds/beep4_decrackled.wav",
			maxconcurrent = 3,
		},
		--[[
		MyAwesomeSounds = {
			file = "sounds/booooom.wav",
			gain = 2.0, --- for uber-loudness
			pitch = 0.2, --- bass-test
			priority = 15, --- very high
			maxconcurrent = 1, ---only once
			maxdist = 500, --- only when near
			preload = true, --- you got it
			in3d = true,
			looptime = "1000", --- in miliseconds, can / will be stopped like regular items
			MapEntryValExtract(items, "dopplerscale", dopplerScale);
			MapEntryValExtract(items, "rolloff", rolloff);
		},
		--]]
		mlr_launch = {
			file = "sounds/weapon/missile/mlr_launch.wav",
			maxconcurrent = 30,
			pitchmod = 0.09,
			in3d = true,
			dopplerscale = 0.1,
			rolloff = 0.42,
			gain = 1.25,
			maxdist = maxdistance,
		},
		ion_loop = {
			file = "sounds/weapon/laser/ion_burn.wav",
			maxconcurrent = 30,
			pitchmod = 0.01,
			in3d = true,
			dopplerscale = 0.7,
			rolloff = 0.4,
			gain = 0.1,
			looptime = 145,
			maxdist = maxdistance,
		},
		mlr_impact = {
			file = "sounds/weapon/missile/rapid_rocket_hit.wav",
			maxconcurrent = 100,
			pitchmod = 0.02,
			in3d = true,
			dopplerscale = 0.2,
			rolloff = 0.5,
			gain = 1.4,
			maxdist = maxdistance,
		},
		missile_fire7 = {
			file = "sounds/weapon/missile/missile_fire7.wav",
			maxconcurrent = 100,
			pitchmod = 0.05,
			in3d = true,
			dopplerscale = 0.2,
			rolloff = 0.33,
			maxdist = maxdistance,
		},
		sabot_hit_soft = {
			file = "sounds/weapon/missile/sabot_hit.wav",
			maxconcurrent = 100,
			pitchmod = 0.05,
			in3d = true,
			dopplerscale = 0.2,
			rolloff = 0.80,
			gain = 0.7,
			maxdist = maxdistance,
		},
		waylayer_launch = {
			file = "sounds/weapon/missile/gator_launch.wav",
			maxconcurrent = 100,
			pitchmod = 0.05,
			in3d = true,
			dopplerscale = 0.4,
			rolloff = 0.80,
			gain = 0.66,
			maxdist = maxdistance,
		},
		bomb_hit = {
			file = "sounds/explosion/ex_med6.wav",
			maxconcurrent = 100,
			in3d = true,
			dopplerscale = 0.6,
			rolloff = 0.9,
			gain = 0.7,
			maxdist = maxdistance,
		},
		soft_tracker = {
			file = "sounds/weapon/laser/tracker.wav",
			maxconcurrent = 100,
			in3d = true,
			dopplerscale = 0.4,
			rolloff = 0.90,
			gain = 1,
			looptime = 445,
			maxdist = maxdistance,
		},
		PulseLaser = {
			file = "sounds/weapon/laser/pulse_laser_start.wav",
			pitchmod = 0.15,
			gainmod = 0.1,
			pitch = 1,
			gain = 1.5,
			maxdist = maxdistance,
		},
		BladeSwing = {
			file = "sounds/weapon/blade/blade_swing.wav",
			pitchmod = 0.1,
			gainmod = 0.1,
			pitch = 0.8,
			gain = 0.9,
			priority = 1,
		},
		BladeHit = {
			file = "sounds/weapon/blade/blade_hit.wav",
			pitchmod = 0.5,
			gainmod = 0.2,
		},
		FireLaunch = {
			file = "sounds/weapon/cannon/cannon_fire3.wav",
			pitchmod = 0.1,
			gainmod = 0.1,
		},
		FireHit = {
			file = "sounds/explosion/ex_med6.wav",
			pitchmod = 0.4,
			gainmod = 0.2,
		},
		NoSound = {
			file = "sounds/nosound.wav",
			maxconcurrent = 1,
		},
		DefaultsForSounds = { -- this are default settings
			file = "ThisEntryMustBePresent.wav",
			gain = 1.0,
			pitch = 1.0,
			priority = 0,
			maxconcurrent = 20, --- some reasonable limits
			--maxdist = nil, --- no cutoff at all (engine defaults to FLT_MAX)
			maxdist = maxdistance,
			rolloff = 0.5,
			in3d = true,
		},
		DetrimentJump = {
			file = "sounds/detriment_jump.wav",
			pitchmod = 0.1,
			gainmod = 0.05,
		},
		Sparks = {
			file = "sounds/sparks.wav",
			priority = -10,
			maxconcurrent = 1,
			maxdist = 1000,
			preload = false,
			in3d = true,
			rolloff = 4,
		},
		Launcher = {
			file = "sounds/weapon/launcher.wav",
			pitchmod = 0.05,
			gainmod = 0,
			gain = 2.4,
			maxdist = maxdistance,
			rolloff = 0.5,
		},
		TorpedoHitVariable = {
			file = "sounds/explosion/wet/ex_underwater.wav",
			pitchmod = 0.1,
			gainmod = 0.05,
			maxdist = maxdistance,
			rolloff = 0.5,
		},
		Jump = {
			file = "sounds/jump.wav",
			pitchmod = 0.1,
			gainmod = 0.05,
			maxdist = maxdistance,
			rolloff = 0.7,
		},
		JumpLand = {
			file = "sounds/jump_land.wav",
			pitchmod = 0.1,
			gainmod = 0.05,
			maxdist = maxdistance,
			rolloff = 0.7,
		},
		Teleport2 = {
			file = "sounds/misc/teleport2.wav",
			maxconcurrent = 20,
			gain = 1.0,
			pitch = 1.0,
			preload = true,
			maxdist = maxdistance,
			rolloff = 0.7,
		},
		SiloLaunch = {
			file = "sounds/weapon/missile/tacnuke_launch.wav",
			gain = 1.0,
			pitch = 1.0,
			priority = 2,
			maxconcurrent = 16,
			preload = true,
			maxdist = maxdistance,
			rolloff = 0.8,
		},
		LurkerHit = {
			file = "sounds/weapon/cannon/lurker_hit.wav",
			gain = 0.69,
			pitch = 1.0,
			maxconcurrent = 16,
			preload = false,
			rollOff = 0.4,
			maxdist = maxdistance,
		},
		LurkerFire = {
			file = "sounds/weapon/cannon/lurker_fire.wav",
			gain = 0.69,
			pitch = 1.0,
			maxconcurrent = 20,
			preload = false,
			maxdist = nil,
			rollOff = 0.4,
			maxdist = maxdistance,
		},
		PreserverSecondaryHit = {
			file = "sounds/weapon/emp/LightningBolt3.wav",
			gain = 0.65,
			pitch = 1.0,
			maxconcurrent = 20,
			preload = false,
			rollOff = 0.6,
			maxdist = maxdistance,
		},
		flamethrowerfire = {
			file = "sounds/weapon/cannon/flamethrower_fire.wav",
			gain = 1.0,
			pitch = 1.0,
			priority = -3,
			maxconcurrent = 20,
			preload = false,
			rollOff = 0.5,
			maxdist = maxdistance,
		},
		flamethrowerhit = {
			file = "sounds/weapon/cannon/wolverine_hit.wav",
			gain = 1.0,
			pitch = 1.0,
			priority = -21,
			maxconcurrent = 20,
			preload = false,
			rollOff = 0.5,
			maxdist = maxdistance,
		},
		gausslimitedfire = {
			file = "sounds/weapon/cannon/gauss_rapid.wav",
			gain = 1.0,
			pitch = 1.0,
			priority = -3,
			preload = false,
			maxconcurrent = 14,
			rollOff = 0.6,
			maxdist = maxdistance,
		},
		gausslimitedhit = {
			file = "sounds/weapon/cannon/heavy_gauss_hit.wav",
			gain = 1.0,
			pitch = 1.0,
			priority = -4,
			preload = false,
			maxconcurrent = 14,
			rollOff = 0.5,
			maxdist = maxdistance,
		},
		nukewarning = {
			file = "sounds/reply/advisor/nuclearthreat.wav",
			gain = 1.33,
			pitch = 1.0,
			priority = 20,
			preload = true,
			maxconcurrent = 1,
			maxdist = nil, -- UI land.
		},
	},
}

--------------------------------------------------------------------------------
-- Automagical sound handling
--------------------------------------------------------------------------------
local VFSUtils = VFS.Include('gamedata/VFSUtils.lua')

local optionOverrides = {
}

local defaultOpts = {
	pitchmod = 0, --0.02,
	gainmod = 0,
}
local replyOpts = {
	pitchmod = 0, --0.02,
	gainmod = 0,
}

local noVariation = {
	dopplerscale = 0,
	in3d = false,
	pitchmod = 0,
	gainmod = 0,
	pitch = 1,
	gain = 1,
}

local ignoredExtensions = {
	["svn-base"] = true,
}

local function AutoAdd(subDir, generalOpts)
	generalOpts = generalOpts or {}
	local opts
	local dirList = RecursiveFileSearch("sounds/" .. subDir)
	--local dirList = RecursiveFileSearch("sounds/")
	--Spring.Echo("Adding sounds for " .. subDir)
	for _, fullPath in ipairs(dirList) do
		local path, key, ext = fullPath:match("sounds/(.*/(.*)%.(.*))")
		local pathPart = fullPath:match("(.*)[.]")
		pathPart = pathPart:sub(8, -1)	-- truncates extension fullstop and "sounds/" part of path
		--Spring.Echo(pathPart)
		if path ~= nil and (not ignoredExtensions[ext]) then
			if optionOverrides[pathPart] then
				opts = optionOverrides[pathPart]
				--Spring.Echo("optionOverrides for " .. pathPart)
			else
				opts = generalOpts
			end
			--Spring.Echo(path,key,ext, pathPart)
			Sounds.SoundItems[pathPart] = {
				file = tostring('sounds/'..path),
				rolloff = opts.rollOff,
				dopplerscale = opts.dopplerscale,
				maxdist = opts.maxdist,
				maxconcurrent = opts.maxconcurrent,
				priority = opts.priority,
				in3d = opts.in3d,
				gain = opts.gain,
				gainmod = opts.gainmod,
				pitch = opts.pitch,
				pitchmod = opts.pitchmod
			}
			--Spring.Echo(Sounds.SoundItems[key].file)
		end
	end
end

-- add sounds
AutoAdd("weapon", defaultOpts)
AutoAdd("explosion", defaultOpts)
AutoAdd("reply", replyOpts)
AutoAdd("music", noVariation)

return Sounds
