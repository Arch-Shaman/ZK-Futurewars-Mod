== Data Types ==
**number**
	A natural number.
**realNumber**
	A real number. Can be positive, negative, floating point or zero. realNumber implies that all real values will be handled. strings which are not numbers will be treated as nil.
**posNumber**
	A positive, non-zero, real number. note that positivity is *not* checked and non positive values will lead to undefined behavour. strings which are not numbers will be treated as nil.
**realNumberArray**
	A comma seperated array of realNumbers. follows the same rules as realNumber.
**string**
	A string value.
**bool**
	A boolean value. `nil`, `"false"` and `"0"` are treated as false, all other values are treated as true.
	Note that for bool values which default to false, it may not be safe to use `"false"` or `"0"`. however `nil` will always be read as false.
**switch**
	A switch/enum with a very specific set of valid inputs. inputs other than the exact ones defined here may result in undefined behavour.
**ceg**
	The name of a ceg. See Spring.SpawnCEG.


== Cluster Ammunition Customparams ==
parsed by  luaRules/Configs/submunition_config.lua
handled by luaRules/Gadgets/weapon_cluster_ammunition_spawner.lua


posNumber **spawndist**
	Distance at which the projectile clusters?
	REQUIRED if noairburst is false.
posNumber **timeddeploy**
	Time before the weapon will be forced to cluster.
bool **use2ddist** = `false`
	Will spawndist checks use 3d (xyz) distance or 2d (xz) distance?
bool **timeoutspawn** = `true`
	Will this missile cluster when it times out?
bool **proxy** = `false`
	Are nearby units also checked?
posNumber **proxydist** = spawndist
	How far to check for units?
bool **alwaysvisible#** = `false`
	Is the projectile always visible?
posNumber **clustercharges** = `1`
	How many times can the projectile cluster before despawning?
posNumber **clusterdelay**
	The mininium delay between each clustering.
switch **clusterdelaytype** = `0`
	Controls how continous clustering works.
	`0` - The projectile will continously cluster until it expires after it is triggered.
	`1` - The projectile will only cluster if it's clustering conditions are met.
bool **useheight** = `false`
	If true, should spawndist wull bebe checked against ground height.
bool **dyndamage** = `false`
	Set to true to if this weapon have commander-esq dynamic damage.
bool **noairburst** = `false`
	If true, this weapon will skip all airburst checks except timeddeploy.
	REQUIRED if spawndist is not set
bool **useasl** = `false`	
	If true, useheight will use the projectile's absolute height instead of height over ground.
bool **onexplode** = `false`
	If true, any explosions from this weapon will result in a clustering.
bool **usertargetable** = `false`
	If true, this weapon a MIRV and the submunitions will be targetable.
bool **noceg** = `false`
	If true, cegs will not be spawned when the cluster weapon clusters.
bool **cas_nocruisecheck** = `false`
	If true, all clustering checks are skipped while the projectile is in cruise.
realNumber **maxvelocity** = 0
	The maximium velocity above which height-based clustering will not happen.

== Subprojectile Customparams ==
Replace the **#** in the names of these customparam with the instance of subprojectile. `projectile1` would refer to the first submunition entry, while `projectile3` would refer to the 3rd

string **projectile#**
	the full weapondef name of the projectile to spawn.
	REQUIRED if spawnsfx is not set.
number **spawnsfx#**
	the value to pass into Spring.SpawnSFX.
	REQUIRED if projectile is not set.
number **numprojectiles#** = `1`
	the number of submunitions to spawn.
realNumberArray **posspread#** 
	an array of numbers to define the positional spread of the subprojectile. the element 1-3 define one end of the spread in x, y and z respectively. element 3-6 define the other end, and default to the additive inverse of the first 3 values.
switch **posspreadmode#** = `none` (`cylY` if posspread is defined)
	the 3d shape which gets scaled by `posspread` to produce the area within a random vector will be chosen for the positional spread.
	Accepts `none`, `cylY`, `cylX`, `cylZ`, `box`, `sphere`
realNumberArray **velspread#**
	see `posspread`
switch **velspreadmode#** = `none` (`cylY` if velspread is defined)
	see `velspreadmode`
realNumberArray **keepmomentum#** = `1, 1, 1`
	either a size 1 or size 3 array detailing the scaling factors for either the total velocity, or the x, y, and z velocity of the parent projectile before it is added to the velocity of the submunitions.
	Set to 0 to disable.


== Singularities Customparams ==
parsed and handed by Gadgets/weapon_singularities.lua

boolean **singularity**
	Does this weapon create a singularity upon explosion.
	REQUIRED for singularities.
posNumber **singu_radius** = `400`
	radius of the singularity in elmos.
posNumber **singu_lifespan** = `300`
	Lifespan of the singularity in frames.
realNumber **singu_strength** = `75`
	strength of the singularity.
realNumber **singu_finalstrength** = `singu_strength * 10`
	Used in place of strength on the final frame of the singularity's life.
	Note that this is applied in the opposite direction.
realNumber **singu_height** = `0`
	Y displacement for spawning the singularity.
ceg **singu_ceg**
	Ceg to be spawned throughout the singularity's life.
ceg **singu_finalceg**
	Ceg to be spawned at the end of the singularity's life.
realNumber **singy_edgeeffect** = `0`
	Modifier for the effect falloff. Works the same way as weapondefs' EdgeEffectiveness.
realNumber **singu_baseeffect** = `0.25`
	Base effectiveness factor for the singularity.
boolean **singu_nodamageimmunity** = `false`
	If true, units affected by the singularity will not have collision damage immunity applied for the duration of the effect.
	Note that this makes singularities do terrifying amounts of damage.

== Carrier Drones customParams ==
boolean **drone_launch**
	Is this weapon a dummy for a drone launch?
intege **drone_launch_rate**
	How many frames between launching each drone?

== Siege Zones customParams ==
(Note that a unit cannot have multiple siege targeters or they will override one another)
string **sieges_for**
	Which weaponDefName is this siege targeter sieging for?
	REQUIRED for siege targeters if **sieges_for_all** is not true
boolean **sieges_for_all**
	This siege targeter sieges for all the weapons on a unit
	REQUIRED for siege targeters if **sieges_for_all** is not true
posNumber **sieges_radius**
	How large is the siege circle?
number **sieges_time**
	How long, in frames, does the siege take?

