$ModelName "chamberdoor\chamberdoor.mdl"
$Scale 40
$body chamber "chamberdoor.smd"
$staticprop
$surfaceprop "metal"
$cdmaterials "chamberdoor"
$sequence idle "chamber_idle.smd" loop fps 1
$collisionmodel "chamberdoor.smd"
{
	$automass
}