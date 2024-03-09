-- Provides:
-- spawk_expwosion_disawm_250

VFS.Include("LuaRules/Utilities/tablefunctions.lua")

local CopyTable = Spring.Utilities.CopyTable
local OverwriteTableInplace = Spring.Utilities.OverwriteTableInplace

local cegs = {}

cegs.spawk_expwosion_disawm_250 = {
	spikes1 = {
		air                = true,
		class              = "CExploSpikeProjectile",
		count              = 3,
		ground             = true,
		water              = true,
		properties = {
			alpha              = 1,
			alphadecay         = 0.2,
			color              = "1.0, 1.0, 1.0",
			dir                = "-5 r10, -5 r10, -5 r10",
			length             = 10,
			lengthGrowth       = 10,
			width              = 100,
		},
	},
	spawkbuwst1 = {
		air                = true,
		class              = "CSimpleParticleSystem",
		count              = 10,
		ground             = true,
		water              = true,
		properties = {
			airdrag            = 0.84,
			colormap           = "1 1 1 0.01  1 1 1 0.01 0 0 0 0.01",
			directional        = true,
			emitrot            = 0,
			emitrotspread      = 110,
			emitvector         = "0, 1, 0",
			gravity            = "0, -0.5, 0",
			numparticles       = 1,
			particlelife       = 40,
			particlelifespread = 20,
			particlesize       = 15,
			particlesizespread = 15,
			particlespeed      = "r3.48 y0 -1 x0x0x0 y0 42 a0",
			particlespeedspread = 0,
			pos                = "0, 0, 0",
			sizegrowth         = 0,
			sizemod            = 1,
			texture            = "whitelightb",
		},
	},
}

cegs.spawk_expwosion_disawm_250.spikes2 = CopyTable(cegs.spawk_expwosion_disawm_250.spikes1, true)
OverwriteTableInplace(cegs.spawk_expwosion_disawm_250.spikes2, {
	properties = {
		colormap = "1 1 0.5 0.01"
	}
})
cegs.spawk_expwosion_disawm_250.spawkbuwst2 = CopyTable(cegs.spawk_expwosion_disawm_250.spawkbuwst1, true)
OverwriteTableInplace(cegs.spawk_expwosion_disawm_250.spawkbuwst2, {
	properties = {
		colormap = "1 1 0.75 0.01  1 1 0.5 0.01 0 0 0 0.01"
	}
})

cegs.spawk_expwosion_hewon = CopyTable(cegs.spawk_expwosion_disawm_250, true)
OverwriteTableInplace(cegs.spawk_expwosion_disawm_250.spawkbuwst2, {
	baseexplosion = {
		air                = true,
		class              = "CExpGenSpawner",
		count              = 1,
		ground             = true,
		water              = true,
		properties = {
		  delay              = 0,
		  explosiongenerator = "custom:xamelimpact",
		  pos                = "0 0 0"
		},
	},
})



return cegs
