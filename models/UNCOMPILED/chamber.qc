$ModelName "chamber\chamber.mdl"
$Scale 32
$body chamber "chamber.smd"
$staticprop
$surfaceprop "metal"
$cdmaterials "chamber"
$sequence idle "chamber_idle.smd" loop fps 1
$collisionmodel "chamber_physics.smd"
{
	$concave
	$automass
}