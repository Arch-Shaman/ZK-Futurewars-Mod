local _, def = VFS.Include("gamedata/modularcomms/weapons/heavymachinegun.lua")

def.name = "Disruptor " .. def.name
def.cegtag = "hmg_trail_disrupt"
def.customParams.timeslow_damagefactor = 3
for armorType, damage in pairs (def.damage) do
	def.damage[armorType] = damage * 0.85
end
def.customParams.antibaitbypass = "ärsytät minua"
def.customParams.light_color = "1.3 0.5 1.6"
def.customParams.altforms = nil -- baseline also has a lime variant, disruptor doesn't yet
def.explosionGenerator = "custom:BEAMWEAPON_HIT_PURPLE"
def.rgbColor = "0.9 0.1 0.9"

return "commweapon_heavymachinegun_disrupt", def