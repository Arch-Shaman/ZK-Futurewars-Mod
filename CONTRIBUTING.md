# Commit Etiquette

This repository uses homemade automation to produce patch notes, tags, and game versions. Remember to use the following format in commits:

If this is a unit change:
- name the commit the unit name
- add changes to the description. The following fields are currently supported: HP, Damage, Cost, Reload, Speed, reload, projectile speed, aoe. Double weapons are currently not supported.

If this is a bug fix, remember to add "Fix", "fixed", "Resolve", "resolved", or "Lua error" to your commit title!
For any non-game changing changes, prefix your commit title with "[Ignore]" so the bot does not include it in the patch notes.

If this is a game version increment: ENSURE THE TITLE IS IN THE FOLLOWING FORMAT:
v{Release}.{Major}.{Minor}
Where release is 1 if we are post release
Where Major is incremented starting from 0 if compatibility with ZK:Stable is broken or a major change has taken place.
Where Minor is incremented for "everything else", starting at 0 after major is incremented.

For instance:
v0.39.3 -- not released, 39th major, 3rd minor

IMPORTANT: REMEMBER TO SPELL CHECK!
IMPORTANT 2: Do not use any quotes or apostrophes! They seem to break the bot.
