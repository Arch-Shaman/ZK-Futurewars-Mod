-- $Id: LuaAI.lua 3171 2008-11-06 09:06:29Z det $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  LuaAI.lua
--
--    List of LuaAIs supported by the mod.
--
--

return {
  {
	-- to be recognised as a CAI there must be an entry with this name in
	-- LuaRules\Configs\cai\configCoordinator.lua
    name = 'CAI',
    desc = 'Shard dev's rival'
  },
  --{
  --  name = 'CAI2',
  --  desc = 'Another AI that plays regular Zero-K'
  --},
  {
    name = 'Chicken: Beginner',
    desc = 'A sad experience.'
  },
  {
    name = 'Chicken: Very Easy',
    desc = 'You must really like picking on biologicals'
  },
  {
    name = 'Chicken: Easy',
    desc = 'They might scratch the paint job'
  },
  {
    name = 'Chicken: Normal',
    desc = 'Some bruises in the morning'
  },
  {
    name = 'Chicken: Hard',
    desc = 'You\'re probably not coming home.'
  },
  {
    name = 'Chicken: Suicidal',
    desc = 'God help you.'
  },
  {
    name = 'Chicken: Custom',
    desc = 'A chicken experience customizable using modoptions'
  },
  {
	name ='Null AI',
	desc = 'The perfect plan: sit in one space and stare menacingly until you die.'
  }
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
