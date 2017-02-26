$ModelName "chamberdoor\chamberdoor.mdl"
$Scale 32
$body chamber "chamberdoor.smd"
$staticprop
$surfaceprop "glass"
$cdmaterials "chamberdoor"
$sequence idle "chamber_idle.smd" loop fps 1
$collisionmodel "chamberdoor.smd"
{
	$automass
}