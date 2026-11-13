class_name MapSurroundings
extends Node3D
## What lives round the slab of a level and over it, apart from the cells: the
## scenery of its edge and far off (the backdrop), the creature that swims by
## and the specks drifting in the water (marine snow, bubbles or ash). All
## three follow the level on show.

var backdrop := MapBackdrop.new()
var ambient := MapAmbient.new()
var specks := LevelSpecks.new()


func _init() -> void:
	name = &"Surroundings"
	for part: Node in [backdrop, ambient, specks]:
		add_child(part)


## Dresses a map of [param width] by [param height] cells as [param level].
func show_level(level: int, width: int, height: int) -> void:
	backdrop.show_level(level, width, height)
	ambient.show_level(level, width, height)
	specks.show_level(level, width, height)


## Lets the scenery take the shadows of what stands on the map, or not.
func receive_shadows(on: bool) -> void:
	backdrop.receive_shadows(on)


## Lets the specks drift, or stops and hides them (the quality panel's setting).
func set_particles(enabled: bool) -> void:
	specks.set_running(enabled)
