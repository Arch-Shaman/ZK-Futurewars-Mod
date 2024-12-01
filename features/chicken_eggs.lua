-- $Id$

local eggDefs = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local defaultEgg = {
  description = [[Egg]],
  blocking    = false,
  damage      = 10000,
  reclaimable = true,
  energy      = 0,
  footprintx  = 1,
  footprintz  = 1,

  customParams = {
    mod = true,
  },
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local type  = type
local pairs = pairs
local function CopyTable(outtable,intable)
  for i,v in pairs(intable) do
    if (type(v)=='table') then
      if (type(outtable[i])~='table') then outtable[i] = {} end
      CopyTable(outtable[i],v)
    else
      outtable[i] = v
    end
  end
end
local function MergeTable(table1,table2)
  local ret = {}
  CopyTable(ret,table2)
  CopyTable(ret,table1)
  return ret
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


eggDefs.chicken_egg = MergeTable(defaultEgg, {
  metal       = 10,
  reclaimTime = 10,
  object      = [[chickenegg.s3o]],
})
eggDefs.chicken_pigeon_egg = MergeTable(defaultEgg, {
  metal       = 50,
  reclaimTime = 50,
  object      = [[chickeneggblue.s3o]],
})
eggDefs.chickens_egg = MergeTable(defaultEgg, {
  metal       = 50,
  reclaimTime = 50,
  object      = [[chickenegggreen.s3o]],
})
eggDefs.chickenr_egg = MergeTable(defaultEgg, {
  metal       = 75,
  reclaimTime = 75,
  object      = [[chickeneggblue.s3o]],
})
eggDefs.chicken_spidermonkey_egg = MergeTable(defaultEgg, {
  metal       = 100,
  reclaimTime = 100,
  object      = [[chickenegg.s3o]],
})
eggDefs.chickenc_egg = MergeTable(defaultEgg, {
  metal       = 50,
  reclaimTime = 50,
  object      = [[chickeneggaqua.s3o]],
})




eggDefs.chicken_dodo_egg = MergeTable(defaultEgg, {
  metal       = 20,
  reclaimTime = 20,
  object      = [[chickeneggcrimson.s3o]],
})
eggDefs.chicken_roc_egg = MergeTable(defaultEgg, {
  metal       = 150,
  reclaimTime = 150,
  object      = [[chickenegggreen.s3o]],
})
eggDefs.chickenf_egg = MergeTable(defaultEgg, {
  metal       = 40,
  reclaimTime = 40,
  object      = [[chickeneggyellow.s3o]],
})
eggDefs.chickenwurm_egg = MergeTable(defaultEgg, {
  metal       = 100,
  reclaimTime = 100,
  object      = [[chickeneggbrown.s3o]],
})
eggDefs.chickena_egg = MergeTable(defaultEgg, {
  metal       = 50,
  reclaimTime = 50,
  object      = [[chickeneggred.s3o]],
})



eggDefs.chicken_sporeshooter_egg = MergeTable(defaultEgg, {
  metal       = 100,
  reclaimTime = 100,
  object      = [[chickeneggyellow.s3o]],
})
eggDefs.chicken_blimpy_egg = MergeTable(defaultEgg, {
  metal       = 300,
  reclaimTime = 300,
  object      = [[chickeneggaqua.s3o]],
})
eggDefs.chickenblobber_egg = MergeTable(defaultEgg, {
  metal       = 300,
  reclaimTime = 300,
  object      = [[chickeneggblue.s3o]],
})
eggDefs.chicken_shield_egg = MergeTable(defaultEgg, {
  metal       = 250,
  reclaimTime = 250,
  object      = [[chickenegggreen_big.s3o]],
})
eggDefs.chicken_tiamat_egg = MergeTable(defaultEgg, {
  metal       = 350,
  reclaimTime = 350,
  object      = [[chickeneggwhite.s3o]],
})


eggDefs.chicken_rafflesia_egg = MergeTable(defaultEgg, {
  metal       = 4200,
  reclaimTime = 4200,
  object      = [[chickenegggreen_big.s3o]],
})
eggDefs.chickend_egg = MergeTable(defaultEgg, {
  metal       = 150,
  reclaimTime = 150,
  object      = [[chickeneggaqua.s3o]],
})
eggDefs.chicken_leaper_egg = MergeTable(defaultEgg, {
  metal       = 20,
  reclaimTime = 20,
  object      = [[chickeneggbrown.s3o]],
})
eggDefs.chicken_dragon_egg = MergeTable(defaultEgg, {
  metal       = 6500,
  reclaimTime = 6500,
  object      = [[chickeneggblue_huge.s3o]],
})

-- specify origin unit (for tooltip/contextmenu)
for name,data in pairs(eggDefs) do
	local unitname = name
	local truncate = unitname:find("_egg")
	unitname = unitname:sub(1, truncate)
	data.customParams.unit = unitname
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return lowerkeys( eggDefs )

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
