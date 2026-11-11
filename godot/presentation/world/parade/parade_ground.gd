class_name ParadeGround
extends Node3D
## The parade ground itself: a slab for the deck, with the army's crest, a lit
## ring and a disc, in the middle. Stand-ins for the island of the Flutter
## parade, until a model of it exists.

## The crest's outer radius, and how thick its ring is.
const CREST_RADIUS := 1.1
const CREST_THICKNESS := 0.1

var deck := MeshInstance3D.new()
var crest := MeshInstance3D.new()


func _init() -> void:
	name = &"Ground"
	var width := ParadeLayout.ISLAND * ParadeLayout.CELL + 2.0 * ParadeLayout.RIM
	var slab := BoxMesh.new()
	slab.size = Vector3(width, ParadeLayout.DEPTH, width)
	deck.name = &"Deck"
	deck.mesh = slab
	deck.position.y = -ParadeLayout.DEPTH / 2.0
	var stone := StandardMaterial3D.new()
	stone.albedo_color = WorldPalette.GROUND
	stone.roughness = 0.9
	deck.material_override = stone
	var ring := TorusMesh.new()
	ring.outer_radius = CREST_RADIUS
	ring.inner_radius = CREST_RADIUS - CREST_THICKNESS
	crest.name = &"Crest"
	crest.mesh = ring
	crest.position = ParadeLayout.at(ParadeLayout.CREST) + Vector3(0.0, CREST_THICKNESS / 2.0, 0.0)
	var light := StandardMaterial3D.new()
	light.albedo_color = WorldPalette.CREST
	light.emission_enabled = true
	light.emission = WorldPalette.CREST
	light.emission_energy_multiplier = 0.8
	crest.material_override = light
	add_child(deck)
	add_child(crest)
