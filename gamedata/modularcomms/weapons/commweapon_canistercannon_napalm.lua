local _, def = VFS.Include("gamedata/modularcomms/weapons/commweapon_canistercannon.lua")

def.name = "Incendiary Launcher"
def.damage = {
	default = 40 * 15
}

def.customParams.burntime = 420 -- blaze it!
def.customParams.burnchance = 1
def.customParams.setunitsonfire = 1
def.customParams.projectile1 = "commweapon_napalmcanister_fragment"
def.customParams.spawndist = 210
def.customParams.numprojectiles1 = 15
def.customParams.vradius1 = "-6,-1,-6,6,1,6"
def.rgbColor = "1 0.3 0.1"
def.soundHit = "weapon/clusters/cluster_light_napalm"

return "commweapon_canistercannon_napalm", def
