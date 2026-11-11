class_name BaseShadows
extends RefCounted
## Which meshes of the base are not worth their shadows. The key light's
## shadows cost a pass each, in two cascades.

## The meshes whose shadows are not worth their triangles in each of the
## two shadow passes: glowing trims and algae, too thin to see; the deck,
## which only shadows itself; the island's rocks, mostly under the deck,
## and its coral, small on the rims. The buildings and the rampart keep
## theirs: 124k triangles drawn, 88k more for the shadows, not 211k.
const NO_SHADOW: Array[String] = [
	"*_glow", "*_glow_pink", "*_algae", "Island_stone", "Island_rock", "Island_coral",
]


## Turns off the shadows of the meshes of [param model] that are not worth
## them.
static func quiet(model: Node) -> void:
	for node: Node in model.find_children("*", "GeometryInstance3D", true, false):
		for pattern in NO_SHADOW:
			if String(node.name).match(pattern):
				(node as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
