class_name MapLayers
extends Node3D
## A part of the map laid in [MapLayer]s that the shadows of what stands on the
## cells fall on: the floor, the scenery round it. It fills most of the screen,
## and the Compatibility renderer (the web's) draws a second time every lit
## surface that receives shadows, so it takes them only while the view is close
## ([MapCamera.zoomed]), when the contents cast theirs: from far they cast none.
## The layers stay from a draw to the next while what decides them does not
## change ([Drawn]), and those kept follow the shadows as those laid anew.

## Whether the layers take shadows: those laid later do as those laid.
var _receiving := false
## What the layers were laid for.
var _laid := Drawn.new()


## Lets the layers take shadows, or not.
func receive_shadows(on: bool) -> void:
	_receiving = on
	for layer: MapLayer in get_children():
		layer.receive_shadows(on)


## Takes the layers away, for others to be laid.
func _clear() -> void:
	for child: Node in get_children():
		child.free()


## Lays [param mesh] at each of [param places] (Transform3D) as the layer
## [param part_name].
func _lay(part_name: StringName, mesh: Mesh, places: Array) -> void:
	add_child(MapLayer.new(part_name, mesh, places, _receiving))
