local _, def = VFS.Include("gamedata/modularcomms/weapons/commweapon_rocketlauncher.lua")

def.name = "Multiple Light Napalm Rocket Launcher"
def.areaOfEffect = def.areaOfEffect * 1.5 -- other napalms are 1.25 tho?
for armorType, damage in pairs (def.damage) do
	def.damage[armorType] = damage * 0.75
end
def.customParams.burntime = 120
def.customParams.burnchance = 1
def.customParams.area_damage = 1
def.customParams.area_damage_radius = 108
def.customParams.area_damage_dps = 18
def.customParams.area_damage_duration = 16
def.customParams.setunitsonfire = 1
def.craterBoost = 1
def.craterMult = 1

def.customParams.light_color = "0.95 0.5 0.25"
def.customParams.light_radius = def.customParams.light_radius * 1.25
def.customParams.light_camera_height = def.customParams.light_camera_height + 600
def.explosiongenerator = "custom:napalm_koda"
def.soundHit = "weapon/burn_mixed"

return "commweapon_rocketlauncher_napalm", def
