include "constants.lua"

local dyncomm = include('dynamicCommander.lua')
_G.dyncomm = dyncomm

local AntennaTip = piece('AntennaTip')
local ArmLeft = piece('ArmLeft')
local ArmRight = piece('ArmRight')
local AssLeft = piece('AssLeft')
local AssRight = piece('AssRight')
local Breast = piece('Breast')
local CalfLeft = piece('CalfLeft')
local CalfRight = piece('CalfRight')
local FingerA = piece('FingerA')
local FingerB = piece('FingerB')
local FingerC = piece('FingerC')
local FootLeft = piece('FootLeft')
local FootRight = piece('FootRight')
local Gun = piece('Gun')
local HandRight = piece('HandRight')
local Head = piece('Head')
local HipLeft = piece('HipLeft')
local HipRight = piece('HipRight')
local Muzzle = piece('Muzzle')
local Palm = piece('Palm')
local Stomach = piece('Stomach')
local Base = piece('Base')
local Nano = piece('Nano')
local UnderGun = piece('UnderGun')
local UnderMuzzle = piece('UnderMuzzle')
local RightMuzzle = piece('RightMuzzle')
local Eye = piece('Eye')
local Shield = piece('Shield')
local FingerTipA = piece('FingerTipA')
local FingerTipB = piece('FingerTipB')
local FingerTipC = piece('FingerTipC')
-- Modules --
local ablativearmor0 = piece('ablativearmor0')
local ablativearmor3 = piece('ablativearmor3') -- hide ablativearmor0
local ablativearmor6 = piece('ablativearmor6')
local ablativearmor8 = piece('ablativearmor8') -- hide ablativearmor3 ablativearmor6
local advnano3 = piece('advnano3')
local advnano6 = piece('advnano6') -- hide advnano3 ArmLeft
local advnano8 = piece('advnano8')
local advtargeting3 = piece('advtargeting3')
local advtargeting6 = piece('advtargeting6') -- hide advtargeting3
local advtargeting8 = piece('advtargeting8') -- hide advtargeting6
local autorepair3 = piece('autorepair3')
local autorepair6 = piece('autorepair6')
local autorepair8 = piece('autorepair8')
local cloakrepair0 = piece('cloakrepair0')
local cloakrepair3 = piece('cloakrepair3') -- hide cloakrepair0
local cloakrepair6 = piece('cloakrepair6') -- hide cloakrepair3
local cloakrepair8 = piece('cloakrepair8') -- hide cloakrepair6 Breast
local detpack1 = piece('detpack1') -- spin detpack1 in value 1
local detpack2 = piece('detpack2')
local detpack3 = piece('detpack3') -- spin detpack3 in value -2
local dmgbooster3 = piece('dmgbooster3')
local dmgbooster6 = piece('dmgbooster6') -- hide dmgbooster3
local dmgbooster8 = piece('dmgbooster8') -- hide dmgbooster6
local jammer1 = piece('jammer1')
local powerservos31 = piece('powerservos31') -- hide FootRight
local powerservos32 = piece('powerservos32') -- hide FootLeft
local powerservos61 = piece('powerservos61') -- hide CalfRight
local powerservos62 = piece('powerservos62') -- hide CalfLeft
local powerservos81 = piece('powerservos81') -- hide HipRight
local powerservos82 = piece('powerservos82') -- hide HipLeft
local strikeservos3 = piece('strikeservos3')
local strikeservos6 = piece('strikeservos6')
local strikeservos8 = piece('strikeservos8')
-- Right Arm Module Weapon --
local busterdisrupt = piece('busterdisrupt') -- hide Gun UnderGun tankbuster undertankbuster
local underbusterdisrupt = piece('underbusterdisrupt') -- hide Gun UnderGun tankbuster undertankbuster
local heavyrifle = piece('heavyrifle') -- hide Gun UnderGun
local underheavyrifle = piece('underheavyrifle') -- hide Gun UnderGun
local heavyrifledisrupt = piece('heavyrifledisrupt') -- hide Gun UnderGun heavyrifle underheavyrifle
local underheavyrifledisrupt = piece('underheavyrifledisrupt') -- hide Gun UnderGun heavyrifle underheavyrifle
local lightninggun = piece('lightninggun') -- hide Gun UnderGun
local underlightninggun = piece('underlightninggun') -- hide Gun UnderGun
local lightninggunimproved = piece('lightninggunimproved') -- hide Gun UnderGun lightninggun underlightninggun
local underlightninggunimproved = piece('underlightninggunimproved') -- hide Gun UnderGun lightninggun underlightninggun
local shotgun = piece('shotgun') -- hide Gun UnderGun
local undershotgun = piece('undershotgun') -- hide Gun UnderGun
local shotgundisrupt = piece('shotgundisrupt') -- hide Gun UnderGun shotgun undershotgun
local undershotgundisrupt = piece('undershotgundisrupt') -- hide Gun UnderGun shotgun undershotgun
local tankbuster = piece('tankbuster') -- hide Gun UnderGun
local undertankbuster = piece('undertankbuster') -- hide Gun UnderGun
local WeaponsRight = {
	busterdisrupt = {busterdisrupt, underbusterdisrupt},
	heavyrifle = {heavyrifle, underheavyrifle},
	heavyrifledisrupt = {heavyrifledisrupt, underheavyrifledisrupt},
	lightninggun = {lightninggun, underlightninggun},
	lightninggunimproved = {lightninggunimproved, underlightninggunimproved},
	shotgun = {shotgun, undershotgun},
	shotgundisrupt = {shotgundisrupt, undershotgundisrupt},
	tankbuster = {tankbuster, undertankbuster}
}
-- Left Arm Module Weapon --
local disintegrator = piece('disintegrator') -- hide HandRight FingerA FingerB FingerC
local underdisintegrator = piece('underdisintegrator') -- hide HandRight FingerA FingerB FingerC
local disintegratorFingerA = piece('disintegratorFingerA') -- hide HandRight FingerA FingerB FingerC
local disintegratorFingerB = piece('disintegratorFingerB') -- hide HandRight FingerA FingerB FingerC
local disintegratorFingerC = piece('disintegratorFingerC') -- hide HandRight FingerA FingerB FingerC
local minefieldinacan = piece('minefieldinacan') -- hide HandRight FingerA FingerB FingerC
local underminefieldinacan = piece('underminefieldinacan') -- hide HandRight FingerA FingerB FingerC
local multistunner = piece('multistunner') -- hide HandRight FingerA FingerB FingerC
local undermultistunner = piece('undermultistunner') -- hide HandRight FingerA FingerB FingerC
local rightbusterdisrupt = piece('rightbusterdisrupt') -- hide HandRight FingerA FingerB FingerC tankbuster undertankbuster
local rightunderbusterdisrupt = piece('rightunderbusterdisrupt') -- hide HandRight FingerA FingerB FingerC tankbuster undertankbuster
local rightheavyrifle = piece('rightheavyrifle') -- hide HandRight FingerA FingerB FingerC
local rightunderheavyrifle = piece('rightunderheavyrifle') -- hide HandRight FingerA FingerB FingerC
local rightheavyrifledisrupt = piece('rightheavyrifledisrupt') -- hide HandRight FingerA FingerB FingerC heavyrifle underheavyrifle
local rightunderheavyrifledisrupt = piece('rightunderheavyrifledisrupt') -- hide HandRight FingerA FingerB FingerC heavyrifle underheavyrifle
local rightlightninggun = piece('rightlightninggun') -- hide HandRight FingerA FingerB FingerC
local rightunderlightninggun = piece('rightunderlightninggun') -- hide HandRight FingerA FingerB FingerC
local rightlightninggunimproved = piece('rightlightninggunimproved') -- hide HandRight FingerA FingerB FingerC lightninggun underlightninggun
local rightunderlightninggunimproved = piece('rightunderlightninggunimproved') -- hide HandRight FingerA FingerB FingerC lightninggun underlightninggun
local rightshotgun = piece('rightshotgun') -- hide HandRight FingerA FingerB FingerC
local rightundershotgun = piece('rightundershotgun') -- hide HandRight FingerA FingerB FingerC
local rightshotgundisrupt = piece('rightshotgundisrupt') -- hide HandRight FingerA FingerB FingerC shotgun undershotgun
local rightundershotgundisrupt = piece('rightundershotgundisrupt') -- hide HandRight FingerA FingerB FingerC shotgun undershotgun
local righttankbuster = piece('righttankbuster') -- hide HandRight FingerA FingerB FingerC
local rightundertankbuster = piece('rightundertankbuster') -- hide HandRight FingerA FingerB FingerC
local sunburst = piece('sunburst') -- hide HandRight FingerA FingerB FingerC
local undersunburst = piece('undersunburst') -- hide HandRight FingerA FingerB FingerC

local WeaponsLeft = {
	disintegrator = {disintegrator, underdisintegrator, disintegratorFingerA, disintegratorFingerB, disintegratorFingerC},
	minefieldinacan = {minefieldinacan, underminefieldinacan},
	sunburst = {sunburst, undersunburst},
	multistunner = {multistunner, undermultistunner},
	multistunnerimproved = {multistunner, undermultistunner},
	tankbuster = {righttankbuster, rightundertankbuster},
	busterdisrupt = {rightbusterdisrupt, rightunderbusterdisrupt},
	lightninggun = {rightlightninggun, rightunderlightninggun},
	lightninggunimproved = {rightlightninggunimproved, rightunderlightninggunimproved},
	shotgun = {rightshotgun, rightundershotgun},
	shotgundisrupt = {rightshotgundisrupt, rightundershotgundisrupt},
	heavyrifle = {rightheavyrifle, rightunderheavyrifle},
	heavyrifledisrupt = {rightheavyrifledisrupt, rightunderheavyrifledisrupt}
}

local TORSO_SPEED_YAW = math.rad(300)
local ARM_SPEED_PITCH = math.rad(180)
local smokePiece = {Breast, Head}
local nanoPieces = {Nano}
local nanoing = false
local aiming = false
local FINGER_ANGLE_IN = math.rad(10)
local FINGER_ANGLE_OUT = math.rad(-25)
local FINGER_SPEED = math.rad(60)
local SIG_RIGHT = 1
local SIG_RESTORE_RIGHT = 2
local SIG_LEFT = 4
local SIG_RESTORE_LEFT = 8
local SIG_RESTORE_TORSO = 16
local SIG_WALK = 32
local SIG_NANO = 64
local okpconfig
local RESTORE_DELAY = 2500
local instantaimweapon2 = false
local priorityAim = false
local priorityAimNum = 0
local needsBattery = false

local function GetOKP()
	while Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1") == nil do
		Sleep(33)
	end
	okpconfig = dyncomm.GetOKPConfig()
	--Spring.Echo("Use OKP: " .. tostring(okpconfig[1].useokp or okpconfig[2].useokp))
	if okpconfig[1].useokp or okpconfig[2].useokp then
		GG.OverkillPrevention_ForceAdd(unitID)
	end
end


---------------------------------------------------------------------
---  blender-exported animation: data (move to include file?)     ---
---------------------------------------------------------------------
local Animations = {};
Animations['die'] = {
	{
		['time'] = 0,
		['commands'] = {
		}
	},
	{
		['time'] = 5,
		['commands'] = {
			{['c']='turn',['p']=Base, ['a']=x_axis, ['t']=0.232016, ['s']=0.696048},
			{['c']='turn',['p']=Base, ['a']=y_axis, ['t']=0.004894, ['s']=0.014683},
			{['c']='turn',['p']=Base, ['a']=z_axis, ['t']=0.250887, ['s']=0.032047},
			{['c']='move',['p']=Base, ['a']=y_axis, ['t']=-10.286314, ['s']=16.366669},
			{['c']='move',['p']=Base, ['a']=z_axis, ['t']=25.215321, ['s']=28.891800},
			{['c']='turn',['p']=CalfRight, ['a']=x_axis, ['t']=1.605359, ['s']=4.816078},
			{['c']='turn',['p']=CalfRight, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfRight, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Stomach, ['a']=x_axis, ['t']=-0.541880, ['s']=0.587425},
			{['c']='turn',['p']=Stomach, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Stomach, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=x_axis, ['t']=1.114193, ['s']=2.644143},
			{['c']='turn',['p']=CalfLeft, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Breast, ['a']=x_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Breast, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Breast, ['a']=z_axis, ['t']=0.161811, ['s']=0.485432},
			{['c']='turn',['p']=HipRight, ['a']=x_axis, ['t']=-0.286401, ['s']=0.859202},
			{['c']='turn',['p']=HipRight, ['a']=y_axis, ['t']=-0.000001, ['s']=0.000000},
			{['c']='turn',['p']=HipRight, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head, ['a']=x_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head, ['a']=z_axis, ['t']=0.432971, ['s']=1.298912},
			{['c']='turn',['p']=ArmLeft, ['a']=x_axis, ['t']=-0.192287, ['s']=1.014448},
			{['c']='turn',['p']=ArmLeft, ['a']=z_axis, ['t']=0.015827, ['s']=0.000000},
			{['c']='turn',['p']=HipLeft, ['a']=x_axis, ['t']=-0.094390, ['s']=0.283170},
			{['c']='turn',['p']=HipLeft, ['a']=y_axis, ['t']=-0.245644, ['s']=0.736933},
			{['c']='turn',['p']=HipLeft, ['a']=z_axis, ['t']=0.163177, ['s']=0.489530},
			{['c']='turn',['p']=ArmRight, ['a']=x_axis, ['t']=-0.083255, ['s']=1.066882},
			{['c']='turn',['p']=ArmRight, ['a']=y_axis, ['t']=0.413306, ['s']=0.676712},
			{['c']='turn',['p']=ArmRight, ['a']=z_axis, ['t']=0.238749, ['s']=0.331098},
		}
	},
	{
		['time'] = 15,
		['commands'] = {
			{['c']='move',['p']=Base, ['a']=y_axis, ['t']=-6.303279, ['s']=8.535074},
			{['c']='move',['p']=Base, ['a']=z_axis, ['t']=23.746590, ['s']=3.147281},
			{['c']='turn',['p']=CalfRight, ['a']=x_axis, ['t']=2.268937, ['s']=1.421952},
			{['c']='turn',['p']=CalfRight, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfRight, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Stomach, ['a']=x_axis, ['t']=-0.411610, ['s']=0.279149},
			{['c']='turn',['p']=Stomach, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Stomach, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=HandRight, ['a']=x_axis, ['t']=-0.298665, ['s']=0.639996},
			{['c']='turn',['p']=HandRight, ['a']=y_axis, ['t']=0.057640, ['s']=0.123514},
			{['c']='turn',['p']=HandRight, ['a']=z_axis, ['t']=-0.052757, ['s']=0.113051},
			{['c']='turn',['p']=CalfLeft, ['a']=x_axis, ['t']=1.883354, ['s']=1.648202},
			{['c']='turn',['p']=CalfLeft, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=HipRight, ['a']=x_axis, ['t']=-0.791779, ['s']=1.082954},
			{['c']='turn',['p']=HipRight, ['a']=y_axis, ['t']=-0.000001, ['s']=0.000000},
			{['c']='turn',['p']=HipRight, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=ArmLeft, ['a']=x_axis, ['t']=-0.419692, ['s']=0.487297},
			{['c']='turn',['p']=ArmLeft, ['a']=y_axis, ['t']=-0.208858, ['s']=0.000000},
			{['c']='turn',['p']=ArmLeft, ['a']=z_axis, ['t']=0.015827, ['s']=0.000000},
			{['c']='turn',['p']=HipLeft, ['a']=x_axis, ['t']=-0.641872, ['s']=1.173175},
			{['c']='turn',['p']=HipLeft, ['a']=y_axis, ['t']=-0.245644, ['s']=0.000000},
			{['c']='turn',['p']=HipLeft, ['a']=z_axis, ['t']=0.163177, ['s']=0.000000},
			{['c']='turn',['p']=Gun, ['a']=x_axis, ['t']=-0.221850, ['s']=0.475394},
			{['c']='turn',['p']=Gun, ['a']=y_axis, ['t']=-0.304574, ['s']=0.652659},
			{['c']='turn',['p']=Gun, ['a']=z_axis, ['t']=-0.036910, ['s']=0.079093},
		}
	},
	{
		['time'] = 29,
		['commands'] = {
			{['c']='move',['p']=Base, ['a']=y_axis, ['t']=-11.554915, ['s']=26.258180},
			{['c']='turn',['p']=CalfRight, ['a']=x_axis, ['t']=1.680374, ['s']=2.942814},
			{['c']='turn',['p']=CalfRight, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfRight, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=HandRight, ['a']=x_axis, ['t']=-0.603072, ['s']=1.522036},
			{['c']='turn',['p']=HandRight, ['a']=y_axis, ['t']=0.111299, ['s']=0.268299},
			{['c']='turn',['p']=HandRight, ['a']=z_axis, ['t']=-0.147644, ['s']=0.474433},
			{['c']='turn',['p']=AssLeft, ['a']=x_axis, ['t']=0.575311, ['s']=1.871441},
			{['c']='turn',['p']=AssLeft, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=AssLeft, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=x_axis, ['t']=1.425336, ['s']=2.290088},
			{['c']='turn',['p']=CalfLeft, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Breast, ['a']=x_axis, ['t']=0.186159, ['s']=0.930793},
			{['c']='turn',['p']=Breast, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Breast, ['a']=z_axis, ['t']=0.161811, ['s']=0.000000},
			{['c']='turn',['p']=HipRight, ['a']=x_axis, ['t']=-0.144300, ['s']=3.237398},
			{['c']='turn',['p']=HipRight, ['a']=y_axis, ['t']=-0.000001, ['s']=0.000000},
			{['c']='turn',['p']=HipRight, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=ArmLeft, ['a']=x_axis, ['t']=-0.921177, ['s']=2.507425},
			{['c']='turn',['p']=ArmLeft, ['a']=y_axis, ['t']=-0.108622, ['s']=0.501180},
			{['c']='turn',['p']=ArmLeft, ['a']=z_axis, ['t']=-0.047991, ['s']=0.319091},
			{['c']='turn',['p']=HipLeft, ['a']=x_axis, ['t']=-0.523475, ['s']=0.591982},
			{['c']='turn',['p']=HipLeft, ['a']=z_axis, ['t']=0.163177, ['s']=0.000000},
			{['c']='turn',['p']=ArmRight, ['a']=x_axis, ['t']=-0.697045, ['s']=3.068952},
			{['c']='turn',['p']=ArmRight, ['a']=y_axis, ['t']=0.503615, ['s']=0.451545},
			{['c']='turn',['p']=ArmRight, ['a']=z_axis, ['t']=0.051914, ['s']=0.934174},
			{['c']='turn',['p']=Gun, ['a']=x_axis, ['t']=-0.563546, ['s']=1.708478},
			{['c']='turn',['p']=Gun, ['a']=y_axis, ['t']=-0.222652, ['s']=0.409613},
			{['c']='turn',['p']=Gun, ['a']=z_axis, ['t']=0.061517, ['s']=0.492138},
		}
	},
	{
		['time'] = 35,
		['commands'] = {
			{['c']='turn',['p']=Base, ['a']=x_axis, ['t']=1.191343, ['s']=4.796636},
			{['c']='turn',['p']=Base, ['a']=y_axis, ['t']=0.004894, ['s']=0.000000},
			{['c']='turn',['p']=Base, ['a']=z_axis, ['t']=0.250887, ['s']=0.000000},
			{['c']='move',['p']=Base, ['a']=x_axis, ['t']=4.315906, ['s']=13.935559},
			{['c']='move',['p']=Base, ['a']=y_axis, ['t']=-21.297955, ['s']=48.715196},
			{['c']='move',['p']=Base, ['a']=z_axis, ['t']=15.503991, ['s']=41.212993},
			{['c']='turn',['p']=CalfRight, ['a']=x_axis, ['t']=0.670799, ['s']=5.047876},
			{['c']='turn',['p']=CalfRight, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfRight, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=HandRight, ['a']=x_axis, ['t']=-1.360638, ['s']=3.787832},
			{['c']='turn',['p']=HandRight, ['a']=y_axis, ['t']=0.111299, ['s']=0.000001},
			{['c']='turn',['p']=HandRight, ['a']=z_axis, ['t']=-0.147644, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=x_axis, ['t']=0.396744, ['s']=5.142960},
			{['c']='turn',['p']=CalfLeft, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Breast, ['a']=x_axis, ['t']=0.517826, ['s']=1.658337},
			{['c']='turn',['p']=Breast, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Breast, ['a']=z_axis, ['t']=0.161811, ['s']=0.000000},
			{['c']='turn',['p']=ArmLeft, ['a']=x_axis, ['t']=-1.242896, ['s']=1.608593},
			{['c']='turn',['p']=ArmLeft, ['a']=y_axis, ['t']=-0.108622, ['s']=0.000000},
			{['c']='turn',['p']=ArmLeft, ['a']=z_axis, ['t']=-0.047991, ['s']=0.000000},
			{['c']='turn',['p']=FootRight, ['a']=x_axis, ['t']=0.448296, ['s']=2.241478},
			{['c']='turn',['p']=FootRight, ['a']=y_axis, ['t']=0.000001, ['s']=0.000000},
			{['c']='turn',['p']=FootRight, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=ArmRight, ['a']=x_axis, ['t']=-1.191173, ['s']=2.470638},
			{['c']='turn',['p']=ArmRight, ['a']=y_axis, ['t']=0.503615, ['s']=0.000000},
			{['c']='turn',['p']=ArmRight, ['a']=z_axis, ['t']=0.051914, ['s']=0.000000},
			{['c']='turn',['p']=Gun, ['a']=x_axis, ['t']=-1.308940, ['s']=3.726971},
			{['c']='turn',['p']=Gun, ['a']=y_axis, ['t']=-0.222652, ['s']=0.000000},
			{['c']='turn',['p']=Gun, ['a']=z_axis, ['t']=0.061517, ['s']=0.000000},
		}
	},
	{
		['time'] = 41,
		['commands'] = {
			{['c']='turn',['p']=Base, ['a']=x_axis, ['t']=1.511230, ['s']=2.399147},
			{['c']='turn',['p']=Base, ['a']=y_axis, ['t']=0.004894, ['s']=0.000000},
			{['c']='turn',['p']=Base, ['a']=z_axis, ['t']=0.250887, ['s']=0.000000},
			{['c']='move',['p']=Base, ['a']=y_axis, ['t']=-25.564775, ['s']=32.001157},
			{['c']='move',['p']=Base, ['a']=z_axis, ['t']=7.163431, ['s']=62.554203},
			{['c']='turn',['p']=CalfRight, ['a']=x_axis, ['t']=0.215270, ['s']=3.416467},
			{['c']='turn',['p']=CalfRight, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfRight, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=FootLeft, ['a']=x_axis, ['t']=0.205250, ['s']=2.591299},
			{['c']='turn',['p']=FootLeft, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=FootLeft, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=x_axis, ['t']=0.168139, ['s']=1.714537},
			{['c']='turn',['p']=CalfLeft, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=CalfLeft, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=ArmLeft, ['a']=x_axis, ['t']=-1.695927, ['s']=3.397732},
			{['c']='turn',['p']=ArmLeft, ['a']=y_axis, ['t']=-0.003014, ['s']=0.792059},
			{['c']='turn',['p']=ArmLeft, ['a']=z_axis, ['t']=0.707491, ['s']=5.666117},
			{['c']='turn',['p']=HipLeft, ['a']=x_axis, ['t']=-0.615074, ['s']=0.686993},
			{['c']='turn',['p']=HipLeft, ['a']=z_axis, ['t']=0.163177, ['s']=0.000000},
			{['c']='turn',['p']=ArmRight, ['a']=x_axis, ['t']=-1.601538, ['s']=3.077738},
			{['c']='turn',['p']=ArmRight, ['a']=y_axis, ['t']=0.078940, ['s']=3.185058},
			{['c']='turn',['p']=ArmRight, ['a']=z_axis, ['t']=-1.185024, ['s']=9.277040},
		}
	},
	{
		['time'] = 45,
		['commands'] = {
		}
	},
}

---------------------------------------------------------------------
---  blender-exported animation: framework code             ---------
---------------------------------------------------------------------

local animCmd = {['turn']=Turn,['move']=Move};
function PlayAnimation(animname)
    local anim = Animations[animname];
    for i = 1, #anim do
        local commands = anim[i].commands;
        for j = 1,#commands do
            local cmd = commands[j];
            animCmd[cmd.c](cmd.p,cmd.a,cmd.t,cmd.s);
        end
        if(i < #anim) then
            local t = anim[i+1]['time'] - anim[i]['time'];
            Sleep(t*33); -- sleep works on milliseconds
        end
    end
end

function constructSkeleton(unit, piece, offset)
    if (offset == nil) then
        offset = {0,0,0};
    end

    local bones = {};
    local info = Spring.GetUnitPieceInfo(unit,piece);

    for i=1,3 do
        info.offset[i] = offset[i]+info.offset[i];
    end

    bones[piece] = info.offset;
    local map = Spring.GetUnitPieceMap(unit);
    local children = info.children;

    if (children) then
        for i, childName in pairs(children) do
            local childId = map[childName];
            local childBones = constructSkeleton(unit, childId, info.offset);
            for cid, cinfo in pairs(childBones) do
                bones[cid] = cinfo;
            end
        end
    end
    return bones;
end

---------------------------------------------------------------------
-- Walking

local BASE_PACE = 2.18
local BASE_VELOCITY = UnitDefNames.benzcom1.speed or 1.25*30
local VELOCITY = UnitDefs[unitDefID].speed or BASE_VELOCITY
local PACE = BASE_PACE * VELOCITY/BASE_VELOCITY

local SLEEP_TIME = 935*10/30 -- Empirically determined

local walkCycle = 1 -- Alternate between 1 and 2

local walkAngle = {
	{ -- Moving forwards
		wait = HipLeft,
		{
			hip = {math.rad(-28), math.rad(40) * PACE},
			leg = {math.rad(80), math.rad(100) * PACE},
			foot = {math.rad(15), math.rad(150) * PACE},
			arm = {math.rad(-5), math.rad(20) * PACE},
			hand = {math.rad(0), math.rad(20) * PACE},
		},
		{
			hip = {math.rad(-64), math.rad(30) * PACE},
			leg = {math.rad(16), math.rad(90) * PACE},
			foot = {math.rad(-40), math.rad(180) * PACE},
		},
	},
	{ -- Moving backwards
		wait = HipRight,
		{
			hip = {math.rad(4), math.rad(35) * PACE},
			leg = {math.rad(2), math.rad(50) * PACE},
			foot = {math.rad(10), math.rad(40) * PACE},
			arm = {math.rad(20), math.rad(20) * PACE},
			hand = {math.rad(-25), math.rad(20) * PACE},
		},
		{
			hip = {math.rad(10), math.rad(35) * PACE},
			leg = {math.rad(15), math.rad(25) * PACE},
			foot = {math.rad(60), math.rad(30) * PACE},
		}
		
	},
}

local function Walk()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	
	local scaleMult = dyncomm.GetScale()
	
	while true do
		walkCycle = 3 - walkCycle
		local speedMult = math.max(0.05, (Spring.GetUnitRulesParam(unitID,"totalMoveSpeedChange") or 1)*dyncomm.GetPace()) * 0.96
		
		local left = walkAngle[walkCycle]
		local right = walkAngle[3 - walkCycle]
		-----------------------------------------------------------------------------------
		
		Turn(HipLeft, x_axis,  left[1].hip[1],  left[1].hip[2] * speedMult)
		Turn(CalfLeft, x_axis, left[1].leg[1],  left[1].leg[2] * speedMult)
		Turn(FootLeft, x_axis, left[1].foot[1], left[1].foot[2] * speedMult)
		
		Turn(HipRight, x_axis,  right[1].hip[1],  right[1].hip[2] * speedMult)
		Turn(CalfRight, x_axis, right[1].leg[1],  right[1].leg[2] * speedMult)
		Turn(FootRight, x_axis,  right[1].foot[1], right[1].foot[2] * speedMult)
		
		if not aiming then
		    Turn(ArmLeft, x_axis, left[1].arm[1],  left[1].arm[2] * speedMult)
			Turn(HandRight, x_axis, right[1].hand[1], right[1].hand[2] * speedMult)
			
			Turn(Stomach, x_axis, math.rad(30), 1 * speedMult)
			Turn(Head, x_axis, math.rad(-30), 1 * speedMult)
			Turn(Gun, z_axis, math.rad(90), 10 * speedMult)
            Spin(undersunburst, z_axis, 1)
			Spin(underdisintegrator, z_axis, 1)
		end
		
		Move(Base, z_axis, 0.5 * scaleMult, 40 * speedMult * scaleMult)
		
		--WaitForTurn(left.wait, x_axis)
		--Spring.Echo(Spring.GetGameFrame())
		Sleep(SLEEP_TIME / speedMult)
		-----------------------------------------------------------------------------------
		
		Turn(HipLeft, x_axis,  left[2].hip[1],  left[2].hip[2] * speedMult)
		Turn(CalfLeft, x_axis, left[2].leg[1],  left[2].leg[2] * speedMult)
		Turn(FootLeft, x_axis, left[2].foot[1], left[2].foot[2] * speedMult)
		
		Turn(HipRight, x_axis,  right[2].hip[1],  right[2].hip[2] * speedMult)
		Turn(CalfRight, x_axis, right[2].leg[1],  right[2].leg[2] * speedMult)
		Turn(FootRight, x_axis,  right[2].foot[1], right[2].foot[2] * speedMult)
		
		if not aiming then
			Turn(Stomach, x_axis, math.rad(15), 1 * speedMult)
			Turn(Head, x_axis, math.rad(-15), 1 * speedMult)
		end
		
		Move(Base, z_axis, 0.5 * scaleMult, 40 * speedMult * scaleMult)
		
		--WaitForTurn(left.wait, x_axis)
		--Spring.Echo(Spring.GetGameFrame())
		Sleep(SLEEP_TIME / speedMult)
	end
end

local function RestoreLegs()
	Signal(SIG_WALK)
	SetSignalMask(SIG_WALK)
	
	Turn(HipLeft,  x_axis, 0, 1)
	Turn(CalfLeft, x_axis, 0, 3)
	Turn(FootLeft, x_axis, 0, 2.5)
	
	Turn(HipRight,  x_axis, 0, 1)
	Turn(CalfRight, x_axis, 0, 3)
	Turn(FootRight, x_axis, 0, 2.5)
	
	if not aiming then
	    Turn(Stomach, x_axis, math.rad(0), 1)
	    Turn(Head, x_axis, math.rad(0), 1)
	end
	Move(Base, z_axis, 0, 4)
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(RestoreLegs)
end

local function trimstring(weaponname)
	weaponname = string.lower(weaponname)
	weaponname = weaponname:gsub("_", "")
	weaponname = weaponname:gsub("commweapon", "")
	weaponname = weaponname:gsub("%d+", "")
	return weaponname
end

local function HideAllWeapons()
	Hide(Gun)
	Hide(UnderGun)
	Hide(busterdisrupt)
	Hide(tankbuster) -- hide Gun UnderGun
	Hide(undertankbuster) -- hide Gun UnderGun
	Hide(underbusterdisrupt) -- hide Gun UnderGun tankbuster undertankbuster
	Hide(heavyrifle)
	Hide(underheavyrifle)
	Hide(heavyrifledisrupt)
	Hide(underheavyrifledisrupt)
	Hide(lightninggun)
	Hide(underlightninggun)
	Hide(lightninggunimproved)
	Hide(underlightninggunimproved)
	Hide(shotgun)
	Hide(undershotgun)
	Hide(shotgundisrupt)
	Hide(undershotgundisrupt)
	-- Right hand --
	Hide(disintegrator) -- hide HandRight FingerA FingerB FingerC
	Hide(underdisintegrator)
	Hide(disintegratorFingerA)
	Hide(disintegratorFingerB)
	Hide(disintegratorFingerC)
	Hide(minefieldinacan)
	Hide(underminefieldinacan)
	Hide(multistunner)
	Hide(undermultistunner)
	Hide(rightbusterdisrupt)
	Hide(rightunderbusterdisrupt)
	Hide(rightheavyrifle)
	Hide(rightunderheavyrifle)
	Hide(rightheavyrifledisrupt)
	Hide(rightunderheavyrifledisrupt)
	Hide(rightlightninggun)
	Hide(rightunderlightninggun)
	Hide(rightlightninggunimproved)
	Hide(rightunderlightninggunimproved)
	Hide(rightshotgun)
	Hide(rightundershotgun)
	Hide(rightshotgundisrupt)
	Hide(rightundershotgundisrupt)
	Hide(righttankbuster)
	Hide(rightundertankbuster)
	Hide(sunburst)
	Hide(undersunburst)
end

local function HideModules()
	Hide(ablativearmor0)
	Hide(ablativearmor3)
	Hide(ablativearmor6)
	Hide(ablativearmor8)
	Hide(advnano3)
	Hide(advnano6)
	Hide(advnano8)
	Hide(advtargeting3)
	Hide(advtargeting6)
	Hide(advtargeting8)
	Hide(autorepair3)
	Hide(autorepair6)
	Hide(autorepair8)
	Hide(cloakrepair0)
	Hide(cloakrepair3)
	Hide(cloakrepair6)
	Hide(cloakrepair8)
	Hide(dmgbooster3)
	Hide(dmgbooster6)
	Hide(dmgbooster8)
	Hide(detpack1)
	Hide(detpack2)
	Hide(detpack3)
	Hide(powerservos31)
	Hide(powerservos32)
	Hide(powerservos61)
	Hide(powerservos62)
	Hide(powerservos81)
	Hide(powerservos82)
	Hide(jammer1)
	Hide(strikeservos3)
	Hide(strikeservos6)
	Hide(strikeservos8)
end

local function UpdateModulesThread()
	while Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1") == nil do -- script.Create is called before unit_commander_upgrade.lua sets our data.
		Sleep(33)
	end
	HideModules()
	-- modules -- module_high_power_servos
	local ablativearmorcount = Spring.GetUnitRulesParam(unitID, "module_ablative_armor_count")             or 0 
	local advnanocount       = Spring.GetUnitRulesParam(unitID, "module_adv_nano_count")                   or 0 
	local advtargetingcount  = Spring.GetUnitRulesParam(unitID, "module_adv_targeting_count")              or 0 
	local autorepaircount    = Spring.GetUnitRulesParam(unitID, "module_autorepair_count")                 or 0 
	local cloakrepaircount   = Spring.GetUnitRulesParam(unitID, "module_cloakregen_count")                 or 0 
	local detpackcount       = Spring.GetUnitRulesParam(unitID, "module_detpack_count")                    or 0 
	local damageboostercount = Spring.GetUnitRulesParam(unitID, "module_dmg_booster_count")                or 0 
	local servoscount        = Spring.GetUnitRulesParam(unitID, "module_high_power_servos_count")          or 0 
	local strikecount        = Spring.GetUnitRulesParam(unitID, "module_high_power_servos_improved_count") or 0 
	local hasRadarStealth    = (Spring.GetUnitRulesParam(unitID, "module_personaljammer_count") or 0) == 1            
	
	--Spring.Echo("Module Count: " .. ablativearmorcount, advnanocount, advtargetingcount, autorepaircount, cloakrepaircount, detpackcount, damageboostercount, servoscount, strikecount, hasRadarStealth)
	
	-- Set up modules. PERKELEEN PERKELE LEOJ.
	if ablativearmorcount < 3 then
		Show(ablativearmor0)
	elseif ablativearmorcount < 6 then
		Show(ablativearmor3)
	elseif ablativearmorcount < 8 then
	    Show(ablativearmor3)
		Show(ablativearmor6)
	else
		Show(ablativearmor8)
	end
    if advnanocount < 3 then
	    Show(Stomach)
	elseif advnanocount < 6 then
		Show(advnano3)
	elseif advnanocount < 8 then
	    Hide(ArmLeft)
		Show(advnano6)
	else
	    Hide(ArmLeft)
	    Show(advnano6)
		Show(advnano8)
	end
    if advtargetingcount < 3 then
	    Show(Stomach)
	elseif advtargetingcount < 6 then
	    Show(advtargeting3)
	elseif advtargetingcount < 8 then
	    Show(advtargeting6)
	else
	    Show(advtargeting8)
	end
    if autorepaircount < 3 then
	    Show(Stomach)
	elseif autorepaircount < 6 then
	    Show(autorepair3)
	elseif autorepaircount < 8 then
	    Show(autorepair3)
	    Show(autorepair6)
	else
	    Show(autorepair3)
		Show(autorepair6)
	    Show(autorepair8)
	end
	if cloakrepaircount < 3 then
		Show(cloakrepair0)
	elseif cloakrepaircount < 6 then
		Show(cloakrepair3)
	elseif cloakrepaircount <= 7 then
		Show(cloakrepair6)
	else
		Show(cloakrepair8)
		Hide(Breast)
	end
    if damageboostercount < 3 then
	    Show(Stomach)
	elseif damageboostercount < 6 then
	    Show(dmgbooster3)
	elseif damageboostercount < 8 then
	    Show(dmgbooster6)
	else
	    Show(dmgbooster8)
	end
	if detpackcount >= 1 then
		Show(detpack1)
	end
	if detpackcount >= 2 then
		Show(detpack2)
	end
	if detpackcount >= 3 then
		Show(detpack3)
	end
	if servoscount > 2 then
		Show(powerservos31)
		Show(powerservos32)
		Hide(FootLeft)
		Hide(FootRight)
	end
	if servoscount > 6 then
		Hide(CalfLeft)
		Hide(CalfRight)
		Show(powerservos61)
		Show(powerservos62)
	end
	if servoscount == 8 then
		Hide(HipLeft)
		Hide(HipRight)
		Show(powerservos81)
		Show(powerservos82)
	end
	if strikecount > 2 then
		Show(strikeservos3)
	end
	if strikecount > 5 then
		Show(strikeservos6)
	end
	if strikecount == 8 then
		Show(strikeservos8)
	end
	if hasRadarStealth then
		Show(jammer1)
	end
end


local function UpdateWeaponsThread()
	HideAllWeapons()
	while Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1") == nil do -- script.Create is called before unit_commander_upgrade.lua sets our data.
		Sleep(33)
	end
	local weaponname1 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_1") or "heavyrifle"
	local weaponname2 = Spring.GetUnitRulesParam(unitID, "comm_weapon_name_2") or ""
	if weaponname1 == "commweapon_light_disintegrator" then
		weaponname1 = "commweapon_lightninggun"
	elseif weaponname1 == "commweapon_disintegrator" then
		weaponname1 = "commweapon_lightninggun"
	end
	if weaponname2 == "commweapon_light_disintegrator" then
		weaponname2 = "commweapon_lightninggun"
	end
	weaponname1 = trimstring(weaponname1)
	if weaponname2 ~= "" then
		weaponname2 = trimstring(weaponname2)
	end
	if weaponname2 == "microriftgenerator" then -- microrift isn't a "weapon"
		weaponname2 = ""
		instantaimweapon2 = true
	end
	--Spring.Echo("Weapons: " .. tostring(weaponname1), weaponname2)
	for key, piece in ipairs(WeaponsRight[weaponname1]) do Show(piece) end
	if weaponname2 ~= "" then
		Hide(HandRight)
		Hide(FingerA)
		Hide(FingerB)
		Hide(FingerC)
		for key, piece in ipairs(WeaponsLeft[weaponname2]) do Show(piece) end
	end
end

function OnMorphComplete()
	StartThread(UpdateModulesThread)
	StartThread(UpdateWeaponsThread)
end

---------------------------------------------------------------------
---------------------------------------------------------------------
-- Aiming and Firing

function script.AimFromWeapon(num)
	if dyncomm.IsManualFire(num) then
		if dyncomm.GetWeapon(num) == 1 then
			return Palm
		elseif dyncomm.GetWeapon(num) == 2 then
			return RightMuzzle
		end
	end
	return Shield
end

function script.QueryWeapon(num)
	if dyncomm.GetWeapon(num) == 1 then
		return Muzzle
	elseif dyncomm.GetWeapon(num) == 2 then
		return RightMuzzle
	end
	return Shield
end

local function RestoreTorsoAim(sleepTime)
	Signal(SIG_RESTORE_TORSO)
	SetSignalMask(SIG_RESTORE_TORSO)
	Sleep(sleepTime or RESTORE_DELAY)
	if not nanoing then
		Turn(Breast, z_axis, 0, TORSO_SPEED_YAW)
		aiming = false
	end
end

local function RestoreRightAim(sleepTime)
	StartThread(RestoreTorsoAim, sleepTime)
	Signal(SIG_RESTORE_RIGHT)
	SetSignalMask(SIG_RESTORE_RIGHT)
	Sleep(sleepTime or RESTORE_DELAY)
	Spin(undermultistunner, z_axis, 0)
	Turn(disintegratorFingerA, x_axis, math.rad(0), 2 * ARM_SPEED_PITCH)
	Turn(disintegratorFingerB, x_axis, math.rad(0), 2 * ARM_SPEED_PITCH)
	Turn(disintegratorFingerC, x_axis, math.rad(0), 2 * ARM_SPEED_PITCH)	
	if not nanoing then
		Turn(ArmLeft, x_axis, math.rad(-5), ARM_SPEED_PITCH)
		Turn(HandRight, x_axis, math.rad(-5), ARM_SPEED_PITCH)
	end
end

local function RestoreLeftAim(sleepTime)
	StartThread(RestoreTorsoAim, sleepTime)
	Signal(SIG_RESTORE_LEFT)
	SetSignalMask(SIG_RESTORE_LEFT)
	Sleep(sleepTime or RESTORE_DELAY)
	Turn(ArmRight, x_axis, math.rad(-5), ARM_SPEED_PITCH)
	Turn(Gun, x_axis, math.rad(-5), ARM_SPEED_PITCH)
end

local function AimArm(heading, pitch, arm, hand, wait)
	aiming = true
	Turn(Head, x_axis, math.rad(0), ARM_SPEED_PITCH)
	Turn(Stomach, x_axis, math.rad(0), ARM_SPEED_PITCH)
	Turn(arm, x_axis, -pitch, ARM_SPEED_PITCH)
	Turn(Breast, z_axis, heading, TORSO_SPEED_YAW)
	if wait then
		WaitForTurn(Breast, z_axis)
		WaitForTurn(arm, x_axis)
	end
end

local overriden = false

local function StartPriorityAim(num)
	priorityAim = true
	priorityAimNum = num
	Sleep(5000)
	priorityAim = false
end

function script.AimWeapon(num, heading, pitch) 
	local weaponNum = dyncomm.GetWeapon(num)
	GG.DontFireRadar_CheckAim(unitID)
	if weaponNum == 3 then
		return true
	end
	if priorityAim and weaponNum ~= priorityAimNum then
		return false
	end
	if weaponNum and dyncomm.IsManualFire(num) and not priorityAim and dyncomm.PriorityAimCheck(num) then
		StartThread(StartPriorityAim, weaponNum)
		if weaponNum == 1 then
			Signal(SIG_DGUN)
		else
			Signal(SIG_LASER)
		end
	end
	if weaponNum == 1 then
		Signal(SIG_LEFT)
		SetSignalMask(SIG_LEFT)
		Signal(SIG_RESTORE_LEFT)
		Signal(SIG_RESTORE_TORSO)
		AimArm(heading, pitch, ArmRight, Gun, true)
		Turn(Gun, z_axis, math.rad(0), 2 * ARM_SPEED_PITCH)
		WaitForTurn(Gun, z_axis)
		StartThread(RestoreLeftAim)
		return true
	elseif weaponNum == 2 then
		if instantaimweapon2 then
			if not overriden then
				GG.Microrifts_AddUnitOverride(unitID, num)
				overriden = true
			end
			return true
		end
		Signal(SIG_RIGHT)
		SetSignalMask(SIG_RIGHT)
		Signal(SIG_RESTORE_RIGHT)
		Signal(SIG_RESTORE_TORSO)
		AimArm(heading, pitch, ArmLeft, HandRight, true)
		Turn(HandRight, x_axis, math.rad(-90), 2 * ARM_SPEED_PITCH)
		Spin(undermultistunner, z_axis, 12)
		Spin(undersunburst, z_axis, 4)
		Turn(disintegratorFingerA, x_axis, math.rad(-40), 2 * ARM_SPEED_PITCH)
		Turn(disintegratorFingerB, x_axis, math.rad(-40), 2 * ARM_SPEED_PITCH)
		Turn(disintegratorFingerC, x_axis, math.rad(-40), 2 * ARM_SPEED_PITCH)
		WaitForTurn(HandRight, x_axis)
		StartThread(RestoreRightAim)
		return true
	end
	return false
end

function script.FireWeapon(num)
	local weaponNum = dyncomm.GetWeapon(num)
	if weaponNum == 1 then
		dyncomm.EmitWeaponFireSfx(Muzzle, num)
	elseif weaponNum == 2 then
		dyncomm.EmitWeaponFireSfx(RightMuzzle, num)
	end
end

function script.Shot(num)
	local weaponNum = dyncomm.GetWeapon(num)
	if dyncomm.IsManualFire(num) then
		priorityAim = false
	end
	if weaponNum == 1 then
		dyncomm.EmitWeaponShotSfx(Muzzle, num)
	elseif weaponNum == 2 then
		dyncomm.EmitWeaponShotSfx(RightMuzzle, num)
	end
end

local function NanoAnimation()
	Signal(SIG_NANO)
	SetSignalMask(SIG_NANO)
	while true do
	    Turn(Stomach, x_axis, math.rad(0), 1)
		Turn(Head, x_axis, math.rad(0), 1)
		Turn(ArmLeft, x_axis, math.rad(15), 1)
		Turn(HandRight, x_axis, math.rad(-75), 1)
		Turn(FingerA, x_axis, FINGER_ANGLE_OUT, FINGER_SPEED)
		Sleep(200)
		Turn(FingerB, x_axis, FINGER_ANGLE_IN, FINGER_SPEED)
		Sleep(200)
		Turn(FingerC, x_axis, FINGER_ANGLE_OUT, FINGER_SPEED)
		Sleep(200)
		Turn(FingerA, x_axis, FINGER_ANGLE_IN, FINGER_SPEED)
		Sleep(200)
		Turn(FingerB, x_axis, FINGER_ANGLE_OUT, FINGER_SPEED)
		Sleep(200)
		Turn(FingerC, x_axis, FINGER_ANGLE_IN, FINGER_SPEED)
		Sleep(200)
	end
end

local function NanoRestore()
	Signal(SIG_NANO)
	SetSignalMask(SIG_NANO)
	Sleep(500)
	Turn(ArmLeft, x_axis, math.rad(0), 1)
	Turn(HandRight, x_axis, math.rad(0), 1)
	Turn(FingerA, x_axis, 0, FINGER_SPEED)
	Turn(FingerB, x_axis, 0, FINGER_SPEED)
	Turn(FingerC, x_axis, 0, FINGER_SPEED)
end
	
function script.StopBuilding()
	SetUnitValue(COB.INBUILDSTANCE, 0)
	StartThread(RestoreRightAim, 200)
	StartThread(NanoRestore)
	nanoing = false
end

function script.StartBuilding(heading, pitch)
	AimArm(heading, pitch, ArmLeft, HandRight, false)
	SetUnitValue(COB.INBUILDSTANCE, 1)
	StartThread(NanoAnimation)
	nanoing = true
end

function script.BlockShot(num, targetID)
	local weaponNum = dyncomm.GetWeapon(num)
	--Spring.Echo(unitID .. ": BlockShot: " .. weaponNum)
	local radarcheck = (targetID and GG.DontFireRadar_CheckBlock(unitID, targetID)) and true or false
	local battery = false
	if needsBattery then
		battery = GG.BatteryManagement.CanFire(unitID, weaponNum)
	end
	local okp = false
	if okpconfig and okpconfig[weaponNum] and okpconfig[weaponNum].useokp and targetID then
		okp = GG.OverkillPrevention_CheckBlock(unitID, targetID, okpconfig[weaponNum].damage, okpconfig[weaponNum].timeout, okpconfig[weaponNum].speedmult, okpconfig[weaponNum].structureonly) or false -- (unitID, targetID, damage, timeout, fastMult, radarMult, staticOnly)
		--Spring.Echo("OKP: " .. tostring(okp))
	end
	return okp or radarcheck or battery
end

---------------------------------------------------------------------
---------------------------------------------------------------------
-- Creation and Death

function script.Create()
	local map = Spring.GetUnitPieceMap(unitID);
	local offsets = constructSkeleton(unitID,map.Scene, {0,0,0});
	Spin(detpack1, z_axis, 1)
	Spin(detpack3, z_axis, -2)
	needsBattery = dyncomm.SetUpBattery()
    for a,anim in pairs(Animations) do
        for i,keyframe in pairs(anim) do
            local commands = keyframe.commands;
            for k,command in pairs(commands) do
                -- commands are described in (c)ommand,(p)iece,(a)xis,(t)arget,(s)peed format
                -- the t attribute needs to be adjusted for move commands from blender's absolute values
                if (command.c == "move") then
                    local adjusted =  command.t - (offsets[command.p][command.a]);
                    Animations[a][i]['commands'][k].t = command.t - (offsets[command.p][command.a]);
                end
            end
        end
    end
    
    Turn(Muzzle, x_axis, math.rad(180))
    Turn(RightMuzzle,x_axis, math.rad(180))
	
	dyncomm.Create()
	StartThread(GetOKP)
	OnMorphComplete()
	Spring.SetUnitNanoPieces(unitID, nanoPieces)
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	local x, y, z = Spring.GetUnitPosition(unitID)
	if severity < 0.5 then
		GG.Script.InitializeDeathAnimation(unitID)
		PlayAnimation('die')
	end
	local assetDenialSystemActivated = dyncomm.Explode(x, y, z)
	if severity < 0.5 and not assetDenialSystemActivated then
		dyncomm.SpawnWreck(1)
	else
		Explode(Head, SFX.FALL + SFX.FIRE)
		Explode(Stomach, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(ArmLeft, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(ArmRight, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(HandRight, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(Gun, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(CalfLeft, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(CalfRight, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(HipLeft, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(HipRight, SFX.FALL + SFX.FIRE + SFX.SMOKE + SFX.EXPLODE)
		Explode(Breast, SFX.SHATTER + SFX.EXPLODE)
		if not assetDenialSystemActivated then
			dyncomm.SpawnWreck(2)
		end
	end
end
